#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

python3 "$SCRIPT_DIR/backup.py" "$@" 2>/dev/null || python "$SCRIPT_DIR/backup.py" "$@"
