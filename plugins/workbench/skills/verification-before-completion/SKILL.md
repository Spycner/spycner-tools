---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, passing, ready, or safe to merge, especially before commits, pushes, PRs, or handoff summaries.
---

# Verification Before Completion

Require fresh evidence before any completion claim.

## Core Rule

Do not claim that work is complete, fixed, passing, ready, or safe to merge unless the proving command or check ran after the final relevant edit and its output was read.

Evidence comes before claims.

## Gate

Before claiming status:

1. Identify the command or check that proves the claim.
2. Run the full command or complete the full check.
3. Read the output, exit code, and failure count.
4. Compare the evidence to the claim.
5. Report the actual status with the evidence.

If the evidence does not prove the claim, report the gap instead of softening the wording.

## Required Evidence

| Claim | Required evidence |
|---|---|
| Tests pass | Fresh test output with a passing exit code and no failures |
| Lint is clean | Fresh lint output with a passing exit code |
| Build succeeds | Fresh build output with a passing exit code |
| Bug is fixed | The original symptom or regression test now passes |
| Regression test is valid | Red, green, and restored-green evidence |
| Agent completed work | VCS diff plus relevant verification, not the agent report alone |
| Requirements are met | Re-read checklist or spec and verify each item |
| PR is ready | Local verification plus any required pre-PR checks |

## Red Flags

Stop and verify before using wording like:

- "done"
- "complete"
- "fixed"
- "passes"
- "ready"
- "green"
- "safe to merge"
- "should work"
- "looks good"

Also stop before committing, pushing, opening a PR, handing work back to the user, or moving to the next task.

## Failure Handling

If verification fails:

- State the failing command or check.
- Summarize the relevant error.
- Do not claim completion.
- Either fix and rerun, or report the blocker.

If verification cannot be run:

- State that it was not run.
- Explain the concrete reason.
- Report any partial checks as partial only.

## Reporting Pattern

Use concise evidence:

```text
Verified: bash tests/unit/test-workbench-verification-before-completion-skill.sh, passed.
```

For partial status:

```text
Not fully verified: lint passed, but integration tests were not run because live auth is unavailable.
```

## Behavioral Rules

- Never use prior-session output as proof.
- Never use pre-final-edit output as proof, even if it came from the same turn.
- Never treat confidence as evidence.
- Never treat an agent report as proof without checking the diff and relevant commands.
- Never omit verification results from a completion summary.
- Keep the report short, but include what ran and whether it passed.
