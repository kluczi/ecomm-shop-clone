import html
import json
from pathlib import Path

import pytest
from pydantic import ValidationError
from selectolax.lexbor import LexborHTMLParser

from parser import (
    UnavailableProduct,
    id_from_url,
    parse_description_images,
    parse_menu_categories,
    parse_product,
    parse_product_urls,
    to_kg,
)

FIXTURES = Path(__file__).parent / "fixtures"
URL = "https://topmarket.pl/15070-wiertarkowkretarka-akumulatorowa-nac-smart-nscid20s-20v.html"


def make_page(gallery: bool = True, **overrides) -> LexborHTMLParser:
    data = {
        "id": "1",
        "name": "Test",
        "price_amount": 10,
        "rate": 23,
        "availability": "available",
        "reference": "",
        "features": [],
        "link": "https://topmarket.pl/1-test.html",
    } | overrides
    attr = html.escape(json.dumps(data), quote=True)
    description = '<div class="product-description">Opis produktu</div>'
    images = (
        '<div id="product-images-large">'
        '<a href="https://topmarket.pl/1-thickbox_default/t.jpg"></a></div>'
        if gallery
        else ""
    )
    return LexborHTMLParser(
        f'<div id="product-details" data-product="{attr}"></div>{images}{description}'
    )


def test_parse_real_product_page():
    tree = LexborHTMLParser((FIXTURES / "product.html").read_text(encoding="utf-8"))
    product = parse_product(tree, URL, [1])

    assert product.id == 15070
    assert product.name == "Wiertarko-wkrętarka akumulatorowa NAC Smart NS-CID-20-S 20V"
    assert product.price_gross == 229.0
    assert product.vat_rate == 23.0
    assert product.sku == "5905842521681"
    assert product.source_url == URL
    assert len(product.slider_images) >= 1
    assert all("thickbox_default" in u for u in product.slider_images)
    assert product.description_images  # images embedded in the description
    assert not set(product.description_images) & set(product.slider_images)
    assert "NAC SMART" in product.description
    assert "<" not in product.description
    assert product.category_ids == [1]


def test_missing_product_data_raises():
    with pytest.raises(ValueError):
        parse_product(LexborHTMLParser("<html></html>"), URL, [1])


@pytest.mark.parametrize(
    "availability", ["unavailable", "unknown", "last_remaining", "", None]
)
def test_unavailable_or_unknown_product_is_rejected(availability):
    with pytest.raises(UnavailableProduct, match="product is not available"):
        parse_product(make_page(availability=availability), URL, [1])


def test_product_without_availability_is_rejected():
    tree = make_page()
    node = tree.css_first("#product-details")
    data = json.loads(node.attributes["data-product"])
    del data["availability"]
    node.attrs["data-product"] = json.dumps(data)
    with pytest.raises(UnavailableProduct, match="product is not available"):
        parse_product(tree, URL, [1])


@pytest.mark.parametrize("availability", ["available", "last_remaining_items"])
def test_available_product_is_accepted_without_exporting_availability(availability):
    product = parse_product(make_page(availability=availability), URL, [1])
    assert "availability" not in product.model_dump()


@pytest.mark.parametrize(
    ("value", "expected"),
    [
        (1.7, 1.7),
        ("1,5", 1.5),
        ("32", 32.0),
        ("0.0004", 0.0004),
        ("0", None),
        ("0.000000", None),
        (None, None),
        ("500 mg", None),  # not a plain number -> unknown, never a wrong weight
        ("1,36/0,95 kg", None),
    ],
)
def test_to_kg(value, expected):
    assert to_kg(value) == expected


def test_weight_falls_back_to_attributes():
    tree = make_page(features=[{"name": "Waga (kg)", "value": "8.6"}])
    assert parse_product(tree, URL, [1]).weight_kg == 8.6


def test_features_can_be_a_dict():
    tree = make_page(features={"0": {"name": "Kolor", "value": "czarny"}})
    assert parse_product(tree, URL, [1]).attributes == {"Kolor": "czarny"}


def test_zero_vat_is_kept():
    assert parse_product(make_page(rate=0), URL, [1]).vat_rate == 0.0
    assert parse_product(make_page(rate=None), URL, [1]).vat_rate is None


def test_ean_is_ignored_and_sku_is_kept():
    product = parse_product(
        make_page(ean13="4006381333931", reference="NS-1"), URL, [1]
    )
    assert product.sku == "NS-1"
    assert "ean" not in product.model_dump()
    assert parse_product(make_page(), URL, [1]).sku is None


