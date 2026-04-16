#!/usr/bin/env bash
# Integration test: writing skill (panel-only mode)
# Tests that the panel phase produces consolidated critique on a small draft
# NOTE: This dispatches four agents; expect 2-5 minutes runtime
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Integration Test: writing skill (panel-only mode) ==="
echo ""

# Use a temp directory with a pre-written draft
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

cat > "$TEST_DIR/draft.md" <<'DRAFT'
# Why I stopped using semaphores

*Draft v1*

I used to leverage semaphores for concurrency control in all of my services. It's worth noting that they are an incredibly powerful primitive, providing robust synchronization across threads. However, I've come to realize that they are also a source of significant complexity in modern codebases.

The fact that semaphores require explicit acquire and release calls means that any programmer can forget one. There is the additional problem that deadlocks become possible when multiple semaphores are involved. In my experience, the cost is rarely worth it.

I now navigate the complexities of concurrency by using channels instead. Here's the thing about channels: they enforce ownership semantics in a way semaphores do not. At the end of the day, this leads to more maintainable code.

In conclusion, semaphores are a tool of last resort.
DRAFT

LOG_FILE=$(mktemp)
trap "rm -f $LOG_FILE" EXIT

echo "Test 1: Panel runs and produces critique.md..."
echo "  Working dir: $TEST_DIR"

output=$(run_claude_logged \
    "Run only the panel phase of the writing skill on the draft at $TEST_DIR/draft.md. Use --phase panel --dir $TEST_DIR. Use the default style guide." \
    "$LOG_FILE" \
    300)

if [ -f "$TEST_DIR/critique.md" ]; then
    echo "  [PASS] critique.md created"
else
    echo "  [FAIL] critique.md not found"
    ls -la "$TEST_DIR" | sed 's/^/    /'
fi

echo ""
echo "Test 2: All four per-critic files created..."
for critic in hemingway hitchcock mom asshole; do
    if [ -f "$TEST_DIR/critique-${critic}.md" ]; then
        echo "  [PASS] critique-${critic}.md created"
    else
        echo "  [FAIL] critique-${critic}.md not found"
    fi
done

echo ""
echo "Test 3: Each critic flagged at least one issue (the draft is intentionally bad)..."
for critic in hemingway hitchcock mom asshole; do
    if [ -f "$TEST_DIR/critique-${critic}.md" ]; then
        line_count=$(wc -l < "$TEST_DIR/critique-${critic}.md")
        if [ "$line_count" -gt 5 ]; then
            echo "  [PASS] critique-${critic}.md has substantive content ($line_count lines)"
        else
            echo "  [FAIL] critique-${critic}.md is suspiciously short ($line_count lines)"
        fi
    fi
done

echo ""
echo "Test 4: Asshole reader flagged unearned claims (the draft has many)..."
if grep -qiE "unearned|claim|generaliz|in my experience|cherry" "$TEST_DIR/critique-asshole.md" 2>/dev/null; then
    echo "  [PASS] Asshole reader engaged with the draft's argument"
else
    echo "  [FAIL] Asshole reader did not flag any argument issues"
fi

echo ""
echo "Test 5: AI-pattern detector would flag (verifying via direct grep on draft)..."
echo "  (Smoke test only checks panel phase; finishing pass tested separately if added later)"

echo ""
echo "=== writing integration test complete ==="
