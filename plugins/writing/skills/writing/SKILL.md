---
name: writing
description: Use when the user wants to draft a blog post, essay, talk, newsletter, memo, announcement, briefing, literature note, or any longer-form prose; or when they want to review, critique, or finish an existing draft. Orchestrates a multi-phase pipeline (interview, outline, throughline gate, draft, panel review, finishing) modeled on Katie Parrott's process. For analytical formats (memo, briefing, announcement), the outline phase dispatches to the pyramid skill for Minto-style structural construction (intake, construct, audit, opener, render) and the draft phase uses an analytical draft prompt. The format-gated Smart-Brevity panel critic runs for memo, newsletter, and announcement pieces. Triggers on writing intent (drafting, reviewing, polishing, voice work) and not on simple text generation tasks.
---

# Writing Skill

Multi-phase writing pipeline with a panel of specialised critics. Modeled on Katie Parrott's process and the existing research plugin's orchestrator pattern.

---

## Tool Preference

1. **Agent tool**: to dispatch phase agents (interview, outline, draft) and critics (Hemingway, Hitchcock, Mom reader, Asshole reader, Clarity, Usage, Steel-man, plus Smart-Brevity for memo/newsletter/announcement formats) and finishing passes (AI-pattern detector, style enforcer, line editor, Sedaris). The throughline gate runs in the orchestrator and does not dispatch an agent.
2. **Read**: to load prompt templates and existing artifacts
3. **Bash**: for directory creation, file existence checks, state file read/write
4. **TaskCreate / TaskUpdate**: to surface progress through the pipeline visibly
5. **Write / Edit**: for state file management and orchestrator-level artifact updates
6. **AskUserQuestion**: for outline negotiation and resolution choices

## Workflow

### Step 1: Determine the topic and the working directory

Ask the user what they want to write about (or what existing piece they want to work on).

Resolve working directory in this order:
1. **Explicit flag**: `--dir ./path/to/project/`
2. **Existing artifacts in cwd**: if the cwd already contains any of `interview.md`, `outline.md`, `draft.md`, `critique.md`, treat the cwd as the working directory
3. **State file lookup**: read `~/.claude/projects/<project-id>/writing-skill-state.json` (where `<project-id>` is the cwd path with slashes replaced by hyphens, leading hyphen). If a working directory is recorded for an in-flight piece, offer to resume there.
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

Resolution order:
1. Explicit flag: `--format <format>`
2. State memory: the state file's recorded format for this project
3. Default silently to `essay` and surface the default in the first response with an inline change hint: "Format: essay (default). Pass `--format memo|briefing|announcement|newsletter|blog|talk` to change."

Ask via AskUserQuestion only when the working directory name or the interview synthesis strongly signals a different format than the recorded state (for example, a state-stored `essay` format but the working directory is `memos/q3-roadmap-2026-04-23/`). In ambiguous cases, surface both candidates and let the user pick. Otherwise, resolve silently.

Format gates:
- **Pyramid pipeline:** analytical formats (`memo`, `briefing`, `announcement`) skip writing's interview and outline phases entirely. Phase 1 dispatches the pyramid skill's intake; Phase 2 dispatches pyramid's construct, audit, opener, and render phases. The pyramid pipeline produces `pyramid.md`, which is then consumed by writing's throughline (Phase 3) and analytical draft (Phase 4) phases.
- **Smart-Brevity critic:** formats `memo`, `newsletter`, `announcement` add the Smart-Brevity critic to the panel fan-out. Other formats run the default seven-critic panel. Note: `briefing` does NOT add Smart-Brevity, because briefings are dense by construction and the Smart-Brevity lens has lower signal there.

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
- pyramid.md exists → pyramid render (Phase 2) complete; outline equivalent ready for throughline
- `throughline.md` exists → throughline phase complete
- `draft.md` exists → draft phase complete
- `critique.md` exists → panel phase complete
- `finishing-notes.md` exists → finishing phase has started or completed

Determine the latest completed phase. Present to user:
- "I see you have completed phases X. Resume from {next phase}?"
- Offer phase-jump option: user can name any phase to jump to

User can also pre-empt the dialogue by passing `--phase X` (X ∈ {interview, outline, throughline, draft, panel, finishing}).

### Step 5: Create task list

Use TaskCreate to add one task per phase that will run, plus sub-tasks for the panel and finishing phases. Example for a fresh full pipeline:

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
   └── Critic: Smart-Brevity (only for memo/newsletter/announcement)
6. Phase 6: Finishing pass
   ├── AI-pattern detector
   ├── Style enforcer
   ├── Line editor
   └── Sedaris
