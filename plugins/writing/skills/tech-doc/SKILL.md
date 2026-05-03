---
name: tech-doc
description: Use when the user wants to draft, review, or finish technical documentation: tutorials, how-to guides, API references, CLI references, configuration references, error code references, REST endpoint references, or conceptual explanations. Diátaxis-aware (four quadrants: tutorial, how-to, reference, explanation), each with its own draft prompt and critic panel composition. Enforces curated full transcriptions of the Microsoft Writing Style Guide and the Google Developer Documentation Style Guide via selectable presets (google, microsoft, or merged house default), each preset structured as a directory of eight topic-scoped sidecars (core, wordlist, procedures, admonitions, code-samples, links, numbers, api-reference). Six-phase pipeline (intake, outline, throughline, draft, panel, finishing) with eight-critic panel per quadrant and three sequential finishing passes (AI-pattern-detector, style-enforcer-tech, terminology-consistency). Triggers on technical-writing intent, not general prose.
---

# Tech-doc Skill

Diátaxis-aware technical writing pipeline. Standalone, AND dispatched from the writing skill when the format is tutorial, how-to, reference, or explanation.

---

## Tool Preference

1. **Subagent dispatch when available and permitted:** to dispatch phase agents (intake per quadrant, draft per quadrant, panel critics, finishing passes). Throughline gate runs in the orchestrator.
2. **File read tools:** to load prompt templates, schema files, style presets, existing artifacts.
3. **Shell:** for directory creation, file existence checks, state file read/write.
4. **Progress list:** to surface progress through the pipeline.
5. **File write and edit tools:** for state file management and orchestrator-level artifact updates.
6. **User question tool or direct question:** for quadrant routing, throughline gate, panel re-dispatch overrides.

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

1. **Explicit flag:** `--dir ./path/to/project/`
2. **Existing artifacts in cwd:** if the cwd already contains any of `intake.md`, `outline.md`, `schema.md`, `throughline.md`, `draft.md`, `critique.md`, `finishing-notes.md`, treat the cwd as the working directory.
3. **State file lookup:** read `<state-root>/<project-id>/tech-doc-skill-state.json`. If an in-flight piece is recorded, offer to resume there.
4. **Default:** prompt for a slug, create `tech-doc/{slug}-{YYYY-MM-DD}/` in cwd.

### Step 2: Resolve the active style preset directory

Resolution order:

1. **Explicit flag:** `--style-preset google|microsoft|house`
2. **State memory:** the state file's recorded preset for this project.
3. **Skill default:** `house`.

Resolve to absolute path: `<skill-install-path>/style-presets/<preset>/`. Locate the skill install path by `Glob`-ing for `**/tech-doc/SKILL.md` under the active plugin directory and taking the parent. Validate: directory exists AND `core.md` inside the directory exists. If either is missing, fall back to `house`, warn once.

Surface in the first response: "Using style preset directory: {path}".

### Step 3: Determine quadrant

Resolution order:

1. **Explicit flag:** `--quadrant tutorial|how-to|reference|explanation`. Confirmation question is still asked, mirroring pyramid's `--mode` handling.
2. **State memory:** recorded quadrant for this project.
3. **Always-asked AskUserQuestion** if neither.

Surface in the first response: "Quadrant: {quadrant}. Style preset directory: {path}".

### Step 4: Determine starting phase

Scan the working directory for artifacts:

- `intake.md` exists → intake complete
- `outline.md` exists (tutorial/how-to/explanation) OR `schema.md` exists (reference) → outline complete
- `throughline.md` exists → throughline gate passed
- `draft.md` exists → draft complete
- `critique.md` exists → panel complete
- `finishing-notes.md` exists → finishing has started or completed
- `glossary.md` exists → terminology-consistency pass has run

Determine the latest completed phase. Present: "I see you have completed phases X. Resume from {next phase}?". Offer phase-jump.

User can pre-empt with `--phase X` (X is one of `intake`, `outline`, `throughline`, `draft`, `panel`, `finishing`).

