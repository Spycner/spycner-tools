#!/usr/bin/env bash
# Test: jira skill
# Verifies the skill is loaded and describes correct capabilities
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: jira skill ==="
echo ""

# Test 1: Skill recognition and auth
echo "Test 1: Skill loading and auth approach..."

output=$(run_claude "What is the jira skill? Describe its authentication requirements briefly." 30)

assert_contains "$output" "jira|Jira" "Skill is recognized" || true
assert_contains "$output" "acli|ATLASSIAN|auth|token" "Mentions authentication" || true

echo ""

# Test 2: Tool preference
echo "Test 2: Tool preference..."

output=$(run_claude "In the jira skill, what tools does it use to interact with Jira? Which is preferred?" 30)

assert_contains "$output" "acli" "Mentions acli CLI" || true
assert_contains "$output" "curl|REST|API|fallback" "Mentions curl or REST API" || true

echo ""

# Test 3: Operations coverage
echo "Test 3: Operations coverage..."

output=$(run_claude "What operations can the jira skill perform? List the main categories." 30)

assert_contains "$output" "search|JQL|query|find" "Mentions search capability" || true
assert_contains "$output" "create|issue|ticket" "Mentions issue creation" || true
assert_contains "$output" "transition|status|move|workflow" "Mentions transitions" || true
assert_contains "$output" "assign" "Mentions assignment" || true
assert_contains "$output" "comment" "Mentions comments" || true

echo ""

# Test 4: Supporting references
echo "Test 4: Supporting references..."

output=$(run_claude "Does the jira skill reference any supporting files like JQL recipes or ADF format? What are they?" 30)

assert_contains "$output" "jql|JQL" "Mentions JQL" || true
assert_contains "$output" "ADF|document.*format|Atlassian.*Document" "Mentions ADF" || true

echo ""

echo "=== jira skill tests complete ==="
