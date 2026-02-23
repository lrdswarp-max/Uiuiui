#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Uso: $0 <google_drive_file_id> [arquivo_saida]" >&2
  exit 1
fi

FILE_ID="$1"
OUT_FILE="${2:-downloaded_from_drive.bin}"
URL="https://drive.google.com/uc?export=download&id=${FILE_ID}"

echo "Baixando de: ${URL}"
curl -fL "$URL" -o "$OUT_FILE"

BYTES=$(wc -c < "$OUT_FILE" | tr -d ' ')
echo "Download concluído: $OUT_FILE (${BYTES} bytes)"
