---
name: writing
description: Use when the user wants to draft a blog post, essay, talk, newsletter, memo, announcement, briefing, literature note, or any longer-form prose; or when they want to review, critique, or finish an existing draft. Orchestrates a multi-phase pipeline (interview, outline, throughline gate, draft, panel review, finishing) modeled on Katie Parrott's process. For analytical formats (memo, briefing, announcement), the outline phase dispatches to the pyramid skill for Minto-style structural construction (intake, construct, audit, opener, render) and the draft phase uses an analytical draft prompt. The format-gated Smart-Brevity panel critic runs for memo, newsletter, and announcement pieces. Triggers on writing intent (drafting, reviewing, polishing, voice work) and not on simple text generation tasks.
---

# Writing Skill

Multi-phase writing pipeline with a panel of specialised critics. Modeled on Katie Parrott's process and the existing research plugin's orchestrator pattern.

---

## Tool Preference

1. **Subagent dispatch when available and permitted**: to dispatch phase agents (interview, outline, draft, plus the dispatched pyramid pipeline for analytical formats) and critics (Hemingway, Hitchcock, Mom reader, Asshole reader, Clarity, Usage, Steel-man, plus Smart-Brevity for memo/newsletter/announcement formats) and finishing passes (AI-pattern detector, style enforcer, line editor, Sedaris for narrative formats or analytical-voice for analytical formats). The throughline gate runs in the orchestrator and does not dispatch an agent.
2. **File read tools**: to load prompt templates and existing artifacts
3. **Shell**: for directory creation, file existence checks, state file read/write
4. **Progress list**: to surface progress through the pipeline visibly
5. **File write and edit tools**: for state file management and orchestrator-level artifact updates
6. **User question tool or direct question**: for outline negotiation and resolution choices

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

### Step 1: Determine the topic and the working directory

Ask the user what they want to write about (or what existing piece they want to work on).

Resolve working directory in this order:
1. **Explicit flag**: `--dir ./path/to/project/`
2. **Existing artifacts in cwd**: if the cwd already contains any of `interview.md`, `outline.md`, `intake.md`, `pyramid.md`, `draft.md`, `critique.md`, treat the cwd as the working directory
3. **State file lookup**: read `<state-root>/<project-id>/writing-skill-state.json` (where `<project-id>` is the cwd path with slashes replaced by hyphens, leading hyphen). If a working directory is recorded for an in-flight piece, offer to resume there.
4. **Default**: prompt for a slug, create `writing/{slug}-{YYYY-MM-DD}/` in the cwd.

### Step 2: Resolve the active style guide

