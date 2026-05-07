#!/usr/bin/env bash
# Test: workbench:verification-before-completion skill structure
# Verifies the ported skill exists and preserves the evidence-before-claims gate.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/workbench/skills/verification-before-completion"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: workbench:verification-before-completion skill ==="

if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "[PASS] SKILL.md exists with frontmatter"
else
    echo "[FAIL] SKILL.md missing or no frontmatter"; exit 1
fi

for marker in 'Evidence comes before claims' 'after the final relevant edit' 'pre-final-edit output' '## Gate' '## Required Evidence' '## Failure Handling' '## Reporting Pattern'; do
    if grep -qF "$marker" "$SKILL_MD"; then
        echo "[PASS] body mentions $marker"
    else
        echo "[FAIL] body missing $marker"; exit 1
    fi
done

for claim in 'Tests pass' 'Lint is clean' 'Build succeeds' 'Bug is fixed' 'PR is ready'; do
    if grep -qF "$claim" "$SKILL_MD"; then
        echo "[PASS] evidence table mentions $claim"
    else
        echo "[FAIL] evidence table missing $claim"; exit 1
    fi
done

if grep -qP '[\x{2013}\x{2014}]' "$SKILL_MD"; then
    echo "[FAIL] em-dash or en-dash in SKILL.md"; exit 1
else
    echo "[PASS] no em or en-dash"
fi

if grep -qF 'verification-before-completion' "$REPO_ROOT/plugins/workbench/README.md"; then
    echo "[PASS] README lists the skill"
else
    echo "[FAIL] README missing skill"; exit 1
fi

echo "=== Tests complete ==="
