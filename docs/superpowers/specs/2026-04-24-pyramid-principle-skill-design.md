# Pyramid Principle Skill v1 Design

*Date: 2026-04-24*

## Problem

The writing skill already handles longform prose (essays, blogs, talks, newsletters) and format-gated memo/announcement/briefing critiques (Smart-Brevity). What it does not handle is the structural logic that memos and analytical documents live or die by: Barbara Minto's pyramid principle.

PR #10 tried to solve this inline with a thin `outline-pyramid-prompt.md` for format ∈ {memo, announcement, briefing}. That prompt covered SCQA framing and a 3-to-5 MECE supporting-argument list, which is only the facade. The real method carries: MECE testing against live material, so-what/therefore logic chains, the top-down question-answer dialogue method, vertical-vs-horizontal (inductive-vs-deductive) classification, grouping-size discipline, and a step-by-step procedure for reverse-engineering a pyramid from an existing draft. None of that fits inside one outline prompt without bloating it past usefulness.

Commit ff9e237 stripped the inline stopgap. Issue [#11](https://github.com/pgoell/pgoell-claude-tools/issues/11) tracks the follow-up: extract pyramid principle into its own first-class skill that the writing skill will eventually dispatch to.

The operational knowledge that drives this design is captured in [`2026-04-24-pyramid-principle-research.md`](./2026-04-24-pyramid-principle-research.md), the research report produced as input to this spec. The design cites that report by section number throughout.

## Design Goal

A dedicated `pyramid` skill that helps a writer either:

- **Mode A (greenfield):** produce a pyramid-structured outline from a topic, by running Minto's top-down question-answer dialogue procedure with audit gates.
- **Mode B (restructure):** diagnose and restructure an existing draft into a pyramid, by running the reverse-engineering procedure with the same audit gates.

The skill is standalone and usable directly by a human. It is designed to be dispatched from the writing skill's Phase 2 outline step in a later PR, but that integration is out of scope here and tracked as a follow-up issue.

A third mode (interactive Socratic dialogue that walks the user through pyramid construction question-by-question, Minto's "question-answer dialogue" applied as a conversation rather than a prompt) is explicitly deferred and tracked as a separate follow-up issue.

## Approach: Orchestrator with Parallel Audit Panel

One skill at `plugins/writing/skills/pyramid/`. The orchestrator runs five phases, hybrid sequential + parallel audit fan-out:

| Phase | Name | Dispatch | Role |
|-------|------|----------|------|
| 1 | `intake` | orchestrator-only, interactive | Domain-limits gate, mode choice (A/B), topic or draft, working dir and state |
| 2 | `construct` | 1 Agent (branched by mode) | Build the pyramid: Q-A dialogue (A) or reverse-engineering (B) |
| 3 | `audit` | 4 Agents in parallel | MECE / So-What / Q-A alignment / Inductive-or-Deductive audits |
| 4 | `opener` | 1 Agent | SCQA opener, written last against a stable apex |
| 5 | `render` | orchestrator-only | Assemble final `pyramid.md` |

This mirrors the writing skill's orchestrator pattern: parallel fan-out for audit critics (equivalent to writing's panel), sequential phases with gates elsewhere, state file for resume. The audit panel uses the same verdict token semantics (PASS / MINOR / CRITICAL on the first whitespace-delimited token of the `**Verdict:**` line) and the same re-dispatch loop (CRITICAL triggers re-dispatch of `construct` with consolidated audit feedback injected, max 2 iterations, then user gate).

The skill lives in the `writing` plugin rather than a new plugin. Rationale: pyramid is part of the writing product family; installing the writing plugin should give the user both skills; the writing skill will dispatch to pyramid in a future PR; the "one plugin per product family" convention already covers this (Gmail + Calendar under `google-workspace`, Jira + Confluence under `atlassian`).

## File Layout

```
plugins/writing/
├── .claude-plugin/
│   └── plugin.json                          # description and keywords updated for pyramid
├── README.md                                # new section added for pyramid skill
└── skills/
    ├── writing/                             # existing, unchanged
    │   └── ...
    └── pyramid/                             # new
        ├── SKILL.md                         # orchestrator
        ├── pyramid-principle-reference.md   # condensed audit-question reference shipped with the skill
        ├── construct-greenfield-prompt.md   # Mode A
        ├── construct-restructure-prompt.md  # Mode B
        ├── opener-prompt.md                 # SCQA opener
        └── audits/
            ├── mece.md                      # Four MECE Audit Questions
            ├── so-what.md                   # So-What / Why chain
            ├── qa-alignment.md              # Q-A Alignment Audit
            └── inductive-deductive.md       # Inductive-or-Deductive Audit
```

Marketplace registration: no new entry. The existing `writing` plugin entry in `.claude-plugin/marketplace.json` bumps to version `1.3.0` and its description extends to mention the pyramid skill. The plugin `plugin.json` adds pyramid-related keywords (`pyramid`, `minto`, `mece`, `scqa`, `memo`).

## Pipeline Flow

```
/pyramid (or /pyramid --phase X --dir Y, where X ∈ {intake, construct, audit, opener, render})
  ↓
[Working directory resolution]  (flag → state memory → slug fallback)
  ↓
[Reference resolution]  (flag → state memory → skill default)
  ↓
[State scan]  (detect existing artifacts in working dir)
  ↓
[Task list created]  (one entry per phase + sub-tasks per auditor)
  ↓
[Phase 1: Intake (orchestrator)]
  → interactive: domain-limits check, mode choice (A or B), topic/draft, audience, reader question
  writes: intake.md
  ↓
[Phase 2: Construct Agent]
  Mode A reads: construct-greenfield-prompt.md  → runs Q-A Dialogue Procedure
  Mode B reads: construct-restructure-prompt.md → runs Reverse-Engineering Procedure (steps 1-7)
  writes: construction.md (+ restructure-notes.md if Mode B)
  ↓
[Phase 3: Audit Panel (4 agents in parallel)]
  mece.md, so-what.md, qa-alignment.md, inductive-deductive.md
  writes: audit-mece.md, audit-so-what.md, audit-qa.md, audit-logic.md
  consolidates to: audit-summary.md
  → if any CRITICAL: re-dispatch construct with audit-summary injected, up to 2 iterations
  ↓
[Phase 4: Opener Agent]
  reads: construct-greenfield/restructure output, audit-summary (for any late MINOR fixes), reference
  writes: opener.md (SCQA fields + rendered opener paragraph)
  ↓
[Phase 5: Render (orchestrator)]
  assembles: opener.md + construction.md → pyramid.md (final artifact)
  appends: Audit notes block listing MINOR flags the user should know about
  ↓
[Present pyramid.md and audit-summary.md to user]
```

## Phase Details

### Phase 1: Intake

Orchestrator-only, interactive. No Agent dispatch.

**Working directory resolution** (in order):
1. Explicit flag: `--dir ./path/to/project/`
2. Existing artifacts in cwd (`intake.md`, `construction.md`, `pyramid.md`): treat cwd as working dir.
3. State file lookup: `~/.claude/projects/<project-id>/pyramid-skill-state.json`. If an in-flight piece is recorded, offer to resume.
4. Default: prompt for a slug, create `pyramid/{slug}-{YYYY-MM-DD}/` in the cwd.

**Reference resolution** (in order):
1. Explicit flag: `--reference ./path/to/pyramid-reference.md`
2. State memory (recorded reference for this project)
3. Skill default: `pyramid-principle-reference.md` shipped with the skill. Resolve the skill's install path via `Glob` on `**/pyramid/SKILL.md` under the active plugin directory, then take the parent.

Surface the active reference in the first response: `"Using pyramid reference: {path}"`.

**Mode determination** (always interactive, per user direction):

Use `AskUserQuestion` with two options:
- *Greenfield: I have a topic and want a fresh pyramid outline.*
- *Restructure: I have an existing draft and want to pyramid-ify it.*

No silent inference from `--mode` flag or draft presence in cwd. If the user passes `--mode greenfield|restructure` as a flag, still confirm via `AskUserQuestion` but pre-select the flagged option. This prevents the "surprise wrong mode" failure class.

**Domain-limits gate** (cites research section 11):

Before accepting the mode, ask what kind of document this is. If the user's answer maps to one of the genres in research section 11's "does not work for" list (narrative longform, personal essays building to a realisation, exploratory or discovery documents, emotionally-driven persuasion, creative writing, in-progress thinking, pedagogical walk-throughs), surface the mismatch and offer three choices via `AskUserQuestion`:
- *Proceed anyway (I understand the pyramid may be the wrong frame).*
- *Switch: route me to the writing skill instead (for narrative and essay work).*
- *Cancel.*

Not a hard refusal. The writer stays in control.

**Mode A inputs** (if greenfield): topic, audience, the question you expect the reader to have (the apex's implicit question). All interactive, minimal prompting.

**Mode B inputs** (if restructure): draft path (absolute path to a markdown file) OR draft-pasted-inline (orchestrator writes to `draft.md`). The agent reads `draft.md` from the working directory regardless of how it got there.

**Task list** (via `TaskCreate`): one task per phase that will run plus one sub-task per auditor for the panel phase. Mirrors writing skill.

**Output file:** `intake.md` with fields `mode`, `topic_or_draft_path`, `audience`, `reader_question`, `genre`, `domain_limits_acknowledged` (true/false).

### Phase 2: Construct

One Agent dispatch. Mode-branched prompt file.

**Mode A (`construct-greenfield-prompt.md`):** implements **The Q-A Dialogue Procedure** from research section 3. The eight numbered steps are inlined verbatim so the agent executes them in order. Construction proceeds top-down: Subject → Reader/Question → Answer (apex) → Situation (worked backwards) → Complication → verify S+C produces Q → recurse below A.

**Mode B (`construct-restructure-prompt.md`):** implements **The Reverse-Engineering Procedure** from research section 7, steps 1-7 only. Steps 8 (SCQA) and 9 (render prose) are deferred to phases 4 and 5 of the orchestrator. Inputs: `draft.md` in the working directory. Construction proceeds bottom-up: Extract → Cluster → Name governing thoughts → Identify apex → MECE-draft-check → Q-A-draft-check → Sequence.

Both modes write `construction.md` in the same schema:

```markdown
# Pyramid (construction)

**Mode:** greenfield | restructure
**Apex (governing thought):** <one sentence>
**Reader question:** <the question the apex answers>
**Top-level grouping noun:** <plural noun: reasons | steps | risks | recommendations | causes | ...>
**Top-level logic:** inductive | deductive

## Siblings

### 1. <Finding 1 (not a label)>
- Evidence: <one-line evidence>
- Evidence: <...>
- Sub-grouping (if any):
  - <child finding>
    - evidence: <...>

### 2. <Finding 2>
...

### 3. <Finding 3>
...
```

Mode B additionally writes `restructure-notes.md` recording orphan points, items cut, and decisions made during the reverse-engineering. Audit critics read this alongside `construction.md` so the user can see not just what was kept but what was dropped and why.

### Phase 3: Audit Panel (parallel)

Four Agents dispatched in parallel (single message with four Agent tool calls). Each reads `construction.md` (and `restructure-notes.md` in Mode B) and the shipped reference, and writes a verdict file.

| Prompt file | Output file | Test from research |
|-------------|-------------|--------------------|
| `audits/mece.md` | `audit-mece.md` | The Four MECE Audit Questions (section 4) with failed-grouping examples as few-shots |
| `audits/so-what.md` | `audit-so-what.md` | The So-What / Why Chain (section 6) with GLOBIS raise-request example and Caveman Answer Test |
| `audits/qa-alignment.md` | `audit-qa.md` | The Q-A Alignment Audit (section 3) |
| `audits/inductive-deductive.md` | `audit-logic.md` | The Inductive-or-Deductive Audit (section 5) |

Each audit output starts with `**Verdict:** PASS | MINOR ISSUES | CRITICAL ISSUES` on its own line, then contents:

```markdown
**Verdict:** CRITICAL ISSUES

## Findings
1. <issue> — <citation back to construction.md>
2. <issue> — <...>

## Recommended repairs
- <specific repair that addresses finding N>
- <...>

## Reference
Applied audit questions from pyramid-principle-reference.md section N.
```

Orchestrator consolidates into `audit-summary.md`:

```markdown
# Audit Summary

## Verdicts
| Auditor | Verdict | Headline |
|---------|---------|----------|
| MECE | PASS/MINOR/CRITICAL | <one-line> |
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

Verdict-token match follows writing skill verbatim: first whitespace-delimited token of each auditor's `**Verdict:**` line. Expected tokens: `PASS`, `MINOR`, `CRITICAL`.

- All auditors emit PASS or MINOR → continue to Phase 4 (opener).
- Any auditor emits CRITICAL → re-dispatch `construct` (same mode) with `audit-summary.md` injected as `{REVIEWER_FEEDBACK}`. Re-run the panel. Repeat up to 2 iterations. If still CRITICAL after 2, present remaining issues via `AskUserQuestion`: *Continue to opener with known logic issues? / Pause for manual intervention? / Cancel.*

### Phase 4: Opener

One Agent dispatch. Reads `construction.md`, `audit-summary.md` (for any MINOR flags to respect while composing), and the reference.

Implements **The SCQA Opener Audit** from research section 2 generatively: the four audit questions (S friction-free, C identifies cause not symptom, Q arises from C, A-change-requires-C-change) guide production, not just critique.

Writes `opener.md`:

```markdown
# Opener (SCQA)

**Situation:** <noncontroversial context the reader already agrees with>
**Complication:** <the change that makes the situation unstable; identifies a cause, not a symptom>
**Question:** <the falsifiable question C forces>
**Answer:** <the apex, one sentence; must match construction.md's apex>

## Rendered

<one paragraph: S sentence, C sentence, Q sentence, A sentence, written in prose>
```

The agent MUST NOT modify the apex. If the apex cannot support a clean SCQA opener (e.g. no genuine complication exists for this audience, or C would be manufactured), the agent emits `**Verdict:** MISMATCH` followed by a one-paragraph explanation. The orchestrator detects the MISMATCH token and asks the user via `AskUserQuestion` whether to proceed with a degraded opener (S and A only, C and Q omitted), revise the apex by re-running construct with the mismatch note injected as feedback, or cancel. PASS openers need no verdict line.

### Phase 5: Render

Orchestrator-only. Reads `opener.md` + `construction.md` + `audit-summary.md`. Writes `pyramid.md`:

```markdown
# <working title inferred from apex or provided at intake>

**Opener (SCQA).**
S: <situation>. C: <complication>. Q: <question>. A: <apex>.

## Apex
<one-sentence governing thought>

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

(If all audits returned PASS, this section reads: "All four audits passed.")
```

If the user passed `--phase render` directly after editing a construction.md by hand, the render phase detects the absence of `opener.md` and asks whether to run Phase 4 first or render without an opener (degraded output).

## Artifacts per Phase

| File | Phase | Contents |
|------|-------|----------|
| `intake.md` | 1 | mode, topic-or-draft-path, audience, reader question, genre, domain-limits acknowledgement |
| `draft.md` | 1 (Mode B only) | user-supplied original prose |
| `construction.md` | 2 | tentative pyramid (apex + siblings + evidence) |
| `restructure-notes.md` | 2 (Mode B only) | orphan points, items cut, decisions made |
| `audit-mece.md` | 3 | MECE audit verdict and findings |
| `audit-so-what.md` | 3 | So-What audit verdict and findings |
| `audit-qa.md` | 3 | Q-A alignment audit verdict and findings |
| `audit-logic.md` | 3 | Inductive/Deductive classification audit verdict |
| `audit-summary.md` | 3 | consolidated verdicts table + full critic content |
| `opener.md` | 4 | SCQA fields + rendered opener paragraph |
| `pyramid.md` | 5 | final artifact, consumer-facing |

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

Recognised mode values: `greenfield`, `restructure`. The state file is keyed by working directory so multiple in-flight pyramids in the same project each have their own state.

## Phase Identifier Names

Used in `--phase` flag and task list: `intake`, `construct`, `audit`, `opener`, `render`.

## Dispatch Conventions (apply to every Agent-dispatched phase)

Identical to the writing skill's conventions, restated briefly so the skill is self-contained:

- `{OUTPUT_PATH}` is always the working directory, never a file path. Each prompt appends its own filename.
- Prompt file extraction: read entire prompt file as text, perform placeholder substitution (`{TOPIC}`, `{DRAFT_PATH}`, `{OUTPUT_PATH}`, `{REFERENCE_PATH}`, `{REVIEWER_FEEDBACK}`, `{YYYY-MM-DD}`), pass full result to the Agent tool. The agent ignores surrounding commentary.
- Reviewer feedback injection: when `{REVIEWER_FEEDBACK}` is non-empty (re-dispatch on audit CRITICAL), append a standing instruction: *"Reviewer feedback is provided above. Read the existing construction.md in the output directory, address the specific concerns raised by the auditors, and update the file in place."*
- Date substitution: `{YYYY-MM-DD}` resolves to today's date in ISO format.

## Edge Cases

- **Working dir does not exist:** create with `mkdir -p`.
- **Reference not found:** fall back to default and warn *"Using default pyramid reference."*
- **Phase artifact missing on resume:** re-run that phase.
- **Agent dispatch fails:** retry once, then surface error and pause.
- **Auditor returns malformed output (no `**Verdict:**` line):** log, treat as MINOR for safety (not CRITICAL, to avoid false gates), continue.
- **User cancels mid-pipeline:** state file records last completed phase; next invocation resumes.
- **Audit gate fails twice:** present remaining CRITICAL issues, ask whether to proceed or intervene manually.
- **Missing prerequisite artifact on phase jump:**
  - Construct requires `intake.md` (for mode). If absent on `--phase construct`, run intake first (after asking).
  - Audit requires `construction.md`. If absent, run construct first (after asking).
  - Opener requires `construction.md`. If absent, run construct first.
  - Render requires `construction.md` and `opener.md`. If `opener.md` absent, offer Phase 4 or degraded render.
- **Unknown mode value in state or flag:** warn once, ask interactively, record corrected value.
- **Mode A with draft-present-in-cwd:** intake surfaces the draft and asks whether the user meant restructure. Does not silently override their mode choice.
- **Mode B with empty draft:** ask for the draft or bail to Mode A.
- **Domain-limits gate with "proceed anyway":** pipeline continues but records `genre_override: true` in `intake.md`, and the render phase's Audit notes block prepends *"Domain-limits gate was overridden (genre: essay / narrative / etc.). The pyramid may be a poor fit for this piece."*

## Tests

Three layers, matching repo convention.

### Unit (`tests/unit/test-pyramid-skill.sh`)

No auth required. Runs `run_claude` with prompts that probe the skill's recognition and self-description. Assertions:

- Skill loads without error
- Description mentions "pyramid principle" and "Minto"
- SKILL.md references each of the five phases by name
- SKILL.md references the four named audits (MECE, So-What, Q-A Alignment, Inductive-Deductive)
- SKILL.md references the shipped reference file
- SKILL.md references the two construction modes (greenfield, restructure)
- SKILL.md references the domain-limits gate

### Skill-triggering (`tests/skill-triggering/prompts/`)

One `.txt` file per test case. Run with `PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh pyramid tests/skill-triggering/prompts/<file>.txt`.

Positive triggers (should activate pyramid skill):
- `pyramid-greenfield-memo.txt`: *"Help me structure a recommendation memo for our Q3 strategy pivot. Top line is we should sunset product X."*
- `pyramid-restructure-memo.txt`: *"I have this draft memo but the ask is buried at the end and the reasons feel repetitive. Can you pyramid-ify it?"*

Negative triggers (should NOT activate pyramid skill, to prevent over-triggering):
- `pyramid-negative-narrative.txt`: *"Help me write a personal essay about how I learned to ship before I felt ready."* (Belongs to writing skill; pyramid's domain-limits gate would refuse.)
- `pyramid-negative-factual.txt`: *"What are the three rules of the pyramid principle?"* (Informational question; no pyramid to build.)

Boundary triggers (should activate pyramid AND surface the domain-limits gate):
- `pyramid-domain-limit-essay.txt`: *"I want a pyramid-structured version of my personal essay about shipping early."* (Genre is essay, user explicitly asked for pyramid; skill should run intake, surface domain-limits gate, let the user choose.)

### Integration (`tests/integration/test-pyramid-integration.sh`)

One end-to-end smoke test. No auth required (pure text, no external services).

Scenario: Mode A greenfield pipeline on a fixture topic (*"We should raise Series B in Q1 2027"*), with an audience (*"board of directors"*) and a reader question (*"should we raise now or wait?"*). Assertions:

- All nine artifacts exist: `intake.md`, `construction.md`, `audit-mece.md`, `audit-so-what.md`, `audit-qa.md`, `audit-logic.md`, `audit-summary.md`, `opener.md`, `pyramid.md`
- `pyramid.md` contains the required top-level sections: `**Opener (SCQA).**`, `## Apex`, `## Supporting findings`, `## Audit notes`
- `audit-summary.md` has a verdicts table with four rows
- State file exists with `last_completed_phase: render`

Test runner: `run_claude_logged` with `--output-format stream-json` to capture tool usage.

## Editorial Positions (from research, baked into prompts)

These are commitments, not runtime flags. The research produced defensible positions on open questions in the literature; we fix the choice and build around it.

1. **SCQA externally, SCQ+Apex internally.** Users read SCQA in practitioner sources, so the skill calls it SCQA. Internally (construct phase) the apex is treated as the pyramid's top, not as part of the opener. This matches Minto's own material ([research section 2](./2026-04-24-pyramid-principle-research.md#2-the-scqa-opener-mintos-scq-plus-the-apex)).
2. **Default grouping size 3, ceiling 5, 6+ is MECE-failure signal.** When a grouping balloons past 5, the audit prompt instructs the auditor to run the Four MECE Audit Questions before defending the size ([research section 8](./2026-04-24-pyramid-principle-research.md#8-grouping-size-guidance-a-position-on-3-5)).
3. **Inductive by default at every non-leaf.** The construct-greenfield prompt instructs the agent to default to inductive groupings unless a load-bearing causal chain genuinely requires deductive ([research section 5](./2026-04-24-pyramid-principle-research.md#5-vertical-vs-horizontal-logic-inductive-vs-deductive)).
4. **Three worked before/after examples as few-shots.** The audit prompts inline the launch-delay memo, churn memo, and raise-request examples from research section 10 so auditors pattern-match against concrete shapes.
5. **Opener written last.** Phase 4 runs after phase 3, not before phase 2. This prevents the "answer-first bleed" failure mode documented in research section 2.

## Out of Scope (Deferred Follow-ups)

Tracked as new follow-up issues to open after this PR merges:

- **Writing-skill dispatch integration.** Phase 2 of the writing skill dispatches to pyramid when `format ∈ {memo, announcement, briefing}`. Writing produces `interview-synthesis.md`; pyramid reads it as an alternative to an interactive topic intake; pyramid writes `outline.md` (in the writing skill's expected schema) in addition to `pyramid.md`. Requires a small adapter in the construct-greenfield prompt and a schema-alignment pass.
- **Mode D: interactive Socratic dialogue.** Minto's question-answer dialogue applied as a turn-by-turn conversation with the user, each turn producing one tier. Requires significantly more orchestration than modes A and B (user consent gates between every Q-A exchange). Deferred per explicit decision during brainstorming.
- **Storyboarding for presentations.** Minto's chapter on translating pyramids into slide decks. A possible Phase 6 or a sibling skill. Not in v1.
- **Writing skill's format-gated outline routing.** Currently writing always uses its narrative outline prompt. When the integration in the first bullet lands, format gates route memo/announcement/briefing formats through pyramid instead.

## References

- [Research report: pyramid principle operational reference](./2026-04-24-pyramid-principle-research.md)
- [Issue #11: extract pyramid principle into its own skill](https://github.com/pgoell/pgoell-claude-tools/issues/11)
- Writing skill design: [`./2026-04-16-writing-skill-design.md`](./2026-04-16-writing-skill-design.md)
- Research plugin pattern: `plugins/research/skills/research/SKILL.md` (for the parallel fan-out + gate precedent)
- Minto, Barbara. *The Pyramid Principle: Logic in Writing and Thinking.* Primary source, cited via the research report.
