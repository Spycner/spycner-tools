#!/usr/bin/env bash
# Test: terminal:tmux skill structure
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/terminal/skills/tmux"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: terminal:tmux skill ==="

if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "[PASS] SKILL.md exists with frontmatter"
else
    echo "[FAIL] SKILL.md missing or no frontmatter"; exit 1
fi

for marker in \
    'name: tmux' \
    'interactive terminal programs' \
    'tmux -S "$SOCKET"' \
    'capture-pane -p -J' \
    'send-keys -l --' \
    'Steering Agent Sessions' \
    'codex' \
    'claude' \
    'Native Windows terminals are out of scope' \
    'Do not add helper scripts'; do
    if grep -qF "$marker" "$SKILL_MD"; then
        echo "[PASS] body mentions $marker"
    else
        echo "[FAIL] body missing $marker"; exit 1
    fi
done

if find "$SKILL_DIR" -type f ! -name 'SKILL.md' | grep -q .; then
    echo "[FAIL] tmux skill should not bundle helper scripts"; exit 1
else
    echo "[PASS] tmux skill has no helper scripts"
fi

if grep -qP '[\x{2013}\x{2014}]' "$SKILL_MD" "$REPO_ROOT/plugins/terminal/README.md" "$REPO_ROOT/plugins/terminal/NOTICE"; then
    echo "[FAIL] U+2014 or U+2013 in terminal markdown"; exit 1
else
    echo "[PASS] no U+2014 or U+2013"
fi

for f in \
    "$REPO_ROOT/plugins/terminal/README.md" \
    "$REPO_ROOT/README.md" \
    "$REPO_ROOT/AGENTS.md"; do
    if grep -qF 'tmux' "$f"; then
        echo "[PASS] $f mentions tmux"
    else
        echo "[FAIL] $f missing tmux"; exit 1
    fi
done

for manifest in \
    "$REPO_ROOT/plugins/terminal/.claude-plugin/plugin.json" \
    "$REPO_ROOT/plugins/terminal/.codex-plugin/plugin.json"; do
    if jq -e '.name == "terminal" and .version == "0.1.0" and .license == "Apache-2.0"' "$manifest" >/dev/null; then
        echo "[PASS] $manifest metadata is valid"
    else
        echo "[FAIL] $manifest metadata invalid"; exit 1
    fi
done

echo "=== Tests complete ==="
