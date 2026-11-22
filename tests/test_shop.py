import random

from playwright.sync_api import expect

from shop import (
    CATEGORIES,
    add_product,
    assert_cart,
    candidates,
    cart_row,
    choose_products,
    money,
    open_cart,
    product_data,
    search,
    visit,
)


def test_shopping_flow(page):
    open_cart(page)
    expect(page.locator(".cart-item")).to_have_count(0)
    selected = choose_products(page, CATEGORIES[0], 5)
    selected += choose_products(page, CATEGORIES[1], 5, {p["id"] for p in selected})
    expected = {}
    for index, product in enumerate(selected):
        quantity = 1 + index % 2
        add_product(page, product, quantity)
        expected[product["id"]] = quantity
        assert_cart(page, expected)

    # A phrase from a real product name; exclude items already in the cart.
    phrase = selected[0]["name"].split()[0]
    search(page, phrase)
    urls = candidates(page)
    random.shuffle(urls)
    for url in urls:
        visit(page, url)
        data = product_data(page)
        if int(data["id"]) not in expected and data.get("availability") in (
            "available",
            "last_remaining_items",
        ):
            extra = {"id": int(data["id"]), "name": data["name"], "url": url}
            break
    else:
        raise AssertionError(f"No available new search result for {phrase!r}")
    print(f"Random search selection: {extra['id']} — {extra['name']}")
    add_product(page, extra, 1)
    expected[extra["id"]] = 1
    assert_cart(page, expected)
    assert len(expected) == 11

    for product in selected[:3]:
        row = cart_row(page, product["id"])
        row.locator(".remove-from-cart").click()
        expect(row).to_have_count(0)
        del expected[product["id"]]
        assert_cart(page, expected)
    assert len(expected) == 8


def test_empty_cart_and_product_details(page):
    open_cart(page)
    expect(page.locator(".cart-item")).to_have_count(0)
    expect(
        page.get_by_text(
            "W Twoim koszyku nie ma jeszcze żadnych produktów.", exact=True
        ).last
    ).to_be_visible()
    product = choose_products(page, CATEGORIES[0], 1)[0]
    visit(page, product["url"])
    expect(page.locator("h1")).to_contain_text(product["name"])
    assert product["name"].strip()
    assert float(product_data(page)["price_amount"]) > 0
    image = page.locator("#product-images-large .swiper-slide-active img").first
    expect(image).to_be_visible(timeout=15_000)
    expect(image).to_have_js_property("complete", True)
    expect(image).not_to_have_js_property("naturalWidth", 0)
    expect(
        page.locator('#add-to-cart-or-refresh [data-button-action="add-to-cart"]')
    ).to_be_enabled()


def test_quantity_update(page):
    product = choose_products(page, CATEGORIES[0], 1)[0]
    add_product(page, product, 1)
    row = cart_row(page, product["id"])
    unit_price = money(row.locator(".unit-price .value").inner_text())
    quantity = row.locator("input.js-cart-line-product-quantity")
    with page.expect_response(
        lambda r: r.request.method == "POST" and "koszyk" in r.url
    ):
        row.locator(".js-increase-product-quantity").click()
    expect(quantity).to_have_value("2")
    expect(row.locator(".product-price")).to_contain_text(
        f"{unit_price * 2:.2f}".replace(".", ",")
    )
    open_cart(page)
    assert_cart(page, {product["id"]: 2})
    assert (
        money(cart_row(page, product["id"]).locator(".product-price").inner_text())
        == unit_price * 2
    )


def test_search_without_results(page):
    search(page, "zzzxqvnonexistentproduct987654321")
    expect(page.locator("#js-product-list article.product-miniature")).to_have_count(0)
    expect(page.get_by_role("alert")).to_contain_text("Brak produktów w tej kategorii.")
