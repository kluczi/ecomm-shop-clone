"""Browser interactions shared by the PrestaShop E2E scenarios."""

import json
import os
import random
import re
from decimal import Decimal
from functools import cache
from pathlib import Path
from urllib.parse import parse_qs, urlparse

from playwright.sync_api import expect

CATEGORY_NAMES = ("Dom", "Ogród")
ADD_TO_CART = '#add-to-cart-or-refresh [data-button-action="add-to-cart"]'
SEARCH_FIELD = '#header #search_widget input[name="s"]'


def visit(page, path):
    response = page.goto(path, wait_until="domcontentloaded")
    assert response is not None and response.ok, "The requested shop page did not load"
    expect(page.locator("body")).to_be_visible()


def shop_url(page, name):
    return page.evaluate("name => prestashop.urls.pages[name]", name)


def category_urls(page):
    visit(page, "./")
    visit(page, shop_url(page, "sitemap"))
    sitemap = page.locator(".sitemap")
    categories = []
    for name in CATEGORY_NAMES:
        link = sitemap.get_by_role("link", name=name, exact=True)
        expect(link).to_be_visible()
        categories.append(link.evaluate("element => element.href"))
    assert len(set(categories)) == len(CATEGORY_NAMES)
    return categories


def product_data(page):
    return json.loads(page.locator("#product-details").get_attribute("data-product"))


@cache
def catalog_weights():
    # Classic omits weight from the product data embedded on the storefront.
    default_catalog = (
        Path(__file__).resolve().parents[1] / "scraper-results" / "products.json"
    )
    catalog = Path(
        os.environ.get("E2E_CATALOG_PATH", str(default_catalog))
    ).expanduser()
    if not catalog.is_file():
        return {}

    return {
        str(product.get("sku") or f"TOP-{product['id']}"): Decimal(
            str(product.get("weight_kg") or 0)
        )
        for product in json.loads(catalog.read_text(encoding="utf-8"))
    }


def candidates(page):
    return page.locator(
        "#js-product-list article.product-miniature .product-title a"
    ).evaluate_all("links => links.map(link => link.href)")


def available_product(page, url, excluded, quantity):
    visit(page, url)
    data = product_data(page)
    product_id = int(data["id_product"])
    reported_weight = data.get("weight")
    weight = (
        Decimal(str(reported_weight))
        if reported_weight is not None and reported_weight != ""
        else catalog_weights().get(data.get("reference"))
    )
    if (
        product_id in excluded
        or int(data.get("quantity") or 0) < quantity
        or int(data.get("id_product_attribute") or 0) != 0
        or weight is None
        or weight > 2
        or not page.locator(ADD_TO_CART).is_enabled()
    ):
        return None
    return {"id": product_id, "name": data["name"], "url": url}


def choose_products(page, category, count, excluded=()):
    """Find distinct products with two units in stock and a shippable weight."""
    excluded = set(excluded)
    chosen = []
    listing_url = category
    for _ in range(3):
        visit(page, listing_url)
        urls = candidates(page)
        next_link = page.locator('link[rel="next"]')
        next_url = next_link.get_attribute("href") if next_link.count() else None
        for url in dict.fromkeys(urls):
            product = available_product(page, url, excluded, quantity=2)
            if product:
                chosen.append(product)
                excluded.add(product["id"])
                if len(chosen) == count:
                    return chosen
        if not next_url:
            break
        listing_url = next_url
    raise AssertionError(
        f"Found only {len(chosen)}/{count} suitable products in {category}. "
        "For products that do not expose their weight, set E2E_CATALOG_PATH "
        "to the catalogue used by the test store."
    )


def open_cart(page):
    url = shop_url(page, "cart")
    separator = "&" if "?" in url else "?"
    visit(page, f"{url}{separator}action=show")
    expect(page.locator("body#cart")).to_be_visible()


def cart_row(page, product_id):
    return page.locator(".cart-item").filter(
        has=page.locator(f'[data-id-product="{product_id}"]')
    )


def assert_cart(page, expected):
    expect(page.locator(".cart-item")).to_have_count(len(expected))
    for product_id, quantity in expected.items():
        row = cart_row(page, product_id)
        expect(row).to_be_visible()
        expect(row.locator("input.js-cart-line-product-quantity")).to_have_value(
            str(quantity)
        )


def add_product(page, product, quantity):
    visit(page, product["url"])
    expect(page.locator("h1")).to_contain_text(product["name"])
    page.wait_for_function("() => Boolean(window.jQuery?.isReady)")
    page.locator("#quantity_wanted").fill(str(quantity))
    cart_path = urlparse(shop_url(page, "cart")).path
    with page.expect_response(
        lambda response: (
            response.request.method == "POST"
            and urlparse(response.url).path == cart_path
        )
    ) as response:
        page.locator(ADD_TO_CART).click()
    result = response.value
    assert result.ok and not result.json().get("hasError"), (
        f"Could not add {product['name']}"
    )


def search(page, phrase):
    field = page.locator(SEARCH_FIELD)
    field.fill(phrase)
    field.press("Enter")
    page.wait_for_url(lambda url: parse_qs(urlparse(url).query).get("s") == [phrase])
    expect(page.locator(SEARCH_FIELD)).to_have_value(phrase)


def choose_search_product(page, products, excluded):
    words = (re.findall(r"[^\W_]{3,}", product["name"]) for product in products)
    phrases = dict.fromkeys(matches[0] for matches in words if matches)
    for phrase in list(phrases)[:4]:
        search(page, phrase)
        urls = candidates(page)
        random.shuffle(urls)
        for url in urls:
            product = available_product(page, url, excluded, quantity=1)
            if product:
                return product
    raise AssertionError("Search did not return any available product outside the cart")


def money(text):
    return Decimal(re.sub(r"[^\d,.-]", "", text).replace(",", "."))
