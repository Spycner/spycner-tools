---
name: writing-plans
description: "Use when a design spec or approved requirements need to become a concrete, step-by-step implementation plan before code changes."
---

# Writing Plans

Write implementation plans that a fresh agent can execute task by task without guessing.

## Overview

Use this after `workbench:writing-spec` or after the user provides approved requirements. The output is a concrete plan with exact file paths, bite-sized checkbox steps, test commands, expected results, and commit points.

Assume the implementer is a capable engineer with little project context. Give them enough detail to work correctly, but keep the plan focused on the requested change. DRY, YAGNI, TDD, and frequent commits are the default.

## Path Resolution

Resolve the plan path in this order:

1. `.workbench/autopilot.md` `Plans:` heading.
2. Project `CLAUDE.md` or `AGENTS.md` plan-path convention.
3. `docs/workbench/plans/YYYY-MM-DD-<feature-name>.md`.

If the resolved value is `don't commit`, write the plan to `/tmp/<project-name>-autopilot/YYYY-MM-DD-<feature-name>.md` and skip committing it.

## Scope Check

Before writing tasks, check whether the spec covers multiple independent subsystems. If it does, stop and split it into separate plans, one per independently testable change.

Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map which files will be created or modified and what each file is responsible for.

- Use exact paths.
- Follow existing project patterns.
- Keep files focused on one responsibility.
- Keep related changes together.
- Include a split only when it is directly needed for this work.

This file map governs the task decomposition.

## Bite-Sized Task Granularity

Each checkbox step should be one small action:

- Write the failing test.
- Run the test and confirm the expected failure.
- Implement the smallest passing change.
- Run the test and confirm it passes.
- Commit the logical chunk.

Avoid broad steps that require the implementer to invent missing details.

## Plan Document Header

Every plan MUST start with this header:

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:test-driven-development` for implementation chunks. Use `superpowers:subagent-driven-development` when independent tasks can be delegated, or execute sequentially in the main session when subagents are unavailable. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about the approach]

**Tech Stack:** [Key technologies, libraries, and commands]

---
```

## Task Structure

Use this shape for each task:

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/new-file.ext`
- Modify: `exact/path/to/existing-file.ext`
- Test: `tests/exact/path/to/test-file.ext`

- [ ] **Step 1: Write the failing test**

```language
complete test code
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `exact test command`
Expected: FAIL with the missing behavior or assertion named explicitly.

- [ ] **Step 3: Write the minimal implementation**

```language
complete implementation code or precise patch-sized instructions
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `exact test command`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add exact/path/to/test-file.ext exact/path/to/existing-file.ext
git commit -m "type(scope): describe the change"
```
````

## No Placeholders

Never write plan steps that leave work to interpretation:

- `TBD`, `TODO`, `implement later`, or `fill in details`.
- Generic instructions such as "add appropriate error handling" or "handle edge cases".
- "Write tests for the above" without concrete test code or exact assertions.
- "Similar to Task N". Repeat the relevant details because tasks may be read independently.
- Code steps that omit the code, command, expected output, or file path.
- References to types, functions, files, or methods not introduced by the plan or already present in the codebase.

## Plan Review

After writing the plan, dispatch a fresh-eyes reviewer subagent before presenting it. The reviewer should not receive the conversation history. Give it only the plan path, the source spec or requirements path when available, and the prompt template in `plan-reviewer-prompt.md`.

Claude Code: `Agent` tool, `general-purpose` subagent_type, no model override.
Codex: equivalent general-purpose subagent.

The reviewer checks:

1. Spec coverage: each requirement maps to at least one task.
2. Placeholder scan: the plan contains none of the forbidden placeholder patterns.
3. Type and name consistency: later tasks use the same file names, function names, types, and command names introduced earlier.
4. Testability: every implementation task has a command that proves the change.
5. Scope: the plan still fits one coherent implementation sequence.

Apply the reviewer's blocking findings inline. No re-review is required. Advisory recommendations do not block handoff unless they expose a real implementation risk.

## Execution Handoff

After saving the plan, report the path and offer the execution route that fits the runtime:

```text
Plan complete and saved to `<path>`.

Recommended execution: use `superpowers:test-driven-development` for each implementation chunk. If subagents are available, use `superpowers:subagent-driven-development`; otherwise execute the checkbox steps sequentially in this session.
```

Do not start implementation until the plan is saved, the reviewer pass is complete, and the required implementation discipline is clear.
