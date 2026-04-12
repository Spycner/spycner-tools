#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_DIR"

INTEGRATION=false
VERBOSE=false
SPECIFIC_TEST=""
TIMEOUT=300

while [[ $# -gt 0 ]]; do
    case $1 in
        --integration) INTEGRATION=true; shift ;;
        --verbose) VERBOSE=true; shift ;;
        --test) SPECIFIC_TEST="$2"; shift 2 ;;
        --timeout) TIMEOUT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo "=== pgoell-claude-tools Plugin Tests ==="
echo ""

# Set plugin directory for all tests
export PLUGIN_DIR="$REPO_DIR/plugins/atlassian"

# Make scripts executable
chmod +x tests/test-helpers.sh
find tests -name "*.sh" -exec chmod +x {} \;

# Run unit tests
echo "--- Unit Tests ---"
for test in tests/unit/test-*.sh; do
    [ -f "$test" ] || continue
    if [ -n "$SPECIFIC_TEST" ] && [[ "$test" != *"$SPECIFIC_TEST"* ]]; then
        continue
    fi
    echo ""
    echo "Running: $(basename "$test")"
    if $VERBOSE; then
        bash "$test" || true
    else
        bash "$test" 2>&1 || true
    fi
done

# Run skill triggering tests
echo ""
echo "--- Skill Triggering Tests ---"
for prompt_file in tests/skill-triggering/prompts/*.txt; do
    [ -f "$prompt_file" ] || continue
    prompt_name="$(basename "$prompt_file" .txt)"

    # Determine expected skill from filename
    if [[ "$prompt_name" == jira-* ]]; then
        expected_skill="jira"
    elif [[ "$prompt_name" == confluence-* ]]; then
        expected_skill="confluence"
    else
        continue
    fi

    echo ""
    echo "Triggering test: $prompt_name (expect: $expected_skill)"
    bash tests/skill-triggering/run-test.sh "$expected_skill" "$prompt_file"
done

# Run integration tests (only if --integration flag)
if $INTEGRATION; then
    echo ""
    echo "--- Integration Tests ---"
    for test in tests/integration/test-*.sh; do
        [ -f "$test" ] || continue
        if [ -n "$SPECIFIC_TEST" ] && [[ "$test" != *"$SPECIFIC_TEST"* ]]; then
            continue
        fi
        echo ""
        echo "Running: $(basename "$test")"
        bash "$test" || true
    done
else
    echo ""
    echo "(Skipping integration tests — use --integration to include)"
fi
