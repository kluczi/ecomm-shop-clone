"""Small UI helpers for the source shop; no HTTP/API cart shortcuts."""

import json
import re
from decimal import Decimal
from urllib.parse import parse_qs, urlparse

from playwright.sync_api import expect

CATEGORIES = ("/1040-dom", "/1109-ogrod")


def visit(page, path):
    response = page.goto(path, wait_until="domcontentloaded")
    assert response is not None and response.ok, f"Cannot open {path}"
    expect(page.locator("body")).to_be_visible()
    # Some deployments show consent on the first visit only.
    consent = page.get_by_role(
        "button",
        name=re.compile(r"^(Akceptuj wszystkie|Akceptuję|Zgadzam się)$", re.IGNORECASE),
    )
    if consent.first.is_visible():
        consent.first.click()


def product_data(page):
    return json.loads(page.locator("#product-details").get_attribute("data-product"))


def candidates(page):
    cards = page.locator("#js-product-list article.product-miniature")
    expect(cards.first).to_be_visible()
    return cards.locator(".product-title a").evaluate_all(
        "links => links.map(a => a.href)"
    )


def choose_products(page, category, count, excluded=None, quantity=2):
    """Discover available products on at most three category pages."""
    excluded = set(excluded or ())
    chosen = []
    for number in range(1, 4):
        visit(page, f"{category}?page={number}")
        urls = candidates(page)
        for url in dict.fromkeys(urls):
            visit(page, url)
            data = product_data(page)
            if int(data["id"]) in excluded:
                continue
            if data.get("availability") not in ("available", "last_remaining_items"):
                continue
            if int(data.get("quantity", 0)) < quantity:
                continue
            button = page.locator(
                '#add-to-cart-or-refresh [data-button-action="add-to-cart"]'
            )
            if not button.is_enabled():
                continue
            chosen.append({"id": int(data["id"]), "name": data["name"], "url": url})
            excluded.add(int(data["id"]))
            if len(chosen) == count:
                return chosen
    raise AssertionError(
        f"Found only {len(chosen)}/{count} suitable products in {category}"
    )


def cart_row(page, product_id):
    return page.locator(".cart-item").filter(
        has=page.locator(f'[data-id-product="{product_id}"]')
    )


def open_cart(page):
    visit(page, "/koszyk?action=show")


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
    # The theme binds AJAX cart actions on DOM ready; clicking earlier submits
    # the plain form and can open an empty cart instead of adding the product.
    page.wait_for_function("window.jQuery && jQuery.isReady")
    page.locator("#quantity_wanted").fill(str(quantity))
    with page.expect_response(
        lambda r: r.request.method == "POST" and "koszyk" in r.url
    ) as response:
        page.locator(
            '#add-to-cart-or-refresh [data-button-action="add-to-cart"]'
        ).click()
    assert response.value.ok, "Add-to-cart request failed"
    open_cart(page)
    expect(cart_row(page, product["id"])).to_contain_text(product["name"])
    expect(
        cart_row(page, product["id"]).locator("input.js-cart-line-product-quantity")
    ).to_have_value(str(quantity))


def search(page, phrase):
    visit(page, "/")
    field = page.locator('#search_widget input[name="s"]')
    field.fill(phrase)
    field.press("Enter")
    page.wait_for_url(
        lambda url: parse_qs(urlparse(url).query).get("s") == [phrase],
        wait_until="commit",
    )
    expect(page.locator('#search_widget input[name="s"]')).to_have_value(phrase)


def money(text):
    # Cart prices use Polish formatting, e.g. '1 234,50 zł'.
    return Decimal(re.sub(r"[^\d,.-]", "", text).replace(",", "."))
