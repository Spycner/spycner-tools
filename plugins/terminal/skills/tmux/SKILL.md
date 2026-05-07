---
name: tmux
description: Use when the user wants to control interactive terminal programs through tmux, drive REPLs, debuggers, TUI tools, or experiment with steering nested Claude Code or Codex CLI sessions by sending keys and reading pane output.
---

# tmux Skill

Use `tmux` as a programmable terminal for interactive CLIs that do not fit plain `exec` commands. This skill is for Linux, macOS, and WSL. Native Windows terminals are out of scope.

---

## Auth Approach

No authentication is required. Attempt the `tmux` command first. If it fails, diagnose missing `tmux`, missing WSL, a dead socket, or a stale session.

## Tool Preference

Use the host shell tool to run `tmux` directly. Do not add helper scripts. Keep sessions on a private socket so agent-controlled panes stay separate from the user's personal tmux server.

Platform mapping:

- Claude Code: use the Bash tool for `tmux` commands.
- Codex: use `exec_command` for `tmux` commands and `write_stdin` only for host PTY sessions, not tmux panes.

## Session Convention

Always create a socket directory and use `tmux -S "$SOCKET"`:

```bash
TMUX_SOCKET_DIR="${CLAUDE_TMUX_SOCKET_DIR:-${TMPDIR:-/tmp}/agent-tmux-sockets}"
mkdir -p "$TMUX_SOCKET_DIR"
SOCKET="$TMUX_SOCKET_DIR/terminal.sock"
SESSION="agent-python"
tmux -S "$SOCKET" new-session -d -s "$SESSION" -n shell
```

After starting a session, tell the user how to monitor it:

```bash
tmux -S "$SOCKET" attach -t "$SESSION"
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":. -S -200
```

Repeat the monitor command again when leaving a long-running session open.

Use `"$SESSION":.` for the active pane unless you have inspected pane indexes. This avoids failures on user configs that start window indexes at `1`.

## Operations: Tier 1 (Read)

List sessions on the private socket:

```bash
tmux -S "$SOCKET" list-sessions
```

List panes with targets:

```bash
tmux -S "$SOCKET" list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_title}'
```

Capture recent output from a pane:

```bash
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":. -S -200
```

For full-screen TUIs where style escape codes matter during diagnosis, add `-e`:

```bash
tmux -S "$SOCKET" capture-pane -p -e -J -t "$SESSION":. -S -200
```

Scan all known agent sockets:

```bash
find "${CLAUDE_TMUX_SOCKET_DIR:-${TMPDIR:-/tmp}/agent-tmux-sockets}" -type s -maxdepth 1 -print
```

## Operations: Tier 2 (Write)

Start a new session:

```bash
tmux -S "$SOCKET" new-session -d -s "$SESSION" -n shell
```

Send literal text, then press Enter:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":. -l -- 'python3 -q'
tmux -S "$SOCKET" send-keys -t "$SESSION":. Enter
```

Send control keys:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":. C-c
tmux -S "$SOCKET" send-keys -t "$SESSION":. C-d
```

Poll for prompt text without a helper script:

```bash
deadline=$((SECONDS + 15))
while (( SECONDS < deadline )); do
  pane="$(tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":. -S -200)"
  printf '%s\n' "$pane" | grep -Eq '^>>>' && break
  sleep 0.5
done
printf '%s\n' "$pane" | grep -Eq '^>>>'
```

## Operations: Tier 3 (Manage)

Kill one session when the interactive task is done:

```bash
tmux -S "$SOCKET" kill-session -t "$SESSION"
```

Kill the private server only after confirming no useful sessions remain:

```bash
tmux -S "$SOCKET" kill-server
```

Ask before killing sessions that the user may be monitoring.

## Recipes

Python REPL:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":. -l -- 'PYTHON_BASIC_REPL=1 python3 -q'
tmux -S "$SOCKET" send-keys -t "$SESSION":. Enter
```

Debugger:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":. -l -- 'gdb --quiet ./a.out'
tmux -S "$SOCKET" send-keys -t "$SESSION":. Enter
tmux -S "$SOCKET" send-keys -t "$SESSION":. -l -- 'set pagination off'
tmux -S "$SOCKET" send-keys -t "$SESSION":. Enter
```

Generic TTY program:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":. -l -- 'psql "$DATABASE_URL"'
tmux -S "$SOCKET" send-keys -t "$SESSION":. Enter
```

## Steering Agent Sessions

Use tmux for nested agent CLIs only as an experiment. It can work for observing and steering `codex` or `claude` sessions, but it is more brittle than native subagent tools because prompts, permission flows, and screen updates are text scraped from a terminal pane.

Start a nested Codex session:

```bash
SESSION="agent-codex"
tmux -S "$SOCKET" new-session -d -s "$SESSION" -n codex
tmux -S "$SOCKET" send-keys -t "$SESSION":. -l -- 'codex'
tmux -S "$SOCKET" send-keys -t "$SESSION":. Enter
```

Start a nested Claude Code session:

```bash
SESSION="agent-claude"
tmux -S "$SOCKET" new-session -d -s "$SESSION" -n claude
tmux -S "$SOCKET" send-keys -t "$SESSION":. -l -- 'claude'
tmux -S "$SOCKET" send-keys -t "$SESSION":. Enter
```

Rules for nested agents:

- Keep each nested agent in its own session name and private socket.
- Capture before sending input so you know what state the agent is in.
- Wait several seconds before judging a blank pane. Agent CLIs may start MCP servers or render full-screen UI slowly.
- Prefer plain text prompts and explicit commands.
- Do not paste secrets into panes.
- Expect manual intervention for auth, trust, model selection, plugin prompts, and permission prompts.
- Prefer host-native subagent tools when the goal is normal delegation.

## Self-Healing

If `tmux` is missing, tell the user to install it. On Windows, recommend WSL with `tmux` installed inside the Linux environment.

If a session is missing, run:

```bash
tmux -S "$SOCKET" list-sessions
```

If the pane target is wrong, run:

```bash
tmux -S "$SOCKET" list-panes -a
```

If a poll times out, capture the pane and reason from the visible state instead of blindly sending more input.

## Behavioral Guidelines

- Use tmux only for programs that require a persistent TTY.
- Prefer simple shell commands for non-interactive work.
- Use slug-like session names without spaces.
- Always use `send-keys -l --` for literal text.
- Use `capture-pane -p -J` before deciding the next keystroke.
- Clean up finished sessions.
- Leave monitor commands when a session remains open.
