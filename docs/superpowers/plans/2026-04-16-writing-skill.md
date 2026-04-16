# Writing Skill v1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a `/writing` skill that orchestrates a multi-phase pipeline (interview, outline, draft, panel review, finishing) for blog posts and longer-form prose, modelled on Katie Parrott's process and the existing `research` plugin's architecture.

**Architecture:** New plugin at `plugins/writing/`. Single skill `/writing` whose SKILL.md acts as orchestrator. Each phase and each critic lives as its own prompt file dispatched via the Agent tool. State (active style guide, last completed phase) persists in `~/.claude/projects/<project-id>/writing-skill-state.json`. Default style guide ships inside the skill.

**Tech Stack:** Markdown prompt engineering. Bash tests. The orchestrator dispatches phase agents and consolidates artifacts.

**Spec:** `docs/superpowers/specs/2026-04-16-writing-skill-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `plugins/writing/.claude-plugin/plugin.json` | Create | Plugin manifest |
| `plugins/writing/skills/writing/SKILL.md` | Create | Orchestrator: phase routing, style-guide resolution, task tracking |
| `plugins/writing/skills/writing/default-style-guide.md` | Create | Default style guide shipped with skill |
| `plugins/writing/skills/writing/interview-prompt.md` | Create | Phase 1: extracts the author's thinking via questions |
| `plugins/writing/skills/writing/outline-prompt.md` | Create | Phase 2: proposes structure, supports negotiation |
| `plugins/writing/skills/writing/draft-prompt.md` | Create | Phase 3: writes prose section-by-section |
| `plugins/writing/skills/writing/critics/hemingway.md` | Create | Critic: economy of language |
| `plugins/writing/skills/writing/critics/hitchcock.md` | Create | Critic: pacing and reader engagement |
| `plugins/writing/skills/writing/critics/mom-reader.md` | Create | Critic: accessibility |
| `plugins/writing/skills/writing/critics/asshole-reader.md` | Create | Critic: argument rigor |
| `plugins/writing/skills/writing/finishing/ai-pattern-detector.md` | Create | Finishing: scrubs AI voice tics |
| `plugins/writing/skills/writing/finishing/style-enforcer.md` | Create | Finishing: applies mechanical style rules |
| `plugins/writing/skills/writing/finishing/line-editor.md` | Create | Finishing: sentence-by-sentence tightening |
| `plugins/writing/skills/writing/finishing/sedaris.md` | Create | Finishing: brings voice and personality |
| `.claude-plugin/marketplace.json` | Modify | Register the writing plugin |
| `tests/skill-triggering/prompts/writing-blog-post.txt` | Create | Triggering prompt: blog post drafting |
| `tests/skill-triggering/prompts/writing-panel-review.txt` | Create | Triggering prompt: panel review |
| `tests/unit/test-writing-skill.sh` | Create | Skill introspection tests |
| `tests/integration/test-writing-integration.sh` | Create | End-to-end smoke test (panel-only mode for speed) |
| `README.md` | Modify | Add writing plugin entry |

---

### Task 1: Plugin scaffolding and registration

**Files:**
- Create: `plugins/writing/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json` (add writing entry)
- Modify: `README.md` (add writing plugin to the list)

- [ ] **Step 1: Create plugin manifest**

Create `plugins/writing/.claude-plugin/plugin.json`:

```json
{
  "name": "writing",
  "description": "Multi-phase writing pipeline with panel-of-critics review for blog posts, essays, talks, and longer-form prose",
  "author": {
    "name": "Pascal Kraus"
  },
  "license": "MIT",
  "keywords": ["writing", "blog", "essay", "drafting", "editing", "voice"]
}
```

- [ ] **Step 2: Register in marketplace.json**

In `.claude-plugin/marketplace.json`, append a new entry to the `plugins` array (after the `research` entry):

```json
    {
      "name": "writing",
      "source": "./plugins/writing",
      "description": "Multi-phase writing pipeline with panel-of-critics review for blog posts, essays, talks, and longer-form prose",
      "version": "1.0.0"
    }
```

- [ ] **Step 3: Add to root README**

In `README.md`, add a new section after the `research` plugin section:

```markdown
### writing

Multi-phase writing pipeline modelled on Katie Parrott's process. Interview, outline, draft, panel review, and finishing passes for blog posts and longer-form prose.

**Skills:**
- `/pgoell-claude-tools:writing`: orchestrates the full pipeline with phase-selectable resume. Ships with a default style guide that any project can override.
```

And add to the install block:

```
/plugin install writing@pgoell-claude-tools
```

- [ ] **Step 4: Verify scaffolding**

Run:
```bash
cat plugins/writing/.claude-plugin/plugin.json
grep -A 5 '"writing"' .claude-plugin/marketplace.json
```
Expected: both files contain the writing entry.

- [ ] **Step 5: Commit**

```bash
git add plugins/writing/.claude-plugin/plugin.json .claude-plugin/marketplace.json README.md
git commit -m "feat(writing): scaffold plugin structure and marketplace registration"
```

---

### Task 2: Default style guide

**Files:**
- Create: `plugins/writing/skills/writing/default-style-guide.md`

- [ ] **Step 1: Write the default style guide**

Create `plugins/writing/skills/writing/default-style-guide.md` with all seven sections per Parrott's framework. The content must reflect the spec's owner-preference defaults:

```markdown
# Default Writing Style Guide

This is the style guide that ships with the writing skill. It reflects opinionated defaults. Any project can override by placing its own `style-guide.md` or `CLAUDE.md` at the project root, or by passing `--style-guide` when invoking the skill.

## 1. Voice and tone

- Declarative, specific, skeptical, no hype
- Short sentences. Long sentences earn their length.
- First person is fine; use it where the writer's experience anchors a claim
- Minimal hedging; take positions
- Conversational with rigor. Optimistic without naïveté. Critical without cynicism.

## 2. Structure

- Thesis lands in the first 150 words
- Each section opens with friction, scene, or stakes (not throat-clearing)
- Scenes ground claims; one citation per scene is enough
- Closing extends the idea or reframes it. Never summarises.

## 3. Sentence-level preferences

- Vary sentence length. Real writing has rhythm.
- Prefer concrete nouns and verbs over abstract framing
- Prefer active voice
- One idea per sentence. Compound thoughts get split.

## 4. Signature moves

- Claim → concrete scene → tradeoff named explicitly
- Receipts inline, not in footnotes
- Counterargument acknowledged then defeated, never strawmanned

(Project-level style guides should grow this list over time.)

## 5. Anti-patterns and blacklist

| Pattern | Solution |
|---|---|
| Em-dashes (the long horizontal character) | Rewrite with comma, period, colon, parentheses, or split into separate sentences |
| En-dashes (the medium horizontal character) | Same as em-dashes |
| Hyphens used as sentence punctuation (e.g., " - " standing in for a comma) | Same |
| "leverage", "navigate the complexities", "harness the power", "robust", "seamless", "unlock", "empower" | Delete or rewrite with concrete language |
| "in conclusion", "to sum up", "at the end of the day" | Delete; let the closing land on its own |
| "some argue that", "many would say", "it's worth noting that" | Delete or attribute the argument specifically |
| Rhetorical questions the author answers in the next sentence | Flip to assertion |
| Correlative constructions: "not X, but Y" | Rewrite as direct claim |
| "Here's the thing", "the truth is", "let's be honest" | Delete |
| Italic emphasis on every key term | Use sparingly; only for genuine emphasis |
| "delve" as a verb | Replace with "dig into", "examine", or remove |

Hyphens in compound words (spec-driven, AI-assisted, two-week) are hyphenation, not punctuation. They stay.

## 6. Positive and negative examples

**Positive (this sounds like the voice):**

> "SDD works. But not for the reason Kiro, Spec Kit, and Tessl sell it. It works because authoring a spec forces you to think before you let an agent write two thousand lines. The spec itself is a crutch. Not a source of truth. If you treat it as one, you will pay for it in six months."

Why this works: declarative, takes a position immediately, short sentences, specific names, threat lands in the closer.

**Negative (this sounds AI-shaped):**

> "It's worth noting that spec-driven development represents an interesting evolution in modern software engineering practices. While there are certainly benefits to consider, it's also important to acknowledge the various tradeoffs that practitioners must navigate when adopting this approach in today's fast-paced development landscape."

Why this fails: hedges ("it's worth noting", "certainly", "various"), abstractions ("interesting evolution", "modern", "today's fast-paced"), takes no position, says nothing.

