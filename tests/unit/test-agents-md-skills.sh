#!/usr/bin/env bash
# Test: agents-md-improver and agents-md-session-capture skills
# Verifies the skills load, mention both AGENTS.md and CLAUDE.md, include
# realpath dedup, the Platform Adaptation table, and reference docs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)/plugins/agents-md-management"

echo "=== Test: agents-md-management plugin structure ==="
echo ""

# Test 1: Plugin manifest files exist and parse
echo "Test 1: Plugin manifests exist and parse..."
if [ -f "$PLUGIN_ROOT/.claude-plugin/plugin.json" ] \
   && jq empty "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null; then
    echo "  [PASS] .claude-plugin/plugin.json exists and parses"
else
    echo "  [FAIL] .claude-plugin/plugin.json missing or malformed"
    exit 1
fi
if [ -f "$PLUGIN_ROOT/.codex-plugin/plugin.json" ] \
   && jq empty "$PLUGIN_ROOT/.codex-plugin/plugin.json" 2>/dev/null; then
    echo "  [PASS] .codex-plugin/plugin.json exists and parses"
else
    echo "  [FAIL] .codex-plugin/plugin.json missing or malformed"
    exit 1
fi
echo ""

# Test 2: Both skills' SKILL.md files exist
echo "Test 2: Skill files exist..."
for skill in agents-md-improver agents-md-session-capture; do
    if [ -f "$PLUGIN_ROOT/skills/$skill/SKILL.md" ]; then
        echo "  [PASS] skills/$skill/SKILL.md exists"
    else
        echo "  [FAIL] skills/$skill/SKILL.md missing"
        exit 1
    fi
done
echo ""

# Test 3: Reference docs exist and are non-empty
echo "Test 3: Reference docs exist..."
for ref in quality-criteria.md templates.md update-guidelines.md; do
    f="$PLUGIN_ROOT/skills/agents-md-improver/references/$ref"
    if [ -s "$f" ]; then
        echo "  [PASS] references/$ref exists"
    else
        echo "  [FAIL] references/$ref missing or empty"
        exit 1
    fi
done
echo ""

# Test 4: Both skill bodies mention AGENTS.md and CLAUDE.md
echo "Test 4: Both skill bodies mention AGENTS.md and CLAUDE.md..."
for skill in agents-md-improver agents-md-session-capture; do
    body="$(cat "$PLUGIN_ROOT/skills/$skill/SKILL.md")"
    if echo "$body" | grep -q 'AGENTS\.md' && echo "$body" | grep -q 'CLAUDE\.md'; then
        echo "  [PASS] $skill mentions both"
    else
        echo "  [FAIL] $skill missing one of AGENTS.md / CLAUDE.md"
        exit 1
    fi
done
echo ""

# Test 5: Both skill bodies mention realpath (dedup hint, embedded in shared discovery snippet)
echo "Test 5: Both skill bodies mention realpath..."
for skill in agents-md-improver agents-md-session-capture; do
    if grep -q 'realpath' "$PLUGIN_ROOT/skills/$skill/SKILL.md"; then
        echo "  [PASS] $skill mentions realpath"
    else
        echo "  [FAIL] $skill missing realpath dedup snippet"
        exit 1
    fi
done
echo ""

# Test 6: Both skill bodies include Platform Adaptation table
echo "Test 6: Both skill bodies have Platform Adaptation table..."
for skill in agents-md-improver agents-md-session-capture; do
    body="$(cat "$PLUGIN_ROOT/skills/$skill/SKILL.md")"
    if echo "$body" | grep -q '## Platform Adaptation' \
       && echo "$body" | grep -q 'Claude Code' \
       && echo "$body" | grep -q 'Codex'; then
        echo "  [PASS] $skill has Platform Adaptation table"
    else
        echo "  [FAIL] $skill missing Platform Adaptation table"
        exit 1
    fi
done
echo ""

# Test 7: agents-md-improver SKILL.md references the three reference docs by name
echo "Test 7: agents-md-improver references all three docs..."
body="$(cat "$PLUGIN_ROOT/skills/agents-md-improver/SKILL.md")"
for ref in quality-criteria.md templates.md update-guidelines.md; do
    if echo "$body" | grep -q "references/$ref"; then
        echo "  [PASS] references $ref"
    else
        echo "  [FAIL] missing reference to $ref"
        exit 1
    fi
done
echo ""

# Test 8: User-global memory files mentioned in both skill bodies
echo "Test 8: User-global files mentioned in both skill bodies..."
for skill in agents-md-improver agents-md-session-capture; do
    body="$(cat "$PLUGIN_ROOT/skills/$skill/SKILL.md")"
    if echo "$body" | grep -q '~/.claude/CLAUDE.md' \
       && echo "$body" | grep -q '~/.codex/AGENTS.md'; then
        echo "  [PASS] $skill includes both user-global paths"
    else
        echo "  [FAIL] $skill missing one or both user-global paths"
        exit 1
    fi
done
echo ""

# Test 9: Skill descriptions trigger on the right phrases
echo "Test 9: Description fields mention key trigger phrases..."
improver_body="$(cat "$PLUGIN_ROOT/skills/agents-md-improver/SKILL.md")"
capture_body="$(cat "$PLUGIN_ROOT/skills/agents-md-session-capture/SKILL.md")"

improver_desc=$(echo "$improver_body" | awk '/^description:/{flag=1;sub(/^description:[ ]*/,"")} /^---$/{flag=0} flag')
capture_desc=$(echo "$capture_body" | awk '/^description:/{flag=1;sub(/^description:[ ]*/,"")} /^---$/{flag=0} flag')

if echo "$improver_desc" | grep -qiE 'audit|improve|fix'; then
    echo "  [PASS] improver description mentions audit/improve/fix"
else
    echo "  [FAIL] improver description missing audit/improve/fix"
    exit 1
fi

if echo "$capture_desc" | grep -qiE 'session|learned|capture|revise'; then
    echo "  [PASS] capture description mentions session/learned/capture/revise"
else
    echo "  [FAIL] capture description missing session/learned/capture/revise"
    exit 1
fi

if echo "$capture_desc" | grep -q '/revise-claude-md' \
   && echo "$capture_desc" | grep -q '/revise-agents-md'; then
    echo "  [PASS] capture description mentions both legacy and new slash forms"
else
    echo "  [FAIL] capture description missing one of the slash forms"
    exit 1
fi
echo ""

echo "=== Tests complete ==="
