#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

if command -v python3 >/dev/null 2>&1; then
  exec python3 "$SCRIPT_DIR/restore.py" "$@"
else
  exec python "$SCRIPT_DIR/restore.py" "$@"
fi
