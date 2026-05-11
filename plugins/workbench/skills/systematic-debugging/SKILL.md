---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

## Overview

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

Use for ANY technical issue:
- Test failures
- Bugs in production
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work
- You don't fully understand the issue

**Don't skip when:**
- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (rushing guarantees rework)
- Manager wants it fixed NOW (systematic is faster than thrashing)

## The Four Phases

You MUST complete each phase before proceeding to the next. Each phase below is the orchestrator-level summary; the full step-by-step walk-through, including multi-component evidence-gathering, the architecture-questioning escape hatch, and the "no root cause" edge case, lives in `four-phases.md` in this directory.

### Phase 1: Root Cause Investigation

Read errors carefully, reproduce consistently, check recent changes, and gather evidence at every component boundary in multi-layer systems before forming any theory. If the error is deep in a call stack, trace data flow backward to the source.

See `four-phases.md` for the full Phase 1 procedure and `root-cause-tracing.md` for the backward tracing technique.

### Phase 2: Pattern Analysis

Find similar working code, read reference implementations completely (no skimming), enumerate every difference between working and broken, and understand all dependencies before fixing.

See `four-phases.md` for the full Phase 2 procedure.

### Phase 3: Hypothesis and Testing

Form one specific hypothesis ("I think X is the root cause because Y"), make the smallest possible change to test it, change one variable at a time, and form a new hypothesis on failure rather than stacking fixes.

See `four-phases.md` for the full Phase 3 procedure.

### Phase 4: Implementation

Create a failing test case before fixing anything, implement one targeted fix at the root cause (no bundled refactoring), and verify. **If 3+ fixes have failed: stop and question the architecture.** That pattern means the design is wrong, not the hypothesis.

See `four-phases.md` for the full Phase 4 procedure including the architecture-questioning protocol.

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare | Identify differences |
| **3. Hypothesis** | Form theory, test minimally | Confirmed or new hypothesis |
| **4. Implementation** | Create test, fix, verify | Bug resolved, tests pass |

## Red Flags - STOP and Follow Process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow
- **"One more fix attempt" (when already tried 2+)**
- **Each fix reveals new problem in different place**

**ALL of these mean: STOP. Return to Phase 1.**

**If 3+ fixes failed:** Question the architecture (see Phase 4 in `four-phases.md`).

## Your Human Partner's Signals You're Doing It Wrong

**Watch for these redirections:**
- "Is that not happening?" - You assumed without verifying
- "Will it show us...?" - You should have added evidence gathering
- "Stop guessing" - You're proposing fixes without understanding
- "Ultrathink this" - Question fundamentals, not just symptoms
- "We're stuck?" (frustrated) - Your approach isn't working

**When you see these:** STOP. Return to Phase 1.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix works" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question pattern, don't fix again. |

## Supporting Techniques

These references in this directory deepen specific phases:

- **`four-phases.md`** - Full step-by-step walk-through of Phases 1 to 4, the architecture-questioning protocol, the "no root cause" edge case, and real-world impact data.
- **`root-cause-tracing.md`** - Trace bugs backward through the call stack to find the original trigger (Phase 1, step 5).
- **`defense-in-depth.md`** - Add validation at multiple layers once root cause is fixed (Phase 4 follow-up).
- **`condition-based-waiting.md`** - Replace arbitrary timeouts with condition polling when debugging flaky timing (Phase 1 evidence gathering).

## Related Skills

- **workbench:test-driven-development** - For creating the failing test case in Phase 4, Step 1.
- **workbench:verification-before-completion** - Verify the fix worked before claiming success.

## Output Format

Default for this artifact: **html**.

Override resolution order, highest precedence first:

1. Per-invocation override in the user prompt. Recognize phrases like `"a markdown debug report"`, `"in HTML"`, `"as a markdown report"`, and equivalents.
2. `.workbench/config.md` `## Output formats` entry for `Debug reports:`. Schema documented in `plugins/workbench/skills/autopilot/references/config-schema.md`.
3. Per-skill hard-coded default (html).

Path: `.workbench/debug-reports/YYYY-MM-DD-<topic>-debug.<ext>` by default. Override path via `.workbench/config.md` `## Output paths` `Debug reports:`.

When emitting HTML, follow `references/debug-report-template.html` in this skill's directory. Read the template lazily.

## Report File Behavior

At the end of the four-phase loop, after the fix is verified, write a debug report file to the resolved path. The report captures:

- Hypothesis tree from Phase 1.
- "What I tried" timeline from Phase 2.
- Root cause from Phase 3.
- Fix description and validation from Phase 4.

Announce the file path in the conversation when emitting (for example: "Debug report written to `.workbench/debug-reports/2026-05-08-cache-stale-debug.html`") before the final summary message.

For other HTML artifact types not covered by a workbench or research skill, see `workbench:crafting-html`.

### Applying a design system

Before emitting HTML, check for an active design system and inline its overrides into the artifact's `<style>` block:

1. Resolve the design-system name: per-prompt override (e.g., "render with the `brand-2026` design system"), then `.workbench/config.md` `## Design system` `Name:`, then no override.
2. Locate the directory: `.workbench/design-systems/<name>/` (project scope), then `~/.claude/workbench/design-systems/<name>/` (user scope). If a name resolves but no directory is found at either scope, report the missing path to the user and emit with template defaults; do not fabricate a substitute.
3. Inline `colors.css` (and `typography.css` if present) **after** the template's own `:root` declarations, so the design system's values win the cascade.
4. For any referenced component, paste `components/<n>.html` markup and scoped style into the artifact body.
5. For any referenced image, base64-encode (`base64 -w 0 <file>`) and inline as `data:image/<type>;base64,<payload>`. SVG is text and can be inlined directly. Use relative paths only when the artifact and the design system co-exist in the same git tree and the artifact will not travel.

To create or edit a design system, see `workbench:crafting-design-systems`.
