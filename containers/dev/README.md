# Dev Container

Podman-first dev container for running Claude Code and Codex with bypass permissions in host-isolated mode.

## Quick Start

```bash
cd containers/dev
./run-dev          # build image (first time), start container, attach shell
./run-dev shell    # attach again later
./run-dev status   # report state
./run-dev stop     # stop the container
./run-dev rebuild  # nuke container + image, start fresh (volumes survive)
```

The container is named `claude-codex-dev` and is reused across projects. Run `run-dev` from each project directory; the project bind mount picks up `$PWD` automatically.

## What Gets Mounted

- `~/.claude` and `~/.codex` (read-write): your existing agent configs.
- `$PWD` to `/workspace` (read-write): the current project.
- Named volume `claude-codex-mise` to `/home/dev/.local/share/mise`: language installs cached across rebuilds.
- Named volume `claude-codex-shell-history` to `/home/dev/.shell_history`: bash and zsh history.

## What Gets Snapshot-Copied at Start

`.bashrc`, `.profile`, `.zshenv`, `.tmux.conf`, `.gitconfig`, `.tmux/`. Set `COPY_DOTFILES=0` before `run-dev` to skip the copy and use a vanilla container shell.

The entrypoint post-processes the copied `.bashrc` so lines that cannot run in the container do not error on every shell start:

- The linuxbrew `shellenv` line is commented out (linuxbrew is not bundled).
- The `. "$HOME/.cargo/env"` line is commented out (mise's Rust install handles cargo on PATH via shims).
- Hard-coded host-home `mise` paths are rewritten to `/home/dev/.local/bin/mise`.

Starship init and mise activate remain functional.

## Bundled Tools

Beyond bash, zsh, tmux, mise, git, and the build dependencies needed by mise, the image includes a small curated CLI set so snapshot-copied dotfiles work without errors and common workflows feel native:

- `ripgrep` (`rg`), `fd-find` (exposed as `fd`), `fzf`, `jq`, `bat` (exposed as `bat`), `eza`, `btop`.
- Via mise: `starship` (prompt), `node@lts` + `npm` (Codex install), `rust@stable` (cargo, rustc).
- Anything else you need: install at runtime inside the container with `mise install <tool>` or `apt install <pkg>`.

## What Is NOT Mounted

`.aws/`, `.ssh/`, `.gnupg/`, `.docker/`, `.cargo/`, `.rustup/`, IDE state. Mise manages language toolchains inside the container instead.

## Engine Support

Podman is the primary target. Docker is a tested-compatible fallback. The wrapper detects `podman` first, then `docker`. Override with `CONTAINER_ENGINE=docker run-dev`.

Rootless podman remaps container UIDs into a subordinate range by default, which would make a bind-mounted host home (mode 0750) unreadable to the container's `dev` user. The wrapper passes `--userns=keep-id` for podman so the host UID stays the same inside the container, and the `dev` user owns the bind-mounted files. For docker (no default user namespace remapping), the wrapper passes `--user $(id -u):$(id -g)` instead.

## First-Run Costs

- Image build: 1-3 minutes.
- Claude and Codex install on first container start: 30-90 seconds.
- mise compile-from-source for a new language version: minutes (Python, Ruby). Cached in the named volume after the first install.

## Manual Acceptance Checklist

After any change to the Dockerfile, entrypoint, or wrapper, run this end-to-end:

- [ ] Take a hash of host home contents excluding the bind mount targets:
      `(cd ~ && find . -path ./.claude -prune -o -path ./.codex -prune -o -path ./Code -prune -o -type f -print0 | sort -z | xargs -0 sha256sum) | sha256sum`
      Save the result.
- [ ] `cd` into a test project (e.g. a fresh git repo under `~/Code/`) and run `./run-dev`.
- [ ] Inside the container, run `claude --dangerously-skip-permissions` (or `codex`) and ask it to make a benign change to the test project.
- [ ] Verify the project change appears on the host (the bind mount is working).
- [ ] Detach with `exit` and run `./run-dev stop`.
- [ ] Re-run the host-home hash from step 1 with the same prune list.
- [ ] **Both hashes MUST match.** Any mismatch is a regression of the host-isolation safety claim.

## Troubleshooting

- "neither podman nor docker found": install one or set `CONTAINER_ENGINE`.
- Container starts but `claude` is not on PATH: install URLs may have changed; run `./run-dev rebuild` after updating `CLAUDE_INSTALL_CMD` / `CODEX_INSTALL_CMD` in `entrypoint.sh`.
- mise hangs on first language install: it is compiling from source. Check `~/.local/share/mise/installs/` from inside the container for progress.
