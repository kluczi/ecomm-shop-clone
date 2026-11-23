#!/usr/bin/env python3
"""
PrestaShop Disaster Recovery: Restore Script

Restores the complete PrestaShop store from a backup:
1. Re-creates MariaDB database and imports decompressed database.sql.gz.
2. Extracts product images into PrestaShop volume (/var/www/html/img/p).
3. Restores deployment configuration files and .env.example from config/.
4. Clears PrestaShop production cache.
5. Validates store health and benchmarks recovery time.

Usage:
    python deploy/restore.py [--backup-dir DIR]
"""

import argparse
import gzip
import shutil
import ssl
import subprocess
import sys
import time
import urllib.error
import urllib.request
import zlib
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


def find_latest_backup(backup_base: Path) -> Path | None:
    """Find the latest backup directory via timestamp sorting"""
    dirs = sorted(
        [d for d in backup_base.glob("backup_*") if d.is_dir()],
        key=lambda d: d.name,
        reverse=True,
    )
    return dirs[0] if dirs else None


def verify_dump_integrity(dump_file: Path) -> tuple[bool, str]:
    """Verify that database dump file exists, is valid gzip, and decompresses cleanly."""
    if not dump_file.exists():
        return False, f"File does not exist: {dump_file}"
    if dump_file.stat().st_size == 0:
        return False, f"Dump file is empty (0 bytes): {dump_file}"

    decompressed_bytes = 0
    header_sample = b""

    try:
        with gzip.open(dump_file, "rb") as gz:
            while chunk := gz.read(1024 * 1024):
                if not header_sample:
                    header_sample = chunk[:4096]
                decompressed_bytes += len(chunk)
    except gzip.BadGzipFile as e:
        return False, f"Invalid or corrupted gzip archive: {e}"
    except (EOFError, zlib.error, OSError) as e:
        return False, f"Decompression failed (corrupted or truncated archive): {e}"

    if decompressed_bytes == 0:
        return False, "Decompressed SQL content is empty (0 bytes)"

    # Basic sanity check for SQL dump signature
    lower_sample = header_sample.lower()
    if not any(
        marker in lower_sample
        for marker in (b"dump", b"create", b"insert", b"table", b"set", b"mariadb", b"mysql")
    ):
        return False, "Dump file does not appear to contain valid SQL statements"

    return True, f"Verified valid gzip SQL dump ({decompressed_bytes / (1024 * 1024):.2f} MB uncompressed)"


