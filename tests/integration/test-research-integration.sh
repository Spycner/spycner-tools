#!/usr/bin/env bash
# Integration test: research skill (v4)
# Tests the full v4 research cycle on a simple topic
# NOTE: This test makes real web searches and dispatches multiple agents, so it is slow.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Integration Test: research skill (v4) ==="
echo ""

# Use a temp directory for output
TEST_OUTPUT_DIR=$(mktemp -d)
REPORT_DIR="$TEST_OUTPUT_DIR/test-output"
trap 'rm -rf "$TEST_OUTPUT_DIR"' EXIT

LOG_FILE=$(mktemp)

echo "Test 1: v4 research cycle..."
echo "  Output dir: $REPORT_DIR"

output=$(run_claude_logged \
    "Research the history of markdown syntax. Save the report to $REPORT_DIR/. Keep the scope tight: a brief overview is fine." \
    "$LOG_FILE" \
    600)

echo ""

# Check intermediate artifacts
echo "Test 2: Verify v4 artifacts..."

if [ -d "$REPORT_DIR" ]; then
    echo "  [PASS] Report directory created"
else
    echo "  [FAIL] Report directory not found at $REPORT_DIR"
    echo "  Contents of output dir:"
    ls -la "$TEST_OUTPUT_DIR" 2>/dev/null | sed 's/^/    /' || echo "    (empty)"
fi

if [ -f "$REPORT_DIR/brief.md" ]; then
    echo "  [PASS] brief.md exists"
else
    echo "  [FAIL] brief.md not found"
fi

if [ -f "$REPORT_DIR/plan.md" ]; then
    echo "  [PASS] plan.md exists"
else
    echo "  [FAIL] plan.md not found"
fi

if ls "$REPORT_DIR/research/"*.md 2>/dev/null | grep -v -E '(synthesis|review)' >/dev/null; then
    echo "  [PASS] At least one researcher cluster file exists in research/"
else
    echo "  [FAIL] No researcher cluster files found in research/"
fi

if [ -f "$REPORT_DIR/research/synthesis.md" ]; then
    echo "  [PASS] research/synthesis.md exists"
else
    echo "  [FAIL] research/synthesis.md not found"
fi

if ls "$REPORT_DIR/research/synthesis-review-"*.md 2>/dev/null >/dev/null; then
    echo "  [PASS] At least one synthesis-review-N.md exists"
else
    echo "  [FAIL] No synthesis-review files found"
fi

echo ""

# Check final report
echo "Test 3: Verify report..."

if [ -f "$REPORT_DIR/report.md" ]; then
    echo "  [PASS] report.md exists"
    assert_contains "$(cat "$REPORT_DIR/report.md")" "Executive Summary|executive summary" "Report has Executive Summary" || true
    assert_contains "$(cat "$REPORT_DIR/report.md")" "References|references|Sources|sources" "Report has References" || true
    assert_contains "$(cat "$REPORT_DIR/report.md")" "http|https" "Report contains citation URLs" || true
else
    echo "  [FAIL] report.md not found"
fi

if ls "$REPORT_DIR/report-review-"*.md 2>/dev/null >/dev/null; then
    echo "  [PASS] At least one report-review-N.md exists"
else
    echo "  [FAIL] No report-review files found"
fi

echo ""

# Verify v3 artifacts are NOT produced
echo "Test 4: v3 artifacts absent..."

if [ -f "$REPORT_DIR/research/sources.md" ]; then
    echo "  [FAIL] v3 sources.md still being produced (should be inline in cluster files)"
else
    echo "  [PASS] No legacy sources.md"
fi

if [ -f "$REPORT_DIR/research/notes.md" ]; then
    echo "  [FAIL] v3 notes.md still being produced (should be inline in cluster files)"
else
    echo "  [PASS] No legacy notes.md"
fi

echo ""

# Show tools used
echo "Test 5: Tool usage..."
show_tools_used "$LOG_FILE"

echo ""
echo "=== research integration tests complete ==="
