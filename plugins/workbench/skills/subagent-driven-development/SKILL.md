---
name: subagent-driven-development
description: Use when executing an implementation plan with fresh subagents, task ownership, and review gates in the current session.
---

# Subagent-Driven Development

Execute an implementation plan by giving each task a focused implementation agent, then running two review gates before moving on.

Core rule: the main session coordinates. Agents implement or review bounded work. The main session integrates, verifies, and decides when to proceed.

## When To Use

Use this skill when:

- An implementation plan already exists.
- The plan has checkbox tasks or similarly bounded steps.
- Tasks can be assigned with clear ownership.
- The current runtime has subagent support, or the main session can follow the same task discipline sequentially.

If there is no plan yet, use `workbench:writing-plans` first. If implementation is starting, use `workbench:test-driven-development` before writing production code.

## Task Loop

For each plan task:

1. Paste the task text into the agent prompt.
2. Define ownership: files, directories, or behavior the agent may change.
3. Include acceptance criteria and verification commands.
4. Tell the agent it is not alone in the codebase and must not revert edits made by others.
5. Wait for the implementation agent to return.
6. Run the spec compliance reviewer.
7. Fix any spec gaps and re-review.
8. Run the code quality reviewer.
9. Fix any quality issues and re-review.
10. Mark the task complete only after both review gates pass.

## Two review gates

Spec compliance reviewer:

- Confirms the implementation matches the plan and spec.
- Flags missing requested behavior.
- Flags extra behavior that was not requested.

Code quality reviewer:

- Checks maintainability, local patterns, tests, error handling, and integration risk.
- Focuses on bugs and regressions, not style preferences.
- Approves only when important issues are resolved.

Do not start the code quality reviewer until spec compliance passes.

## Implementation agent prompt

```md
Implement this plan task:

[paste one checkbox task]

Ownership:
- You may edit: [files or directories]
- Do not edit: [files or directories]

Context:
- Relevant spec or plan excerpt.
- Relevant prior commits or decisions.

Rules:
- Use workbench:test-driven-development.
- You are not alone in the codebase. Do not revert edits made by others.
- Keep the change minimal.

Return:
- Status: DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, or BLOCKED.
- Files changed.
- Verification commands and results.
- Concerns, if any.
```

## Handling Agent Status

`DONE`: proceed to spec compliance review.

`DONE_WITH_CONCERNS`: read the concerns. Fix in-scope correctness, lint, test, or scope concerns before review.

`NEEDS_CONTEXT`: provide the missing context and continue with the same task.

`BLOCKED`: change something before retrying. Provide missing context, split the task, use a more capable model, or stop if the plan is wrong.

## Parallelism

Default to one implementation task at a time. This keeps review gates simple and avoids shared-state conflicts.

Use `workbench:dispatching-parallel-agents` only when tasks are truly independent and have disjoint write scopes. If tasks share files, generated outputs, schemas, lockfiles, or ordering dependencies, run them sequentially.

Read-only review agents may run in parallel when they review different artifacts.

## Runtime Mapping

Claude Code: use `Agent` with a focused prompt for implementation and review agents.

Codex: use `spawn_agent` for independent sidecar tasks when useful. For urgent blocking work, implement locally and preserve the same task loop. For delegated code edits, assign a disjoint write set and tell the worker not to revert others' changes.

## Completion

After all tasks pass both review gates:

- Run the full relevant verification set.
- Inspect `git status` and `git diff`.
- Use `workbench:verification-before-completion` before claiming the branch is complete or ready.
