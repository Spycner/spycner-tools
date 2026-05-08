#!/usr/bin/env bash
# Test: frontend-design plugin's emil-design-eng skill structure
# Verifies the port of emilkowalski/skill: SKILL.md exists with all expected
# headings, no em-dashes/en-dashes, animations.dev attribution preserved,
# NOTICE attributes the upstream, plugin manifests bumped to 0.2.0.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PLUGIN_DIR="${PLUGIN_DIR:-$REPO_ROOT/plugins/frontend-design}"
SKILL_DIR="$PLUGIN_DIR/skills/emil-design-eng"
SKILL_MD="$SKILL_DIR/SKILL.md"
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
CODEX_PLUGIN_JSON="$PLUGIN_DIR/.codex-plugin/plugin.json"
NOTICE_FILE="$PLUGIN_DIR/NOTICE"
README_FILE="$PLUGIN_DIR/README.md"
MARKETPLACE="$REPO_ROOT/.claude-plugin/marketplace.json"

echo "=== Test: frontend-design emil-design-eng skill structure ==="
echo ""

# Test 1: Plugin manifests bumped to 0.2.0
echo "Test 1: Plugin manifests at 0.2.0..."
if jq -e '.version == "0.2.0"' "$PLUGIN_JSON" >/dev/null; then
    echo "  [PASS] Claude manifest at 0.2.0"
else
    echo "  [FAIL] Claude manifest not at 0.2.0"
    exit 1
fi
if jq -e '.version == "0.2.0"' "$CODEX_PLUGIN_JSON" >/dev/null; then
    echo "  [PASS] Codex manifest at 0.2.0"
else
    echo "  [FAIL] Codex manifest not at 0.2.0"
    exit 1
fi
echo ""

# Test 2: Marketplace entry bumped
echo "Test 2: Claude marketplace frontend-design entry at 0.2.0..."
if jq -e '.plugins[] | select(.name == "frontend-design") | .version == "0.2.0"' "$MARKETPLACE" >/dev/null; then
    echo "  [PASS] Claude marketplace frontend-design at 0.2.0"
else
    echo "  [FAIL] Claude marketplace frontend-design not at 0.2.0"
    exit 1
fi
echo ""

# Test 3: SKILL.md exists with frontmatter
echo "Test 3: SKILL.md exists with frontmatter..."
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

# Test 4: Frontmatter name is emil-design-eng
echo "Test 4: Frontmatter name is emil-design-eng..."
if head -10 "$SKILL_MD" | grep -q '^name: emil-design-eng$'; then
    echo "  [PASS] frontmatter name is emil-design-eng"
else
    echo "  [FAIL] frontmatter name is not emil-design-eng"
    exit 1
fi
echo ""

# Test 5: Frontmatter description is non-empty
echo "Test 5: Frontmatter description present..."
if head -10 "$SKILL_MD" | grep -q '^description: .'; then
    echo "  [PASS] frontmatter description present"
else
    echo "  [FAIL] frontmatter description missing or empty"
    exit 1
fi
echo ""

# Test 6: All required body headings
echo "Test 6: All required body headings..."
required_headings=(
    '## Initial Response'
    '## Core Philosophy'
    '## Review Format (Required)'
    '## The Animation Decision Framework'
    '## Spring Animations'
    '## Component Building Principles'
    '## CSS Transform Mastery'
    '## clip-path for Animation'
    '## Gesture and Drag Interactions'
    '## Performance Rules'
    '## Accessibility'
    '## The Sonner Principles (Building Loved Components)'
    '## Stagger Animations'
    '## Debugging Animations'
    '## Review Checklist'
)
for heading in "${required_headings[@]}"; do
    if grep -qF "$heading" "$SKILL_MD"; then
        echo "  [PASS] heading present: $heading"
    else
        echo "  [FAIL] heading missing: $heading"
        exit 1
    fi
done
echo ""

# Test 7: No em-dashes (U+2014) or en-dashes (U+2013)
echo "Test 7: SKILL.md free of em-dashes and en-dashes..."
if grep -qP '[\x{2014}\x{2013}]' "$SKILL_MD"; then
    echo "  [FAIL] SKILL.md contains em-dashes or en-dashes"
    grep -nP '[\x{2014}\x{2013}]' "$SKILL_MD" | head -5
    exit 1
else
    echo "  [PASS] no em-dashes or en-dashes"
fi
echo ""

# Test 8: animations.dev link preserved
echo "Test 8: animations.dev attribution preserved..."
if grep -qF 'animations.dev' "$SKILL_MD"; then
    echo "  [PASS] animations.dev link present"
else
    echo "  [FAIL] animations.dev link missing from Initial Response"
    exit 1
fi
echo ""

# Test 9: NOTICE attributes emilkowalski/skill
echo "Test 9: NOTICE attributes emilkowalski/skill..."
if grep -qF 'emilkowalski/skill' "$NOTICE_FILE"; then
    echo "  [PASS] NOTICE includes emilkowalski/skill attribution"
else
    echo "  [FAIL] NOTICE missing emilkowalski/skill attribution"
    exit 1
fi
echo ""

# Test 10: Plugin README mentions both skills
echo "Test 10: Plugin README mentions both skills..."
if grep -qF 'frontend-design' "$README_FILE"; then
    echo "  [PASS] plugin README mentions frontend-design"
else
    echo "  [FAIL] plugin README missing frontend-design"
    exit 1
fi
if grep -qF 'emil-design-eng' "$README_FILE"; then
    echo "  [PASS] plugin README mentions emil-design-eng"
else
    echo "  [FAIL] plugin README missing emil-design-eng"
    exit 1
fi
echo ""

echo "=== Tests complete ==="
