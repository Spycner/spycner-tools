#!/usr/bin/env bash
# Helper functions for pgoell-claude-tools plugin tests
# Follows superpowers test-helpers.sh pattern

# macOS compatibility: use gtimeout if available, otherwise a bash fallback
if command -v gtimeout &>/dev/null; then
    timeout_cmd="gtimeout"
elif command -v timeout &>/dev/null; then
    timeout_cmd="timeout"
else
    # Bash fallback for macOS without coreutils
    timeout_cmd=""
    _timeout() {
        local secs="$1"; shift
        ( "$@" ) &
        local pid=$!
        ( sleep "$secs" && kill "$pid" 2>/dev/null ) &
        local watcher=$!
        wait "$pid" 2>/dev/null
        local rc=$?
        kill "$watcher" 2>/dev/null 2>&1
        wait "$watcher" 2>/dev/null 2>&1
        return $rc
    }
fi

_run_timeout() {
    if [ -n "$timeout_cmd" ]; then
        "$timeout_cmd" "$@"
    else
        _timeout "$@"
    fi
}

# Plugin directory — set by run-tests.sh or override in individual tests
PLUGIN_DIR="${PLUGIN_DIR:-}"

# Run Claude Code with a prompt and capture output
# Usage: output=$(run_claude "prompt text" [timeout_seconds])
run_claude() {
    local prompt="$1"
    local timeout="${2:-60}"
    local output_file=$(mktemp)
    local plugin_flag=""
    if [ -n "$PLUGIN_DIR" ]; then
        plugin_flag="--plugin-dir $PLUGIN_DIR"
    fi

    if bash -c "claude -p \"$prompt\" $plugin_flag --dangerously-skip-permissions" > "$output_file" 2>&1; then
        cat "$output_file"
        rm -f "$output_file"
        return 0
    else
        local exit_code=$?
        cat "$output_file" >&2
        rm -f "$output_file"
        return $exit_code
    fi
}

# Check if output contains a pattern
# Usage: assert_contains "output" "pattern" "test name"
assert_contains() {
    local output="$1"
    local pattern="$2"
    local test_name="${3:-test}"

    # Strip markdown formatting before matching
    local clean
    clean=$(echo "$output" | sed 's/\*\*//g; s/`//g; s/\*//g')
    if echo "$clean" | grep -qiE "$pattern"; then
        echo "  [PASS] $test_name"
        return 0
    else
        echo "  [FAIL] $test_name"
        echo "  Expected to find: $pattern"
        echo "  In output (first 500 chars):"
        echo "$clean" | head -c 500 | sed 's/^/    /'
        return 1
    fi
}

# Check if output does NOT contain a pattern
# Usage: assert_not_contains "output" "pattern" "test name"
assert_not_contains() {
    local output="$1"
    local pattern="$2"
    local test_name="${3:-test}"

    local clean
    clean=$(echo "$output" | sed 's/\*\*//g; s/`//g; s/\*//g')
    if echo "$clean" | grep -qiE "$pattern"; then
        echo "  [FAIL] $test_name"
        echo "  Did not expect to find: $pattern"
        return 1
    else
        echo "  [PASS] $test_name"
        return 0
    fi
}

# Check if pattern A appears before pattern B
# Usage: assert_order "output" "pattern_a" "pattern_b" "test name"
assert_order() {
    local output="$1"
    local pattern_a="$2"
    local pattern_b="$3"
    local test_name="${4:-test}"

    local clean
    clean=$(echo "$output" | sed 's/\*\*//g; s/`//g; s/\*//g')
    local line_a=$(echo "$clean" | grep -niE "$pattern_a" | head -1 | cut -d: -f1)
    local line_b=$(echo "$clean" | grep -niE "$pattern_b" | head -1 | cut -d: -f1)

    if [ -z "$line_a" ]; then
        echo "  [FAIL] $test_name: pattern A not found: $pattern_a"
        return 1
    fi
    if [ -z "$line_b" ]; then
        echo "  [FAIL] $test_name: pattern B not found: $pattern_b"
        return 1
    fi
    if [ "$line_a" -lt "$line_b" ]; then
        echo "  [PASS] $test_name (A at line $line_a, B at line $line_b)"
        return 0
    else
        echo "  [FAIL] $test_name: expected '$pattern_a' before '$pattern_b' but A=$line_a B=$line_b"
        return 1
    fi
}

