import logging
import time
from urllib.parse import urlsplit
from urllib.robotparser import RobotFileParser

import httpx

logger = logging.getLogger(__name__)

USER_AGENT = "topmarket-scraper"
# Identify ourselves honestly instead of pretending to be a browser.
HEADERS = {"User-Agent": f"{USER_AGENT}/0.1 (student project: ecomm-shop-clone)"}
DELAY_SECONDS = 0.5  # pause between requests


def request_with_retries(client, url, before_request=None, **kwargs) -> httpx.Response:
    for attempt in range(3):
        if before_request is not None:
            before_request()
        try:
            response = client.get(url, **kwargs)
        except (httpx.TimeoutException, httpx.NetworkError):
            if attempt == 2:
                raise
        else:
            if response.status_code != 429 and not 500 <= response.status_code < 600:
                return response
            if attempt == 2:
                response.raise_for_status()
        time.sleep(2**attempt)


def load_robots(client: httpx.Client, robots_url: str) -> RobotFileParser:
    """Rules from robots.txt: 200 = use them, 404 = no rules (all allowed),
    401/403 = all forbidden. Any other status (429, 5xx, ...) raises an error,
    because then we cannot know what is allowed."""
    response = request_with_retries(client, robots_url)
    robots = RobotFileParser(robots_url)
    if response.status_code == 200:
        robots.parse(response.text.splitlines())
    elif response.status_code == 404:
        robots.parse([])
    elif response.status_code in (401, 403):
        robots.parse(["User-agent: *", "Disallow: /"])
    else:
        response.raise_for_status()
        raise httpx.HTTPError(f"unexpected robots.txt status {response.status_code}")
    return robots


class Fetcher:
    """HTTP client that obeys robots.txt and waits between requests."""

    def __init__(self, base_url: str):
        self.client = httpx.Client(timeout=30, follow_redirects=True, headers=HEADERS)
        self.last_request = 0.0

        parts = urlsplit(base_url)
        self.robots = load_robots(
            self.client, f"{parts.scheme}://{parts.netloc}/robots.txt"
        )
        self.delay = max(DELAY_SECONDS, self.robots.crawl_delay(USER_AGENT) or 0)

    def get(self, url: str, **params) -> httpx.Response:
        if not self.robots.can_fetch(USER_AGENT, url):
            raise PermissionError(f"blocked by robots.txt: {url}")

        def wait_for_request():
            time.sleep(max(0, self.last_request + self.delay - time.monotonic()))
            self.last_request = time.monotonic()

        response = request_with_retries(
            self.client, url, before_request=wait_for_request, params=params
        )
        response.raise_for_status()
        return response