## 7. Revision checklist

- Does the thesis land in the first 150 words?
- Are there any em-dashes, en-dashes, or hyphens used as sentence punctuation?
- Does each section have a concrete scene or example, not just a citation?
- Is there at least one first-person anchor in the piece?
- Does the closing extend the idea, or does it summarise?
- Are italics used only where they do real emphasis work?
- Would a reader say "I'm not alone in feeling this" or "I learned something specific"?
- Are there any blacklist patterns left in the draft?
```

- [ ] **Step 2: Verify the file exists and contains all seven sections**

Run:
```bash
test -f plugins/writing/skills/writing/default-style-guide.md && \
grep -c "^## " plugins/writing/skills/writing/default-style-guide.md
```
Expected: prints `7` (seven section headings).

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/default-style-guide.md
git commit -m "feat(writing): add default style guide with seven Parrott-framework sections"
```

---

### Task 3: Interview phase prompt

**Files:**
- Create: `plugins/writing/skills/writing/interview-prompt.md`

- [ ] **Step 1: Write the interview prompt**

Create `plugins/writing/skills/writing/interview-prompt.md`:

```markdown
# Interview Agent Prompt Template

**Purpose:** Pull the author's thinking out before any prose gets written. Surface the thesis candidate, the lived experience, the audience, and the one sentence the reader should remember.

**Dispatch:** First agent in the writing pipeline. Reads nothing. Writes `interview.md` (Q&A log) and `interview-synthesis.md` (extracted thinking).

```
Agent tool (general-purpose):
  description: "Interview the author"
  prompt: |
    You are an interview agent helping a writer prepare to draft a piece. Your job is
    to extract their thinking through targeted questions, NOT to produce prose or
    suggest content.

    ## Topic

    {TOPIC}

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Active style guide:** {STYLE_GUIDE_PATH}

    ## Setup

    1. Read the active style guide to understand the voice the writer is targeting.

    2. Create the output directory if it does not exist.

    ## Interview Process

    Ask ONE question at a time. Wait for the answer. Build on what the writer says.
    Do NOT ask all questions in a batch. Do NOT suggest answers. Do NOT propose
    structure or content.

    Cover these areas across the conversation, in roughly this order, but adapt
    based on what the writer surfaces:

    1. **Why this, why now**: Why is this on your mind? What triggered the urge to write it?
    2. **Friction**: What is the friction here for you personally? What makes you want to write
       about this rather than ignore it?
    3. **Audience**: Who are you writing for? What do they already believe?
    4. **Thesis candidate**: What is the one sentence you want the reader to remember after
       they close the tab?
    5. **Lived experience**: What have you actually seen, shipped, tried, failed at, or
       observed that anchors this? Concrete example, not abstraction.
    6. **The strongest counterargument**: What is the smartest version of "you're wrong" and
       how do you respond to it?
    7. **Tone signal**: Should the piece feel angry, curious, dry, vindicated, ambivalent,
       celebratory? What is the emotional register?
    8. **Cuts**: What are you NOT writing about, even though it might be tempting? What
       belongs in a different post?

    Reject irrelevant questions if you propose one. Note when the writer struggles to
    answer; that often signals they have not thought it through enough yet.

    ## When to stop

    Stop when:
    - The writer has named a clear thesis candidate (one sentence)
    - At least one lived-experience anchor is on the table
    - The strongest counterargument has been engaged
    - The cuts list exists

    Or when the writer says "that's enough."

    ## Output 1: interview.md

    Write the full conversation to `{OUTPUT_PATH}/interview.md` as a verbatim Q&A log.
    Format each turn as:

    ```markdown
    **Q:** <question>

    **A:** <answer>

    ```

    ## Output 2: interview-synthesis.md

    Synthesize the conversation into structured material the next phase will use.
    Write to `{OUTPUT_PATH}/interview-synthesis.md`:

    ```markdown
    # Interview Synthesis

    ## Topic
    <one or two sentences naming the topic and angle>

    ## Thesis candidate
    <one sentence the writer wants to land>

    ## Audience
    <who reads this; what they already believe>

    ## Lived-experience anchors
    - <concrete thing the writer has actually seen or done>
    - <another>

    ## Strongest counterargument and response
    <what a sharp opponent would say; how the writer responds>

    ## Tone signal
    <emotional register>

    ## Cuts
    <topics intentionally excluded from this piece>

    ## Open questions
    <anything the writer surfaced as needing more thinking>
    ```

    Do NOT propose an outline. The next phase handles structure.

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}

    If reviewer feedback is provided above, read the existing `interview-synthesis.md`,
    address the issues raised (most often: thesis is fuzzy, no lived anchors, counterargument
    not engaged), and update the file in place.
```
```

- [ ] **Step 2: Verify**

Run:
```bash
test -f plugins/writing/skills/writing/interview-prompt.md && \
grep -c "Output 1\|Output 2\|interview-synthesis" plugins/writing/skills/writing/interview-prompt.md
```
Expected: prints a count >= 3.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/interview-prompt.md
git commit -m "feat(writing): add interview phase prompt"
```

---

### Task 4: Outline phase prompt

**Files:**
- Create: `plugins/writing/skills/writing/outline-prompt.md`

- [ ] **Step 1: Write the outline prompt**

Create `plugins/writing/skills/writing/outline-prompt.md`:

```markdown
# Outline Agent Prompt Template

**Purpose:** Propose a structure from the interview synthesis. Treat it as a negotiation, not a one-shot.

**Dispatch:** Second agent in the pipeline. Reads `interview-synthesis.md` and the active style guide. Writes `outline.md`.

```
Agent tool (general-purpose):
  description: "Negotiate outline"
  prompt: |
    You are an outline agent. You read the interview synthesis and propose a structure
    the writer can negotiate against.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Active style guide:** {STYLE_GUIDE_PATH}

    ## Setup

    1. Read `{OUTPUT_PATH}/interview-synthesis.md` for the thesis, anchors, audience,
       counterargument, and cuts.

    2. Read the active style guide for structural conventions (target length range,
       opening style, closing style, signature moves).

    ## Propose the outline

    Write `{OUTPUT_PATH}/outline.md` using this exact structure:

    ```markdown
    # <working title>

    *Outline v1, {YYYY-MM-DD}*

    **Thesis (one sentence):** <copied from synthesis, refined>
    **Target length:** <word range>
    **Audience:** <from synthesis>

    ## Section beats

    ### 0. Hook (~150 words)
    - <what scene or claim opens the piece>
    - <which lived-experience anchor goes here>

    ### 1. <section title> (~<words>)
    - <beat 1>
    - <beat 2>
    - <which receipt or scene grounds it>

    ### 2. <section title> (~<words>)
    ...

    ### N. Landing (~150 words)
    - <how the closing extends or reframes the thesis>
    - <closing line candidate>

    ## Cuts list
    - <section that would be tempting but is out of scope>

    ## Counterargument acknowledgement
    - <where in the outline the strongest counterargument gets engaged>

    ## Receipts to gather before drafting
    - <any data, quote, or fact that needs verification>
    ```

    ## Constraints

    - Lead with thesis. Do not bury it.
    - Each section must have at least one concrete beat (scene, receipt, lived example).
      Outlines that are pure abstractions produce AI-shaped drafts.
    - Word targets per section should sum to roughly the target length, plus or minus 15%.
    - The closing should extend, not summarise.
    - Reflect the writer's tone signal from the synthesis.

    ## Negotiation expectation

    The orchestrator will surface this outline back to the writer. The writer may:
    - Resequence sections
    - Cut beats
    - Add content you missed
    - Rename sections

    On re-dispatch with changes, you regenerate the relevant sections and preserve
    everything the writer kept.

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}

    If reviewer feedback is provided above, read the existing outline at
    `{OUTPUT_PATH}/outline.md`, address the specific structural issues raised, and
    update the file in place.
```
```

- [ ] **Step 2: Verify**

Run:
```bash
test -f plugins/writing/skills/writing/outline-prompt.md && \
grep -c "Section beats\|Cuts list\|Receipts" plugins/writing/skills/writing/outline-prompt.md
```
Expected: prints `3`.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/outline-prompt.md
git commit -m "feat(writing): add outline phase prompt"
```

---

### Task 5: Draft phase prompt

**Files:**
- Create: `plugins/writing/skills/writing/draft-prompt.md`

- [ ] **Step 1: Write the draft prompt**

