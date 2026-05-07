---
name: dispatching-parallel-agents
description: Use when facing two or more independent tasks that can be worked on concurrently without shared state or sequential dependencies.
---

# Dispatching Parallel Agents

Delegate independent problem domains to separate agents so they can run concurrently while the main session coordinates scope, integration, and verification.

## When To Use

Use this skill when all of these are true:

- There are two or more independent failures, investigations, or edits.
- Each task can be understood with its own focused context.
- Each task has a disjoint write scope, or is read-only.
- The result of one task is not needed before another can start.

Common cases:

- Different failing test files with different likely root causes.
- Independent package or module updates.
- Multiple read-only codebase surveys.
- Separate documentation updates in unrelated directories.

## Do not use when

- Failures are likely symptoms of one shared root cause.
- Tasks edit the same files, generated artifacts, shared schemas, lockfiles, or global configuration.
- One task depends on another task's result.
- You need a single coherent system diagnosis before splitting work.

When in doubt, do one short local pass to classify the work before dispatching agents.

## Process

1. Identify independent domains. Name the task, files, and expected output for each domain.
2. Confirm disjoint write scopes. If two tasks might touch the same file, run them sequentially or merge them into one task.
3. Dispatch agents in parallel. Give each agent only the context it needs.
4. Keep the main session as coordinator. Do not duplicate the delegated work locally.
5. Review returned summaries and diffs.
6. Run the combined verification command after integration.

## Prompt Shape

Each agent prompt should include:

- The exact problem domain.
- Files or directories the agent owns.
- Files or directories it must not edit.
- Relevant failure output or acceptance criteria.
- Expected final report format.

Example:

```md
Investigate and fix failures in tests/unit/test-calendar-skill.sh.

Ownership: tests/unit/test-calendar-skill.sh and plugins/google-workspace/skills/calendar/SKILL.md.
Do not edit Gmail, Jira, Confluence, or Workbench files.

Return:
- Root cause.
- Files changed.
- Verification command and result.
```

## Runtime Mapping

Claude Code: dispatch multiple `Agent` calls in one message when scopes are independent.

Codex: use `spawn_agent` for independent sidecar work, or execute sequentially when subagents are unavailable. For code edits, give each worker a disjoint write set and tell it not to revert other workers' edits.

## Integration Checklist

- Read every returned summary before committing.
- Inspect `git status` and `git diff`.
- Resolve conflicts in the main session.
- Run the full relevant test set after all agent work lands.
- If one agent's result changes another agent's assumptions, re-verify the affected task.
