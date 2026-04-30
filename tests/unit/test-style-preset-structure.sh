#!/usr/bin/env bash
# Verifies the modular style-preset structure: 3 presets × 8 sidecars + SOURCES.md each.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PRESETS_DIR="$REPO_ROOT/plugins/writing/skills/tech-doc/style-presets"

EXPECTED_FILES=(
  "core.md"
  "wordlist.md"
  "procedures.md"
  "admonitions.md"
  "code-samples.md"
  "links.md"
  "numbers.md"
  "api-reference.md"
  "SOURCES.md"
)

EXPECTED_PRESETS=("google" "microsoft" "house")

failures=0

for preset in "${EXPECTED_PRESETS[@]}"; do
  preset_dir="$PRESETS_DIR/$preset"
  if [[ ! -d "$preset_dir" ]]; then
    echo "FAIL: preset directory missing: $preset_dir"
    failures=$((failures + 1))
    continue
  fi
  for f in "${EXPECTED_FILES[@]}"; do
    file_path="$preset_dir/$f"
    if [[ ! -f "$file_path" ]]; then
      echo "FAIL: missing file: $file_path"
      failures=$((failures + 1))
    elif [[ ! -s "$file_path" ]]; then
      echo "FAIL: empty file: $file_path"
      failures=$((failures + 1))
    fi
  done
done

if [[ $failures -gt 0 ]]; then
  echo "Structure test: $failures failures"
  exit 1
fi

echo "Structure test: PASS (3 presets × 9 files all present and non-empty)"