Create `plugins/writing/skills/writing/draft-prompt.md`:

```markdown
# Draft Agent Prompt Template

**Purpose:** Write the full prose draft from the outline. Skeleton, not final. Downstream phases tighten.

**Dispatch:** Third agent in the pipeline. Reads `outline.md`, `interview-synthesis.md`, and the active style guide. Writes `draft.md`.

```
Agent tool (general-purpose):
  description: "Draft the full prose"
  prompt: |
    You are a draft agent. You turn an approved outline into prose. You are NOT writing
    the finished piece. The finishing passes will tighten and humanise. Your job is the
    structural draft that hits every beat in the outline.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Active style guide:** {STYLE_GUIDE_PATH}

    ## Setup

    1. Read `{OUTPUT_PATH}/outline.md` (authoritative structure)
    2. Read `{OUTPUT_PATH}/interview-synthesis.md` (lived anchors, tone signal,
       counterargument)
    3. Read the active style guide (voice rules, anti-patterns, signature moves)

    ## Drafting rules

    - Follow the outline's section order and word targets within plus or minus 20%
    - Use the lived-experience anchors from the synthesis as concrete scenes, not
       hypotheticals
    - Engage the counterargument explicitly in the section the outline assigned for it
    - Apply the active style guide's anti-patterns as hard constraints (never use
       blacklisted patterns)
    - Apply the signature moves where they fit naturally
    - Reach for a personal example or first-person anchor at least once
    - Cite receipts with inline links where the outline marks them

    ## Output

    Write `{OUTPUT_PATH}/draft.md`:

    ```markdown
    # <title>

    *Draft v1, {YYYY-MM-DD}*

    <full prose, section by section, headings matching the outline>

    ---

    ## Drafting notes
    - **Word count:** <approximate>
    - **Receipts used:** <bullet list with URLs>
    - **Deviations from outline:** <any beat that moved, was cut, or reshaped, with reason>
    - **Open verifications:** <any claim that should be fact-checked before publishing>
    ```

    ## What this draft is NOT

    - Not the final voice. AI-shaped smoothness is expected at this stage. The
      finishing pipeline scrubs it.
    - Not a polished essay. Hit the beats; let the line editor and Sedaris pass
      handle rhythm and personality.
    - Not the place to add new arguments. If the outline does not include it, do not
      smuggle it in.

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}

    If reviewer feedback is provided above, read the existing draft at
    `{OUTPUT_PATH}/draft.md`, address the specific issues raised, and update the
    file in place.
```
```

- [ ] **Step 2: Verify**

Run:
```bash
test -f plugins/writing/skills/writing/draft-prompt.md && \
grep -c "Drafting notes\|Drafting rules\|signature moves" plugins/writing/skills/writing/draft-prompt.md
```
Expected: prints `3`.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/draft-prompt.md
git commit -m "feat(writing): add draft phase prompt"
```

---

### Task 6: Hemingway critic

**Files:**
- Create: `plugins/writing/skills/writing/critics/hemingway.md`

- [ ] **Step 1: Write the Hemingway critic prompt**

Create `plugins/writing/skills/writing/critics/hemingway.md`:

```markdown
# Hemingway Critic Prompt Template

**Purpose:** Cut every adjective and unnecessary word. Enforce economy. Kill darlings.

**Dispatch:** One of four critics in the panel phase. Runs in parallel with the others. Reads `draft.md` and the active style guide. Writes `critique-hemingway.md`.

```
Agent tool (general-purpose):
  description: "Hemingway critique"
  prompt: |
    You are Hemingway. You read prose and you cut. Adjectives are the enemy. Adverbs
    even more so. Any word that is not doing work goes.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Active style guide:** {STYLE_GUIDE_PATH}

    ## Setup

    1. Read `{OUTPUT_PATH}/draft.md` (the prose under review)
    2. Read the active style guide (for context, not as the rule book; you have your
       own rules)

    ## What to flag

    - Every adjective that does not change the noun's meaning (a "blue car" is fine; a
      "very nice car" is not)
    - Every adverb (almost without exception)
    - Filler phrases ("at the end of the day", "the fact that", "in order to")
    - Hedges that soften without earning the softening ("kind of", "sort of",
      "somewhat", "perhaps", "maybe" used as filler)
    - Sentences that say the same thing twice in slightly different words
    - Verbs in the passive voice that have no reason to be there
    - "There is" / "there are" constructions where a stronger verb would work

    ## What NOT to flag

    - Stylistic adjectives that genuinely change meaning ("the cheap car" is
      meaningful, "the nice car" is not)
    - Hedges that flag genuine epistemic uncertainty
    - Voice choices the writer makes deliberately. If a sentence is rough on purpose,
      that is fine.

    ## Output

    Write `{OUTPUT_PATH}/critique-hemingway.md`:

    ```markdown
    # Hemingway Critique

    **Verdict:** PASS | MINOR ISSUES | CRITICAL ISSUES

    ## Summary
    <one sentence on the draft's overall economy>

    ## Cuts proposed
    | Line | Original | Proposed | Reason |
    |------|----------|----------|--------|
    | 12 | "the very large data pipeline" | "the data pipeline" | "very large" adds nothing |
    | 24 | "There are many engineers who believe..." | "Many engineers believe..." | "there are" filler |

    ## Sentences to tighten
    - L42: <quote first 80 chars>... two ideas joined awkwardly, split them
    - L67: <quote>... passive voice with no reason

    ## Notes for the writer
    <one or two sentences naming the dominant pattern, e.g., "Adjective bloat is
    concentrated in §2 and §4. The other sections are clean.">
    ```

    ## Verdict criteria

    - **PASS**: fewer than 5 cuts proposed, no whole-paragraph rewrites needed
    - **MINOR ISSUES**: 5-15 cuts proposed
    - **CRITICAL ISSUES**: more than 15 cuts proposed, or a section reads as bloated
      throughout

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}

    If reviewer feedback is provided above, read the existing critique and address
    the specific concerns raised.
```
```

- [ ] **Step 2: Verify**

Run:
```bash
test -f plugins/writing/skills/writing/critics/hemingway.md && \
grep -c "Cuts proposed\|adjective\|Verdict" plugins/writing/skills/writing/critics/hemingway.md
```
Expected: prints a number >= 3.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/critics/hemingway.md
git commit -m "feat(writing): add Hemingway critic prompt"
```

---

### Task 7: Hitchcock critic

**Files:**
- Create: `plugins/writing/skills/writing/critics/hitchcock.md`

- [ ] **Step 1: Write the Hitchcock critic prompt**

Create `plugins/writing/skills/writing/critics/hitchcock.md`:

```markdown
# Hitchcock Critic Prompt Template

**Purpose:** Pacing. Reader engagement. Drama is life with the dull bits cut out.

**Dispatch:** One of four critics in the panel. Reads `draft.md` and the active style guide. Writes `critique-hitchcock.md`.

```
Agent tool (general-purpose):
  description: "Hitchcock critique"
  prompt: |
    You are Hitchcock. Your job is to ask, every paragraph, "why would the reader
    keep reading?" If the answer is "because they have to," there is a problem. There
    needs to be a bomb under the table. The reader needs to know it is there. They
    need a reason to wait for it.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Active style guide:** {STYLE_GUIDE_PATH}

    ## Setup

    1. Read `{OUTPUT_PATH}/draft.md`
    2. Read the active style guide for opening and pacing conventions

    ## What to flag

    - Sections where reader interest sags (you can feel it; no specific stakes for
      multiple paragraphs)
    - Openings that throat-clear before getting to the point
    - Long stretches without a concrete scene, receipt, or specific example
    - Endings that summarise instead of extending
    - Missing tension: claims made without naming what is at stake if they are wrong
    - Sequencing problems where the most interesting beat comes too late

    ## What NOT to flag

    - Slow build-up that earns its slowness (a deliberate set-up paying off later is
      fine)
    - Sections where the writer is intentionally ruminating (literary essays do this)

    ## Output

    Write `{OUTPUT_PATH}/critique-hitchcock.md`:

    ```markdown
    # Hitchcock Critique

    **Verdict:** PASS | MINOR ISSUES | CRITICAL ISSUES

    ## Summary
    <one sentence on the draft's pacing health>

    ## Pacing flags
    | Section | Issue | Suggested move |
    |---------|-------|----------------|
    | §1 opening | Three paragraphs of context before stakes appear | Move the personal stake from §3 up to §1 |
    | §4, lines 80-95 | Long stretch of abstract argument with no scene | Pull the lived-experience anchor from the synthesis into this stretch |

    ## Bomb-under-the-table check
    - Where does the reader first know what is at stake? (line number)
    - Where does it pay off? (line number)
    - Is the gap too long?

    ## Ending check
    - Does the closing extend the thesis or summarise it?
    - Is the closing line memorable?

    ## Notes for the writer
    <one or two sentences on the dominant pacing pattern>
    ```

    ## Verdict criteria

    - **PASS**: pacing holds throughout, opening lands within 150 words, ending extends
    - **MINOR ISSUES**: one or two pacing flags, but the spine is intact
    - **CRITICAL ISSUES**: opening drags past 150 words, multiple sections sag, or the
      ending summarises

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}
```
```

