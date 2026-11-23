"""Download and unpack product images archive for PrestaShop.

Workflow:
1. Local cache: Check if every product in scraper-results/products.json has images.
2. Local ZIP: Check if scraper-results/images.zip exists locally with valid checksum.
3. GitHub CLI: Check if 'gh' CLI is installed and download release asset.
4. Direct HTTP API: Download via GitHub REST API streaming directly from storage.
5. Scraper Fallback: Run 'scraper/images.py' as safety net.
"""

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
import urllib.error
import urllib.request
import zipfile
from pathlib import Path

RELEASE_TAG = "v1.0.0-images"
ASSET_NAME = "images.zip"
EXPECTED_SHA256 = "f6df0a22378b05137b93d6ba5bd2901e7eabd2ed5943b89c241459107c5925c7"


class NoRedirectHandler(urllib.request.HTTPRedirectHandler):
    """Custom HTTP redirect handler that stops automatic redirect following."""

    def redirect_request(
        self,
        req: urllib.request.Request,
        fp: object,
        code: int,
        msg: str,
        headers: object,
        newurl: str,
    ) -> None:
        return None


def get_required_images_count(repo_root: Path) -> int:
    """Determine minimum required images count based on products.json."""
    products_file = repo_root / "scraper-results" / "products.json"
    if products_file.exists():
        try:
            with open(products_file, "r", encoding="utf-8") as f:
                products = json.load(f)
            if isinstance(products, list) and len(products) > 0:
                return len(products)
        except (json.JSONDecodeError, OSError):
            pass
    return 1000


def check_images_per_product(
    repo_root: Path, images_dir: Path
) -> tuple[bool, int, int]:
    """Verify that every product from products.json has at least one valid image in images_dir."""
    products_file = repo_root / "scraper-results" / "products.json"
    if not products_file.exists():
        return False, 0, 0

    try:
        with open(products_file, "r", encoding="utf-8") as f:
            products = json.load(f)
        if not isinstance(products, list) or len(products) == 0:
            return False, 0, 0
    except (json.JSONDecodeError, OSError):
        return False, 0, 0

    total_products = len(products)
    products_with_images = 0

    for prod in products:
        pid = prod.get("id")
        if not pid:
            continue
        p_dir = images_dir / str(pid)
        if p_dir.is_dir() and any(p.stat().st_size > 0 for p in p_dir.glob("*.jpg")):
            products_with_images += 1

    all_present = (products_with_images == total_products) and total_products > 0
    return all_present, products_with_images, total_products


def verify_zip_integrity(
    zip_path: Path, expected_sha256: str = EXPECTED_SHA256
) -> bool:
    """Verify archive integrity using SHA-256 checksum."""
    if not zip_path.exists() or zip_path.stat().st_size == 0:
        return False
    try:
        with open(zip_path, "rb") as f:
            computed = hashlib.file_digest(f, "sha256").hexdigest().lower()
        if computed != expected_sha256.lower():
            print(
                f"[WARN] Checksum mismatch for {zip_path.name} (got {computed[:12]}..., expected {expected_sha256[:12]}...)."
            )
            return False
        return True
    except OSError as e:
        print(f"[ERROR] Failed to read {zip_path}: {e}")
        return False


def count_existing_images(images_dir: Path) -> int:
    """Count valid JPEG images in product subdirectories."""
    if not images_dir.exists():
        return 0
    return sum(1 for p in images_dir.glob("*/*.jpg") if p.stat().st_size > 0)


def extract_zip(repo_root: Path, zip_path: Path, target_dir: Path) -> bool:
    """Safely verify integrity and extract ZIP archive into target directory."""
    if not verify_zip_integrity(zip_path):
        return False
    print(f"Extracting {zip_path.name} to {target_dir}...")
    target_dir.mkdir(parents=True, exist_ok=True)
    try:
        with zipfile.ZipFile(zip_path, "r") as zf:
            zf.extractall(target_dir)
        all_cached, present_products, total_products = check_images_per_product(
            repo_root, target_dir
        )
        if all_cached:
            print(
                f"[OK] Successfully extracted and verified images ({present_products}/{total_products} products covered)."
            )
            return True
        print(
            f"[WARN] Extracted archive incomplete ({present_products}/{total_products} products covered). Trying next source..."
        )
        return False
    except (zipfile.BadZipFile, OSError) as e:
        print(f"[ERROR] Failed to extract {zip_path}: {e}")
        return False


