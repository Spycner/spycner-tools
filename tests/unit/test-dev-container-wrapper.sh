#!/usr/bin/env bash
# tests/unit/test-dev-container-wrapper.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WRAPPER="$REPO_ROOT/containers/dev/run-dev"

fail() { echo "FAIL: $1" >&2; exit 1; }

mock_dir="$(mktemp -d)"
trap "rm -rf $mock_dir" EXIT

make_shim() {
    local name="$1"
    cat > "$mock_dir/$name" <<EOF
#!/usr/bin/env bash
echo "$name \$@"
EOF
    chmod +x "$mock_dir/$name"
}

# Test 1: podman preferred when both present.
make_shim podman
make_shim docker
out=$(PATH="$mock_dir:$PATH" "$WRAPPER" engine 2>&1) || fail "engine subcmd failed: $out"
[ "$out" = "podman" ] || fail "expected podman, got: $out"

# Test 2: docker fallback when podman absent.
# Invoke the parent bash binary directly so the wrapper's `/usr/bin/env bash`
# shebang does not need to resolve `bash` via PATH (we restrict PATH to
# $mock_dir to hide the host's real podman/docker).
rm "$mock_dir/podman"
out=$(PATH="$mock_dir" "$BASH" "$WRAPPER" engine 2>&1) || fail "engine subcmd failed: $out"
[ "$out" = "docker" ] || fail "expected docker, got: $out"

# Test 3: error when neither present.
rm "$mock_dir/docker"
PATH="$mock_dir" "$BASH" "$WRAPPER" engine 2>/dev/null && fail "expected nonzero exit when no engine"

# Test 4: CONTAINER_ENGINE override.
make_shim docker
make_shim podman
out=$(PATH="$mock_dir:$PATH" CONTAINER_ENGINE=docker "$WRAPPER" engine 2>&1) || fail "override failed"
[ "$out" = "docker" ] || fail "expected docker via override, got: $out"

# --- Task 4: start subcommand tests ---

# Capture-shim: writes invocation to a log file instead of executing.
make_capture_shim() {
    local name="$1"
    local log="$2"
    cat > "$mock_dir/$name" <<EOF
#!/usr/bin/env bash
echo "\$@" >> "$log"
case "\$1" in
    inspect) exit 1 ;;  # simulate "container does not exist"
    images) echo "" ;;  # simulate "image does not exist"
    *) exit 0 ;;
esac
EOF
    chmod +x "$mock_dir/$name"
}

log_file="$(mktemp)"
make_capture_shim podman "$log_file"
rm -f "$mock_dir/docker"

cd /tmp
PATH="$mock_dir:$PATH" HOST_SHELL=/bin/bash "$WRAPPER" start >/dev/null 2>&1 || fail "start subcmd failed"

grep -q "^build " "$log_file" || fail "expected 'build' invocation"
grep -q "^run .*--name claude-codex-dev" "$log_file" || fail "expected '--name claude-codex-dev'"
grep -q "^run .*-v .*\.claude:/home/dev/\.claude" "$log_file" || fail "expected .claude bind mount"
grep -q "^run .*-v .*\.codex:/home/dev/\.codex" "$log_file"  || fail "expected .codex bind mount"
grep -q "^run .*-v /tmp:/workspace" "$log_file" || fail "expected /tmp:/workspace bind mount"
grep -q "^run .*-v claude-codex-mise:/home/dev/\.local/share/mise" "$log_file" || fail "expected mise volume"
grep -q "^run .*-e HOST_SHELL=/bin/bash" "$log_file" || fail "expected HOST_SHELL env"
grep -q "^run .*-e COPY_DOTFILES=" "$log_file" || fail "expected COPY_DOTFILES env"
grep -q "^run .*-v .*:/host-home:ro" "$log_file" || fail "expected /host-home read-only mount"

echo "PASS: wrapper engine detection"
