#!/usr/bin/env bash
# Test: workbench:terse-mode skill structure
# Verifies narrow activation, persistence, disable phrases, clarity exceptions,
# non-trigger guidance, and punctuation lint compatibility.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/workbench/skills/terse-mode"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: workbench:terse-mode skill structure ==="

# Test 1: SKILL.md exists with frontmatter
if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "[PASS] SKILL.md exists with frontmatter"
else
    echo "[FAIL] SKILL.md missing or no frontmatter"; exit 1
fi

# Test 2: Frontmatter name
if grep -q '^name: terse-mode$' "$SKILL_MD"; then
    echo "[PASS] frontmatter name is terse-mode"
else
    echo "[FAIL] frontmatter name missing"; exit 1
fi

# Test 3: Description stays narrow and explicit
desc=$(awk '/^description:/{flag=1;sub(/^description:[ ]*/,"")} /^---$/{flag=0} flag' "$SKILL_MD")
for phrase in 'explicitly asks' 'terse mode' 'token saving mode' '/terse-mode'; do
    if echo "$desc" | grep -qiF "$phrase"; then
        echo "[PASS] description mentions $phrase"
    else
        echo "[FAIL] description missing $phrase"; exit 1
    fi
done
for broad in 'be brief' 'be concise' 'make this shorter' 'tighten this copy'; do
    if echo "$desc" | grep -qiF "$broad"; then
        echo "[FAIL] description includes broad non-trigger: $broad"; exit 1
    else
        echo "[PASS] description avoids broad non-trigger: $broad"
    fi
done

# Test 4: Activation phrases are present
for phrase in 'use terse-mode' 'enable terse mode' 'less tokens mode' 'token saving mode'; do
    if grep -qiF "$phrase" "$SKILL_MD"; then
        echo "[PASS] activation phrase present: $phrase"
    else
        echo "[FAIL] activation phrase missing: $phrase"; exit 1
    fi
done

# Test 5: Persistence and disable behavior are present
for phrase in 'future turns until the user explicitly disables it' 'stop terse mode' 'disable terse mode' 'normal mode' 'stop token saving mode'; do
    if grep -qiF "$phrase" "$SKILL_MD"; then
        echo "[PASS] persistence or disable phrase present: $phrase"
    else
        echo "[FAIL] persistence or disable phrase missing: $phrase"; exit 1
    fi
done

# Test 6: Non-trigger guidance is present
for phrase in 'be brief' 'be concise' 'make this shorter' 'tighten this copy' 'current content only'; do
    if grep -qiF "$phrase" "$SKILL_MD"; then
        echo "[PASS] non-trigger guidance present: $phrase"
    else
        echo "[FAIL] non-trigger guidance missing: $phrase"; exit 1
    fi
done

# Test 7: Compression rules are present
for phrase in 'No filler' 'Code blocks' 'Exact errors' 'Command output' 'File paths' 'Quoted text'; do
    if grep -qiF "$phrase" "$SKILL_MD"; then
        echo "[PASS] compression rule present: $phrase"
    else
        echo "[FAIL] compression rule missing: $phrase"; exit 1
    fi
done

# Test 8: Clarity exceptions are present
for phrase in 'Security warnings' 'Destructive or irreversible operations' 'Multi-step procedures' 'User confusion' 'Resume terse mode'; do
    if grep -qiF "$phrase" "$SKILL_MD"; then
        echo "[PASS] clarity exception present: $phrase"
    else
        echo "[FAIL] clarity exception missing: $phrase"; exit 1
    fi
done

# Test 9: Neutral implementation, no caveman persona
if grep -qiF 'caveman' "$SKILL_MD"; then
    echo "[FAIL] skill mentions caveman"; exit 1
else
    echo "[PASS] skill is neutral"
fi

# Test 10: No literal U+2014 or U+2013 characters
if grep -qP '[\x{2013}\x{2014}]' "$SKILL_MD"; then
    echo "[FAIL] U+2014 or U+2013 in SKILL.md"; exit 1
else
    echo "[PASS] no U+2014 or U+2013"
fi

echo "=== Tests complete ==="
