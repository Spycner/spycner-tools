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

# Rootless podman remaps container UIDs into a subuid range, so a bind-mounted
# host directory owned by the running user is unreadable to the container's
# UID 1000. --userns=keep-id keeps host UID == container UID. Docker has no
# default user namespace remapping; nothing extra required.
USERNS_ARGS=()
if [ "$ENGINE" = "podman" ]; then
    USERNS_ARGS=(--userns=keep-id)
fi

fail() { echo "FAIL: $1" >&2; exit 1; }

cleanup() {
    "$ENGINE" rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

"$ENGINE" build -t "$IMAGE_TAG" "$CONTAINER_DIR" || fail "image build failed"

"$ENGINE" run -d --name "$CONTAINER_NAME" "${USERNS_ARGS[@]}" "$IMAGE_TAG" || fail "container start failed"

"$ENGINE" exec "$CONTAINER_NAME" bash -lc 'command -v bash && command -v zsh && command -v tmux && command -v mise && command -v git && command -v curl && command -v rg && command -v fd && command -v fzf && command -v jq && command -v bat && command -v eza && command -v btop && command -v starship && command -v node && command -v npm && command -v cargo' \
    || fail "expected tools missing on PATH"

uid_inside=$("$ENGINE" exec "$CONTAINER_NAME" id -u dev) \
    || fail "user dev does not exist"
[ "$uid_inside" = "1000" ] || fail "expected dev UID 1000, got $uid_inside"

running=$("$ENGINE" inspect -f '{{.State.Running}}' "$CONTAINER_NAME") \
    || fail "inspect failed"
[ "$running" = "true" ] || fail "container not running after start"

# --- Task 6: dotfile snapshot ---

fixture_home="$(mktemp -d)"
trap "rm -rf $fixture_home; cleanup" EXIT

# Build a fake host home with the expected dotfiles. The .bashrc fixture
# includes the linuxbrew line so the entrypoint's snapshot post-process step
# can be verified.
cat > "$fixture_home/.bashrc" <<'EOF'
# fake bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
. "$HOME/.cargo/env"
eval "$(starship init bash)"
eval "$(/home/pascal/.local/bin/mise activate bash)"
EOF
echo "# fake profile" > "$fixture_home/.profile"
echo "# fake zshenv" > "$fixture_home/.zshenv"
echo "# fake tmux conf" > "$fixture_home/.tmux.conf"
printf '[user]\n  name = Test\n' > "$fixture_home/.gitconfig"
mkdir -p "$fixture_home/.tmux/plugins/tpm"
echo "# fake tpm" > "$fixture_home/.tmux/plugins/tpm/README.md"

# Recreate container with the fixture mounted as /host-home.
"$ENGINE" rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
"$ENGINE" run -d --name "$CONTAINER_NAME" \
    "${USERNS_ARGS[@]}" \
    -v "$fixture_home:/host-home:ro" \
    -e "HOST_SHELL=/bin/bash" \
    -e "COPY_DOTFILES=1" \
    "$IMAGE_TAG" \
    || fail "container start with fixture failed"

# Wait briefly for entrypoint to copy.
sleep 2

for f in .bashrc .profile .zshenv .tmux.conf .gitconfig; do
    "$ENGINE" exec "$CONTAINER_NAME" test -f "/home/dev/$f" \
        || fail "expected /home/dev/$f after dotfile snapshot"
done
"$ENGINE" exec "$CONTAINER_NAME" test -d "/home/dev/.tmux/plugins/tpm" \
    || fail "expected /home/dev/.tmux/plugins/tpm after dotfile snapshot"

# Verify snapshot post-process neutralizes lines that cannot run in the
# container, leaves working lines intact, and rewrites host-home mise paths.
"$ENGINE" exec "$CONTAINER_NAME" grep -q '^#.*linuxbrew' /home/dev/.bashrc \
    || fail "expected linuxbrew line to be commented out in /home/dev/.bashrc"
"$ENGINE" exec "$CONTAINER_NAME" grep -q '^#.*cargo/env' /home/dev/.bashrc \
    || fail "expected cargo env line to be commented out in /home/dev/.bashrc"
"$ENGINE" exec "$CONTAINER_NAME" grep -q '/home/dev/.local/bin/mise activate' /home/dev/.bashrc \
    || fail "expected mise activate path to be rewritten to /home/dev/"
"$ENGINE" exec "$CONTAINER_NAME" grep -q '/home/pascal/.local/bin/mise' /home/dev/.bashrc \
    && fail "/home/pascal/ should not appear in container .bashrc after rewrite"
"$ENGINE" exec "$CONTAINER_NAME" grep -q '^eval "$(starship init bash)"' /home/dev/.bashrc \
    || fail "expected starship line to remain intact in /home/dev/.bashrc"

# Verify COPY_DOTFILES=0 skips the copy.
"$ENGINE" rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
"$ENGINE" run -d --name "$CONTAINER_NAME" \
    "${USERNS_ARGS[@]}" \
    -v "$fixture_home:/host-home:ro" \
    -e "HOST_SHELL=/bin/bash" \
    -e "COPY_DOTFILES=0" \
    "$IMAGE_TAG" \
    || fail "container start with COPY_DOTFILES=0 failed"
sleep 2

if "$ENGINE" exec "$CONTAINER_NAME" test -f "/home/dev/.bashrc" 2>/dev/null; then
    "$ENGINE" exec "$CONTAINER_NAME" grep -q "fake bashrc" /home/dev/.bashrc \
        && fail "COPY_DOTFILES=0 should not have copied .bashrc"
fi

# --- Task 7: default shell selection ---

"$ENGINE" rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
"$ENGINE" run -d --name "$CONTAINER_NAME" \
    "${USERNS_ARGS[@]}" \
    -v "$fixture_home:/host-home:ro" \
    -e "HOST_SHELL=/usr/bin/zsh" \
    -e "COPY_DOTFILES=1" \
    "$IMAGE_TAG" \
    || fail "container start (zsh) failed"
sleep 2

shell_for_dev=$("$ENGINE" exec "$CONTAINER_NAME" getent passwd dev | cut -d: -f7) \
    || fail "getent passwd dev failed"
[ "$shell_for_dev" = "/usr/bin/zsh" ] || fail "expected /usr/bin/zsh as dev shell, got $shell_for_dev"

# Fallback to bash for an unknown shell.
"$ENGINE" rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
"$ENGINE" run -d --name "$CONTAINER_NAME" \
    "${USERNS_ARGS[@]}" \
    -v "$fixture_home:/host-home:ro" \
    -e "HOST_SHELL=/usr/bin/fish" \
    -e "COPY_DOTFILES=1" \
    "$IMAGE_TAG" \
    || fail "container start (fish fallback) failed"
sleep 2

shell_for_dev=$("$ENGINE" exec "$CONTAINER_NAME" getent passwd dev | cut -d: -f7)
[ "$shell_for_dev" = "/bin/bash" ] || fail "expected /bin/bash fallback, got $shell_for_dev"

echo "PASS: dev container build smoke + dotfile snapshot + shell selection"
