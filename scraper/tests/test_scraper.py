import json
from urllib.robotparser import RobotFileParser

import httpx
import pytest

import scraper
from fetcher import USER_AGENT, Fetcher, load_robots
from models import Category, Product
from parser import UnavailableProduct, id_from_url
from scraper import load_scraped, save_checkpoint


@pytest.fixture(autouse=True)
def no_real_sleep(monkeypatch):
    monkeypatch.setattr("fetcher.time.sleep", lambda seconds: None)


def test_fetcher_refuses_urls_blocked_by_robots_txt():
    fetcher = Fetcher.__new__(Fetcher)  # skip the network in __init__
    fetcher.robots = RobotFileParser()
    fetcher.robots.parse(["User-agent: *", "Disallow: /private/"])

    with pytest.raises(PermissionError):
        fetcher.get("https://topmarket.pl/private/page")


def make_client(status: int, body: str = "") -> httpx.Client:
    transport = httpx.MockTransport(lambda request: httpx.Response(status, text=body))
    return httpx.Client(transport=transport)


URL = "https://topmarket.pl/1098-narzedzia"
ROBOTS = "https://topmarket.pl/robots.txt"


def test_robots_200_uses_the_rules():
    robots = load_robots(make_client(200, "User-agent: *\nDisallow: /private/"), ROBOTS)
    assert robots.can_fetch(USER_AGENT, URL)
    assert not robots.can_fetch(USER_AGENT, "https://topmarket.pl/private/x")


@pytest.mark.parametrize("status", [401, 403])
def test_robots_forbidden_means_everything_is_blocked(status):
    assert not load_robots(make_client(status), ROBOTS).can_fetch(USER_AGENT, URL)


def test_robots_404_means_everything_is_allowed():
    assert load_robots(make_client(404), ROBOTS).can_fetch(USER_AGENT, URL)


@pytest.mark.parametrize("status", [429, 500, 503])
def test_robots_rate_limit_or_server_error_is_an_error_not_permission(status):
    with pytest.raises(httpx.HTTPError):
        load_robots(make_client(status), ROBOTS)


def product(product_id: int) -> Product:
    return Product(
        id=product_id,
        name="Test",
        description="Opis",
        price_gross=1,
        category_ids=[1],
        slider_images=["https://topmarket.pl/1-thickbox_default/a.jpg"],
        source_url=f"https://topmarket.pl/{product_id}-test.html",
    )


def test_checkpoint_roundtrip_and_leaves_no_temp_file(tmp_path, monkeypatch):
    monkeypatch.setattr(scraper, "PRODUCTS_JSONL", tmp_path / "products.jsonl")
    save_checkpoint({1: product(1), 2: product(2)})

    assert sorted(load_scraped()) == [1, 2]
    assert [f.name for f in tmp_path.iterdir()] == ["products.jsonl"]


def test_corrupt_last_line_is_dropped_and_logged(tmp_path, monkeypatch, caplog):
    path = tmp_path / "products.jsonl"
    monkeypatch.setattr(scraper, "PRODUCTS_JSONL", path)
    path.write_text(product(1).model_dump_json() + '\n{"id": 2, "na', encoding="utf-8")

    products = load_scraped()
    save_checkpoint(products)

    assert list(products) == [1]
    assert "line 2 is invalid" in caplog.text
    assert path.read_text(encoding="utf-8").endswith("\n")  # safe to append to


def test_pick_products_is_balanced_and_small_categories_give_everything(monkeypatch):
    monkeypatch.setattr(scraper, "MAIN_CATEGORY_IDS", (1109, 1040, 1098, 1089))
    listings = {}
    for main_id, count in ((1109, 500), (1040, 500), (1098, 500), (1089, 30)):
        for n in range(count):
            listings[f"https://topmarket.pl/{main_id}{n}-p.html"] = [main_id]

    chosen = scraper.pick_products(listings, 1400)

    per_main = {m: sum(f"/{m}" in u for u in chosen) for m in (1109, 1040, 1098, 1089)}
    assert per_main[1089] == 30  # all of the small category
    assert 1399 <= len(chosen) <= 1400
    assert (
        max(per_main[m] for m in (1109, 1040, 1098))
        - min(per_main[m] for m in (1109, 1040, 1098))
        <= 1
    )
    assert len(set(chosen)) == len(chosen)
    assert chosen == scraper.pick_products(listings, 1400)  # same on every run


