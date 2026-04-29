#!/usr/bin/env bash
# Integration smoke test: run the tech-doc pipeline on a known-violations fixture.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_ROOT/tests/test-helpers.sh"

FIXTURE="$REPO_ROOT/tests/integration/fixtures/sample-how-to-with-violations.md"
WORK_DIR=$(mktemp -d -t tech-doc-smoke-XXXXXX)
trap 'rm -rf "$WORK_DIR"' EXIT

cp "$FIXTURE" "$WORK_DIR/draft.md"
cat > "$WORK_DIR/intake.md" <<EOF
# Intake
**Quadrant:** how-to
**Audience skill level:** intermediate
**Language or platform:** generic
EOF
echo "Reset the database safely." > "$WORK_DIR/throughline.md"

PROMPT="Run the tech-doc panel and finishing on the draft at $WORK_DIR/draft.md, using the working directory $WORK_DIR. Use --quadrant how-to --style-preset house --phase panel through finishing."

echo "Running pipeline against fixture..."
run_claude_logged "$PROMPT"

# Assertions
failures=0

for critique in critique-style-adherence.md critique-admonitions.md critique-code-fidelity.md; do
  if [[ ! -f "$WORK_DIR/$critique" ]]; then
    echo "FAIL: missing $critique"
    failures=$((failures + 1))
  fi
done

if [[ -f "$WORK_DIR/critique-admonitions.md" ]]; then
  if ! grep -qi "delete\|warning\|caution" "$WORK_DIR/critique-admonitions.md"; then
    echo "FAIL: admonitions critic did not flag the inline data-loss warning"
    failures=$((failures + 1))
  fi
fi

if [[ -f "$WORK_DIR/critique-style-adherence.md" ]]; then
  if ! grep -qi "click\|just\|currently\|easily\|em-dash\|em dash" "$WORK_DIR/critique-style-adherence.md"; then
    echo "FAIL: style-adherence critic did not flag the wordlist or em-dash violations"
    failures=$((failures + 1))
  fi
fi

if [[ -f "$WORK_DIR/finishing-notes.md" ]]; then
  if ! grep -qi "wordlist:" "$WORK_DIR/finishing-notes.md"; then
    echo "FAIL: style-enforcer-tech did not log any wordlist substitutions"
    failures=$((failures + 1))
  fi
fi

if [[ $failures -gt 0 ]]; then
  echo "Integration smoke test: $failures failures"
  exit 1
fi

echo "Integration smoke test: PASS"
