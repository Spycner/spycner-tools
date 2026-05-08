#!/usr/bin/env bash
# Test: agent-system-management:creating-skills skill structure
# Verifies SKILL.md exists, frontmatter is valid, all five mode sections are present,
# four reference files plus the templates/ subdirectory exist and are non-empty,
# plugin manifests are at 0.4.2, and the skill mentions marketplace detection plus
# the three SKILL.md template types.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PLUGIN_ROOT="$REPO_ROOT/plugins/agent-system-management"
SKILL_DIR="$PLUGIN_ROOT/skills/creating-skills"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: agent-system-management:creating-skills skill structure ==="
echo ""

# Test 1: Plugin manifests exist, parse, and are at 0.4.2
echo "Test 1: Plugin manifests at 0.4.2..."
for manifest in .claude-plugin/plugin.json .codex-plugin/plugin.json; do
    f="$PLUGIN_ROOT/$manifest"
    if [ ! -f "$f" ]; then
        echo "  [FAIL] $manifest missing"
        exit 1
    fi
    if ! jq empty "$f" 2>/dev/null; then
        echo "  [FAIL] $manifest malformed JSON"
        exit 1
    fi
    version=$(jq -r .version "$f")
    if [ "$version" != "0.4.2" ]; then
        echo "  [FAIL] $manifest version is $version, expected 0.4.2"
        exit 1
    fi
    echo "  [PASS] $manifest exists, parses, version 0.4.2"
done
echo ""

# Test 2: Codex manifest has skills field and full interface block
echo "Test 2: Codex manifest is well-formed..."
CODEX="$PLUGIN_ROOT/.codex-plugin/plugin.json"
if [ "$(jq -r .skills "$CODEX")" != "./skills/" ]; then
    echo "  [FAIL] Codex manifest skills field missing or wrong"
    exit 1
fi
echo "  [PASS] skills field is ./skills/"
for field in displayName shortDescription longDescription developerName category capabilities defaultPrompt; do
    if [ "$(jq -r ".interface.$field" "$CODEX")" = "null" ]; then
        echo "  [FAIL] Codex manifest interface.$field missing"
        exit 1
    fi
    echo "  [PASS] interface.$field present"
done
echo ""

# Test 3: SKILL.md exists with valid frontmatter
echo "Test 3: SKILL.md exists with frontmatter..."
if [ ! -s "$SKILL_MD" ]; then
    echo "  [FAIL] SKILL.md missing or empty"
    exit 1
fi
if ! head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "  [FAIL] SKILL.md missing frontmatter delimiter"
    exit 1
fi
if ! grep -q '^name: creating-skills$' "$SKILL_MD"; then
    echo "  [FAIL] SKILL.md missing or wrong name field"
    exit 1
fi
if ! grep -q '^description:' "$SKILL_MD"; then
    echo "  [FAIL] SKILL.md missing description field"
    exit 1
fi
echo "  [PASS] SKILL.md exists with valid frontmatter"
echo ""

# Test 4: All four reference files plus the templates directory exist and are non-empty
echo "Test 4: Reference files exist..."
for ref in test-patterns iteration-loop pressure-testing description-optimization; do
    f="$SKILL_DIR/references/$ref.md"
    if [ ! -s "$f" ]; then
        echo "  [FAIL] references/$ref.md missing or empty"
        exit 1
    fi
    echo "  [PASS] references/$ref.md exists"
done
TEMPLATES_DIR="$SKILL_DIR/references/templates"
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "  [FAIL] references/templates/ directory missing"
    exit 1
fi
for tpl in README skill-bodies manifests marketplace-entries index-doc-rows tests; do
    f="$TEMPLATES_DIR/$tpl.md"
    if [ ! -s "$f" ]; then
        echo "  [FAIL] references/templates/$tpl.md missing or empty"
        exit 1
    fi
    echo "  [PASS] references/templates/$tpl.md exists"
done
echo ""

# Test 5: SKILL.md mentions every reference file plus the templates directory
echo "Test 5: SKILL.md mentions every reference..."
for ref in test-patterns iteration-loop pressure-testing description-optimization; do
    if grep -qF "references/$ref.md" "$SKILL_MD"; then
        echo "  [PASS] SKILL.md mentions $ref.md"
    else
        echo "  [FAIL] SKILL.md missing reference to $ref.md"
        exit 1
    fi
done
if grep -qF "references/templates/" "$SKILL_MD"; then
    echo "  [PASS] SKILL.md mentions references/templates/"
else
    echo "  [FAIL] SKILL.md missing reference to references/templates/"
    exit 1
fi
echo ""