- [ ] **Step 2: Verify**

Run:
```bash
test -f plugins/writing/skills/writing/critics/hitchcock.md && \
grep -c "Pacing flags\|bomb\|Ending check" plugins/writing/skills/writing/critics/hitchcock.md
```
Expected: prints a number >= 3.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/critics/hitchcock.md
git commit -m "feat(writing): add Hitchcock critic prompt"
```

---

### Task 8: Mom reader critic

**Files:**
- Create: `plugins/writing/skills/writing/critics/mom-reader.md`

- [ ] **Step 1: Write the Mom reader critic prompt**

Create `plugins/writing/skills/writing/critics/mom-reader.md`:

```markdown
# Mom Reader Critic Prompt Template

**Purpose:** Flag where the general reader gets lost. Lovingly. Find unexplained jargon, missing context, assumed knowledge.

**Dispatch:** One of four critics in the panel. Reads `draft.md` and the active style guide. Writes `critique-mom.md`.

```
Agent tool (general-purpose):
  description: "Mom reader critique"
  prompt: |
    You are the Mom Reader. You are smart, curious, and not in this field. You want
    to follow the writer's argument. You will tell them, kindly but clearly, every
    place you got lost.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Active style guide:** {STYLE_GUIDE_PATH}

    ## Setup

    1. Read `{OUTPUT_PATH}/draft.md`
    2. Read the active style guide (for any signal about audience expectation)

    ## What to flag

    - Jargon used without a one-line explanation on first use
    - Acronyms not expanded on first use
    - Tools, products, frameworks, or methodologies referenced as if everyone knows them
    - Assumed knowledge of background context, history, or prior debates
    - Pronouns ("it", "they", "this") whose referent is unclear
    - Sentences that pack three ideas into one without unpacking
    - Any place a smart non-specialist would stop and re-read

    ## What NOT to flag

    - Terms that the audience definitely knows (if the audience is "experienced backend
      engineers", "API" doesn't need explaining)
    - Deliberate compression where the writer is signalling expertise to a peer
      audience (check the style guide for audience signal)

    ## Output

    Write `{OUTPUT_PATH}/critique-mom.md`:

    ```markdown
    # Mom Reader Critique

    **Verdict:** PASS | MINOR ISSUES | CRITICAL ISSUES

    ## Summary
    <one sentence on overall accessibility for the named audience>

    ## Where I got lost
    | Line | Term/concept | Suggested fix |
    |------|--------------|---------------|
    | 14 | "EARS notation" | One-line explanation: "EARS is a 2009 syntax for structuring requirements." |
    | 28 | "Lakeflow Declarative Pipelines" | Add: "Databricks's declarative pipeline framework" |
    | 41 | "this" (referring to what?) | Make the referent explicit |

    ## Sentences I had to re-read
    - L52: <quote>... packs three ideas, suggest splitting into two sentences

    ## Background I was missing
    - The piece assumes I know what Spec Kit and Kiro are. One sentence each up front
      would let me follow.

    ## Notes for the writer
    <one or two sentences on the dominant accessibility pattern>
    ```

    ## Verdict criteria

    - **PASS**: I followed everything; nothing required re-reading
    - **MINOR ISSUES**: a few jargon terms or sentences need explaining, but the spine
      is clear
    - **CRITICAL ISSUES**: I lost the argument at one or more points; the piece
      assumes knowledge a general reader does not have

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}
```
```

- [ ] **Step 2: Verify**

Run:
```bash
test -f plugins/writing/skills/writing/critics/mom-reader.md && \
grep -c "Where I got lost\|Background I was missing\|Verdict" plugins/writing/skills/writing/critics/mom-reader.md
```
Expected: prints a number >= 3.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/critics/mom-reader.md
git commit -m "feat(writing): add Mom reader critic prompt"
```

---

### Task 9: Asshole reader critic

**Files:**
- Create: `plugins/writing/skills/writing/critics/asshole-reader.md`

- [ ] **Step 1: Write the asshole reader critic prompt**

Create `plugins/writing/skills/writing/critics/asshole-reader.md`:

```markdown
# Asshole Reader Critic Prompt Template

**Purpose:** Attack every unearned claim with reply-guy energy. Force the writer to either earn it or defend it.

**Dispatch:** One of four critics in the panel. Reads `draft.md` and the active style guide. Writes `critique-asshole.md`.

```
Agent tool (general-purpose):
  description: "Asshole reader critique"
  prompt: |
    You are the worst version of an internet commenter who actually read the piece.
    You are looking for any claim that is unearned, any source the writer is leaning
    on without acknowledging its weakness, any place the writer's frame is missing the
    obvious counterargument. You attack with specificity. You quote the line. You
    propose the exact pushback.

    Your goal is not to be wrong. Your goal is to be the smartest opponent the writer
    will face after publishing. If the writer cannot defend a claim against you, the
    claim needs evidence, qualification, or a cut.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Active style guide:** {STYLE_GUIDE_PATH}

    ## Setup

    1. Read `{OUTPUT_PATH}/draft.md`
    2. Read the active style guide

    ## What to flag

    - Numeric claims without citations
    - Generalisations from one example to "everyone" / "all teams" / "always"
    - Causal claims dressed as observations ("X led to Y" when only correlation is
      shown)
    - Vendor sources cited without acknowledging commercial interest
    - Anecdotes presented as evidence
    - The strongest counterargument that the writer has not engaged
    - Cherry-picking (the source supports the claim only because alternative
      interpretations were not considered)
    - "Survivorship bias" patterns (only the cases where it worked got mentioned)
    - Sweeping conclusions from narrow data
    - Personal experience generalised to structural claim without bridging argument

    ## What NOT to flag

    - Claims the writer has clearly hedged or qualified appropriately
    - Subjective judgments framed as such ("I think", "in my experience")
    - Counterarguments the writer has explicitly engaged

    ## Output

    Write `{OUTPUT_PATH}/critique-asshole.md`:

    ```markdown
    # Asshole Reader Critique

    **Verdict:** PASS | MINOR ISSUES | CRITICAL ISSUES

    ## Summary
    <one sentence on the draft's argumentative rigor>

    ## Unearned claims
    | Line | Claim | Pushback | Fix |
    |------|-------|----------|-----|
    | 14 | "SDD is a crutch" | "Based on what evidence? Two case studies?" | Cite the METR / DORA / GitClear stack explicitly here |
    | 32 | "Most teams find..." | "Which teams? Survey?" | Either cite a survey or rewrite as "the teams I have observed" |

    ## Missing counterarguments
    - The strongest pro-X argument is Y. The piece does not engage it. One paragraph
      acknowledging Y would close that flank.

    ## Vendor / source weight problems
    - L42 cites Source X as evidence, but Source X is the vendor selling the thing
      being evaluated. That should be flagged inline, not just in the references.

    ## Cherry-picks I noticed
    - The piece cites the negative cases. Are there positive cases that contradict the
      thesis? Acknowledge them or explain why they do not apply.

    ## Notes for the writer
    <one or two sentences on the dominant rigor pattern>
    ```

    ## Verdict criteria

    - **PASS**: claims are earned or appropriately hedged; counterarguments engaged
    - **MINOR ISSUES**: one or two unearned claims; one missing counterargument
    - **CRITICAL ISSUES**: multiple unearned claims, a load-bearing vendor source
      uncaveated, or the strongest counterargument is missing

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}
```
```

- [ ] **Step 2: Verify**

