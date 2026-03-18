#!/usr/bin/env bash
# Test: Gmail integration (live API)
# Requires gws auth (gws auth login -s gmail)
# Captures stream-json to verify which tools Claude uses
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"
cd "$(cd "$SCRIPT_DIR/../.." && pwd)"

LOG_DIR=$(mktemp -d)
trap "rm -rf $LOG_DIR" EXIT

echo "=== Test: Gmail integration (live API) ==="

# Skip if no gws auth available
if ! check_gws_auth; then
    echo "  [SKIP] No gws auth configured (run 'gws auth login -s gmail')"
    exit 0
fi

# Test 1: Triage inbox
echo ""
echo "Test 1: Triage inbox"
output=$(run_claude_logged "Triage my Gmail inbox using the gws CLI. Show a summary of unread messages." "$LOG_DIR/triage.json" 120)
assert_contains "$output" "inbox|unread|message|subject|from" "Triage returned results" || true
show_tools_used "$LOG_DIR/triage.json"

# Test 2: Search messages
echo ""
echo "Test 2: Search messages"
output=$(run_claude_logged "Search my Gmail for messages from the last 7 days using the gws CLI." "$LOG_DIR/search.json" 120)
assert_contains "$output" "message|result|email|subject" "Search returned results" || true
show_tools_used "$LOG_DIR/search.json"

# Test 3: Read a message
echo ""
echo "Test 3: Read a message (most recent)"
output=$(run_claude_logged "Use gws to find my most recent Gmail message and read its content." "$LOG_DIR/read.json" 120)
assert_not_contains "$output" "unauthorized|403|401" "No auth errors" || true
show_tools_used "$LOG_DIR/read.json"

# Test 4: Send email (to self)
echo ""
echo "Test 4: Send email to self"
TIMESTAMP=$(date +%s)
output=$(run_claude_logged "Use gws to send an email to me (my own address) with subject 'Integration test $TIMESTAMP' and body 'Automated test from spycner-tools'." "$LOG_DIR/send.json" 120)
assert_not_contains "$output" "unauthorized|403|401" "Send without auth errors" || true
show_tools_used "$LOG_DIR/send.json"

# Test 5: Create and delete a label
echo ""
echo "Test 5: Create and delete a label"
output=$(run_claude_logged "Use gws to create a Gmail label called 'test-label-$TIMESTAMP', then immediately delete it." "$LOG_DIR/label.json" 180)
assert_not_contains "$output" "unauthorized|403|401" "Label ops without auth errors" || true
show_tools_used "$LOG_DIR/label.json"

echo ""
echo "=== Gmail integration tests complete ==="
