import pytest
from pydantic import ValidationError

from models import Category, Product

VALID = {
    "id": 1,
    "name": "Test",
    "description": "Opis",
    "price_gross": 9.99,
    "category_ids": [1],
    "slider_images": ["https://topmarket.pl/1-thickbox_default/test.jpg"],
    "source_url": "https://topmarket.pl/1-test.html",
}


def test_valid_product():
    product = Product(**VALID)
    assert product.vat_rate is None


@pytest.mark.parametrize(
    "override",
    [
        {"price_gross": 0},
        {"price_gross": -5},
        {"name": "   "},
        {"description": ""},
        {"slider_images": []},
        {"category_ids": []},
        {"slider_images": ["not-a-url"]},
        {"vat_rate": 150},
        {"weight_kg": 0},
        {"id": 0},
    ],
)
def test_invalid_product_is_rejected(override):
    with pytest.raises(ValidationError):
        Product(**(VALID | override))


def test_category_requires_url_and_name():
    Category(id=1, name="Ogród", source_url="https://topmarket.pl/1-ogrod")
    with pytest.raises(ValidationError):
        Category(id=1, name="", source_url="https://topmarket.pl/1-ogrod")
