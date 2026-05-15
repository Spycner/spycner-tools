#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="${PLUGIN_DIR:-plugins/workbench}"
SKILL_DIR="$PLUGIN_DIR/skills/crafting-design-systems"
SKILL_MD="$SKILL_DIR/SKILL.md"
REFS_DIR="$SKILL_DIR/references"
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"

echo "Test 1: SKILL.md exists..."
[ -s "$SKILL_MD" ] || { echo "[FAIL] missing or empty SKILL.md"; exit 1; }
echo "[PASS]"

echo "Test 2: SKILL.md frontmatter has name=crafting-design-systems..."
awk '/^---$/{c++; next} c==1' "$SKILL_MD" \
  | python3 -c "import sys,yaml; d=yaml.safe_load(sys.stdin); assert d['name']=='crafting-design-systems'" \
  || { echo "[FAIL] frontmatter name mismatch"; exit 1; }
echo "[PASS]"

echo "Test 3: SKILL.md frontmatter has non-trivial description..."
awk '/^---$/{c++; next} c==1' "$SKILL_MD" \
  | python3 -c "import sys,yaml; d=yaml.safe_load(sys.stdin); assert 'description' in d and len(d['description']) > 100" \
  || { echo "[FAIL] description missing or too short"; exit 1; }
echo "[PASS]"

echo "Test 4: references/ contains starter-colors.css and example-design-system/..."
[ -s "$REFS_DIR/starter-colors.css" ] || { echo "[FAIL] missing starter-colors.css"; exit 1; }
[ -s "$REFS_DIR/example-design-system/manifest.md" ] || { echo "[FAIL] missing example manifest.md"; exit 1; }
[ -s "$REFS_DIR/example-design-system/colors.css" ] || { echo "[FAIL] missing example colors.css"; exit 1; }
echo "[PASS]"

echo "Test 5: starter-colors.css declares variables from each template family..."
for var in '--ivory' '--bg' '--ink' '--accent'; do
  grep -q -- "$var" "$REFS_DIR/starter-colors.css" \
    || { echo "[FAIL] starter-colors.css missing $var"; exit 1; }
done
echo "[PASS]"

echo "Test 6: SKILL.md mentions all six consuming skills..."
for skill in writing-spec writing-plans brainstorming systematic-debugging research crafting-html; do
  grep -q "$skill" "$SKILL_MD" || { echo "[FAIL] missing skill mention: $skill"; exit 1; }
done
echo "[PASS]"

echo "Test 7: SKILL.md mentions both scope paths..."
grep -q '\.workbench/design-systems/' "$SKILL_MD" \
  || { echo "[FAIL] missing project-scope path"; exit 1; }
grep -q '~/\.claude/workbench/design-systems/' "$SKILL_MD" \
  || { echo "[FAIL] missing user-scope path"; exit 1; }
echo "[PASS]"

echo "Test 8: SKILL.md includes per-template variable inventory section..."
grep -q '^## Per-template variable inventory' "$SKILL_MD" \
  || { echo "[FAIL] missing per-template inventory section heading"; exit 1; }
echo "[PASS]"

echo "Test 9: skill tree free of U+2014 and U+2013..."
if grep -rqP '[\x{2014}\x{2013}]' "$SKILL_DIR"; then
  echo "[FAIL] em-dash or en-dash found in skill tree"
  grep -rnP '[\x{2014}\x{2013}]' "$SKILL_DIR" | head -5
  exit 1
fi
echo "[PASS]"

echo "Test 10: workbench plugin version pinned to 0.14.0..."
jq -e '.version == "0.14.0"' "$PLUGIN_JSON" > /dev/null \
  || { echo "[FAIL] workbench plugin.json not at 0.14.0"; exit 1; }
echo "[PASS]"

echo
echo "All tests passed."