def test_pick_products_includes_all_six_main_categories():
    listings = {
        f"https://topmarket.pl/{main_id * 10000 + n}-p.html": [main_id]
        for main_id in scraper.MAIN_CATEGORY_IDS
        for n in range(20 if main_id == 1089 else 500)
    }
    chosen = scraper.pick_products(listings, 1400)
    assert len(set(chosen)) == len(chosen) == 1400
    assert all(
        any(main_id in listings[u] for u in chosen)
        for main_id in scraper.MAIN_CATEGORY_IDS
    )


def test_listings_cache_extends_only_new_main_categories(tmp_path, monkeypatch):
    cache = tmp_path / "listings.json"
    monkeypatch.setattr(scraper, "LISTINGS_JSON", cache)
    old_url, new_url = product(1).source_url, product(2).source_url
    cache.write_text(json.dumps({old_url: [1109, 11091]}))
    categories = [
        Category(id=1109, name="Old", source_url=URL),
        Category(id=11091, name="Old sub", parent_id=1109, source_url=URL + "/old"),
        Category(id=1671, name="New", source_url=URL + "/new"),
        Category(id=16711, name="New sub", parent_id=1671, source_url=URL + "/sub"),
        Category(id=16712, name="Empty sub", parent_id=1671, source_url=URL + "/empty"),
    ]
    requests = []

    def listing(fetcher, url):
        requests.append(url)
        return [] if url.endswith("empty") else [old_url, new_url]

    monkeypatch.setattr(scraper, "get_category_product_urls", listing)
    result = scraper.collect_listings(object(), categories)
    assert requests == [c.source_url for c in categories[2:]]
    assert result[old_url] == [1109, 11091, 1671, 16711]
    assert result[new_url] == [1671, 16711]
    requests.clear()
    assert scraper.collect_listings(object(), categories) == result
    assert not requests


@pytest.mark.parametrize("resume", [False, True])
@pytest.mark.parametrize("available", [{2, 4, 5, 6, 9}, {2, 4}])
def test_scraper_replaces_unavailable_candidates_and_resumes(
    tmp_path, monkeypatch, caplog, resume, available
):
    target = 3
    listings = {product(n).source_url: [1109] for n in range(1, 11)}
    monkeypatch.setattr(scraper, "OUTPUT_DIR", tmp_path)
    monkeypatch.setattr(scraper, "PRODUCTS_JSONL", tmp_path / "products.jsonl")
    monkeypatch.setattr(scraper, "setup_logging", lambda: None)
    monkeypatch.setattr(scraper, "Fetcher", lambda base_url: object())
    monkeypatch.setattr(scraper, "get_tree", lambda fetcher, url: url)
    monkeypatch.setattr(scraper, "parse_menu_categories", lambda tree, ids: [])
    monkeypatch.setattr(scraper, "collect_listings", lambda fetcher, cats: listings)
    checked = []
    monkeypatch.setattr(
        scraper, "check_requirements", lambda products, cats: checked.append(products)
    )
    if resume:
        save_checkpoint({4: product(4)})
    requests = []

    def parse(tree, url, ids):
        product_id = id_from_url(url)
        requests.append(product_id)
        if product_id not in available:
            raise UnavailableProduct("not available")
        return product(product_id)

    monkeypatch.setattr(scraper, "parse_product", parse)
    scraper.main(total=target)

    saved = load_scraped()
    assert len(saved) == min(target, len(available))
    assert set(saved) <= available
    assert len(requests) == len(set(requests))
    assert any(n not in (1, 4, 7) for n in requests)
    assert "not available" not in caplog.text
    assert len(checked[0]) == len(saved)
    if resume:
        assert 4 not in requests
    if len(available) < target:
        assert len(requests) == len(listings) - int(resume)
        assert "all candidates exhausted" in caplog.text


def test_candidate_batches_do_not_repeat_or_omit_urls():
    listings = {
        product(n).source_url: [scraper.MAIN_CATEGORY_IDS[n % 4]] for n in range(1, 41)
    }
    saved = {4: product(4)}
    candidates = list(scraper.product_candidates(listings, 7, saved))
    assert len(candidates) == len(set(candidates)) == 39
    assert set(candidates) == set(listings) - {product(4).source_url}


