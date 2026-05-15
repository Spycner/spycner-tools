#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="${PLUGIN_DIR:-plugins/workbench}"
SKILL_DIR="$PLUGIN_DIR/skills/crafting-presentations"
SKILL_MD="$SKILL_DIR/SKILL.md"
REFS_ROOT="$SKILL_DIR/references"
EXAMPLE_DIR="$REFS_ROOT/deloitte-databricks-alliance"
SLIDES_DIR="$EXAMPLE_DIR/slides"
ASSETS_DIR="$EXAMPLE_DIR/assets"
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"

echo "Test 1: SKILL.md exists..."
[ -s "$SKILL_MD" ] || { echo "[FAIL] missing or empty SKILL.md"; exit 1; }
echo "[PASS]"

echo "Test 2: SKILL.md frontmatter has name=crafting-presentations..."
awk '/^---$/{c++; next} c==1' "$SKILL_MD" \
  | python3 -c "import sys,yaml; d=yaml.safe_load(sys.stdin); assert d['name']=='crafting-presentations'" \
  || { echo "[FAIL] frontmatter name mismatch"; exit 1; }
echo "[PASS]"

echo "Test 3: SKILL.md frontmatter has non-trivial description..."
awk '/^---$/{c++; next} c==1' "$SKILL_MD" \
  | python3 -c "import sys,yaml; d=yaml.safe_load(sys.stdin); assert 'description' in d and len(d['description']) > 100" \
  || { echo "[FAIL] description missing or too short"; exit 1; }
echo "[PASS]"

echo "Test 4: SKILL.md mentions cross-reference skills..."
for token in crafting-html crafting-design-systems; do
  grep -q "$token" "$SKILL_MD" || { echo "[FAIL] missing cross-reference: $token"; exit 1; }
done
echo "[PASS]"

echo "Test 5: SKILL.md mentions the bundled example by name..."
grep -q 'deloitte-databricks-alliance' "$SKILL_MD" || { echo "[FAIL] missing example reference"; exit 1; }
echo "[PASS]"

echo "Test 6: SKILL.md catalog references every slide-type template..."
for tpl in TitleSlide SectionDivider AgendaSlide ContentSlide StatSlide CapabilitiesSlide ComparisonSlide QuoteSlide TimelineSlide ClosingSlide; do
  grep -q "$tpl" "$SKILL_MD" || { echo "[FAIL] missing slide type: $tpl"; exit 1; }
done
echo "[PASS]"

echo "Test 7: SKILL.md mentions presenter mode..."
grep -qi 'presenter' "$SKILL_MD" || { echo "[FAIL] presenter mode not documented"; exit 1; }
echo "[PASS]"

echo "Test 8: Bundled example top-level files present..."
for f in README.md colors_and_type.css; do
  [ -s "$EXAMPLE_DIR/$f" ] || { echo "[FAIL] missing $EXAMPLE_DIR/$f"; exit 1; }
done
echo "[PASS]"

echo "Test 9: Bundled slide-type templates present..."
for tpl in TitleSlide.html SectionDivider.html AgendaSlide.html ContentSlide.html StatSlide.html CapabilitiesSlide.html ComparisonSlide.html QuoteSlide.html TimelineSlide.html ClosingSlide.html; do
  [ -s "$SLIDES_DIR/$tpl" ] || { echo "[FAIL] missing $SLIDES_DIR/$tpl"; exit 1; }
done
echo "[PASS]"

echo "Test 10: Deck runtime + composed deck + presenter window present..."
for f in slides.css deck-stage.js presenter.js index.html presenter.html; do
  [ -s "$SLIDES_DIR/$f" ] || { echo "[FAIL] missing $SLIDES_DIR/$f"; exit 1; }
done
echo "[PASS]"

echo "Test 11: Required asset SVGs present..."
for svg in deloitte-wordmark.svg databricks-wordmark.svg motif-blocks.svg; do
  [ -s "$ASSETS_DIR/$svg" ] || { echo "[FAIL] missing $ASSETS_DIR/$svg"; exit 1; }
done
echo "[PASS]"

echo "Test 12: skill tree free of U+2014 and U+2013..."
if grep -rqP '[\x{2014}\x{2013}]' "$SKILL_DIR"; then
  echo "[FAIL] em-dash or en-dash found in skill tree"
  grep -rnP '[\x{2014}\x{2013}]' "$SKILL_DIR" | head -10
  exit 1
fi
echo "[PASS]"

echo "Test 13: workbench plugin version pinned to 0.14.0..."
jq -e '.version == "0.14.0"' "$PLUGIN_JSON" > /dev/null \
  || { echo "[FAIL] workbench plugin.json not at 0.14.0"; exit 1; }
echo "[PASS]"

echo
echo "All tests passed."
