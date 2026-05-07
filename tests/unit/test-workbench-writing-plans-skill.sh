#!/usr/bin/env bash
# Test: workbench:writing-plans skill structure
# Verifies the ported skill exists and preserves concrete planning discipline.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/workbench/skills/writing-plans"
SKILL_MD="$SKILL_DIR/SKILL.md"
REVIEWER="$SKILL_DIR/plan-reviewer-prompt.md"

echo "=== Test: workbench:writing-plans skill ==="

if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "[PASS] SKILL.md exists with frontmatter"
else
    echo "[FAIL] SKILL.md missing or no frontmatter"; exit 1
fi

for marker in 'Path Resolution' 'Scope Check' 'File Structure' 'Bite-Sized Task Granularity' 'Plan Document Header' 'Task Structure' 'No Placeholders' 'Plan Review' 'Execution Handoff'; do
    if grep -qF "$marker" "$SKILL_MD"; then
        echo "[PASS] body mentions $marker"
    else
        echo "[FAIL] body missing $marker"; exit 1
    fi
done

for marker in 'workbench:writing-spec' 'checkbox (`- [ ]`) syntax' 'exact file paths' 'Expected: FAIL' 'Expected: PASS' 'git commit -m'; do
    if grep -qF "$marker" "$SKILL_MD"; then
        echo "[PASS] planning rule mentions $marker"
    else
        echo "[FAIL] planning rule missing $marker"; exit 1
    fi
done

for marker in 'fresh-eyes reviewer subagent' 'plan-reviewer-prompt.md' 'Apply the reviewer' 'reviewer pass is complete'; do
    if grep -qF "$marker" "$SKILL_MD"; then
        echo "[PASS] reviewer flow mentions $marker"
    else
        echo "[FAIL] reviewer flow missing $marker"; exit 1
    fi
done

if [ -s "$REVIEWER" ] && grep -qF 'Plan Reviewer Prompt Template' "$REVIEWER" && grep -qF 'Review implementation plan' "$REVIEWER"; then
    echo "[PASS] plan-reviewer-prompt.md present and well-formed"
else
    echo "[FAIL] plan reviewer prompt missing or incomplete"; exit 1
fi

if grep -qP '[\x{2013}\x{2014}]' "$SKILL_MD"; then
    echo "[FAIL] em-dash or en-dash in SKILL.md"; exit 1
else
    echo "[PASS] no em or en-dash"
fi

if grep -qF 'writing-plans' "$REPO_ROOT/plugins/workbench/README.md" && grep -qF 'skills/writing-plans/SKILL.md' "$REPO_ROOT/plugins/workbench/NOTICE"; then
    echo "[PASS] README and NOTICE list the skill"
else
    echo "[FAIL] README or NOTICE missing skill"; exit 1
fi

if grep -qF 'workbench:writing-plans' "$REPO_ROOT/plugins/workbench/skills/autopilot/SKILL.md" && grep -qF 'workbench:writing-plans' "$REPO_ROOT/plugins/workbench/skills/autopilot/references/required-skills.md"; then
    echo "[PASS] autopilot references workbench:writing-plans"
else
    echo "[FAIL] autopilot missing workbench:writing-plans"; exit 1
fi

echo "=== Tests complete ==="
