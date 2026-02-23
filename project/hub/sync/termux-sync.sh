#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:-$HOME/projects}"
TARGET_DIR="${2:-$HOME/ubuntu-projects}"

mkdir -p "$SOURCE_DIR" "$TARGET_DIR"
rsync -av --delete "$SOURCE_DIR/" "$TARGET_DIR/"
echo "Sync concluído: $SOURCE_DIR -> $TARGET_DIR"
