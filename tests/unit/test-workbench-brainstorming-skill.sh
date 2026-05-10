#!/usr/bin/env bash
# Test: workbench:brainstorming skill (slim Q&A only)
# Verifies the skill is slim, points at writing-spec and visualizing-options,
# and no longer carries spec-writing or visual-companion content.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/workbench/skills/brainstorming"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: workbench:brainstorming slim skill ==="

# Test 1: SKILL.md exists with frontmatter
if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "[PASS] SKILL.md exists with frontmatter"
else
    echo "[FAIL] SKILL.md missing or no frontmatter"; exit 1
fi

# Test 2: Slim body markers present
for marker in 'HARD-GATE' 'Anti-Pattern' 'workbench:writing-spec' 'workbench:visualizing-options'; do
    if grep -qF "$marker" "$SKILL_MD"; then
        echo "[PASS] body mentions $marker"
    else
        echo "[FAIL] body missing $marker"; exit 1
    fi
done

# Test 3: Spec-writing content has been removed
for stale in 'Write design doc' 'Spec self-review' 'docs/workbench/specs' 'spec-document-reviewer-prompt.md'; do
    if grep -qF "$stale" "$SKILL_MD"; then
        echo "[FAIL] body still contains stale marker: $stale"; exit 1
    else
        echo "[PASS] no stale marker: $stale"
    fi
done

# Test 4: Visual-companion content has been removed
if [ -e "$SKILL_DIR/visual-companion.md" ] || [ -e "$SKILL_DIR/scripts" ]; then
    echo "[FAIL] visual-companion.md or scripts/ still present in brainstorming/"; exit 1
else
    echo "[PASS] visual-companion content moved out"
fi

# Test 5: spec-document-reviewer-prompt.md has been removed
if [ -e "$SKILL_DIR/spec-document-reviewer-prompt.md" ]; then
    echo "[FAIL] spec-document-reviewer-prompt.md still present in brainstorming/"; exit 1
else
    echo "[PASS] spec reviewer prompt moved out"
fi

# Test 6: No em-dash or en-dash in body
if grep -qP '[\x{2013}\x{2014}]' "$SKILL_MD"; then
    echo "[FAIL] em-dash or en-dash in SKILL.md body"; exit 1
else
    echo "[PASS] no em or en-dash"
fi

for f in "$SKILL_DIR"/references/*.html; do
    [ -e "$f" ] || continue
    if grep -qP '[\x{2013}\x{2014}]' "$f"; then
        echo "[FAIL] em-dash or en-dash in $f"; exit 1
    fi
done
TEMPLATE="$SKILL_DIR/references/brainstorm-summary-template.html"
[ -s "$TEMPLATE" ] || { echo "[FAIL] missing template: $TEMPLATE"; exit 1; }
head -c 32 "$TEMPLATE" | grep -qiE '<!DOCTYPE|<html' || { echo "[FAIL] template malformed: $TEMPLATE"; exit 1; }
echo "[PASS] em-dash + template checks"

# Test 7: Plugin manifests at 0.11.0
CCM="$REPO_ROOT/plugins/workbench/.claude-plugin/plugin.json"
CXM="$REPO_ROOT/plugins/workbench/.codex-plugin/plugin.json"
if jq -e '.version == "0.11.0"' "$CCM" >/dev/null && jq -e '.version == "0.11.0"' "$CXM" >/dev/null; then
    echo "[PASS] plugin manifests at 0.11.0"
else
    echo "[FAIL] plugin manifests not at 0.11.0"; exit 1
fi

echo "=== Tests complete ==="
