#!/usr/bin/env bash
set -euo pipefail

# Load the script to be tested
COMMON_SCRIPT="$(dirname "$0")/../common.sh"
if [[ ! -f "$COMMON_SCRIPT" ]]; then
    echo "Error: common.sh not found at $COMMON_SCRIPT"
    exit 1
fi
source "$COMMON_SCRIPT"

# Helper for assertions
assert_contains() {
    local output="$1"
    local expected="$2"
    if [[ "$output" != *"$expected"* ]]; then
        echo "FAIL: Output '$output' does not contain '$expected'"
        exit 1
    fi
}

assert_equals() {
    local actual="$1"
    local expected="$2"
    if [[ "$actual" != "$expected" ]]; then
        echo "FAIL: Expected '$expected', got '$actual'"
        exit 1
    fi
}

test_log() {
    local msg="test log message"
    local output
    output=$(log "$msg")
    # Verify timestamp format [HH:MM:SS]
    if [[ ! "$output" =~ ^\[[0-9]{2}:[0-9]{2}:[0-9]{2}\]\ test\ log\ message$ ]]; then
        echo "FAIL: log output format incorrect: '$output'"
        exit 1
    fi
    echo "PASS: test_log"
}

test_err() {
    local msg="test error message"
    local output
    # Capture stderr
    output=$(err "$msg" 2>&1)
    assert_equals "$output" "[ERRO] test error message"
    echo "PASS: test_err"
}

test_need_cmd_exists() {
    if ! need_cmd "ls"; then
        echo "FAIL: need_cmd failed for existing command 'ls'"
        exit 1
    fi
    echo "PASS: test_need_cmd_exists"
}

test_need_cmd_missing() {
    local output
    # checking failure: run in subshell to avoid exiting main script?
    # common.sh need_cmd calls exit 1.
    if ( need_cmd "non_existent_command_12345" 2>/dev/null ); then
        echo "FAIL: need_cmd should fail (exit) for missing command"
        exit 1
    else
        # It failed as expected.
        # Verify error message. output capture needs subshell too.
        output=$( (need_cmd "non_existent_command_12345") 2>&1 || true )
        assert_contains "$output" "Comando não encontrado: non_existent_command_12345"
    fi
    echo "PASS: test_need_cmd_missing"
}

test_run_normal() {
    local output
    output=$(run "echo run_test_output")
    assert_contains "$output" "run_test_output"
    # Also verify log message was printed
    if [[ ! "$output" =~ \[.*\]\ echo\ run_test_output ]]; then
        echo "FAIL: run did not log command: $output"
        exit 1
    fi
    echo "PASS: test_run_normal"
}

test_run_dry_run() {
    export DRY_RUN=1
    local test_file="/tmp/test_common_dry_run_$(date +%s)"
    local output

    # Try to create a file
    output=$(run "touch $test_file")

    # Verify file was NOT created
    if [[ -f "$test_file" ]]; then
        rm "$test_file"
        echo "FAIL: dry run executed command (file created)"
        unset DRY_RUN
        exit 1
    fi

    # Verify log output contains [dry-run]
    assert_contains "$output" "[dry-run] touch $test_file"

    unset DRY_RUN
    echo "PASS: test_run_dry_run"
}

echo "Running tests for common.sh..."
test_log
test_err
test_need_cmd_exists
test_need_cmd_missing
test_run_normal
test_run_dry_run
echo "All tests passed!"
