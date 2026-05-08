#!/usr/bin/env bash
# tests/integration/test-dev-container-build.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONTAINER_DIR="$REPO_ROOT/containers/dev"
IMAGE_TAG="pgoell-dev-container-test:latest"
CONTAINER_NAME="pgoell-dev-container-test"

ENGINE=""
if command -v podman >/dev/null 2>&1; then ENGINE=podman
elif command -v docker >/dev/null 2>&1; then ENGINE=docker
else
    echo "SKIP: neither podman nor docker available"
    exit 0
fi

fail() { echo "FAIL: $1" >&2; exit 1; }

cleanup() {
    "$ENGINE" rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

"$ENGINE" build -t "$IMAGE_TAG" "$CONTAINER_DIR" || fail "image build failed"

"$ENGINE" run -d --name "$CONTAINER_NAME" "$IMAGE_TAG" || fail "container start failed"

"$ENGINE" exec "$CONTAINER_NAME" bash -lc 'command -v bash && command -v zsh && command -v tmux && command -v mise && command -v git && command -v curl && command -v rg && command -v fd && command -v fzf && command -v jq && command -v bat && command -v eza && command -v btop && command -v starship && command -v node && command -v npm && command -v cargo' \
    || fail "expected tools missing on PATH"

uid_inside=$("$ENGINE" exec "$CONTAINER_NAME" id -u dev) \
    || fail "user dev does not exist"
[ "$uid_inside" = "1000" ] || fail "expected dev UID 1000, got $uid_inside"

running=$("$ENGINE" inspect -f '{{.State.Running}}' "$CONTAINER_NAME") \
    || fail "inspect failed"
[ "$running" = "true" ] || fail "container not running after start"

echo "PASS: dev container build smoke"
