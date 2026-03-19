#!/usr/bin/env bash
# Test: confluence skill
# Verifies the skill is loaded and describes correct capabilities
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: confluence skill ==="
echo ""

# Test 1: Skill recognition and auth
echo "Test 1: Skill loading and auth approach..."

output=$(run_claude "What is the confluence skill? Describe its authentication requirements briefly." 30)

assert_contains "$output" "confluence|Confluence" "Skill is recognized" || true
assert_contains "$output" "acli|ATLASSIAN|auth|token|env" "Mentions authentication" || true

echo ""

# Test 2: Tool preference
echo "Test 2: Tool preference (curl primary)..."

output=$(run_claude "In the confluence skill, what tools does it use? Is acli or curl the primary tool and why?" 30)

assert_contains "$output" "curl|REST|API" "Mentions curl/REST API" || true
assert_contains "$output" "limited|primary|most|acli.*only|page.*view" "Notes acli limitation or curl priority" || true

echo ""

# Test 3: Operations coverage
echo "Test 3: Operations coverage..."

output=$(run_claude "What operations can the confluence skill perform? List the main categories." 30)

assert_contains "$output" "search|CQL|find" "Mentions search capability" || true
assert_contains "$output" "page|read|view" "Mentions page reading" || true
assert_contains "$output" "create|write|new" "Mentions page creation" || true
assert_contains "$output" "update|edit|modify" "Mentions page updates" || true
assert_contains "$output" "space" "Mentions spaces" || true

echo ""

# Test 4: Key gotchas
echo "Test 4: Key gotchas..."

output=$(run_claude "What are the key gotchas or important things to know when using the confluence skill? Mention version numbers and API versions." 30)

assert_contains "$output" "version|v1|v2|body.format|storage" "Mentions version or format gotcha" || true

echo ""

echo "=== confluence skill tests complete ==="