### Step 5: Create task list

Use the progress list. Use this shape (varies by quadrant only in Phase 5 sub-task):

```
1. Phase 1: Intake (quadrant-specific)
2. Phase 2: Outline (or schema-fill for reference)
3. Phase 3: Throughline gate (≤10-word for tutorial/how-to/explanation; schema-completeness for reference)
4. Phase 4: Draft
5. Phase 5: Panel review
   ├── Critic: style-adherence
   ├── Critic: accessibility
   ├── Critic: inclusive-language
   ├── Critic: code-fidelity
   ├── Critic: future-features
   ├── Critic: quadrant-fit
   ├── Critic: admonitions
   └── Critic: <task-orientation | completeness | steel-man>  (gated by quadrant)
6. Phase 6: Finishing
   ├── AI-pattern detector
   ├── Style-enforcer-tech
   └── Terminology-consistency
```

For phase-selectable runs, only the requested phases get tasks. Mark each `in_progress` when starting, `completed` when artifact verified.

### Step 6: Execute phases

Dispatch each phase agent via the host subagent tool when supported. The orchestrator injects context into the prompt template.

#### Dispatch conventions

- `{OUTPUT_PATH}` is always the working directory, never a file path. Each prompt file appends its own filename.
- **Prompt file extraction.** Each prompt file documents the dispatched prompt inside a fenced block under the `**Dispatch:**` header. Read the entire prompt file as text, perform placeholder substitution (`{OUTPUT_PATH}`, `{STYLE_GUIDE_DIR}`, `{REVIEWER_FEEDBACK}`, `{YYYY-MM-DD}`, `{QUADRANT}`, `{LANGUAGE_OR_PLATFORM}`, `{AUDIENCE_SKILL_LEVEL}`), pass the full result to the host subagent tool.
- **Reviewer feedback injection.** When `{REVIEWER_FEEDBACK}` is non-empty (re-dispatch on a failed gate), append: *"Reviewer feedback is provided above. Read the existing artifact in the output directory, address the specific concerns, and update the file in place rather than starting fresh."*
- **Date substitution.** `{YYYY-MM-DD}` resolves to today's date in ISO format.

#### Phase 1: Intake

Dispatch per quadrant:

- `tutorial` → `intake-tutorial-prompt.md`
- `how-to` → `intake-how-to-prompt.md`
- `reference` → `intake-reference-prompt.md`
- `explanation` → `intake-explanation-prompt.md`

Verify `intake.md` exists. Mark task completed.

#### Phase 2: Outline

For tutorial/how-to/explanation: ask the writer to confirm a section skeleton, then write `{OUTPUT_PATH}/outline.md` using the template in Behavioral Guidelines below.

For reference: read `intake.md` for the declared schema type, copy the schema's required-fields skeleton from `reference-schemas/<type>.md` to `{OUTPUT_PATH}/schema.md`, and present to the user for confirmation.

Verify `outline.md` (tutorial/how-to/explanation) or `schema.md` (reference) exists. Mark task completed.

#### Phase 3: Throughline gate

Orchestrator-only synchronous gate. No Agent dispatch.

For tutorial/how-to/explanation: ten-word compression gate. Phrasing per quadrant (see Behavioral Guidelines). Validate by splitting on whitespace and ignoring empty strings; ≤10 tokens passes. On failure, offer "RETURN TO OUTLINE" escape hatch to resume Phase 2 with the attempted throughline as reviewer feedback.

For reference: schema-completeness check. Read `schema.md`. If any required field is `<unknown>`, ask via AskUserQuestion: "Backfill the missing fields, or accept partial-reference disclosure (a 'Reference incomplete' note prepended to draft.md)?" Record gate result in `throughline.md`.

Write `{OUTPUT_PATH}/throughline.md`:

- Tutorial/how-to/explanation: single line, the accepted ≤10-word throughline.
- Reference: gate result string (`schema-complete` or `schema-partial-disclosure-accepted`).