```

For phase-selectable runs, only the requested phases get tasks.

Mark each task as `in_progress` when starting, `completed` when the artifact is verified.

### Step 6: Execute phases

Dispatch each phase agent via the Agent tool. The orchestrator injects context into the prompt template.

#### Dispatch conventions (apply to every phase)

- **`{OUTPUT_PATH}` is always the working directory**, never a file path. Each prompt file appends its own filename.
- **Prompt file extraction.** Each prompt file documents the dispatched prompt inside a fenced block under the `**Dispatch:**` header. The dispatched body itself contains nested fences for example outputs. The simplest robust approach: read the entire prompt file as text, perform placeholder substitution (`{TOPIC}`, `{OUTPUT_PATH}`, `{STYLE_GUIDE_PATH}`, `{REVIEWER_FEEDBACK}`, `{YYYY-MM-DD}`), and pass the full result to the Agent tool. The dispatched agent ignores the surrounding commentary because the actionable instructions sit inside the visible prompt body.
- **Reviewer feedback injection.** When `{REVIEWER_FEEDBACK}` is non-empty (re-dispatch on a failed gate), append this standing instruction to the dispatched prompt, regardless of what the prompt template itself says: *"Reviewer feedback is provided above. Read the existing artifact in the output directory, address the specific concerns, and update the file in place rather than starting fresh."* This compensates for the asymmetric treatment of feedback across the prompt files.
- **Date substitution.** `{YYYY-MM-DD}` resolves to today's date in ISO format.

#### Phase 1: Interview

1. Read `interview-prompt.md` from this skill directory
2. Inject: topic, output path, style guide path, empty reviewer feedback
3. Dispatch via Agent tool. The agent will conduct an interactive interview with the user.
4. Verify `interview.md` and `interview-synthesis.md` exist
5. Mark task completed

#### Phase 2: Outline

1. Read `outline-prompt.md`
2. Inject: output path, style guide path, empty reviewer feedback
3. Dispatch via Agent tool
4. Verify `outline.md` exists
5. Surface the outline to the user. Accept revisions via AskUserQuestion ("Outline as proposed, or revisions before draft?"). On revisions, re-dispatch with feedback injected.
6. Mark task completed when user accepts

#### Phase 3: Throughline

Orchestrator-only synchronous gate. No agent dispatch. Happens after the outline is accepted, before the draft agent is dispatched. If the writer cannot compress the piece into ten words, the piece is not ready to draft.

1. Read `{OUTPUT_PATH}/outline.md` and extract the `**Thesis (one sentence):**` line.
2. Surface the thesis to the user via AskUserQuestion: "Throughline check. Compress the piece to ≤10 words. Current outline thesis: \"{thesis}\". What is the one thing you most want the reader to take away?"
3. Validate word count on the user's response by splitting on whitespace and ignoring empty strings. If more than 10 words, re-ask via AskUserQuestion: "That is N words. Cut it to 10 or fewer. If you cannot, the outline may be wrong. Return to Phase 2."
4. Offer an explicit escape hatch: the user may answer the re-ask with "RETURN TO OUTLINE" to resume Phase 2 with their attempted throughline as reviewer feedback injected into the outline prompt.
5. On acceptance, write `{OUTPUT_PATH}/throughline.md` as a single-line file containing only the accepted throughline (no markdown headers, no decoration).
6. Mark task completed.

#### Phase 4: Draft

1. Read `draft-prompt.md`
2. Inject: output path, style guide path, empty reviewer feedback
3. Dispatch via Agent tool
4. Verify `draft.md` exists
5. Mark task completed

#### Phase 5: Panel review

Fan out: dispatch all critic agents in parallel (single message with multiple Agent tool calls). The critic set depends on format.

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
3. Dispatch via Agent tool
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

Sequential, NOT parallel. Each pass updates the draft in place; later passes need the earlier passes' changes.

For each pass in order [ai-pattern-detector, style-enforcer, line-editor, sedaris]:
1. Read `finishing/{pass}.md`
2. Inject: output path, style guide path, empty reviewer feedback
3. Dispatch via Agent tool
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
- **Missing prerequisite artifact on phase jump**: some phases depend on artifacts produced by earlier phases (Outline reads `interview-synthesis.md`; Throughline reads `outline.md`; Sedaris reads `interview-synthesis.md`; Draft reads `outline.md` and `throughline.md` if present; Panel and Finishing read `draft.md`). If the user invokes `--phase X` on a directory missing the upstream artifact, ask via AskUserQuestion whether to (a) run the missing upstream phase first, (b) accept a degraded run where the agent works without that input (only safe for Sedaris reading the synthesis, or Draft reading a missing throughline), or (c) cancel and let the user produce the artifact manually
- **Throughline thesis line missing**: if the outline does not contain a `**Thesis (one sentence):**` line (e.g., user hand-wrote an outline), ask the user for the thesis directly before running the throughline gate rather than failing silently
- **Unknown format value**: if `--format` or the state file contains an unrecognised value, warn once, fall back to `essay`, and ask the user to confirm

## State File Format

`~/.claude/projects/<project-id>/writing-skill-state.json`:

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

Recognised format values: `essay`, `blog`, `talk`, `newsletter`, `memo`, `announcement`, `briefing`. Defaults to `essay` if absent. The format drives panel composition (Smart-Brevity critic added for `memo`, `newsletter`, `announcement`). A future change (issue #11) will add pyramid-structured outlines via a dedicated skill that the writing skill dispatches to.

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
