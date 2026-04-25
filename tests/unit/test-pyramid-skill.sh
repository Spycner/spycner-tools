#!/usr/bin/env bash
# Test: pyramid skill
# Verifies the skill is loaded and describes correct capabilities
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: pyramid skill ==="
echo ""

# Test 1: Skill recognition
echo "Test 1: Skill loading and recognition..."
output=$(run_claude "What is the pyramid skill? Describe what it does briefly." 30)
assert_contains "$output" "pyramid|Pyramid" "Skill is recognized" || true
assert_contains "$output" "Minto|minto" "Mentions Barbara Minto" || true
assert_contains "$output" "outline|restructur|memo|recommendation" "Mentions outline or restructure or memo use case" || true
echo ""

# Test 2: Phases
echo "Test 2: Phase coverage..."
output=$(run_claude "What phases does the pyramid skill have? List them." 30)
assert_contains "$output" "intake|Intake" "Mentions intake phase" || true
assert_contains "$output" "construct|Construct" "Mentions construct phase" || true
assert_contains "$output" "audit|Audit" "Mentions audit phase" || true
assert_contains "$output" "opener|Opener|SCQA" "Mentions opener phase" || true
assert_contains "$output" "render|Render" "Mentions render phase" || true
echo ""

# Test 3: Audit panel
echo "Test 3: Audit panel coverage..."
output=$(run_claude "What audits does the pyramid skill run? Name them." 30)
assert_contains "$output" "MECE|mece" "Mentions MECE audit" || true
assert_contains "$output" "[Ss]o.[Ww]hat|so.what" "Mentions So-What audit" || true
assert_contains "$output" "Q.A [Aa]lignment|Q-A alignment|QA alignment" "Mentions Q-A Alignment audit" || true
assert_contains "$output" "[Ii]nductive|[Dd]eductive" "Mentions Inductive/Deductive audit" || true
echo ""

# Test 4: Two construction modes
echo "Test 4: Greenfield and restructure modes..."
output=$(run_claude "What modes does the pyramid skill support? Can it work with an existing draft?" 30)
assert_contains "$output" "greenfield|topic|fresh" "Mentions greenfield/topic mode" || true
assert_contains "$output" "restructur|existing draft|existing prose" "Mentions restructure mode" || true
echo ""

# Test 5: Domain limits gate
echo "Test 5: Domain-limits gate..."
output=$(run_claude "When does the pyramid skill refuse or warn about applying the pyramid? What genres?" 30)
assert_contains "$output" "narrative|essay|exploratory|discovery|emotion" "Mentions at least one non-applicable genre" || true
assert_contains "$output" "domain|gate|warn|refuse|proceed" "Mentions a domain-limits gate or similar" || true
echo ""

# Test 6: Reference file mentioned
echo "Test 6: Reference file..."
output=$(run_claude "What reference material ships with the pyramid skill?" 30)
assert_contains "$output" "pyramid.principle.reference|pyramid-principle-reference" "Mentions the shipped reference" || true
echo ""

# Test 7: Verdict token semantics
echo "Test 7: Audit verdict semantics..."
output=$(run_claude "What verdict tokens do pyramid audits emit? What happens on CRITICAL?" 30)
assert_contains "$output" "PASS" "Mentions PASS verdict" || true
assert_contains "$output" "MINOR" "Mentions MINOR verdict" || true
assert_contains "$output" "CRITICAL" "Mentions CRITICAL verdict" || true
assert_contains "$output" "re.dispatch|re.run|iteration|construct" "Mentions the re-dispatch loop on CRITICAL" || true
echo ""

# Test 8: Phase-selectable behavior
echo "Test 8: Phase-selectable behavior..."
output=$(run_claude "Can the pyramid skill resume from a specific phase? How?" 30)
assert_contains "$output" "phase|Phase|--phase" "Mentions phase selection" || true
assert_contains "$output" "resume|jump|skip|start" "Mentions resume capability" || true
echo ""

# Test 9: Mode D (Socratic) is documented in SKILL.md
echo "Test 9: Mode D (Socratic dialogue) recognition..."
output=$(run_claude "Does the pyramid skill support an interactive Socratic dialogue mode where it walks the writer through pyramid construction question by question? What is it called?" 30)
assert_contains "$output" "[Ss]ocratic|Mode D" "Mentions Mode D / Socratic" || true
assert_contains "$output" "AskUserQuestion|turn|dialogue|question.and.answer" "Mentions the dialogue mechanic" || true
echo ""

# Test 10: Greenfield prompt has Handoff mode for Mode D handoffs
echo "Test 10: Greenfield Handoff mode section..."
SKILL_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/plugins/writing/skills/pyramid"
GREENFIELD_PROMPT="$SKILL_DIR/construct-greenfield-prompt.md"
if [ -f "$GREENFIELD_PROMPT" ]; then
    if grep -qF '## Handoff mode' "$GREENFIELD_PROMPT"; then
        echo "  [PASS] construct-greenfield-prompt.md has '## Handoff mode' section"
    else
        echo "  [FAIL] construct-greenfield-prompt.md missing '## Handoff mode' section"
    fi
    if grep -qF '{HANDOFF}' "$GREENFIELD_PROMPT"; then
        echo "  [PASS] construct-greenfield-prompt.md references {HANDOFF} placeholder"
    else
        echo "  [FAIL] construct-greenfield-prompt.md missing {HANDOFF} placeholder reference"
    fi
else
    echo "  [FAIL] construct-greenfield-prompt.md not found at $GREENFIELD_PROMPT"
fi
echo ""

echo "=== pyramid skill tests complete ==="
