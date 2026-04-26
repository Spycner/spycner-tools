#!/usr/bin/env bash
# Test: writing skill
# Verifies the skill is loaded and describes correct capabilities
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: writing skill ==="
echo ""

# Test 1: Skill recognition
echo "Test 1: Skill loading and recognition..."
output=$(run_claude "What is the writing skill? Describe what it does briefly." 30)
assert_contains "$output" "writing|Writing" "Skill is recognized" || true
assert_contains "$output" "pipeline|orchestrat|phase" "Mentions pipeline/orchestrator" || true
echo ""

# Test 2: Phases
echo "Test 2: Phase coverage..."
output=$(run_claude "What phases does the writing skill have? List them." 30)
assert_contains "$output" "interview|Interview" "Mentions interview phase" || true
assert_contains "$output" "outline|Outline" "Mentions outline phase" || true
assert_contains "$output" "throughline|Throughline" "Mentions throughline gate" || true
assert_contains "$output" "draft|Draft" "Mentions draft phase" || true
assert_contains "$output" "panel|Panel|critic" "Mentions panel/critics phase" || true
assert_contains "$output" "finishing|Finishing" "Mentions finishing phase" || true
echo ""

# Test 3: Panel of critics
echo "Test 3: Critics coverage..."
output=$(run_claude "What critics are in the panel? Name them." 30)
assert_contains "$output" "Hemingway|hemingway" "Mentions Hemingway" || true
assert_contains "$output" "Hitchcock|hitchcock" "Mentions Hitchcock" || true
assert_contains "$output" "[Mm]om" "Mentions Mom reader" || true
assert_contains "$output" "[Aa]sshole" "Mentions Asshole reader" || true
assert_contains "$output" "[Cc]larity|Zinsser" "Mentions Clarity critic (Zinsser)" || true
assert_contains "$output" "[Uu]sage|Strunk" "Mentions Usage critic (Strunk & White)" || true
assert_contains "$output" "[Ss]teel[- ]?[Mm]an|steelman" "Mentions Steel-man critic" || true
echo ""

# Test 4: Finishing passes
echo "Test 4: Finishing coverage..."
output=$(run_claude "What finishing passes does the writing skill have?" 30)
assert_contains "$output" "AI[- ]pattern|ai[- ]pattern" "Mentions AI-pattern detector" || true
assert_contains "$output" "style.*enforc|enforc.*style" "Mentions style enforcer" || true
assert_contains "$output" "line.*edit|edit.*line" "Mentions line editor" || true
assert_contains "$output" "Sedaris|sedaris" "Mentions Sedaris" || true
echo ""

# Test 5: Style guide handling
echo "Test 5: Style guide handling..."
output=$(run_claude "How does the writing skill handle style guides? What's the resolution order?" 30)
assert_contains "$output" "default|Default" "Mentions default style guide" || true
assert_contains "$output" "override|project|CLAUDE" "Mentions project override" || true
assert_contains "$output" "state|memory|remember" "Mentions state/memory" || true
echo ""

# Test 6: Phase-selectable behavior
echo "Test 6: Phase-selectable behavior..."
output=$(run_claude "Can the writing skill resume from a specific phase? How?" 30)
assert_contains "$output" "phase|Phase|--phase" "Mentions phase selection" || true
assert_contains "$output" "resume|jump|skip|start" "Mentions resume capability" || true
echo ""

# Test 7: Throughline gate semantics
echo "Test 7: Throughline gate..."
output=$(run_claude "What does the throughline gate in the writing skill do and when does it run?" 30)
assert_contains "$output" "10|ten" "Mentions the ten-word limit" || true
assert_contains "$output" "outline|Outline" "Mentions its relationship to outline" || true
assert_contains "$output" "draft|Draft" "Mentions its relationship to draft" || true
echo ""

# Test 8: Steel-man critic purpose
echo "Test 8: Steel-man critic..."
output=$(run_claude "What does the steel-man critic do and how is it different from the asshole reader?" 30)
assert_contains "$output" "[Oo]ppos|[Cc]ounter|[Aa]rgument" "Mentions opposing/counter-argument lens" || true
assert_contains "$output" "[Pp]reempt|engag|fairest|strongest" "Mentions preemption or steel-manned opposition" || true
echo ""

# Test 9: Format awareness
echo "Test 9: Format awareness..."
output=$(run_claude "What piece formats does the writing skill support and what changes based on format?" 30)
assert_contains "$output" "[Ee]ssay|[Bb]log|[Mm]emo|[Nn]ewsletter|[Aa]nnouncement|[Bb]riefing" "Mentions supported formats" || true
assert_contains "$output" "--format|format" "Mentions format flag or concept" || true
assert_contains "$output" "[Ss]mart.[Bb]revity|smart.brevity" "Mentions the format-gated Smart-Brevity critic" || true
echo ""

# Test 10: Smart-brevity critic awareness
echo "Test 10: Smart-brevity critic..."
output=$(run_claude "When does the Smart-Brevity critic run and what does it check?" 30)
assert_contains "$output" "[Mm]emo|[Nn]ewsletter|[Aa]nnouncement" "Mentions which formats trigger smart-brevity" || true
assert_contains "$output" "[Aa]xios|muscular|takeaway|scannable|short" "Mentions smart-brevity tenets" || true
echo ""

# Test 11: Pyramid dispatch in description
echo "Test 11: Pyramid dispatch in description and Step 3..."
SKILL_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/plugins/writing/skills/writing"
WRITING_SKILL="$SKILL_DIR/SKILL.md"
if grep -qE 'pyramid|Minto' "$WRITING_SKILL"; then
    echo "  [PASS] writing SKILL.md mentions pyramid/Minto"
else
    echo "  [FAIL] writing SKILL.md does not mention pyramid dispatch"
fi
if grep -qE 'analytical formats?' "$WRITING_SKILL"; then
    echo "  [PASS] writing SKILL.md mentions analytical formats"
else
    echo "  [FAIL] writing SKILL.md does not mention analytical formats"
fi
if grep -qE 'pyramid\.md.{0,2}exists' "$WRITING_SKILL"; then
    echo "  [PASS] writing SKILL.md Step 4 mentions pyramid.md artifact"
else
    echo "  [FAIL] writing SKILL.md Step 4 does not mention pyramid.md artifact"
fi
echo ""

echo "=== writing skill tests complete ==="
