---
name: pyramid
description: Structure memos, recommendations, briefings, and decision documents with the Pyramid Principle.
---

# Pyramid Skill

Multi-phase pyramid-principle skill with a parallel audit panel. Modeled on Barbara Minto's method.

---

## Tool Preference

1. **Subagent dispatch when available and permitted**: to dispatch phase agents (construct in greenfield or restructure mode, opener) and the audit panel (MECE, So-What, Q-A Alignment, Inductive-Deductive). Intake and render run in the orchestrator itself and do not dispatch an agent.
2. **File read tools**: to load prompt templates, the shipped reference, and existing artifacts.
3. **Shell**: for directory creation, file existence checks, and state file read/write.
4. **Progress list**: to surface progress through the pipeline visibly.
5. **File write and edit tools**: for intake.md, audit-summary.md, pyramid.md, and state file management.
6. **User question tool or direct question**: for mode and genre selection, domain-limits gate, MISMATCH routing, and audit re-dispatch overrides.

## Platform Adaptation

Use the host platform's equivalent tools without changing the workflow:

| Capability | Claude Code | Codex |
|---|---|---|
| Subagent dispatch | Agent tool | `spawn_agent` only when available and permitted. Otherwise run the phase inline. |
| Progress list | TaskCreate, TaskUpdate | `update_plan` |
| User questions | AskUserQuestion | Ask a concise direct question, or use the host structured question tool when available |
| File reads | Read | shell reads such as `sed`, `rg`, or equivalent file read tools |
| File writes and edits | Write, Edit | `apply_patch` or equivalent file edit tools |
| Shell | Bash | shell command tool |

Where this skill says "Agent tool", "TaskCreate", "TaskUpdate", "AskUserQuestion", "Read", "Write", "Edit", or "Bash", use the mapped host capability. When a platform cannot dispatch subagents for the current request, keep the same artifact boundaries and run each phase inline in the orchestrator.

State root is platform-specific. Claude Code uses `~/.claude/projects`. Codex uses `${CODEX_HOME:-~/.codex}/projects` when writable, otherwise create `.codex-skill-state/` under the current working directory.

## Workflow

### Step 1: Determine working directory

Resolve working directory in this order:
1. **Explicit flag**: `--dir ./path/to/project/`
2. **Existing artifacts in cwd**: if the cwd already contains any of `intake.md`, `construction.md`, `audit-summary.md`, `opener.md`, `pyramid.md`, treat the cwd as the working directory.
3. **State file lookup**: read `<state-root>/<project-id>/pyramid-skill-state.json` (where `<project-id>` is the cwd path with slashes replaced by hyphens, leading hyphen stripped). If an in-flight pyramid is recorded, offer to resume there.
4. **Default**: prompt for a slug, create `pyramid/{slug}-{YYYY-MM-DD}/` in the cwd.

### Step 2: Resolve the active reference

