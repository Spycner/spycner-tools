#!/usr/bin/env bash
# Integration smoke test: run the tech-doc pipeline on a known-violations fixture.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_ROOT/tests/test-helpers.sh"

FIXTURE="$REPO_ROOT/tests/integration/fixtures/sample-how-to-with-violations.md"
WORK_DIR=$(mktemp -d -t tech-doc-smoke-XXXXXX)
cleanup() {
  if [[ ${KEEP_WORK_DIR:-0} -eq 1 ]] || [[ ${TEST_FAILED:-0} -eq 1 ]]; then
    echo "Preserving work dir for inspection: $WORK_DIR"
  else
    rm -rf "$WORK_DIR"
  fi
}
trap cleanup EXIT

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
LOG_FILE="$WORK_DIR/claude-stream.log"
PLUGIN_DIR="${PLUGIN_DIR:-plugins/writing}" run_claude_logged "$PROMPT" "$LOG_FILE" 600

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

if [[ ! -f "$WORK_DIR/finishing-notes.md" ]]; then
  echo "FAIL: finishing-notes.md missing; finishing passes did not run"
  failures=$((failures + 1))
elif ! grep -qi "Style-enforcer-tech" "$WORK_DIR/finishing-notes.md"; then
  echo "FAIL: style-enforcer-tech section missing from finishing-notes.md"
  failures=$((failures + 1))
elif ! grep -qiE "rule: (core\.md|procedures\.md|wordlist\.md)" "$WORK_DIR/finishing-notes.md"; then
  echo "FAIL: style-enforcer-tech ran but did not log any sidecar-cited rule applications"
  failures=$((failures + 1))
fi

if [[ $failures -gt 0 ]]; then
  TEST_FAILED=1
  echo "Integration smoke test: $failures failures"
  exit 1
fi

echo "Integration smoke test: PASS"