Resolution order:
1. Explicit flag: `--style-guide ./path/to/guide.md`
2. Project-level: search for `style-guide.md` or `CLAUDE.md` in the working directory and parents (up to repo root)
3. State memory: the state file's recorded style guide for this project
4. Skill default: `default-style-guide.md` shipped with this skill. Resolve its absolute path by locating the directory of this `SKILL.md` file (the skill's own install path) via `Glob` on `**/writing/SKILL.md` under the active plugin directory, then take the parent.

If multiple candidates exist at the project level (e.g., both `style-guide.md` and a `CLAUDE.md` in scope), use AskUserQuestion to ask once which to use, then record the choice in the state file.

Surface the active guide in the first response: "Using style guide: {path}".

### Step 3: Determine the piece format

Panel composition and the outline / draft phases change based on format. The pipeline branches on whether the format is **analytical** (memo, briefing, announcement) or **narrative** (essay, blog, talk, newsletter).

Supported formats:
- Narrative: `essay` (default), `blog`, `talk`, `newsletter`
- Analytical: `memo`, `briefing`, `announcement`
- Technical: `tutorial`, `how-to`, `reference`, `explanation`

Resolution order:
1. Explicit flag: `--format <format>`
2. State memory: the state file's recorded format for this project
3. Default silently to `essay` and surface the default in the first response with an inline change hint: "Format: essay (default). Pass `--format memo|briefing|announcement|newsletter|blog|talk|tutorial|how-to|reference|explanation` to change."

Ask via AskUserQuestion only when the working directory name or the interview synthesis strongly signals a different format than the recorded state (for example, a state-stored `essay` format but the working directory is `memos/q3-roadmap-2026-04-23/`). In ambiguous cases, surface both candidates and let the user pick. Otherwise, resolve silently.

Format gates:
- **Pyramid pipeline:** analytical formats (`memo`, `briefing`, `announcement`) skip writing's interview and outline phases entirely. Phase 1 dispatches the pyramid skill's intake; Phase 2 dispatches pyramid's construct, audit, opener, and render phases. The pyramid pipeline produces `pyramid.md`, which is then consumed by writing's throughline (Phase 3) and analytical draft (Phase 4) phases.
- **Smart-Brevity critic:** formats `memo`, `newsletter`, `announcement` add the Smart-Brevity critic to the panel fan-out. Other formats run the default seven-critic panel. Note: `briefing` does NOT add Smart-Brevity, because briefings are dense by construction and the Smart-Brevity lens has lower signal there.
- **Tech-doc pipeline:** technical formats (`tutorial`, `how-to`, `reference`, `explanation`) skip writing's interview, outline, draft, panel, and finishing phases entirely. Phase 1 dispatches the tech-doc skill's intake; Phase 2 dispatches tech-doc's outline + throughline + draft + panel + finishing as one cohesive sub-pipeline. Writing's Phase 5 (panel) and Phase 6 (finishing) are skipped because tech-doc owns end-to-end. The tech-doc pipeline produces `draft.md`, `critique.md`, `finishing-notes.md`, and `glossary.md`.

Surface the active format in the first response alongside the style guide: "Format: {format}. Using style guide: {path}". Record the format in the state file under the project key.

### Step 4: Determine starting phase

Scan the working directory for existing artifacts. Two artifact families exist depending on format:

**Narrative format artifacts (essay, blog, talk, newsletter):**
- `interview-synthesis.md` exists → interview phase complete
- `outline.md` exists → outline phase complete
- `throughline.md` exists → throughline phase complete
- `draft.md` exists → draft phase complete
- `critique.md` exists → panel phase complete
- `finishing-notes.md` exists → finishing phase has started or completed

**Analytical format artifacts (memo, briefing, announcement):**
- `intake.md` exists → pyramid intake (Phase 1) complete
- `construction.md` exists → pyramid construct (Phase 2 substep) complete
- `audit-summary.md` exists → pyramid audit (Phase 2 substep) complete
- `opener.md` exists → pyramid opener (Phase 2 substep) complete
- `pyramid.md` exists → pyramid render (Phase 2) complete; outline equivalent ready for throughline
- `throughline.md` exists → throughline phase complete
- `draft.md` exists → draft phase complete
- `critique.md` exists → panel phase complete
- `finishing-notes.md` exists → finishing phase has started or completed

**Technical format artifacts (tutorial, how-to, reference, explanation):**
- `intake.md` exists → tech-doc intake (Phase 1) complete
- `outline.md` exists (tutorial/how-to/explanation) OR `schema.md` exists (reference) → tech-doc outline (Phase 2 substep) complete
- `throughline.md` exists → tech-doc throughline (Phase 2 substep) complete
- `draft.md` exists → tech-doc draft (Phase 2 substep) complete
- `critique.md` exists → tech-doc panel complete (Phase 2 sub-substep)
- `finishing-notes.md` exists → tech-doc finishing has started or completed (Phase 2 sub-substep)
- `glossary.md` exists → tech-doc terminology-consistency pass has run

For technical formats, writing's phase identifiers map to tech-doc's: writing's "Phase 1" is tech-doc's intake; writing's "Phase 2" is tech-doc's everything-after-intake.

Determine the latest completed phase. Present to user:
- "I see you have completed phases X. Resume from {next phase}?"
- Offer phase-jump option: user can name any phase to jump to

User can also pre-empt the dialogue by passing `--phase X` (X ∈ {interview, outline, throughline, draft, panel, finishing}).

### Step 5: Create task list

Use the progress list to add one task per phase that will run, plus sub-tasks for the panel and finishing phases. Two task list shapes exist depending on format.

**Narrative format task list** (essay, blog, talk, newsletter):

```
1. Phase 1: Interview the author
2. Phase 2: Negotiate outline
3. Phase 3: Throughline check (≤10-word gate)
4. Phase 4: Draft sections
5. Phase 5: Run panel review
   ├── Critic: Hemingway
   ├── Critic: Hitchcock
   ├── Critic: Mom reader
   ├── Critic: Asshole reader
   ├── Critic: Clarity
   ├── Critic: Usage
   ├── Critic: Steel-man
   └── Critic: Smart-Brevity (only for newsletter)
6. Phase 6: Finishing pass
   ├── AI-pattern detector
   ├── Style enforcer
   ├── Line editor
   └── Sedaris
```

**Analytical format task list** (memo, briefing, announcement):

```
1. Phase 1: Pyramid intake (mode, audience, reader question)
2. Phase 2: Pyramid construct + audit + opener + render
   ├── Construct
   ├── Audit panel (MECE, So-What, Q-A Alignment, Inductive-Deductive)
   ├── Opener (SCQA)
   └── Render pyramid.md
3. Phase 3: Throughline check (≤10-word gate on apex)
4. Phase 4: Analytical draft
5. Phase 5: Run panel review
   ├── Critic: Hemingway
   ├── Critic: Hitchcock
   ├── Critic: Mom reader
   ├── Critic: Asshole reader
   ├── Critic: Clarity
   ├── Critic: Usage
   ├── Critic: Steel-man
   └── Critic: Smart-Brevity (only for memo, announcement)
6. Phase 6: Finishing pass
   ├── AI-pattern detector
   ├── Style enforcer
   ├── Line editor
   └── Analytical voice
```

**Technical format task list** (tutorial, how-to, reference, explanation):

```
1. Phase 1: Tech-doc intake (quadrant-specific)
2. Phase 2: Tech-doc pipeline (outline, throughline, draft, panel, finishing)
   ├── Outline (or schema for reference)
   ├── Throughline gate
   ├── Draft (quadrant-specific)
   ├── Panel review (7 critics, quadrant-gated composition)
   └── Finishing (AI-pattern, style-enforcer-tech, terminology-consistency)
```

The technical pipeline is one-shot from writing's perspective: writing dispatches to tech-doc once and tech-doc owns end-to-end. The expanded sub-tree is shown for visibility into what's running.

For phase-selectable runs, only the requested phases get tasks.

Mark each task as `in_progress` when starting, `completed` when the artifact is verified.

### Step 6: Execute phases

Dispatch each phase agent via the host subagent tool when supported. The orchestrator injects context into the prompt template.

#### Dispatch conventions (apply to every phase)

- **`{OUTPUT_PATH}` is always the working directory**, never a file path. Each prompt file appends its own filename.
- **Prompt file extraction.** Each prompt file documents the dispatched prompt inside a fenced block under the `**Dispatch:**` header. The dispatched body itself contains nested fences for example outputs. The simplest robust approach: read the entire prompt file as text, perform placeholder substitution (`{TOPIC}`, `{OUTPUT_PATH}`, `{STYLE_GUIDE_PATH}`, `{REVIEWER_FEEDBACK}`, `{YYYY-MM-DD}`), and pass the full result to the host subagent tool. The dispatched agent ignores the surrounding commentary because the actionable instructions sit inside the visible prompt body.
- **Reviewer feedback injection.** When `{REVIEWER_FEEDBACK}` is non-empty (re-dispatch on a failed gate), append this standing instruction to the dispatched prompt, regardless of what the prompt template itself says: *"Reviewer feedback is provided above. Read the existing artifact in the output directory, address the specific concerns, and update the file in place rather than starting fresh."* This compensates for the asymmetric treatment of feedback across the prompt files.
- **Date substitution.** `{YYYY-MM-DD}` resolves to today's date in ISO format.

#### Phase 1: Interview (narrative formats) or Pyramid intake (analytical formats)

**Narrative formats** (essay, blog, talk, newsletter):

1. Read `interview-prompt.md` from this skill directory
2. Inject: topic, output path, style guide path, empty reviewer feedback
3. Dispatch via the host subagent tool. The agent will conduct an interactive interview with the user.
4. Verify `interview.md` and `interview-synthesis.md` exist
5. Mark task completed

**Analytical formats** (memo, briefing, announcement):

Skip writing's interview entirely. Run the pyramid skill's Phase 1 (intake) in **dispatched mode** as documented in `plugins/writing/skills/pyramid/SKILL.md`, with these adjustments:

1. **Mode (step 1 of pyramid intake):** ask via AskUserQuestion as normal. Note: Mode B (Restructure) is rare in this dispatched path because writing skill is forward-building; the writer typically picks Greenfield or Socratic.
2. **Genre (step 2 of pyramid intake):** pre-fill from the writing skill's resolved format. `memo` → genre `Memo`. `briefing` → genre `Briefing`. `announcement` → genre `Announcement`. Do NOT ask the user; surface the pre-fill in a one-line confirmation: "Genre: {genre} (from format)."
3. **Domain-limits gate (step 3 of pyramid intake):** SKIP. The writing skill's format gating already validated the genre is analytical-compatible; surfacing the gate would be redundant.
4. **Mode-specific inputs (whichever of steps 4, 5, or 6 of pyramid intake matches the mode chosen in step 1):** ask as normal.
5. **Write intake.md (step 7 of pyramid intake):** as normal, but add field `dispatched_from: writing` so future runs know the entry point.
6. **Mark Phase 1 task completed** when `intake.md` exists.

The orchestrator reads pyramid SKILL.md sections at dispatch time. No code or prompt files are duplicated; the dispatched mode is an instruction overlay applied to pyramid's standalone Phase 1.

**Technical formats** (tutorial, how-to, reference, explanation):

Skip writing's interview entirely. Run the tech-doc skill's Phase 1 (intake) in dispatched mode as documented in `plugins/writing/skills/tech-doc/SKILL.md`, with these adjustments:

1. **Quadrant (always-asked step in tech-doc intake):** pre-fill from the writing skill's resolved format. `tutorial` → quadrant `tutorial`, `how-to` → quadrant `how-to`, `reference` → quadrant `reference`, `explanation` → quadrant `explanation`. Surface the pre-fill in a one-line confirmation: "Quadrant: {quadrant} (from format)." Tech-doc's standalone path always asks the quadrant question; in dispatched mode, accept the format-derived value and skip the question.
2. **Style preset:** dispatch with `--style-preset` set per writing's resolved style guide if it matches a preset (`google`, `microsoft`, or `house`). Otherwise default to `house`.
3. **Write intake.md field:** add `dispatched_from: writing` to the intake.md fields so resume logic can distinguish dispatched-mode intake from a standalone tech-doc run. (Mirrors the analytical dispatch's `dispatched_from: writing` field added to pyramid's intake.md.)
4. **Mark Phase 1 task completed** when `intake.md` exists.

The orchestrator reads tech-doc SKILL.md sections at dispatch time. No code or prompt files are duplicated.

#### Phase 2: Outline (narrative formats) or Pyramid pipeline (analytical formats)

**Narrative formats** (essay, blog, talk, newsletter):

1. Read `outline-prompt.md`
2. Inject: output path, style guide path, empty reviewer feedback
3. Dispatch via the host subagent tool
4. Verify `outline.md` exists
5. Surface the outline to the user. Accept revisions via AskUserQuestion ("Outline as proposed, or revisions before draft?"). On revisions, re-dispatch with feedback injected.
6. Mark task completed when user accepts.

**Analytical formats** (memo, briefing, announcement):

Run pyramid skill's Phases 2 through 5 (construct, audit, opener, render) inline as documented in `plugins/writing/skills/pyramid/SKILL.md`. The pyramid pipeline is reused unchanged; the orchestrator follows pyramid SKILL.md's instructions for each phase.

1. **Pyramid Phase 2 (Construct):** dispatch the construct agent per `pyramid/SKILL.md`. Mode-branched (greenfield, restructure, socratic) based on the mode collected in Phase 1. Verify `construction.md` exists.
2. **Pyramid Phase 3 (Audit panel):** fan out four audit agents in parallel per `pyramid/SKILL.md`. Consolidate into `audit-summary.md`. Apply pyramid's CRITICAL re-dispatch logic (up to 2 iterations) verbatim.
3. **Pyramid Phase 4 (Opener):** dispatch the opener agent per `pyramid/SKILL.md`. Apply pyramid's MISMATCH handling verbatim.
4. **Pyramid Phase 5 (Render):** assemble `pyramid.md` per `pyramid/SKILL.md`'s render template. The pyramid is the outline equivalent for the analytical pipeline.
5. Surface `pyramid.md` to the user. Accept revisions via AskUserQuestion ("Pyramid as proposed, or revisions before draft?"). On revisions, re-dispatch the construct agent (pyramid Phase 2) with the feedback injected, then re-run audit, opener, and render.
6. Mark task completed when user accepts.

After Phase 2 completes, the working directory contains `intake.md`, `construction.md`, `audit-summary.md`, `opener.md`, and `pyramid.md`. The throughline phase reads `pyramid.md`'s apex line; the analytical draft phase reads `pyramid.md` whole.

**Technical formats** (tutorial, how-to, reference, explanation):

Run tech-doc skill's Phases 2-6 (outline, throughline, draft, panel, finishing) inline as documented in `plugins/writing/skills/tech-doc/SKILL.md`. The tech-doc pipeline is reused unchanged; the orchestrator follows tech-doc SKILL.md for each phase.

1. **Tech-doc Phase 2 (Outline):** dispatch the outline phase per `tech-doc/SKILL.md`. Verify `outline.md` (tutorial/how-to/explanation) or `schema.md` (reference) exists.
2. **Tech-doc Phase 3 (Throughline gate):** orchestrator-only. Apply tech-doc's gate per quadrant.
3. **Tech-doc Phase 4 (Draft):** dispatch the quadrant-specific draft agent.
4. **Tech-doc Phase 5 (Panel):** fan out 7 critics in parallel per quadrant. Apply tech-doc's CRITICAL re-dispatch logic verbatim.
5. **Tech-doc Phase 6 (Finishing):** three sequential passes (AI-pattern detector, style-enforcer-tech, terminology-consistency).
6. Surface `draft.md`, `glossary.md`, and `finishing-notes.md` to the user.
7. Mark task completed.

#### Phase 3: Throughline

**For technical formats (tutorial, how-to, reference, explanation):** SKIPPED. Tech-doc's throughline gate has already run during the dispatch in writing's Phase 2. Mark phase task completed and proceed to Phase 4.

Orchestrator-only synchronous gate. No agent dispatch. Happens after Phase 2 completes, before the draft agent is dispatched. If the writer cannot compress the piece into ten words, the piece is not ready to draft.

**Source of truth varies by format:**
- Narrative formats: read `{OUTPUT_PATH}/outline.md` and extract the `**Thesis (one sentence):**` line.
- Analytical formats: read `{OUTPUT_PATH}/pyramid.md` and extract the line under the `## Apex` header (the one-sentence governing thought rendered verbatim from `construction.md`).

1. Surface the source line to the user via AskUserQuestion: "Throughline check. Compress the piece to ≤10 words. Current {thesis|apex}: \"{line}\". What is the one thing you most want the reader to take away?"
2. Validate word count on the user's response by splitting on whitespace and ignoring empty strings. If more than 10 words, re-ask via AskUserQuestion: "That is N words. Cut it to 10 or fewer. If you cannot, the {outline|pyramid} may be wrong. Return to Phase 2."
3. Offer an explicit escape hatch: the user may answer the re-ask with "RETURN TO OUTLINE" (narrative) or "RETURN TO PYRAMID" (analytical) to resume Phase 2 with their attempted throughline as reviewer feedback injected into the outline / construct prompt.
4. On acceptance, write `{OUTPUT_PATH}/throughline.md` as a single-line file containing only the accepted throughline (no markdown headers, no decoration).
5. Mark task completed.

**Edge case for analytical formats:** if `pyramid.md` lacks a `## Apex` header (e.g., a degraded MISMATCH render), fall back to reading `construction.md` and extracting the apex node directly. If neither is parseable, ask the user for the apex sentence directly before running the gate.

#### Phase 4: Draft

**For technical formats (tutorial, how-to, reference, explanation):** SKIPPED. Tech-doc's draft agent has already run during the dispatch in writing's Phase 2. Mark phase task completed and proceed to Phase 5.

**Narrative formats** (essay, blog, talk, newsletter):

1. Read `draft-prompt.md`
2. Inject: output path, style guide path, empty reviewer feedback
3. Dispatch via the host subagent tool
4. Verify `draft.md` exists
5. Mark task completed

**Analytical formats** (memo, briefing, announcement):

1. Read `draft-analytical-prompt.md`
2. Inject: output path, style guide path, empty reviewer feedback
3. Dispatch via the host subagent tool. The agent reads `pyramid.md`, `intake.md`, `throughline.md` (if present), and `audit-summary.md`.
4. Verify `draft.md` exists
5. Mark task completed

#### Phase 5: Panel review

**For technical formats (tutorial, how-to, reference, explanation):** SKIPPED. Tech-doc's Phase 5 has already run during the dispatch in writing's Phase 2. Mark phase task completed and proceed to Phase 6.

Fan out: dispatch all critic agents in parallel when supported. The critic set depends on format.

**Default panel (seven critics).** Used for `essay`, `blog`, `talk` formats.

| Prompt file | Output file | Lens |
|---|---|---|
| `critics/hemingway.md` | `critique-hemingway.md` | Economy: cut adjectives, kill darlings |
| `critics/hitchcock.md` | `critique-hitchcock.md` | Pacing: reader engagement, bomb under the table |
| `critics/mom-reader.md` | `critique-mom.md` | Accessibility: where the general reader gets lost |
| `critics/asshole-reader.md` | `critique-asshole.md` | Rigor: unearned claims, missing counterarguments |
| `critics/clarity.md` | `critique-clarity.md` | Precision: vague abstractions, unclear antecedents (Zinsser) |
| `critics/usage.md` | `critique-usage.md` | Correctness of form: grammar, parallelism, misused words (Strunk & White) |
| `critics/steel-man.md` | `critique-steelman.md` | Preemption: strongest opposing thesis and whether the draft engages it |

**Extended panel (eight critics).** Used for formats `memo`, `newsletter`, `announcement`. Adds one format-gated critic to the default seven:

| Prompt file | Output file | Lens |
|---|---|---|
| `critics/smart-brevity.md` | `critique-smartbrevity.md` | Scannable structure: muscular lead, one takeaway early, short sentences, no fluff (Axios method) |

For each critic in the active set:
1. Read the prompt file from the tables above
2. Inject: output path, style guide path, empty reviewer feedback
3. Dispatch via the host subagent tool
4. Verify the corresponding output file exists
5. Mark sub-task completed

When all active critics return, consolidate into `critique.md` (include Smart-Brevity rows only when it ran):

```markdown
# Panel Critique

## Verdicts

| Critic | Verdict | Headline |
|--------|---------|----------|
| Hemingway | <PASS / MINOR / CRITICAL> | <one-line summary> |
| Hitchcock | ... | ... |
| Mom reader | ... | ... |
| Asshole reader | ... | ... |
| Clarity | ... | ... |
| Usage | ... | ... |
| Steel-man | ... | ... |
| Smart-Brevity | ... | ... | (only when format gated it in)

## Hemingway
<full content of critique-hemingway.md>

## Hitchcock
<full content of critique-hitchcock.md>

## Mom reader
<full content of critique-mom.md>

## Asshole reader
<full content of critique-asshole.md>

## Clarity
<full content of critique-clarity.md>

## Usage
<full content of critique-usage.md>

## Steel-man
<full content of critique-steelman.md>

## Smart-Brevity
<full content of critique-smartbrevity.md, only when the Smart-Brevity critic ran>
```

Then check verdicts. **Match on the first whitespace-delimited token of each critic's `**Verdict:**` line.** Critic prompts emit `PASS`, `MINOR ISSUES`, or `CRITICAL ISSUES`; only the first token is the gate signal. Expected tokens: `PASS`, `MINOR`, `CRITICAL`.

- All active critics emit `PASS` or `MINOR` → continue to finishing
- One or more critics emit `CRITICAL` → re-dispatch the draft agent with the consolidated critique injected as REVIEWER_FEEDBACK. Re-run the panel. Repeat up to 2 iterations. If still CRITICAL after 2 iterations, present remaining critical issues to user via AskUserQuestion: "Continue to finishing, or pause for manual intervention?"

Mark phase task completed when verdict allows progression or user overrides.

#### Phase 6: Finishing

**For technical formats (tutorial, how-to, reference, explanation):** SKIPPED. Tech-doc's Phase 6 has already run during the dispatch in writing's Phase 2. Present the final artifacts to the user and proceed to Step 7.

Sequential, NOT parallel. Each pass updates the draft in place; later passes need the earlier passes' changes.

**Narrative formats** (essay, blog, talk, newsletter): run the four passes in this order:

1. `finishing/ai-pattern-detector.md`
2. `finishing/style-enforcer.md`
3. `finishing/line-editor.md`
4. `finishing/sedaris.md` (literary voice; reads `interview-synthesis.md` for tone calibration)

**Analytical formats** (memo, briefing, announcement): run the four passes in this order:

1. `finishing/ai-pattern-detector.md`
2. `finishing/style-enforcer.md`
3. `finishing/line-editor.md`
4. `finishing/analytical-voice.md` (executive voice; reads `intake.md` for audience calibration; replaces Sedaris because analytical formats do not run the interview phase that Sedaris depends on)

For each pass in order:
1. Read the prompt file
2. Inject: output path, style guide path, empty reviewer feedback
3. Dispatch via the host subagent tool
4. Verify the agent appended its log section to `finishing-notes.md`
5. Mark sub-task completed

After all four passes, present `draft.md` and `finishing-notes.md` to the user. The piece is now ready for the writer's manual voice pass per the user feedback memory (drafted prose is a skeleton, the writer rewrites in own voice).

### Step 7: Update state and present

Update the state file. The working directory is the *key* under `projects` (not a field). For that key, write:
- `active_style_guide`: absolute path
- `last_completed_phase`: name of last successful phase
- `last_run_at`: ISO timestamp

See the State File Format section below for the exact JSON shape.

Present the final draft and a summary of what each pass did.

## Edge Cases

- **Working dir does not exist**: create with `mkdir -p`
- **Style guide not found at any level**: fall back to default and warn "Using default style guide"
- **Phase artifact missing on resume**: re-run that phase
- **Agent dispatch fails**: retry once, then surface error and pause
- **Critic returns malformed output**: log, continue with the remaining critics, mark that sub-task as failed
- **User cancels mid-pipeline**: state file records the last completed phase; next invocation resumes
- **Critique gate fails twice**: present remaining critical issues, ask whether to proceed or intervene manually
- **Multiple style guide candidates** with no state record: ask once, record choice
- **Missing prerequisite artifact on phase jump (narrative)**: Outline reads `interview-synthesis.md`; Throughline reads `outline.md`; Sedaris reads `interview-synthesis.md`; Draft reads `outline.md` and `throughline.md` if present; Panel and Finishing read `draft.md`. If the user invokes `--phase X` on a directory missing the upstream artifact, ask via AskUserQuestion whether to (a) run the missing upstream phase first, (b) accept a degraded run where the agent works without that input (only safe for Sedaris reading the synthesis, or Draft reading a missing throughline), or (c) cancel and let the user produce the artifact manually
- **Missing prerequisite artifact on phase jump (analytical)**: pyramid Phase 2 reads `intake.md`; Throughline reads `pyramid.md` (or `construction.md` as fallback); Analytical Draft reads `pyramid.md`, `intake.md`, optionally `throughline.md` and `audit-summary.md`; Analytical voice pass reads `draft.md`, `intake.md`, `pyramid.md`, optionally `audit-summary.md`; Panel and Finishing read `draft.md`. Apply the same three options on phase-jump with missing upstream.
- **Throughline thesis or apex line missing**: if the source file does not contain the expected line (e.g., user hand-wrote an outline, or a degraded MISMATCH render produced a partial pyramid.md), ask the user for the throughline directly before running the gate rather than failing silently
- **Unknown format value**: if `--format` or the state file contains an unrecognised value, warn once, fall back to `essay`, and ask the user to confirm
- **Format mismatch on resume**: state file recorded format `essay` but the working directory contains `pyramid.md`, or recorded `memo` but contains `outline.md`. Ask via AskUserQuestion which format applies; record the corrected value.
- **Pyramid CRITICAL audit gate fails twice during dispatched run**: pyramid's standard handling applies (present remaining critical issues, ask whether to continue to opener with known issues, pause for manual intervention, or cancel). The writing skill does NOT add a second layer of gate handling on top.
- **Pyramid MISMATCH on opener**: pyramid's standard handling applies. If the user accepts the degraded opener (S and A only), the analytical draft prompt still works because it reads `pyramid.md` and the partial opener renders correctly.
- **Missing prerequisite artifact on phase jump (technical):** intake reads no upstream; outline reads `intake.md`; throughline reads `outline.md`/`schema.md`; draft reads `intake.md`, `outline.md`/`schema.md`, optionally `throughline.md`; panel reads `draft.md`; finishing reads `draft.md`. Apply the same three-option pattern (run upstream / accept degraded / cancel) on phase-jump with missing upstream.
- **Tech-doc panel CRITICAL gate fails twice during dispatched run:** tech-doc's standard handling applies (present remaining critical issues, ask whether to continue to finishing with known issues, pause, or cancel). Writing skill does NOT add a second gate handling layer.
- **Tech-doc quadrant-fit CRITICAL persistent:** tech-doc's standard handling applies (offer to switch quadrant). If the user chooses to switch, the working directory may need to be reset. Tech-doc owns this.
- **Format mismatch on resume (technical):** state file recorded format `tutorial` but working directory contains pyramid artifacts (e.g., `intake.md` with `genre: Memo`), or pyramid was the intended track but `intake.md` has `dispatched_from: writing` and a `quadrant:` field. Use the `dispatched_from` field and the presence of `quadrant:` (technical) vs. `genre:` (analytical) to disambiguate. Ask via AskUserQuestion which format applies; record the corrected value.

## State File Format

`<state-root>/<project-id>/writing-skill-state.json`:

```json
{
  "version": 1,
  "projects": {
    "<absolute-working-directory>": {
      "active_style_guide": "<absolute-path-or-default>",
      "format": "essay",
      "last_completed_phase": "draft",
      "last_run_at": "2026-04-16T12:00:00Z"
    }
  }
}
```

Recognised format values: `essay`, `blog`, `talk`, `newsletter`, `memo`, `announcement`, `briefing`, `tutorial`, `how-to`, `reference`, `explanation`. Defaults to `essay` if absent. The format drives panel composition (Smart-Brevity critic added for `memo`, `newsletter`, `announcement`) and pipeline routing. For analytical formats (`memo`, `briefing`, `announcement`), the writing skill dispatches Phases 1 and 2 to the pyramid skill. For technical formats (`tutorial`, `how-to`, `reference`, `explanation`), the writing skill dispatches Phases 1 and 2 to the tech-doc skill, which owns Phases 5 and 6 (panel and finishing) as part of its dispatched pipeline; writing's Phases 5 and 6 are skipped.

The state file is keyed by working directory so multiple in-flight pieces in the same project can each have their own state.

## Phase Identifier Names

Used in `--phase` flag and task list:
`interview`, `outline`, `throughline`, `draft`, `panel`, `finishing`

## Behavioral Guidelines

- Trigger on writing intent (drafting, reviewing, polishing, voice work), not on simple text generation
- When in doubt about scope: "Would you like the full pipeline, or are you starting from a specific phase?"
- Always announce the active style guide in the first response
- Always create the task list before dispatching the first phase agent so the user sees what is coming
- Never present a finished draft as if it is the final voice; remind the user the writer's manual voice pass is the next step
- Critics return verdicts; the orchestrator decides whether to gate or proceed
