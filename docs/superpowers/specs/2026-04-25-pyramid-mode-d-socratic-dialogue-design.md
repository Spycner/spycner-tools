# Pyramid Skill Mode D: Interactive Socratic Dialogue Design

*Date: 2026-04-25*

## Problem

The pyramid skill v1 ([design](./2026-04-24-pyramid-principle-skill-design.md)) ships with two construction modes: greenfield (topic in, pyramid out) and restructure (draft in, pyramid out). Both run as a single Agent dispatch that executes Minto's procedure internally. The agent asks itself questions and answers them. The user sees only the finished pyramid.

That produces structurally correct pyramids but does not teach the writer the method. The dialogue is hidden. Audit panel verdicts surface the gaps after the fact, but the writer never had to think through the apex, justify the siblings, or feel the friction of a sibling that fails the So-What test.

A third mode, deferred from v1 and tracked in [issue #12](https://github.com/pgoell/pgoell-claude-tools/issues/12), externalises the dialogue. Each tier of the pyramid is negotiated with the user via `AskUserQuestion`. The skill asks the question, the user writes the finding, an inline micro-audit fires, the next turn proceeds. The pyramid emerges from a real conversation. The writer ends up with both the artifact and the discipline.

## Design Goal

Add **Mode D (Socratic)** to the pyramid skill. Mode D is a peer to Modes A and B, picked by the user at intake. It changes only Phase 2 (construct); Phases 3-5 (audit panel, opener, render) run unchanged on the user-built `construction.md`.

Mode D is orchestrator-driven. No Agent dispatch in Phase 2. The orchestrator runs a turn loop, where each turn is one `AskUserQuestion` plus one inline micro-audit, with always-available structured escape options (hand off to Mode A, pause, cancel) on every turn.

## Pipeline Changes

The five-phase pipeline shape from the v1 design is unchanged. Only Phase 1 (intake) gains a new mode option, and Phase 2 (construct) gains a third branch.

```
Phase 1: Intake
  → mode picker now has 3 options: greenfield | restructure | socratic
  → if socratic: gather audience and reader question (Mode A inputs); skip Mode B inputs
  → write intake.md with mode: socratic
Phase 2: Construct
  → mode == greenfield: dispatch construct-greenfield-prompt.md (existing behaviour)
  → mode == restructure: dispatch construct-restructure-prompt.md (existing behaviour)
  → mode == socratic: read construct-socratic-prompt.md, run the turn loop in the orchestrator (no Agent dispatch)
Phase 3-5: unchanged
```

## Phase 1 Change: Three-Option Mode Picker

The intake `AskUserQuestion` for mode becomes:

- *Greenfield: I have a topic and want a fresh pyramid outline.*
- *Restructure: I have an existing draft and want to pyramid-ify it.*
- *Interactive: walk me through it question by question (Socratic dialogue).*

`intake.md`'s `mode` field gains a third recognised value: `socratic`. State file's recognised mode values become: `greenfield`, `restructure`, `socratic`.

Mode A inputs (topic, audience, reader question) are gathered the same way as in Mode A. The dialogue itself begins in Phase 2, not in intake. Domain-limits gate runs identically (genres on the "does not work for" list still surface a mismatch).

## Phase 2 Change: Mode D Turn Loop

When `mode == socratic`, the orchestrator reads `construct-socratic-prompt.md` and runs the turn loop. No Agent dispatch.

### Turn Sequence (Medium Granularity)

Eleven turns for a three-sibling pyramid. The grouping noun choice and the "add or stop" turn are short; the others ask for one finding each.

| Turn | Question | Inline micro-audit |
|---|---|---|
| 1 | *"What question do you expect the reader to have?"* (pre-filled from intake; user can edit) | Question is a real question (ends with `?`, not a topic label) |
| 2 | *"What is the apex (the one-sentence finding that answers that question)?"* | **Block:** label-vs-finding (apex must be a sentence with a verb, not a noun phrase like "Three reasons we should raise") |
| 3 | *"Below the apex, what one question does the apex raise for the reader?"* | Question downward is distinct from Turn 1's reader question |
| 4 | *"What plural noun names the children that will answer that question? (reasons, risks, steps, recommendations, causes, ...)"* | Noun is plural; pre-flags inductive vs deductive |
| 5 | *"State the first finding."* | **Block:** label-vs-finding. **Warn:** So-What ("would the reader say 'so what?' to this?") |
| 6 | *"State the second finding."* | Same. **Warn:** ME overlap with finding 1 |
| 7 | *"State the third finding."* | Same. **Warn:** CE gap ("any obvious case missing?") |
| 8 | *"Add a fourth finding, or stop here?"* (options: *Add one more / Stop at three / Add and stop at five*) | Cap at 5; block at 6+ with MECE prompt |
| 9..N | *"For finding 1, what evidence supports it? (one bullet per line)"* (repeats per finding) | **Warn:** Why-Is-That-True (each bullet is evidence, not restatement) |

For four- or five-sibling pyramids, the sibling and evidence turns expand. Total turns scale linearly with sibling count.

### Input Model: Freeform Only

At every turn the user types their answer freeform. No skill-generated options for the apex, the reader question, or any sibling. The whole point of Mode D is that the writer's voice and thinking shape every node. Generating options would do the thinking for the writer, which is the failure mode of Modes A and B that this mode is meant to fix.

The `AskUserQuestion`'s structured options are reserved for the escape hatches (see below).

### Escape Options on Every Turn

Every turn's `AskUserQuestion` carries these structured options alongside the freeform answer field:

- *Other (type my answer)*: primary path, where the user's answer goes
- *Hand off remaining tiers to Mode A*: see Hand-Off Mechanics below
- *Pause and resume later*: see Pause and Resume below
- *Cancel*: same semantics as Cancel in Modes A and B today

Always present, always discoverable. No sentinel strings to remember.

### Inline Micro-Audit Behaviour: Hybrid Block-or-Warn

The block list is short and named explicitly:

1. **Apex is a noun-phrase label, not a sentence with a verb** (Turn 2). Diagnostic: *"That looks like a label, not a finding. A label names a topic ('Series B considerations'); a finding makes a claim ('We should raise Series B in Q1 2027'). What is your finding?"*
2. **Any sibling is a noun-phrase label** (Turns 5-8). Same diagnostic shape.
3. **Sibling count exceeds 5 without a MECE re-pass** (Turn 8). Diagnostic asks the user to apply the Four MECE Audit Questions before defending the size.

Everything else (So-What strength, ME overlap, CE gap, evidence quality, downward question distinctness) **warns** with a one-line diagnostic and accepts the answer. The audit panel at the end is the formal gate.

If a hard-blocked turn fails twice on the same answer pattern (the user keeps tripping the same block), the orchestrator softens to a warning on the third attempt: *"Letting this through. The audit panel will flag it formally."* This caps user frustration without abandoning the discipline.

### Live Render Between Turns

After each accepted turn, the orchestrator writes the partial pyramid to `construction.md` in the standard schema, with `<pending>` placeholders for nodes not yet reached. The orchestrator then emits a one-line summary to the user: *"Pyramid so far: apex + 2 of 3 siblings + 0 evidence rows. Next: finding 3."* Single line, no full re-render. The full pyramid is in `construction.md` for the user to inspect at any time.

This keeps `construction.md` as the single source of truth. Resume infers turn position from it; pause does not need a separate write; hand-off does not need a separate write.

## New File: `construct-socratic-prompt.md`

Lives next to `construct-greenfield-prompt.md` and `construct-restructure-prompt.md`. Unlike its siblings, it is **not an Agent dispatch prompt**. It is an orchestrator playbook: the orchestrator reads it at the start of Phase 2 when `mode == socratic` and follows the turn loop it specifies.

A header note at the top of the file states this explicitly so a reader does not get confused by the naming convention.

**Contents:**

1. **Header note** explaining the file is read by the orchestrator, not dispatched as an agent prompt. No `{OUTPUT_PATH}` substitution at dispatch time; the orchestrator owns the loop.
2. **Turn sequence table** (the one above) plus the exact `AskUserQuestion` text for each turn.
3. **Inline micro-audit specs**: for each turn, the exact diagnostic the orchestrator should emit when a soft warning fires or a hard block fires.
4. **Block list**: the three blocking failures, named explicitly so the orchestrator does not over-block.
5. **Standard escape options**: the four options every turn carries, with the exact label text.
6. **Live render contract**: schema for the partial `construction.md` with `<pending>` placeholders, plus the one-line progress summary template.
7. **Hand-off contract**: what the orchestrator does when the user picks *Hand off remaining tiers to Mode A* (see next section).

## Hand-Off Mechanics

When the user picks *Hand off remaining tiers to Mode A* at any turn:

1. The orchestrator's live `construction.md` already has the locked nodes (with `<pending>` placeholders for unfinished ones), so no new write is needed (the live render contract handles this).
2. Orchestrator updates the state file: `mode: greenfield`, adds a `handoff_from: socratic` field. A future resume picks up greenfield, not socratic; reality is now greenfield.
3. Orchestrator reads `construct-greenfield-prompt.md`, substitutes a new placeholder `{HANDOFF}` with `true`, dispatches the greenfield agent.
4. Phase 2 continues from the agent's output. Phases 3-5 run unchanged on the merged pyramid.

### Greenfield Prompt Change

`construct-greenfield-prompt.md` adds a `## Handoff mode` section near `## Reviewer Feedback`:

> **Handoff mode.** If `{HANDOFF}` is `true`, an existing `construction.md` is present. Read it. Locked nodes (any node that is not `<pending>`) are fixed: do NOT modify them. Fill in only `<pending>` nodes by running the Q-A Dialogue Procedure from the apex downward, but accept all locked nodes as given. Verify the pyramid as a whole still passes the rules (apex is a finding, siblings are MECE, grouping noun is consistent); if not, leave a note at the end of `construction.md` under `## Handoff notes` flagging the inconsistencies the audit panel should pay attention to.

The greenfield prompt's three operating modes after this change:

- **Fresh build:** `{REVIEWER_FEEDBACK}` empty, `{HANDOFF}` false.
- **Re-dispatch on CRITICAL audit:** `{REVIEWER_FEEDBACK}` non-empty, `{HANDOFF}` false.
- **Hand-off from Mode D:** `{HANDOFF}` true, `{REVIEWER_FEEDBACK}` empty.

The orchestrator never sets both flags simultaneously.

## State File and Resume

The state file gains a third recognised `mode` value: `socratic`. **No new fields.** Turn position is derived from `construction.md` itself: the orchestrator counts populated nodes versus `<pending>` placeholders to infer which turn to ask next. Single source of truth, no drift risk.

```json
{
  "version": 1,
  "projects": {
    "<absolute-working-directory>": {
      "mode": "socratic",
      "active_reference": "<absolute-path-or-default>",
      "last_completed_phase": "intake",
      "last_run_at": "2026-04-25T10:00:00Z"
    }
  }
}
```

Recognised mode values are now: `greenfield`, `restructure`, `socratic`. After a hand-off, the state file's `mode` becomes `greenfield` and gains a `handoff_from: socratic` field.

### Pause Behaviour

When the user picks *Pause and resume later* at any turn:

- Whatever is in flight is already in `construction.md` (live render).
- State file records `mode: socratic`, `last_completed_phase: intake`, `last_run_at: <now>`.
- Orchestrator emits a one-line confirmation and exits.

### Resume Behaviour

Next `/pyramid` invocation in this directory:

- Existing state file with `mode: socratic` and `last_completed_phase: intake` → orchestrator says: *"In-flight Socratic dialogue found. Resume from <next-turn description>?"* via `AskUserQuestion`.
- On yes, read `construction.md`, infer next turn from populated nodes, re-enter the turn loop.

### Cancel Behaviour

Same as Cancel in Modes A and B today: working directory artifacts left in place; state file entry removed. The user can `rm -rf` the directory manually if they want a fresh start.

## Edge Cases (additions only)

The v1 edge case list applies unchanged. Mode D adds:

- **Repeated block on the same turn.** After two failed attempts on a hard-blocked turn, soften to a warning on the third attempt. Lets the audit panel be the final gate.
- **Existing `construction.md` when user starts Mode D fresh** (e.g. a prior Mode A run produced a pyramid in this directory). Orchestrator asks via `AskUserQuestion`: *Reset and rebuild via dialogue / Keep existing pyramid (no Mode D needed) / Cancel.*
- **Empty answer in the freeform field.** Re-ask the question without consuming a turn.
- **Phase-jump invocation: `/pyramid --phase construct --mode socratic` on a directory without `intake.md`.** Same handling as Mode A: ask whether to run intake first.

Domain-limits gate, working-directory resolution, reference resolution, audit-panel re-dispatch, and opener MISMATCH all behave identically to Modes A and B. Mode D only changes Phase 2.

## Artifacts (additions only)

No new artifact files. `construction.md` is written by the orchestrator turn-by-turn instead of by an agent in one shot. Schema is identical, with the addition of `<pending>` placeholders during the dialogue (replaced by real content as turns complete; absent from the final pyramid).

`intake.md`'s `mode` field gains the `socratic` value. State file's `mode` field gains the `socratic` value plus an optional `handoff_from` field after a hand-off.

## Tests

Three layers, matching repo convention.

### Unit additions (`tests/unit/test-pyramid-skill.sh`)

- `SKILL.md` describes a third mode (mentions "socratic", "interactive dialogue", or "walk me through it").
- `SKILL.md` references `construct-socratic-prompt.md`.
- `SKILL.md` documents `socratic` as a recognised state-file mode value.
- `construct-greenfield-prompt.md` contains a `## Handoff mode` section.

### Skill-triggering additions (`tests/skill-triggering/prompts/`): three new positive triggers

- `pyramid-socratic-walk-me-through.txt`: *"Walk me through building a pyramid for this memo question by question."*
- `pyramid-socratic-interactive.txt`: *"Help me build a pyramid interactively in a Socratic dialogue."*
- `pyramid-socratic-not-spit-it-out.txt`: *"Build the pyramid with me, asking me questions, not by writing it out yourself."*

The existing negative triggers (narrative, factual question) cover Mode D's negatives without addition.

### Integration addition (`tests/integration/test-pyramid-integration.sh`): one new scenario

Mode D end-to-end happy path. Eleven embedded answers in the prompt (reader question, apex, downward question, plural noun, three siblings, stop-at-three confirmation, three evidence batches). The orchestrator reads the embedded answers and skips firing `AskUserQuestion` (the same trick the existing Mode A test uses). Plus the existing assertions: nine artifacts, sections in `pyramid.md`, four-row verdicts table, state file records `mode: socratic` and `last_completed_phase: render`, apex matches expected finding shape.

A separate hand-off integration test is **deferred to a follow-up issue**. It is mostly redundant with Mode A's existing test, and the unit-level check that `construct-greenfield-prompt.md` carries the `Handoff mode` section gives most of the safety.

## Out of Scope (Deferred Follow-ups)

Tracked as new follow-up issues to open after this PR merges:

- **Hand-off integration test.** End-to-end test that simulates a partial Mode D dialogue, picks *Hand off remaining tiers to Mode A* mid-flow, and verifies the merged pyramid.
- **Storyboarding for presentations.** Carried forward from v1's deferred list. Not in this PR.
- **Writing-skill dispatch integration.** Carried forward from v1's deferred list. Mode D does not change this.

## References

- [Issue #12: Pyramid skill: add Mode D (interactive Socratic dialogue)](https://github.com/pgoell/pgoell-claude-tools/issues/12)
- [v1 design: pyramid principle skill](./2026-04-24-pyramid-principle-skill-design.md)
- [Research report: pyramid principle operational reference](./2026-04-24-pyramid-principle-research.md), section 3 (Q-A Dialogue Procedure) for the method Mode D externalises
- Writing skill design: [`./2026-04-16-writing-skill-design.md`](./2026-04-16-writing-skill-design.md), for the orchestrator-with-AskUserQuestion-loop precedent
- Minto, Barbara. *The Pyramid Principle: Logic in Writing and Thinking.* Primary source, cited via the research report.
