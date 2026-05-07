# Claude Code Adapter for Workbench Autopilot

This doc maps the autopilot skill's tool references to Claude Code tool names and documents Claude-Code-specific patterns. Read alongside `SKILL.md`.

## Tool name mapping

| `SKILL.md` reference | Claude Code tool |
|---|---|
| Skill invocation | `Skill` |
| Subagent dispatch | `Agent` with `subagent_type=general-purpose` for plan tasks |
| Background process / CI polling | `Monitor` for stream-style polling; `run_in_background` for fire-and-forget |
| Shell | `Bash` |
| File ops | `Read`, `Write`, `Edit` |
| GitHub | `gh` (via `Bash`) |

## Subagent dispatch pattern (step 5)

Plan tasks dispatch through `Agent` with `subagent_type=general-purpose`. Three regimes:

### Independent tasks (parallel)

No shared files, no ordering dependency. Invoke `workbench:dispatching-parallel-agents`, then send multiple `Agent` calls in a single message; they run in parallel.

Typical examples:

- Per-package documentation updates that touch different package directories.
- Independent refactors in unrelated modules.
- Multiple entity-page redesigns that do not edit the same i18n catalog.

### Shared-state tasks (sequential)

Tasks that touch the same i18n catalog, the same `app.css`, the same shared route tree, or the same component file. Dispatch one agent at a time, waiting for each to return before dispatching the next. One agent per task; they queue instead of fan out.

Tip: if you can batch all edits to a shared file into a single prep task, the remaining tasks become independent and can run in parallel.

### Trivial polish (main session)

Renaming one symbol, a one-line lint fix, a typo. Use a subagent if the work touches files the main session has not loaded. Skip the subagent only when the main session just made the surrounding edit and still has the file in context.

## Subagent prompt requirements

Each subagent prompt must include:

- The plan task it owns. Paste the checkbox block from the plan.
- Which files to touch.
- Relevant commits that preceded it (one-line summary each).
- Acceptance criteria: tests to run, lint to pass, project-specific rules from the profile that apply.

The main session reviews the agent's diff and commits. The agent should not commit on its own.

## Subagent error recovery

If a subagent errors mid-run (for example "Overloaded"), it may have written files without committing. Before dispatching a continuation:

1. From the main session, run `git status` and `git diff` to see what partial work survived.
2. If the partial work is mostly correct, continue in the main session rather than redispatching. The main session is usually cheaper than retrying when the agent already did the heavy edit.
3. Include a brief "Continuing from subagent state" note in the next commit's body so the review trail is legible.

If a subagent reports `DONE_WITH_CONCERNS` and the concern is in-scope (perf-budget regression, unfixed lint, missing test), fix it before committing, either in the main session or by re-dispatching with the gap added to the acceptance criteria. Do not carry the concern into the PR.

## CI polling shape (step 8)

Use `Monitor` to stream `gh pr view` JSON until checks resolve:

```bash
gh pr view <pr> --json statusCheckRollup -q '.statusCheckRollup[] | "\(.status):\(.conclusion // "")"'
```

Loop until no row's status differs from `COMPLETED` and no conclusion is `FAILURE`, `CANCELLED`, or `TIMED_OUT`.

For human-readable status, `gh pr checks <pr>` works; do not pass `--json` to it (the flag does not exist there). For programmatic polling, the JSON form on `gh pr view` is correct.

## Common Claude Code failure modes

- **`Monitor` consumes context fast.** For long-running CI loops, prefer a tighter poll interval and exit early once the rollup resolves.
- **`Agent` cost.** Each `Agent` invocation has overhead. For tasks the main session can do quickly with files already loaded, do not spawn a subagent purely for hygiene.
- **`gh` auth.** Assume `gh` is already authenticated. If it is not, surface that to the user instead of trying to authenticate inside autopilot.

## See also

- `SKILL.md`: the autopilot orchestration.
- `codex-adapter.md`: the Codex-side mapping.
- `../using-workbench/references/codex-tools.md`: broader Codex tool table.
