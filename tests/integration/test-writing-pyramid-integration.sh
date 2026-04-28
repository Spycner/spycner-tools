#!/usr/bin/env bash
# Integration test: writing skill dispatches to pyramid for analytical formats
# Verifies end-to-end memo flow: intake.md, pyramid.md, throughline.md, draft.md
# NOTE: dispatches multiple agents (intake interactive + construct + audit panel + opener +
# render + analytical draft); expect 8-15 minutes runtime
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Integration Test: writing skill dispatches to pyramid for memo ==="
echo ""

TEST_DIR=$(mktemp -d)
LOG_FILE=$(mktemp)
trap 'rm -rf "$TEST_DIR" "$LOG_FILE"' EXIT

echo "Test 1: Memo run via /writing produces pyramid artifacts and draft..."
echo "  Working dir: $TEST_DIR"

output=$(run_claude_logged \
    "Run the writing skill in --format memo mode on the topic 'Why we should standardise on PostgreSQL across services' for an audience of platform engineering leads. Use --dir $TEST_DIR. Pick Greenfield mode when asked. The reader question is 'Should we standardise our database choice?'. Answer pyramid intake questions sensibly so the pipeline can proceed. Run through Phase 4 (analytical draft) and stop before panel review." \
    "$LOG_FILE" \
    900)

echo ""
echo "Test 2: Pyramid artifacts exist..."
for artifact in intake.md construction.md audit-summary.md opener.md pyramid.md; do
    if [ -f "$TEST_DIR/$artifact" ]; then
        echo "  [PASS] $artifact created"
    else
        echo "  [FAIL] $artifact not found"
    fi
done

echo ""
echo "Test 3: Throughline gate fired and produced throughline.md..."
if [ -f "$TEST_DIR/throughline.md" ]; then
    word_count=$(wc -w < "$TEST_DIR/throughline.md")
    if [ "$word_count" -le 10 ]; then
        echo "  [PASS] throughline.md exists with ≤10 words ($word_count)"
    else
        echo "  [FAIL] throughline.md has $word_count words, expected ≤10"
    fi
else
    echo "  [FAIL] throughline.md not found"
fi

echo ""
echo "Test 4: Analytical draft.md exists and has expected structure..."
if [ -f "$TEST_DIR/draft.md" ]; then
    echo "  [PASS] draft.md created"
    if grep -qE 'Drafting notes' "$TEST_DIR/draft.md"; then
        echo "  [PASS] draft.md has Drafting notes section"
    else
        echo "  [FAIL] draft.md missing Drafting notes section"
    fi
    if grep -qE 'Pyramid coverage' "$TEST_DIR/draft.md"; then
        echo "  [PASS] draft.md mentions Pyramid coverage (analytical-draft signature)"
    else
        echo "  [FAIL] draft.md missing Pyramid coverage notes (likely used wrong draft prompt)"
    fi
else
    echo "  [FAIL] draft.md not found"
fi

echo ""
echo "Test 5: No outline.md created (analytical path skipped narrative outline)..."
if [ -f "$TEST_DIR/outline.md" ]; then
    echo "  [FAIL] outline.md unexpectedly created (analytical path should skip narrative outline)"
else
    echo "  [PASS] outline.md correctly absent"
fi

echo ""
echo "=== writing-pyramid integration test complete ==="
echo "Working dir preserved at $TEST_DIR (cleaned by trap on exit)"
echo "Tool log: $LOG_FILE"
echo ""
show_tools_used "$LOG_FILE"
