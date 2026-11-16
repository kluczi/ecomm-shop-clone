import json
import logging
import sys
from pathlib import Path

import httpx
from pydantic import ValidationError
from selectolax.lexbor import LexborHTMLParser

from fetcher import Fetcher
from models import Category, Product
from parser import (
    UnavailableProduct,
    id_from_url,
    parse_menu_categories,
    parse_product,
    parse_product_urls,
)

logger = logging.getLogger("scraper")

BASE_URL = "https://topmarket.pl/"

# Main categories: Ogród, Dom, Narzędzia, Meble domowe, Prezenty, Produkty NAC
MAIN_CATEGORY_IDS = (1109, 1040, 1098, 1089, 1736, 1671)
TOTAL_PRODUCTS = 1400  # scraped in total, spread evenly over the main categories

OUTPUT_DIR = Path(__file__).resolve().parent.parent / "scraper-results"
PRODUCTS_JSONL = OUTPUT_DIR / "products.jsonl"  # one product per line, appended
LISTINGS_JSON = OUTPUT_DIR / "listings.json"  # product url -> category ids (cache)
LOG_FILE = OUTPUT_DIR / "scraper.log"


def setup_logging() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    logging.getLogger("httpx").setLevel(logging.WARNING)  # one line per request
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler(LOG_FILE, encoding="utf-8"),
        ],
    )


def get_tree(fetcher: Fetcher, url: str, **params) -> LexborHTMLParser:
    return LexborHTMLParser(fetcher.get(url, **params).text)


def get_category_product_urls(fetcher: Fetcher, category_url: str) -> list[str]:
    """Product urls from every page of one category listing."""
    urls: list[str] = []
    page = 1
    while True:
        page_urls = parse_product_urls(get_tree(fetcher, category_url, page=page))
        new_urls = [url for url in page_urls if url not in urls]
        if not new_urls:  # empty page, or the shop repeats the last one
            return urls
        urls += new_urls
        page += 1


def collect_listings(fetcher: Fetcher, categories: list) -> dict[str, list[int]]:
    """Maps each product url to the categories whose listing contains it.

    Crawling every category is needed: a product's default category is often
    missing from the menu, and products can sit in several categories.
    The result is cached; newly selected main categories extend the cache.
    Delete listings.json to crawl everything again."""
    listings = (
        json.loads(LISTINGS_JSON.read_text(encoding="utf-8"))
        if LISTINGS_JSON.exists()
        else {}
    )
    cached_ids = {cat_id for ids in listings.values() for cat_id in ids}
    parents = {category.id: category.parent_id for category in categories}

    for category in categories:
        main_id = category.id
        while parents.get(main_id) is not None:
            main_id = parents[main_id]
        if main_id in cached_ids:
            continue
        urls = get_category_product_urls(fetcher, category.source_url)
        logger.info("%s (%d): %d products", category.name, category.id, len(urls))
        for url in urls:
            ids = listings.setdefault(url, [])
            if category.id not in ids:
                ids.append(category.id)

    LISTINGS_JSON.write_text(json.dumps(listings, indent=1), encoding="utf-8")
    return listings


