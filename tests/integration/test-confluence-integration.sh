#!/usr/bin/env bash
# Test: Confluence integration (live API)
# Requires Atlassian auth (acli or env vars)
# Captures stream-json to verify which tools Claude uses
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"
cd "$(cd "$SCRIPT_DIR/../.." && pwd)"

LOG_DIR=$(mktemp -d)
trap "rm -rf $LOG_DIR" EXIT

echo "=== Test: Confluence integration (live API) ==="

# Skip if no auth available
if ! check_any_auth; then
    echo "  [SKIP] No Atlassian auth configured (run 'acli auth login' or set env vars)"
    exit 0
fi

# Test 1: List spaces
echo ""
echo "Test 1: List Confluence spaces"
output=$(run_claude_logged "List all Confluence spaces." "$LOG_DIR/spaces.json" 120)
assert_contains "$output" "TWC|space|key" "Lists spaces" || true
show_tools_used "$LOG_DIR/spaces.json"

# Test 2: Create a test page
echo ""
echo "Test 2: Create a test page"
TIMESTAMP=$(date +%s)
output=$(run_claude_logged "Create a Confluence page titled 'Integration Test Page $TIMESTAMP' in the TWC space (space ID 98307) with body '<p>Automated test page. Safe to delete.</p>'. Tell me the page ID." "$LOG_DIR/create.json" 180)
assert_not_contains "$output" "unauthorized|403|401" "Page created without auth errors" || true
show_tools_used "$LOG_DIR/create.json"

# Extract page ID
PAGE_ID=$(echo "$output" | sed 's/\*\*//g; s/`//g' | grep -oE '[0-9]{4,}' | head -1 || true)

if [ -n "$PAGE_ID" ]; then
    echo "  Created page ID: $PAGE_ID"

    # Test 3: Read the page back
    echo ""
    echo "Test 3: Read the created page"
    output=$(run_claude_logged "Get Confluence page with ID $PAGE_ID." "$LOG_DIR/read.json" 120)
    assert_contains "$output" "test|Integration Test Page|automated" "Shows page content" || true
    show_tools_used "$LOG_DIR/read.json"

    # Test 4: Search for the page
    echo ""
    echo "Test 4: Search for the page"
    output=$(run_claude_logged "Search Confluence for pages titled 'Integration Test Page $TIMESTAMP'." "$LOG_DIR/search.json" 120)
    assert_contains "$output" "Integration Test Page" "Found the page via search" || true
    show_tools_used "$LOG_DIR/search.json"
else
    echo "  [SKIP] Could not extract page ID from create output"
fi

echo ""
echo "=== Confluence integration tests complete ==="
