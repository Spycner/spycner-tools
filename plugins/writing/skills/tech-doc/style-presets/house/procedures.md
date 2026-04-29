# House: Procedures and instructions

Source: Union of Google developer style and Microsoft Writing Style Guide (house synthesis)
Last refreshed: 2026-04-29

## Prerequisites

State all prerequisites before step 1 under a "Before you begin" heading or a short prerequisite list. Do not scatter requirements inside steps. Prerequisites include: required software versions, permissions, credentials, environment configuration, and any prior procedures that must have completed successfully.

## Step structure

- One action per step. Each step covers one reader decision or one discrete action.
- State the location or context before the action: "In the dashboard, click **Settings**." Not "Click **Settings** in the dashboard."
- State the goal before the action when it aids clarity: "To export the report, click **Download**."
- Conditions come before the instruction: "If you are on Linux, run `sudo apt install …`." Not "Run `sudo apt install …` if you are on Linux."
- State the result or justification after the action in the same step: "Click **Deploy**. The deployment status appears in the activity log."
- When a step's result is needed later, note it inline: "Copy the API key. You will need it in step 4."
- Optional steps begin with "Optional:": "Optional: Add a description to help team members identify the resource."
- Start each step with an imperative verb. Use complete sentences; capitalize the first word and end with a period.

## Numbering and bullets

- Numbered list for multi-step procedures where order matters.
- Single bullet for single-step procedures (consistent with surrounding numbered lists).
- A single-step procedure may also be a plain sentence when list formatting adds no value.
- Sub-steps: use lowercase letters (a, b, c). Sub-sub-steps: use lowercase Roman numerals (i, ii, iii). Avoid going deeper than two levels; restructure instead.
- Abbreviate simple sequential selections with angle brackets: "Select **File** > **Export** > **CSV**." Include spaces around the brackets; do not bold the brackets themselves.

## Procedure introductions

- Introduce every procedure with a sentence that extends beyond the heading. Do not restate the heading verbatim.
- "To \<do X\>:" introduces a procedure directly above its numbered steps.
- End the introduction with a colon when the steps follow immediately; end with a period when a note or paragraph falls between the introduction and step 1.
- Short imperative form is also acceptable directly above the steps: "Configure the firewall rules:" followed by the numbered list.
- Headings for procedures should be parallel in structure. Prefer gerund or imperative forms consistently within a document.

## Tone in procedures

- Imperative mood, present tense, second person.
- Active voice: "Run the script." Not "The script should be run."
- No "please".
- Prefer input-neutral verbs ("select", "choose", "go to") over device-specific verbs ("click", "tap") unless the document targets a specific input device.
- No directional language ("above", "below", "right-hand side"). Reference UI labels or heading names instead.
- No hedging: "You may want to consider clicking" becomes "Click".

## Single-step vs multi-step

- Two or more sequential actions that must be performed in order: numbered list.
- One action: a bullet or a plain sentence.
- If a numbered procedure exceeds seven steps, look for a natural split into a "Before you begin" block, sub-procedures, or separate headings.
- Do not artificially split one action into two steps. Do not artificially merge two decisions into one step.

## Parenthetical UI hints

When a UI label is ambiguous or appears in more than one location, add a brief parenthetical immediately after the label: "Click **File** (the menu bar item, not the toolbar shortcut)." Keep the parenthetical to one clause. If more context is required, add a screenshot or restructure the step into two steps with intermediate clarification.

## Sub-steps and branching

When a step contains a branch (the reader must choose one of two paths), present the branch as: "Do one of the following:" followed by a lettered list of alternatives. Do not mix branches and sequential actions inside the same numbered step. Keep nesting to step > sub-step (two levels). Three levels of nesting is a restructuring signal.
