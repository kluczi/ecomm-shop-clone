#!/usr/bin/env python3
"""
PrestaShop Disaster Recovery: Backup Script

Creates a complete, sanitized backup containing:
1. MariaDB database dump (compressed database.sql.gz).
2. Product images from PrestaShop volume (/var/www/html/img/p).
3. System configuration and metadata.

Usage:
    python deploy/backup.py [--output-dir DIR]
"""

import argparse
import gzip
import json
import shutil
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path


def load_env(env_path: Path) -> dict[str, str]:
    """Parse key-value pairs from .env file"""
    env_vars = {}
    if not env_path.exists():
        return env_vars
    with open(env_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                env_vars[k.strip()] = v.strip().strip("\"'")
    return env_vars


def main():
    parser = argparse.ArgumentParser(description="Create PrestaShop complete backup")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=None,
        help="Custom backup directory (default: deploy/backups/backup_YYYYMMDD_HHMMSS)",
    )
    args = parser.parse_args()

    start_time = time.perf_counter()
    repo_root = Path(__file__).resolve().parent.parent
    env_file = repo_root / ".env"
    env_vars = load_env(env_file)

    db_name = env_vars.get("DATABASE_NAME", "prestashop")
    db_user = env_vars.get("DATABASE_USER", "prestashop")
    db_pass = env_vars.get("DATABASE_PASSWORD", "admin")

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_base = repo_root / "deploy" / "backups"
    backup_dir = args.output_dir or (backup_base / f"backup_{timestamp}")
    backup_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 60)
    print("       PRESTASHOP BACKUP SCRIPT        ")
    print("=" * 60)
    print(f"Target Directory: {backup_dir}")

    # 1. MariaDB Database Dump
    db_dump_file = backup_dir / "database.sql.gz"
    print("\n[1/3] Dumping MariaDB database...")
    dump_cmd = [
        "docker",
        "compose",
        "--env-file",
        str(env_file),
        "-f",
        str(repo_root / "deploy" / "compose.yaml"),
        "exec",
        "-T",
        "mariadb",
        "mariadb-dump",
        f"-u{db_user}",
        f"-p{db_pass}",
        "--single-transaction",
        "--quick",
        "--default-character-set=utf8mb4",
        db_name,
    ]

    try:
        proc = subprocess.Popen(dump_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if proc.stdout is not None:
            with gzip.open(db_dump_file, "wb", compresslevel=6) as gz_out:
                shutil.copyfileobj(proc.stdout, gz_out)
        proc.wait()

        if proc.returncode != 0:
            err = proc.stderr.read().decode("utf-8", errors="replace") if proc.stderr else ""
            print(f"[ERROR] Database dump failed: {err}")
            sys.exit(1)

        db_size_mb = db_dump_file.stat().st_size / (1024 * 1024)
        print(f"  -> Database dump saved: {db_dump_file.name} ({db_size_mb:.2f} MB)")
    except (subprocess.SubprocessError, OSError) as e:
        print(f"[ERROR] Failed to dump database: {e}")
        sys.exit(1)

    # 2. Product Images Backup
    images_tar_file = backup_dir / "images.tar.gz"
    print("\n[2/3] Archiving product images from PrestaShop volume (/var/www/html/img/p)...")
    images_cmd = [
        "docker",
        "compose",
        "--env-file",
        str(env_file),
        "-f",
        str(repo_root / "deploy" / "compose.yaml"),
        "exec",
        "-T",
        "prestashop",
        "tar",
        "-czf",
        "-",
        "-C",
        "/var/www/html/img",
        "p",
    ]

    try:
        proc = subprocess.Popen(images_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if proc.stdout is not None:
            with open(images_tar_file, "wb") as f_out:
                shutil.copyfileobj(proc.stdout, f_out)
        proc.wait()

        if proc.returncode != 0:
            err = proc.stderr.read().decode("utf-8", errors="replace") if proc.stderr else ""
            print(f"[WARN] Images archive stderr: {err}")

        images_size_mb = images_tar_file.stat().st_size / (1024 * 1024)
        print(f"  -> Images archive saved: {images_tar_file.name} ({images_size_mb:.2f} MB)")
    except (subprocess.SubprocessError, OSError) as e:
        print(f"[WARN] Failed to archive container images: {e}")

    # 3. Configuration & Metadata
    print("\n[3/3] Saving configuration and metadata...")
    config_dir = backup_dir / "config"
    config_dir.mkdir(exist_ok=True)
    for sql_file in (repo_root / "deploy").glob("*.sql"):
        shutil.copy2(sql_file, config_dir / sql_file.name)
    if (repo_root / ".env.example").exists():
        shutil.copy2(repo_root / ".env.example", config_dir / ".env.example")

    # Count products in database
    count_cmd = [
        "docker",
        "compose",
        "--env-file",
        str(env_file),
        "-f",
        str(repo_root / "deploy" / "compose.yaml"),
        "exec",
        "-T",
        "mariadb",
        "mariadb",
        f"-u{db_user}",
        f"-p{db_pass}",
        "-s",
        "-N",
        "-e",
        "SELECT count(*) FROM ps_product;",
        db_name,
    ]
    prod_count_res = subprocess.run(count_cmd, capture_output=True, text=True, check=False)
    product_count = prod_count_res.stdout.strip() if prod_count_res.returncode == 0 else "N/A"

    duration = time.perf_counter() - start_time
    total_size_mb = (
        sum(f.stat().st_size for f in backup_dir.rglob("*") if f.is_file()) / (1024 * 1024)
    )

    metadata = {
        "timestamp": timestamp,
        "database": db_name,
        "product_count": product_count,
        "duration_seconds": round(duration, 2),
        "total_size_mb": round(total_size_mb, 2),
    }

    with open(backup_dir / "metadata.json", "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)

    try:
        display_backup_dir = backup_dir.relative_to(repo_root)
    except ValueError:
        display_backup_dir = backup_dir

    print("\n" + "=" * 60)
    print("         BACKUP COMPLETED        ")
    print("=" * 60)
    print(f"Backup Location      : {display_backup_dir}")
    print(f"Total Products       : {product_count}")
    print(f"Backup Archive Size  : {total_size_mb:.2f} MB")
    print(f"Execution Time       : {duration:.2f} s")
    print("=" * 60)
    print("[OK] Backup created successfully.")


if __name__ == "__main__":
    main()