def pick_products(listings: dict[str, list[int]], total: int) -> list[str]:
    """Choose about `total` product urls, evenly spread over the main categories
    (and, by taking every n-th product, over their subcategories). A small
    category gives all it has and the others share the rest. The choice is the
    same on every run, so resuming works."""
    # a product in several main categories counts for the smallest one, so
    # small categories keep their products
    sizes = {m: sum(m in ids for ids in listings.values()) for m in MAIN_CATEGORY_IDS}
    by_main: dict[int, list[str]] = {main_id: [] for main_id in MAIN_CATEGORY_IDS}
    for url, category_ids in listings.items():
        mains = [m for m in MAIN_CATEGORY_IDS if m in category_ids]
        if mains:
            by_main[min(mains, key=sizes.get)].append(url)

    chosen = []
    smallest_first = sorted(by_main.values(), key=len)
    for number, urls in enumerate(smallest_first):
        quota = (total - len(chosen)) // (len(smallest_first) - number)
        count = min(quota, len(urls))
        chosen += [urls[k * len(urls) // count] for k in range(count)]
    return chosen


def load_scraped() -> dict[int, Product]:
    """Products already saved. Broken lines (e.g. cut off by a crash) are logged."""
    products = {}
    if PRODUCTS_JSONL.exists():
        lines = PRODUCTS_JSONL.read_text(encoding="utf-8").splitlines()
        for number, line in enumerate(lines, 1):
            if not line.strip():
                continue
            try:
                product = Product.model_validate_json(line)
            except ValidationError as error:
                logger.error(
                    "%s line %d is invalid: %s", PRODUCTS_JSONL.name, number, error
                )
            else:
                products[product.id] = product
    return products


def product_candidates(listings: dict[str, list[int]], total: int, scraped: dict):
    """Choose successive balanced batches; try each unsaved URL at most once."""
    remaining = {
        url: ids for url, ids in listings.items() if id_from_url(url) not in scraped
    }
    while remaining:
        batch = pick_products(remaining, total)
        if not batch:
            return
        for url in batch:
            del remaining[url]
            yield url


def save_checkpoint(products: dict[int, Product]) -> None:
    """Rewrite products.jsonl with valid products only, so a half-written last
    line from a crash cannot glue itself to the next product we append.
    Written to a temp file first: an interruption here cannot damage the
    existing checkpoint."""
    temp = PRODUCTS_JSONL.with_suffix(".tmp")
    temp.write_text(
        "".join(p.model_dump_json() + "\n" for p in products.values()), encoding="utf-8"
    )
    temp.replace(PRODUCTS_JSONL)


def save_json(name: str, items: list) -> None:
    """One item per line: readable, and much smaller than indent=2
    (the repository must not contain files over 10 MB)."""
    path = OUTPUT_DIR / name
    lines = [json.dumps(item.model_dump(), ensure_ascii=False) for item in items]
    path.write_text("[\n" + ",\n".join(lines) + "\n]\n", encoding="utf-8")
    logger.info("saved %d items -> %s", len(items), path)


def populated_category_ids(
    products: list[Product], categories: list[Category]
) -> set[int]:
    parents = {category.id: category.parent_id for category in categories}
    populated = set()
    for product in products:
        for category_id in product.category_ids:
            # A product in a deeper category also populates its ancestors.
            visited = set()
            while category_id in parents and category_id not in visited:
                visited.add(category_id)
                populated.add(category_id)
                category_id = parents[category_id]
    return populated


def remove_empty_categories(
    products: list[Product], categories: list[Category]
) -> list[Category]:
    populated = populated_category_ids(products, categories)
    return [c for c in categories if c.id in populated or c.id in MAIN_CATEGORY_IDS]


def check_requirements(products: list[Product], categories: list[Category]) -> None:
    products = list({product.id: product for product in products}.values())
    errors = []
    if len(products) < 1000:
        errors.append(f"need at least 1000 unique valid products, got {len(products)}")

    parents = {category.id: category.parent_id for category in categories}
    populated = populated_category_ids(products, categories)

    for main_id in MAIN_CATEGORY_IDS:
        count = sum(
            category.parent_id == main_id and category.id in populated
            for category in categories
        )
        if main_id not in parents or count < 2:
            errors.append(
                f"main category {main_id}: need 2 nonempty subcategories, got {count}"
            )
    empty = [str(c.id) for c in categories if c.id not in populated]
    if empty:
        errors.append("empty categories: " + ", ".join(empty))
    if errors:
        raise ValueError("product requirements NOT met: " + "; ".join(errors))


def main(total: int = TOTAL_PRODUCTS) -> None:
    """The first run crawls all category listings (a few minutes) and caches
    them in listings.json (delete it to crawl again)."""
    setup_logging()
    fetcher = Fetcher(BASE_URL)

    categories = parse_menu_categories(
        get_tree(fetcher, BASE_URL), set(MAIN_CATEGORY_IDS)
    )

    listings = collect_listings(fetcher, categories)
    scraped = load_scraped()
    # Update memberships of saved products when a newly added category overlaps.
    for url, ids in listings.items():
        product = scraped.get(id_from_url(url))
        if product is not None:
            product.category_ids = list(dict.fromkeys(product.category_ids + ids))
    save_checkpoint(scraped)
    logger.info(
        "%d listed, %d done, target %d valid available products",
        len(listings),
        len(scraped),
        total,
    )

    with PRODUCTS_JSONL.open("a", encoding="utf-8") as file:
        for url in product_candidates(listings, total, scraped):
            if len(scraped) >= total:
                break
            try:
                product = parse_product(get_tree(fetcher, url), url, listings[url])
            except UnavailableProduct:
                continue
            except (httpx.HTTPError, PermissionError, ValueError, KeyError) as error:
                # ValueError includes pydantic's ValidationError
                logger.error("skipped %s: %s", url, error)
                continue
            if product.id in scraped:
                continue
            file.write(product.model_dump_json() + "\n")
            file.flush()  # keep what we have if the script is interrupted
            scraped[product.id] = product

    if len(scraped) < total:
        logger.warning(
            "all candidates exhausted: saved %d/%d valid available products",
            len(scraped),
            total,
        )

    products = list(load_scraped().values())
    save_json("products.json", products)
    categories = remove_empty_categories(products, categories)
    check_requirements(products, categories)
    save_json("categories.json", categories)


if __name__ == "__main__":
    main(total=int(sys.argv[1]) if len(sys.argv) > 1 else TOTAL_PRODUCTS)
