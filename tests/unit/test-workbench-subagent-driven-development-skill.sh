#!/usr/bin/env bash
# Test: workbench:subagent-driven-development skill structure
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/workbench/skills/subagent-driven-development"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: workbench:subagent-driven-development skill ==="

if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "[PASS] SKILL.md exists with frontmatter"
else
    echo "[FAIL] SKILL.md missing or no frontmatter"; exit 1
fi

for marker in \
    'Subagent-Driven Development' \
    'Two review gates' \
    'Implementation agent prompt' \
    'Spec compliance reviewer' \
    'Code quality reviewer' \
    'workbench:dispatching-parallel-agents' \
    'workbench:test-driven-development'; do
    if grep -qF "$marker" "$SKILL_MD"; then
        echo "[PASS] body mentions $marker"
    else
        echo "[FAIL] body missing $marker"; exit 1
    fi
done

if grep -qP '[\x{2013}\x{2014}]' "$SKILL_MD"; then
    echo "[FAIL] em-dash or en-dash in SKILL.md"; exit 1
else
    echo "[PASS] no em or en-dash"
fi

for f in \
    "$REPO_ROOT/plugins/workbench/README.md" \
    "$REPO_ROOT/README.md" \
    "$REPO_ROOT/plugins/workbench/NOTICE"; do
    if grep -qF 'subagent-driven-development' "$f"; then
        echo "[PASS] $f mentions subagent-driven-development"
    else
        echo "[FAIL] $f missing subagent-driven-development"; exit 1
    fi
done

USING="$REPO_ROOT/plugins/workbench/skills/using-workbench/SKILL.md"
if grep -qF 'workbench:subagent-driven-development' "$USING"; then
    echo "[PASS] using-workbench routes subagent-driven-development to workbench"
else
    echo "[FAIL] using-workbench missing subagent-driven-development routing"; exit 1
fi

AUTO="$REPO_ROOT/plugins/workbench/skills/autopilot/SKILL.md"
RS="$REPO_ROOT/plugins/workbench/skills/autopilot/references/required-skills.md"
for f in "$AUTO" "$RS"; do
    if grep -qF 'workbench:subagent-driven-development' "$f"; then
        echo "[PASS] $(basename "$f") mentions workbench:subagent-driven-development"
    else
        echo "[FAIL] $(basename "$f") missing workbench:subagent-driven-development"; exit 1
    fi
    if grep -qF 'superpowers:subagent-driven-development' "$f"; then
        echo "[FAIL] $(basename "$f") still references superpowers:subagent-driven-development"; exit 1
    else
        echo "[PASS] $(basename "$f") does not reference superpowers:subagent-driven-development"
    fi
done

CCM="$REPO_ROOT/plugins/workbench/.claude-plugin/plugin.json"
CXM="$REPO_ROOT/plugins/workbench/.codex-plugin/plugin.json"
if jq -e '.version == "0.14.0"' "$CCM" >/dev/null && jq -e '.version == "0.14.0"' "$CXM" >/dev/null; then
    echo "[PASS] plugin manifests at 0.14.0"
else
    echo "[FAIL] plugin manifests not at 0.14.0"; exit 1
fi

MP="$REPO_ROOT/.claude-plugin/marketplace.json"
if jq -e '.plugins[] | select(.name == "workbench") | .version == "0.14.0"' "$MP" >/dev/null; then
    echo "[PASS] Claude marketplace workbench at 0.14.0"
else
    echo "[FAIL] Claude marketplace workbench not at 0.14.0"; exit 1
fi

echo "=== Tests complete ==="
