#!/usr/bin/env bash
# Integration test: claude-codex-bridge fixture-driven
# Each fixture under tests/fixtures/runtime-bridge/<name>/ has:
#   input/       : the synthetic mini-repo to run the skill on
#   expected/    : the post-apply filesystem state
#   prompt.txt   : the natural-language prompt to invoke with
#   options.txt  : optional, one line, "dry-run" if dry-run mode is intended
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$REPO_ROOT/tests/fixtures/runtime-bridge"
PLUGIN_DIR="$REPO_ROOT/plugins/runtime-bridge"
export PLUGIN_DIR

if [ ! -d "$FIXTURES_DIR" ]; then
    echo "No fixtures dir found at $FIXTURES_DIR; nothing to run."
    exit 0
fi

PASSES=0
FAILS=0

for fixture in "$FIXTURES_DIR"/*/; do
    fixture_name="$(basename "$fixture")"
    input="$fixture/input"
    expected="$fixture/expected"
    prompt_file="$fixture/prompt.txt"
    options_file="$fixture/options.txt"

    [ -d "$input" ] || { echo "[SKIP] $fixture_name (no input/)"; continue; }
    [ -d "$expected" ] || { echo "[SKIP] $fixture_name (no expected/)"; continue; }
    [ -f "$prompt_file" ] || { echo "[SKIP] $fixture_name (no prompt.txt)"; continue; }

    echo ""
    echo "=== Fixture: $fixture_name ==="

    # Copy input to a temp dir
    workdir="$(mktemp -d)"
    cp -a "$input/." "$workdir/"

    # Run per-fixture setup script if present (e.g. to restore mtimes lost on git checkout)
    if [ -f "$fixture/setup.sh" ]; then
        WORKDIR="$workdir" bash "$fixture/setup.sh"
    fi

    prompt="$(cat "$prompt_file")"
    is_dry_run="false"
    if [ -f "$options_file" ] && grep -q "dry-run" "$options_file"; then
        is_dry_run="true"
    fi

    log_file="$(mktemp)"

    # Run the skill in the temp workdir
    (
        cd "$workdir"
        run_claude_logged "$prompt" "$log_file" 180 > /dev/null 2>&1 || true
    )

    # Compare resulting filesystem to expected/
    if [ "$is_dry_run" = "true" ]; then
        # Dry-run: filesystem must NOT have changed (input == workdir contents).
        if diff -r "$input" "$workdir" > /dev/null 2>&1; then
            echo "  [PASS] $fixture_name dry-run preserved input filesystem"
            PASSES=$((PASSES+1))
        else
            echo "  [FAIL] $fixture_name dry-run modified filesystem"
            diff -r "$input" "$workdir" | head -20 | sed 's/^/    /'
            FAILS=$((FAILS+1))
        fi
    else
        # Full run: filesystem must match expected/
        if diff -r "$expected" "$workdir" > /dev/null 2>&1; then
            echo "  [PASS] $fixture_name matches expected"
            PASSES=$((PASSES+1))
        else
            echo "  [FAIL] $fixture_name diff:"
            diff -r "$expected" "$workdir" | head -40 | sed 's/^/    /'
            echo "    (full log at: $log_file)"
            FAILS=$((FAILS+1))
        fi
    fi

    rm -rf "$workdir"
done

echo ""
echo "=== Fixtures: $PASSES PASS, $FAILS FAIL ==="
[ "$FAILS" -eq 0 ]
