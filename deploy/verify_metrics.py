#!/usr/bin/env python3
"""
Automated Verification of Requirements Metrics (Etap 1: W2, W3, D2)
Queries MariaDB directly inside the container and prints a formatted audit table.
"""

import io
import subprocess
import sys

# Fix Windows console encoding for UTF-8 box-drawing characters
if sys.platform == "win32" and isinstance(sys.stdout, io.TextIOWrapper):
    sys.stdout.reconfigure(encoding="utf-8")


def run_sql(query: str) -> str:
    """Execute SQL query inside shop-mariadb container via stdin"""
    docker_cmd = [
        "docker",
        "exec",
        "-i",
        "shop-mariadb",
        "sh",
        "-c",
        'mariadb -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" -N -B',
    ]
    try:
        proc = subprocess.run(
            docker_cmd,
            input=query.encode("utf-8"),
            capture_output=True,
            check=True,
        )
        return proc.stdout.decode("utf-8").strip()
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] SQL Query Failed: {e.stderr.decode('utf-8', errors='ignore')}", file=sys.stderr)
        return ""


def main():
    print("\n" + "=" * 78)
    print("      WERYFIKACJA METRYK PROJEKTOWYCH      ")
    print("=" * 78)
    print(f"{'Wymaganie':<11} | {'Metryka':<28} | {'Próg':<12} | {'Wynik w sklepie':<16} | Status")
    print("-" * 78)

    all_passed = True

    def check(req: str, metric: str, threshold: str, val_str: str, passed: bool):
        nonlocal all_passed
        status_str = "[PASS]" if passed else "[FAIL]"
        if not passed:
            all_passed = False
        print(f"{req:<11} | {metric:<28} | {threshold:<12} | {val_str:<16} | {status_str}")

    # 1. Liczba produktów (W3)
    prod_count_raw = run_sql("SELECT COUNT(*) FROM ps_product;")
    prod_count = int(prod_count_raw) if prod_count_raw.isdigit() else 0
    check("W3", "Liczba produktów", ">= 1000", f"{prod_count} szt.", prod_count >= 1000)

    # 2. Produkty niedostępne (W3) & Max stan (W3)
    stock_raw = run_sql(
        "SELECT SUM(quantity = 0), COUNT(*), ROUND(AVG(quantity = 0)*100, 1), MAX(quantity) "
        "FROM ps_stock_available WHERE id_product_attribute = 0;"
    )
    if stock_raw and "\t" in stock_raw:
        parts = stock_raw.split("\t")
        zero_pct = float(parts[2])
        max_qty = int(parts[3])
    else:
        zero_pct = 0.0
        max_qty = 999

    check("W3", "Produkty niedostępne (stan 0)", "5% - 20%", f"{zero_pct}%", 5.0 <= zero_pct <= 20.0)
    check("W3", "Maksymalny stan magazynowy", "<= 10 szt.", f"{max_qty} szt.", max_qty <= 10)

    # 3. Kategorie i podkategorie (W3)
    cat_raw = run_sql(
        "SELECT COUNT(*) FROM ("
        "  SELECT c.id_category FROM ps_category c "
        "  JOIN ps_category sub ON sub.id_parent = c.id_category "
        "  WHERE c.id_parent = 2 GROUP BY c.id_category HAVING COUNT(sub.id_category) >= 2"
        ") AS cats;"
    )
    cat_cnt = int(cat_raw) if cat_raw.isdigit() else 0
    check("W3", "Kategorie główne (>=2 podk.)", ">= 4", f"{cat_cnt} kat.", cat_cnt >= 4)

    # 4. Zdjęcia (W2, W3)
    img_multi_raw = run_sql(
        "SELECT COUNT(*) FROM ("
        "  SELECT id_product FROM ps_image GROUP BY id_product HAVING COUNT(*) >= 2"
        ") AS multi;"
    )
    img_multi_cnt = int(img_multi_raw) if img_multi_raw.isdigit() else 0
    check("W2, W3", "Produkty z >= 2 zdjęciami", ">= 50", f"{img_multi_cnt} prod.", img_multi_cnt >= 50)

    # 5. Metody płatności (W3)
    pay_raw = run_sql(
        "SELECT COUNT(DISTINCT m.name) FROM ps_module m "
        "JOIN ps_module_carrier mc ON m.id_module = mc.id_module "
        "WHERE m.name IN ('ps_wirepayment', 'ps_cashondelivery') AND m.active = 1;"
    )
    pay_cnt = int(pay_raw) if pay_raw.isdigit() else 0
    check("W3", "Metody płatności", "2 aktywne", f"{pay_cnt} aktywne", pay_cnt == 2)

    # 6. Przewoźnicy (W3)
    carr_raw = run_sql(
        "SELECT COUNT(*) FROM ps_carrier "
        "WHERE (name LIKE '%DPD%' OR name LIKE '%InPost%') AND active = 1 AND deleted = 0;"
    )
    carr_cnt = int(carr_raw) if carr_raw.isdigit() else 0
    check("W3", "Przewoźnicy (DPD, InPost)", "2 aktywnych", f"{carr_cnt} aktywnych", carr_cnt >= 2)

    print("=" * 78)
    if all_passed:
        print("[SUKCES] Wszystkie weryfikowane metryki spełniają wymagania projektowe!\n")
        return 0
    else:
        print("[UWAGA] Niektóre metryki nie spełniają progów projektowych!\n")
        return 1


if __name__ == "__main__":
    sys.exit(main())
