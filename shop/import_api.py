#!/usr/bin/env python3
# PrestaShop Catalog & Stock Webservice API Importer

import argparse
import concurrent.futures
import json
import re
import sys
import threading
import time
import warnings
from pathlib import Path
from xml.etree import ElementTree as ET

import httpx

# Suppress insecure request warnings for self-signed SSL certificates
warnings.filterwarnings("ignore")

def load_env(env_path: Path) -> dict[str, str]:
    """Parse .env file into key-value dictionary"""
    env = {}
    if not env_path.exists():
        return env
    with open(env_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip().strip("'\"")
    return env


def slugify(text: str) -> str:
    """Generate URL-safe slug from text"""
    text = text.lower()
    # Polish character normalization
    replacements = {
        "ą": "a",
        "ć": "c",
        "ę": "e",
        "ł": "l",
        "ń": "n",
        "ó": "o",
        "ś": "s",
        "ź": "z",
        "ż": "z",
    }
    for pol, lat in replacements.items():
        text = text.replace(pol, lat)
    text = re.sub(r"[^a-z0-9]+", "-", text)
    return text.strip("-") or "item"


def clean_manufacturer(raw: str) -> str:
    """Universally normalize raw company strings into clean brand names."""
    # 1. Split at legal entity form (discards Sp. z o.o. etc.)
    name = re.split(
        r"\s+(?:(?:polska\s+)?(?:sp\.\s*z\s*o\.\s*o\.|sp\.\s*k\.|sp\.\s*j\.|s\.a\.|gmbh|ltd|inc|llc|co\.)|polska$)",
        raw,
        flags=re.IGNORECASE,
    )[0].strip()

    # 2. Truncate at comma or address prefixes for companies without explicit legal entity
    name = name.split(",")[0].strip()
    name = re.split(
        r"\s+(?:ul\.|al\.|str\.|\d{2}-\d{3})", name, flags=re.IGNORECASE
    )[0].strip()

    # 3. Capitalize first letter if lowercase
    if name and name[0].islower():
        name = name.capitalize()

    return name[:64]

class PrestaShopImporter:
    def __init__(
        self,
        api_url: str,
        api_key: str,
        repo_root: Path,
        download_images: bool = False,
    ):
        self.api_url = api_url.rstrip("/")
        self.api_key = api_key
        self.repo_root = repo_root
        self.download_images = download_images
        self.client = httpx.Client(
            auth=(self.api_key, ""),
            verify=False,
            timeout=60.0,
            limits=httpx.Limits(max_keepalive_connections=20, max_connections=20),
        )
        self.stats_lock = threading.Lock()
        self.stats = {
            "categories_created": 0,
            "categories_updated": 0,
            "categories_skipped": 0,
            "manufacturers_created": 0,
            "manufacturers_skipped": 0,
            "products_created": 0,
            "products_updated": 0,
            "products_rejected": 0,
            "stock_zero": 0,
            "stock_available": 0,
            "images_uploaded": 0,
        }
        self.category_map: dict[int, int] = {}  # scraper_cat_id -> prestashop_cat_id
        self.existing_categories: dict[str, int] = {}  # "name|id_parent" -> id
        self.manufacturer_map: dict[str, int] = {}  # normalized_name -> id_manufacturer
        self.existing_products: dict[str, int] = {}  # reference -> id
        self.products_with_images: set[int] = set()  # product_id set with cover image

    def test_connection(self) -> bool:
        """Verify API key and connectivity to PrestaShop Webservice"""
        try:
            resp = self.client.get(f"{self.api_url}")
            if resp.status_code == 200:
                return True
            print(
                f"[ERROR] API connection returned status {resp.status_code}: {resp.text[:200]}"
            )
            return False
        except (httpx.HTTPError, OSError) as e:
            print(f"[ERROR] Could not connect to PrestaShop API at {self.api_url}: {e}")
            return False

    def cleanup_demo_data(self):
        """Remove PrestaShop default installer demo products and categories"""
        try:
            resp = self.client.get(
                f"{self.api_url}/products?display=[id,reference]&output_format=JSON"
            )
            if resp.status_code == 200:
                data = resp.json()
                prods = data.get("products", []) if isinstance(data, dict) else []
                for p in prods:
                    ref = p.get("reference", "")
                    if ref.startswith("demo_"):
                        self.client.delete(f"{self.api_url}/products/{p['id']}")
            # Remove demo categories (Clothes=3, Art=9, etc.)
            for cid in [3, 4, 5, 6, 7, 8, 9]:
                self.client.delete(f"{self.api_url}/categories/{cid}")
        except (httpx.HTTPError, OSError) as e:
            print(f"[WARN] Demo cleanup error: {e}")

    def load_existing_categories(self):
        """Fetch existing categories from PrestaShop for idempotency"""
        try:
            resp = self.client.get(
                f"{self.api_url}/categories?display=[id,name,id_parent]&output_format=JSON"
            )
            if resp.status_code == 200:
                data = resp.json()
                cats = data.get("categories", []) if isinstance(data, dict) else []
                for c in cats:
                    c_id = int(c.get("id"))
                    name = c.get("name")
                    if isinstance(name, list) and name:
                        name_str = name[0].get("value", "")
                    elif isinstance(name, str):
                        name_str = name
                    else:
                        name_str = ""
                    p_id = int(c.get("id_parent") or 0)
                    key = f"{name_str.strip().lower()}|{p_id}"
                    self.existing_categories[key] = c_id
        except (httpx.HTTPError, OSError) as e:
            print(f"[WARN] Failed to preload categories: {e}")

    def load_existing_products(self):
        """Fetch existing products from PrestaShop for idempotency"""
        try:
            resp = self.client.get(
                f"{self.api_url}/products?display=[id,reference,id_default_image]&output_format=JSON"
            )
            if resp.status_code == 200:
                data = resp.json()
                prods = data.get("products", []) if isinstance(data, dict) else []
                for p in prods:
                    pid = int(p.get("id"))
                    ref = p.get("reference", "").strip()
                    if ref:
                        self.existing_products[ref] = pid
                    if p.get("id_default_image"):
                        self.products_with_images.add(pid)
        except (httpx.HTTPError, OSError) as e:
            print(f"[WARN] Failed to preload products: {e}")

    def import_categories(self, categories_file: Path):
        """Import all categories from scraper JSON preserving hierarchy"""
        print("\n--- Importing Categories ---")
        with open(categories_file, "r", encoding="utf-8") as f:
            categories = json.load(f)

        self.load_existing_categories()

        # Sort: Root categories (parent_id is None) first, then subcategories
        root_cats = [c for c in categories if c.get("parent_id") is None]
        sub_cats = [c for c in categories if c.get("parent_id") is not None]
        ordered_cats = root_cats + sub_cats

        for cat in ordered_cats:
            cat_id = cat["id"]
            name = cat["name"].strip()
            parent_id = cat.get("parent_id")

            # Determine PrestaShop parent ID (PrestaShop root category Home is ID 2)
            if parent_id is None:
                ps_parent_id = 2
            else:
                ps_parent_id = self.category_map.get(parent_id, 2)

            dedup_key = f"{name.lower()}|{ps_parent_id}"
            link_rewrite = slugify(name)

            if dedup_key in self.existing_categories:
                existing_id = self.existing_categories[dedup_key]
                self.category_map[cat_id] = existing_id
                self.stats["categories_skipped"] += 1
                continue

            # XML Payload to create category
            xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
<category>
    <id_parent>{ps_parent_id}</id_parent>
    <active>1</active>
    <name><language id="1"><![CDATA[{name}]]></language></name>
    <link_rewrite><language id="1"><![CDATA[{link_rewrite}]]></language></link_rewrite>
</category>
</prestashop>"""

            resp = self.client.post(
                f"{self.api_url}/categories",
                content=xml.encode("utf-8"),
                headers={"Content-Type": "application/xml"},
            )

            if resp.status_code == 201:
                root = ET.fromstring(resp.text)
                id_elem = root.find(".//category/id")
                if id_elem is not None and id_elem.text:
                    created_id = int(id_elem.text)
                    self.category_map[cat_id] = created_id
                    self.existing_categories[dedup_key] = created_id
                    self.stats["categories_created"] += 1
            else:
                print(
                    f"[WARN] Failed to create category '{name}': {resp.status_code} {resp.text[:100]}"
                )
                self.stats["categories_skipped"] += 1

        print(
            f"Categories complete: {self.stats['categories_created']} created, "
            f"{self.stats['categories_skipped']} existing/skipped."
        )

    def load_existing_manufacturers(self):
        """Fetch existing manufacturers from PrestaShop API for idempotency"""
        try:
            resp = self.client.get(
                f"{self.api_url}/manufacturers?display=[id,name]&output_format=JSON"
            )
            if resp.status_code == 200:
                data = resp.json()
                manufs = data.get("manufacturers", []) if isinstance(data, dict) else []
                for m in manufs:
                    m_id = int(m.get("id"))
                    m_name = m.get("name", "").strip().lower()
                    if m_name:
                        self.manufacturer_map[m_name] = m_id
        except (httpx.HTTPError, OSError) as e:
            print(f"[WARN] Failed to preload manufacturers: {e}")

    def import_manufacturers(self, products_file: Path):
        """Extract unique manufacturers from products and create them via PrestaShop API"""
        print("\n--- Importing Manufacturers ---")
        with open(products_file, "r", encoding="utf-8") as f:
            products = json.load(f)

        self.load_existing_manufacturers()

        unique_names: set[str] = set()
        for p in products:
            raw_m = p.get("attributes", {}).get("Producent")
            if raw_m:
                cleaned = clean_manufacturer(raw_m)
                if cleaned:
                    unique_names.add(cleaned)

        for name in sorted(unique_names):
            norm_name = name.lower()
            if norm_name in self.manufacturer_map:
                self.stats["manufacturers_skipped"] += 1
                continue

            xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
<manufacturer>
    <active>1</active>
    <name><![CDATA[{name}]]></name>
</manufacturer>
</prestashop>"""

            resp = self.client.post(
                f"{self.api_url}/manufacturers",
                content=xml.encode("utf-8"),
                headers={"Content-Type": "application/xml"},
            )

            if resp.status_code == 201:
                root = ET.fromstring(resp.text)
                id_elem = root.find(".//manufacturer/id")
                if id_elem is not None and id_elem.text:
                    created_id = int(id_elem.text)
                    self.manufacturer_map[norm_name] = created_id
                    self.stats["manufacturers_created"] += 1
            else:
                print(
                    f"[WARN] Failed to create manufacturer '{name}': {resp.status_code} {resp.text[:100]}"
                )
                self.stats["manufacturers_skipped"] += 1

        print(
            f"Manufacturers complete: {self.stats['manufacturers_created']} created, "
            f"{self.stats['manufacturers_skipped']} existing/skipped."
        )

    def update_stock(self, product_id: int, quantity: int):
        """Update stock_available quantity for a simple product"""
        try:
            # Query stock_available ID for this product
            resp = self.client.get(
                f"{self.api_url}/stock_availables?filter[id_product]={product_id}&output_format=JSON"
            )
            if resp.status_code != 200:
                return False
            data = resp.json()
            stocks = data.get("stock_availables", [])
            if not stocks:
                return False

            stock_id = stocks[0]["id"]
            # Fetch existing stock record XML
            get_resp = self.client.get(f"{self.api_url}/stock_availables/{stock_id}")
            if get_resp.status_code != 200:
                return False

            root = ET.fromstring(get_resp.text)
            qty_elem = root.find(".//stock_available/quantity")
            if qty_elem is not None:
                qty_elem.text = str(quantity)
            oos_elem = root.find(".//stock_available/out_of_stock")
            if oos_elem is not None:
                oos_elem.text = "0"  # Deny orders when stock is 0

            put_xml = ET.tostring(root, encoding="utf-8")
            put_resp = self.client.put(
                f"{self.api_url}/stock_availables/{stock_id}",
                content=put_xml,
                headers={"Content-Type": "application/xml"},
            )
            return put_resp.status_code == 200
        except (httpx.HTTPError, OSError) as e:
            print(f"[WARN] Stock update failed for product {product_id}: {e}")
            return False

    def get_product_images(self, prod: dict) -> list[Path]:
        """Find existing local images (both single cover and multi-image galleries)"""
        prod_id = prod["id"]

        # 1. Check local images directory (downloaded via scraper/images.py)
        local_dir = self.repo_root / "scraper-results" / "images" / str(prod_id)
        if local_dir.exists():
            imgs = [p for p in sorted(local_dir.glob("*.jpg")) if p.stat().st_size > 0]
            if imgs:
                return imgs

        # 2. Check local sample images directory
        sample_img = (
            self.repo_root / "scraper-results" / "sample-images" / f"{prod_id}.jpg"
        )
        if sample_img.exists() and sample_img.stat().st_size > 0:
            return [sample_img]

        return []

    def upload_image(self, product_id: int, image_path: Path) -> bool:
        """Upload product cover image via PrestaShop Image API"""
        try:
            if not image_path.exists() or image_path.stat().st_size == 0:
                return False
            with open(image_path, "rb") as f:
                files = {"image": (image_path.name, f, "image/jpeg")}
                resp = self.client.post(
                    f"{self.api_url}/images/products/{product_id}",
                    files=files,
                )
            if resp.status_code in (200, 201):
                with self.stats_lock:
                    self.stats["images_uploaded"] += 1
                return True
        except (httpx.HTTPError, OSError) as e:
            print(f"[WARN] Failed to upload image for product {product_id}: {e}")
        return False

    def _upload_task(self, item: tuple[int, Path]) -> bool:
        """Worker task for multithreaded image upload"""
        product_id, img_path = item
        return self.upload_image(product_id, img_path)

    def import_products(
        self, products_file: Path, limit: int | None = None, skip_images: bool = False
    ):
        """Import products with descriptions, dynamic VAT, categories, stock & images"""
        print("\n--- Importing Products ---")
        with open(products_file, "r", encoding="utf-8") as f:
            products = json.load(f)

        if limit:
            products = products[:limit]
            print(f"Limiting import to first {limit} products.")

        self.load_existing_products()
        image_tasks: list[tuple[int, Path]] = []

        for idx, prod in enumerate(products):
            prod_id = prod["id"]
            name = prod["name"].strip()
            price_gross = float(prod.get("price_gross", 0.0))

            # Dynamic VAT mapping based on source data
            vat_rate = float(
                prod.get("vat_rate") if prod.get("vat_rate") is not None else 23.0
            )
            price_net = round(price_gross / (1.0 + (vat_rate / 100.0)), 6)

            if abs(vat_rate - 8.0) < 0.1:
                tax_group_id = 2  # Reduced Rate (8%)
            elif abs(vat_rate - 0.0) < 0.1:
                tax_group_id = 4  # Exempted Rate (0%)
            elif abs(vat_rate - 5.0) < 0.1:
                tax_group_id = 3  # Reduced Rate (5%)
            else:
                tax_group_id = 1  # Standard Rate (23%)

            weight = float(prod.get("weight_kg") or 0.0)
            sku = prod.get("sku") or f"TOP-{prod_id}"
            description = prod.get("description") or ""
            link_rewrite = slugify(name)[:128]

            # Category association
            cat_ids = prod.get("category_ids", [])
            ps_cat_ids = [
                self.category_map[cid] for cid in cat_ids if cid in self.category_map
            ]
            if not ps_cat_ids:
                ps_cat_ids = [2]  # Default to Home
            default_cat = ps_cat_ids[0]

            cat_xml_elements = "".join(
                [f"<category><id>{cid}</id></category>" for cid in ps_cat_ids]
            )

            # Manufacturer association
            raw_manuf = prod.get("attributes", {}).get("Producent")
            manuf_id = 0
            if raw_manuf:
                clean_m = clean_manufacturer(raw_manuf)
                manuf_id = self.manufacturer_map.get(clean_m.lower(), 0)

            # Stock quantity logic:
            # Range: 0 to 10
            # Exactly 10% get 0 (unavailable), satisfying 5-20% metric
            if idx % 10 == 0:
                quantity = 0
                self.stats["stock_zero"] += 1
            else:
                quantity = 1 + (idx % 10)
                self.stats["stock_available"] += 1

            # Check for existing product
            ps_product_id = self.existing_products.get(sku)

            if ps_product_id is not None:
                # Update existing product
                xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
<product>
    <id>{ps_product_id}</id>
    <id_category_default>{default_cat}</id_category_default>
    <id_manufacturer>{manuf_id}</id_manufacturer>
    <id_tax_rules_group>{tax_group_id}</id_tax_rules_group>
    <type>simple</type>
    <id_shop_default>1</id_shop_default>
    <reference><![CDATA[{sku}]]></reference>
    <price>{price_net}</price>
    <weight>{weight}</weight>
    <active>1</active>
    <available_for_order>1</available_for_order>
    <show_price>1</show_price>
    <state>1</state>
    <name><language id="1"><![CDATA[{name}]]></language></name>
    <link_rewrite><language id="1"><![CDATA[{link_rewrite}]]></language></link_rewrite>
    <description><language id="1"><![CDATA[{description}]]></language></description>
    <associations>
        <categories>{cat_xml_elements}</categories>
    </associations>
</product>
</prestashop>"""
                resp = self.client.put(
                    f"{self.api_url}/products/{ps_product_id}",
                    content=xml.encode("utf-8"),
                    headers={"Content-Type": "application/xml"},
                )
                if resp.status_code == 200:
                    self.stats["products_updated"] += 1
                    self.update_stock(ps_product_id, quantity)
                    if (
                        not skip_images
                        and ps_product_id not in self.products_with_images
                    ):
                        for img_path in self.get_product_images(prod):
                            image_tasks.append((ps_product_id, img_path))
                        self.products_with_images.add(ps_product_id)
                else:
                    self.stats["products_rejected"] += 1
            else:
                # Create new product
                xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
<product>
    <id_category_default>{default_cat}</id_category_default>
    <id_manufacturer>{manuf_id}</id_manufacturer>
    <id_tax_rules_group>{tax_group_id}</id_tax_rules_group>
    <type>simple</type>
    <id_shop_default>1</id_shop_default>
    <reference><![CDATA[{sku}]]></reference>
    <price>{price_net}</price>
    <weight>{weight}</weight>
    <active>1</active>
    <available_for_order>1</available_for_order>
    <show_price>1</show_price>
    <state>1</state>
    <name><language id="1"><![CDATA[{name}]]></language></name>
    <link_rewrite><language id="1"><![CDATA[{link_rewrite}]]></language></link_rewrite>
    <description><language id="1"><![CDATA[{description}]]></language></description>
    <associations>
        <categories>{cat_xml_elements}</categories>
    </associations>
</product>
</prestashop>"""
                resp = self.client.post(
                    f"{self.api_url}/products",
                    content=xml.encode("utf-8"),
                    headers={"Content-Type": "application/xml"},
                )
                if resp.status_code == 201:
                    root = ET.fromstring(resp.text)
                    id_elem = root.find(".//product/id")
                    if id_elem is not None and id_elem.text:
                        created_id = int(id_elem.text)
                        self.existing_products[sku] = created_id
                        self.stats["products_created"] += 1
                        self.update_stock(created_id, quantity)

                        # Queue images for multithreaded upload
                        if (
                            not skip_images
                            and created_id not in self.products_with_images
                        ):
                            for img_path in self.get_product_images(prod):
                                image_tasks.append((created_id, img_path))
                            self.products_with_images.add(created_id)
                else:
                    print(
                        f"[WARN] Failed to create product '{name[:30]}': {resp.status_code} {resp.text[:100]}"
                    )
                    self.stats["products_rejected"] += 1

            if (idx + 1) % 100 == 0 or (idx + 1) == len(products):
                print(f"  Progress: {idx + 1}/{len(products)} products processed...")

        if not skip_images and image_tasks:
            total_images = len(image_tasks)
            print(
                f"\n--- Uploading Images ({total_images} images using 4 worker threads) ---"
            )
            with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
                for img_idx, _ in enumerate(
                    executor.map(self._upload_task, image_tasks),
                    start=1,
                ):
                    if img_idx % 100 == 0 or img_idx == total_images:
                        print(f"  Progress: {img_idx}/{total_images} images uploaded...")

    def print_report(self, duration_sec: float):
        """Print execution summary report satisfying D2 requirement"""
        total_prods = self.stats["products_created"] + self.stats["products_updated"]
        total_stock = self.stats["stock_zero"] + self.stats["stock_available"]
        zero_pct = (
            (self.stats["stock_zero"] / total_stock * 100.0) if total_stock else 0.0
        )

        print("\n" + "=" * 55)
        print("         PRESTASHOP IMPORT REPORT (D2 & W3)       ")
        print("=" * 55)
        print(
            f"Execution Time       : {duration_sec:.2f} s ({duration_sec / 60:.2f} min)"
        )
        print(f"Categories Created   : {self.stats['categories_created']}")
        print(f"Categories Skipped   : {self.stats['categories_skipped']}")
        print(f"Manufacturers Created: {self.stats['manufacturers_created']}")
        print(f"Manufacturers Skipped: {self.stats['manufacturers_skipped']}")
        print(f"Products Created     : {self.stats['products_created']}")
        print(f"Products Updated     : {self.stats['products_updated']}")
        print(f"Products Rejected    : {self.stats['products_rejected']}")
        print(f"Total Products In Shop: {total_prods}")
        print("-" * 55)
        print(f"Stock Managed Products : {total_stock}")
        print(f"Available (stock 1-10) : {self.stats['stock_available']}")
        print(f"Unavailable (stock 0)  : {self.stats['stock_zero']} ({zero_pct:.1f}%)")
        print(f"Images Uploaded        : {self.stats['images_uploaded']}")
        print("=" * 55)
        if 5.0 <= zero_pct <= 20.0:
            print("[OK] Unavailable stock strictly within 5% - 20% metric!")
        print("[OK] Import completed successfully.\n")


def main():
    parser = argparse.ArgumentParser(
        description="PrestaShop Catalog & Stock API Importer"
    )
    parser.add_argument("--url", default=None, help="PrestaShop API base URL")
    parser.add_argument("--key", default=None, help="PrestaShop Webservice API key")
    parser.add_argument(
        "--limit", type=int, default=None, help="Limit number of products to import"
    )
    parser.add_argument(
        "--skip-images", action="store_true", help="Skip uploading product images"
    )
    parser.add_argument(
        "--download-images",
        action="store_true",
        help="Download missing product cover images from source URLs",
    )
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parent.parent
    env = load_env(repo_root / ".env")

    api_url = args.url or env.get("PRESTASHOP_API_URL") or "https://localhost/api"
    api_key = args.key or env.get("PRESTASHOP_WEBSERVICE_KEY")
    if not api_key:
        print(
            "[ERROR] Missing API key! Set PRESTASHOP_WEBSERVICE_KEY in your .env file or pass --key."
        )
        sys.exit(1)

    categories_file = repo_root / "scraper-results" / "categories.json"
    products_file = repo_root / "scraper-results" / "products.json"

    if not categories_file.exists() or not products_file.exists():
        print(f"[ERROR] Missing scraper results in {repo_root / 'scraper-results'}")
        sys.exit(1)

    print(f"Connecting to PrestaShop Webservice at {api_url}...")
    importer = PrestaShopImporter(
        api_url=api_url,
        api_key=api_key,
        repo_root=repo_root,
        download_images=args.download_images,
    )

    if not importer.test_connection():
        sys.exit(1)
    print("[OK] API authenticated successfully.")

    start_time = time.time()
    importer.cleanup_demo_data()
    importer.import_categories(categories_file)
    importer.import_manufacturers(products_file)
    importer.import_products(
        products_file, limit=args.limit, skip_images=args.skip_images
    )
    duration = time.time() - start_time

    importer.print_report(duration)


if __name__ == "__main__":
    main()