def catalog():
    categories = []
    leaves = []
    for main_id in scraper.MAIN_CATEGORY_IDS:
        categories.append(Category(id=main_id, name="Main", source_url=URL))
        for n in (1, 2):
            sub_id = main_id * 10 + n
            leaf_id = sub_id * 10
            categories.extend(
                [
                    Category(id=sub_id, name="Sub", parent_id=main_id, source_url=URL),
                    Category(id=leaf_id, name="Leaf", parent_id=sub_id, source_url=URL),
                ]
            )
            leaves.append(leaf_id)
    products = [
        product(n + 1).model_copy(update={"category_ids": [leaves[n % len(leaves)]]})
        for n in range(1000)
    ]
    return products, categories


def test_product_requirements_accept_populated_descendants():
    products, categories = catalog()
    scraper.check_requirements(products, categories)


def test_product_requirements_count_unique_products():
    products, categories = catalog()
    with pytest.raises(ValueError, match="got 999"):
        scraper.check_requirements(products[:-1] + [products[0]], categories)


def test_product_requirements_reject_empty_subcategory():
    products, categories = catalog()
    for item in products:
        if item.category_ids == [110920]:
            item.category_ids = [110910]
    with pytest.raises(ValueError, match="1109: need 2 nonempty subcategories, got 1"):
        scraper.check_requirements(products, categories)


def test_empty_leaf_is_rejected_and_removed_without_removing_ancestors():
    products, categories = catalog()
    empty = Category(id=999999, name="Empty", parent_id=11091, source_url=URL)
    categories.append(empty)
    with pytest.raises(ValueError, match="empty categories: 999999"):
        scraper.check_requirements(products, categories)

    filtered = scraper.remove_empty_categories(products, categories)
    assert filtered == categories[:-1]
    scraper.check_requirements(products, filtered)


def test_empty_branch_is_removed_and_empty_main_is_still_rejected():
    products, categories = catalog()
    products = [p for p in products if p.category_ids[0] not in (108910, 108920)]
    filtered = scraper.remove_empty_categories(products, categories)
    assert 1089 in {c.id for c in filtered}
    assert not any(c.parent_id == 1089 for c in filtered)
    with pytest.raises(ValueError, match="1089: need 2 nonempty subcategories, got 0"):
        scraper.check_requirements(products, filtered)


@pytest.mark.parametrize("failure", [429, 500, 503, "timeout", "connection"])
def test_fetcher_retries_temporary_failures_with_backoff(monkeypatch, failure):
    requests = []
    sleeps = []

    def respond(request):
        requests.append(request)
        if len(requests) < 3:
            if failure == "timeout":
                raise httpx.ReadTimeout("temporary", request=request)
            if failure == "connection":
                raise httpx.ConnectError("temporary", request=request)
            return httpx.Response(failure)
        return httpx.Response(200)

    fetcher = Fetcher.__new__(Fetcher)
    fetcher.client = httpx.Client(transport=httpx.MockTransport(respond))
    fetcher.robots = RobotFileParser()
    fetcher.robots.parse([])
    fetcher.delay = 0
    fetcher.last_request = 0
    monkeypatch.setattr("fetcher.time.sleep", sleeps.append)

    assert fetcher.get(URL, page=2).status_code == 200
    assert len(requests) == 3
    assert all(request.url.params["page"] == "2" for request in requests)
    assert [delay for delay in sleeps if delay > 0] == [1, 2]


@pytest.mark.parametrize(
    "status, attempts",
    [(404, 1), (403, 1), (429, 3), (500, 3), ("timeout", 3), ("connection", 3)],
)
def test_fetcher_stops_after_allowed_attempts(status, attempts):
    requests = []

    def respond(request):
        requests.append(request)
        if status == "timeout":
            raise httpx.ReadTimeout("temporary", request=request)
        if status == "connection":
            raise httpx.ConnectError("temporary", request=request)
        return httpx.Response(status)

    fetcher = Fetcher.__new__(Fetcher)
    fetcher.client = httpx.Client(transport=httpx.MockTransport(respond))
    fetcher.robots = RobotFileParser()
    fetcher.robots.parse([])
    fetcher.delay = 0
    fetcher.last_request = 0
    with pytest.raises(httpx.HTTPError):
        fetcher.get(URL)
    assert len(requests) == attempts


def test_robots_recovers_from_temporary_error():
    requests = []

    def respond(request):
        requests.append(request)
        return httpx.Response(
            503 if len(requests) == 1 else 200,
            text="User-agent: *\nDisallow: /private/",
        )

    robots = load_robots(httpx.Client(transport=httpx.MockTransport(respond)), ROBOTS)
    assert len(requests) == 2
    assert robots.can_fetch(USER_AGENT, URL)
    assert not robots.can_fetch(USER_AGENT, "https://topmarket.pl/private/x")
