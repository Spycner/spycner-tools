#!/usr/bin/env bash
# Test: workbench:visualizing-options skill structure
# Verifies the moved visual companion lives in its own skill, references its
# deep guide and scripts, and triggering description targets visual intent.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/workbench/skills/visualizing-options"
SKILL_MD="$SKILL_DIR/SKILL.md"
GUIDE="$SKILL_DIR/visual-companion.md"
SCRIPTS="$SKILL_DIR/scripts"

echo "=== Test: workbench:visualizing-options skill ==="

# Test 1: SKILL.md exists with frontmatter
if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "[PASS] SKILL.md exists with frontmatter"
else
    echo "[FAIL] SKILL.md missing or no frontmatter"; exit 1
fi

# Test 2: Description triggers on visual intent
desc=$(awk '/^description:/{flag=1;sub(/^description:[ ]*/,"")} /^---$/{flag=0} flag' "$SKILL_MD")
for term in 'visual' 'browser'; do
    if echo "$desc" | grep -qiF "$term"; then
        echo "[PASS] description mentions $term"
    else
        echo "[FAIL] description missing $term"; exit 1
    fi
done

# Test 3: Body markers present
for marker in 'When to Use' 'Quick Start' 'The Loop' 'visual-companion.md' 'screen_dir' 'state_dir'; do
    if grep -qF "$marker" "$SKILL_MD"; then
        echo "[PASS] body mentions $marker"
    else
        echo "[FAIL] body missing $marker"; exit 1
    fi
done

# Test 4: Visual-companion.md present and intact
if [ -s "$GUIDE" ]; then
    echo "[PASS] visual-companion.md present"
else
    echo "[FAIL] visual-companion.md missing or empty"; exit 1
fi

# Test 5: All five script files present
for f in frame-template.html helper.js server.cjs start-server.sh stop-server.sh; do
    if [ -s "$SCRIPTS/$f" ]; then
        echo "[PASS] scripts/$f present"
    else
        echo "[FAIL] scripts/$f missing or empty"; exit 1
    fi
done

# Test 6: Shell scripts executable
for f in start-server.sh stop-server.sh; do
    if [ -x "$SCRIPTS/$f" ]; then
        echo "[PASS] scripts/$f is executable"
    else
        echo "[FAIL] scripts/$f not executable"; exit 1
    fi
done

# Test 7: No em or en-dash in SKILL.md
if grep -qP '[\x{2013}\x{2014}]' "$SKILL_MD"; then
    echo "[FAIL] em-dash or en-dash in SKILL.md"; exit 1
else
    echo "[PASS] no em or en-dash"
fi

echo "=== Tests complete ==="
