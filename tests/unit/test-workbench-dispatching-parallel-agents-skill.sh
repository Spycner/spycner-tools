#!/usr/bin/env bash
# Test: workbench:dispatching-parallel-agents skill structure
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/workbench/skills/dispatching-parallel-agents"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: workbench:dispatching-parallel-agents skill ==="

if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "[PASS] SKILL.md exists with frontmatter"
else
    echo "[FAIL] SKILL.md missing or no frontmatter"; exit 1
fi

for marker in \
    'Dispatching Parallel Agents' \
    'independent domains' \
    'disjoint write scopes' \
    'Do not use when' \
    'Codex' \
    'Claude Code'; do
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
    if grep -qF 'dispatching-parallel-agents' "$f"; then
        echo "[PASS] $f mentions dispatching-parallel-agents"
    else
        echo "[FAIL] $f missing dispatching-parallel-agents"; exit 1
    fi
done

USING="$REPO_ROOT/plugins/workbench/skills/using-workbench/SKILL.md"
if grep -qF 'workbench:dispatching-parallel-agents' "$USING"; then
    echo "[PASS] using-workbench routes dispatching-parallel-agents to workbench"
else
    echo "[FAIL] using-workbench missing dispatching-parallel-agents routing"; exit 1
fi

CCM="$REPO_ROOT/plugins/workbench/.claude-plugin/plugin.json"
CXM="$REPO_ROOT/plugins/workbench/.codex-plugin/plugin.json"
if jq -e '.version == "0.12.0"' "$CCM" >/dev/null && jq -e '.version == "0.12.0"' "$CXM" >/dev/null; then
    echo "[PASS] plugin manifests at 0.12.0"
else
    echo "[FAIL] plugin manifests not at 0.12.0"; exit 1
fi

MP="$REPO_ROOT/.claude-plugin/marketplace.json"
if jq -e '.plugins[] | select(.name == "workbench") | .version == "0.12.0"' "$MP" >/dev/null; then
    echo "[PASS] Claude marketplace workbench at 0.12.0"
else
    echo "[FAIL] Claude marketplace workbench not at 0.12.0"; exit 1
fi

echo "=== Tests complete ==="
