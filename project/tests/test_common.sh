#!/usr/bin/env bash

# Source the file to be tested
COMMON_SH_PATH="$(dirname "$0")/../scripts/common.sh"
if [ ! -f "$COMMON_SH_PATH" ]; then
    echo "Error: common.sh not found at $COMMON_SH_PATH"
    exit 1
fi
source "$COMMON_SH_PATH"

TESTS_PASSED=0
TESTS_FAILED=0

pass() {
    echo "✅ PASS: $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo "❌ FAIL: $1"
    echo "  Expected: $2"
    echo "  Actual:   $3"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# --- Test 1: Normal Execution ---
echo "--- Test 1: Normal Execution ---"
unset DRY_RUN
OUTPUT_FILE=$(mktemp)
run echo "hello world" > "$OUTPUT_FILE" 2>&1
if grep -q "hello world" "$OUTPUT_FILE"; then
    pass "Normal execution output contains hello world"
else
    fail "Normal execution output missing hello world" "hello world" "$(cat "$OUTPUT_FILE")"
fi
rm -f "$OUTPUT_FILE"

# --- Test 2: Dry Run Execution ---
echo "--- Test 2: Dry Run Execution ---"
export DRY_RUN=1
TEST_FILE="/tmp/test_dry_run_file"
rm -f "$TEST_FILE"
OUTPUT_FILE=$(mktemp)
run touch "$TEST_FILE" > "$OUTPUT_FILE" 2>&1
if [ ! -f "$TEST_FILE" ]; then
    pass "File not created during dry run"
else
    fail "File created during dry run" "File not to exist" "File exists"
    rm -f "$TEST_FILE"
fi
if grep -q "\[dry-run\] touch $TEST_FILE" "$OUTPUT_FILE"; then
    pass "Dry run log found"
else
    fail "Dry run log missing" "\[dry-run\] touch $TEST_FILE" "$(cat "$OUTPUT_FILE")"
fi
rm -f "$OUTPUT_FILE"
unset DRY_RUN

# --- Test 3: Error Handling ---
echo "--- Test 3: Error Handling ---"
set +e
run false
EXIT_CODE=$?
set -e
if [ "$EXIT_CODE" -ne 0 ]; then
    pass "run false returns non-zero exit code ($EXIT_CODE)"
else
    fail "run false should return non-zero exit code" "non-zero" "$EXIT_CODE"
fi

# Summary
echo "--- Summary ---"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

if [ "$TESTS_FAILED" -gt 0 ]; then
    exit 1
else
    exit 0
fi
