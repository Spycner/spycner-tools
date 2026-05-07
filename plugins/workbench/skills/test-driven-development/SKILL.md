---
name: test-driven-development
description: "Use when implementing any feature, bugfix, refactor, or behavior change before writing implementation code. Enforces test-first RED-GREEN-REFACTOR discipline."
---

# Test-Driven Development

Use this skill before implementation work. It governs each small implementation chunk until the change is complete.

## Core Rule

Write the test first. Watch it fail for the expected reason. Write the smallest code that makes it pass. Refactor only after green.

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

If implementation code was written before the test, delete that implementation and restart from the test. Do not keep it as reference material.

## When To Use

Use for:

- New features.
- Bug fixes.
- Refactoring that can change behavior.
- Any user-visible behavior change.

Exceptions require an explicit user decision:

- Throwaway prototypes.
- Generated code.
- Pure configuration changes.

## Red-Green-Refactor

### RED: Write One Failing Test

Write the smallest test that expresses one expected behavior.

Requirements:

- One behavior per test.
- Clear name that describes the expected behavior.
- Real code when possible. Use mocks only when the boundary is external or expensive.
- No broad "works" tests.

### Verify RED

Run the narrowest useful test command.

Confirm:

- The test fails.
- The failure is the expected assertion or missing behavior.
- The failure is not a syntax error, setup error, typo, or unrelated broken test.

If the test passes immediately, it does not prove the new behavior. Fix the test before writing implementation code.

### GREEN: Write Minimal Code

Write only the implementation needed for the failing test.

Do not add:

- Extra options.
- Future-proofing.
- Unrequested error handling.
- Refactors that are not needed for the current test.

### Verify GREEN

Run the narrow test again and confirm it passes. Then run the relevant broader test command for the touched area.

If the test fails, fix implementation code first. Only change the test if the expected behavior is wrong.

### REFACTOR

After green only:

- Improve names.
- Remove duplication.
- Move code into existing local patterns.

Keep the same tests green after every refactor.

## Good Tests

| Quality | Good | Bad |
|---|---|---|
| Minimal | One behavior. | A test name with "and" covering multiple behaviors. |
| Clear | Name states the expected behavior. | `test1` or `works`. |
| Behavior-focused | Exercises public behavior. | Checks private implementation details. |
| Repeatable | Runs without manual state. | Depends on local setup not created by the test. |

## Common Rationalizations

| Excuse | Response |
|---|---|
| "Too simple to test." | Simple code still breaks. Write the small test. |
| "I'll test after." | Tests written after implementation can pass without proving they catch the missing behavior. |
| "I already manually tested it." | Manual checks are not repeatable regression coverage. |
| "The existing code has no tests." | Add the narrowest test around the behavior you are changing. |
| "Keeping the code as reference is harmless." | Reference code biases the test. Delete it and restart test-first. |
| "TDD is slowing me down." | Debugging untested behavior is usually slower than proving it incrementally. |

## Red Flags

Stop and restart the chunk if any of these happen:

- Implementation code before a failing test.
- Test added after implementation.
- Test passes immediately.
- You cannot explain the failure.
- The failure is from setup or syntax instead of missing behavior.
- You are rationalizing "just this once."
- You are adapting code that was written before the test.

## Workflow With Plans

When executing a Workbench implementation plan, this skill is invoked as `workbench:test-driven-development`:

1. Take one checkbox implementation chunk.
2. Write or update the test first.
3. Run the exact command and capture the expected failure.
4. Implement the smallest passing change.
5. Run the exact command and relevant broader checks.
6. Mark the chunk complete only after green.

If a chunk is too large to test first, split the chunk. Hard-to-test behavior is usually underspecified or poorly isolated.

## Runtime Notes

Use the test runner documented by the project. In this repository, prefer deterministic filesystem checks for skill structure and run the frontmatter lint after changing any `SKILL.md`.
