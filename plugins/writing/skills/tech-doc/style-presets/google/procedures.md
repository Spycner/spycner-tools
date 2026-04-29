# Google: Procedures and instructions

Source: https://developers.google.com/style/procedures
Last refreshed: 2026-04-29

## Prerequisites

State prerequisites before the procedure begins. Readers must have the required hardware, software, credentials, or permissions before they start. Do not bury prerequisites inside steps.

## Step structure

- One action per step. Each step covers one reader decision or one discrete action.
- State the location or context before the action: "In the Google Cloud console, click **Create**." Not "Click **Create** in the Google Cloud console."
- State the goal before the action when it aids clarity: "To start a new document, click **File > New > Document**."
- State the result or justification after the action, in the same step: "Click **Run**. The query results appear after the query runs."
- If justification is needed for a future step, add it inline: "Store the private key in a secure location. You need it later."
- Conditions come before the instruction: "If you are on Linux, run `sudo apt install …`." Not "Run `sudo apt install …` if you are on Linux."
- Optional steps are prefixed with "Optional:" (not "(Optional)"): "Optional: Type an arbitrary string to label the export."
- Start each step with an imperative verb. Not "You need to clone the repository" but "Clone the repository."
- Use complete, grammatically correct sentences. Capitalize the first word; end with a period.

## Numbering and bullets

- Use a numbered list for multi-step procedures where order matters.
- Use a bulleted list (single bullet) for single-step procedures.
- Use lowercase letters (a, b, c) for sub-steps within a numbered step.
- Use lowercase Roman numerals (i, ii, iii) for sub-sub-steps.
- Treat a step that has sub-steps like an introductory sentence: end with a colon if the sub-steps follow immediately, a period if intervening material separates them.

## Procedure introductions

- Introduce most procedures with a sentence that extends beyond the heading. Do not just restate the heading.
- End the introductory sentence with a colon if the steps follow directly: "To customize the buttons, follow these steps:"
- End with a period if a note or paragraph separates the introduction from the steps.
- Acceptable short form: "Customize the buttons:" directly above the steps.
- Do not use an incomplete sentence as the introduction: "To customize the buttons:" with no completion is not acceptable.

## Tone in procedures

- Imperative mood throughout: "Click", "Run", "Set", not "You should click" or "The user clicks".
- Present tense.
- Second person ("you") when a subject is needed.
- No "please".
- No directional language ("above", "below", "right-hand side"). Reference UI labels or headings instead.
- Avoid keyboard shortcut instructions as the primary path; include "Press Enter" as a step component when required, not as a shortcut alternative.

## Single-step vs multi-step

- Single step: format as one sentence in a bulleted list. "To clear the entire log, click **Clear logcat**."
- Multi-step (two or more actions in sequence): numbered list.
- Combine very short sequential actions in the same UI location using angle brackets: "Click **Next > Finish**." Do not chain more than two or three actions this way.
- Do not split what is genuinely one action into two steps to inflate the count.

## Parenthetical UI hints

When a UI label is ambiguous or appears in multiple locations, add a brief parenthetical clarification immediately after the label: "Click **File** (the menu bar item, not the toolbar shortcut)." Keep parentheticals short. If the clarification requires more than one clause, provide a screenshot or restructure the step instead.

## Multiple procedures for the same task

Document one procedure when possible. If a task can be completed multiple ways, prefer the path that: uses keyboard-only navigation, is shortest, or uses the most familiar tool. Separate alternative procedures into distinct headings, pages, or tabs. Do not present all alternatives in a single numbered list.

## Repetitive procedures

Cross-reference earlier procedures rather than repeating steps verbatim: "Create a service account as described in the previous section." Repeat a procedure in full only when the context genuinely differs enough to make a cross-reference unhelpful.
