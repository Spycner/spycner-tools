#!/usr/bin/env bash
# Test: workbench:autopilot skill structure
# Verifies PR 2 of the autopilot port: SKILL.md exists, references all six refs,
# names every universal skill, has all ten step headings, and the plugin manifests
# are at 0.3.0.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/workbench/skills/autopilot"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: workbench:autopilot skill structure ==="
echo ""

# Test 1: SKILL.md exists with frontmatter
echo "Test 1: SKILL.md exists with frontmatter..."
if [ -s "$SKILL_MD" ]; then
    if head -1 "$SKILL_MD" | grep -q '^---$'; then
        echo "  [PASS] SKILL.md exists with frontmatter"
    else
        echo "  [FAIL] SKILL.md missing frontmatter"
        exit 1
    fi
else
    echo "  [FAIL] SKILL.md missing or empty"
    exit 1
fi
echo ""

# Test 2: All six reference files exist
echo "Test 2: Reference files exist..."
for ref in profile-schema example-project-profile invariants required-skills claude-code-adapter codex-adapter; do
    f="$SKILL_DIR/references/$ref.md"
    if [ -s "$f" ]; then
        echo "  [PASS] references/$ref.md exists"
    else
        echo "  [FAIL] references/$ref.md missing or empty"
        exit 1
    fi
done
echo ""

# Test 3: SKILL.md mentions all six reference files
echo "Test 3: SKILL.md references all six reference files..."
for ref in profile-schema example-project-profile invariants required-skills claude-code-adapter codex-adapter; do
    if grep -qF "$ref" "$SKILL_MD"; then
        echo "  [PASS] SKILL.md mentions $ref"
    else
        echo "  [FAIL] SKILL.md missing reference to $ref"
        exit 1
    fi
done
echo ""

# Test 4: SKILL.md mentions .workbench/autopilot.md
echo "Test 4: SKILL.md mentions .workbench/autopilot.md..."
if grep -qF '.workbench/autopilot.md' "$SKILL_MD"; then
    echo "  [PASS] SKILL.md mentions .workbench/autopilot.md"
else
    echo "  [FAIL] SKILL.md missing .workbench/autopilot.md"
    exit 1
fi
echo ""

# Test 5: SKILL.md mentions every skill in the universal table
echo "Test 5: SKILL.md mentions every universal skill..."
for skill in 'workbench:using-workbench' 'workbench:brainstorming' 'workbench:writing-spec' 'workbench:writing-plans' 'workbench:test-driven-development' 'superpowers:subagent-driven-development' 'agent-system-management:capturing-session-learnings' 'agent-system-management:improving-instructions' 'workbench:verification-before-completion'; do
    if grep -qF "$skill" "$SKILL_MD"; then
        echo "  [PASS] SKILL.md mentions $skill"
    else
        echo "  [FAIL] SKILL.md missing $skill"
        exit 1
    fi
done
echo ""

# Test 6: All ten step headings present
echo "Test 6: All ten step headings present..."
for n in 0 1 2 3 4 5 6 7 8 9; do
    if grep -qE "^### Step $n[: ]" "$SKILL_MD"; then
        echo "  [PASS] Step $n heading present"
    else
        echo "  [FAIL] Step $n heading missing"
        exit 1
    fi
done
echo ""

# Test 7: invariants.md lists six non-negotiables
echo "Test 7: invariants.md lists six non-negotiables..."
INV="$SKILL_DIR/references/invariants.md"
HEADINGS=$(grep -cE '^## [0-9]+\. ' "$INV" || true)
if [ "$HEADINGS" -eq 6 ]; then
    echo "  [PASS] invariants.md has six numbered headings"
else
    echo "  [FAIL] invariants.md has $HEADINGS numbered headings (expected 6)"
    exit 1
fi
for term in 'PR behavior' 'hooks' 'AI attribution' 'Conventional Commits' 'em-dash' 'freehand'; do
    if grep -qiF "$term" "$INV"; then
        echo "  [PASS] invariants mentions $term"
    else
        echo "  [FAIL] invariants missing $term"
        exit 1
    fi
done
echo ""

# Test 8: required-skills.md complete
echo "Test 8: required-skills.md complete..."
RS="$SKILL_DIR/references/required-skills.md"
for term in 'workbench:using-workbench' 'workbench:brainstorming' 'workbench:verification-before-completion' 'replaces' 'additional' 'Removal not supported'; do
    if grep -qF "$term" "$RS"; then
        echo "  [PASS] required-skills mentions $term"
    else
        echo "  [FAIL] required-skills missing $term"
        exit 1
    fi
