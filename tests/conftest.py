import os
import shlex
import subprocess
from dataclasses import dataclass, field
from pathlib import Path
from urllib.parse import urljoin, urlparse

import pytest
from playwright.sync_api import expect

REPO_ROOT = Path(__file__).resolve().parents[1]
LOCAL_HOSTS = {"localhost", "127.0.0.1", "::1"}


@dataclass(frozen=True)
class AdminSettings:
    url: str = field(repr=False)
    email: str = field(repr=False)
    password: str = field(repr=False)


@pytest.fixture(scope="session")
def base_url():
    return os.environ.get("BASE_URL", "https://localhost").rstrip("/") + "/"


def local_admin_url(base_url):
    command = [
        "docker",
        "compose",
        "--env-file",
        ".env",
        "-f",
        "deploy/compose.yaml",
        "exec",
        "-T",
        "prestashop",
        "sh",
        "-c",
        (
            "for dir in /var/www/html/admin*/; do "
            'if [ -f "${dir}index.php" ]; then basename "$dir"; fi; done'
        ),
    ]
    try:
        result = subprocess.run(
            command,
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=True,
            timeout=15,
        )
    except (OSError, subprocess.SubprocessError):
        pytest.fail(
            "Could not find the local back office. Set E2E_ADMIN_URL.", pytrace=False
        )
    directories = result.stdout.splitlines()
    if len(directories) != 1:
        pytest.fail(
            "Set E2E_ADMIN_URL to the PrestaShop back office URL.", pytrace=False
        )
    return urljoin(base_url, directories[0] + "/")


def local_admin_credentials():
    env_file = REPO_ROOT / ".env"
    credentials = {}
    if env_file.is_file():
        for line in env_file.read_text(encoding="utf-8").splitlines():
            key, separator, value = line.strip().removeprefix("export ").partition("=")
            if separator and key.strip() in {"ADMIN_MAIL", "ADMIN_PASSWORD"}:
                value = value.strip()
                if value.startswith(("'", '"')):
                    value = shlex.split(value, comments=True)[0]
                else:
                    value = value.split(" #", 1)[0].rstrip()
                credentials[key.strip()] = value
    return credentials


@pytest.fixture(scope="session")
def admin_settings(base_url):
    url = os.environ.get("E2E_ADMIN_URL")
    email = os.environ.get("E2E_ADMIN_EMAIL")
    password = os.environ.get("E2E_ADMIN_PASSWORD")
    if urlparse(base_url).hostname in LOCAL_HOSTS:
        url = url or local_admin_url(base_url)
        if urlparse(url).hostname in LOCAL_HOSTS and (not email or not password):
            credentials = local_admin_credentials()
            email = email or credentials.get("ADMIN_MAIL")
            password = password or credentials.get("ADMIN_PASSWORD")
    if not (url and email and password):
        pytest.fail(
            "Set E2E_ADMIN_URL, E2E_ADMIN_EMAIL and E2E_ADMIN_PASSWORD.", pytrace=False
        )
    return AdminSettings(url, email, password)


@pytest.fixture(scope="session")
def browser_context_args(browser_context_args, base_url):
    return {
        **browser_context_args,
        "base_url": base_url,
        "viewport": {"width": 1440, "height": 1000},
        "ignore_https_errors": (
            urlparse(base_url).hostname in LOCAL_HOSTS
            or os.environ.get("E2E_IGNORE_HTTPS_ERRORS") == "1"
        ),
    }


@pytest.fixture(autouse=True)
def page_timeouts(page):
    expect.set_options(timeout=15_000)
    page.set_default_timeout(15_000)
    page.set_default_navigation_timeout(30_000)


@pytest.fixture(autouse=True)
def dismiss_cookie_banner(page, page_timeouts):
    page.add_locator_handler(
        page.locator("#domitek-cookie-banner"),
        lambda: page.locator("#domitek-cookie-accept").click(),
    )