def test_id_from_url():
    assert id_from_url("https://topmarket.pl/15070-foo-bar.html") == 15070
    assert id_from_url("https://topmarket.pl/1098-narzedzia") == 1098
    assert id_from_url("https://topmarket.pl/1098-narzedzia?page=2") == 1098
    assert id_from_url("https://topmarket.pl/promocje") is None


MENU = """
<ul>
 <li class="cbp-hrmenu-tab"><a class="nav-link" href="https://topmarket.pl/1109-ogrod">Ogród</a>
  <div class="cbp-category-link-w"><a class="cbp-column-title" href="https://topmarket.pl/1657-kosiarki">Kosiarki</a>
   <ul class="cbp-category-tree"><li><div><a href="https://topmarket.pl/1536-roboty">Roboty</a></div></li></ul>
  </div>
 </li>
 <li class="cbp-hrmenu-tab"><a class="nav-link" href="https://topmarket.pl/1736-prezenty">Prezenty</a></li>
</ul>
"""


def test_parse_menu_categories_builds_hierarchy():
    categories = parse_menu_categories(LexborHTMLParser(MENU), {1109})
    tree = {c.id: c.parent_id for c in categories}
    assert tree == {1109: None, 1657: 1109, 1536: 1657}  # 1736 not a main category


def test_menu_fixture_has_four_main_categories_with_subcategories():
    tree = LexborHTMLParser((FIXTURES / "menu.html").read_text(encoding="utf-8"))
    categories = parse_menu_categories(tree, {1109, 1040, 1098, 1089})
    mains = [c for c in categories if c.parent_id is None]

    assert [c.id for c in mains] == [1109, 1040, 1098, 1089]
    for main in mains:
        assert sum(c.parent_id == main.id for c in categories) >= 2
    assert all(c.source_url.startswith("https://topmarket.pl/") for c in categories)


def test_parse_product_urls_from_listing_fixture():
    tree = LexborHTMLParser((FIXTURES / "listing.html").read_text(encoding="utf-8"))
    urls = parse_product_urls(tree)

    assert len(urls) == 15
    assert len(set(urls)) == 15
    assert all(
        u.startswith("https://topmarket.pl/") and u.endswith(".html") for u in urls
    )


def test_menu_includes_added_categories_with_subcategories():
    from scraper import MAIN_CATEGORY_IDS

    tree = LexborHTMLParser((FIXTURES / "menu.html").read_text(encoding="utf-8"))
    categories = parse_menu_categories(tree, set(MAIN_CATEGORY_IDS))
    assert {c.id for c in categories if c.parent_id is None} == set(MAIN_CATEGORY_IDS)
    for main_id in (1736, 1671):
        assert sum(c.parent_id == main_id for c in categories) >= 2


def test_product_without_images_fails_validation():
    tree = make_page(gallery=False)
    with pytest.raises(ValidationError):
        parse_product(tree, URL, [1])


def test_description_images_ignore_placeholders_and_resolve_relative_urls():
    tree = LexborHTMLParser(
        '<div class="product-description">'
        '<img src="--deleted-from-2--"><img src="/img/cms/a.jpg">'
        '<img src="https://topmarket.pl/img/cms/b.jpg"><img src="data:image/gif;base64,xx">'
        "</div>"
    )
    assert parse_description_images(tree) == [
        "https://topmarket.pl/img/cms/a.jpg",
        "https://topmarket.pl/img/cms/b.jpg",
    ]


def test_features_with_missing_name_or_value_do_not_crash():
    tree = make_page(
        features=[
            {"value": "x"},
            {"name": "Kolor"},
            {"name": "Materiał", "value": "stal"},
        ]
    )
    assert parse_product(tree, URL, [1]).attributes == {"Kolor": "", "Materiał": "stal"}


def test_description_image_urls_are_encoded_so_they_are_clickable():
    tree = LexborHTMLParser(
        '<div class="product-description">'
        '<img src="https://wdomku.pl/img/cms/ZDJĘCIA DO OPISÓW/DAYTONA/124_1.png">'
        "</div>"
    )
    (url,) = parse_description_images(tree)

    assert " " not in url and url.isascii()
    assert (
        url
        == "https://wdomku.pl/img/cms/ZDJ%C4%98CIA%20DO%20OPIS%C3%93W/DAYTONA/124_1.png"
    )


def test_product_without_description_fails_validation():
    tree = LexborHTMLParser(str(make_page().html).replace("Opis produktu", ""))
    with pytest.raises(ValidationError):
        parse_product(tree, URL, [1])
