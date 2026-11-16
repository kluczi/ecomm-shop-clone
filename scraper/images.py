"""Download product images from products.json (safe to re-run).

Every image is scaled so its longer side is 800-1600 px and saved as JPEG of at
most 300 KB. An image that cannot meet both limits is logged and NOT saved.

Policy, to keep the repository small: every product gets its first slider
image, and FULL_GALLERY_PRODUCTS products that have a gallery (2+ images) get
all of it, so at least 50 products end up with 2+ images.

Usage: uv run python images.py
Result: scraper-results/images/<product_id>/slider_<n>.jpg (not in git) and
20 example images in scraper-results/sample-images/ (committed)
"""

import io
import json
import logging
import shutil

import httpx
from PIL import Image, ImageOps

from fetcher import Fetcher
from scraper import BASE_URL, OUTPUT_DIR, setup_logging

logger = logging.getLogger("images")

IMAGES_DIR = OUTPUT_DIR / "images"
MIN_SIDE = 800
MAX_SIDE = 1600
MAX_BYTES = 300_000
QUALITIES = (85, 70, 55, 40)
FULL_GALLERY_PRODUCTS = 60
SAMPLES_DIR = OUTPUT_DIR / "sample-images"  # the only images committed to git
SAMPLE_IMAGES = 20


def to_jpeg(data: bytes) -> bytes | None:
    """Resize and encode; returns None if no size/quality fits the limits."""
    image = ImageOps.exif_transpose(Image.open(io.BytesIO(data)))
    if max(image.size) < MIN_SIDE:
        return None  # too small, we never upscale

    if image.mode in ("RGBA", "LA", "P"):  # flatten transparency onto white
        image = image.convert("RGBA")
        background = Image.new("RGB", image.size, "white")
        background.paste(image, mask=image.getchannel("A"))
        image = background
    image = image.convert("RGB")

    side = min(MAX_SIDE, max(image.size))
    while side >= MIN_SIDE:
        resized = image.copy()
        resized.thumbnail((side, side), Image.LANCZOS)
        for quality in QUALITIES:
            buffer = io.BytesIO()
            resized.save(buffer, "JPEG", quality=quality, optimize=True)
            if buffer.tell() <= MAX_BYTES:
                return buffer.getvalue()
        side = int(side * 0.9)  # still too big: try smaller dimensions
    return None


def valid_image(path) -> bool:
    try:
        if path.stat().st_size > MAX_BYTES:
            return False
        with Image.open(path) as image:
            valid = (
                image.format in ("JPEG", "WEBP")
                and MIN_SIDE <= max(image.size) <= MAX_SIDE
            )
            image.load()
        return valid
    except OSError:
        return False


def main() -> None:
    setup_logging()
    products = json.loads((OUTPUT_DIR / "products.json").read_text(encoding="utf-8"))
    fetcher = Fetcher(BASE_URL)
    saved = failed = 0

    with_gallery = [p["id"] for p in products if len(p["slider_images"]) >= 2]
    full_gallery_ids = with_gallery[:FULL_GALLERY_PRODUCTS]

    for product in products:
        urls = product["slider_images"]
        if product["id"] not in full_gallery_ids:
            urls = urls[:1]

        folder = IMAGES_DIR / str(product["id"])
        folder.mkdir(parents=True, exist_ok=True)
        for number, url in enumerate(urls, 1):
            path = folder / f"slider_{number}.jpg"
            if path.exists() and valid_image(path):
                continue
            try:
                jpeg = None
                if path.exists():
                    try:
                        jpeg = to_jpeg(path.read_bytes())
                    except OSError:
                        pass  # download again if the existing image is broken
                if jpeg is None:
                    jpeg = to_jpeg(fetcher.get(url).content)
            except (
                httpx.HTTPError,
                OSError,
            ) as error:  # OSError covers PermissionError (robots.txt) and unreadable images
                logger.error("image failed %s: %s", url, error)
                failed += 1
                continue
            if jpeg is None:
                logger.error("image cannot meet size limits, not saved: %s", url)
                failed += 1
                continue
            temp = path.with_suffix(".part")
            temp.write_bytes(jpeg)
            temp.replace(path)  # an interrupted write never leaves a broken .jpg
            saved += 1

    logger.info("images saved: %d, failed: %d", saved, failed)
    check_requirements(products)
    copy_samples(products)


def copy_samples(products: list[dict]) -> None:
    """The repository may hold up to 20 example images: copy the first image of
    20 products spread over the whole list (so over all categories)."""
    shutil.rmtree(SAMPLES_DIR, ignore_errors=True)  # never more than 20 files
    SAMPLES_DIR.mkdir(exist_ok=True)
    step = max(1, len(products) // SAMPLE_IMAGES)
    for product in products[::step][:SAMPLE_IMAGES]:
        source = IMAGES_DIR / str(product["id"]) / "slider_1.jpg"
        if source.exists():
            shutil.copy(source, SAMPLES_DIR / f"{product['id']}.jpg")


def check_requirements(products: list[dict]) -> None:
    """Count the images that really are on disk: >= 1 for every product and
    >= 2 for at least 50 products."""
    counts = []
    invalid = []
    for product in products:
        paths = list((IMAGES_DIR / str(product["id"])).glob("slider_*.jpg"))
        good = 0
        for path in paths:
            if valid_image(path):
                good += 1
            else:
                invalid.append(str(path))
        counts.append(good)
    with_one = sum(count >= 1 for count in counts)
    with_two = sum(count >= 2 for count in counts)
    logger.info(
        "products with 1+ images: %d/%d, with 2+: %d", with_one, len(products), with_two
    )
    if invalid or with_one < len(products) or with_two < 50:
        raise ValueError(
            f"image requirements NOT met: {with_one}/{len(products)} products "
            f"have 1+ images, {with_two}/50 have 2+; invalid images: {invalid}"
        )


if __name__ == "__main__":
    main()
