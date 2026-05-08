#!/usr/bin/env bash
# Test: workbench:test-driven-development skill structure
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/workbench/skills/test-driven-development"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: workbench:test-driven-development skill ==="

if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "[PASS] SKILL.md exists with frontmatter"
else
    echo "[FAIL] SKILL.md missing or no frontmatter"; exit 1
fi

for marker in \
    'NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST' \
    'Red-Green-Refactor' \
    'Verify RED' \
    'Verify GREEN' \
    'Common Rationalizations' \
    'workbench'; do
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

if grep -qF 'test-driven-development' "$REPO_ROOT/plugins/workbench/README.md"; then
    echo "[PASS] README lists test-driven-development"
else
    echo "[FAIL] README missing test-driven-development"; exit 1
fi

if grep -qF 'skills/test-driven-development/SKILL.md' "$REPO_ROOT/plugins/workbench/NOTICE"; then
    echo "[PASS] NOTICE credits test-driven-development"
else
    echo "[FAIL] NOTICE missing test-driven-development"; exit 1
fi

USING="$REPO_ROOT/plugins/workbench/skills/using-workbench/SKILL.md"
if grep -qF 'workbench:test-driven-development' "$USING"; then
    echo "[PASS] using-workbench routes bare test-driven-development to workbench"
else
    echo "[FAIL] using-workbench missing test-driven-development routing"; exit 1
fi

AUTO="$REPO_ROOT/plugins/workbench/skills/autopilot/SKILL.md"
RS="$REPO_ROOT/plugins/workbench/skills/autopilot/references/required-skills.md"
for f in "$AUTO" "$RS"; do
    if grep -qF 'workbench:test-driven-development' "$f"; then
        echo "[PASS] $(basename "$f") mentions workbench:test-driven-development"
    else
        echo "[FAIL] $(basename "$f") missing workbench:test-driven-development"; exit 1
    fi
done

CCM="$REPO_ROOT/plugins/workbench/.claude-plugin/plugin.json"
CXM="$REPO_ROOT/plugins/workbench/.codex-plugin/plugin.json"
if jq -e '.version == "0.10.0"' "$CCM" >/dev/null && jq -e '.version == "0.10.0"' "$CXM" >/dev/null; then
    echo "[PASS] plugin manifests at 0.10.0"
else
    echo "[FAIL] plugin manifests not at 0.10.0"; exit 1
fi

MP="$REPO_ROOT/.claude-plugin/marketplace.json"
if jq -e '.plugins[] | select(.name == "workbench") | .version == "0.10.0"' "$MP" >/dev/null; then
    echo "[PASS] Claude marketplace workbench at 0.10.0"
else
    echo "[FAIL] Claude marketplace workbench not at 0.10.0"; exit 1
fi

echo "=== Tests complete ==="
