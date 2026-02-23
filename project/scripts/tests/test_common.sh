#!/usr/bin/env bash

# Load the script to be tested
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

fail() {
  echo "FAIL: $1"
  return 1
}

assert_equals() {
  if [[ "$1" != "$2" ]]; then
    fail "Expected \"$2\", got \"$1\""
    return 1
  fi
}

test_log() {
  echo "Testing log()..."
  output=$(log "test message")
  # Check if output contains timestamp format and message
  if [[ ! "$output" =~ ^\[[0-9]{2}:[0-9]{2}:[0-9]{2}\]\ test\ message$ ]]; then
      fail "log output format incorrect: \"$output\""
      return 1
  fi
  echo "PASS"
}

test_err() {
  echo "Testing err()..."
  # err prints to stderr, so we redirect stderr to stdout to capture it
  output=$(err "error message" 2>&1)
  expected="[ERRO] error message"
  assert_equals "$output" "$expected" || return 1
  echo "PASS"
}

test_need_cmd_exists() {
  echo "Testing need_cmd() with existing command..."
  if ! need_cmd "ls"; then
      fail "need_cmd failed for existing command \"ls\""
      return 1
  fi
  echo "PASS"
}

test_need_cmd_missing() {
  echo "Testing need_cmd() with missing command..."
  # need_cmd exits if command is missing, so run in subshell
  output=$( (need_cmd "non_existent_command_12345") 2>&1 )
  status=$?

  if [[ $status -eq 0 ]]; then
    fail "need_cmd should fail for missing command"
    return 1
  fi

  if [[ "$output" != *"Comando não encontrado: non_existent_command_12345"* ]]; then
      fail "need_cmd error message incorrect: \"$output\""
      return 1
  fi
  echo "PASS"
}

test_run_normal() {
  echo "Testing run() normal execution..."
  captured=$(run "echo \"hello world\"")

  if [[ "$captured" != *"echo \"hello world\""* ]]; then
      fail "run output missing command log. Output: \"$captured\""
      return 1
  fi

  if [[ "$captured" != *"hello world"* ]]; then
       fail "run output missing command execution output. Output: \"$captured\""
       return 1
  fi
  echo "PASS"
}

test_run_dry_run() {
  echo "Testing run() dry-run..."
  export DRY_RUN=1
  test_file="/tmp/should_not_exist_$(date +%s)"

  captured=$(run "touch $test_file")
  unset DRY_RUN

  if [[ -f "$test_file" ]]; then
      rm "$test_file"
      fail "dry run executed command (file created)"
      return 1
  fi

  if [[ "$captured" != *"[dry-run] touch"* ]]; then
       fail "dry run log missing or incorrect. Output: \"$captured\""
       return 1
  fi
  echo "PASS"
}

# Run tests
echo "Running tests for common.sh..."
FAILED=0
test_log || FAILED=1
test_err || FAILED=1
test_need_cmd_exists || FAILED=1
test_need_cmd_missing || FAILED=1
test_run_normal || FAILED=1
test_run_dry_run || FAILED=1

if [[ $FAILED -ne 0 ]]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests passed!"
