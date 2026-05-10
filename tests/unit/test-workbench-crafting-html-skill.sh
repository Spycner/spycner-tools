#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="${PLUGIN_DIR:-plugins/workbench}"
SKILL_DIR="$PLUGIN_DIR/skills/crafting-html"
SKILL_MD="$SKILL_DIR/SKILL.md"
REFS_DIR="$SKILL_DIR/references"
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"

echo "Test 1: SKILL.md exists..."
[ -s "$SKILL_MD" ] || { echo "[FAIL] missing or empty SKILL.md"; exit 1; }
echo "[PASS]"

echo "Test 2: SKILL.md frontmatter has name=crafting-html..."
awk '/^---$/{c++; next} c==1' "$SKILL_MD" \
  | python3 -c "import sys,yaml; d=yaml.safe_load(sys.stdin); assert d['name']=='crafting-html'" \
  || { echo "[FAIL] frontmatter name mismatch"; exit 1; }
echo "[PASS]"

echo "Test 3: SKILL.md frontmatter has non-trivial description..."
awk '/^---$/{c++; next} c==1' "$SKILL_MD" \
  | python3 -c "import sys,yaml; d=yaml.safe_load(sys.stdin); assert 'description' in d and len(d['description']) > 100" \
  || { echo "[FAIL] description missing or too short"; exit 1; }
echo "[PASS]"

echo "Test 4: references/ contains exactly 21 files..."
count=$(ls "$REFS_DIR" | wc -l)
[ "$count" -eq 21 ] || { echo "[FAIL] expected 21 files, got $count"; exit 1; }
echo "[PASS]"

echo "Test 5: every reference file is non-empty and starts with <!DOCTYPE or <html..."
for f in "$REFS_DIR"/*.html; do
  [ -s "$f" ] || { echo "[FAIL] empty file: $f"; exit 1; }
  head -c 32 "$f" | grep -qiE '<!DOCTYPE|<html' || { echo "[FAIL] bad start: $f"; exit 1; }
done
echo "[PASS]"

echo "Test 6: skill tree free of U+2014 and U+2013..."
if grep -rqP '[\x{2014}\x{2013}]' "$SKILL_DIR"; then
  echo "[FAIL] em-dash or en-dash found in skill tree"
  grep -rnP '[\x{2014}\x{2013}]' "$SKILL_DIR" | head -5
  exit 1
fi
echo "[PASS]"

echo "Test 7: SKILL.md description mentions disjunction with frontend-design..."
grep -q 'frontend-design' "$SKILL_MD" || { echo "[FAIL] no frontend-design mention"; exit 1; }
echo "[PASS]"

echo "Test 8: SKILL.md lists each deferring skill..."
for skill in writing-spec writing-plans brainstorming systematic-debugging research; do
  grep -q "$skill" "$SKILL_MD" || { echo "[FAIL] missing skill mention: $skill"; exit 1; }
done
echo "[PASS]"

echo "Test 9: workbench plugin version pinned to 0.11.0..."
jq -e '.version == "0.11.0"' "$PLUGIN_JSON" > /dev/null \
  || { echo "[FAIL] workbench plugin.json not at 0.11.0"; exit 1; }
echo "[PASS]"

echo
echo "All tests passed."
