# Ticket writing template

Maps a good ticket into the standard **Description + Acceptance Criteria** fields. Use this before assigning research/design tickets especially — that's where most underspecification bites.

---

## Description (field 1)

```markdown
## Context
[1-3 sentences: why this matters now, what triggered it]

## Deliverable
[The actual artifact. Be concrete:
 - Confluence page at <location>
 - Merged PR in <repo>
 - ADR in /docs/decisions
 - 15-min demo in <forum>
 - Decision memo tagging <people>
Not "investigate X" — what do I get at the end?]

## Scope
- In: [what's explicitly included]
- Out: [what's explicitly excluded — prevents scope creep]

## Stakeholders
- Review: [names — who signs off]
- Input needed from: [names — who to talk to]
- FYI: [names]

## Timebox
[Xh soft / Yh hard. If hard cap hits and you're not done,
bring it back to refinement — don't silently extend.]

## References
- [Related doc]
- [Related ticket XYZ-123]
```

## Acceptance Criteria (field 2)

```markdown
## Done when
- [ ] [Checkable condition 1]
- [ ] [Checkable condition 2]
- [ ] [Checkable condition 3]

## Key decisions to make (research/design only)
- [ ] Question 1: [e.g., should we use X or Y for Z?]
- [ ] Question 2: [e.g., who owns cleanup?]
```

**Rule:** If you can't write 2-3 checkboxes for "Done when", the ticket isn't ready — it's still a topic. Send it back to refinement, don't assign it.

---

## When to use which sections

| Ticket type | Must have | Can skip |
|---|---|---|
| Bug fix | Context, Deliverable (PR), Done when, Scope | Decisions, Stakeholders |
| Feature implementation | All except Decisions | Decisions (usually) |
| Research / investigation | **All** — especially Deliverable + Done when | — |
| Design / architecture | **All** — especially Decisions + Stakeholders | — |
| Spike / timeboxed exploration | Context, Deliverable, Timebox, Done when | Scope (loose by design) |

---

## The three questions that catch 80% of bad tickets

Before you hit save, ask:

1. **"What artifact do I get?"** — If the answer is a verb ("investigate", "analyze"), you don't have a deliverable. Pick a format.
2. **"How do I know it's done?"** — If you can't list 2-3 checkboxes, the scope isn't defined yet.
3. **"Who does the assignee need to talk to?"** — If unnamed, they'll either skip those conversations or block waiting for you to name them.

If any of these fail, the ticket isn't refined — it's a topic.

---

## Example: before/after

**Before:**
> Investigate and evaluate how Claude Code skills can be set up and integrated with the Gini Code environment. Analyze the risks of end users executing Gini-generated code.

Problems: Two tickets in one. No deliverable. No done-state. No scope bound.

**After (description):**
> **Context:** We want to codify platform-specific context (data rigs, dbt, data product configs) into reusable Claude Code skills so the team doesn't re-solve the same patterns.
>
> **Deliverable:** Confluence page `Platform / Claude Code Skills Playbook` covering (a) how to author skills for our environment, (b) how to deploy them, (c) 2 worked examples.
>
> **Scope — In:** skill authoring, deployment, 2 examples (data rigs + dbt).
> **Scope — Out:** security risk analysis (split to separate ticket), IDE integrations.
>
> **Stakeholders:** Review: [me]. Input from: [platform lead]. FYI: team.
>
> **Timebox:** 8h soft / 16h hard.

**After (acceptance criteria):**
> - [ ] Playbook page published in Confluence under Platform space
> - [ ] 2 working skill examples checked in and linked from page
> - [ ] At least one teammate has reviewed and confirmed they could author a skill from the doc
> - [ ] Decision documented: where do team skills live (shared repo vs. per-project)?