Mark task completed.

#### Phase 4: Draft

Dispatch per quadrant:

- `tutorial` → `draft-tutorial-prompt.md`
- `how-to` → `draft-how-to-prompt.md`
- `reference` → `draft-reference-prompt.md`
- `explanation` → `draft-explanation-prompt.md`

Verify `draft.md` exists. Mark task completed.

#### Phase 5: Panel review

Fan out: dispatch all critics in the active panel in parallel (single message with multiple Agent calls). Active panel by quadrant:

- **Tutorial:** style-adherence, accessibility, inclusive-language, code-fidelity, future-features, quadrant-fit, admonitions, task-orientation. (8)
- **How-to:** style-adherence, accessibility, inclusive-language, code-fidelity, future-features, quadrant-fit, admonitions, task-orientation. (8)
- **Reference:** style-adherence, accessibility, inclusive-language, code-fidelity, future-features, quadrant-fit, admonitions, completeness. (8)
- **Explanation:** style-adherence, accessibility, inclusive-language, code-fidelity, future-features, quadrant-fit, admonitions, steel-man. (8)

Each critic writes its own `critique-<critic>.md`. When all critics return, consolidate into `{OUTPUT_PATH}/critique.md`:

````markdown
# Panel Critique

## Verdicts

| Critic | Verdict | Headline |
|--------|---------|----------|
| Style-adherence | <PASS / MINOR / CRITICAL> | <one-line summary> |
| Accessibility | ... | ... |
| Inclusive-language | ... | ... |
| Code-fidelity | ... | ... |
| Future-features | ... | ... |
| Quadrant-fit | ... | ... |
| Admonitions | ... | ... |
| <Task-orientation / Completeness / Steel-man> | ... | ... |  (gated critic)

## Style-adherence
<full content of critique-style-adherence.md>

## Accessibility
<full content of critique-accessibility.md>

## Inclusive-language
<full content of critique-inclusive-language.md>

## Code-fidelity
<full content of critique-code-fidelity.md>

## Future-features
<full content of critique-future-features.md>

## Quadrant-fit
<full content of critique-quadrant-fit.md>

## Admonitions
<full content of critique-admonitions.md>

## <Gated critic name>
<full content of the gated critique file>
````

Match on first whitespace-delimited token of each critic's `**Verdict:**` line. Tokens: PASS, MINOR, CRITICAL.

- All PASS or MINOR → continue to finishing.
- One or more CRITICAL → re-dispatch the draft agent with consolidated `critique.md` injected as `{REVIEWER_FEEDBACK}`. Re-run the panel. Repeat up to 2 iterations. If still CRITICAL after 2, AskUserQuestion: "Continue to finishing or pause for manual intervention?"

Mark phase task completed when verdict allows progression or user overrides.

#### Phase 6: Finishing

Sequential, NOT parallel. Each pass updates the draft in place; later passes need the earlier passes' changes. Three passes in this order:

1. `finishing/ai-pattern-detector.md`
2. `finishing/style-enforcer-tech.md`
3. `finishing/terminology-consistency.md`

For each pass: read prompt file, inject `{OUTPUT_PATH}`, `{STYLE_GUIDE_DIR}`, and `{REVIEWER_FEEDBACK}` (always empty for finishing passes), dispatch via the host subagent tool, verify the agent appended its log section to `finishing-notes.md`, mark sub-task completed.

After all three, present `draft.md`, `glossary.md`, and `finishing-notes.md` to the user. The piece is now ready for the writer's review.

### Step 7: Update state and present

Update state file. Working directory is the key under `projects`. Fields:

- `quadrant`
- `style_preset`
- `audience_skill_level`
- `language_or_platform`
- `glossary_path` (absolute path to glossary.md)
- `last_completed_phase`
- `last_run_at` (ISO timestamp)

Present final draft and a summary of what each pass did.

## Edge Cases

