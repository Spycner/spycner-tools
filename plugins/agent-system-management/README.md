# agent-system-management

Manage the host agent's instruction layer and skill layer in any runtime: audit and update `AGENTS.md` / `CLAUDE.md` files (and their variants), capture session learnings, and scaffold or iterate on Claude Code / Codex skills.

Three skills:

| | Purpose | Triggered by |
|---|---|---|
| `improving-instructions` | Periodic cold audit of agent-instruction files | "audit my CLAUDE.md", "check if AGENTS.md is up to date" |
| `capturing-session-learnings` | End-of-session warm capture of learnings | "/revise-agents-md", "update AGENTS.md with what we learned this session" |
| `creating-skills` | Full skill lifecycle (scaffold, iterate, pressure-test, optimize description, extract from session) | "scaffold a new skill", "iterate on this skill", "pressure-test", "turn this conversation into a skill" |

Works in Claude Code and Codex CLI. Files are deduped via `realpath`, so `CLAUDE.md` symlinked to `AGENTS.md` counts as one logical file.

## Files in scope (instruction skills)

- `AGENTS.md`, `AGENTS.local.md`
- `CLAUDE.md`, `CLAUDE.local.md`
- `.claude.md`, `.claude.local.md` (legacy lowercase from upstream)
- `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` (user-global, included so generalizable rules can be hoisted)

`GEMINI.md` and other runtime variants are out of scope.

## Usage

```text
audit my CLAUDE.md files
check if AGENTS.md is up to date
update AGENTS.md with what we learned this session
/revise-agents-md
/revise-claude-md
scaffold a new skill in this marketplace
iterate on this skill until it triggers reliably
pressure-test this discipline skill
turn this conversation into a reusable skill
```

## Credits

The `improving-instructions` and `capturing-session-learnings` skills are derived from Anthropic's [`claude-md-management`](https://github.com/anthropics/claude-plugins/tree/main/plugins/claude-md-management) plugin by Isabella He, licensed under Apache 2.0. The reference docs under `skills/improving-instructions/references/` are imported verbatim. See `NOTICE` for full attribution.

This plugin is licensed MIT (`LICENSE`).
