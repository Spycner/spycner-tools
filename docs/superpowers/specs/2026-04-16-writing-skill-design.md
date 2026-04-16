# Writing Skill v1 Design

*Date: 2026-04-16*

## Problem

The owner is starting to write blog posts and longer-form prose with AI assistance. The first draft of "SDD is a crutch for planning" exposed a recurring failure mode: even with explicit voice rules captured in a project CLAUDE.md, agent-drafted prose reads as AI-shaped. Even paragraph rhythm, italic overuse, tidy parallel constructions, meta-framing phrases, rhetorical-question openers, and zero personal texture all show through. The voice rules catch the loud tells; subtle ones slip past.

Katie Parrott's process (documented in her two Every essays, captured in `Zettelkasten/03 Ressources/02 Literature/Katie Parrott - Writing With AI is Harder Than You Think (Every).md` and the companion AI Style Guides note) names a different shape: AI-assisted writing works when you build friction back in, not when you remove it. Her workflow has explicit phases (interview, outline, draft, panel review, finishing) and a panel of specialized critics rather than one generic reviewer.

The repo currently has no writing skill. The closest analog is the `research` plugin which orchestrates a multi-agent pipeline.

## Design Goal

A `/writing` skill in this marketplace that orchestrates the full Parrott pipeline (interview, outline, draft, panel review, finishing) for any prose work (blog posts, essays, talks, newsletters, literature notes). Personal-use first; marketplace-shareable later if it earns the polish.

## Approach: Orchestrator with Phase-Selectable Resume + Task Tracking

One orchestrator skill at `plugins/writing/skills/writing/`. Internal phases run as separate prompt files dispatched via Agent. The orchestrator:

1. Resolves the active style guide (default + override + memory)
2. Determines starting phase (fresh, resume, or jump)
3. Creates a TaskCreate entry per phase (and per critic in the panel phase) so progress is visible
4. Dispatches phase agents in sequence, with critics fanned out in parallel during the panel phase
5. Runs review gates between phases with a re-dispatch loop on critical failures
6. Persists state so subsequent invocations resume cleanly

This mirrors the `research` plugin's architecture exactly. The two differences are: (a) phase-selectable entry, (b) explicit task list visible to the user.

## File Layout

```
plugins/writing/
├── README.md
└── skills/
    └── writing/
        ├── SKILL.md                    # orchestrator
        ├── default-style-guide.md      # ships with the skill
        ├── interview-prompt.md         # phase 1
        ├── outline-prompt.md           # phase 2
        ├── draft-prompt.md             # phase 3
        ├── critics/
        │   ├── hemingway.md            # economy
        │   ├── hitchcock.md            # pacing
        │   ├── mom-reader.md           # accessibility
        │   └── asshole-reader.md       # rigor
        └── finishing/
            ├── ai-pattern-detector.md  # voice tics
            ├── style-enforcer.md       # mechanical rules
            ├── line-editor.md          # sentence-level tightening
            └── sedaris.md              # voice and humor
```

Marketplace registration: one new entry in `.claude-plugin/marketplace.json`:

```json
{
  "name": "writing",
  "source": "./plugins/writing",
  "description": "Multi-phase writing pipeline with panel-of-critics review for blog posts, essays, talks, and longer-form prose",
  "version": "1.0.0"
}
```

## Pipeline Flow

```
/writing  (or /writing --phase X --dir Y, where X ∈ {interview, outline, draft, panel, finishing})
  ↓
[Style guide resolution]  (flag → project file → state memory → skill default)
  ↓
[State scan]  (detect existing artifacts in working dir)
  ↓
[Task list created]  (one entry per phase + sub-tasks per critic)
  ↓
[Phase 1: Interview Agent]
  reads: topic, style guide
  writes: interview.md (Q&A log), interview-synthesis.md (extracted thinking)
  ↓
[Phase 2: Outline Agent]
  reads: interview-synthesis.md, style guide
  writes: outline.md
  ↓
[Phase 3: Draft Agent]
  reads: outline.md, style guide
  writes: draft.md
  ↓
[Phase 4: Panel Review]  (all four critics in parallel)
  ├─ Hemingway → critique-hemingway.md
  ├─ Hitchcock → critique-hitchcock.md
  ├─ Mom Reader → critique-mom.md
  └─ Asshole Reader → critique-asshole.md
  → Consolidated into critique.md
  ├─ PASS or IMPORTANT-only → continue
  └─ CRITICAL → re-dispatch Draft Agent with critique → re-review (max 2, then escalate to user)
  ↓
[Phase 5: Finishing]  (sequential, four passes)
  ├─ AI-pattern detector
  ├─ Style enforcer
  ├─ Line editor
  └─ Sedaris
  → Updates draft.md in place, appends finishing-notes.md
  ↓
[Final draft presented to user]
```

## Phase Prompt Responsibilities

### Interview Agent (`interview-prompt.md`)

Takes the topic and the active style guide. Asks the user one question at a time to extract their thinking. Questions designed per Parrott's interview pattern:

- Why is this on your mind?
- How has this shown up in your work?
- What do you want readers to walk away thinking about?
- What is the friction that makes you want to write this?
- What is the one sentence you want the reader to remember?
- What lived experience anchors this for you?

