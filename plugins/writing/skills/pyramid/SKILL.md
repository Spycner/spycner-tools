---
name: pyramid
description: Use when the user wants a pyramid-structured outline (Barbara Minto's pyramid principle) for a memo, recommendation, briefing, decision document, or analytical report; or wants to restructure an existing draft into pyramid form. Two construction modes (greenfield, restructure). Orchestrates a five-phase pipeline (intake with domain-limits gate, construct, parallel audit panel of MECE / So-What / Q-A Alignment / Inductive-Deductive, SCQA opener, render). Triggers on memo/recommendation/briefing intent and on explicit requests for pyramid/Minto structure. Does NOT trigger for narrative prose, personal essays, or exploratory documents, those belong to the writing skill.
---

# Pyramid Skill

Multi-phase pyramid-principle skill with a parallel audit panel. Modeled on Barbara Minto's method.

---

## Tool Preference

1. **Agent tool**: to dispatch phase agents (construct in greenfield or restructure mode, opener) and the audit panel (MECE, So-What, Q-A Alignment, Inductive-Deductive). Intake and render run in the orchestrator itself and do not dispatch an agent.
2. **Read**: to load prompt templates, the shipped reference, and existing artifacts.
3. **Bash**: for directory creation, file existence checks, and state file read/write.
4. **TaskCreate / TaskUpdate**: to surface progress through the pipeline visibly.
5. **Write / Edit**: for intake.md, audit-summary.md, pyramid.md, and state file management.
6. **AskUserQuestion**: for mode and genre selection, domain-limits gate, MISMATCH routing, and audit re-dispatch overrides.

## Workflow

### Step 1: Determine working directory

Resolve working directory in this order:
1. **Explicit flag**: `--dir ./path/to/project/`
2. **Existing artifacts in cwd**: if the cwd already contains any of `intake.md`, `construction.md`, `audit-summary.md`, `opener.md`, `pyramid.md`, treat the cwd as the working directory.
3. **State file lookup**: read `~/.claude/projects/<project-id>/pyramid-skill-state.json` (where `<project-id>` is the cwd path with slashes replaced by hyphens, leading hyphen stripped). If an in-flight pyramid is recorded, offer to resume there.
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

Use TaskCreate to add one task per phase that will run, plus four sub-tasks for the audit panel. Example for a fresh full pipeline:

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

Dispatch each phase agent via the Agent tool. The orchestrator injects context into the prompt template.

#### Dispatch conventions (apply to every phase)

- **`{OUTPUT_PATH}` is always the working directory**, never a file path. Each prompt file appends its own filename.
- **Prompt file extraction.** Each prompt file documents the dispatched prompt inside a fenced block under the `**Dispatch:**` header. The simplest robust approach: read the entire prompt file as text, perform placeholder substitution (`{OUTPUT_PATH}`, `{REFERENCE_PATH}`, `{REVIEWER_FEEDBACK}`, `{YYYY-MM-DD}`), and pass the full result to the Agent tool. The dispatched agent ignores the surrounding commentary because the actionable instructions sit inside the visible prompt body.
- **Reviewer feedback injection.** When `{REVIEWER_FEEDBACK}` is non-empty (re-dispatch on a failed audit gate, or after a MISMATCH the user asked to revise), append this standing instruction to the dispatched prompt, regardless of what the prompt template itself says: *"Reviewer feedback is provided above. Read the existing artifact in the output directory, address the specific concerns, and update the file in place rather than starting fresh."*
- **Date substitution.** `{YYYY-MM-DD}` resolves to today's date in ISO format.

## Phase details

### Phase 1: Intake

Orchestrator-only, interactive. No Agent dispatch.

1. **Mode.** Ask via AskUserQuestion: *Greenfield (I have a topic and want a fresh pyramid outline) / Restructure (I have an existing draft and want to pyramid-ify it)*. Always ask, even if `--mode` was passed; the flag only pre-selects the option. This prevents "surprise wrong mode" failures.
2. **Genre.** Ask via AskUserQuestion: *Memo / Recommendation / Briefing / Strategy doc / Case interview answer / Project proposal / Postmortem / Other (describe)*. Map to the lists in reference section 11.
3. **Domain-limits gate.** If the genre falls in the "Does not work for" list from reference section 11 (narrative longform, personal essay, exploratory or discovery document, emotionally-driven persuasion, creative writing, in-progress thinking, pedagogical walk-through), surface the mismatch via AskUserQuestion with three options: *Proceed anyway (I understand the pyramid may be the wrong frame) / Switch: route me to the writing skill instead / Cancel*. Honor the choice. If the user proceeds anyway, record `genre_override: true` in intake.md so Phase 5 can prepend a caveat to Audit notes.
4. **Mode A (Greenfield) inputs.** Ask for topic, audience, and the reader question (the question you expect the reader to have, which the apex will answer). Use AskUserQuestion or simple prompts as appropriate.
5. **Mode B (Restructure) inputs.** Ask for the draft path (absolute path to a markdown file) OR accept the draft pasted inline. If pasted inline, write it to `{OUTPUT_PATH}/draft.md`. Either way, the construct agent reads `draft.md` from the working directory.
6. **Write intake.md** with fields: `mode`, `topic_or_draft_path`, `audience`, `reader_question`, `genre`, `domain_limits_acknowledged`, `genre_override`.
7. Mark the Phase 1 task completed.

### Phase 2: Construct

One Agent dispatch, mode-branched.

1. Read `construct-greenfield-prompt.md` if `mode == greenfield`, or `construct-restructure-prompt.md` if `mode == restructure`.
2. Inject: output path, reference path, empty reviewer feedback (on first dispatch; populated on re-dispatch), today's date.
3. Dispatch via Agent tool.
4. Verify `{OUTPUT_PATH}/construction.md` exists. For Mode B (restructure), also verify `{OUTPUT_PATH}/restructure-notes.md` exists.
5. Mark task completed.

On re-dispatch (after a CRITICAL audit gate), inject `audit-summary.md` content as `{REVIEWER_FEEDBACK}` so the construct agent updates `construction.md` in place to address the flagged issues rather than rebuilding from scratch.

### Phase 3: Audit panel

Four Agent dispatches in PARALLEL. Issue all four Agent tool calls in a single message so they run concurrently.

| Prompt file | Output file | Lens |
|---|---|---|
| `audits/mece.md` | `audit-mece.md` | Four MECE Audit Questions (reference section 4) |
| `audits/so-what.md` | `audit-so-what.md` | So-What / Why-Is-That-True / Caveman Answer (reference section 6) |
| `audits/qa-alignment.md` | `audit-qa.md` | Q-A Alignment Audit (reference section 3) |
| `audits/inductive-deductive.md` | `audit-logic.md` | Inductive vs Deductive classification (reference section 5) |

For each auditor:
1. Read the prompt file from the table above.
2. Inject output path, reference path, empty reviewer feedback.
3. Dispatch via Agent tool (all four in the same message to run in parallel).
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
3. Dispatch via Agent tool.
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
- **Unknown mode value** (state file contains a value other than `greenfield` or `restructure`): warn once, fall back to asking the user via AskUserQuestion, and record the corrected value in the state file.
- **Mode A (Greenfield) with a draft present in cwd**: if `draft.md` already exists in the working directory but the user picked greenfield, surface the file and ask: *"A draft is present in this directory. Did you mean Restructure mode?"* via AskUserQuestion. Accept the answer and proceed.
- **Mode B (Restructure) with an empty or missing draft**: if `draft.md` is empty (zero bytes) or the provided path does not exist, ask the user to supply the draft or bail to Mode A (Greenfield).
- **Domain-limits gate override**: the user chose *Proceed anyway* despite a mismatched genre. The pipeline continues normally. Phase 5 render prepends a caveat to the Audit notes section (see Phase 5 above).

## State File Format

`~/.claude/projects/<project-id>/pyramid-skill-state.json`:

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

Recognised mode values: `greenfield`, `restructure`. Key by absolute working-directory path so multiple in-flight pyramids in the same project each have their own state.

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
