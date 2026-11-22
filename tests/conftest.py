import os
from urllib.parse import urlparse

import pytest
from playwright.sync_api import expect


@pytest.fixture(scope="session")
def base_url():
    return os.environ.get("BASE_URL", "https://topmarket.pl").rstrip("/")


@pytest.fixture(scope="session")
def browser_type_launch_args(browser_type_launch_args):
    # The source server intermittently closes Chromium's HTTP/2 connections.
    return {**browser_type_launch_args, "args": ["--disable-http2"]}


@pytest.fixture(scope="session")
def browser_context_args(browser_context_args, base_url):
    return {
        **browser_context_args,
        "base_url": base_url,
        "viewport": {"width": 1440, "height": 1000},
        "ignore_https_errors": urlparse(base_url).hostname
        in ("localhost", "127.0.0.1", "::1"),
    }


@pytest.fixture(autouse=True)
def page_timeouts(page):
    expect.set_options(timeout=15_000)
    page.set_default_timeout(15_000)
    page.set_default_navigation_timeout(30_000)


@pytest.fixture(autouse=True)
def dismiss_source_cookie_banner(page, base_url, page_timeouts):
    if urlparse(base_url).hostname in ("topmarket.pl", "www.topmarket.pl"):
        reject = page.get_by_role("button", name="Odmowa", exact=True)
        page.add_locator_handler(reject, lambda button: button.click())