# Test 6: SKILL.md surfaces all five lifecycle modes
echo "Test 6: SKILL.md surfaces all five modes..."
for mode in 'Mode A' 'Mode B' 'Mode C' 'Mode D' 'Mode E'; do
    if grep -qF "$mode" "$SKILL_MD"; then
        echo "  [PASS] SKILL.md has $mode heading"
    else
        echo "  [FAIL] SKILL.md missing $mode heading"
        exit 1
    fi
done
for keyword in scaffold iterate pressure-test 'optimize description' extract; do
    if grep -qiF "$keyword" "$SKILL_MD"; then
        echo "  [PASS] SKILL.md mentions $keyword"
    else
        echo "  [FAIL] SKILL.md missing $keyword"
        exit 1
    fi
done
echo ""

# Test 7: SKILL.md mentions marketplace detection
echo "Test 7: SKILL.md mentions marketplace detection..."
for term in '.claude-plugin/marketplace.json' '.agents/plugins/marketplace.json'; do
    if grep -qF "$term" "$SKILL_MD"; then
        echo "  [PASS] SKILL.md mentions $term"
    else
        echo "  [FAIL] SKILL.md missing $term"
        exit 1
    fi
done
echo ""

# Test 8: SKILL.md mentions the three SKILL.md template types
echo "Test 8: SKILL.md mentions three template types..."
for kind in 'api' 'workflow' 'reference'; do
    if grep -qiE "$kind" "$SKILL_MD"; then
        echo "  [PASS] SKILL.md mentions $kind template"
    else
        echo "  [FAIL] SKILL.md missing $kind template type"
        exit 1
    fi
done
echo ""

# Test 9: SKILL.md description includes specific trigger keywords
echo "Test 9: Description has triggers..."
desc=$(awk '/^description:/{flag=1;sub(/^description:[ ]*/,"")} /^---$/{flag=0} flag' "$SKILL_MD")
if echo "$desc" | grep -qiE 'scaffold|iterat|pressure|optim|extract'; then
    echo "  [PASS] description mentions lifecycle verbs"
else
    echo "  [FAIL] description missing lifecycle verbs"
    exit 1
fi
if echo "$desc" | grep -qi 'marketplace'; then
    echo "  [PASS] description mentions marketplace"
else
    echo "  [FAIL] description missing marketplace context"
    exit 1
fi
echo ""

# Test 10: SKILL.md no em-dashes (project rule)
echo "Test 10: No em-dashes in SKILL.md..."
if grep -nP '[\x{2014}\x{2013}]' "$SKILL_MD"; then
    echo "  [FAIL] em-dashes found in SKILL.md"
    exit 1
fi
echo "  [PASS] no em-dashes in SKILL.md"
for ref in test-patterns iteration-loop pressure-testing description-optimization; do
    f="$SKILL_DIR/references/$ref.md"
    if grep -nP '[\x{2014}\x{2013}]' "$f"; then
        echo "  [FAIL] em-dashes found in references/$ref.md"
        exit 1
    fi
    echo "  [PASS] no em-dashes in references/$ref.md"
done
while IFS= read -r f; do
    if grep -nP '[\x{2014}\x{2013}]' "$f"; then
        echo "  [FAIL] em-dashes found in $f"
        exit 1
    fi
    echo "  [PASS] no em-dashes in ${f#$SKILL_DIR/}"
done < <(find "$SKILL_DIR/references/templates" -name '*.md')
echo ""

# Test 11: Marketplace registration in both files
echo "Test 11: Marketplace registration..."
for mkt in .claude-plugin/marketplace.json .agents/plugins/marketplace.json; do
    if jq -r '.plugins[].name' "$REPO_ROOT/$mkt" | grep -q '^agent-system-management$'; then
        echo "  [PASS] $mkt registers agent-system-management"
    else
        echo "  [FAIL] $mkt does not register agent-system-management"
        exit 1
    fi
done
echo ""

# Test 12: Version bump invariant is explicit
echo "Test 12: Version bump invariant..."
if grep -qF 'Version bump required for every plugin change' "$SKILL_MD"; then
    echo "  [PASS] SKILL.md requires plugin version bumps"
else
    echo "  [FAIL] SKILL.md missing version bump invariant"
    exit 1
fi
if grep -qF 'Every plugin change bumps version' "$REPO_ROOT/AGENTS.md"; then
    echo "  [PASS] AGENTS.md requires plugin version bumps"
else
    echo "  [FAIL] AGENTS.md missing plugin version bump rule"
    exit 1
fi
if jq -e '.plugins[] | select(.name == "agent-system-management") | .version == "0.4.2"' "$REPO_ROOT/.claude-plugin/marketplace.json" >/dev/null; then
    echo "  [PASS] Claude marketplace agent-system-management at 0.4.2"
else
    echo "  [FAIL] Claude marketplace agent-system-management not at 0.4.2"
    exit 1
fi
echo ""

echo "=== Tests complete ==="
