#!/usr/bin/env bash
# Test: workbench:writing-spec skill structure
# Verifies the new skill exists, frontmatter triggers correctly, body covers
# the synthesize-review-gate flow, and the moved reviewer prompt is intact.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/workbench/skills/writing-spec"
SKILL_MD="$SKILL_DIR/SKILL.md"
REVIEWER="$SKILL_DIR/spec-document-reviewer-prompt.md"

echo "=== Test: workbench:writing-spec skill ==="

# Test 1: SKILL.md exists with frontmatter
if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "[PASS] SKILL.md exists with frontmatter"
else
    echo "[FAIL] SKILL.md missing or no frontmatter"; exit 1
fi

# Test 2: Description triggers correctly
desc=$(awk '/^description:/{flag=1;sub(/^description:[ ]*/,"")} /^---$/{flag=0} flag' "$SKILL_MD")
for term in 'design discussion' 'spec' 'self-review' 'writing-plans'; do
    if echo "$desc" | grep -qiF "$term"; then
        echo "[PASS] description mentions $term"
    else
        echo "[FAIL] description missing $term"; exit 1
    fi
done

# Test 3: Body markers present
for marker in 'When to Invoke' 'Self-Review' 'User Approval Gate' 'workbench:writing-plans' 'spec-document-reviewer-prompt.md'; do
    if grep -qF "$marker" "$SKILL_MD"; then
        echo "[PASS] body mentions $marker"
    else
        echo "[FAIL] body missing $marker"; exit 1
    fi
done

# Test 4: Reviewer prompt present and intact
if [ -s "$REVIEWER" ] && grep -qiF 'spec' "$REVIEWER" && grep -qiF 'review' "$REVIEWER"; then
    echo "[PASS] spec-document-reviewer-prompt.md present and well-formed"
else
    echo "[FAIL] spec reviewer prompt missing or incomplete"; exit 1
fi

# Test 5: No em or en-dash in SKILL.md body
if grep -qP '[\x{2013}\x{2014}]' "$SKILL_MD"; then
    echo "[FAIL] em-dash or en-dash in SKILL.md"; exit 1
else
    echo "[PASS] no em or en-dash"
fi

echo "=== Tests complete ==="