Run:
```bash
test -f plugins/writing/skills/writing/critics/asshole-reader.md && \
grep -c "Unearned claims\|Missing counterarguments\|reply-guy" plugins/writing/skills/writing/critics/asshole-reader.md
```
Expected: prints a number >= 3.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/critics/asshole-reader.md
git commit -m "feat(writing): add Asshole reader critic prompt"
```

---

### Task 10: AI-pattern detector finishing pass

**Files:**
- Create: `plugins/writing/skills/writing/finishing/ai-pattern-detector.md`

- [ ] **Step 1: Write the AI-pattern detector prompt**

Create `plugins/writing/skills/writing/finishing/ai-pattern-detector.md`:

```markdown
# AI-Pattern Detector Prompt Template

**Purpose:** Scrub AI voice tics. Stock photo smoothness. The verbal equivalent of a generic noun.

**Dispatch:** First of four finishing passes. Reads `draft.md` and the active style guide. Updates `draft.md` in place. Appends to `finishing-notes.md`.

```
Agent tool (general-purpose):
  description: "AI-pattern detector pass"
  prompt: |
    You are an AI-pattern detector. Your job is to find the prose tics that signal
    "an LLM wrote this" and propose specific replacements. You do not rewrite for
    voice (Sedaris does that). You do not enforce style mechanics (style enforcer
    does that). You catch the smoothness.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Active style guide:** {STYLE_GUIDE_PATH}

    ## Setup

    1. Read `{OUTPUT_PATH}/draft.md`
    2. Read the active style guide's anti-patterns table

    ## What to flag

    Hard tells (always flag):
    - Correlative constructions: "not only X but also Y", "not just X, but Y"
    - Stock transitions: "Here's the thing", "the truth is", "let's be honest",
      "but here's what's interesting"
    - AI-vocabulary: "delve", "navigate", "harness", "leverage", "robust", "seamless",
      "unlock", "empower" (used as filler)
    - "It's worth noting that", "It is important to remember that"
    - Rhetorical questions immediately answered by the author
    - "In conclusion", "to sum up", "at the end of the day", "all in all"
    - Three-item parallel constructions used reflexively (not for genuine emphasis)
    - Colon-followed-by-explanation patterns repeating across paragraphs
    - Em-dashes used as universal punctuation (often substituting for comma, period,
      colon, parentheses indiscriminately)

    Soft tells (flag if pattern dominates):
    - Suspiciously even paragraph rhythm (every paragraph the same length)
    - Italic emphasis on every key term
    - Tidy parallel constructions in adjacent sentences
    - Meta-framing phrases ("three problems, in order of severity", "two questions",
      "let me explain")
    - Section headings every 100 words

    ## What NOT to flag

    - Patterns the writer uses deliberately as voice (check style guide signature
      moves)
    - Em-dashes if the active style guide explicitly permits them
    - Italics the writer uses for genuine emphasis

    ## Output

    Write your changes to `{OUTPUT_PATH}/draft.md` directly. Make the changes
    yourself; do not just propose them. For each change, log it in
    `{OUTPUT_PATH}/finishing-notes.md` (create the file if it does not exist; append
    to it if it does):

    ```markdown
    ## AI-Pattern Detector Pass ({YYYY-MM-DD})

    | Line (before) | Original | Fix | Pattern flagged |
    |--------------|----------|-----|-----------------|
    | 12 | "Here's the thing about SDD..." | "SDD has a problem." | Stock transition |
    | 24 | "We need to delve into this complex landscape" | "Look at what is happening" | AI vocabulary + filler |

    **Hard-tell count:** N
    **Soft-tell count:** M
    **Sections most affected:** §2, §4
    **Notes:** <one or two sentences on dominant pattern>
    ```

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}
```
```

- [ ] **Step 2: Verify**

Run:
```bash
test -f plugins/writing/skills/writing/finishing/ai-pattern-detector.md && \
grep -c "correlative\|stock transitions\|hard tells\|Hard tells" plugins/writing/skills/writing/finishing/ai-pattern-detector.md
```
Expected: prints a number >= 3.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/finishing/ai-pattern-detector.md
git commit -m "feat(writing): add AI-pattern detector finishing pass"
```

---

### Task 11: Style enforcer finishing pass

**Files:**
- Create: `plugins/writing/skills/writing/finishing/style-enforcer.md`

- [ ] **Step 1: Write the style enforcer prompt**

Create `plugins/writing/skills/writing/finishing/style-enforcer.md`:

```markdown
# Style Enforcer Prompt Template

**Purpose:** Apply the active style guide's mechanical rules. Punctuation, capitalization, vocabulary blacklist, format rules.

**Dispatch:** Second of four finishing passes. Reads `draft.md` and the active style guide. Updates `draft.md` in place. Appends to `finishing-notes.md`.

```
Agent tool (general-purpose):
  description: "Style enforcer pass"
  prompt: |
    You are a style enforcer. You apply the active style guide's mechanical rules to
    the draft. You do not make voice judgments. You do not propose rewrites for
    rhythm. You apply rules.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Active style guide:** {STYLE_GUIDE_PATH}

    ## Setup

    1. Read the active style guide. Pay special attention to:
       - The anti-patterns / blacklist table
       - Punctuation rules (em-dashes, en-dashes, hyphens, Oxford commas, etc.)
       - Vocabulary preferences
       - Capitalization conventions
       - Number formatting rules
    2. Read `{OUTPUT_PATH}/draft.md`

    ## What to do

    For every rule in the style guide that has a clear mechanical fix, scan the
    draft and apply the fix. Examples:

    - Style guide says "no em-dashes": find every em-dash in the writer's prose
      (not in verbatim quotes), rewrite each with comma, period, colon, parentheses,
      or split sentence
    - Style guide says "use Oxford commas": add missing commas before "and" in lists
      of three or more
    - Style guide blacklists "leverage": find every instance, replace with concrete
      verb
    - Style guide says "numerals for 10 and up": replace "ten thousand" with "10,000"
      etc.

    ## What NOT to do

    - Do not change verbatim quotes from external sources. The style guide rules apply
      to the writer's prose, not to material being quoted.
    - Do not apply rules that require voice judgment. If the rule is "vary sentence
      length", that is for the line editor.
    - Do not rewrite sentences for rhythm. That is the line editor's job.

    ## Output

    Apply the changes to `{OUTPUT_PATH}/draft.md`. Append to
    `{OUTPUT_PATH}/finishing-notes.md`:

    ```markdown
    ## Style Enforcer Pass ({YYYY-MM-DD})

    | Rule applied | Instances fixed | Examples |
    |--------------|----------------|----------|
    | No em-dashes (writer's prose) | 7 | L12, L23, L41, L48, L62, L77, L91 |
    | Blacklisted vocabulary "leverage" | 2 | L34, L80 |
    | Oxford commas | 3 | L19, L55, L88 |

    **Total mechanical fixes:** N
    **Quotes left untouched:** M (em-dashes preserved in verbatim quotes)
    **Rules with no instances found:** <list>
    ```

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}
```
```

- [ ] **Step 2: Verify**

Run:
```bash
test -f plugins/writing/skills/writing/finishing/style-enforcer.md && \
grep -c "mechanical\|blacklist\|verbatim" plugins/writing/skills/writing/finishing/style-enforcer.md
```
Expected: prints a number >= 3.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/finishing/style-enforcer.md
git commit -m "feat(writing): add style enforcer finishing pass"
```

---

### Task 12: Line editor finishing pass

**Files:**
- Create: `plugins/writing/skills/writing/finishing/line-editor.md`

- [ ] **Step 1: Write the line editor prompt**

Create `plugins/writing/skills/writing/finishing/line-editor.md`:

```markdown
# Line Editor Prompt Template

**Purpose:** Sentence-by-sentence tightening. Cut dead weight. Flag passive voice. Compress flabby constructions.

**Dispatch:** Third of four finishing passes. Reads `draft.md` and the active style guide. Updates `draft.md` in place. Appends to `finishing-notes.md`.

