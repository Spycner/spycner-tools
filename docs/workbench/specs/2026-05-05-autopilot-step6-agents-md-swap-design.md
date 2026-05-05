# Autopilot Step 6: Swap to agents-md-management

**Status:** Approved (brainstorm)
**Date:** 2026-05-05
**Author:** Pascal Göllner

## Goal

Replace the upstream `claude-md-management` skill invocations in workbench autopilot's step 6 with this repo's `agents-md-management` skills. Adjust step 6's prose, dispatch architecture, and bullet list to match the new skills' broader scope (AGENTS.md and CLAUDE.md across project, local, and user-global variants).

## Current state

Autopilot step 6 ("Finalize docs and improvement pass") currently invokes two upstream skills:

- `claude-md-management:revise-claude-md` (warm session-learning capture)
- `claude-md-management:claude-md-improver` (cold audit)

The skills exist in the upstream Anthropic plugin only. This repo ships `agents-md-management` as a runtime-agnostic fork with two equivalent skills:

- `agents-md-management:agents-md-session-capture` (replaces `revise-claude-md`)
- `agents-md-management:agents-md-improver` (replaces `claude-md-improver`)

The forks differ in scope: the new skills handle AGENTS.md alongside CLAUDE.md, dedupe symlinked pairs via `realpath`, and route learnings across project / `*.local.md` / user-global files by scope.

## Decision summary

| Decision | Choice |
|---|---|
| Skill IDs | `agents-md-management:agents-md-session-capture` + `agents-md-management:agents-md-improver` |
| Order | session-capture first, then improver |
| Dispatch | session-capture in orchestrator (main session); improver in general-purpose subagent |
| Prompt approval skip | autopilot's invocation prompt instructs the skills to apply directly (no skill-side flag) |
| Auto-memory bullet | dropped (Claude-specific per-project memory; durable learnings go through session-capture instead) |
| Doc-drift bullet | dropped (future generic doc-drift skill replaces it) |
| ADR / OPEN_THINGS bullets | unchanged (separate follow-up makes them configurable) |

## File-level changes

| File | Line(s) | Old | New |
|---|---|---|---|
| `plugins/workbench/skills/autopilot/SKILL.md` | 49 (table) | `claude-md-management:revise-claude-md` and `claude-md-management:claude-md-improver` | `agents-md-management:agents-md-session-capture` and `agents-md-management:agents-md-improver` |
| `plugins/workbench/skills/autopilot/SKILL.md` | 151-164 (step 6 body) | see "Step 6 rewrite" below | see "Step 6 rewrite" below |
| `plugins/workbench/skills/autopilot/references/required-skills.md` | 14-15 | `claude-md-management:*` rows | `agents-md-management:*` rows |
| `plugins/workbench/skills/autopilot/references/required-skills.md` | 55 (example prose) | `revise-claude-md` and `claude-md-improver` | `agents-md-session-capture` and `agents-md-improver` |

## Step 6 rewrite

Full replacement for `plugins/workbench/skills/autopilot/SKILL.md` lines 151-164:

```markdown
### Step 6: Finalize docs and improvement pass

**First actions, in order:**

1. Invoke `agents-md-management:agents-md-session-capture` via the `Skill` tool in the main session. This skill reads the conversation transcript, so it must run inline in the orchestrator. Pass the autonomous-mode instruction below.
2. Dispatch `agents-md-management:agents-md-improver` to a general-purpose subagent (Claude Code: `Agent` tool, `general-purpose` subagent_type, no model override. Codex: equivalent general-purpose subagent.) Pass the autonomous-mode instruction below. The improver does a cold audit and does not need session context; running it in a subagent keeps the orchestrator's context lean.

Either skill can be replaced via the profile.

**Autonomous-mode instruction (paste into both invocation prompts):**

> "You are running inside workbench autopilot, on the feature branch in the current working directory. Skip the approval prompt at the end of your skill. After deciding what to change, apply the edits directly. Commit each logical change on the feature branch with a Conventional Commits message. Report back: every file you edited, a one-line summary per file, and (subagent only) the commit hashes you created."

**All edits land on the feature branch in this run.** AGENTS.md, CLAUDE.md, `*.local.md`, user-global agent-instruction files, ADRs, OPEN_THINGS updates: each one a commit on the current branch with a matching Conventional Commits type. No follow-up chore PRs.

After the subagent returns, the orchestrator:

1. Reads the subagent's summary.
2. Verifies the commits exist via `git log <feature-branch> --oneline`.
3. Includes both skills' summaries in the end-of-turn report.

Then:

- Update `<paths.adr>/NNNN-<short-title>.md` for load-bearing decisions if the path exists in the project. Index in `<paths.adr>/README.md`.
- Update `<paths.open_things>` if it exists: remove resolved items, add follow-ups ordered by importance.
```