done
echo ""

# Test 9: Adapter docs runtime-correct
echo "Test 9: Adapter docs..."
CC="$SKILL_DIR/references/claude-code-adapter.md"
CX="$SKILL_DIR/references/codex-adapter.md"
if grep -qF 'Agent' "$CC" && grep -qF 'Monitor' "$CC" && grep -qiF 'subagent' "$CC"; then
    echo "  [PASS] claude-code-adapter mentions Agent, Monitor, subagent"
else
    echo "  [FAIL] claude-code-adapter incomplete"
    exit 1
fi
if grep -qF 'sequential' "$CX" && grep -qF 'fallback' "$CX"; then
    echo "  [PASS] codex-adapter mentions sequential fallback"
else
    echo "  [FAIL] codex-adapter incomplete"
    exit 1
fi
echo ""

# Test 10: Description triggers correctly
echo "Test 10: Description trigger phrases..."
desc=$(awk '/^description:/{flag=1;sub(/^description:[ ]*/,"")} /^---$/{flag=0} flag' "$SKILL_MD")
if echo "$desc" | grep -qiE 'autonomous|autopilot|end-to-end'; then
    echo "  [PASS] description mentions autonomous/autopilot/end-to-end"
else
    echo "  [FAIL] description missing key trigger phrase"
    exit 1
fi
if echo "$desc" | grep -qF '.workbench/autopilot.md'; then
    echo "  [PASS] description mentions .workbench/autopilot.md"
else
    echo "  [FAIL] description missing .workbench/autopilot.md"
    exit 1
fi
echo ""

# Test 11: Plugin manifests at 0.8.0
echo "Test 11: Plugin manifests at 0.8.0..."
CCM="$REPO_ROOT/plugins/workbench/.claude-plugin/plugin.json"
CXM="$REPO_ROOT/plugins/workbench/.codex-plugin/plugin.json"
if jq -e '.version == "0.8.0"' "$CCM" >/dev/null && jq -e '.version == "0.8.0"' "$CXM" >/dev/null; then
    echo "  [PASS] both plugin manifests at 0.8.0"
else
    echo "  [FAIL] plugin manifests not at 0.8.0"
    exit 1
fi
echo ""

# Test 12: Marketplace entries at 0.8.0
echo "Test 12: Marketplace entries..."
MP="$REPO_ROOT/.claude-plugin/marketplace.json"
if jq -e '.plugins[] | select(.name == "workbench") | .version == "0.8.0"' "$MP" >/dev/null; then
    echo "  [PASS] Claude marketplace workbench at 0.8.0"
else
    echo "  [FAIL] Claude marketplace workbench not at 0.8.0"
    exit 1
fi
echo ""

# Test 13: Old claude-md-management skill IDs are absent from SKILL.md and required-skills.md
echo "Test 13: Old claude-md-management skill IDs absent from autopilot files..."
RS="$SKILL_DIR/references/required-skills.md"
for old_id in 'claude-md-management:revise-claude-md' 'claude-md-management:claude-md-improver'; do
    if grep -qF "$old_id" "$SKILL_MD"; then
        echo "  [FAIL] SKILL.md still references $old_id (should have been swapped to agent-system-management)"
        exit 1
    else
        echo "  [PASS] SKILL.md does not reference $old_id"
    fi
    if grep -qF "$old_id" "$RS"; then
        echo "  [FAIL] required-skills.md still references $old_id (should have been swapped to agent-system-management)"
        exit 1
    else
        echo "  [PASS] required-skills.md does not reference $old_id"
    fi
done
echo ""

# Test 14: required-skills.md has Step 3 row for writing-spec
echo "Test 14: required-skills.md has Step 3 row for writing-spec..."
RS="$SKILL_DIR/references/required-skills.md"
if grep -qE '^\| 3 \| `workbench:writing-spec`' "$RS"; then
    echo "  [PASS] Step 3 row present in required-skills.md"
else
    echo "  [FAIL] Step 3 row missing in required-skills.md"
    exit 1
fi
if grep -qE '^\| 3 \| `workbench:writing-spec` \|$' "$SKILL_MD"; then
    echo "  [PASS] Step 3 row present in SKILL.md"
else
    echo "  [FAIL] Step 3 row missing in SKILL.md"
    exit 1
fi
echo ""

echo "=== Tests complete ==="