Writes the full Q&A log to `interview.md`. Synthesizes the extracted thinking into `interview-synthesis.md` (a structured document covering thesis candidate, target audience, key claims, lived experience anchors, and tone signals).

### Outline Agent (`outline-prompt.md`)

Reads `interview-synthesis.md`. Proposes a structure. Treats the outline as a negotiation, not a one-shot. Writes `outline.md` with:

- Working title and one-sentence thesis
- Target length and audience
- Section-by-section beats with word targets
- Concrete scenes or receipts each section will use
- Closing line candidate
- Cut list (sections to drop if over length)

The orchestrator presents the outline back to the user and accepts revisions before passing to the draft phase.

### Draft Agent (`draft-prompt.md`)

Reads `outline.md` and the style guide. Drafts the full prose section by section. Writes `draft.md` with:

- The full prose, matching the style guide's voice rules
- A drafting notes section listing fact-check needs, deviations from the outline, web searches run

The draft is treated as a skeleton, not a final draft. The downstream phases will tighten it.

### Critics (`critics/*.md`)

Each critic is a focused prompt. All four dispatched in parallel during the panel phase. Each writes its own structured feedback file, then the orchestrator consolidates.

- **Hemingway**: cuts every adjective and unnecessary word; flags redundancy; demands you kill your darlings
- **Hitchcock**: checks pacing; flags where reader interest sags; identifies missing tension or stakes
- **Mom reader**: flags where general audiences get lost (jargon, missing context, assumed knowledge)
- **Asshole reader**: attacks every unearned claim with reply-guy energy; demands evidence or explicit defense

Each critic returns: a verdict (PASS, MINOR ISSUES, CRITICAL ISSUES), a list of issues with line references, and a one-sentence summary.

### Finishing passes (`finishing/*.md`)

Sequential. Each reads the draft, applies its narrow lens, and writes back. Each appends notes to `finishing-notes.md`.

- **AI-pattern detector**: scans for correlative constructions, stock transitions ("Here's the thing"), AI vocabulary ("delve"), suspiciously even paragraph rhythm, italic overuse
- **Style enforcer**: applies the active style guide's mechanical rules (punctuation, capitalization, word choices)
- **Line editor**: sentence-by-sentence tightening; flags passive voice, dead weight, flabby constructions
- **Sedaris**: brings personality and voice forward; offers humor or rhythm-breaks where the prose has gone flat

User accepts or rejects per pass or in batch.

## Style Guide Handling

Resolution order on every invocation:

1. **Explicit flag**: `/writing --style-guide ./path/to/guide.md`
2. **Project-level**: search for `style-guide.md` or `CLAUDE.md` in the working directory and parents
3. **State memory**: `~/.claude/projects/<project-id>/writing-skill-state.json` records the last resolved guide for this project. `<project-id>` follows the Claude Code harness convention (working-directory path with slashes replaced by hyphens, leading hyphen, e.g., `-home-pascal-Zettelkasten`)
4. **Skill default**: `default-style-guide.md` shipped with the skill

Once resolved, the path is recorded in the state file. Subsequent invocations in the same project use the remembered guide silently. The orchestrator surfaces the active guide in its first response: "Using style guide: {path}".

If multiple candidates exist and none is in the state file, orchestrator asks once and records the choice.

## Task Tracking

Brainstorming-skill style. On orchestrator entry, after determining which phases to run, the skill creates one TaskCreate entry per phase. Sub-tasks for the panel phase (per critic) and the finishing phase (per pass).

Example task list for a fresh full pipeline run:

```
1. [pending] Phase 1: Interview the author
2. [pending] Phase 2: Negotiate outline
3. [pending] Phase 3: Draft sections
4. [pending] Phase 4: Run panel review
   ├── [pending] Critic: Hemingway
   ├── [pending] Critic: Hitchcock
   ├── [pending] Critic: Mom reader
   └── [pending] Critic: Asshole reader
5. [pending] Phase 5: Finishing pass
   ├── [pending] AI-pattern detector
   ├── [pending] Style enforcer
   ├── [pending] Line editor
   └── [pending] Sedaris
```

Tasks marked `in_progress` when starting, `completed` when artifact verified. Sub-task IDs are tracked individually so parallel critic returns can be marked as they complete.

For phase-selectable runs, only the requested phases get tasks created.

## Working Directory and Artifact Layout

Default working directory: `writing/{slug}-{YYYY-MM-DD}/` in the current project root.

Resolution order:
1. **Explicit flag**: `/writing --dir ./path/to/project/`
2. **Existing artifacts in cwd**: if the current working directory already contains any of the phase artifacts (`interview.md`, `outline.md`, `draft.md`, `critique.md`), the orchestrator treats the cwd as the working directory
3. **State file lookup**: if the project's state file records a working directory for an in-flight piece, offer to resume there
4. **Default**: prompt for a slug, create `writing/{slug}-{YYYY-MM-DD}/` in the cwd

Artifact layout in the working directory:

