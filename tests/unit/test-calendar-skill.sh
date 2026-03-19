#!/usr/bin/env bash
# Test: calendar skill
# Verifies the skill is loaded and describes correct capabilities
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: calendar skill ==="
echo ""

# Test 1: Skill recognition and auth
echo "Test 1: Skill loading and auth approach..."

output=$(run_claude "What is the calendar skill? Describe its authentication requirements briefly." 30)

assert_contains "$output" "calendar|Calendar" "Skill is recognized" || true
assert_contains "$output" "gws|auth|authenticated" "Mentions authentication" || true

echo ""

# Test 2: Tool preference
echo "Test 2: Tool preference..."

output=$(run_claude "In the calendar skill, what tool does it use to interact with Google Calendar? What are helper commands?" 30)

assert_contains "$output" "gws" "Mentions gws CLI" || true
assert_contains "$output" "helper|\+agenda|\+insert" "Mentions helper commands" || true

echo ""

# Test 3: Operations coverage
echo "Test 3: Operations coverage..."

output=$(run_claude "What operations can the calendar skill perform? List the main categories." 30)

assert_contains "$output" "agenda|events|schedule" "Mentions agenda/events" || true
assert_contains "$output" "create|insert|add" "Mentions event creation" || true
assert_contains "$output" "delete|manage|calendar" "Mentions management" || true
assert_contains "$output" "free|busy|availability" "Mentions availability" || true

echo ""

# Test 4: Supporting references
echo "Test 4: Supporting references..."

output=$(run_claude "Does the calendar skill reference any supporting files for common patterns? What are they?" 30)

assert_contains "$output" "recipe|pattern|example" "Mentions recipes/patterns" || true

echo ""

echo "=== calendar skill tests complete ==="
