#!/usr/bin/env bash
# containers/dev/entrypoint.sh
set -euo pipefail

CLAUDE_INSTALL_CMD='curl -fsSL https://claude.ai/install.sh | bash'
CODEX_INSTALL_CMD='npm install -g @openai/codex && mise reshim'

DOTFILES=(.bashrc .profile .zshenv .tmux.conf .gitconfig)
DOTDIRS=(.tmux)

snapshot_dotfiles() {
    local src=/host-home
    local dst=/home/dev
    [ -d "$src" ] || return 0
    for f in "${DOTFILES[@]}"; do
        if [ -f "$src/$f" ]; then
            cp -f "$src/$f" "$dst/$f"
        fi
    done
    for d in "${DOTDIRS[@]}"; do
        if [ -d "$src/$d" ]; then
            cp -rf "$src/$d" "$dst/$d"
        fi
    done
}

neutralize_unsupported_lines() {
    local target=/home/dev/.bashrc
    [ -f "$target" ] || return 0
    # Comment out linuxbrew shellenv (linuxbrew is not bundled).
    sed -i 's|^\(eval "\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv.*\)|# disabled in container: \1|' "$target"
    # Comment out cargo env source (mise's rust install handles cargo on PATH;
    # ~/.cargo/env does not exist inside the container).
    sed -i 's|^\(\. "\$HOME/\.cargo/env".*\)|# disabled in container: \1|' "$target"
    sed -i 's|^\(\. "/home/[^/]*/\.cargo/env".*\)|# disabled in container: \1|' "$target"
    # Rewrite hard-coded host-home mise binary paths to the container path.
    sed -i 's|/home/[^/]*/\.local/bin/mise|/home/dev/.local/bin/mise|g' "$target"
}

select_default_shell() {
    local requested="${HOST_SHELL:-/bin/bash}"
    if [ -x "$requested" ]; then
        sudo chsh -s "$requested" dev
    else
        sudo chsh -s /bin/bash dev
    fi
}

install_agents() {
    if ! command -v claude >/dev/null 2>&1; then
        eval "$CLAUDE_INSTALL_CMD"
    fi
    if ! command -v codex >/dev/null 2>&1; then
        eval "$CODEX_INSTALL_CMD"
    fi
}

if [ "${COPY_DOTFILES:-1}" = "1" ]; then
    snapshot_dotfiles
    neutralize_unsupported_lines
fi
select_default_shell
install_agents

exec tail -f /dev/null