Resolution order:
1. **Explicit flag**: `--reference ./path/to/pyramid-reference.md`
2. **State memory**: the state file's recorded reference for this project.
3. **Skill default**: `pyramid-principle-reference.md` shipped with this skill. Resolve its absolute path by locating the directory of this `SKILL.md` file (the skill's own install path) via `Glob` on `**/pyramid/SKILL.md` under the active plugin directory, then take the parent.

Surface the active reference in the first response: "Using pyramid reference: {path}".

### Step 3: Determine starting phase

Scan the working directory for existing artifacts:
- `intake.md` exists → intake phase complete
- `construction.md` exists → construct phase complete
- `audit-summary.md` exists → audit phase complete
- `opener.md` exists → opener phase complete
- `pyramid.md` exists → render phase complete

Determine the latest completed phase. Present to user:
- "I see you have completed phases X. Resume from {next phase}?"
- Offer phase-jump option: the user can name any phase to jump to.

The user can also pre-empt the dialogue by passing `--phase X` (X ∈ {intake, construct, audit, opener, render}).

### Step 4: Create task list

Use the progress list to add one task per phase that will run, plus four sub-tasks for the audit panel. Example for a fresh full pipeline:

```
1. Phase 1: Intake (mode, genre, domain-limits gate, inputs)
2. Phase 2: Construct the pyramid
3. Phase 3: Audit panel
   ├── Auditor: MECE
   ├── Auditor: So-What
   ├── Auditor: Q-A Alignment
   └── Auditor: Inductive-Deductive
4. Phase 4: Compose SCQA opener
5. Phase 5: Render pyramid.md
```

For phase-selectable runs, only the requested phases get tasks.

Mark each task as `in_progress` when starting and `completed` when the artifact is verified.

### Step 5: Execute phases

Dispatch each phase agent via the host subagent tool when supported. The orchestrator injects context into the prompt template.

#### Dispatch conventions (apply to every phase)

- **`{OUTPUT_PATH}` is always the working directory**, never a file path. Each prompt file appends its own filename.
- **Prompt file extraction.** Each prompt file documents the dispatched prompt inside a fenced block under the `**Dispatch:**` header. The simplest robust approach: read the entire prompt file as text, perform placeholder substitution (`{OUTPUT_PATH}`, `{REFERENCE_PATH}`, `{REVIEWER_FEEDBACK}`, `{HANDOFF}`, `{YYYY-MM-DD}`), and pass the full result to the host subagent tool. The dispatched agent ignores the surrounding commentary because the actionable instructions sit inside the visible prompt body.
- **`{HANDOFF}` default.** When dispatching `construct-greenfield-prompt.md` in fresh-build or re-dispatch (CRITICAL audit) cases, substitute `{HANDOFF}` with `false`. Substitute `true` only when handing off mid-Mode-D dialogue, or when re-dispatching a Mode-D-built pyramid after a CRITICAL audit. The greenfield prompt's `## Handoff mode` section keys off this value.
- **Reviewer feedback injection.** When `{REVIEWER_FEEDBACK}` is non-empty (re-dispatch on a failed audit gate, or after a MISMATCH the user asked to revise), append this standing instruction to the dispatched prompt, regardless of what the prompt template itself says: *"Reviewer feedback is provided above. Read the existing artifact in the output directory, address the specific concerns, and update the file in place rather than starting fresh."*
- **Date substitution.** `{YYYY-MM-DD}` resolves to today's date in ISO format.

## Phase details

### Phase 1: Intake

Orchestrator-only, interactive. No Agent dispatch.

1. **Mode.** Ask via AskUserQuestion: *Greenfield (I have a topic and want a fresh pyramid outline) / Restructure (I have an existing draft and want to pyramid-ify it) / Socratic (walk me through it question by question, interactive dialogue)*. Always ask, even if `--mode` was passed; the flag only pre-selects the option. This prevents "surprise wrong mode" failures.
2. **Genre.** Ask via AskUserQuestion: *Memo / Recommendation / Briefing / Strategy doc / Case interview answer / Project proposal / Postmortem / Other (describe)*. Map to the lists in reference section 11.
3. **Domain-limits gate.** If the genre falls in the "Does not work for" list from reference section 11 (narrative longform, personal essay, exploratory or discovery document, emotionally-driven persuasion, creative writing, in-progress thinking, pedagogical walk-through), surface the mismatch via AskUserQuestion with three options: *Proceed anyway (I understand the pyramid may be the wrong frame) / Switch: route me to the writing skill instead / Cancel*. Honor the choice. If the user proceeds anyway, record `genre_override: true` in intake.md so Phase 5 can prepend a caveat to Audit notes.
   *Run only the input step matching the mode chosen in step 1; skip the others.*
4. **Mode A (Greenfield) inputs.** Ask for topic, audience, and the reader question (the question you expect the reader to have, which the apex will answer). Use AskUserQuestion or simple prompts as appropriate.
5. **Mode B (Restructure) inputs.** Ask for the draft path (absolute path to a markdown file) OR accept the draft pasted inline. If pasted inline, write it to `{OUTPUT_PATH}/draft.md`. Either way, the construct agent reads `draft.md` from the working directory.
6. **Mode D (Socratic) inputs.** Same as Mode A: ask for topic, audience, and the reader question. The dialogue itself runs in Phase 2, not in intake. Do NOT collect a draft; Mode D builds the pyramid from scratch with the writer.
7. **Write intake.md** with fields: `mode`, `topic_or_draft_path`, `audience`, `reader_question`, `genre`, `domain_limits_acknowledged`, `genre_override`.
8. Mark the Phase 1 task completed.

### Phase 2: Construct

Mode-branched. Modes A and B run as one Agent dispatch. Mode D runs as an orchestrator-only turn loop with no Agent dispatch.

**Modes A (Greenfield) and B (Restructure):**

1. Read `construct-greenfield-prompt.md` if `mode == greenfield`, or `construct-restructure-prompt.md` if `mode == restructure`.
2. Inject: output path, reference path, empty reviewer feedback (on first dispatch; populated on re-dispatch), `{HANDOFF}` set to `false`, today's date.
3. Dispatch via the host subagent tool.
4. Verify `{OUTPUT_PATH}/construction.md` exists. For Mode B (restructure), also verify `{OUTPUT_PATH}/restructure-notes.md` exists.
5. Mark task completed.

On re-dispatch (after a CRITICAL audit gate), inject `audit-summary.md` content as `{REVIEWER_FEEDBACK}` so the construct agent updates `construction.md` in place to address the flagged issues rather than rebuilding from scratch.

**Mode D (Socratic):**

1. Read `construct-socratic-prompt.md`. This file is an orchestrator playbook, NOT an Agent dispatch prompt. The orchestrator owns the loop; no Agent is dispatched in Phase 2 for Mode D.
2. Run the turn loop the playbook specifies: each turn is one `AskUserQuestion` plus one inline micro-audit. After each accepted turn, write the partial `{OUTPUT_PATH}/construction.md` in the standard schema with `<pending>` placeholders for unanswered nodes; emit a one-line progress summary to the user.
3. Every `AskUserQuestion` carries four standard options: *Other (type my answer)* (the freeform answer field), *Hand off remaining tiers to Mode A*, *Pause and resume later*, *Cancel*.
4. **Hand-off to Mode A.** If the user picks *Hand off remaining tiers to Mode A* at any turn: update the state file's `mode` to `greenfield` and add `handoff_from: socratic`; read `construct-greenfield-prompt.md`, set `{HANDOFF}` to `true`, dispatch the greenfield agent. Phase 2 continues from the agent's output; Phases 3-5 run unchanged on the merged pyramid.
5. **Pause.** If the user picks *Pause and resume later*: write the state file with `mode: socratic`, `last_completed_phase: intake`, `last_run_at: <now>`. Emit a one-line confirmation and exit.
6. **Cancel.** Same semantics as Cancel in Modes A and B: working directory artifacts left in place; state file entry removed.
7. **Resume.** Next `/pyramid` invocation in this directory: state file with `mode: socratic` and `last_completed_phase: intake` triggers an `AskUserQuestion`: *"In-flight Socratic dialogue found. Resume from <next-turn description>?"*. On yes, read `construction.md`, count populated nodes vs `<pending>` placeholders to infer next turn, re-enter the loop.
8. When all turns complete, verify `{OUTPUT_PATH}/construction.md` exists and contains no `<pending>` placeholders. Mark task completed.

On re-dispatch (after a CRITICAL audit gate from Phase 3), Mode D's pyramid is treated as the user-built ground truth: re-dispatch goes to `construct-greenfield-prompt.md` with `{HANDOFF}` set to `true` and `{REVIEWER_FEEDBACK}` populated, so the agent updates the construction in place rather than restarting the dialogue.

### Phase 3: Audit panel

Four subagent dispatches in parallel when supported. Issue all four host subagent calls in one turn when the platform supports concurrent dispatch.

| Prompt file | Output file | Lens |
|---|---|---|
| `audits/mece.md` | `audit-mece.md` | Four MECE Audit Questions (reference section 4) |
| `audits/so-what.md` | `audit-so-what.md` | So-What / Why-Is-That-True / Caveman Answer (reference section 6) |
| `audits/qa-alignment.md` | `audit-qa.md` | Q-A Alignment Audit (reference section 3) |
| `audits/inductive-deductive.md` | `audit-logic.md` | Inductive vs Deductive classification (reference section 5) |

For each auditor:
1. Read the prompt file from the table above.
2. Inject output path, reference path, empty reviewer feedback.
3. Dispatch via the host subagent tool, all four in the same turn when supported.
4. Verify the corresponding output file exists.
5. Mark the sub-task completed.

When all four audits return, consolidate into `audit-summary.md`:

```markdown
# Audit Summary

## Verdicts

| Auditor | Verdict | Headline |
|---------|---------|----------|
| MECE | <PASS / MINOR / CRITICAL> | <one-line summary> |
| So-What | ... | ... |
| Q-A Alignment | ... | ... |
| Inductive/Deductive | ... | ... |

## MECE
<full content of audit-mece.md>

## So-What
<full content of audit-so-what.md>

## Q-A Alignment
<full content of audit-qa.md>

## Inductive/Deductive
<full content of audit-logic.md>
```

Then check verdicts. **Match on the first whitespace-delimited token of each auditor's `**Verdict:**` line.** Auditors emit `PASS`, `MINOR ISSUES`, or `CRITICAL ISSUES`; only the first token is the gate signal. Expected tokens: `PASS`, `MINOR`, `CRITICAL`.

- All four auditors emit `PASS` or `MINOR` → continue to Phase 4 (opener).
- One or more auditors emit `CRITICAL` → re-dispatch Phase 2 (construct) with `audit-summary.md` injected as `{REVIEWER_FEEDBACK}`. Re-run Phase 3. Repeat up to 2 total iterations. If still CRITICAL after 2 iterations, present remaining critical issues to the user via AskUserQuestion: *Continue to opener with known logic issues / Pause for manual intervention / Cancel.*

Mark phase task completed when the verdict allows progression or the user overrides.

### Phase 4: Opener

One Agent dispatch.

1. Read `opener-prompt.md`.
2. Inject: output path, reference path, empty reviewer feedback.
3. Dispatch via the host subagent tool.
4. Verify `{OUTPUT_PATH}/opener.md` exists.
5. Inspect the first non-frontmatter line. If it reads `**Verdict:** MISMATCH`, do NOT treat this as a failure. The opener agent correctly refused to manufacture a bogus complication. Read the `## Reason` and `## Partial opener` sections and ask the user via AskUserQuestion: *Proceed with degraded opener (S and A only, C and Q omitted) / Revise apex by re-running construct with the mismatch note injected as reviewer feedback / Cancel.*
6. If the user chooses to revise the apex, inject the MISMATCH reason into `{REVIEWER_FEEDBACK}` and re-dispatch Phase 2, then re-run Phase 3, then re-run Phase 4. If the user proceeds with the degraded opener, Phase 5 will render only S and A.
7. Mark task completed.

The opener is deliberately Phase 4 (not Phase 1) so it is written LAST against a stable apex. This prevents a premature opener from forcing structural changes to the apex, which is the whole point of the pyramid method.

### Phase 5: Render

Orchestrator-only. No Agent dispatch.

1. Read `{OUTPUT_PATH}/construction.md` for apex, top-level grouping noun, siblings, and evidence.
2. Read `{OUTPUT_PATH}/opener.md` for the SCQA opener (or the Partial opener if MISMATCH was accepted).
3. Read `{OUTPUT_PATH}/audit-summary.md` for the MINOR flags worth surfacing.
4. Assemble `{OUTPUT_PATH}/pyramid.md` in this shape:

```markdown
# <working title inferred from apex, or provided at intake>

**Opener (SCQA).**
S: <situation>. C: <complication>. Q: <question>. A: <apex>.

## Apex
<one-sentence governing thought, verbatim from construction.md>

## Supporting findings (<plural noun from construction.md>)

- <Finding 1>
  - <evidence>
  - <evidence>
- <Finding 2>
  - <evidence>
  - <sub-grouping if present, rendered as nested bullets>
- <Finding 3>
  - ...

## Audit notes

The following MINOR flags did not block the pyramid but are worth knowing:

- <MECE flag from audit-summary>
- <So-What flag>
- <...>
```

Degraded render cases:
- **Opener was MISMATCH and user accepted degraded output.** Replace the SCQA line with a Partial opener rendered from `opener.md`'s `## Partial opener` section (S and A only; omit C and Q).
- **All four audits returned PASS.** The Audit notes section reads exactly: *"All four audits passed."*
- **Genre override from domain-limits gate.** Prepend a caveat to Audit notes: *"Genre override: user acknowledged the pyramid may be the wrong frame for this piece."*

Mark task completed and update the state file.

### Step 6: Update state and present

Update the state file. The working directory is the *key* under `projects` (not a field). For that key, write:
- `mode`: `greenfield` or `restructure`
- `active_reference`: absolute path
- `last_completed_phase`: name of the last successful phase
- `last_run_at`: ISO timestamp

See the State File Format section below for the exact JSON shape.

Present `pyramid.md` and `audit-summary.md` to the user.

## Edge Cases

- **Working dir does not exist**: create with `mkdir -p`.
- **Reference not found at any level**: fall back to the skill default and warn "Using default pyramid reference".
- **Phase artifact missing on resume**: re-run that phase.
- **Agent dispatch fails**: retry once, then surface the error and pause.
- **Auditor returns malformed output** (no `**Verdict:**` line, or an unrecognised token): log, treat as `MINOR`, continue with the remaining auditors. Record the malformed output in `audit-summary.md` under the auditor's section verbatim so the user can inspect it.
- **User cancels mid-pipeline**: the state file records the last completed phase; the next invocation resumes from there.
- **Audit gate fails twice** (CRITICAL after 2 iterations): present remaining critical issues, ask whether to continue to opener with known issues, pause for manual intervention, or cancel.
- **Missing prerequisite artifact on phase jump**: some phases depend on artifacts produced by earlier phases:
  - `construct` needs `intake.md`.
  - `audit` needs `construction.md`.
  - `opener` needs `construction.md` (and benefits from `audit-summary.md` for MINOR flags).
  - `render` needs `construction.md` AND `opener.md` (and `audit-summary.md` for the notes section).
  If the user invokes `--phase X` on a directory missing the upstream artifact, ask via AskUserQuestion whether to (a) run the missing upstream phase first, (b) accept a degraded run (only safe for render without opener.md, which renders S-and-A placeholder in place of the SCQA line), or (c) cancel and let the user produce the artifact manually.
- **Unknown mode value** (state file contains a value other than `greenfield`, `restructure`, or `socratic`): warn once, fall back to asking the user via AskUserQuestion, and record the corrected value in the state file.
- **Mode A (Greenfield) with a draft present in cwd**: if `draft.md` already exists in the working directory but the user picked greenfield, surface the file and ask: *"A draft is present in this directory. Did you mean Restructure mode?"* via AskUserQuestion. Accept the answer and proceed.
- **Mode B (Restructure) with an empty or missing draft**: if `draft.md` is empty (zero bytes) or the provided path does not exist, ask the user to supply the draft or bail to Mode A (Greenfield).
- **Mode D (Socratic) repeated block on the same turn**: after two failed attempts on a hard-blocked turn (apex is a label, sibling is a label, sibling count exceeds 5), soften to a warning on the third attempt: *"Letting this through. The audit panel will flag it formally."* Caps user frustration without abandoning the discipline.
- **Mode D with existing `construction.md` from a prior run**: ask via AskUserQuestion *Reset and rebuild via dialogue / Keep existing pyramid (no Mode D needed) / Cancel*. Honor the choice.
- **Mode D empty answer in the freeform field**: re-ask the question without consuming a turn.
- **Mode D phase-jump invocation (`--phase construct --mode socratic` on a directory without `intake.md`)**: same handling as Mode A; ask whether to run intake first.
- **Domain-limits gate override**: the user chose *Proceed anyway* despite a mismatched genre. The pipeline continues normally. Phase 5 render prepends a caveat to the Audit notes section (see Phase 5 above).

## State File Format

`<state-root>/<project-id>/pyramid-skill-state.json`:

```json
{
  "version": 1,
  "projects": {
    "<absolute-working-directory>": {
      "mode": "greenfield",
      "active_reference": "<absolute-path-or-default>",
      "last_completed_phase": "construct",
      "last_run_at": "2026-04-24T12:00:00Z"
    }
  }
}
```

Recognised mode values: `greenfield`, `restructure`, `socratic`. Key by absolute working-directory path so multiple in-flight pyramids in the same project each have their own state. After a Mode-D-to-Mode-A hand-off, the `mode` field becomes `greenfield` and an optional `handoff_from: socratic` field is added.

## Phase Identifier Names

Used in `--phase` flag and task list:
`intake`, `construct`, `audit`, `opener`, `render`

## Behavioral Guidelines

- Trigger on memo, recommendation, briefing, decision document, or analytical report intent, and on explicit requests for pyramid or Minto structure.
- Do NOT trigger on narrative, personal essay, exploratory or discovery, or pedagogical writing. Route those to the writing skill.
- Always announce the active reference in the first response: *"Using pyramid reference: {path}"*.
- Always create the task list before dispatching the first phase agent so the user sees what is coming.
- Never skip the domain-limits gate silently. Surface it even when the user asked for pyramid explicitly; the writer stays in control but must acknowledge the mismatch.
- Auditors emit verdicts (PASS / MINOR / CRITICAL); the orchestrator decides whether to gate or proceed based on those tokens.
- The opener is written LAST (Phase 4), against a stable apex, so it cannot force structural changes to the apex. A MISMATCH verdict is a legitimate outcome, not a failure: it means the apex cannot support a clean SCQA and the user must decide whether to degrade the opener or revise the apex.
