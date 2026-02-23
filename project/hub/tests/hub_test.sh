#!/usr/bin/env bash
set -euo pipefail

# Setup
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
export HUB_DB="$TEST_DIR/test_hub.db"
HUB_SH="./project/hub/hub.sh"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper Functions
assert_contains() {
    local output="$1"
    local expected="$2"
    local message="$3"
    if [[ "$output" == *"$expected"* ]]; then
        echo -e "${GREEN}PASS:${NC} $message"
    else
        echo -e "${RED}FAIL:${NC} $message"
        echo "  Expected to contain: $expected"
        echo "  Actual output: $output"
        exit 1
    fi
}

assert_success() {
    local message="$1"
    shift
    if "$@"; then
        echo -e "${GREEN}PASS:${NC} $message"
    else
        echo -e "${RED}FAIL:${NC} $message"
        exit 1
    fi
}

assert_failure() {
    local message="$1"
    shift
    if ! "$@"; then
        echo -e "${GREEN}PASS:${NC} $message"
    else
        echo -e "${RED}FAIL:${NC} $message (expected failure)"
        exit 1
    fi
}

echo "Running Hub Tests..."

# 3. Test database initialization
echo "--- Testing Database Initialization ---"
output=$(bash "$HUB_SH" list)
assert_contains "$output" "git" "Initial data contains 'git' category"
assert_contains "$output" "npm" "Initial data contains 'npm' category"

# 4. Test 'add' command
echo "--- Testing 'add' Command ---"
assert_success "Add new skill with all arguments" bash "$HUB_SH" add "test-cmd" "test-cat" "test-desc"
output=$(bash "$HUB_SH" ask "test-cmd")
assert_contains "$output" "test-desc" "Added skill correctly stored description"

assert_success "Add new skill with default values" bash "$HUB_SH" add "default-cmd"
output=$(bash "$HUB_SH" ask "default-cmd")
assert_contains "$output" "default-cmd" "Default description is the command name"

assert_failure "Fail when name is missing" bash "$HUB_SH" add

# 5. Test query commands ('ask', 'search', 'list')
echo "--- Testing Query Commands ---"
output=$(bash "$HUB_SH" ask "git clone")
assert_contains "$output" "Clone um repositório" "hub ask returns info for initial skills"

output=$(bash "$HUB_SH" search "Instalar")
assert_contains "$output" "npm install" "hub search finds skill by description"

output=$(bash "$HUB_SH" list)
assert_contains "$output" "git" "hub list contains 'git' category"
assert_contains "$output" "test-cat" "hub list contains 'test-cat' category"

# 6. Test special character handling
echo "--- Testing Special Character Handling ---"
assert_success "Add skill with single quote" bash "$HUB_SH" add "quote'cmd" "cat'1" "desc'1"
output=$(bash "$HUB_SH" ask "quote'cmd")
assert_contains "$output" "desc'1" "Handles single quotes correctly"

echo -e "\n${GREEN}All tests passed!${NC}"
