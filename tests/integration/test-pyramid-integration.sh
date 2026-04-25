#!/usr/bin/env bash
# Integration test: pyramid skill (greenfield end-to-end)
# Runs the full five-phase pipeline on a fixture topic and verifies artifacts
# NOTE: dispatches one construct + four audits + one opener; expect 4-8 minutes
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Integration Test: pyramid skill (greenfield end-to-end) ==="
echo ""

TEST_DIR=$(mktemp -d)
LOG_FILE=$(mktemp)
trap 'rm -rf "$TEST_DIR" "$LOG_FILE"' EXIT

echo "Working dir: $TEST_DIR"
echo ""

echo "Test 1: Full pipeline runs end-to-end..."
# Intake answers are embedded in the prompt so the pipeline runs non-interactively.
PROMPT="Run the full pyramid skill pipeline in greenfield mode in $TEST_DIR. Use --phase intake to start. Topic: 'We should raise Series B in Q1 2027.' Audience: 'board of directors.' Reader question: 'should we raise now or wait?' Genre: 'recommendation.' Do not ask me any follow-up questions; proceed with the answers given. When you reach the domain-limits gate, proceed anyway (this IS a recommendation document, so it should pass the gate). Continue through construct, audit, opener, and render."

output=$(run_claude_logged "$PROMPT" "$LOG_FILE" 600)

echo ""
echo "Test 2: All nine artifacts exist..."
for artifact in intake.md construction.md audit-mece.md audit-so-what.md audit-qa.md audit-logic.md audit-summary.md opener.md pyramid.md; do
    if [ -f "$TEST_DIR/$artifact" ]; then
        echo "  [PASS] $artifact created"
    else
        echo "  [FAIL] $artifact not found"
    fi
done

echo ""
echo "Test 3: pyramid.md contains required top-level sections..."
if [ -f "$TEST_DIR/pyramid.md" ]; then
    for section in 'Opener (SCQA)' '## Apex' '## Supporting findings' '## Audit notes'; do
        if grep -qF "$section" "$TEST_DIR/pyramid.md"; then
            echo "  [PASS] pyramid.md contains: $section"
        else
            echo "  [FAIL] pyramid.md missing: $section"
        fi
    done
else
    echo "  [FAIL] pyramid.md does not exist; cannot check sections"
fi

echo ""
echo "Test 4: audit-summary.md has verdicts table with four rows..."
if [ -f "$TEST_DIR/audit-summary.md" ]; then
    verdict_rows=$(grep -cE '\| (MECE|So-What|Q-A|Inductive)' "$TEST_DIR/audit-summary.md" || true)
    if [ "$verdict_rows" -ge 4 ]; then
        echo "  [PASS] audit-summary.md has 4+ verdict rows ($verdict_rows found)"
    else
        echo "  [FAIL] audit-summary.md has only $verdict_rows verdict rows; expected 4"
    fi
fi

echo ""
echo "Test 5: Each audit file starts with a Verdict line..."
for audit in mece so-what qa logic; do
    file="$TEST_DIR/audit-${audit}.md"
    if [ -f "$file" ]; then
        first_verdict=$(grep -m1 -E '^\*\*Verdict:\*\*' "$file" || true)
        if [ -n "$first_verdict" ]; then
            echo "  [PASS] audit-${audit}.md has Verdict line: $first_verdict"
        else
            echo "  [FAIL] audit-${audit}.md missing Verdict line"
        fi
    fi
done

echo ""
echo "Test 6: State file records last_completed_phase=render..."
STATE_FILE="$HOME/.claude/projects/$(echo "$TEST_DIR" | sed 's|/|-|g; s|^-||')/pyramid-skill-state.json"
if [ -f "$STATE_FILE" ]; then
    if grep -q '"last_completed_phase": "render"' "$STATE_FILE"; then
        echo "  [PASS] state file records last_completed_phase=render"
    else
        echo "  [FAIL] state file does not record render as last phase"
        cat "$STATE_FILE" | sed 's/^/    /'
    fi
else
    echo "  [WARN] state file not found at $STATE_FILE (orchestrator may use different path)"
fi

echo ""
echo "Test 7: Apex in pyramid.md is a finding, not a label..."
if [ -f "$TEST_DIR/pyramid.md" ]; then
    apex_line=$(awk '/^## Apex$/{flag=1; next} flag && NF{print; exit}' "$TEST_DIR/pyramid.md")
    if echo "$apex_line" | grep -qiE "raise|Series B|Q1 2027"; then
        echo "  [PASS] Apex names the finding (contains raise/Series B/Q1 2027)"
    else
        echo "  [FAIL] Apex does not contain the expected topic keywords"
        echo "    Apex line: $apex_line"
    fi
fi

echo ""
echo "=== Mode D (Socratic) end-to-end smoke ==="
echo ""

TEST_DIR_D=$(mktemp -d)
LOG_FILE_D=$(mktemp)
trap 'rm -rf "$TEST_DIR" "$LOG_FILE" "$TEST_DIR_D" "$LOG_FILE_D"' EXIT

echo "Working dir (Mode D): $TEST_DIR_D"
echo ""