def download_from_gh_cli(repo_root: Path, zip_path: Path) -> bool:
    """Step 3: Attempt to download images.zip from GitHub Release using gh CLI."""
    print(
        f"Attempting to download {ASSET_NAME} from GitHub Release '{RELEASE_TAG}' via gh CLI..."
    )
    try:
        cmd = [
            "gh",
            "release",
            "download",
            RELEASE_TAG,
            "-p",
            ASSET_NAME,
            "-D",
            str(zip_path.parent),
            "--clobber",
        ]
        result = subprocess.run(
            cmd,
            cwd=repo_root,
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode == 0 and zip_path.exists() and zip_path.stat().st_size > 0:
            print(f"[OK] Downloaded {zip_path.name} via gh CLI.")
            return True
        if result.returncode != 0:
            print(
                f"[INFO] gh release download exited with code {result.returncode} ({result.stderr.strip()[:100]})."
            )
    except FileNotFoundError:
        print("[INFO] GitHub CLI ('gh') is not installed on this machine.")
    except subprocess.SubprocessError as e:
        print(f"[WARN] gh execution error: {e}")
    return False


def download_from_http_api(zip_path: Path) -> bool:
    """Step 4: Attempt direct HTTP download from GitHub Releases REST API.

    GitHub API responds to asset stream requests with a 302 redirect to storage (AWS S3).
    We intercept the redirect URL and make the download request without the Authorization
    header so authentication mechanisms do not clash.
    """
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    api_url = f"https://api.github.com/repos/kluczi/ecomm-shop-clone/releases/tags/{RELEASE_TAG}"
    print(f"Attempting direct HTTP download from GitHub API ({api_url})...")
    try:
        req = urllib.request.Request(api_url)
        req.add_header("User-Agent", "Python-Release-Downloader")
        if token:
            req.add_header("Authorization", f"Bearer {token}")
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            for asset in data.get("assets", []):
                if asset.get("name") == ASSET_NAME:
                    asset_api_url = asset.get("url")
                    if not asset_api_url:
                        continue
                    size_mb = asset.get("size", 0) / (1024 * 1024)
                    print(
                        f"Downloading {ASSET_NAME} via GitHub API ({size_mb:.1f} MB)..."
                    )
                    asset_req = urllib.request.Request(asset_api_url)
                    asset_req.add_header("User-Agent", "Python-Release-Downloader")
                    asset_req.add_header("Accept", "application/octet-stream")
                    if token:
                        asset_req.add_header("Authorization", f"Bearer {token}")

                    # Intercept 302 redirect from GitHub API to get AWS S3 presigned URL
                    opener = urllib.request.build_opener(NoRedirectHandler())
                    download_url = None
                    try:
                        with opener.open(asset_req, timeout=30) as r:
                            download_url = r.geturl()
                    except urllib.error.HTTPError as e:
                        if e.code in (301, 302, 303, 307, 308):
                            download_url = e.headers.get("Location")
                        else:
                            raise

                    if not download_url:
                        print(
                            "[WARN] Could not retrieve download URL from GitHub redirect."
                        )
                        continue

                    # Stream download from storage without Authorization header
                    download_req = urllib.request.Request(download_url)
                    download_req.add_header("User-Agent", "Python-Release-Downloader")
                    with (
                        urllib.request.urlopen(download_req, timeout=120) as in_f,
                        open(zip_path, "wb") as out_f,
                    ):
                        while chunk := in_f.read(1024 * 1024):
                            out_f.write(chunk)

                    if zip_path.exists() and zip_path.stat().st_size > 0:
                        print(f"[OK] Downloaded {zip_path.name} via HTTP API.")
                        return True
    except (urllib.error.URLError, TimeoutError, OSError) as e:
        print(f"[INFO] Direct HTTP release download unavailable: {e}")
    return False


def fallback_scraper(repo_root: Path) -> bool:
    """Step 5: Fallback to running scraper/images.py."""
    print(
        "[WARN] GitHub Release unavailable. Falling back to scraping images via scraper/images.py..."
    )
    scraper_script = repo_root / "scraper" / "images.py"
    if not scraper_script.exists():
        print(f"[ERROR] Missing fallback scraper script: {scraper_script}")
        return False
    try:
        cmd = [sys.executable, str(scraper_script)]
        result = subprocess.run(cmd, cwd=repo_root, check=False)
        return result.returncode == 0
    except subprocess.SubprocessError as e:
        print(f"[ERROR] Failed to execute fallback scraper: {e}")
        return False


def ensure_images(repo_root: Path | None = None) -> bool:
    """Ensure product images are downloaded and available according to multi-tier workflow."""
    if repo_root is None:
        repo_root = Path(__file__).resolve().parent.parent

    images_dir = repo_root / "scraper-results" / "images"
    zip_path = repo_root / "scraper-results" / ASSET_NAME

    # 1. Local cache: Check if every product has images present
    all_cached, present_products, total_products = check_images_per_product(
        repo_root, images_dir
    )
    if all_cached:
        print(
            f"[OK] Product images cache verified ({present_products}/{total_products} products have images). Skipping download."
        )
        return True

    print(
        f"Product images cache incomplete ({present_products}/{total_products} products covered). Provisioning..."
    )

    # 2. Local ZIP: Check if local archive already exists and is valid
    if zip_path.exists():
        if verify_zip_integrity(zip_path):
            print(f"Found valid local archive: {zip_path.name} (SHA-256 verified)")
            if extract_zip(repo_root, zip_path, images_dir):
                return True
        else:
            print(
                f"[WARN] Existing {zip_path.name} is incomplete or corrupted. Removing before download."
            )
            zip_path.unlink(missing_ok=True)

    # 3. GitHub CLI: Download via 'gh release download'
    if download_from_gh_cli(repo_root, zip_path) and extract_zip(
        repo_root, zip_path, images_dir
    ):
        return True

    # 4. Direct HTTP API: Download via GitHub REST API
    if download_from_http_api(zip_path) and extract_zip(
        repo_root, zip_path, images_dir
    ):
        return True

    # 5. Scraper Fallback: Execute scraper/images.py
    return fallback_scraper(repo_root)


def main() -> None:
    repo_root = Path(__file__).resolve().parent.parent
    if not ensure_images(repo_root):
        print("[ERROR] Failed to ensure product images.")
        sys.exit(1)


if __name__ == "__main__":
    main()
