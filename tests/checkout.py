"""Storefront checkout and back-office payment confirmation."""

import re
from pathlib import Path
from uuid import uuid4

from playwright.sync_api import expect

from shop import shop_url, visit

COD_PENDING = "Oczekiwanie na płatność przy odbiorze"
PAYMENT_ACCEPTED = "Płatność zaakceptowana"
CARRIERS = ("DPD Kurier", "InPost Paczkomat 24/7")


def register_customer(page):
    visit(page, shop_url(page, "registration"))
    form = page.locator("#customer-form")
    form.locator('[name="firstname"]').fill("Tester")
    form.locator('[name="lastname"]').fill("Playwright")
    form.locator('[name="email"]').fill(f"e2e-{uuid4().hex}@example.test")
    form.locator('[name="password"]').fill(f"Sklep!9-{uuid4().hex}")
    for checkbox in form.locator('input[type="checkbox"][required]').all():
        checkbox.check()
    form.locator('[data-link-action="save-customer"]').click()
    expect(page.locator(".user-info a.account")).to_contain_text("Tester Playwright")


def checkout_with_cash_on_delivery(page, ordered_products):
    page.locator(".cart-detailed-actions a.btn-primary").click()
    address = page.locator("#delivery-address")
    expect(address).to_be_visible()
    country = address.locator('select[name="id_country"]')
    if country.locator("option:checked").inner_text().strip() != "Polska":
        country.select_option(label="Polska")
    address.locator('[name="address1"]').fill("ul. Testowa 10")
    address.locator('[name="postcode"]').fill("80-001")
    address.locator('[name="city"]').fill("Gdańsk")
    address.locator('[name="phone"]').fill("500000001")
    page.locator('#checkout-addresses-step button[name="confirm-addresses"]').click()
    shipping = page.locator("#checkout-delivery-step")
    expect(shipping.locator("#js-delivery")).to_be_visible()
    for carrier in CARRIERS:
        option = shipping.locator(".delivery-option").filter(
            has=page.get_by_text(carrier, exact=True)
        )
        if option.count():
            break
    else:
        raise AssertionError(
            "Neither DPD nor InPost is available for the checkout address"
        )
    option.locator("label").click()
    expect(option.get_by_role("radio")).to_be_checked()
    shipping.locator('[name="confirmDeliveryOption"]').click()

    payment = page.locator("#checkout-payment-step")
    expect(payment.locator('input[data-module-name="ps_wirepayment"]')).to_be_visible()
    cod = page.locator('input[data-module-name="ps_cashondelivery"]')
    expect(cod).to_be_visible()
    payment.locator(".payment-option").filter(has=cod).locator("label").click()
    expect(cod).to_be_checked()
    for checkbox in payment.locator(
        '#conditions-to-approve input[type="checkbox"]'
    ).all():
        checkbox.check()
    confirm = payment.locator("#payment-confirmation button")
    expect(confirm).to_be_enabled()
    confirm.click()

    order_details = page.locator("#order-details")
    expect(order_details.locator("#order-reference-value")).to_be_visible()
    expect(order_details).to_contain_text(carrier)
    expect(order_details).to_contain_text("przy odbiorze", ignore_case=True)
    lines = page.locator(".order-confirmation-table .order-line")
    expect(lines).to_have_count(len(ordered_products))
    for product_name, quantity in ordered_products:
        row = lines.filter(has=page.get_by_text(product_name, exact=True))
        expect(row.locator(".qty .row > div").nth(1)).to_have_text(str(quantity))
    return order_details.locator("#order-reference-value").inner_text().split()[-1]


def order_history_row(page, reference):
    visit(page, shop_url(page, "history"))
    row = page.locator("table tbody tr").filter(
        has=page.get_by_role("rowheader", name=reference, exact=True)
    )
    expect(row).to_be_visible()
    return row


def confirm_payment_in_back_office(page, admin_settings, reference):
    visit(page, admin_settings.url)
    form = page.locator("form").filter(has=page.locator('input[type="password"]'))
    form.locator('input[name="email"]').fill(admin_settings.email)
    form.locator('input[type="password"]').fill(admin_settings.password)
    form.locator('button[type="submit"]').click()

    orders = page.locator("#subtab-AdminOrders a").first
    expect(orders).to_have_attribute("href", re.compile(r".+"), timeout=30_000)
    visit(page, orders.evaluate("element => element.href"))
    row = page.locator("tr").filter(has=page.get_by_text(reference, exact=True))
    expect(row).to_be_visible()
    row.locator('a[href*="/sell/orders/"][href*="/view"]').click()
    expect(page.locator("#order-view-page")).to_have_attribute(
        "data-order-title", re.compile(re.escape(reference) + r"$")
    )
    status_form = page.locator("#update_order_status_action_form")
    status_form.get_by_role("combobox").click()
    page.get_by_role("option", name=PAYMENT_ACCEPTED, exact=True).click()
    submit = status_form.locator("#update_order_status_action_btn")
    expect(submit).to_be_enabled()
    submit.click()
    expect(page.locator('[data-role="status-column"]').first).to_contain_text(
        PAYMENT_ACCEPTED
    )


def download_invoice(page, row, destination: Path):
    invoice = row.locator('a[href*="pdf-invoice"]')
    expect(invoice).to_be_visible()
    with page.expect_download() as result:
        invoice.click()
    download = result.value
    assert download.suggested_filename.lower().endswith(".pdf")
    destination.parent.mkdir(parents=True, exist_ok=True)
    download.save_as(destination)
    with destination.open("rb") as pdf:
        assert pdf.read(5) == b"%PDF-"
