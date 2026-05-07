# Example Workbench Autopilot Profiles

Two examples in one file. Copy whichever shape fits and adapt.

## Example 1: Recommended minimum

The smallest profile that does anything explicit. Use this as the starting point for a new project.

```md
# Workbench Autopilot Profile

## PR behavior
Mode: stop_at_green
```

That is the entire file. Defaults cover everything else: branch detected from `git symbolic-ref`, task runner detected from `mise.toml` / `Makefile` / `package.json`, doc paths inferred from existence, no overrides on the universal required-skills table, no hooks. Autopilot stops at green CI; you merge manually.

## Example 2: Kitchen sink

Every optional heading populated. This is what a fully-tuned project profile looks like (fictional project `widgetshop`).

```md
# Workbench Autopilot Profile

## Project name
widgetshop

## Branching
Default branch: master
Branch prefixes: feat, fix, docs, chore, refactor, test, perf, style, ci, build, revert

## Commands
Task runner: mise run
Lint: lint
Test: test
Format: fmt

## Documentation paths
Specs: don't commit
Plans: don't commit
Open things: docs/superpowers/OPEN_THINGS.md
ADRs: docs/adr

## PR behavior
Mode: automerge
Base branch: master
Squash: yes

Hooks:
- post_pr: uv run .claude/commands/post_brainstorm_comments.py {{pr}}
- post_ci_green: ./scripts/notify-slack.sh "{{pr}} merged"

## Required skills
| Step | Skill | Action |
|---|---|---|
| 4 | my-project:writing-plans | replaces workbench:writing-plans |
| 6 | widgetshop:regenerate-changelog | additional |

## Project-specific rules

Before any step that runs Python tests touching `widget_solver` (the maturin-built PyO3 binding), if an earlier task in the same autopilot run modified `solver/solver-core/` or `solver/solver-py/`, run `mise run solver:rebuild` first. A stale binding will surface phantom wire-format errors that look like real bugs.

After backend Pydantic schema changes, regenerate frontend API types with `mise run fe:types` before any task that touches `frontend/src/api/`.

Use `mise exec --` for `git push` so the pinned lefthook runs.
```

## When to omit a heading

If the same information already lives in your project's `CLAUDE.md` or `AGENTS.md`, omit the heading from the profile. The autopilot skill reads project information in this order: profile → session context (`CLAUDE.md`, `AGENTS.md`) → git/filesystem detection → ask the user.

For example, if `CLAUDE.md` already says "default branch is master" and "use `mise run` for tasks," your profile can drop both `## Branching` and `## Commands`. The kitchen-sink example duplicates them only to show the full vocabulary.

## What stays autopilot-coupled

Some things genuinely belong in the profile rather than `CLAUDE.md`:

- `## PR behavior` and `Hooks`: workflow policy, not project info.
- `## Required skills`: overrides on autopilot's audit table, only meaningful in autopilot's context.
- `## Project-specific rules` that govern the autopilot run itself (like the solver-rebuild ordering above): autopilot-coupled, even if the underlying fact (the binding) is also a `CLAUDE.md` topic.

When in doubt: if the rule only matters during an autopilot run, put it in the profile. If it's a general project fact, put it in `CLAUDE.md` or `AGENTS.md`.
