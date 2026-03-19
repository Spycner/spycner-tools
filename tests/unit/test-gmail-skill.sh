#!/usr/bin/env bash
# Test: gmail skill
# Verifies the skill is loaded and describes correct capabilities
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: gmail skill ==="
echo ""

# Test 1: Skill recognition and auth
echo "Test 1: Skill loading and auth approach..."

output=$(run_claude "What is the gmail skill? Describe its authentication requirements briefly." 30)

assert_contains "$output" "gmail|Gmail" "Skill is recognized" || true
assert_contains "$output" "gws|auth|authenticated" "Mentions authentication" || true

echo ""

# Test 2: Tool preference
echo "Test 2: Tool preference..."

output=$(run_claude "In the gmail skill, what tool does it use to interact with Gmail? What are helper commands?" 30)

assert_contains "$output" "gws" "Mentions gws CLI" || true
assert_contains "$output" "helper|\+send|\+triage|\+read" "Mentions helper commands" || true

echo ""

# Test 3: Operations coverage
echo "Test 3: Operations coverage..."

output=$(run_claude "What operations can the gmail skill perform? List the main categories." 30)

assert_contains "$output" "triage|inbox|unread" "Mentions triage/inbox" || true
assert_contains "$output" "send|email|message" "Mentions sending" || true
assert_contains "$output" "read|search|list" "Mentions reading/searching" || true
assert_contains "$output" "label|filter|manage" "Mentions management" || true

echo ""

# Test 4: Supporting references
echo "Test 4: Supporting references..."

output=$(run_claude "Does the gmail skill reference any supporting files for search queries? What are they?" 30)

assert_contains "$output" "search|recipe|operator" "Mentions search recipes" || true

echo ""

echo "=== gmail skill tests complete ==="
