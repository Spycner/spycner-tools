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

echo "PASS: wrapper engine detection"
