#!/usr/bin/env bash
# Skill triggering test — verifies Claude auto-triggers the expected skill
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
export PLUGIN_DIR="${PLUGIN_DIR:-$REPO_DIR/plugins/atlassian}"
cd "$REPO_DIR"

EXPECTED_SKILL="$1"
PROMPT_FILE="$2"
PROMPT="$(cat "$PROMPT_FILE")"
LOG_FILE=$(mktemp)

trap "rm -f $LOG_FILE" EXIT

# Run Claude with stream-json to capture tool invocations
local_plugin_flag=""
if [ -n "$PLUGIN_DIR" ]; then
    local_plugin_flag="--plugin-dir $PLUGIN_DIR"
fi

# macOS compat
if command -v gtimeout &>/dev/null; then _to=gtimeout; elif command -v timeout &>/dev/null; then _to=timeout; else _to=""; fi

if [ -n "$_to" ]; then
    "$_to" 60 bash -c "claude -p \"$PROMPT\" $local_plugin_flag --verbose --output-format stream-json" > "$LOG_FILE" 2>&1 || true
else
    bash -c "claude -p \"$PROMPT\" $local_plugin_flag --verbose --output-format stream-json" > "$LOG_FILE" 2>&1 || true
fi

# Check if the skill was triggered
SKILL_PATTERN="\"skill\":\"([^\"]*:)?${EXPECTED_SKILL}\""
if grep -qE "$SKILL_PATTERN" "$LOG_FILE"; then
    echo "  [PASS] Skill '$EXPECTED_SKILL' was triggered"
else
    echo "  [FAIL] Skill '$EXPECTED_SKILL' was NOT triggered"
    echo "  Log file (first 500 chars):"
    head -c 500 "$LOG_FILE" | sed 's/^/    /'
fi