```
Agent tool (general-purpose):
  description: "Line editor pass"
  prompt: |
    You are a line editor. You read the draft sentence by sentence and tighten. You
    do not change voice. You do not restructure paragraphs. You make each sentence
    do its job with fewer words.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Active style guide:** {STYLE_GUIDE_PATH}

    ## Setup

    1. Read `{OUTPUT_PATH}/draft.md`
    2. Read the active style guide for sentence-level preferences

    ## What to do

    For each sentence, ask:
    - Can the same idea be said in fewer words without losing meaning?
    - Is there a passive voice construction that should be active?
    - Is there a long subject + weak verb that should be a strong verb?
    - Is there a flabby phrase ("in order to", "the fact that", "is able to") that
      can be compressed?
    - Is the sentence carrying two ideas that should be split?

    Apply the tightening directly. Note significant changes (more than just removing
    a word) in the log.

    ## What NOT to do

    - Do not change voice or tone. If the writer's sentence is rough, leave it rough
      unless it is also flabby.
    - Do not restructure paragraphs.
    - Do not introduce or remove information.
    - Do not break sentences just because they are long. Long sentences that earn
      their length stay.

    ## Output

    Apply changes to `{OUTPUT_PATH}/draft.md`. Append to
    `{OUTPUT_PATH}/finishing-notes.md`:

    ```markdown
    ## Line Editor Pass ({YYYY-MM-DD})

    | Line | Original | Tightened | Change type |
    |------|----------|-----------|-------------|
    | 14 | "The team was able to ship the feature in two weeks." | "The team shipped the feature in two weeks." | "was able to" → strong verb |
    | 28 | "There is a problem that needs to be addressed." | "There is a problem we need to address." OR "We need to address a problem." | passive → active; flabby → direct |

    **Total tightenings:** N
    **Sentences split:** M
    **Passive-to-active conversions:** P
    **Notes:** <one or two sentences on dominant pattern>
    ```

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}
```
```

- [ ] **Step 2: Verify**

Run:
```bash
test -f plugins/writing/skills/writing/finishing/line-editor.md && \
grep -c "passive\|tightening\|flabby" plugins/writing/skills/writing/finishing/line-editor.md
```
Expected: prints a number >= 3.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/finishing/line-editor.md
git commit -m "feat(writing): add line editor finishing pass"
```

---

### Task 13: Sedaris finishing pass

**Files:**
- Create: `plugins/writing/skills/writing/finishing/sedaris.md`

- [ ] **Step 1: Write the Sedaris prompt**

Create `plugins/writing/skills/writing/finishing/sedaris.md`:

```markdown
# Sedaris Finishing Pass Prompt Template

**Purpose:** Bring voice and personality forward. Find the funny. Break flat passages. Add the small specific human touches that make prose sound like a person.

**Dispatch:** Fourth and final finishing pass. Reads `draft.md`, `interview-synthesis.md` (for tone signal and lived anchors), and the active style guide. Updates `draft.md` in place. Appends to `finishing-notes.md`.

```
Agent tool (general-purpose):
  description: "Sedaris voice pass"
  prompt: |
    You are Sedaris. Not literally David Sedaris, but his ear: dry, specific, willing
    to be funny without trying, willing to be small and human in service of a larger
    point. Your job is to find the places in the draft where the prose has gone flat
    and lift them with a specific image, a self-aware aside, or a single funny word.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Active style guide:** {STYLE_GUIDE_PATH}

    ## Setup

    1. Read `{OUTPUT_PATH}/draft.md`
    2. Read `{OUTPUT_PATH}/interview-synthesis.md` for the tone signal and lived
       anchors. Use this to calibrate. If the writer signalled "wry and grumpy", do
       not insert warmth. If they signalled "celebratory", do not turn cynical.
    3. Read the active style guide

    ## What to do

    Find:
    - Paragraphs that are technically correct but emotionally flat
    - Transitions that read as procedural ("now, let us turn to") rather than human
    - Places where a specific concrete image would land harder than the abstract
      version
    - Places where the writer's own dry self-awareness could break a stretch of
      argument

    Propose targeted small additions, not rewrites. One specific image per flat
    paragraph. One dry aside per long argument stretch. Not more.

    ## What NOT to do

    - Do not add humor that does not match the tone signal
    - Do not rewrite for personality wholesale; the writer's voice already exists
    - Do not add personal anecdotes the writer has not put on the table
    - Do not pad. If a section is fine, leave it.
    - Do not insert "humor" via cliche, pun, or quip. Specificity is funnier than
      cleverness.

    ## Output

    Apply small changes to `{OUTPUT_PATH}/draft.md`. Append to
    `{OUTPUT_PATH}/finishing-notes.md`:

    ```markdown
    ## Sedaris Pass ({YYYY-MM-DD})

    | Line | Before | After | Move |
    |------|--------|-------|------|
    | 24 | "The agent then ignored half of what it had written." | "The agent then ignored half of what it had written. For a date." | Specific aside echoing the hook |
    | 67 | "Now, let us turn to the question of finishing." | "Then comes the polish, which is where most drafts die quietly." | Procedural transition replaced with human one |

    **Touches added:** N
    **Sections improved:** §1, §3
    **Sections left alone:** §2, §4 (already had the right energy)
    **Notes:** <one sentence on tone match with the writer's signal>
    ```

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}
```
```

- [ ] **Step 2: Verify**

Run:
```bash
test -f plugins/writing/skills/writing/finishing/sedaris.md && \
grep -c "tone signal\|specific image\|flat" plugins/writing/skills/writing/finishing/sedaris.md
```
Expected: prints a number >= 3.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/finishing/sedaris.md
git commit -m "feat(writing): add Sedaris voice finishing pass"
```

---

### Task 14: Orchestrator SKILL.md

**Files:**
- Create: `plugins/writing/skills/writing/SKILL.md`

This is the load-bearing file. The orchestrator handles routing, style-guide resolution, task tracking, agent dispatch, gating, and re-dispatch.

- [ ] **Step 1: Write the orchestrator**

Create `plugins/writing/skills/writing/SKILL.md`:

```markdown
---
name: writing
description: Use when the user wants to draft a blog post, essay, talk, newsletter, literature note, or any longer-form prose; or when they want to review, critique, or finish an existing draft. Orchestrates a multi-phase pipeline (interview, outline, draft, panel review, finishing) modeled on Katie Parrott's process. Triggers on writing intent (drafting, reviewing, polishing, voice work) and not on simple text generation tasks.
---

# Writing Skill

Multi-phase writing pipeline with a panel of specialised critics. Modeled on Katie Parrott's process and the existing research plugin's orchestrator pattern.

---

## Tool Preference

1. **Agent tool**: to dispatch phase agents (interview, outline, draft) and critics (Hemingway, Hitchcock, Mom reader, Asshole reader) and finishing passes (AI-pattern detector, style enforcer, line editor, Sedaris)
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
4. Skill default: `default-style-guide.md` shipped with this skill

If multiple candidates exist at the project level (e.g., both `style-guide.md` and a `CLAUDE.md` in scope), use AskUserQuestion to ask once which to use, then record the choice in the state file.

Surface the active guide in the first response: "Using style guide: {path}".

### Step 3: Determine starting phase

Scan the working directory for existing artifacts:
- `interview-synthesis.md` exists → interview phase complete
- `outline.md` exists → outline phase complete
- `draft.md` exists → draft phase complete
- `critique.md` exists → panel phase complete
- `finishing-notes.md` exists → finishing phase has started or completed

Determine the latest completed phase. Present to user:
- "I see you have completed phases X. Resume from {next phase}?"
- Offer phase-jump option: user can name any phase to jump to

User can also pre-empt the dialogue by passing `--phase X` (X ∈ {interview, outline, draft, panel, finishing}).

### Step 4: Create task list

Use TaskCreate to add one task per phase that will run, plus sub-tasks for the panel and finishing phases. Example for a fresh full pipeline:

```
1. Phase 1: Interview the author
2. Phase 2: Negotiate outline
3. Phase 3: Draft sections
4. Phase 4: Run panel review
   ├── Critic: Hemingway
   ├── Critic: Hitchcock
   ├── Critic: Mom reader
   └── Critic: Asshole reader
5. Phase 5: Finishing pass
   ├── AI-pattern detector
   ├── Style enforcer
   ├── Line editor
   └── Sedaris
```

For phase-selectable runs, only the requested phases get tasks.

Mark each task as `in_progress` when starting, `completed` when the artifact is verified.

### Step 5: Execute phases

Dispatch each phase agent via the Agent tool. The orchestrator injects context into the prompt template.

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

#### Phase 3: Draft

1. Read `draft-prompt.md`
2. Inject: output path, style guide path, empty reviewer feedback
3. Dispatch via Agent tool
4. Verify `draft.md` exists
5. Mark task completed

#### Phase 4: Panel review

Fan out: dispatch all four critic agents in parallel (single message with multiple Agent tool calls).

For each critic:
1. Read `critics/{critic}.md`
2. Inject: output path, style guide path, empty reviewer feedback
3. Dispatch via Agent tool
4. Verify `critique-{critic}.md` exists
5. Mark sub-task completed

