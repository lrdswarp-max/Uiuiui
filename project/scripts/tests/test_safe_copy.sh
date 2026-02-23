#!/bin/bash

# Test script for safe_copy function in project/scripts/install.sh

# Mock dependencies
STATE_DIR="/tmp/test_state_dir"
mkdir -p "$STATE_DIR"

err() {
  echo "ERROR: $*" >&2
}

run() {
  echo "RUN: $*"
}

record_action() {
  echo "RECORD: $*"
}

# Extract safe_copy function from install.sh
# We use sed to extract the function definition.
# It assumes the function starts with "safe_copy() {" and ends with "}"
# This is a bit fragile but avoids sourcing the whole script which executes code.
# The previous attempt failed because of 'exit' in the script content.
# This sed command extracts lines from 'safe_copy() {' to the matching '}'
sed -n '/^safe_copy() {/,/^}/p' project/scripts/install.sh > project/scripts/tests/safe_copy_extracted.sh
source project/scripts/tests/safe_copy_extracted.sh

# Test Case: Source file missing
test_safe_copy_missing_source() {
  local step="test_step"
  local src="non_existent_file"
  local dest="dest_path"

  echo "Testing safe_copy with missing source file..."

  # Capture output and exit code
  # We use a subshell to capture stderr and stdout
  if output=$(safe_copy "$step" "$src" "$dest" 2>&1); then
     local exit_code=0
  else
     local exit_code=$?
  fi

  # Assertions
  if [[ "$exit_code" -ne 1 ]]; then
    echo "FAIL: Expected exit code 1, got $exit_code"
    return 1
  fi

  if [[ "$output" != *"Arquivo fonte não encontrado: $src"* ]]; then
    echo "FAIL: Expected error message containing 'Arquivo fonte não encontrado: $src'"
    echo "Got: $output"
    return 1
  fi

  echo "PASS: safe_copy handled missing source file correctly."
  return 0
}

# Run tests
test_safe_copy_missing_source
result=$?

# Cleanup
rm -f project/scripts/tests/safe_copy_extracted.sh
rm -rf "$STATE_DIR"

if [ $result -ne 0 ]; then
    echo "Tests failed"
    false
else
    echo "Tests passed"
    true
fi
