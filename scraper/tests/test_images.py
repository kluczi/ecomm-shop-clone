import io
import json
import random
import types

import pytest
from PIL import Image

import images
from images import MAX_BYTES, MAX_SIDE, MIN_SIDE, to_jpeg


def make_jpeg(width: int, height: int, noisy: bool = False) -> bytes:
    image = Image.new("RGB", (width, height), "white")
    if noisy:  # incompressible content, hard to fit into 300 KB
        rng = random.Random(1)
        pixels = [
            tuple(rng.randrange(256) for _ in range(3)) for _ in range(width * height)
        ]
        image.putdata(pixels)
    buffer = io.BytesIO()
    image.save(buffer, "JPEG", quality=95)
    return buffer.getvalue()


def size_of(jpeg: bytes) -> tuple[int, int]:
    return Image.open(io.BytesIO(jpeg)).size


def test_large_image_is_scaled_down_to_max_side():
    jpeg = to_jpeg(make_jpeg(3000, 2000))

    assert max(size_of(jpeg)) == MAX_SIDE
    assert len(jpeg) <= MAX_BYTES
    assert Image.open(io.BytesIO(jpeg)).format == "JPEG"


def test_image_within_limits_keeps_its_size():
    assert size_of(to_jpeg(make_jpeg(1100, 1422))) == (1100, 1422)


def test_hard_image_is_shrunk_but_never_saved_oversized():
    jpeg = to_jpeg(make_jpeg(1000, 900, noisy=True))

    # either it fits both limits, or it is rejected - never an oversized file
    assert jpeg is None or (
        len(jpeg) <= MAX_BYTES and MIN_SIDE <= max(size_of(jpeg)) <= MAX_SIDE
    )


def test_image_that_cannot_fit_the_size_limit_is_rejected(monkeypatch):
    monkeypatch.setattr("images.MAX_BYTES", 1000)  # impossible for a 1100 px photo
    assert to_jpeg(make_jpeg(1100, 1100, noisy=True)) is None


def test_too_small_image_is_rejected():
    assert to_jpeg(make_jpeg(400, 300)) is None


def test_transparent_png_gets_white_background():
    buffer = io.BytesIO()
    Image.new("RGBA", (900, 900), (0, 0, 0, 0)).save(buffer, "PNG")

    pixel = (
        Image.open(io.BytesIO(to_jpeg(buffer.getvalue())))
        .convert("RGB")
        .getpixel((5, 5))
    )
    assert min(pixel) > 240


def test_blocked_or_broken_image_does_not_stop_the_rest(tmp_path, monkeypatch):
    good = make_jpeg(1100, 1100)

    class FakeFetcher:
        def __init__(self, base_url):
            pass

        def get(self, url):
            if "blocked" in url:
                raise PermissionError("blocked by robots.txt")
            if "broken" in url:
                return types.SimpleNamespace(content=b"not an image")
            return types.SimpleNamespace(content=good)

    products = [
        {
            "id": 1,
            "slider_images": [
                "https://x/blocked.jpg",
                "https://x/broken.jpg",
                "https://x/good.jpg",
            ],
        }
    ]
    (tmp_path / "products.json").write_text(json.dumps(products), encoding="utf-8")
    monkeypatch.setattr(images, "OUTPUT_DIR", tmp_path)
    monkeypatch.setattr(images, "IMAGES_DIR", tmp_path / "images")
    monkeypatch.setattr(images, "SAMPLES_DIR", tmp_path / "samples")
    monkeypatch.setattr(images, "Fetcher", FakeFetcher)
    monkeypatch.setattr(images, "setup_logging", lambda: None)

    with pytest.raises(ValueError, match="image requirements NOT met"):
        images.main()

    assert [f.name for f in (tmp_path / "images" / "1").iterdir()] == ["slider_3.jpg"]


