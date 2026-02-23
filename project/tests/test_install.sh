#!/usr/bin/env bash
set -euo pipefail

# Tests for install.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SCRIPT="$ROOT_DIR/scripts/install.sh"
TEMP_DIR="$(mktemp -d)"

log() { echo "Test: $*"; }

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Test 1: Help message
log "Checking help message..."
if "$INSTALL_SCRIPT" --help | grep -q "Uso:"; then
  echo "PASS: Help message found"
else
  echo "FAIL: Help message missing"
  false
fi

# Test 2: Dry Run
log "Checking dry run..."
# Run in subshell to capture output
if OUTPUT="$("$INSTALL_SCRIPT" --dry-run --target-home "$TEMP_DIR/home" --non-interactive 2>&1)"; then
  if echo "$OUTPUT" | grep -q "Instalação concluída com sucesso"; then
    echo "PASS: Dry run completed successfully"
  else
    echo "FAIL: Dry run failed to complete successfully"
    echo "Output: $OUTPUT"
    false
  fi
else
  echo "FAIL: Dry run execution failed"
  echo "Output: $OUTPUT"
  false
fi

# Test 3: Check generated structure in dry-run
log "Verifying no files created in dry run..."
if [ -d "$TEMP_DIR/home/.termux" ]; then
    echo "FAIL: Directory created in dry run: $TEMP_DIR/home/.termux"
    ls -R "$TEMP_DIR/home/.termux"
    false
else
    echo "PASS: No directory created in dry run"
fi

echo "All tests passed!"
