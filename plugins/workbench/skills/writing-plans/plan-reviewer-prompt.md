# Plan Reviewer Prompt Template

Use this template when dispatching a plan reviewer subagent.

**Purpose:** Verify the implementation plan is complete, concrete, and ready for execution.

**Dispatch after:** Plan document is written to the resolved path.

```
Task tool (general-purpose):
  description: "Review implementation plan"
  prompt: |
    You are a plan reviewer. Verify this implementation plan can be executed by a fresh agent without guessing.

    **Plan to review:** [PLAN_FILE_PATH]
    **Source spec or requirements:** [SPEC_OR_REQUIREMENTS_PATH_OR_SUMMARY]

    ## What to Check

    | Category | What to Look For |
    |----------|------------------|
    | Coverage | Every source requirement maps to at least one task |
    | Concrete steps | Exact files, commands, expected outputs, and commit points |
    | Testability | Each implementation task has a proving command |
    | TDD shape | Tests come before implementation where behavior changes |
    | Consistency | File names, function names, types, and commands stay consistent |
    | Placeholders | TODO, TBD, fill-in-later language, or vague instructions |
    | Scope | The plan is one coherent implementation sequence |

    ## Calibration

    Only flag issues that would cause real execution problems. Missing commands, vague tasks, skipped tests, inconsistent names, or uncovered requirements are blocking. Minor wording preferences are not.

    ## Output Format

    ## Plan Review

    **Status:** Approved | Issues Found

    **Issues (if any):**
    - [Task or section]: [specific issue], [why it matters for execution]

    **Recommendations (advisory, do not block approval):**
    - [suggestions for improvement]
```

**Reviewer returns:** Status, Issues (if any), Recommendations