def test_full_gallery_goes_to_products_that_have_one(tmp_path, monkeypatch):
    class FakeFetcher:
        def __init__(self, base_url):
            pass

        def get(self, url):
            return types.SimpleNamespace(content=make_jpeg(1100, 1100))

    def product(product_id, count):
        return {
            "id": product_id,
            "slider_images": [f"https://x/{n}.jpg" for n in range(count)],
        }

    # the first product has one image only, so the gallery slot goes to the next one
    products = [product(1, 1), product(2, 3), product(3, 3)]
    (tmp_path / "products.json").write_text(json.dumps(products), encoding="utf-8")
    monkeypatch.setattr(images, "OUTPUT_DIR", tmp_path)
    monkeypatch.setattr(images, "IMAGES_DIR", tmp_path / "images")
    monkeypatch.setattr(images, "SAMPLES_DIR", tmp_path / "samples")
    monkeypatch.setattr(images, "Fetcher", FakeFetcher)
    monkeypatch.setattr(images, "setup_logging", lambda: None)
    monkeypatch.setattr(images, "FULL_GALLERY_PRODUCTS", 1)

    with pytest.raises(ValueError, match="image requirements NOT met"):
        images.main()

    counts = {
        n: len(list((tmp_path / "images" / str(n)).glob("*.jpg"))) for n in (1, 2, 3)
    }
    assert counts == {1: 1, 2: 3, 3: 1}


@pytest.mark.parametrize(
    "missing_first, galleries", [(False, 50), (True, 50), (False, 49)]
)
def test_requirements_check_saved_images(
    tmp_path, monkeypatch, missing_first, galleries
):
    monkeypatch.setattr(images, "IMAGES_DIR", tmp_path)
    products = [{"id": n} for n in range(51)]
    jpeg = make_jpeg(1100, 1100)
    for n in range(51):
        folder = tmp_path / str(n)
        folder.mkdir()
        if not (missing_first and n == 50):
            (folder / "slider_1.jpg").write_bytes(jpeg)
        if n < galleries:
            (folder / "slider_2.jpg").write_bytes(jpeg)

    if missing_first or galleries < 50:
        with pytest.raises(ValueError, match="image requirements NOT met"):
            images.check_requirements(products)
    else:
        images.check_requirements(products)


@pytest.mark.parametrize("existing", ["oversized", "broken", "valid"])
def test_existing_images_are_checked_and_repaired(tmp_path, monkeypatch, existing):
    jpeg = make_jpeg(1100, 1100)
    folder = tmp_path / "images" / "1"
    folder.mkdir(parents=True)
    path = folder / "slider_1.jpg"
    content = {
        "oversized": jpeg + b"\0" * (300_001 - len(jpeg)),
        "broken": b"broken jpeg",
        "valid": jpeg,
    }[existing]
    path.write_bytes(content)
    requests = []

    class FakeFetcher:
        def __init__(self, base_url):
            pass

        def get(self, url):
            requests.append(url)
            return types.SimpleNamespace(content=jpeg)

    products = [{"id": 1, "slider_images": ["https://x/1.jpg"]}]
    (tmp_path / "products.json").write_text(json.dumps(products), encoding="utf-8")
    monkeypatch.setattr(images, "OUTPUT_DIR", tmp_path)
    monkeypatch.setattr(images, "IMAGES_DIR", tmp_path / "images")
    monkeypatch.setattr(images, "Fetcher", FakeFetcher)
    monkeypatch.setattr(images, "setup_logging", lambda: None)

    # Only one product: the final gallery-count check must still reject this run.
    with pytest.raises(ValueError, match="image requirements NOT met"):
        images.main()
    assert images.valid_image(path)
    assert path.stat().st_size <= 300_000
    assert len(requests) == (1 if existing == "broken" else 0)
    if existing == "valid":
        assert path.read_bytes() == content


def test_requirements_reject_oversized_image_even_with_enough_other_images(
    tmp_path, monkeypatch
):
    monkeypatch.setattr(images, "IMAGES_DIR", tmp_path)
    jpeg = make_jpeg(1100, 1100)
    products = [{"id": n} for n in range(50)]
    for product in products:
        folder = tmp_path / str(product["id"])
        folder.mkdir()
        (folder / "slider_1.jpg").write_bytes(jpeg)
        (folder / "slider_2.jpg").write_bytes(jpeg)
    (tmp_path / "0" / "slider_3.jpg").write_bytes(jpeg + b"\0" * (300_001 - len(jpeg)))
    with pytest.raises(ValueError, match="invalid images: .*slider_3.jpg"):
        images.check_requirements(products)
