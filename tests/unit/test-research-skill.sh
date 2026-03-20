#!/usr/bin/env bash
# Test: research skill
# Verifies the skill is loaded and describes correct capabilities
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: research skill ==="
echo ""

# Test 1: Skill recognition
echo "Test 1: Skill loading and recognition..."

output=$(run_claude "What is the research skill? Describe what it does briefly." 30)

assert_contains "$output" "research|Research" "Skill is recognized" || true
assert_contains "$output" "web.*search|WebSearch|investigate|deep dive" "Mentions web research capability" || true

echo ""

# Test 2: Tool preference
echo "Test 2: Tool preference..."

output=$(run_claude "In the research skill, what tools does it use? What is the primary execution mechanism?" 30)

assert_contains "$output" "WebSearch|web search" "Mentions WebSearch" || true
assert_contains "$output" "WebFetch|web fetch|fetch" "Mentions WebFetch" || true
assert_contains "$output" "agent|Agent|subagent" "Mentions agent dispatch" || true

echo ""

# Test 3: Workflow coverage
echo "Test 3: Workflow coverage..."

output=$(run_claude "What workflow does the research skill follow? What are the main steps?" 30)

assert_contains "$output" "clarif|scope|question" "Mentions clarification step" || true
assert_contains "$output" "route|dispatch|prompt" "Mentions routing decision" || true
assert_contains "$output" "deep|quick|mode" "Mentions research modes" || true

echo ""

# Test 4: Supporting references
echo "Test 4: Supporting references..."

output=$(run_claude "Does the research skill reference any supporting files? What templates or recipes does it use?" 30)

assert_contains "$output" "template|report" "Mentions report template" || true
assert_contains "$output" "recipe|pattern|strateg" "Mentions research recipes" || true

echo ""

echo "Test: Deep research agent mentions author estimate labeling"
result=$(run_claude "I want to research AI adoption metrics. What would you do if you derived a threshold yourself during research?" 30)
assert_contains "$result" "author estimate" "Should mention author estimate labeling for derived numbers" || true

echo ""
echo "Test: Deep research agent describes creative synthesis phase"
result=$(run_claude "I want to do creative research on remote work trends. What does creative mode do?" 30)
assert_contains "$result" "original analysis" "Should mention original analysis tagging in creative mode" || true

echo ""
echo "Test: Deep research agent mentions bias consistency for reused data"
result=$(run_claude "When writing a research report, how should I handle vendor data that I cite multiple times?" 30)
assert_contains "$result" "credibility" "Should mention credibility tagging on reuse of biased sources" || true

echo ""
echo "Test: Deep research agent mentions single-source transparency"
result=$(run_claude "Can I include a key finding that only has one source?" 30)
assert_contains "$result" "single source" "Should mention flagging single-source status for key findings" || true

echo ""
echo "Test: Deep research agent mentions threshold integrity in self-audit"
result=$(run_claude "What does the deep research agent check during self-audit before writing the report?" 30)
assert_contains "$result" "author estimate|threshold|source" "Should mention threshold integrity in self-audit" || true

echo ""
echo "Test: Research skill recognizes creative parameter"
result=$(run_claude "I want to do a creative deep dive on climate policy. What options can I configure?" 30)
assert_contains "$result" "creative" "Should mention creative as a configurable parameter" || true

echo "=== research skill tests complete ==="