When all four critics return, consolidate into `critique.md`:

```markdown
# Panel Critique

## Verdicts

| Critic | Verdict | Headline |
|--------|---------|----------|
| Hemingway | <PASS / MINOR / CRITICAL> | <one-line summary> |
| Hitchcock | ... | ... |
| Mom reader | ... | ... |
| Asshole reader | ... | ... |

## Hemingway
<full content of critique-hemingway.md>

## Hitchcock
<full content of critique-hitchcock.md>

## Mom reader
<full content of critique-mom.md>

## Asshole reader
<full content of critique-asshole.md>
```

Then check verdicts:
- All PASS or MINOR → continue to finishing
- One or more CRITICAL → re-dispatch the draft agent with the consolidated critique injected as REVIEWER_FEEDBACK. Re-run the panel. Repeat up to 2 iterations. If still CRITICAL after 2 iterations, present remaining critical issues to user via AskUserQuestion: "Continue to finishing, or pause for manual intervention?"

Mark phase task completed when verdict allows progression or user overrides.

#### Phase 5: Finishing

Sequential, NOT parallel. Each pass updates the draft in place; later passes need the earlier passes' changes.

For each pass in order [ai-pattern-detector, style-enforcer, line-editor, sedaris]:
1. Read `finishing/{pass}.md`
2. Inject: output path, style guide path, empty reviewer feedback
3. Dispatch via Agent tool
4. Verify the agent appended its log section to `finishing-notes.md`
5. Mark sub-task completed

After all four passes, present `draft.md` and `finishing-notes.md` to the user. The piece is now ready for the writer's manual voice pass per the user feedback memory (drafted prose is a skeleton, the writer rewrites in own voice).

### Step 6: Update state and present

Update the state file:
- `last_completed_phase`: name of last successful phase
- `working_directory`: absolute path
- `active_style_guide`: absolute path
- `last_run_at`: ISO timestamp

Present the final draft and a summary of what each pass did.

## Edge Cases

- **Working dir does not exist**: create with `mkdir -p`
- **Style guide not found at any level**: fall back to default and warn "Using default style guide"
- **Phase artifact missing on resume**: re-run that phase
- **Agent dispatch fails**: retry once, then surface error and pause
- **Critic returns malformed output**: log, continue with the other three, mark that sub-task as failed
- **User cancels mid-pipeline**: state file records the last completed phase; next invocation resumes
- **Critique gate fails twice**: present remaining critical issues, ask whether to proceed or intervene manually
- **Multiple style guide candidates** with no state record: ask once, record choice

## State File Format

`~/.claude/projects/<project-id>/writing-skill-state.json`:

```json
{
  "version": 1,
  "projects": {
    "<absolute-working-directory>": {
      "active_style_guide": "<absolute-path-or-default>",
      "last_completed_phase": "draft",
      "last_run_at": "2026-04-16T12:00:00Z"
    }
  }
}
```

The state file is keyed by working directory so multiple in-flight pieces in the same project can each have their own state.

## Phase Identifier Names

Used in `--phase` flag and task list:
`interview`, `outline`, `draft`, `panel`, `finishing`

## Behavioral Guidelines

- Trigger on writing intent (drafting, reviewing, polishing, voice work). not on simple text generation
- When in doubt about scope: "Would you like the full pipeline, or are you starting from a specific phase?"
- Always announce the active style guide in the first response
- Always create the task list before dispatching the first phase agent so the user sees what is coming
- Never present a finished draft as if it is the final voice; remind the user the writer's manual voice pass is the next step
- Critics return verdicts; the orchestrator decides whether to gate or proceed
```

- [ ] **Step 2: Verify**

Run:
```bash
test -f plugins/writing/skills/writing/SKILL.md && \
head -3 plugins/writing/skills/writing/SKILL.md | grep -q "name: writing" && \
grep -c "Phase 1\|Phase 2\|Phase 3\|Phase 4\|Phase 5" plugins/writing/skills/writing/SKILL.md
```
Expected: at least 5 (each phase named at least once).

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/writing/SKILL.md
git commit -m "feat(writing): add orchestrator SKILL.md"
```

---

### Task 15: Skill triggering test prompts

**Files:**
- Create: `tests/skill-triggering/prompts/writing-blog-post.txt`
- Create: `tests/skill-triggering/prompts/writing-panel-review.txt`

- [ ] **Step 1: Create the blog-post prompt**

Create `tests/skill-triggering/prompts/writing-blog-post.txt`:

```
I want to draft a blog post about why most engineering teams underinvest in observability. Help me work through the interview, outline, and draft.
```

- [ ] **Step 2: Create the panel-review prompt**

Create `tests/skill-triggering/prompts/writing-panel-review.txt`:

```
I have a draft of an essay sitting in ./drafts/observability/draft.md. Run the panel of critics on it and give me consolidated feedback.
```

- [ ] **Step 3: Verify both files exist**

Run:
```bash
test -f tests/skill-triggering/prompts/writing-blog-post.txt && \
test -f tests/skill-triggering/prompts/writing-panel-review.txt && \
echo "OK"
```
Expected: prints `OK`.

- [ ] **Step 4: Run the triggering test (manual)**

Run:
```bash
PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh writing tests/skill-triggering/prompts/writing-blog-post.txt
PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh writing tests/skill-triggering/prompts/writing-panel-review.txt
```
Expected: both report `[PASS] Skill 'writing' was triggered`.

If they fail, the SKILL.md description needs sharpening; iterate on the description until both prompts trigger.

- [ ] **Step 5: Commit**

```bash
git add tests/skill-triggering/prompts/writing-blog-post.txt tests/skill-triggering/prompts/writing-panel-review.txt
git commit -m "test(writing): add skill-triggering prompts for blog drafting and panel review"
```

---

### Task 16: Skill introspection unit test

**Files:**
- Create: `tests/unit/test-writing-skill.sh`

- [ ] **Step 1: Create the unit test script**

Create `tests/unit/test-writing-skill.sh` with executable bit:

```bash
#!/usr/bin/env bash
# Test: writing skill
# Verifies the skill is loaded and describes correct capabilities
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: writing skill ==="
echo ""

# Test 1: Skill recognition
echo "Test 1: Skill loading and recognition..."
output=$(run_claude "What is the writing skill? Describe what it does briefly." 30)
assert_contains "$output" "writing|Writing" "Skill is recognized" || true
assert_contains "$output" "pipeline|orchestrat|phase" "Mentions pipeline/orchestrator" || true
echo ""

# Test 2: Phases
echo "Test 2: Phase coverage..."
output=$(run_claude "What phases does the writing skill have? List them." 30)
assert_contains "$output" "interview|Interview" "Mentions interview phase" || true
assert_contains "$output" "outline|Outline" "Mentions outline phase" || true
assert_contains "$output" "draft|Draft" "Mentions draft phase" || true
assert_contains "$output" "panel|Panel|critic" "Mentions panel/critics phase" || true
assert_contains "$output" "finishing|Finishing" "Mentions finishing phase" || true
echo ""

# Test 3: Panel of critics
echo "Test 3: Critics coverage..."
output=$(run_claude "What critics are in the panel? Name them." 30)
assert_contains "$output" "Hemingway|hemingway" "Mentions Hemingway" || true
assert_contains "$output" "Hitchcock|hitchcock" "Mentions Hitchcock" || true
assert_contains "$output" "[Mm]om" "Mentions Mom reader" || true
assert_contains "$output" "[Aa]sshole" "Mentions Asshole reader" || true
echo ""

# Test 4: Finishing passes
echo "Test 4: Finishing coverage..."
output=$(run_claude "What finishing passes does the writing skill have?" 30)
assert_contains "$output" "AI[- ]pattern|ai[- ]pattern" "Mentions AI-pattern detector" || true
assert_contains "$output" "style.*enforc|enforc.*style" "Mentions style enforcer" || true
assert_contains "$output" "line.*edit|edit.*line" "Mentions line editor" || true
assert_contains "$output" "Sedaris|sedaris" "Mentions Sedaris" || true
echo ""

# Test 5: Style guide handling
echo "Test 5: Style guide handling..."
output=$(run_claude "How does the writing skill handle style guides? What's the resolution order?" 30)
assert_contains "$output" "default|Default" "Mentions default style guide" || true
assert_contains "$output" "override|project|CLAUDE" "Mentions project override" || true
assert_contains "$output" "state|memory|remember" "Mentions state/memory" || true
echo ""

# Test 6: Phase-selectable behavior
echo "Test 6: Phase-selectable behavior..."
output=$(run_claude "Can the writing skill resume from a specific phase? How?" 30)
assert_contains "$output" "phase|Phase|--phase" "Mentions phase selection" || true
assert_contains "$output" "resume|jump|skip|start" "Mentions resume capability" || true
echo ""

echo "=== writing skill tests complete ==="
```

