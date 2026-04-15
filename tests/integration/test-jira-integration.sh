#!/usr/bin/env bash
# Test: Jira integration (live API)
# Requires Atlassian auth (acli or env vars)
# Captures stream-json to verify which tools Claude uses
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"
cd "$(cd "$SCRIPT_DIR/../.." && pwd)"

LOG_DIR=$(mktemp -d)
trap "rm -rf $LOG_DIR" EXIT

echo "=== Test: Jira integration (live API) ==="

# Skip if no auth available
if ! check_any_auth; then
    echo "  [SKIP] No Atlassian auth configured (run 'acli auth login' or set env vars)"
    exit 0
fi

# Test 1: Search issues
echo ""
echo "Test 1: Search Jira issues"
output=$(run_claude_logged "Search Jira for my issues using JQL 'order by created DESC' and show the first 3 results." "$LOG_DIR/search.json" 120)
assert_contains "$output" "TC|issue|key|result" "Search returned results" || true
show_tools_used "$LOG_DIR/search.json"

# Test 2: Create a test issue
echo ""
echo "Test 2: Create a test issue"
TIMESTAMP=$(date +%s)
output=$(run_claude_logged "Create a Jira task in project TC with summary 'Integration test $TIMESTAMP' and description 'Automated test'. Tell me the issue key." "$LOG_DIR/create.json" 180)
assert_contains "$output" "[A-Z]+-[0-9]+" "Returns an issue key" || true
show_tools_used "$LOG_DIR/create.json"

# Extract issue key
ISSUE_KEY=$(echo "$output" | sed 's/\*\*//g; s/`//g' | grep -oE '[A-Z]+-[0-9]+' | head -1 || true)

if [ -n "$ISSUE_KEY" ]; then
    echo "  Created: $ISSUE_KEY"

    # Test 3: View the issue
    echo ""
    echo "Test 3: View the created issue"
    output=$(run_claude_logged "Show me Jira issue $ISSUE_KEY." "$LOG_DIR/view.json" 120)
    assert_contains "$output" "$ISSUE_KEY" "Shows the issue" || true
    show_tools_used "$LOG_DIR/view.json"

    # Test 4: Add a comment
    echo ""
    echo "Test 4: Add a comment"
    output=$(run_claude_logged "Add a comment to $ISSUE_KEY saying 'Automated test comment'." "$LOG_DIR/comment.json" 120)
    assert_not_contains "$output" "unauthorized|403|401" "Comment added without auth errors" || true
    show_tools_used "$LOG_DIR/comment.json"

    # Test 5: Transition
    echo ""
    echo "Test 5: Transition the issue"
    output=$(run_claude_logged "Move $ISSUE_KEY to Done." "$LOG_DIR/transition.json" 120)
    assert_not_contains "$output" "unauthorized|403|401" "Transition without auth errors" || true
    show_tools_used "$LOG_DIR/transition.json"
else
    echo "  [SKIP] Could not extract issue key from create output"
fi

echo ""
echo "=== Jira integration tests complete ==="
