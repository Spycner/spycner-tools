---
name: claude-codex-bridge
description: Use when the user wants to port a project so it works with both Claude Code and Codex CLI; or wants to detect drift between CLAUDE.md and AGENTS.md (and other paired runtime artifacts); or wants to check whether installed plugins/skills are available in both runtimes. Bidirectional. Auto-detects direction from what exists.
---

# Claude ↔ Codex Bridge Skill

Bidirectional alignment of a project's Claude Code and Codex CLI configuration. Detects what runtime artifacts exist, produces the missing side, surfaces drift, reports plugin availability across runtimes. Pure file-level operation; never edits skill content.

---

## Auth Approach

No authentication required. Operates on the local filesystem only. Never makes network calls.

## Tool Preference

1. Subagent dispatch (when available and permitted) for scout, apply, reviewer phases.
2. File read tools for loading prompt templates and reading project files.
3. Shell for filesystem operations (`ln -s`, `mkdir -p`, `find`, `stat`).
4. User confirmation tool for the manifest approval gate and policy decisions.

## Platform Adaptation

| Capability | Claude Code | Codex |
|---|---|---|
| Subagent dispatch | Agent tool, prompt = `read(<phase>-prompt.md)` + scope vars | `spawn_agent` with the same prompt |
| User confirmation | AskUserQuestion | `ask_user` / built-in approval |
| File ops (apply phase) | Write, Edit, Bash (`ln -s`) | shell tool |
| File reads | Read | shell reads (`cat`, `sed`, etc.) |
| Shell | Bash | shell command tool |

When subagent dispatch is unavailable for the current request, run each phase inline in the orchestrator. Tell the user runtime/context cost has changed.

## Workflow

### Step 1: Confirm scope and mode

If the user hasn't specified, ask one consolidated question: target directory (default: cwd) and dry-run vs full execution. Skip if both are obvious from context.

### Step 2: Dispatch SCOUT

Read `scout-prompt.md`. Dispatch as a subagent with arguments:
- `repo_root`: absolute path to the project root.
- `recipes_path`: absolute path to `port-recipes.md`.
- `schema_path`: absolute path to `manifest-schema.md`.

Scout returns a JSON manifest matching `manifest-schema.md`. Validate it parses (use `jq empty` or equivalent). If invalid, surface the error to the user; do not continue.

### Step 3: Present manifest, get approval

Render the manifest for the user:
- Direction (claude_to_codex / codex_to_claude / bidirectional_drift).
- Op count by kind.
- Each op with the source path, target path, and (for translates and drifts) the diff preview.
- Skip list with reasons.
- Plugin report bucketed (dual / Claude-only / Codex-only).
- Notes (free-form).
- If `trust_warning` is present: include the line "After apply, run `codex` once in this dir and accept the trust prompt; `.codex/` artifacts no-op on untrusted projects."

For drift ops, ask the user to confirm the suggested canonical or pick the other side.

If dry-run: stop here. Print the manifest summary as the final report.

Otherwise: ask the user to approve the full op set. If approved, continue. If declined, stop.

### Step 4: Dispatch APPLY

Read `apply-prompt.md`. Dispatch as a subagent with arguments:
- `manifest`: the approved manifest (with any user drift selections applied).
- `recipes_path`: absolute path to `port-recipes.md`.
- `repo_root`: absolute path.

Apply returns a JSON apply-log matching `manifest-schema.md`. Validate it parses.

### Step 5: Dispatch REVIEWER

Read `reviewer-prompt.md`. Dispatch as a subagent with arguments:
- `manifest`: the same manifest apply consumed.
- `apply_log`: what apply returned.
- `recipes_path`: absolute path to `port-recipes.md`.
- `repo_root`: absolute path.

Reviewer returns a verdict matching `manifest-schema.md`.

### Step 6: Decide loop

If verdict is `pass`: go to Step 7.

If verdict has issues, classify:

- Any `unauthorized_change` issue: STOP. Print final report including the unauthorized change. Do not loop.
- Same issue (same kind + same op_index) appears two rounds in a row: STOP. Stalling.
- Issue requires user decision (drift the user already chose canonical for; translation key with no defensible default): STOP. Surface to user.
- Issue requires action apply cannot perform (mark project trusted in Codex; install a missing plugin): STOP. Surface to user.
- Otherwise (mechanical, in-scope): construct a focused manifest containing only the affected ops + the reviewer's `suggested_fix` text. Dispatch APPLY again with this focused manifest. Then dispatch REVIEWER again. Track issues across rounds for the stalling check.

No fixed iteration cap. Loop until pass or break condition.

### Step 7: Final report

Print to user:
- Direction.
- Ops applied (success count, error count).
- Skips with reasons and suggested followups.
- Plugin report.
- Notes.
- Reviewer verdict.
- Outstanding issues (if any) with detail and suggested_fix verbatim.
- Trust gate reminder if `.codex/` was written.

## Invocation forms

- "Make this project work with codex too" triggers a Claude → Codex full run.
- "I want this codex project to also work in claude code" triggers a Codex → Claude full run.
- "My CLAUDE.md and AGENTS.md are out of sync" triggers bidirectional drift mode.
- "Is this project set up for both runtimes" implies dry-run.
- Add "dry run" or "preview only" to any of the above for dry-run mode.

## Self-Healing

- Manifest fails to parse: surface the raw scout output to the user; suggest re-running.
- Apply errors on a specific op (e.g. `EACCES`): logged in apply-log, reviewer surfaces as `missing`, orchestrator stops with outstanding issue.
- Reviewer disagrees with apply but issue kind is unclear: surface verbatim; user decides.
- Subagent dispatch unavailable: run phases inline. Manifest, apply, and review are still produced; user still sees the two checkpoints.

## Behavioral Guidelines

- Never modify skill content.
- Never run network requests.
- Never apply ops the user did not approve.
- Never touch paths outside the manifest.
- When in doubt about canonical (drift), suggest newer-mtime side and ask the user.
- For Codex writes, always include the trust gate reminder.

See `manifest-schema.md` and `port-recipes.md` for the data contract and translation rules.
