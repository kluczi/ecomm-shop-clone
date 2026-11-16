import json
import re
from urllib.parse import quote, urlsplit

from selectolax.lexbor import LexborHTMLParser

from models import Category, Product

BASE_URL = "https://topmarket.pl"


class UnavailableProduct(ValueError):
    """The product cannot be included because it is not available."""


def id_from_url(url: str) -> int | None:
    """'https://topmarket.pl/1098-narzedzia?page=2' -> 1098"""
    match = re.match(r"/(\d+)-", urlsplit(url).path)
    return int(match[1]) if match else None


def _clean(text: str) -> str:
    return re.sub(r"\s+", " ", text.replace("\xa0", " ")).strip()


def to_kg(value) -> float | None:
    """Weight in kg from a plain number ('1.7', '1,5'); anything else is None."""
    try:
        weight = float(str(value).replace(",", "."))
    except ValueError:
        return None
    return weight if weight > 0 else None


def parse_menu_categories(tree: LexborHTMLParser, main_ids: set[int]) -> list[Category]:
    """Build the category tree (main -> subcategory -> sub-subcategory) from the
    mega menu on the home page."""
    categories: dict[int, Category] = {}

    def add(link, parent_id: int | None) -> int | None:
        url = link.attributes.get("href") or ""
        cat_id = id_from_url(url)
        if cat_id is None or cat_id in categories:
            return cat_id
        categories[cat_id] = Category(
            id=cat_id,
            name=_clean(link.text()),
            parent_id=parent_id,
            source_url=url,
        )
        return cat_id

    for tab in tree.css("li.cbp-hrmenu-tab"):
        main_link = tab.css_first("a.nav-link")
        if main_link is None:
            continue
        main_id = id_from_url(main_link.attributes.get("href") or "")
        if main_id not in main_ids:
            continue
        add(main_link, None)

        for column in tab.css("div.cbp-category-link-w"):
            title = column.css_first("a.cbp-column-title")
            if title is None:
                continue
            sub_id = add(title, main_id)
            # the tree <ul> is a sibling of the title inside the column
            holder = title.parent.parent if title.parent else None
            for child in holder.css("ul.cbp-category-tree a") if holder else []:
                add(child, sub_id)

    return list(categories.values())


def parse_product_urls(tree: LexborHTMLParser) -> list[str]:
    urls = []
    for product in tree.css("#js-product-list .js-product-miniature-wrapper"):
        link = product.css_first("a")
        if link and link.attributes.get("href"):
            urls.append(link.attributes["href"])
    return urls


def parse_slider_images(tree: LexborHTMLParser) -> list[str]:
    links = tree.css("#product-images-large a[href]")
    return list(dict.fromkeys(link.attributes["href"] for link in links))


def parse_description_images(tree: LexborHTMLParser) -> list[str]:
    images: list[str] = []
    for img in tree.css(".product-description img"):
        url = img.attributes.get("src") or img.attributes.get("data-src")
        if not url or url.startswith("data:"):
            continue
        if url.startswith("/"):
            url = BASE_URL + url
        if not url.startswith(("http://", "https://")):
            continue  # placeholders such as "--deleted-from-2--"
        url = quote(url, safe=":/?&=%#")  # spaces and Polish letters -> %XX
        if url not in images:
            images.append(url)
    return images


def parse_description(tree: LexborHTMLParser) -> str:
    node = tree.css_first(".product-description")
    if node is None:
        return ""
    html = re.sub(
        r"(?i)<br\s*/?>|</(p|div|section|li|ul|ol|h[1-6]|tr|table)>",
        "\\g<0>\n",
        node.html,
    )
    block = LexborHTMLParser(html)
    for tag in block.css("script, style"):
        tag.decompose()
    lines = [_clean(line) for line in block.text(separator="").splitlines()]
    return "\n".join(line for line in lines if line)


def parse_attributes(data: dict) -> dict[str, str]:
    features = data.get("features") or []
    if isinstance(features, dict):  # the shop sometimes sends {"0": {...}}
        features = features.values()
    attributes = {}
    for feature in features:
        name = _clean(str(feature.get("name") or ""))
        if name:  # skip parameters without a name
            attributes[name] = _clean(str(feature.get("value") or ""))
    return attributes


def parse_product(tree: LexborHTMLParser, url: str, category_ids: list[int]) -> Product:
    node = tree.css_first("#product-details")
    if node is None:
        raise ValueError(f"no product data on {url}")
    data = json.loads(node.attributes["data-product"])
    if data.get("availability") not in ("available", "last_remaining_items"):
        raise UnavailableProduct(
            f"product is not available: {url} (availability={data.get('availability')!r})"
        )
    attributes = parse_attributes(data)

    # the shop fills the official weight field rarely, usually the weight is
    # the "Waga (kg)" parameter
    weight = to_kg(data.get("weight")) or to_kg(attributes.get("Waga (kg)"))

    return Product(
        id=int(data["id"]),
        name=_clean(data["name"]),
        description=parse_description(tree),
        price_gross=float(data["price_amount"]),
        vat_rate=data.get("rate"),
        attributes=attributes,
        weight_kg=weight,
        slider_images=parse_slider_images(tree),
        description_images=parse_description_images(tree),
        category_ids=category_ids,
        sku=data.get("reference") or None,
        source_url=data.get("link") or url,
    )
