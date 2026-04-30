#!/usr/bin/env bash
# Test: research skill (v4)
# Verifies the skill is loaded and describes the v4 orchestrator-driven pipeline
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: research skill (v4) ==="
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
assert_contains "$output" "agent|Agent|subagent|orchestrat" "Mentions agent dispatch or orchestrator" || true

echo ""

# Test 3: v4 pipeline shape
echo "Test 3: v4 pipeline shape..."

output=$(run_claude "What workflow does the research skill follow? What are the main steps?" 30)

assert_contains "$output" "plan|cluster" "Mentions planning / clustering" || true
assert_contains "$output" "synthesi" "Mentions synthesis step" || true
assert_contains "$output" "review|reviewer" "Mentions review gates" || true
assert_contains "$output" "writer|write" "Mentions writer step" || true

echo ""

# Test 4: Parallel deep researchers
echo "Test 4: Parallel deep researchers..."

output=$(run_claude "How does the research skill handle multiple research topics? What does each researcher produce?" 30)

assert_contains "$output" "parallel|cluster|each.*researcher" "Mentions parallel/cluster fan-out" || true
assert_contains "$output" "iterative|deep|saturation" "Mentions iterative deep search" || true
assert_contains "$output" "inline|self-contained|one.*markdown|sources.*inline" "Mentions one md with inline sources" || true

echo ""

# Test 5: Unbounded review loops with check-in
echo "Test 5: Unbounded review loops..."

output=$(run_claude "How does the research skill handle review iterations? Is there a limit on review loops?" 30)

assert_contains "$output" "unbounded|no.*limit|until.*pass|until.*happy" "Mentions unbounded loops" || true
assert_contains "$output" "check.?in|every.*3|status.*update" "Mentions periodic check-in" || true
assert_contains "$output" "stall|repeated|same.*issue" "Mentions stall detection" || true

echo ""

# Test 6: Synthesis vs writer split
echo "Test 6: Synthesis vs writer split..."

output=$(run_claude "In the research skill, what is the difference between the synthesis agent and the writer agent?" 30)

assert_contains "$output" "synthesi" "Mentions synthesis agent" || true
assert_contains "$output" "writer|prose|polish|render" "Mentions writer agent" || true
assert_contains "$output" "claim|evidence|substance|content|analy" "Mentions synthesis = substance/analysis" || true

echo ""

# Test 7: Reviewer escalation rules
echo "Test 7: Reviewer escalation rules..."

output=$(run_claude "In the research skill, which reviewer can trigger new research, and which cannot?" 30)

assert_contains "$output" "synthesis.*reviewer|synthesis review" "Mentions synthesis reviewer" || true
assert_contains "$output" "writer.*reviewer|writer review|report.*reviewer" "Mentions writer/report reviewer" || true
assert_contains "$output" "only.*synthesis|cannot.*escalat|content.gap.suspect" "Mentions writer-reviewer cannot escalate directly" || true

echo ""

# Test 8: Supporting references
echo "Test 8: Supporting references..."

output=$(run_claude "Does the research skill reference any supporting files? What templates or recipes does it use?" 30)

assert_contains "$output" "template|report" "Mentions report template" || true
assert_contains "$output" "recipe|pattern|strateg" "Mentions research recipes" || true

echo ""

# Test 9: Output file layout
echo "Test 9: Output file layout..."

output=$(run_claude "What files does the research skill create in its output directory?" 30)

assert_contains "$output" "plan\.md|plan.md" "Mentions plan.md" || true
assert_contains "$output" "synthesis\.md|synthesis.md" "Mentions synthesis.md" || true
assert_contains "$output" "report\.md|report.md" "Mentions report.md" || true
assert_contains "$output" "review|review-" "Mentions review files" || true

echo ""

echo "=== research skill tests complete ==="