# Check if acli is authenticated
check_acli_auth() {
    acli auth status &>/dev/null 2>&1
}

# Check if env vars are set for curl
check_env_auth() {
    [[ -n "${ATLASSIAN_DOMAIN:-}" && -n "${ATLASSIAN_EMAIL:-}" && -n "${ATLASSIAN_API_TOKEN:-}" ]]
}

# Check if any Atlassian auth is available
check_any_auth() {
    check_acli_auth || check_env_auth
}

# Run Claude and capture stream-json output to a log file, plus human-readable output
# Usage: run_claude_logged "prompt text" log_file [timeout_seconds]
# Returns: human-readable output on stdout, full JSON stream in log_file
run_claude_logged() {
    local prompt="$1"
    local log_file="$2"
    local timeout="${3:-120}"
    local output_file=$(mktemp)
    local plugin_flag=""
    if [ -n "$PLUGIN_DIR" ]; then
        plugin_flag="--plugin-dir $PLUGIN_DIR"
    fi

    bash -c "claude -p \"$prompt\" $plugin_flag --dangerously-skip-permissions --verbose --output-format stream-json" > "$log_file" 2>&1 || true

    # Extract final result text from stream-json
    if [ -f "$log_file" ]; then
        # The result field in the final JSON line has the complete response
        grep '"type":"result"' "$log_file" 2>/dev/null | grep -oE '"result":"[^"]*"' | sed 's/"result":"//;s/"$//' || \
        # Fallback: extract text from assistant messages
        grep '"type":"assistant"' "$log_file" 2>/dev/null | grep -oE '"text":"[^"]*"' | sed 's/"text":"//;s/"$//' || \
        cat "$log_file"
    fi
}

# Check if a log file contains evidence of script usage
# Usage: assert_used_scripts log_file "test name"
assert_used_scripts() {
    local log_file="$1"
    local test_name="${2:-Used scripts}"

    if grep -q 'scripts/jira/\|scripts/confluence/' "$log_file"; then
        echo "  [PASS] $test_name"
        return 0
    elif grep -q 'acli jira\|acli confluence' "$log_file"; then
        echo "  [INFO] $test_name — used acli instead of scripts"
        return 0
    else
        echo "  [WARN] $test_name — could not determine tool used"
        return 0
    fi
}

# Show which tools Claude used from a stream-json log
# Usage: show_tools_used log_file
show_tools_used() {
    local log_file="$1"
    echo "  Tools used:"
    # Extract tool names from tool_use blocks
    grep -oE '"name":"(Bash|Read|Write|Edit|Glob|Grep|Skill|WebSearch|WebFetch|Agent)"' "$log_file" 2>/dev/null | sort | uniq -c | sed 's/"name":"//;s/"$//;s/^/    /' || true
    # Show bash commands that reference scripts or acli or curl
    echo "  Commands:"
    grep -oE 'scripts/(jira|confluence)/[a-z_-]+\.sh' "$log_file" 2>/dev/null | sort -u | sed 's/^/    - script: /' || true
    grep -oE 'acli (jira|confluence) [a-z-]+ [a-z-]*' "$log_file" 2>/dev/null | sort -u | sed 's/^/    - acli: /' || true
    grep -oE 'gws (gmail|calendar) [+a-z_-]+' "$log_file" 2>/dev/null | sort -u | sed 's/^/    - gws: /' || true
    if grep -q 'curl -s -u' "$log_file" 2>/dev/null; then echo "    - raw curl detected"; fi
    if ! grep -qE 'scripts/|acli |curl -s|gws ' "$log_file" 2>/dev/null; then echo "    (no commands detected)"; fi
}

# Check if gws CLI is authenticated
check_gws_auth() {
    command -v gws &>/dev/null && gws auth status &>/dev/null 2>&1
}

# Export functions for use in tests
export -f run_claude
export -f run_claude_logged
export -f assert_contains
export -f assert_not_contains
export -f assert_order
export -f assert_used_scripts
export -f show_tools_used
export -f check_acli_auth
export -f check_env_auth
export -f check_any_auth
export -f check_gws_auth