- **Working dir does not exist:** create with `mkdir -p`.
- **Style preset not found:** fall back to `house`, warn once.
- **Wrong quadrant chosen, quadrant-fit critic returns CRITICAL twice:** AskUserQuestion offering to switch quadrant. Orchestrator can move artifacts to a sibling working dir under a new slug, or accept the quadrant mismatch.
- **Missing prerequisite artifact on phase jump:** AskUserQuestion to (a) run upstream, (b) accept degraded run, (c) cancel.
- **Reference schema doesn't exist:** offer fall-back to closest schema (`function.md`) with one-line warning, or author free-form (no completeness critic gate).
- **Code-fidelity critic over-flags pseudocode:** allow `<!-- pseudocode -->` HTML comment in snippet to suppress.
- **Tutorial without prerequisites declared:** ask once; if writer insists none, accept.
- **Reference draft produces `<unknown>` fields:** surface at throughline gate; backfill or partial-reference disclosure.
- **Future-features critic false positive:** descriptive future tense for runtime is fine; the critic prompt distinguishes.
- **Glossary input file unreadable:** warn, proceed with within-document terminology.
- **State file format mismatch on resume:** warn once, treat as fresh, ask user to confirm.
- **Mid-pipeline switch from writing-skill dispatch to direct invocation:** working directory and state file are compatible.

## State File Format

`<state-root>/<project-id>/tech-doc-skill-state.json`:

v1 state files (`"version": 1`) are forward-compatible: the `style_preset` field records a preset name (`google` / `microsoft` / `house`), not a path, so the orchestrator's resolution change (file to directory) does not break existing state files. New runs bump the version field to `2`.

```json
{
  "version": 2,
  "projects": {
    "<absolute-working-directory>": {
      "quadrant": "tutorial",
      "style_preset": "house",
      "audience_skill_level": "beginner",
      "language_or_platform": "Python",
      "glossary_path": "<absolute-path-or-null>",
      "last_completed_phase": "draft",
      "last_run_at": "2026-04-28T12:00:00Z"
    }
  }
}
```

Recognized values:

- `quadrant`: `tutorial`, `how-to`, `reference`, `explanation`.
- `style_preset`: `google`, `microsoft`, `house`. Default `house`.
- `audience_skill_level`: `beginner`, `intermediate`, `advanced`. Defaults: tutorial → `beginner`, how-to → `intermediate`, reference → `advanced`, explanation → `intermediate`.

Keyed by working directory.

## Style preset structure

Each preset is a directory under `style-presets/` containing eight topic-scoped sidecar files plus `SOURCES.md`:

```
style-presets/<preset>/
  core.md              # voice, tone, person, tense, capitalization, punctuation, global-audience principles
  wordlist.md          # full word list, ~400 to 600 entries, four-column table grouped by category
  procedures.md        # step format, prerequisites, conditions, optional-step prefix, expected outputs
  admonitions.md       # severity tiers (Note, Tip, Important, Caution, Warning), usage rules, format
  code-samples.md      # placeholders, line length, output formatting, omission indicators, code-in-prose
  links.md             # link text rules, see-also placement, cross-references, anchors
  numbers.md           # numerals, units, dates, time, currency, ranges
  api-reference.md     # parameter naming, type notation, status codes, response shape, deprecation
  SOURCES.md           # source URLs, license, last-refreshed dates; for house, the merge policy
```

The orchestrator resolves the active preset directory once (per Step 2) and substitutes the absolute path as `{STYLE_GUIDE_DIR}` in every dispatched critic, draft, and finishing prompt. Each prompt then reads only the sidecars it needs from `{STYLE_GUIDE_DIR}/<sidecar>.md`.

### Critic-to-sidecar wiring matrix

The orchestrator does not enforce this. Each critic prompt declares its own loads from `{STYLE_GUIDE_DIR}`. This table is the human-readable reference.

