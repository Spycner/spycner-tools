#!/usr/bin/env bash
# Test: playground:playground skill structure
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/plugins/playground"
SKILL_DIR="$PLUGIN_DIR/skills/playground"
SKILL_MD="$SKILL_DIR/SKILL.md"
TEMPLATES_DIR="$SKILL_DIR/templates"

echo "=== Test: playground:playground skill ==="

if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "[PASS] SKILL.md exists with frontmatter"
else
    echo "[FAIL] SKILL.md missing or no frontmatter"; exit 1
fi

for marker in \
    'name: playground' \
    'Playground Builder' \
    'Single HTML file' \
    'Live preview' \
    'Prompt output' \
    'Copy button' \
    'Dark theme' \
    'State management pattern' \
    'Common mistakes to avoid'; do
    if grep -qF "$marker" "$SKILL_MD"; then
        echo "[PASS] body mentions $marker"
    else
        echo "[FAIL] body missing $marker"; exit 1
    fi
done

for tmpl in code-map concept-map data-explorer design-playground diff-review document-critique; do
    if grep -qF "templates/${tmpl}.md" "$SKILL_MD"; then
        echo "[PASS] SKILL.md references templates/${tmpl}.md"
    else
        echo "[FAIL] SKILL.md missing reference to templates/${tmpl}.md"; exit 1
    fi
done

if [ -d "$TEMPLATES_DIR" ]; then
    template_count=$(find "$TEMPLATES_DIR" -maxdepth 1 -type f -name '*.md' | wc -l)
    if [ "$template_count" -eq 6 ]; then
        echo "[PASS] templates/ contains exactly 6 files"
    else
        echo "[FAIL] templates/ should contain 6 files, found $template_count"; exit 1
    fi
else
    echo "[FAIL] templates/ directory missing"; exit 1
fi

for tmpl in code-map concept-map data-explorer design-playground diff-review document-critique; do
    if [ -s "$TEMPLATES_DIR/${tmpl}.md" ]; then
        echo "[PASS] template ${tmpl}.md present and non-empty"
    else
        echo "[FAIL] template ${tmpl}.md missing or empty"; exit 1
    fi
done

LINT_FILES=(
    "$SKILL_MD"
    "$PLUGIN_DIR/README.md"
    "$PLUGIN_DIR/NOTICE"
)
for tmpl in code-map concept-map data-explorer design-playground diff-review document-critique; do
    LINT_FILES+=("$TEMPLATES_DIR/${tmpl}.md")
done

if grep -qP '[\x{2013}\x{2014}]' "${LINT_FILES[@]}"; then
    echo "[FAIL] U+2014 or U+2013 in playground markdown"
    grep -lP '[\x{2013}\x{2014}]' "${LINT_FILES[@]}" >&2
    exit 1
else
    echo "[PASS] no U+2014 or U+2013"
fi

for f in \
    "$PLUGIN_DIR/README.md" \
    "$REPO_ROOT/README.md" \
    "$REPO_ROOT/AGENTS.md"; do
    if grep -qF 'playground' "$f"; then
        echo "[PASS] $f mentions playground"
    else
        echo "[FAIL] $f missing playground"; exit 1
    fi
done

NOTICE="$PLUGIN_DIR/NOTICE"
if grep -qF 'Apache License' "$NOTICE" && grep -qF 'github.com/anthropics/claude-plugins-official' "$NOTICE"; then
    echo "[PASS] NOTICE references upstream Apache 2.0"
else
    echo "[FAIL] NOTICE missing Apache 2.0 attribution"; exit 1
fi

for manifest in \
    "$PLUGIN_DIR/.claude-plugin/plugin.json" \
    "$PLUGIN_DIR/.codex-plugin/plugin.json"; do
    if jq -e '.name == "playground" and .version == "0.1.0" and .license == "MIT"' "$manifest" >/dev/null; then
        echo "[PASS] $manifest metadata is valid"
    else
        echo "[FAIL] $manifest metadata invalid"; exit 1
    fi
done

if jq -e '.skills == "./skills/" and (.interface.displayName | length > 0)' \
    "$PLUGIN_DIR/.codex-plugin/plugin.json" >/dev/null; then
    echo "[PASS] codex manifest has skills path and interface.displayName"
else
    echo "[FAIL] codex manifest missing skills path or interface.displayName"; exit 1
fi

echo "=== Tests complete ==="
