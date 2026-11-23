from pathlib import Path

from checkout import (
    COD_PENDING,
    PAYMENT_ACCEPTED,
    checkout_with_cash_on_delivery,
    confirm_payment_in_back_office,
    download_invoice,
    order_history_row,
    register_customer,
)
from playwright.sync_api import expect

from shop import (
    ADD_TO_CART,
    add_product,
    assert_cart,
    cart_row,
    category_urls,
    choose_products,
    choose_search_product,
    money,
    open_cart,
    product_data,
    search,
    visit,
)


def test_shopping_flow(page, new_context, admin_settings, output_path):
    first, second = category_urls(page)
    open_cart(page)
    assert_cart(page, {})
    selected = choose_products(page, first, 5)
    selected += choose_products(page, second, 5, {p["id"] for p in selected})
    products = {product["id"]: product for product in selected}
    expected = {}
    for index, product in enumerate(selected):
        quantity = 1 + index % 2
        add_product(page, product, quantity)
        expected[product["id"]] = quantity
    open_cart(page)
    assert len(expected) == 10
    assert_cart(page, expected)

    extra = choose_search_product(page, selected, expected)
    add_product(page, extra, 1)
    products[extra["id"]] = extra
    expected[extra["id"]] = 1
    open_cart(page)
    assert len(expected) == 11
    assert_cart(page, expected)

    for product in selected[:3]:
        row = cart_row(page, product["id"])
        row.locator(".remove-from-cart").click()
        expect(row).to_have_count(0)
        del expected[product["id"]]
        assert_cart(page, expected)
    assert len(expected) == 8

    register_customer(page)
    open_cart(page)
    assert_cart(page, expected)
    items = [
        (products[product_id]["name"], quantity)
        for product_id, quantity in expected.items()
    ]
    reference = checkout_with_cash_on_delivery(page, items)
    pending = order_history_row(page, reference)
    expect(pending).to_contain_text(COD_PENDING)
    expect(pending).to_contain_text("przy odbiorze", ignore_case=True)

    # Mark the test order paid in the back office so PrestaShop issues its invoice.
    admin_page = new_context().new_page()
    confirm_payment_in_back_office(admin_page, admin_settings, reference)
    paid = order_history_row(page, reference)
    expect(paid).to_contain_text(PAYMENT_ACCEPTED)
    download_invoice(page, paid, Path(output_path) / "invoice.pdf")


def test_empty_cart_and_product_details(page):
    visit(page, "./")
    open_cart(page)
    expect(page.locator(".cart-overview")).to_be_visible()
    assert_cart(page, {})

    product = choose_products(page, category_urls(page)[0], 1)[0]
    visit(page, product["url"])
    expect(page.locator("h1")).to_contain_text(product["name"])
    assert float(product_data(page)["price_amount"]) > 0
    image = page.locator(".product-cover img").first
    expect(image).to_be_visible()
    expect(image).to_have_js_property("complete", True)
    expect(image).not_to_have_js_property("naturalWidth", 0)
    expect(page.locator(ADD_TO_CART)).to_be_enabled()


def test_quantity_update(page):
    product = choose_products(page, category_urls(page)[0], 1)[0]
    add_product(page, product, 1)
    open_cart(page)
    row = cart_row(page, product["id"])
    unit_price = money(row.locator(".current-price .price").inner_text())
    subtotal = page.locator("#cart-subtotal-products .value")
    old_subtotal = subtotal.inner_text()
    row.locator("button.bootstrap-touchspin-up").click()
    expect(subtotal).not_to_have_text(old_subtotal)
    assert money(subtotal.inner_text()) == unit_price * 2
    assert_cart(page, {product["id"]: 2})
    open_cart(page)
    assert_cart(page, {product["id"]: 2})
    assert money(subtotal.inner_text()) == unit_price * 2


def test_search_without_results(page):
    visit(page, "./")
    search(page, "zzzxqvnonexistentproduct987654321")
    expect(page.locator("#js-product-list article.product-miniature")).to_have_count(0)
    expect(page.locator("#product-search-no-matches")).to_be_visible()