echo "Test D1: Mode D pipeline runs end-to-end with embedded answers..."
PROMPT_D="Run the pyramid skill in Mode D (Socratic dialogue) in $TEST_DIR_D. Use --phase intake to start. Topic: 'We should raise Series B in Q1 2027.' Audience: 'board of directors.' Reader question: 'should we raise now or wait?' Genre: 'recommendation.' Domain-limits gate: proceed anyway. Now run the eleven-turn Socratic dialogue. Answer each turn yourself with the answers I will give you below; do NOT actually emit AskUserQuestion calls because the answers are pre-supplied. Turn 1 (reader question): 'Should we raise Series B now, or wait until later in 2027?' Turn 2 (apex): 'We should raise Series B in Q1 2027 rather than wait.' Turn 3 (downward question the apex raises): 'Why Q1 specifically and not later?' Turn 4 (plural noun): 'reasons.' Turn 5 (sibling 1): 'Our runway tightens past Q2 without it.' Turn 6 (sibling 2): 'Market timing favors Q1 launch over later quarters.' Turn 7 (sibling 3): 'Comparable rounds in Q1 closed faster than Q3 last year.' Turn 8 (add or stop): stop at three. Turn 9 (evidence for sibling 1): 'Burn rate is 1.2M/month; current cash buys us through July; closing a round takes 3-4 months.' Turn 10 (evidence for sibling 2): 'Two key competitors announce in Q2; press cycle is favorable through April; product launch is dated for Feb.' Turn 11 (evidence for sibling 3): 'Q1 2026 round comparables (Acme, Beta) closed in 8 weeks; Q3 2025 comparables took 14+ weeks; sentiment data shows H1 fundraising velocity is 2x H2.' Now continue through audit, opener, and render. Do not ask follow-up questions; proceed with the answers given."

output=$(run_claude_logged "$PROMPT_D" "$LOG_FILE_D" 600)

echo ""
echo "Test D2: All nine artifacts exist..."
for artifact in intake.md construction.md audit-mece.md audit-so-what.md audit-qa.md audit-logic.md audit-summary.md opener.md pyramid.md; do
    if [ -f "$TEST_DIR_D/$artifact" ]; then
        echo "  [PASS] $artifact created"
    else
        echo "  [FAIL] $artifact not found"
    fi
done

echo ""
echo "Test D3: pyramid.md contains required top-level sections..."
if [ -f "$TEST_DIR_D/pyramid.md" ]; then
    for section in 'Opener (SCQA)' '## Apex' '## Supporting findings' '## Audit notes'; do
        if grep -qF "$section" "$TEST_DIR_D/pyramid.md"; then
            echo "  [PASS] pyramid.md contains: $section"
        else
            echo "  [FAIL] pyramid.md missing: $section"
        fi
    done
fi

echo ""
echo "Test D4: construction.md records mode: socratic..."
if [ -f "$TEST_DIR_D/construction.md" ]; then
    if grep -qE '^\*\*Mode:\*\* *socratic' "$TEST_DIR_D/construction.md"; then
        echo "  [PASS] construction.md records Mode: socratic"
    else
        echo "  [FAIL] construction.md does not record Mode: socratic"
    fi
fi

echo ""
echo "Test D5: construction.md has no <pending> placeholders left..."
if [ -f "$TEST_DIR_D/construction.md" ]; then
    pending_count=$(grep -c '<pending>' "$TEST_DIR_D/construction.md" || true)
    if [ "$pending_count" = "0" ]; then
        echo "  [PASS] construction.md has no <pending> placeholders"
    else
        echo "  [FAIL] construction.md still has $pending_count <pending> placeholders"
    fi
fi

echo ""
echo "Test D6: State file records mode: socratic and last_completed_phase: render..."
STATE_FILE_D="$HOME/.claude/projects/$(echo "$TEST_DIR_D" | sed 's|/|-|g; s|^-||')/pyramid-skill-state.json"
if [ -f "$STATE_FILE_D" ]; then
    if grep -q '"mode": "socratic"' "$STATE_FILE_D" && grep -q '"last_completed_phase": "render"' "$STATE_FILE_D"; then
        echo "  [PASS] state file records mode=socratic AND last_completed_phase=render"
    else
        echo "  [FAIL] state file does not record both mode=socratic and last_completed_phase=render"
        cat "$STATE_FILE_D" | sed 's/^/    /'
    fi
else
    echo "  [WARN] state file not found at $STATE_FILE_D"
fi

echo ""
echo "Test D7: Apex in pyramid.md is a finding mentioning the user-supplied content..."
if [ -f "$TEST_DIR_D/pyramid.md" ]; then
    apex_line=$(awk '/^## Apex$/{flag=1; next} flag && NF{print; exit}' "$TEST_DIR_D/pyramid.md")
    if echo "$apex_line" | grep -qiE "raise|Series B|Q1 2027"; then
        echo "  [PASS] Apex contains user-supplied finding (raise/Series B/Q1 2027)"
    else
        echo "  [FAIL] Apex does not contain expected finding keywords"
        echo "    Apex line: $apex_line"
    fi
fi

echo ""
echo "=== pyramid integration test complete ==="
