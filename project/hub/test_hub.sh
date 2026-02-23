#!/usr/bin/env bash
set -euo pipefail

# Use a test database
export HUB_DB="test_hub.db"
rm -f "$HUB_DB"

# Source the hub script or run it as a command
HUB_SCRIPT="./project/hub/hub.sh"

echo "Testing 'add' command..."
$HUB_SCRIPT add "test-skill" "test-cat" "test-desc"

echo "Testing 'list' command..."
$HUB_SCRIPT list | grep -q "test-cat"

echo "Testing 'search' command..."
$HUB_SCRIPT search "test-skill" | grep -q "test-desc"

echo "Testing 'ask' command..."
$HUB_SCRIPT ask "test-skill" | grep -q "test-desc"

echo "Testing default command..."
$HUB_SCRIPT | grep -q "Hub MCP"

echo "Verifying index exists..."
sqlite3 "$HUB_DB" ".indices skills" | grep -q "idx_skills_category"

echo "Functional tests passed!"
rm -f "$HUB_DB"
