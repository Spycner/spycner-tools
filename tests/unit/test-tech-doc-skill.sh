#!/usr/bin/env bash
# Test: tech-doc skill
# Verifies the skill is loaded and describes correct capabilities
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

PLUGIN_DIR="${PLUGIN_DIR:-plugins/writing}"
export PLUGIN_DIR

echo "=== Test: tech-doc skill ==="
echo ""

# Test 1: Skill loads and is recognized
echo "Test 1: Skill loading and recognition..."
output=$(run_claude "What does the tech-doc skill do?" 30)
assert_contains "$output" "tech-doc|tech doc" "Skill is recognized" || true
assert_contains "$output" "Diataxis|Diátaxis|four quadrants|tutorial|how-to|reference|explanation" "Mentions Diátaxis or quadrants" || true
echo ""

# Test 2: Describes all four quadrants
echo "Test 2: All four quadrants covered..."
output=$(run_claude "What document types does the tech-doc skill cover?" 30)
assert_contains "$output" "tutorial" "Mentions tutorial" || true
assert_contains "$output" "how-to|how to" "Mentions how-to" || true
assert_contains "$output" "reference" "Mentions reference" || true
assert_contains "$output" "explanation" "Mentions explanation" || true
echo ""

# Test 3: Style presets including merged default
echo "Test 3: Style presets and merged default..."
output=$(run_claude "Which style guides does the tech-doc skill use?" 30)
assert_contains "$output" "Google" "Mentions Google style" || true
assert_contains "$output" "Microsoft" "Mentions Microsoft style" || true
assert_contains "$output" "house|merged|default" "Mentions house/merged/default preset" || true
echo ""

# Test 4: Critics by name
echo "Test 4: Panel critic names..."
output=$(run_claude "What critics does the tech-doc skill run during panel review?" 30)
assert_contains "$output" "style.adherence|style adherence" "Mentions style-adherence critic" || true
assert_contains "$output" "accessib" "Mentions accessibility critic" || true
assert_contains "$output" "inclusive" "Mentions inclusive-language critic" || true
assert_contains "$output" "code.fidelit|code fidelit" "Mentions code-fidelity critic" || true
assert_contains "$output" "future.feature|pre.announc|pre announc" "Mentions future-features critic" || true
assert_contains "$output" "quadrant.fit|quadrant fit|Diataxis|Diátaxis" "Mentions quadrant-fit critic" || true
echo ""

# Test 5: Finishing passes
echo "Test 5: Finishing passes..."
output=$(run_claude "What finishing passes does the tech-doc skill run?" 30)
assert_contains "$output" "AI.pattern|ai.pattern|ai pattern" "Mentions AI-pattern detector" || true
assert_contains "$output" "style.enforc|style enforc" "Mentions style-enforcer pass" || true
assert_contains "$output" "terminolog" "Mentions terminology-consistency pass" || true
echo ""

echo "=== tech-doc skill tests complete ==="
echo "All tests passed."
