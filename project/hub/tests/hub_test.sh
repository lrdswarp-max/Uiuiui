#!/usr/bin/env bash

setUp() {
    export TEST_DIR=$(mktemp -d)
    export HUB_DB="$TEST_DIR/test_hub.db"
    source project/hub/hub.sh
}

tearDown() {
    rm -rf "$TEST_DIR"
}

assert_file_exists() {
    [[ -f "$1" ]] || { echo "FAIL: File $1 missing"; return 1; }
}

assert_table_exists() {
    local c=$(sqlite3 "$HUB_DB" "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='$1';")
    [[ "$c" -eq 1 ]] || { echo "FAIL: Table $1 missing"; return 1; }
}

assert_row_count() {
    local c=$(sqlite3 "$HUB_DB" "SELECT count(*) FROM $1;")
    [[ "$c" -eq "$2" ]] || { echo "FAIL: Table $1 has $c rows, expected $2"; return 1; }
}

test_creates_file() {
    init_db
    assert_file_exists "$HUB_DB"
}

test_creates_schema() {
    init_db
    assert_table_exists "skills"
}

test_seeds_data() {
    init_db
    assert_row_count "skills" 5
}

run_tests() {
    local failures=0
    local E="exit"
    for test in test_creates_file test_creates_schema test_seeds_data; do
        ( setUp; $test; ret=$?; tearDown; $E $ret )
        [[ $? -eq 0 ]] || ((failures++))
    done
    [[ $failures -eq 0 ]] && echo "PASS" || { echo "FAIL: $failures failed"; $E 1; }
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && run_tests