Note the explicit drops compared to the current text:

- The "Refresh user auto-memory entries for this project" bullet is removed entirely.
- The "Update other project doc files that drifted" bullet is removed entirely.
- The line 157 enumeration ("CLAUDE.md updates, ADRs, OPEN_THINGS updates, auto-memory updates") becomes the broader file list above.

## Subagent dispatch contract (the improver)

The orchestrator dispatches the improver *after* session-capture's commits have landed, so the subagent sees the latest file state.

The dispatch prompt must include:

- The working directory (the feature-branch worktree the orchestrator is in).
- The Skill invocation: `agents-md-management:agents-md-improver`.
- The autonomous-mode instruction (above).
- Conventional Commits guidance: type `docs`, scope `agents-md` or similar; one commit per logical change.
- Acceptance criteria: report every edited file, a one-line summary per file, and the commit hashes.

The orchestrator does not pre-read the agent-instruction files; the subagent does that work via the skill itself.

## Autonomous-mode contract

The skills stay interactive-by-default for non-autopilot callers. Autopilot's invocation prompt carries the autonomous-mode override. This keeps the change scoped to workbench (no cross-plugin coupling with `agents-md-management`).

If a future runtime change forces the approval prompt to be a hard gate (e.g., the skill calls `AskUserQuestion` in a way the orchestrator cannot suppress), the fallback is to add an explicit autonomous-mode flag/parameter to the two skills. The author owns both plugins, so this fallback is cheap if needed.

## Out of scope (future work)

Three follow-ups surfaced during brainstorm. They stay out of this change but are tracked here so they aren't lost:

1. **Pluggable issue tracking.** Project profile names where to route tech debt and follow-ups: `OPEN_THINGS` file vs GitHub issues vs Linear vs other. Step 6's OPEN_THINGS bullet generalizes once this lands.
2. **Optional / configurable ADRs.** Some projects do not want an ADR practice. Profile flag to disable the ADR bullet, or to point at a different decision-log convention.
3. **Generic doc-drift skill.** Replaces the dropped "doc files that drifted" bullet. Takes a path list and a diff, audits each doc against the diff, proposes edits. Reusable outside autopilot.

## Testing

Autopilot is a discipline-skill (instructions to the host agent), not executable code, so testing is structural and triggering-level:

- **Structural unit test** (existing pattern in `tests/unit/`): grep autopilot's `SKILL.md` and `references/required-skills.md` for the new skill IDs; assert the old `claude-md-management:*` strings are absent. Guards against regression.
- **Manual smoke test**: run autopilot end-to-end on a throwaway branch in this repo. Verify (a) session-capture runs in the main session, (b) improver runs as a subagent and commits, (c) no approval prompts surface, (d) the end-of-turn summary shows both skills' edits.
- **Existing skill-triggering tests**: if any reference autopilot, they should still pass after the swap.

No new integration test is needed; `agents-md-management` ships its own unit tests.

## Risks

- **Prompt-override fragility.** The autonomous-mode instruction relies on the host agent honoring an inline instruction to skip the skill's own approval gate. The author owns both plugins and can fall back to an explicit skill-side flag if the inline approach breaks.
- **Breaking change for downstream profiles.** Existing user profiles with `replace` or `additional` rows referencing the old `claude-md-management:*` IDs would silently fail the audit. No such profile exists in this repo, but the workbench changelog and README should call out the rename for any downstream user.

## Rollout

The change is contained to two files in `plugins/workbench/skills/autopilot/`. Workbench version bump (patch or minor; minor since step 6 behavior shifts). Changelog entry mentions the rename and the dropped bullets.
