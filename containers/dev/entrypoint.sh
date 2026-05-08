#!/usr/bin/env bash
# containers/dev/entrypoint.sh
set -euo pipefail

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

# Comment out lines in copied dotfiles that reference binaries deliberately
# not bundled in this container, so the user does not see one-off errors on
# every shell start. Currently: linuxbrew shellenv (linuxbrew is too heavy to
# bundle).
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

if [ "${COPY_DOTFILES:-1}" = "1" ]; then
    snapshot_dotfiles
    neutralize_unsupported_lines
fi
select_default_shell

exec tail -f /dev/null