| Critic / Pass | Quadrants | Sidecars (besides `core.md`) |
|---|---|---|
| `style-adherence` | all | wordlist, procedures, code-samples, links, numbers, admonitions |
| `accessibility` | all | links, code-samples |
| `inclusive-language` | all | wordlist (filtered: section in inclusive/ableist/gendered/bias-free/culturally-narrow) |
| `code-fidelity` | all | code-samples |
| `future-features` | all | (none extra) |
| `quadrant-fit` | all | (none extra) |
| `task-orientation` | tutorial, how-to | procedures |
| `completeness` | reference | procedures, api-reference |
| `steel-man` | explanation | (none extra) |
| `admonitions` | all | admonitions |
| `ai-pattern-detector` (finishing) | all | (no preset reads) |
| `style-enforcer-tech` (finishing) | all | wordlist (filtered: mechanical=yes), procedures |
| `terminology-consistency` (finishing) | all | (no preset reads) |

All sidecar paths in the matrix are relative to `{STYLE_GUIDE_DIR}`. For example, style-adherence reads `{STYLE_GUIDE_DIR}/wordlist.md`, `{STYLE_GUIDE_DIR}/procedures.md`, and so on.

### Wordlist file format

Each `wordlist.md` is a markdown file with a Categories list at the top declaring the fourteen canonical categories, followed by one section per category. Each category section is a four-column table:

`| Term | Replacement | Mechanical | Notes |`

- `Term`: the word or phrase to flag.
- `Replacement`: the suggested alternative, or `(drop)` for words to remove.
- `Mechanical`: `yes` if literal substitution leaves a grammatical sentence in 99% of cases (style-enforcer-tech applies during finishing); `no` otherwise (style-adherence flags only).
- `Notes`: a paraphrased one-sentence explanation; preserves source guidance.

The fourteen canonical categories: `clarity`, `hedge-words`, `action-verbs`, `mouse-keyboard`, `login`, `web-internet`, `error-messages`, `direction`, `numbers-dates`, `inclusive`, `ableist`, `gendered`, `culturally-narrow`, `technical-jargon`.

### Refresh process

Quarterly cadence:
1. Update `<preset>/SOURCES.md` last-refreshed date.
2. Update the relevant sidecar files for that preset directly (paraphrase Microsoft, transcribe Google).
3. Re-merge house: walk topic-by-topic, dedupe wordlists, apply merge policy, document deviations inline.
4. Update `house/SOURCES.md` last-merged date.

## Phase Identifier Names

Used in `--phase` flag and task list:
`intake`, `outline`, `throughline`, `draft`, `panel`, `finishing`.

## Behavioral Guidelines

- Trigger on technical-writing intent (tutorials, how-to guides, references, explanations), not on general prose.
- Always confirm the quadrant in the first response, even if `--quadrant` was passed.
- Always announce the active style preset.
- Always create the task list before dispatching the first phase agent.
- Never present a finished draft as final; tech docs benefit from the writer's manual review of the panel feedback and glossary.
- Critics return verdicts; the orchestrator decides whether to gate or proceed.
- Each critic loads only the sidecars it declares in its own prompt. The wiring matrix in the "Style preset structure" section above is the human-readable reference; the source of truth is the critic prompts themselves.

### Throughline gate phrasing per quadrant

- **Tutorial:** "What will the reader be able to do after finishing this tutorial?" (≤10 words.)
- **How-to:** "What task does this guide accomplish?" (≤10 words.)
- **Reference:** schema-completeness check (not compression).
- **Explanation:** "What is the one thing you want the reader to take away?" (≤10 words.)

### Outline template (tutorial / how-to / explanation)

The Phase 2 outline for these three quadrants is a brief orchestrator-driven step. Format `{OUTPUT_PATH}/outline.md`:

```markdown
# Outline

**Quadrant:** <quadrant>

## Section skeleton
1. <section heading>
2. <section heading>
...

## Notes
<one-paragraph rationale, optional>
```

Ask the writer to confirm or revise the skeleton. On revisions, regenerate.
