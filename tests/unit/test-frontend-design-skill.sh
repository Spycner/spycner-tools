#!/usr/bin/env bash
# Test: frontend-design:frontend-design skill structure
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/frontend-design/skills/frontend-design"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: frontend-design:frontend-design skill ==="

if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "[PASS] SKILL.md exists with frontmatter"
else
    echo "[FAIL] SKILL.md missing or no frontmatter"; exit 1
fi

for marker in \
    'name: frontend-design' \
    'Design Thinking' \
    'Frontend Aesthetics Guidelines' \
    'NEVER use generic AI-generated aesthetics' \
    'Match implementation complexity to the aesthetic vision' \
    'Bold maximalism and refined minimalism both work'; do
    if grep -qF "$marker" "$SKILL_MD"; then
        echo "[PASS] body mentions $marker"
    else
        echo "[FAIL] body missing $marker"; exit 1
    fi
done

if find "$SKILL_DIR" -type f ! -name 'SKILL.md' | grep -q .; then
    echo "[FAIL] frontend-design skill should not bundle helper scripts"; exit 1
else
    echo "[PASS] frontend-design skill has no helper scripts"
fi

if grep -qP '[\x{2013}\x{2014}]' \
    "$SKILL_MD" \
    "$REPO_ROOT/plugins/frontend-design/README.md" \
    "$REPO_ROOT/plugins/frontend-design/NOTICE"; then
    echo "[FAIL] U+2014 or U+2013 in frontend-design markdown"; exit 1
else
    echo "[PASS] no U+2014 or U+2013"
fi

for f in \
    "$REPO_ROOT/plugins/frontend-design/README.md" \
    "$REPO_ROOT/README.md" \
    "$REPO_ROOT/AGENTS.md"; do
    if grep -qF 'frontend-design' "$f"; then
        echo "[PASS] $f mentions frontend-design"
    else
        echo "[FAIL] $f missing frontend-design"; exit 1
    fi
done

NOTICE="$REPO_ROOT/plugins/frontend-design/NOTICE"
if grep -qF 'Apache License' "$NOTICE" && grep -qF 'github.com/anthropics/claude-plugins' "$NOTICE"; then
    echo "[PASS] NOTICE references upstream Apache 2.0"
else
    echo "[FAIL] NOTICE missing Apache 2.0 attribution"; exit 1
fi

for manifest in \
    "$REPO_ROOT/plugins/frontend-design/.claude-plugin/plugin.json" \
    "$REPO_ROOT/plugins/frontend-design/.codex-plugin/plugin.json"; do
    if jq -e '.name == "frontend-design" and .version == "0.1.0" and .license == "MIT"' "$manifest" >/dev/null; then
        echo "[PASS] $manifest metadata is valid"
    else
        echo "[FAIL] $manifest metadata invalid"; exit 1
    fi
done

echo "=== Tests complete ==="