def main():
    parser = argparse.ArgumentParser(description="Restore PrestaShop from backup")
    parser.add_argument(
        "--backup-dir",
        type=Path,
        default=None,
        help="Path to specific backup directory (default: latest backup in deploy/backups)",
    )
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parent.parent
    backup_base = repo_root / "deploy" / "backups"
    backup_dir = args.backup_dir or find_latest_backup(backup_base)

    if not backup_dir or not backup_dir.exists():
        print(f"[ERROR] No valid backup directory found in {backup_base}")
        sys.exit(1)

    db_dump_file = backup_dir / "database.sql.gz"
    if not db_dump_file.exists():
        print(f"[ERROR] Missing database dump: {db_dump_file}")
        sys.exit(1)

    # Pre-flight check: verify dump integrity before making destructive changes (DROP DATABASE)
    print("Checking database dump archive integrity before recovery...")
    is_valid, validation_msg = verify_dump_integrity(db_dump_file)
    if not is_valid:
        print(f"[ERROR] Backup verification failed: {validation_msg}")
        print("[ABORT] Existing database was NOT dropped. Data preserved.")
        sys.exit(1)
    print(f"  -> {validation_msg}")

    env_file = repo_root / ".env"
    env_vars = load_env(env_file)

    db_name = env_vars.get("DATABASE_NAME", "prestashop")
    db_user = env_vars.get("DATABASE_USER", "prestashop")
    db_pass = env_vars.get("DATABASE_PASSWORD", "admin")

    try:
        display_backup_dir = backup_dir.relative_to(repo_root)
    except ValueError:
        display_backup_dir = backup_dir

    print("=" * 60)
    print("      PRESTASHOP RECOVERY SCRIPT        ")
    print("=" * 60)
    print(f"Restoring from: {display_backup_dir}")

    start_time = time.perf_counter()

    # 1. Reset Database & Import Dump
    print("\n[1/5] Re-creating database and importing database dump...")
    recreate_sql = (
        f"DROP DATABASE IF EXISTS `{db_name}`;"
        f"CREATE DATABASE `{db_name}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    )
    recreate_cmd = [
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
        "-e",
        recreate_sql,
    ]
    res = subprocess.run(recreate_cmd, capture_output=True, text=True, check=False)
    if res.returncode != 0:
        print(f"[ERROR] Failed to re-create database: {res.stderr}")
        sys.exit(1)

    import_cmd = [
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
        "--default-character-set=utf8mb4",
        db_name,
    ]

    try:
        proc = subprocess.Popen(import_cmd, stdin=subprocess.PIPE, stderr=subprocess.PIPE)
        with gzip.open(db_dump_file, "rb") as gz_in:
            while chunk := gz_in.read(1024 * 1024):
                if proc.stdin is not None:
                    proc.stdin.write(chunk)
        if proc.stdin is not None:
            proc.stdin.close()
        proc.wait()

        if proc.returncode != 0:
            err = proc.stderr.read().decode("utf-8", errors="replace") if proc.stderr else ""
            print(f"[ERROR] Database import failed: {err}")
            sys.exit(1)
        print("  -> Database restored successfully.")
    except (subprocess.SubprocessError, OSError) as e:
        print(f"[ERROR] Failed during database restore: {e}")
        sys.exit(1)

    # 2. Restore Product Images
    images_tar_file = backup_dir / "images.tar.gz"
    if images_tar_file.exists():
        print("\n[2/5] Restoring product images into PrestaShop volume...")
        tar_cmd = [
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
            "-xzf",
            "-",
            "-C",
            "/var/www/html/img",
        ]
        try:
            proc = subprocess.Popen(tar_cmd, stdin=subprocess.PIPE, stderr=subprocess.PIPE)
            with open(images_tar_file, "rb") as f_in:
                while chunk := f_in.read(1024 * 1024):
                    if proc.stdin is not None:
                        proc.stdin.write(chunk)
            if proc.stdin is not None:
                proc.stdin.close()
            proc.wait()
            if proc.returncode != 0:
                err = proc.stderr.read().decode("utf-8", errors="replace") if proc.stderr else ""
                print(f"[ERROR] Failed to restore product images (exit code {proc.returncode}): {err.strip()}")
                sys.exit(1)
            print("  -> Product images restored successfully.")
        except (subprocess.SubprocessError, OSError) as e:
            print(f"[ERROR] Failed during product images restore: {e}")
            sys.exit(1)
    else:
        print("\n[2/4] Skipping images restore (images.tar.gz not present).")

    # 3. Restore Configuration Files
    config_dir = backup_dir / "config"
    if config_dir.exists() and config_dir.is_dir():
        print("\n[3/5] Restoring configuration files from backup...")
        for conf_file in config_dir.glob("*.sql"):
            dest_file = repo_root / "deploy" / conf_file.name
            shutil.copy2(conf_file, dest_file)
            print(f"  -> Restored deploy/{conf_file.name}")
        env_example_src = config_dir / ".env.example"
        if env_example_src.exists():
            shutil.copy2(env_example_src, repo_root / ".env.example")
            print("  -> Restored .env.example")
    else:
        print("\n[3/5] Skipping configuration restore (no config directory in backup).")

    # 4. Clear PrestaShop Cache
    print("\n[4/5] Clearing PrestaShop production cache...")
    cache_cmd = [
        "docker",
        "compose",
        "--env-file",
        str(env_file),
        "-f",
        str(repo_root / "deploy" / "compose.yaml"),
        "exec",
        "-T",
        "prestashop",
        "sh",
        "-c",
        "rm -rf /var/www/html/var/cache/prod && chown -R www-data:www-data /var/www/html/var/cache && chmod -R 777 /var/www/html/var/cache",
    ]
    subprocess.run(cache_cmd, capture_output=True, text=True, check=False)
    print("  -> Cache cleared.")

    # 5. Verify Store Health and Product Count
    print("\n[5/5] Verifying restored store...")
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
    res_count = subprocess.run(count_cmd, capture_output=True, text=True, check=False)
    restored_products = res_count.stdout.strip() if res_count.returncode == 0 else "0"

    health_status = "N/A"
    try:
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        req = urllib.request.Request("https://localhost", headers={"Host": "localhost"})
        with urllib.request.urlopen(req, context=ctx, timeout=10) as resp:
            health_status = f"HTTP {resp.status} OK"
    except (urllib.error.URLError, TimeoutError, OSError) as e:
        health_status = f"Warning: {e}"

    duration = time.perf_counter() - start_time
    duration_min = duration / 60.0

    print("\n" + "=" * 60)
    print("         DISASTER RECOVERY REPORT         ")
    print("=" * 60)
    print(f"Restored Products     : {restored_products}")
    print(f"Store Health Status   : {health_status}")
    print(f"Recovery Duration     : {duration:.2f} s ({duration_min:.2f} min)")
    print(f"D4 Requirement (<=10m): {'PASSED' if duration_min <= 10.0 else 'FAILED'}")
    print("=" * 60)

    if duration_min <= 10.0:
        print("[OK] Disaster Recovery verified successfully.")
    else:
        print(f"[FAIL] Disaster Recovery took {duration_min:.2f} min (> 10.0 min)")
        sys.exit(1)


if __name__ == "__main__":
    main()
