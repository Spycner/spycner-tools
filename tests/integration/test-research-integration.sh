#!/usr/bin/env bash
# Integration test: research skill (quick mode)
# Tests the full quick-mode research cycle on a simple topic
# NOTE: This test makes real web searches — run sparingly
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Integration Test: research skill (quick mode) ==="
echo ""

# Use a temp directory for output — use a fixed subdir name to avoid slug mismatches
TEST_OUTPUT_DIR=$(mktemp -d)
REPORT_DIR="$TEST_OUTPUT_DIR/test-output"
trap 'rm -rf "$TEST_OUTPUT_DIR"' EXIT

LOG_FILE=$(mktemp)

echo "Test 1: Quick-mode research cycle..."
echo "  Output dir: $REPORT_DIR"

output=$(run_claude_logged \
    "Do a quick research on the history of markdown syntax. Save the report to $REPORT_DIR/. Use quick mode — I just need a brief overview with a few sources." \
    "$LOG_FILE" \
    180)

echo ""

# Check intermediate artifacts
echo "Test 2: Verify intermediate artifacts..."

if [ -d "$REPORT_DIR" ]; then
    echo "  [PASS] Report directory created"
else
    echo "  [FAIL] Report directory not found at $REPORT_DIR"
    echo "  Contents of output dir:"
    ls -la "$TEST_OUTPUT_DIR" 2>/dev/null | sed 's/^/    /' || echo "    (empty)"
fi

if [ -f "$REPORT_DIR/research/plan.md" ]; then
    echo "  [PASS] research/plan.md exists"
else
    echo "  [FAIL] research/plan.md not found"
fi

if [ -f "$REPORT_DIR/research/sources.md" ]; then
    echo "  [PASS] research/sources.md exists"
else
    echo "  [FAIL] research/sources.md not found"
fi

if [ -f "$REPORT_DIR/research/notes.md" ]; then
    echo "  [PASS] research/notes.md exists"
else
    echo "  [FAIL] research/notes.md not found"
fi

echo ""

# Check final report
echo "Test 3: Verify report..."

if [ -f "$REPORT_DIR/report.md" ]; then
    echo "  [PASS] report.md exists"
    assert_contains "$(cat "$REPORT_DIR/report.md")" "Executive Summary|executive summary" "Report has Executive Summary" || true
    assert_contains "$(cat "$REPORT_DIR/report.md")" "Key Findings|key findings" "Report has Key Findings" || true
    assert_contains "$(cat "$REPORT_DIR/report.md")" "References|references|Sources|sources" "Report has References" || true
    assert_contains "$(cat "$REPORT_DIR/report.md")" "http|https" "Report contains citation URLs" || true
else
    echo "  [FAIL] report.md not found"
fi

echo ""

# Test 4: Configurable output path
echo "Test 4: Custom output path..."

CUSTOM_DIR="$TEST_OUTPUT_DIR/custom-output"
LOG_FILE_2=$(mktemp)

output=$(run_claude_logged \
    "Do a quick research on what JSON is. Save to $CUSTOM_DIR/. Quick mode." \
    "$LOG_FILE_2" \
    180)

if [ -d "$CUSTOM_DIR" ]; then
    echo "  [PASS] Custom output path created"
else
    echo "  [FAIL] Custom output path not found at $CUSTOM_DIR"
fi

if [ -f "$CUSTOM_DIR/report.md" ]; then
    echo "  [PASS] report.md exists in custom path"
else
    echo "  [FAIL] report.md not found in custom path"
fi

echo ""

# Show tools used
echo "Test 5: Tool usage..."
show_tools_used "$LOG_FILE"

echo ""
echo "=== research integration tests complete ==="