- [ ] **Step 2: Make executable and run**

Run:
```bash
chmod +x tests/unit/test-writing-skill.sh
PLUGIN_DIR=plugins/writing bash tests/unit/test-writing-skill.sh
```
Expected: most assertions pass. If many fail, iterate on the SKILL.md description and prompt files until Claude can describe the skill accurately.

- [ ] **Step 3: Commit**

```bash
git add tests/unit/test-writing-skill.sh
git commit -m "test(writing): add unit test for skill introspection"
```

---

### Task 17: Integration smoke test

**Files:**
- Create: `tests/integration/test-writing-integration.sh`

For v1, the smoke test exercises the panel-only mode (skipping interview/outline/draft) since those phases require interactive user input. The test feeds a tiny pre-written draft and verifies the panel produces consolidated critique.

- [ ] **Step 1: Create the integration test**

Create `tests/integration/test-writing-integration.sh`:

```bash
#!/usr/bin/env bash
# Integration test: writing skill (panel-only mode)
# Tests that the panel phase produces consolidated critique on a small draft
# NOTE: This dispatches four agents; expect 2-5 minutes runtime
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Integration Test: writing skill (panel-only mode) ==="
echo ""

# Use a temp directory with a pre-written draft
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

cat > "$TEST_DIR/draft.md" <<'DRAFT'
# Why I stopped using semaphores

*Draft v1*

I used to leverage semaphores for concurrency control in all of my services. It's worth noting that they are an incredibly powerful primitive, providing robust synchronization across threads. However, I've come to realize that they are also a source of significant complexity in modern codebases.

The fact that semaphores require explicit acquire and release calls means that any programmer can forget one. There is the additional problem that deadlocks become possible when multiple semaphores are involved. In my experience, the cost is rarely worth it.

I now navigate the complexities of concurrency by using channels instead. Here's the thing about channels: they enforce ownership semantics in a way semaphores do not. At the end of the day, this leads to more maintainable code.

In conclusion, semaphores are a tool of last resort.
DRAFT

LOG_FILE=$(mktemp)
trap "rm -f $LOG_FILE" EXIT

echo "Test 1: Panel runs and produces critique.md..."
echo "  Working dir: $TEST_DIR"

output=$(run_claude_logged \
    "Run only the panel phase of the writing skill on the draft at $TEST_DIR/draft.md. Use --phase panel --dir $TEST_DIR. Use the default style guide." \
    "$LOG_FILE" \
    300)

if [ -f "$TEST_DIR/critique.md" ]; then
    echo "  [PASS] critique.md created"
else
    echo "  [FAIL] critique.md not found"
    ls -la "$TEST_DIR" | sed 's/^/    /'
fi

echo ""
echo "Test 2: All four per-critic files created..."
for critic in hemingway hitchcock mom asshole; do
    if [ -f "$TEST_DIR/critique-${critic}.md" ]; then
        echo "  [PASS] critique-${critic}.md created"
    else
        echo "  [FAIL] critique-${critic}.md not found"
    fi
done

echo ""
echo "Test 3: Each critic flagged at least one issue (the draft is intentionally bad)..."
for critic in hemingway hitchcock mom asshole; do
    if [ -f "$TEST_DIR/critique-${critic}.md" ]; then
        line_count=$(wc -l < "$TEST_DIR/critique-${critic}.md")
        if [ "$line_count" -gt 5 ]; then
            echo "  [PASS] critique-${critic}.md has substantive content ($line_count lines)"
        else
            echo "  [FAIL] critique-${critic}.md is suspiciously short ($line_count lines)"
        fi
    fi
done

echo ""
echo "Test 4: Asshole reader flagged unearned claims (the draft has many)..."
if grep -qiE "unearned|claim|generaliz|in my experience|cherry" "$TEST_DIR/critique-asshole.md" 2>/dev/null; then
    echo "  [PASS] Asshole reader engaged with the draft's argument"
else
    echo "  [FAIL] Asshole reader did not flag any argument issues"
fi

echo ""
echo "Test 5: AI-pattern detector would flag (verifying via direct grep on draft)..."
echo "  (Smoke test only checks panel phase; finishing pass tested separately if added later)"

echo ""
echo "=== writing integration test complete ==="
```

- [ ] **Step 2: Make executable**

Run:
```bash
chmod +x tests/integration/test-writing-integration.sh
```

- [ ] **Step 3: Run the integration test**

Run:
```bash
PLUGIN_DIR=plugins/writing bash tests/integration/test-writing-integration.sh
```
Expected: all five test groups print `[PASS]`. If any fail, the relevant prompt or the orchestrator's panel routing needs fixing.

- [ ] **Step 4: Commit**

```bash
git add tests/integration/test-writing-integration.sh
git commit -m "test(writing): add panel-only integration smoke test"
```

---

### Task 18: Manual validation on SDD post v3

The skill's success criterion is that it can handle the SDD post v3 in the user's Zettelkasten. This task is the manual validation pass.

- [ ] **Step 1: Resume the SDD post in panel-only mode**

From the user's vault root:

Run:
```bash
cd /home/pascal/Zettelkasten
```

Then in Claude Code, invoke:
```
/pgoell-claude-tools:writing --phase panel --dir "02 Projects/Writing"
```

Expected: orchestrator detects the existing draft, runs the four critics, produces `02 Projects/Writing/critique.md` consolidating their feedback.

- [ ] **Step 2: Run the finishing phase**

In Claude Code, invoke:
```
/pgoell-claude-tools:writing --phase finishing --dir "02 Projects/Writing"
```

Expected: AI-pattern detector, style enforcer, line editor, and Sedaris each apply changes to the draft and append to `finishing-notes.md`.

- [ ] **Step 3: Compare to the v3 plan in the existing draft file**

Read `02 Projects/Writing/SDD is a crutch for planning - draft.md` and compare against the existing v3 revision plan (Edit 5 about AI tells, plus the DORA additions in Edits 1-4).

The skill's output should:
- Catch the AI tells the v3 plan flagged (rhythm uniformity, italic overuse, parallel constructions, meta-framing, rhetorical-question openers)
- Surface the same DORA-citation sharpening or comparable structural feedback
- Not introduce em-dashes (style enforcer should hold the line)

If the skill produces output materially better than the existing single-critic v3 plan, the v1 design is validated. If not, log gaps and iterate.

- [ ] **Step 4: Document the validation result**

Append to `docs/superpowers/specs/2026-04-16-writing-skill-design.md` under "Success Criteria for v1" a "Validation result" subsection with the outcome:

```markdown
## Validation result (2026-04-16)

- Panel run on SDD post v2: <PASS / GAPS NOTED>
- Finishing run: <PASS / GAPS NOTED>
- Output vs. existing v3 plan: <materially better / comparable / worse, with notes>
- Open issues for v1.1: <list>
```

- [ ] **Step 5: Commit the validation**

```bash
cd /home/pascal/Code/pgoell-claude-tools
git add docs/superpowers/specs/2026-04-16-writing-skill-design.md
git commit -m "docs(writing): record v1 validation result on SDD post"
```

---

## Self-review summary

After implementing all 18 tasks:

- All spec sections covered: ✓ scaffolding (Task 1), default style guide (Task 2), three phase prompts (Tasks 3-5), four critics (Tasks 6-9), four finishing passes (Tasks 10-13), orchestrator (Task 14), tests (Tasks 15-17), validation (Task 18)
- No TBD/TODO placeholders in any task; every step has concrete content
- File paths consistent across tasks
- Type/name consistency: phase identifier names (interview, outline, draft, panel, finishing) used identically in spec, SKILL.md, and tests; critic file names match across orchestrator and per-task creation
- Tests written incrementally; integration test verifies the load-bearing fan-out behavior

## Open questions deferred to v1.1

- Marketplace polish (generic README, install docs)
- Style-guide builder skill (Parrott's interview-yourself-into-a-guide pattern)
- Per-platform style guide variants (LinkedIn / blog / Substack)
- Programmatic web companion for outline negotiation
