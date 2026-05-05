#!/usr/bin/env bash
# Test: SKILL.md frontmatter YAML
# Verifies every skill frontmatter block parses as YAML.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_DIR"

echo "=== Test: SKILL.md frontmatter YAML ==="
echo ""

uv run --with pyyaml python -c '
from pathlib import Path
import sys
import yaml

failed = False
for path in sorted(Path("plugins").glob("**/SKILL.md")):
    file_failed = False
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        print(f"  [FAIL] {path}: missing opening frontmatter delimiter")
        failed = file_failed = True
        continue

    try:
        frontmatter = text.split("---\n", 2)[1]
    except IndexError:
        print(f"  [FAIL] {path}: missing closing frontmatter delimiter")
        failed = file_failed = True
        continue

    try:
        data = yaml.safe_load(frontmatter)
    except yaml.YAMLError as exc:
        print(f"  [FAIL] {path}: {exc}")
        failed = file_failed = True
        continue

    if not isinstance(data, dict):
        print(f"  [FAIL] {path}: frontmatter did not parse to a mapping")
        failed = file_failed = True
        continue

    for required in ("name", "description"):
        if required not in data:
            print(f"  [FAIL] {path}: missing {required!r}")
            failed = file_failed = True

    if not file_failed:
        print(f"  [PASS] {path}")

if failed:
    sys.exit(1)
'

echo ""
echo "=== SKILL.md frontmatter YAML test complete ==="