```
{working-dir}/
├── interview.md
├── interview-synthesis.md
├── outline.md
├── draft.md
├── critique.md                 (consolidated)
├── critique-hemingway.md       (per-critic, kept for traceability)
├── critique-hitchcock.md
├── critique-mom.md
├── critique-asshole.md
└── finishing-notes.md
```

## Edge Cases

- **Working dir does not exist**: create it via Bash `mkdir -p`
- **Style guide not found** at any resolution level: fall back to default and warn "Using default style guide"
- **Phase artifact missing on resume**: orchestrator detects gap, re-runs the missing phase
- **Agent dispatch fails**: retry once, then surface error and pause for user decision
- **Critic returns malformed feedback**: log, continue with the other three critics, mark that critic's sub-task as failed
- **User cancels mid-pipeline**: state file records the last completed phase; next invocation resumes
- **Critique gate fails twice**: present remaining critical issues to user, ask whether to proceed or intervene manually
- **Multiple style guides present** with no state-file record: orchestrator asks once, records the choice

## Default Style Guide Content

Ships as `default-style-guide.md`. Reflects the owner's preferences (personal-use first). Seven sections per Parrott's framework:

1. **Voice and tone**: declarative, specific, skeptical, no hype, first person fine, minimal hedging
2. **Structure**: thesis upfront, scenes ground claims, end by extending or reframing (not summarising)
3. **Sentence-level preferences**: vary length, prefer concrete nouns and verbs, prefer active voice
4. **Signature moves**: at least one to start, e.g., "claim, then concrete scene, then tradeoff named explicitly"; meant to grow over time
5. **Anti-patterns / blacklist** (table format with patterns and solutions):

| Pattern | Solution |
|---|---|
| em-dashes (—) | rewrite with comma, period, colon, parentheses, or split sentence |
| en-dashes (–) | same |
| Hyphens (-) as sentence punctuation | same |
| "leverage", "navigate the complexities", "harness the power", "robust", "seamless" | delete or rewrite |
| "in conclusion", "to sum up", "at the end of the day" | delete; let the closing land on its own |
| "some argue that", "many would say" | delete or attribute specifically |
| Rhetorical question that the author answers immediately | flip to assertion |
| Correlative constructions: "not X, but Y" | rewrite as direct claim |
| Italic emphasis on every key term | use sparingly, only for genuine emphasis |
| "It's worth noting that" | delete |

6. **Positive and negative examples**: two or three short paragraphs anchoring "this sounds like me" (pulled from existing atomic notes); one negative example showing AI-shaped smoothness
7. **Revision checklist**:
   - Does the thesis land in the first 150 words?
   - Are there any em-dashes, en-dashes, or hyphens-as-punctuation?
   - Does each section have a concrete scene, not just a citation?
   - Is there at least one first-person anchor?
   - Does the closing extend the idea, not summarise it?

## Testing

The repo has `tests/` with `unit/`, `integration/`, and `skill-triggering/` subdirs.

For v1:

- **Skill-triggering test** in `tests/skill-triggering/`: verify the `/writing` description triggers on relevant prompts ("draft a blog post", "review this essay", "help me write an article", "run the panel on this draft") and does not trigger on adjacent things ("write a function", "summarise this article")
- **Smoke test** in `tests/integration/`: minimal end-to-end run on a tiny topic with stubbed agent dispatches; verifies all artifacts get produced and task list updates correctly
- **No unit tests** for v1: the skill is mostly prompt files and orchestration logic; no natural unit boundaries
- **Manual validation**: use the skill on SDD post v3 in the Zettelkasten. The post acts as a forcing function. If the skill cannot handle the SDD post, the design is wrong.

## Out of Scope for v1

- Marketplace polish: README assumes personal use; no install instructions for third parties beyond the standard pattern
- Multi-author / multi-voice configuration (Source Code style with per-piece voice spectrums)
- Automated re-dispatch loops beyond max-2 (research uses max-3)
- Web-based companion or browser interface
- Per-platform style guides (e.g., LinkedIn vs. blog vs. Substack)
- Programmatic style-guide builder (the interview-yourself-into-a-guide pattern from Parrott's second essay)

## Future Work

- **Style-guide builder skill**: a separate skill that runs Parrott's interview process to produce a Level 2 style guide for a project. Pairs with the writing skill but operates earlier in a writer's career.
- **Marketplace polish**: clean defaults, generic README, install instructions, sample style guide sets
- **Per-platform variants**: different finishing rules for LinkedIn (em-dashes OK), blog (em-dashes banned per owner preference), Substack (long-form structural conventions)

## Open Questions

None blocking v1. Optional design extensions documented under "Future Work" can be deferred until after first real use.

## Success Criteria for v1

- The skill can take the SDD post v2 draft, run the panel and finishing phases, and produce a v3 draft that the owner judges materially better than what the previous one-shot critique produced
- Voice tells flagged in the v3 plan (rhythm uniformity, italic overuse, parallel-construction tidiness, meta-framing, rhetorical-question openers) get caught by the AI-pattern detector and the line editor
- The state file correctly records the active style guide so subsequent invocations resolve without re-asking
- The task list updates visibly through each phase; sub-tasks for the panel critics show parallel completion
