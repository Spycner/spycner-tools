#!/usr/bin/env bash
# Integration test: tech-doc skill (tutorial end-to-end smoke)
# Runs the full six-phase pipeline on a tiny tutorial topic and verifies artifacts
# NOTE: dispatches intake, outline, throughline gate, draft, panel critics, and finishing passes;
# expect 5-10 minutes runtime
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

PLUGIN_DIR="${PLUGIN_DIR:-plugins/writing}"
export PLUGIN_DIR

echo "=== Integration Test: tech-doc skill (tutorial smoke) ==="
echo ""

TEST_DIR=$(mktemp -d)
LOG_FILE=$(mktemp)
trap 'rm -rf "$TEST_DIR" "$LOG_FILE"' EXIT
cd "$TEST_DIR"

echo "Working dir: $TEST_DIR"
echo ""

echo "Test 1: Full pipeline runs end-to-end..."
# All intake answers are embedded in the prompt so the pipeline runs non-interactively.
PROMPT="Run the full tech-doc skill pipeline in $TEST_DIR. Use --quadrant tutorial --style-preset house. Audience: beginner. Language/platform: plain markdown. Topic: 'How to add a grocery list entry in a markdown file'. The tutorial throughline (what the reader will do): 'Add a new item to a markdown grocery list'. The section skeleton is: 1. Prerequisites, 2. Open the file, 3. Add the list entry, 4. Save the file. Confirm the quadrant, confirm the outline without revisions, proceed through all six phases (intake, outline, throughline, draft, panel, finishing). Do not ask follow-up questions; use the information provided and proceed."

output=$(run_claude_logged "$PROMPT" "$LOG_FILE" 600)

echo ""
echo "Test 2: Core artifact files exist..."
for artifact in intake.md outline.md throughline.md draft.md critique.md finishing-notes.md glossary.md; do
    if [ -f "$TEST_DIR/$artifact" ]; then
        echo "  [PASS] $artifact created"
    else
        echo "  [FAIL] $artifact not found"
    fi
done

echo ""
echo "Test 3: critique.md has a Verdicts table..."
if [ -f "$TEST_DIR/critique.md" ]; then
    if grep -qiE 'Verdict|verdict' "$TEST_DIR/critique.md"; then
        echo "  [PASS] critique.md contains a Verdicts section"
    else
        echo "  [FAIL] critique.md missing Verdicts section"
    fi
else
    echo "  [FAIL] critique.md does not exist; cannot check structure"
fi

echo ""
echo "Test 4: throughline.md is at most ten words..."
if [ -f "$TEST_DIR/throughline.md" ]; then
    word_count=$(wc -w < "$TEST_DIR/throughline.md")
    if [ "$word_count" -le 10 ]; then
        echo "  [PASS] throughline.md has <=10 words ($word_count)"
    else
        echo "  [FAIL] throughline.md has $word_count words; expected <=10"
    fi
else
    echo "  [FAIL] throughline.md does not exist"
fi

echo ""
echo "Test 5: finishing-notes.md has content from all three passes..."
if [ -f "$TEST_DIR/finishing-notes.md" ]; then
    if grep -qiE 'ai.pattern|pattern detector' "$TEST_DIR/finishing-notes.md"; then
        echo "  [PASS] finishing-notes.md has AI-pattern pass entry"
    else
        echo "  [WARN] finishing-notes.md may be missing AI-pattern pass entry"
    fi
    if grep -qiE 'style.enforc|style enforc' "$TEST_DIR/finishing-notes.md"; then
        echo "  [PASS] finishing-notes.md has style-enforcer pass entry"
    else
        echo "  [WARN] finishing-notes.md may be missing style-enforcer pass entry"
    fi
    if grep -qiE 'terminolog' "$TEST_DIR/finishing-notes.md"; then
        echo "  [PASS] finishing-notes.md has terminology-consistency pass entry"
    else
        echo "  [WARN] finishing-notes.md may be missing terminology-consistency pass entry"
    fi
else
    echo "  [FAIL] finishing-notes.md does not exist"
fi

echo ""
echo "PASS"
echo ""
echo "=== tech-doc integration test complete ==="
echo ""
show_tools_used "$LOG_FILE"
