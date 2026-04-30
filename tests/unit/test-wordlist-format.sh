#!/usr/bin/env bash
# Verifies wordlist.md files have the correct table shape and category taxonomy.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PRESETS_DIR="$REPO_ROOT/plugins/writing/skills/tech-doc/style-presets"

CANONICAL_CATEGORIES=(
  "clarity"
  "hedge-words"
  "action-verbs"
  "mouse-keyboard"
  "login"
  "web-internet"
  "error-messages"
  "direction"
  "numbers-dates"
  "inclusive"
  "ableist"
  "gendered"
  "culturally-narrow"
  "technical-jargon"
)

failures=0

for preset in google microsoft house; do
  wordlist="$PRESETS_DIR/$preset/wordlist.md"
  if [[ ! -f "$wordlist" ]]; then
    echo "FAIL: $wordlist missing"
    failures=$((failures + 1))
    continue
  fi

  # Check the file has at least one table with the correct headers.
  if ! grep -q '^| *Term *| *Replacement *| *Mechanical *| *Notes *|' "$wordlist"; then
    echo "FAIL: $wordlist missing canonical table header (Term | Replacement | Mechanical | Notes)"
    failures=$((failures + 1))
  fi

  # Check the Mechanical column values are exactly "yes" or "no" in data rows.
  bad_mechanical=$(grep -E '^\| [^|]+ \| [^|]+ \| ' "$wordlist" \
    | grep -v '^| Term ' \
    | grep -v '^|---' \
    | awk -F'|' '{print $4}' \
    | sed 's/^ *//;s/ *$//' \
    | grep -vE '^(yes|no)$' || true)

  if [[ -n "$bad_mechanical" ]]; then
    echo "FAIL: $wordlist has Mechanical column values outside {yes, no}:"
    echo "$bad_mechanical" | head -5 | sed 's/^/    /'
    failures=$((failures + 1))
  fi

  # Check that the Categories list at the top mentions every canonical category.
  for cat in "${CANONICAL_CATEGORIES[@]}"; do
    if ! grep -q "^- \`$cat\`" "$wordlist"; then
      echo "FAIL: $wordlist Categories list does not declare \`$cat\`"
      failures=$((failures + 1))
    fi
  done
done

if [[ $failures -gt 0 ]]; then
  echo "Wordlist format test: $failures failures"
  exit 1
fi

echo "Wordlist format test: PASS"
