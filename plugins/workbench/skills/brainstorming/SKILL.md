---
name: brainstorming
description: "Use before creative work to clarify intent, requirements, and design through sequential question and answer."
---

# Brainstorming Ideas Into Designs

Help turn ideas into well-formed designs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once the design is clear and the user approves, hand off to `workbench:writing-spec`.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A todo list, a single-function utility, a config change: all of them. Simple projects are where unexamined assumptions cause the most wasted work. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval.

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Explore project context**: dispatch a cost-efficient subagent to survey files, docs, and recent commits; use its summary as starting context.
2. **Offer visualizing-options** (if the topic will involve visual questions): mention `workbench:visualizing-options` in its own message; the user opts in.
3. **Ask clarifying questions**: one at a time, understand purpose, constraints, and success criteria.
4. **Propose 2-3 approaches**: with trade-offs and your recommendation.
5. **Present design**: in sections scaled to their complexity, get user approval after each section.
6. **Recommend `workbench:writing-spec`** as the terminal step. That skill writes the spec doc, runs self-review, and gates on user approval.

## Process Flow

```dot
digraph brainstorming {
    "Explore project context" [shape=box];
    "Visual questions ahead?" [shape=diamond];
    "Mention workbench:visualizing-options\n(own message)" [shape=box];
    "Ask clarifying questions" [shape=box];
    "Propose 2-3 approaches" [shape=box];
    "Present design sections" [shape=box];
    "User approves design?" [shape=diamond];
    "Recommend workbench:writing-spec" [shape=doublecircle];

    "Explore project context" -> "Visual questions ahead?";
    "Visual questions ahead?" -> "Mention workbench:visualizing-options\n(own message)" [label="yes"];
    "Visual questions ahead?" -> "Ask clarifying questions" [label="no"];
    "Mention workbench:visualizing-options\n(own message)" -> "Ask clarifying questions";
    "Ask clarifying questions" -> "Propose 2-3 approaches";
    "Propose 2-3 approaches" -> "Present design sections";
    "Present design sections" -> "User approves design?";
    "User approves design?" -> "Present design sections" [label="no, revise"];
    "User approves design?" -> "Recommend workbench:writing-spec" [label="yes"];
}
```

## The Process

**Understanding the idea:**

- Delegate project-state exploration to a cost-efficient subagent (Claude Code: `Explore` agent type, haiku model. Codex: read-only research agent equivalent.) Pass a tight prompt: "Survey this repo. Report under 250 words: primary language, top-level structure, recent commits (last 5), presence of CLAUDE.md/AGENTS.md/README, any docs/ directory worth reading. Don't list every file." Use the returned summary as your starting context.
- Before asking detailed questions, assess scope: if the request describes multiple independent subsystems, flag this immediately. Do not spend questions refining details of a project that needs to be decomposed first.
- If the project is too large for a single spec, help the user decompose into sub-projects. Each sub-project then gets its own brainstorm and spec cycle.
- For appropriately scoped projects, ask questions one at a time.
- Prefer multiple choice questions when possible.
- One question per message.
- Focus on understanding: purpose, constraints, success criteria.
- Really grill the user until full understanding for you and the user is achieved.

**Exploring approaches:**

- Propose 2-3 different approaches with trade-offs.
- Lead with your recommendation and explain why.

**Presenting the design:**

- Scale each section to its complexity.
- Ask after each section whether it looks right so far.
- Cover: architecture, components, data flow, error handling, testing.
- Be ready to clarify if something does not make sense.

**Design for isolation and clarity:**

- Break the system into smaller units, each with one clear purpose, communicating through well-defined interfaces.
- Smaller, well-bounded units are easier to reason about. When a file grows large, that is often a signal it is doing too much.

**Working in existing codebases:**

- Delegate exploration of the area you are touching to a cost-efficient subagent. Follow the returned conventions.
- Where existing code has problems that affect the work, include targeted improvements as part of the design.
- Do not propose unrelated refactoring.

## Visual Questions

If the conversation will involve visual content (mockups, layouts, diagrams), mention `workbench:visualizing-options` in its own message before asking the next question. The user opts in by acknowledging. That skill owns the browser companion; this skill stays in the terminal.

The offer message should contain ONLY the pointer; do not combine it with clarifying questions.

## Handoff

Once the user has approved the design, your terminal action is to recommend `workbench:writing-spec`. Do NOT invoke any implementation skill, do NOT write the spec yourself, and do NOT proceed to planning. The spec writing skill takes over from there, runs its self-review, and gates on user approval before handing off to `workbench:writing-plans`.

## Key Principles

- One question at a time.
- Multiple choice preferred.
- YAGNI ruthlessly.
- Explore alternatives.
- Incremental validation.
- Be flexible: go back and clarify when something does not make sense.

## Output Format

Default for this artifact: **html**.

Override resolution order, highest precedence first:

1. Per-invocation override in the user prompt. Recognize phrases like `"a markdown brainstorm summary"`, `"in HTML"`, `"as a markdown summary"`, and equivalents.
2. `.workbench/config.md` `## Output formats` entry for `Brainstorm summaries:`. Schema documented in `plugins/workbench/skills/autopilot/references/config-schema.md`.
3. Per-skill hard-coded default (html).

Path: `.workbench/brainstorms/YYYY-MM-DD-<topic>-brainstorm.<ext>` by default, where `<ext>` resolves from format. Override path via `.workbench/config.md` `## Output paths` `Brainstorm summaries:`.

When emitting HTML, follow `references/brainstorm-summary-template.html` in this skill's directory. Read the template lazily.

## Summary File Behavior

After the user approves the design and before recommending `workbench:writing-spec`, write a brainstorm summary file to the resolved path. The summary captures:

- Q and A timeline of clarifying questions and user answers.
- Agreed design (sections approved during the conversation).
- Parking-lot items (deferred topics).
- Handoff link to the next step (writing-spec).

Announce the file path in the conversation when emitting (for example: "Brainstorm summary written to `.workbench/brainstorms/2026-05-08-html-artifacts-brainstorm.html`") so the user is not surprised. The recommendation of `workbench:writing-spec` then follows in the same final message.

For other HTML artifact types not covered by a workbench or research skill, see `workbench:crafting-html`.
