# Pyramid Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a standalone pyramid-principle skill inside the writing plugin as a sibling to the existing writing skill, per the spec at `docs/superpowers/specs/2026-04-24-pyramid-principle-skill-design.md`.

**Architecture:** One skill at `plugins/writing/skills/pyramid/` with a five-phase orchestrator (intake, construct, audit, opener, render). Phase 2 is mode-branched (greenfield vs restructure). Phase 3 is a parallel audit panel (MECE / So-What / Q-A Alignment / Inductive-Deductive) with CRITICAL re-dispatch loop. Opener is written last against a stable apex. Mirrors writing skill's orchestrator pattern for dispatch, verdict tokens, and state file conventions.

**Tech Stack:** Claude Code Skill markdown, `Agent` tool for dispatching phase agents, `AskUserQuestion` for intake gates, `TaskCreate`/`TaskUpdate` for visible progress, bash shell tests (`run_claude`, `run_claude_logged`, `assert_contains`).

**Primary references for the executor:**
- Spec: `docs/superpowers/specs/2026-04-24-pyramid-principle-skill-design.md`
- Research: `docs/superpowers/specs/2026-04-24-pyramid-principle-research.md` — contains every named audit, failure mode, worked example, and editorial position. Every prompt file should cite it by section.
- Writing skill (structural model): `plugins/writing/skills/writing/SKILL.md` and its critics in `plugins/writing/skills/writing/critics/`.
- Research plugin (parallel fan-out model): `plugins/research/skills/research/SKILL.md`.

**Branch:** work on `feat/pyramid-skill` (already created, based on `origin/main`). Spec and research doc are already committed on this branch.

---

## File Structure

**Create:**
- `plugins/writing/skills/pyramid/SKILL.md`
- `plugins/writing/skills/pyramid/pyramid-principle-reference.md`
- `plugins/writing/skills/pyramid/construct-greenfield-prompt.md`
- `plugins/writing/skills/pyramid/construct-restructure-prompt.md`
- `plugins/writing/skills/pyramid/opener-prompt.md`
- `plugins/writing/skills/pyramid/audits/mece.md`
- `plugins/writing/skills/pyramid/audits/so-what.md`
- `plugins/writing/skills/pyramid/audits/qa-alignment.md`
- `plugins/writing/skills/pyramid/audits/inductive-deductive.md`
- `tests/unit/test-pyramid-skill.sh`
- `tests/skill-triggering/prompts/pyramid-greenfield-memo.txt`
- `tests/skill-triggering/prompts/pyramid-restructure-memo.txt`
- `tests/skill-triggering/prompts/pyramid-domain-limit-essay.txt`
- `tests/skill-triggering/prompts/pyramid-negative-narrative.txt`
- `tests/skill-triggering/prompts/pyramid-negative-factual.txt`
- `tests/integration/test-pyramid-integration.sh`

**Modify:**
- `.claude-plugin/marketplace.json` — bump writing version 1.2.0 → 1.3.0, extend description
- `plugins/writing/.claude-plugin/plugin.json` — extend description, add keywords (`pyramid`, `minto`, `mece`, `scqa`, `memo`)
- `README.md` — add pyramid skill listing under the writing plugin section

---

### Task 1: Plugin metadata and skill directory scaffolding

**Files:**
- Modify: `.claude-plugin/marketplace.json` (writing plugin entry)
- Modify: `plugins/writing/.claude-plugin/plugin.json`
- Modify: `README.md` (writing section)
- Create: `plugins/writing/skills/pyramid/audits/` (directory)

- [ ] **Step 1: Update marketplace.json**

Replace the writing plugin entry with:

```json
{
  "name": "writing",
  "source": "./plugins/writing",
  "description": "Multi-phase writing pipeline with panel-of-critics review for blog posts, essays, talks, and longer-form prose. Format-aware: Smart-Brevity critic added for memo/newsletter/announcement formats. Also ships a dedicated Pyramid Principle skill (Barbara Minto) for greenfield outline construction or restructuring existing prose into pyramid form.",
  "version": "1.3.0"
}
```

- [ ] **Step 2: Update plugin.json**

Replace `plugins/writing/.claude-plugin/plugin.json` with:

```json
{
  "name": "writing",
  "description": "Multi-phase writing pipeline with panel-of-critics review for blog posts, essays, talks, and longer-form prose. Also ships a dedicated Pyramid Principle skill for memos, recommendations, and analytical documents.",
  "author": {
    "name": "Pascal Kraus"
  },
  "license": "MIT",
  "keywords": ["writing", "blog", "essay", "drafting", "editing", "voice", "pyramid", "minto", "mece", "scqa", "memo"]
}
```

- [ ] **Step 3: Update README.md**

Under the existing `### writing` section (replacing the current `**Skills:**` block), add the pyramid skill line so the section reads:

```markdown
### writing

Multi-phase writing pipeline modelled on Katie Parrott's process. Interview, outline, throughline gate (≤10-word compression), draft, panel review (seven critics including steel-man preemption audit), and finishing passes for blog posts and longer-form prose. Format-aware: opt-in Smart-Brevity critic for memos, newsletters, and announcements. Also ships a dedicated Pyramid Principle skill for memos, recommendations, and analytical documents.

**Skills:**
- `/pgoell-claude-tools:writing`: orchestrates the full pipeline with phase-selectable resume. Ships with a default style guide that any project can override.
- `/pgoell-claude-tools:pyramid`: produces a pyramid-structured outline (greenfield) or restructures an existing draft into pyramid form. Five phases (intake, construct, audit, opener, render) with a parallel audit panel (MECE, So-What, Q-A Alignment, Inductive-Deductive).
```

- [ ] **Step 4: Create the skill directory structure**

Run:
```bash
mkdir -p /home/pascal/Code/pgoell-claude-tools/plugins/writing/skills/pyramid/audits
```

Verify:
```bash
ls -la /home/pascal/Code/pgoell-claude-tools/plugins/writing/skills/pyramid/audits
```
Expected: empty directory, no errors.

- [ ] **Step 5: Commit**

```bash
git add .claude-plugin/marketplace.json plugins/writing/.claude-plugin/plugin.json README.md
git commit -m "feat(pyramid): scaffold plugin metadata for pyramid skill

Bumps writing plugin to 1.3.0; extends description and keywords to
cover the forthcoming pyramid skill. Adds an empty audits/
subdirectory under the new skill path."
```

(The empty directory will show up once content lands in Task 4.)

---

### Task 2: Unit test (TDD scaffold)

Write the test first so the rest of the implementation has a target. Test will fail until Task 11 (SKILL.md) lands; that is the point.

**Files:**
- Create: `tests/unit/test-pyramid-skill.sh`

- [ ] **Step 1: Write the failing test**

Create `tests/unit/test-pyramid-skill.sh` with:

```bash
#!/usr/bin/env bash
# Test: pyramid skill
# Verifies the skill is loaded and describes correct capabilities
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: pyramid skill ==="
echo ""

# Test 1: Skill recognition
echo "Test 1: Skill loading and recognition..."
output=$(run_claude "What is the pyramid skill? Describe what it does briefly." 30)
assert_contains "$output" "pyramid|Pyramid" "Skill is recognized" || true
assert_contains "$output" "Minto|minto" "Mentions Barbara Minto" || true
assert_contains "$output" "outline|restructur|memo|recommendation" "Mentions outline or restructure or memo use case" || true
echo ""

# Test 2: Phases
echo "Test 2: Phase coverage..."
output=$(run_claude "What phases does the pyramid skill have? List them." 30)
assert_contains "$output" "intake|Intake" "Mentions intake phase" || true
assert_contains "$output" "construct|Construct" "Mentions construct phase" || true
assert_contains "$output" "audit|Audit" "Mentions audit phase" || true
assert_contains "$output" "opener|Opener|SCQA" "Mentions opener phase" || true
assert_contains "$output" "render|Render" "Mentions render phase" || true
echo ""

# Test 3: Audit panel
echo "Test 3: Audit panel coverage..."
output=$(run_claude "What audits does the pyramid skill run? Name them." 30)
assert_contains "$output" "MECE|mece" "Mentions MECE audit" || true
assert_contains "$output" "[Ss]o.[Ww]hat|so.what" "Mentions So-What audit" || true
assert_contains "$output" "Q.A [Aa]lignment|alignment" "Mentions Q-A Alignment audit" || true
assert_contains "$output" "[Ii]nductive|[Dd]eductive" "Mentions Inductive/Deductive audit" || true
echo ""

# Test 4: Two construction modes
echo "Test 4: Greenfield and restructure modes..."
output=$(run_claude "What modes does the pyramid skill support? Can it work with an existing draft?" 30)
assert_contains "$output" "greenfield|topic|fresh" "Mentions greenfield/topic mode" || true
assert_contains "$output" "restructur|existing draft|existing prose" "Mentions restructure mode" || true
echo ""

# Test 5: Domain limits gate
echo "Test 5: Domain-limits gate..."
output=$(run_claude "When does the pyramid skill refuse or warn about applying the pyramid? What genres?" 30)
assert_contains "$output" "narrative|essay|exploratory|discovery|emotion" "Mentions at least one non-applicable genre" || true
assert_contains "$output" "domain|gate|warn|refuse|proceed" "Mentions a domain-limits gate or similar" || true
echo ""

# Test 6: Reference file mentioned
echo "Test 6: Reference file..."
output=$(run_claude "What reference material ships with the pyramid skill?" 30)
assert_contains "$output" "pyramid.principle.reference|reference|Minto|pyramid-principle" "Mentions the shipped reference" || true
echo ""

# Test 7: Verdict token semantics
echo "Test 7: Audit verdict semantics..."
output=$(run_claude "What verdict tokens do pyramid audits emit? What happens on CRITICAL?" 30)
assert_contains "$output" "PASS" "Mentions PASS verdict" || true
assert_contains "$output" "MINOR" "Mentions MINOR verdict" || true
assert_contains "$output" "CRITICAL" "Mentions CRITICAL verdict" || true
assert_contains "$output" "re.dispatch|re.run|iteration|construct" "Mentions the re-dispatch loop on CRITICAL" || true
echo ""

# Test 8: Phase-selectable behavior
echo "Test 8: Phase-selectable behavior..."
output=$(run_claude "Can the pyramid skill resume from a specific phase? How?" 30)
assert_contains "$output" "phase|Phase|--phase" "Mentions phase selection" || true
assert_contains "$output" "resume|jump|skip|start" "Mentions resume capability" || true
echo ""

echo "=== pyramid skill tests complete ==="
```

- [ ] **Step 2: Make it executable and verify it fails**

```bash
chmod +x tests/unit/test-pyramid-skill.sh
PLUGIN_DIR=plugins/writing bash tests/unit/test-pyramid-skill.sh 2>&1 | tail -30
```

Expected: many `[FAIL]` lines because the pyramid skill does not exist yet. This is TDD — the failures are the target to eliminate.

- [ ] **Step 3: Commit**

```bash
git add tests/unit/test-pyramid-skill.sh
git commit -m "test(pyramid): add unit test for skill recognition and capabilities

Covers skill loading, five phases, four audits, two modes, domain-limits
gate, reference file, verdict semantics, and phase-selectable resume.
Fails at this point; passes after SKILL.md lands."
```

---

### Task 3: Shipped reference file — pyramid-principle-reference.md

The skill ships with a condensed reference that audit and construct prompts cite by section. It is distilled from the research report but scoped to what prompts actually need: named audit questions, failure-mode lists, worked-example skeletons, domain-limits catalogue.

**Files:**
- Create: `plugins/writing/skills/pyramid/pyramid-principle-reference.md`

- [ ] **Step 1: Write the reference file**

Create `plugins/writing/skills/pyramid/pyramid-principle-reference.md` with the following structure. Pull the body content from `docs/superpowers/specs/2026-04-24-pyramid-principle-research.md` sections 1–11; every heading in the reference file should have a `[research §N]` anchor back to the research doc.

```markdown
# Pyramid Principle Reference

Condensed operational reference shipped with the pyramid skill. Every phase prompt can cite this file by section. Full research is at `docs/superpowers/specs/2026-04-24-pyramid-principle-research.md` in the repo.

## 1. The Three Rules [research §1]

1. **Summation.** Each non-leaf node is a finding, not a label. "Revenue grew 23% because of new SKUs" not "Three reasons revenue grew."
2. **Homogeneity.** Siblings are the same kind of idea at the same level of abstraction; one plural noun names the group (reasons, steps, risks, recommendations, causes).
3. **Logical Ordering.** Siblings are ordered chronologically, structurally, comparatively, or deductively. Arbitrary order signals a non-grouping.

## 2. The SCQA Opener [research §2]

External name: SCQA. Internal treatment: SCQ opens, Answer is the apex.

- **S (Situation):** noncontroversial context the reader already agrees with.
- **C (Complication):** the change making S unstable; identifies a cause, not a symptom.
- **Q (Question):** the falsifiable question C forces.
- **A (Answer):** the apex; the pyramid's top.

### The SCQA Opener Audit (four questions)
1. Would the intended reader nod at S without friction?
2. Does C identify a cause, not restate the symptom?
3. Does Q arise from C such that C without Q feels incomplete?
4. Would changing A also require changing C? If not, the opener is decorative.

### Three failure modes
- **Manufactured complication:** SCQA forced onto a document with no real trigger.
- **Question that restates the answer:** "How should we grow revenue?" paired with "By growing revenue."
- **Answer-first bleed:** writer leads with conclusion, backfills S to justify it.

## 3. The Q-A Dialogue Procedure [research §3]

Top-down procedure for greenfield construction:
1. State the Subject.
2. Define Reader and the Question you expect them to have.
3. State the Answer (the governing thought, the apex).
4. Work backwards to write the Situation.
5. Develop the Complication that triggers the Question.
6. Verify S+C produces Q and Q is answered by A.
7. Drop below A: ask "what question does A raise for this reader?" Children answer that one question.
8. Recurse: each new node raises a question the layer below must answer.

### The Q-A Alignment Audit
1. For each non-leaf node, name the question it raises.
2. Verify the grouping below it answers that question as a whole.
3. If children answer different questions, Rule 2 (Homogeneity) fails and Rule 1 (Summation) fails.

## 4. The Four MECE Audit Questions [research §4]

1. Does each sibling directly answer the parent's question? (CE of parent.)
2. Do any two siblings cover the same ground under different labels? (ME overlap.)
3. Is there an obvious case the grouping skips? (CE gap.)
4. Does reordering change meaning? (If yes, must then pass Rule 3 logical order.)

### Failed-grouping examples
- **Overlap:** "Millennials / Online shoppers" (a person can be both).
- **Gap:** "Under 18 / 18-35 / 36-65" (leaves out over 65).
- **Overlap and gap:** "Digital / Retail / B2B sales" (online B2B is in two, licensing missing).
- **Category mismatch:** Fish Sticks under "Baked."
- **Same-thing-twice:** "Plan your pipeline / Build your editorial calendar."

MECE is a direction, not a threshold. A grouping that is MECE relative to the parent's question passes, even if it is not MECE against a Platonic taxonomy.

## 5. Vertical vs Horizontal Logic (Inductive vs Deductive) [research §5]

- **Inductive:** siblings are members of a class; one plural noun names them.
- **Deductive:** siblings are argumentative steps connected by "therefore."

### The Inductive-or-Deductive Audit
1. What plural noun names this group? If answerable, inductive.
2. Can I read this as "X, therefore Y, therefore Z"? If yes, deductive.
3. If I delete one sibling, does the conclusion still hold? Survives = inductive; dies = deductive.

**Position:** default to inductive at every level above the leaves. Use deductive only where a causal chain is load-bearing.

## 6. The So-What Test and the Why-Is-That-True Test [research §6]

### The So-What / Why Chain
1. Ask "so what?" upwards at every internal node: does the summary earn its place, or is it a category label?
2. Ask "why is that true?" downwards: do children supply evidence or restate the parent?
3. If both fail, the node is a ghost; delete and regroup.

### The Caveman Answer Test
Can the position reduce to "Good or Bad? Happy or Sad?"? If not, the core message lacks clarity.

## 7. The Reverse-Engineering Procedure [research §7]

Mode B (restructure) procedure, steps 1-7 for construction (steps 8 and 9 are handled by the opener and render phases):
1. **Extract.** List every assertion in the draft as a one-line bullet.
2. **Cluster.** Group bullets that answer the same implicit question; tentatively name each cluster.
3. **Name the governing thought** for each cluster in one sentence. Ban category-label summaries.
4. **Identify the governing thought of the whole.** If not in the draft, the draft was exploring, not concluding.
5. **Test with MECE.** Run Section 4's audit questions on the top-level grouping.
6. **Test with Q-A alignment.** Does each cluster's governing thought answer a question the apex raises?
7. **Sequence.** Pick one of chronological / structural / comparative / deductive.

Prose signs a draft needs this procedure:
- Conclusion appears in paragraph 3 or later (buried lede).
- Opening is throat-clearing without a complication.
- Argument shifts mid-document.
- Summary sentences are labels rather than findings.

## 8. Grouping Size [research §8]

Default 3. Ceiling 5. **Six or more items is a MECE-failure signal** until proven otherwise. Also flag: a lone subsection under a parent means the parent was either trivial or not a grouping.

## 9. Failing-Pyramid Diagnostics [research §9]

| Prose Symptom | Logic Cause | Repair |
|---|---|---|
| Buried lede | Apex not stated first | Promote Answer |
| Throat-clearing opener | Manufactured complication | SCQA Opener Audit |
| Category-label summaries | Intellectually blank node | So-What Test |
| Two sections covering same ground | ME failure | MECE Audit Q2 |
| Obvious topic missing | CE failure | MECE Audit Q3 |
| Section does not answer implied question | Q-A alignment failure | Q-A Alignment Audit |
| Argument shifts mid-document | Mid-draft pivot | Rerun Reverse-Engineering Procedure |
| Weak claim nobody would challenge | Apex is a truism | Caveman Answer Test |
| Claim with no evidence beneath | Why-Is-That-True failure | Add children or cut |
| Lone subsection under parent | Parent is not a grouping | Collapse parent or find siblings |

## 10. Worked Before/After Examples [research §10]

(Full examples in the research doc section 10. Retained here as few-shot anchors.)

### 10.1 Launch-delay memo
- **Before:** buried lede, "push launch" in paragraph 3.
- **After:** apex first ("Push launch to March 15"), three reasons, next actions.

### 10.2 Churn memo
- **Before:** ordered by evidence shape (charts, correlations).
- **After:** ordered by reasons-to-act (severity, coverage gap, readiness).

### 10.3 Raise request
- **Before:** category labels ("more clients, new team, critical thinking").
- **After:** So-What-promoted outcomes (revenue, capacity, decision velocity).

## 11. Domain Limits: When NOT to Use the Pyramid [research §11]

**Works for:** executive memos, recommendation decks, problem-solution one-pagers, analytical reports, case-interview answers, project proposals, incident postmortems.

**Does not work for:** narrative longform, personal essays building to a realisation, exploratory or discovery documents, emotionally-driven persuasion, creative writing, in-progress thinking, pedagogical walk-throughs. Writers of these genres should be routed to the writing skill instead.
```

- [ ] **Step 2: Verify the file reads correctly**

```bash
wc -l plugins/writing/skills/pyramid/pyramid-principle-reference.md
head -40 plugins/writing/skills/pyramid/pyramid-principle-reference.md
```
Expected: ~200 lines, readable markdown.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/pyramid/pyramid-principle-reference.md
git commit -m "feat(pyramid): add shipped reference with named audits and worked examples

Condensed operational reference that phase prompts cite by section
number. Distilled from the research doc at
docs/superpowers/specs/2026-04-24-pyramid-principle-research.md —
same material, tighter form, colocated with the skill so prompts
do not need to reach into docs/."
```

---

### Task 4: MECE audit prompt

**Files:**
- Create: `plugins/writing/skills/pyramid/audits/mece.md`

- [ ] **Step 1: Write the prompt file**

Create `plugins/writing/skills/pyramid/audits/mece.md`:

````markdown
# MECE Auditor Agent Prompt Template

**Purpose:** Run the Four MECE Audit Questions against a pyramid's groupings and emit a verdict (PASS / MINOR ISSUES / CRITICAL ISSUES). Fourth-prompt-file-in-the-panel — dispatched in parallel alongside so-what, qa-alignment, and inductive-deductive.

**Dispatch:** One of four audit agents in Phase 3. Reads `construction.md` and the shipped reference. Writes `audit-mece.md`.

```
Agent tool (general-purpose):
  description: "Run MECE audit on pyramid groupings"
  prompt: |
    You are a MECE auditor. Your job is to verify that each grouping in a
    pyramid structure is Mutually Exclusive and Collectively Exhaustive
    relative to the question the parent node raises. You do NOT write prose,
    you do NOT fix the pyramid, you identify issues and emit a verdict.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Reference path:** {REFERENCE_PATH}

    ## Setup

    1. Read `{OUTPUT_PATH}/construction.md` for the pyramid to audit.
    2. Read `{OUTPUT_PATH}/restructure-notes.md` if present (Mode B).
    3. Read `{REFERENCE_PATH}` section 4 (The Four MECE Audit Questions) for
       the exact question form and failed-grouping examples.

    ## The Four MECE Audit Questions

    Apply each question to every grouping in the pyramid (top-level siblings
    and any sub-groupings):

    1. Does each sibling directly answer the parent's question? (CE of parent.)
    2. Do any two siblings cover the same ground under different labels? (ME overlap.)
    3. Is there an obvious case the grouping skips? (CE gap.)
    4. Does reordering change meaning? (If yes, validate against logical order.)

    MECE is a direction, not a Platonic threshold. A grouping is MECE enough if
    it is MECE relative to the parent's question.

    ## Failure mode catalogue (from reference section 4)

    When you name a problem, match it to the catalogue:
    - **Overlap:** siblings covering same ground under different labels.
    - **Gap:** obvious case missing.
    - **Overlap-and-gap:** both present.
    - **Category mismatch:** a sibling belongs to a different axis than the group.
    - **Same-thing-twice:** two phrasings of the same activity.

    Also flag, per reference section 8:
    - **Oversized grouping:** 6+ siblings. Run MECE Qs 2 and 3 before defending the size.
    - **Lone subsection:** a parent with exactly one child is not a grouping.

    ## Output format

    Write to `{OUTPUT_PATH}/audit-mece.md`:

    ```markdown
    **Verdict:** PASS | MINOR ISSUES | CRITICAL ISSUES

    ## Findings

    1. <issue> — <citation back to construction.md node path, e.g. "apex → sibling 2">
    2. ...

    ## Recommended repairs

    - <specific repair addressing finding N>
    - ...

    ## Reference

    Applied audit questions from pyramid-principle-reference.md section 4.
    ```

    ## Verdict rules

    - **CRITICAL ISSUES:** any top-level grouping fails MECE (overlap, gap, or
      both). These cannot be repaired without reconstructing the grouping.
    - **MINOR ISSUES:** sub-grouping MECE violations, oversized groupings that
      have a defensible reason, lone subsections.
    - **PASS:** every grouping passes all four audit questions against its parent.

    The first whitespace-delimited token of the Verdict line must be one of
    PASS, MINOR, or CRITICAL (the orchestrator matches on that token only).

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}

    If reviewer feedback is provided above, treat it as context: the construct
    phase has re-run and you are re-auditing. Focus on whether the previously
    flagged CRITICAL issues are resolved; surface anything that is still broken.
```
````

- [ ] **Step 2: Verify the file is syntactically well-formed**

```bash
grep -c "^```" plugins/writing/skills/pyramid/audits/mece.md
```
Expected: `5` (three code fences open + three close = 6, minus the closing one on the outer wrapper... actually count: outer fence open (line 1 after Dispatch), outer close (end), nested "markdown" open, nested "markdown" close = 4. Adjust expectation to `4`.)

Actually the cleaner check:

```bash
python3 -c "import sys; content = open('plugins/writing/skills/pyramid/audits/mece.md').read(); opens = content.count('\`\`\`'); print(f'fence count: {opens} (should be even)'); sys.exit(0 if opens % 2 == 0 else 1)"
```
Expected: even fence count, exit 0.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/pyramid/audits/mece.md
git commit -m "feat(pyramid): add MECE audit prompt

Implements the Four MECE Audit Questions from the reference doc against
pyramid groupings. Emits PASS/MINOR/CRITICAL verdict. CRITICAL means a
top-level grouping failed; orchestrator re-dispatches construct with
feedback. Catalogue of failure modes (overlap, gap, category mismatch,
same-thing-twice, oversized grouping, lone subsection) inlined so
the agent can name problems precisely."
```

---

### Task 5: So-What audit prompt

**Files:**
- Create: `plugins/writing/skills/pyramid/audits/so-what.md`

- [ ] **Step 1: Write the prompt file**

Create `plugins/writing/skills/pyramid/audits/so-what.md` following the same template as the MECE audit (Task 4), adapted to:

- **Purpose:** run the So-What / Why Chain and the Caveman Answer Test on every node
- **Reference sections:** 6 (So-What Test, Why-Is-That-True Test, Caveman Answer Test, the chain)
- **What the auditor looks for:**
  - At every non-leaf node: does the summary earn its place, or is it a category label? (Apply So-What Test)
  - At every node with children: do children supply evidence, or restate the parent? (Apply Why-Is-That-True Test)
  - At the apex: can the position reduce to "Good or Bad? Happy or Sad?" (Caveman Answer Test)
- **Failure modes to name:**
  - **Intellectually blank node:** summary is a label ("three reasons...") not a finding
  - **Evidence-restates-parent:** children paraphrase the summary instead of supporting it
  - **Truism apex:** Caveman Answer Test produces "Both good AND bad, depends" (failed compression)
- **Verdict rules:**
  - **CRITICAL:** apex fails Caveman Answer Test OR three or more nodes fail So-What
  - **MINOR:** a leaf's evidence is weak OR one non-leaf node is intellectually blank
  - **PASS:** all non-leaf nodes earn their place; apex compresses cleanly
- **Output file:** `audit-so-what.md`

Include the GLOBIS raise-request example from reference section 10.3 inline as a one-shot so the agent pattern-matches against a clean So-What chain: "Brought in more clients → boosted company revenue; built new team → aligned with mission; upgraded critical thinking → enabled faster work."

Use the same `**Verdict:**` line format, the same `{OUTPUT_PATH}` / `{REFERENCE_PATH}` / `{REVIEWER_FEEDBACK}` placeholders, and the same nested-code-fence structure as the MECE audit.

- [ ] **Step 2: Verify even fence count**

```bash
python3 -c "content = open('plugins/writing/skills/pyramid/audits/so-what.md').read(); opens = content.count('\`\`\`'); import sys; sys.exit(0 if opens % 2 == 0 else 1)"
```

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/pyramid/audits/so-what.md
git commit -m "feat(pyramid): add So-What audit prompt

Runs the So-What Test, Why-Is-That-True Test, and Caveman Answer Test
against every node. Flags intellectually-blank category-label summaries,
children-that-restate-parent, and truism apexes. GLOBIS raise-request
example inlined as a clean-chain one-shot."
```

---

### Task 6: Q-A Alignment audit prompt

**Files:**
- Create: `plugins/writing/skills/pyramid/audits/qa-alignment.md`

- [ ] **Step 1: Write the prompt file**

Create `plugins/writing/skills/pyramid/audits/qa-alignment.md` following the template, adapted to:

- **Purpose:** for each non-leaf node, name the question the node raises; verify the children answer that question as a grouping
- **Reference section:** 3 (The Q-A Alignment Audit)
- **The three audit steps:**
  1. For each non-leaf node, name the question it raises
  2. Verify the grouping below answers that question as a whole, not as a sum of children answering different questions
  3. If children answer different questions, Rule 2 (Homogeneity) fails and Rule 1 (Summation) fails
- **Failure modes:**
  - **Orphan child:** a sibling answers a different question than the parent raises
  - **Unnamed question:** the auditor cannot articulate the question the node raises (node is a label, not a finding)
  - **Heterogeneous grouping:** siblings each answer a different sub-question; no single plural noun names them
- **Verdict rules:**
  - **CRITICAL:** the apex's question cannot be named OR three or more non-leaf nodes have unnamed questions
  - **MINOR:** one heterogeneous sub-grouping OR one orphan child in an otherwise coherent grouping
  - **PASS:** every non-leaf node has a nameable question and its children answer it coherently
- **Output file:** `audit-qa.md`

Include a worked example in the prompt body: apex "We should raise Series B in Q1 2027" raises the reader question "should we raise now or wait?"; the three siblings must all answer that question (not "is this a good round?" or "what's our runway?" — those are different questions).

- [ ] **Step 2: Verify and commit**

```bash
python3 -c "content = open('plugins/writing/skills/pyramid/audits/qa-alignment.md').read(); opens = content.count('\`\`\`'); import sys; sys.exit(0 if opens % 2 == 0 else 1)"
git add plugins/writing/skills/pyramid/audits/qa-alignment.md
git commit -m "feat(pyramid): add Q-A Alignment audit prompt

For each non-leaf node, names the question the node raises and checks
whether children answer that specific question as a coherent grouping.
Flags orphan children, unnamed-question nodes, and heterogeneous
groupings. Worked example (Series B apex) inlined."
```

---

### Task 7: Inductive/Deductive audit prompt

**Files:**
- Create: `plugins/writing/skills/pyramid/audits/inductive-deductive.md`

- [ ] **Step 1: Write the prompt file**

Create `plugins/writing/skills/pyramid/audits/inductive-deductive.md`, adapted to:

- **Purpose:** classify every grouping as inductive or deductive; flag mixed groupings or deductive-pretending-to-be-inductive chains
- **Reference section:** 5 (Vertical vs Horizontal Logic)
- **The three audit questions:**
  1. What plural noun names this group? If answerable, inductive.
  2. Can I read this as "X, therefore Y, therefore Z"? If yes, deductive.
  3. If I delete one sibling, does the conclusion still hold? Survives = inductive; dies = deductive.
- **Editorial position** (from reference section 5, inlined in the prompt): default to inductive at every level above the leaves. Use deductive only when a causal chain is load-bearing.
- **Failure modes:**
  - **Mixed grouping:** some siblings are class members, others are argument steps
  - **Fragile deductive chain:** deductive structure used where one weak link collapses the conclusion
  - **Narrative-masquerading-as-deductive:** siblings ordered chronologically pretending to be "therefore" steps (e.g. "We did A, then we did B, then we did C" is not an argument)
- **Verdict rules:**
  - **CRITICAL:** apex-level grouping is mixed (inductive and deductive siblings under the same parent) OR a deductive chain at the apex has a fragile link
  - **MINOR:** a sub-grouping is mixed OR uses deductive where inductive would be safer
  - **PASS:** every grouping is clearly one or the other and the default-inductive guideline is respected unless justified
- **Output file:** `audit-logic.md`

Include a contrast example in the prompt body: *"Three reasons revenue dropped: lost enterprise deal, SKU churn, seasonal softness"* is inductive (plural noun: reasons). *"All public venues suffer pandemic effects. Restaurants are public venues. Therefore restaurants suffer pandemic effects"* is deductive. A grouping that is "We started the project in Q1 / hired in Q2 / launched in Q3" is neither — it is a timeline, not a grouping; flag it.

- [ ] **Step 2: Verify and commit**

```bash
python3 -c "content = open('plugins/writing/skills/pyramid/audits/inductive-deductive.md').read(); opens = content.count('\`\`\`'); import sys; sys.exit(0 if opens % 2 == 0 else 1)"
git add plugins/writing/skills/pyramid/audits/inductive-deductive.md
git commit -m "feat(pyramid): add Inductive/Deductive classification audit

Classifies every grouping as inductive (class membership, plural noun)
or deductive (therefore chain). Flags mixed groupings, fragile deductive
chains, and narrative-masquerading-as-deductive. Editorial default:
inductive at every non-leaf unless the causal chain is load-bearing.
Contrast examples (revenue/pandemic/timeline) inlined."
```

---

### Task 8: Construct-greenfield prompt

**Files:**
- Create: `plugins/writing/skills/pyramid/construct-greenfield-prompt.md`

- [ ] **Step 1: Write the prompt file**

Create `plugins/writing/skills/pyramid/construct-greenfield-prompt.md`:

````markdown
# Construct (Greenfield) Agent Prompt Template

**Purpose:** Build a pyramid from scratch using Minto's Q-A Dialogue Procedure. Mode A of the construct phase. The alternative is `construct-restructure-prompt.md` (Mode B, for existing drafts).

**Dispatch:** Phase 2 agent when `mode == greenfield`. Reads `intake.md` and the shipped reference. Writes `construction.md` in the shared schema that phases 3-5 expect.

```
Agent tool (general-purpose):
  description: "Build pyramid top-down (greenfield)"
  prompt: |
    You are a pyramid construction agent operating in greenfield mode.
    You build a pyramid from a topic and audience using Minto's top-down
    Q-A Dialogue Procedure. You do NOT write prose; you produce a structured
    pyramid the audit phase will then validate.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Reference path:** {REFERENCE_PATH}
    - **Today's date:** {YYYY-MM-DD}

    ## Setup

    1. Read `{OUTPUT_PATH}/intake.md` for topic, audience, reader question, genre.
    2. Read `{REFERENCE_PATH}` — especially sections 1 (three rules), 3 (Q-A
       Dialogue Procedure), 5 (Inductive default), and 8 (grouping size).

    ## The Q-A Dialogue Procedure (execute in order)

    1. State the **Subject** in one sentence, drawing on intake.md.
    2. Define the **Reader** and the **Question** you expect them to have.
       Use the `reader_question` from intake.md; if absent, propose one.
    3. State the **Answer** — the governing thought, the apex, one sentence.
       This is a finding, not a label. ("We should raise Series B in Q1 2027,"
       not "Thoughts on the Series B.")
    4. Work backwards to the **Situation** — the first noncontroversial fact
       for this reader that makes the Question inevitable.
    5. Develop the **Complication** — the change making the Situation
       unstable; identifies a cause, not a symptom.
    6. Verify S + C produces Q, and that Q is answered by A. Revise if not.
    7. Drop below A: ask *"what question does A raise for this reader?"*
       Write 3-5 siblings that answer that one question. Default to inductive
       grouping: siblings are members of a class nameable with one plural
       noun (reasons, risks, steps, recommendations, causes).
    8. For each sibling, recurse: ask what question the sibling raises and
       write its evidence or sub-siblings. Stop at one or two tiers below
       the top-level siblings unless intake indicates a deeper piece.

    ## Discipline rules

    - **Apex is a finding, never a label.** "Three reasons to act" is forbidden;
      state the conclusion itself.
    - **3 siblings default, 5 ceiling.** If you are tempted to write 6+, apply
      the MECE questions from reference section 4 against your siblings first;
      consolidate overlaps.
    - **Inductive by default.** If you are writing a deductive (therefore) chain,
      justify it in a comment line; otherwise rewrite as inductive.
    - **SCQA later.** Do NOT generate the SCQA opener yet. Phase 4 does that
      against a stable apex. Your output is structure, not opening prose.

    ## Output format

    Write to `{OUTPUT_PATH}/construction.md`:

    ```markdown
    # Pyramid (construction)

    **Mode:** greenfield
    **Apex (governing thought):** <one sentence, a finding>
    **Reader question:** <the question the apex answers>
    **Top-level grouping noun:** <plural noun: reasons | steps | risks | recommendations | causes | ...>
    **Top-level logic:** inductive | deductive

    ## Subject
    <one sentence>

    ## Reader
    <who is reading this and why>

    ## Siblings

    ### 1. <Finding 1 (not a label)>
    - Evidence: <one-line evidence>
    - Evidence: <one-line evidence>
    - Sub-grouping (optional):
      - <child finding>
        - evidence: <...>

    ### 2. <Finding 2>
    - Evidence: <...>
    - Evidence: <...>

    ### 3. <Finding 3>
    - Evidence: <...>
    - Evidence: <...>
    ```

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}

    If reviewer feedback is provided above, the audit phase flagged CRITICAL
    issues with the previous construction. Read `{OUTPUT_PATH}/construction.md`
    and `{OUTPUT_PATH}/audit-summary.md`, address the specific CRITICAL issues
    (MECE gaps or overlaps, Q-A alignment failures, intellectually blank nodes,
    mixed inductive/deductive groupings), and update construction.md in place.
    Do NOT start from scratch; preserve working siblings and fix what is broken.
```
````

- [ ] **Step 2: Verify and commit**

```bash
python3 -c "content = open('plugins/writing/skills/pyramid/construct-greenfield-prompt.md').read(); opens = content.count('\`\`\`'); import sys; sys.exit(0 if opens % 2 == 0 else 1)"
git add plugins/writing/skills/pyramid/construct-greenfield-prompt.md
git commit -m "feat(pyramid): add greenfield construction prompt

Phase 2 Mode A. Implements Minto's Q-A Dialogue Procedure top-down:
subject → reader question → apex → situation → complication → verify
→ recurse. Discipline rules baked in: apex-as-finding, 3-default-5-cap,
inductive default, SCQA deferred to phase 4. Output schema is shared
with restructure mode so phases 3-5 are mode-agnostic."
```

---

### Task 9: Construct-restructure prompt

**Files:**
- Create: `plugins/writing/skills/pyramid/construct-restructure-prompt.md`

- [ ] **Step 1: Write the prompt file**

Create `plugins/writing/skills/pyramid/construct-restructure-prompt.md` following the same template shape as the greenfield prompt (Task 8), adapted to:

- **Purpose:** Mode B. Reverse-engineer a pyramid from an existing draft using reference section 7's procedure.
- **Reference sections to cite:** 7 (Reverse-Engineering Procedure), 4 (MECE), 3 (Q-A Alignment), 9 (Diagnostics table).
- **Setup reads:** `intake.md`, `draft.md` (the user's original prose), the shipped reference.
- **Procedure** (execute in order — this is steps 1-7 of reference section 7; steps 8 and 9 are deferred to phases 4 and 5):
  1. **Extract.** List every assertion in the draft as a one-line bullet. Do not interpret; just list.
  2. **Cluster.** Group bullets that answer the same implicit question; tentatively name each cluster.
  3. **Name the governing thought** for each cluster in one sentence. Ban category-label summaries (apply So-What Test).
  4. **Identify the apex.** Read your cluster names; look for the one sentence the whole draft is trying to say. If it is not in the draft at all, the draft was exploring rather than concluding; record this in `restructure-notes.md` under "Apex discovery."
  5. **MECE-check the top-level grouping.** Apply the Four MECE Audit Questions; consolidate overlaps and name gaps.
  6. **Q-A-alignment-check.** Does each cluster's governing thought answer a question the apex raises? If not, either promote the cluster's question to a sibling or cut the cluster (record cuts in `restructure-notes.md`).
  7. **Sequence.** Apply Rule 3: pick one of chronological / structural / comparative / deductive.
- **Two output files:**
  - `construction.md` — same schema as greenfield, with `**Mode:** restructure` at the top
  - `restructure-notes.md` — a plaintext log of what was extracted, clustered, cut, and why
- **Reviewer feedback handling:** same as greenfield.

The prompt should also enumerate the "prose signs a draft needs this procedure" from reference section 7 as a one-line pre-flight the agent does before extracting (so it can note in `restructure-notes.md` whether the draft has a buried lede, throat-clearing opener, mid-document argument shift, or label-not-finding summaries).

Output schema for `restructure-notes.md`:

```markdown
# Restructure Notes

## Prose-level symptoms observed
- [buried lede | throat-clearing opener | mid-document pivot | label summaries | ...]

## Extracted assertions
- <bullet 1>
- <bullet 2>
- ...

## Clusters
### Cluster A (tentative name)
- assertion 1
- assertion 2
Governing thought: <one sentence>

### Cluster B
...

## Apex discovery
<Where the apex was found in the draft, or "Not present; inferred from clusters">

## Cuts
- <cluster or assertion> — <why cut>
```

- [ ] **Step 2: Verify and commit**

```bash
python3 -c "content = open('plugins/writing/skills/pyramid/construct-restructure-prompt.md').read(); opens = content.count('\`\`\`'); import sys; sys.exit(0 if opens % 2 == 0 else 1)"
git add plugins/writing/skills/pyramid/construct-restructure-prompt.md
git commit -m "feat(pyramid): add restructure construction prompt

Phase 2 Mode B. Implements reference section 7's Reverse-Engineering
Procedure steps 1-7 (extract, cluster, name governing thought, find
apex, MECE-check, Q-A-align, sequence). Writes construction.md in
the shared schema plus restructure-notes.md recording cuts and apex
discovery. Pre-flight flags prose-level symptoms from reference
section 9's diagnostic table."
```

---

### Task 10: Opener prompt

**Files:**
- Create: `plugins/writing/skills/pyramid/opener-prompt.md`

- [ ] **Step 1: Write the prompt file**

Create `plugins/writing/skills/pyramid/opener-prompt.md` following the template, adapted to:

- **Purpose:** Phase 4. Compose an SCQA opener against a stable apex. Written LAST so the writer does not force the pyramid to fit a premature opener.
- **Reference section:** 2 (The SCQA Opener; The SCQA Opener Audit; three failure modes).
- **Setup reads:** `construction.md` (for apex and reader question), `audit-summary.md` (for any MINOR flags to respect during composition), shipped reference.
- **Procedure:**
  1. Read the apex from `construction.md`.
  2. Identify the reader and the reader question (from construction.md / intake.md).
  3. Write Situation — noncontroversial, friction-free for this reader.
  4. Write Complication — identifies a CAUSE, not a symptom.
  5. Write Question — the falsifiable question the Complication forces.
  6. Verify Answer in construction.md answers that Question.
  7. Apply the four SCQA Opener Audit questions against your draft:
     - Would the reader nod at S without friction?
     - Does C identify a cause?
     - Does Q arise from C?
     - Would changing A require changing C?
  8. If any audit question fails AND the apex cannot support a clean SCQA (no genuine complication exists, or C would be manufactured), emit a **MISMATCH** verdict instead of a valid opener.
- **Failure modes to flag via MISMATCH:**
  - Manufactured complication (no genuine change to point to)
  - Question that restates the apex
  - Answer-first bleed (S would be fabricated to justify A)
- **Output format** (two cases):

For PASS (no verdict line needed):

```markdown
# Opener (SCQA)

**Situation:** <S>
**Complication:** <C>
**Question:** <Q>
**Answer:** <A, matches construction.md apex verbatim>

## Rendered

<one paragraph: S sentence, C sentence, Q sentence, A sentence>
```

For MISMATCH:

```markdown
**Verdict:** MISMATCH

## Reason
<one paragraph explaining which audit question failed and why the apex cannot support a clean SCQA. Be specific about which failure mode applies: manufactured complication, question-restates-answer, or answer-first-bleed.>

## Partial opener (for degraded render)
**Situation:** <S or "N/A">
**Answer:** <apex, unchanged>

(C and Q omitted because they would be manufactured.)
```

The orchestrator matches `**Verdict:** MISMATCH` on the first whitespace-delimited token after `Verdict:` and routes to a user gate.

- [ ] **Step 2: Verify and commit**

```bash
python3 -c "content = open('plugins/writing/skills/pyramid/opener-prompt.md').read(); opens = content.count('\`\`\`'); import sys; sys.exit(0 if opens % 2 == 0 else 1)"
git add plugins/writing/skills/pyramid/opener-prompt.md
git commit -m "feat(pyramid): add SCQA opener prompt

Phase 4. Composes SCQA against a stable apex and self-audits using
the four SCQA Opener Audit questions from reference section 2.
Emits MISMATCH verdict when the apex cannot support a clean SCQA
(manufactured complication, question-restates-answer, answer-first
bleed); orchestrator routes MISMATCH to a user gate. PASS writes
opener.md with SCQA fields plus a rendered paragraph."
```

---

### Task 11: SKILL.md orchestrator

This is the largest task. The orchestrator wires all previous artifacts together.

**Files:**
- Create: `plugins/writing/skills/pyramid/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Create `plugins/writing/skills/pyramid/SKILL.md`. Use the writing skill's SKILL.md (`plugins/writing/skills/writing/SKILL.md`) as the STRUCTURAL template — same section headings, same dispatch conventions, same state-file shape. The content is entirely different (pyramid-specific).

Required sections (in order):

1. **YAML frontmatter:**
   ```yaml
   ---
   name: pyramid
   description: Use when the user wants a pyramid-structured outline (Barbara Minto's pyramid principle) for a memo, recommendation, briefing, decision document, or analytical report; or wants to restructure an existing draft into pyramid form. Two construction modes (greenfield, restructure). Orchestrates a five-phase pipeline (intake with domain-limits gate, construct, parallel audit panel of MECE / So-What / Q-A Alignment / Inductive-Deductive, SCQA opener, render). Triggers on memo/recommendation/briefing intent and on explicit requests for pyramid/Minto structure. Does NOT trigger for narrative prose, personal essays, or exploratory documents — those belong to the writing skill.
   ---
   ```

2. **Heading and one-line purpose** — "Multi-phase pyramid-principle skill with a parallel audit panel. Modeled on Barbara Minto's method."

3. **Tool Preference** — ordered list identical shape to writing skill's: Agent, Read, Bash, TaskCreate/TaskUpdate, Write/Edit, AskUserQuestion.

4. **Workflow** subsections:
   - **Step 1: Determine working directory** — resolution order (flag → existing artifacts → state file → slug fallback), same shape as writing.
   - **Step 2: Resolve the active reference** — flag → state memory → skill default; resolve default by `Glob` on `**/pyramid/SKILL.md` under the active plugin directory, then take the parent. Surface: *"Using pyramid reference: {path}"*.
   - **Step 3: Determine starting phase** — scan artifacts (`intake.md`, `construction.md`, `audit-summary.md`, `opener.md`, `pyramid.md`), identify latest completed phase, offer resume. Support `--phase X` with X ∈ {intake, construct, audit, opener, render}.
   - **Step 4: Create task list** — one task per phase plus four sub-tasks for audit panel.
   - **Step 5: Execute phases** — with the common dispatch conventions block (same as writing skill: `{OUTPUT_PATH}` is working dir, placeholder substitution list, reviewer-feedback injection standing instruction, date substitution).

5. **Phase details** (one subsection per phase):

   - **Phase 1: Intake** — orchestrator-only, interactive. Sequence:
     1. Ask mode via `AskUserQuestion`: *Greenfield / Restructure* (always ask; if `--mode` flag passed, pre-select but confirm).
     2. Ask genre: *Memo / Recommendation / Briefing / Strategy doc / Case interview answer / Project proposal / Postmortem / Other (describe)*. Map to the lists in reference section 11.
     3. If genre is in the "Does not work for" list, surface a domain-limits gate via `AskUserQuestion`: *Proceed anyway / Switch to writing skill / Cancel*. Honor the choice. Record `genre_override: true` in intake.md if user proceeds.
     4. For Mode A: ask topic, audience, reader question (all via AskUserQuestion or simple prompt).
     5. For Mode B: ask for the draft path OR accept draft pasted inline (write to `{OUTPUT_PATH}/draft.md`).
     6. Write `intake.md` with fields: `mode`, `topic_or_draft_path`, `audience`, `reader_question`, `genre`, `domain_limits_acknowledged`, `genre_override`.
     7. Mark task completed.

   - **Phase 2: Construct** — one Agent dispatch, mode-branched. Read `construct-greenfield-prompt.md` OR `construct-restructure-prompt.md` based on intake's mode. Inject: output path, reference path, empty reviewer feedback (on first dispatch), today's date. Verify `construction.md` exists. For Mode B, verify `restructure-notes.md` also exists.

   - **Phase 3: Audit panel** — four Agent dispatches in PARALLEL (one message with four Agent tool calls). Each reads its prompt file from `audits/`. Each writes its output file. After all four return, consolidate into `audit-summary.md` following the schema in the spec: verdicts table then full-content sections per auditor. Parse first whitespace-delimited token of each auditor's `**Verdict:**` line. Expected tokens: PASS, MINOR, CRITICAL. If any CRITICAL, re-dispatch Phase 2 with `audit-summary.md` injected as `{REVIEWER_FEEDBACK}`, re-run Phase 3, up to 2 total iterations. If still CRITICAL after 2, ask user via AskUserQuestion: *Continue to opener with known logic issues / Pause for manual intervention / Cancel.*

   - **Phase 4: Opener** — one Agent dispatch. Inject output path, reference path, empty reviewer feedback. Verify `opener.md` exists. If the first non-frontmatter line is `**Verdict:** MISMATCH`, the orchestrator does NOT treat this as a failure; it reads the `## Reason` and `## Partial opener` sections and asks user via AskUserQuestion: *Proceed with degraded opener (S and A only) / Revise apex by re-running construct with mismatch note / Cancel.*

   - **Phase 5: Render** — orchestrator-only. Read `construction.md`, `opener.md`, `audit-summary.md`. Assemble `pyramid.md` following the schema in the spec (SCQA paragraph, `## Apex`, `## Supporting findings (<plural noun>)`, nested bullets, `## Audit notes` with MINOR flags). If opener.md is MISMATCH, degrade to Partial opener (S and A only). If all audits returned PASS, Audit notes reads *"All four audits passed."*

6. **Edge Cases** section — mirror the writing skill's edge-case list, pyramid-specific. Required entries:
   - Working dir does not exist → create with `mkdir -p`
   - Reference not found → fall back to default, warn
   - Phase artifact missing on resume → re-run that phase
   - Agent dispatch fails → retry once, then pause
   - Auditor returns malformed output (no `**Verdict:**` line) → treat as MINOR, continue
   - User cancels mid-pipeline → state file records, next run resumes
   - Audit gate fails twice → user gate as above
   - Missing prerequisite artifact on phase jump → enumerate: construct needs intake.md; audit needs construction.md; opener needs construction.md; render needs construction.md AND opener.md
   - Unknown mode value → warn once, ask, record corrected value
   - Mode A with draft-present-in-cwd → surface draft, ask if user meant restructure
   - Mode B with empty draft → ask for draft or bail to Mode A
   - Domain-limits gate override → continue but prepend Audit-notes block with a caveat

7. **State File Format** — `~/.claude/projects/<project-id>/pyramid-skill-state.json`, identical schema to writing skill's but with `mode` instead of `format`:
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
   Recognised mode values: `greenfield`, `restructure`. Key by absolute working-directory path.

8. **Phase Identifier Names** — `intake`, `construct`, `audit`, `opener`, `render`.

9. **Behavioral Guidelines** — pyramid-specific guardrails:
   - Trigger on memo/recommendation/briefing/analytical intent or explicit pyramid/Minto requests
   - Do NOT trigger on narrative, personal essay, exploratory, or pedagogical writing (route to writing skill)
   - Always announce the active reference in the first response
   - Always create the task list before dispatching the first phase agent
   - Never skip the domain-limits gate silently; surface it even when the user asked for pyramid explicitly
   - Auditors emit verdicts; orchestrator decides whether to gate or proceed
   - Opener is written LAST so it cannot force structural changes to the apex

- [ ] **Step 2: Run unit test and verify most assertions now pass**

```bash
PLUGIN_DIR=plugins/writing bash tests/unit/test-pyramid-skill.sh 2>&1 | tail -40
```

Expected: the Test 1-8 assertions from Task 2 all pass. Some may fail if SKILL.md does not mention every keyword exactly; fix the prompt content to match, or update the test if the phrasing drift is legitimate.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/pyramid/SKILL.md
git commit -m "feat(pyramid): add orchestrator SKILL.md

Five-phase pipeline (intake / construct / audit / opener / render).
Intake is interactive with domain-limits gate routing essay/narrative
genres to the writing skill. Construct is mode-branched (greenfield
uses Q-A Dialogue; restructure uses Reverse-Engineering). Audit panel
fans out four agents in parallel (MECE / So-What / Q-A alignment /
Inductive-Deductive); CRITICAL triggers re-dispatch up to 2 iterations.
Opener is phase 4 — written last against a stable apex, with MISMATCH
verdict routing to a user gate. Render assembles pyramid.md in the
spec's format. State file keyed by working directory, same shape as
writing skill. Unit test passes after this lands."
```

---

### Task 12: Skill-triggering prompt files

Five .txt files under `tests/skill-triggering/prompts/`. No per-file test assertions — the existing `run-test.sh` handles the pass/fail logic.

**Files:**
- Create: `tests/skill-triggering/prompts/pyramid-greenfield-memo.txt`
- Create: `tests/skill-triggering/prompts/pyramid-restructure-memo.txt`
- Create: `tests/skill-triggering/prompts/pyramid-domain-limit-essay.txt`
- Create: `tests/skill-triggering/prompts/pyramid-negative-narrative.txt`
- Create: `tests/skill-triggering/prompts/pyramid-negative-factual.txt`

- [ ] **Step 1: Write each prompt**

`pyramid-greenfield-memo.txt`:
```
Help me structure a recommendation memo for our Q3 strategy pivot. Top line is we should sunset product X. Audience is the leadership team; they'll want to know why this is the right call and what the alternatives cost.
```

`pyramid-restructure-memo.txt`:
```
I have this draft memo but the ask is buried at the end and the supporting reasons feel repetitive. Can you pyramid-ify it? The file is at ./draft-q3-churn.md.
```

`pyramid-domain-limit-essay.txt`:
```
I want a pyramid-structured version of my personal essay about how I learned to ship before I felt ready.
```

`pyramid-negative-narrative.txt`:
```
Help me write a personal essay about how I learned to ship before I felt ready.
```

`pyramid-negative-factual.txt`:
```
What are the three rules of Barbara Minto's pyramid principle?
```

- [ ] **Step 2: Run the positive triggering tests**

```bash
PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh pyramid tests/skill-triggering/prompts/pyramid-greenfield-memo.txt
PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh pyramid tests/skill-triggering/prompts/pyramid-restructure-memo.txt
PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh pyramid tests/skill-triggering/prompts/pyramid-domain-limit-essay.txt
```

Expected: `[PASS] Skill 'pyramid' was triggered` for all three.

- [ ] **Step 3: Run the negative triggering tests (should NOT trigger pyramid)**

```bash
PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh writing tests/skill-triggering/prompts/pyramid-negative-narrative.txt
```

Expected: `[PASS] Skill 'writing' was triggered`. (Narrative should route to writing skill, not pyramid.)

For the factual-question prompt, neither pyramid nor writing should trigger. The existing `run-test.sh` only checks one skill name. We assert that pyramid does NOT trigger:

```bash
output=$(PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh pyramid tests/skill-triggering/prompts/pyramid-negative-factual.txt 2>&1)
echo "$output"
if echo "$output" | grep -q "FAIL"; then
    echo "  [PASS] pyramid correctly did NOT trigger on a factual question"
else
    echo "  [FAIL] pyramid incorrectly triggered on a factual question"
fi
```

Expected: the final line reads `[PASS] pyramid correctly did NOT trigger on a factual question`.

- [ ] **Step 4: Commit**

```bash
git add tests/skill-triggering/prompts/pyramid-greenfield-memo.txt \
        tests/skill-triggering/prompts/pyramid-restructure-memo.txt \
        tests/skill-triggering/prompts/pyramid-domain-limit-essay.txt \
        tests/skill-triggering/prompts/pyramid-negative-narrative.txt \
        tests/skill-triggering/prompts/pyramid-negative-factual.txt
git commit -m "test(pyramid): add skill-triggering prompts

Five natural-language prompts covering positive, negative, and
boundary triggering cases: greenfield memo, restructure memo,
boundary (explicit pyramid request on an essay topic — should still
trigger and hit the domain-limits gate), negative narrative (should
route to writing skill), negative factual (should not trigger
either skill)."
```

---

### Task 13: Integration test

**Files:**
- Create: `tests/integration/test-pyramid-integration.sh`

- [ ] **Step 1: Write the integration test**

Create `tests/integration/test-pyramid-integration.sh`:

```bash
#!/usr/bin/env bash
# Integration test: pyramid skill (greenfield end-to-end)
# Runs the full five-phase pipeline on a fixture topic and verifies artifacts
# NOTE: dispatches one construct + four audits + one opener — expect 4-8 minutes
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Integration Test: pyramid skill (greenfield end-to-end) ==="
echo ""

TEST_DIR=$(mktemp -d)
LOG_FILE=$(mktemp)
trap 'rm -rf "$TEST_DIR" "$LOG_FILE"' EXIT

echo "Working dir: $TEST_DIR"
echo ""

echo "Test 1: Full pipeline runs end-to-end..."
# Intake answers are embedded in the prompt so the pipeline runs non-interactively.
PROMPT="Run the full pyramid skill pipeline in greenfield mode in $TEST_DIR. Use --phase intake to start. Topic: 'We should raise Series B in Q1 2027.' Audience: 'board of directors.' Reader question: 'should we raise now or wait?' Genre: 'recommendation.' Do not ask me any follow-up questions — proceed with the answers given. When you reach the domain-limits gate, proceed anyway (this IS a recommendation document, so it should pass the gate). Continue through construct, audit, opener, and render."

output=$(run_claude_logged "$PROMPT" "$LOG_FILE" 600)

echo ""
echo "Test 2: All nine artifacts exist..."
for artifact in intake.md construction.md audit-mece.md audit-so-what.md audit-qa.md audit-logic.md audit-summary.md opener.md pyramid.md; do
    if [ -f "$TEST_DIR/$artifact" ]; then
        echo "  [PASS] $artifact created"
    else
        echo "  [FAIL] $artifact not found"
    fi
done

echo ""
echo "Test 3: pyramid.md contains required top-level sections..."
if [ -f "$TEST_DIR/pyramid.md" ]; then
    for section in 'Opener (SCQA)' '## Apex' '## Supporting findings' '## Audit notes'; do
        if grep -qF "$section" "$TEST_DIR/pyramid.md"; then
            echo "  [PASS] pyramid.md contains: $section"
        else
            echo "  [FAIL] pyramid.md missing: $section"
        fi
    done
else
    echo "  [FAIL] pyramid.md does not exist; cannot check sections"
fi

echo ""
echo "Test 4: audit-summary.md has verdicts table with four rows..."
if [ -f "$TEST_DIR/audit-summary.md" ]; then
    verdict_rows=$(grep -cE '\| (MECE|So-What|Q-A|Inductive)' "$TEST_DIR/audit-summary.md" || true)
    if [ "$verdict_rows" -ge 4 ]; then
        echo "  [PASS] audit-summary.md has 4+ verdict rows ($verdict_rows found)"
    else
        echo "  [FAIL] audit-summary.md has only $verdict_rows verdict rows; expected 4"
    fi
fi

echo ""
echo "Test 5: Each audit file starts with a Verdict line..."
for audit in mece so-what qa logic; do
    file="$TEST_DIR/audit-${audit}.md"
    if [ -f "$file" ]; then
        first_verdict=$(grep -m1 -E '^\*\*Verdict:\*\*' "$file" || true)
        if [ -n "$first_verdict" ]; then
            echo "  [PASS] audit-${audit}.md has Verdict line: $first_verdict"
        else
            echo "  [FAIL] audit-${audit}.md missing Verdict line"
        fi
    fi
done

echo ""
echo "Test 6: State file records last_completed_phase=render..."
STATE_FILE="$HOME/.claude/projects/$(echo "$TEST_DIR" | sed 's|/|-|g; s|^-||')/pyramid-skill-state.json"
if [ -f "$STATE_FILE" ]; then
    if grep -q '"last_completed_phase": "render"' "$STATE_FILE"; then
        echo "  [PASS] state file records last_completed_phase=render"
    else
        echo "  [FAIL] state file does not record render as last phase"
        cat "$STATE_FILE" | sed 's/^/    /'
    fi
else
    echo "  [WARN] state file not found at $STATE_FILE (orchestrator may use different path)"
fi

echo ""
echo "Test 7: Apex in pyramid.md is a finding, not a label..."
if [ -f "$TEST_DIR/pyramid.md" ]; then
    apex_line=$(grep -A1 '^## Apex' "$TEST_DIR/pyramid.md" | tail -1)
    if echo "$apex_line" | grep -qiE "raise|Series B|Q1 2027"; then
        echo "  [PASS] Apex names the finding (contains raise/Series B/Q1 2027)"
    else
        echo "  [FAIL] Apex does not contain the expected topic keywords"
        echo "    Apex line: $apex_line"
    fi
fi

echo ""
echo "=== pyramid integration test complete ==="
```

- [ ] **Step 2: Make executable and run**

```bash
chmod +x tests/integration/test-pyramid-integration.sh
PLUGIN_DIR=plugins/writing bash tests/integration/test-pyramid-integration.sh 2>&1 | tail -80
```

Expected: majority of `[PASS]` lines. Some `[WARN]` is acceptable (e.g. state file path mismatch); no `[FAIL]` on the core artifacts or pyramid.md sections.

If this fails, the most likely causes are:
- A prompt file is missing a placeholder or has malformed dispatch.
- SKILL.md's Phase 3 parallel fan-out is not actually running in parallel — check that all four audit Agent calls are in a single message.
- The audit-summary.md consolidation is off — check the table header matches the `(MECE|So-What|Q-A|Inductive)` regex.
- State file path derivation differs from the test's guess. If so, adjust the test or align the path.

Fix the underlying issue before proceeding. Do not paper over failures.

- [ ] **Step 3: Commit**

```bash
git add tests/integration/test-pyramid-integration.sh
git commit -m "test(pyramid): add greenfield integration smoke test

End-to-end pipeline on a Series B fixture topic. Asserts all nine
artifacts land, pyramid.md has the required sections (SCQA opener,
Apex, Supporting findings, Audit notes), audit-summary.md has a
4-row verdict table, every audit file has a Verdict line, and the
state file records last_completed_phase=render. Runs the intake gate
non-interactively by pre-providing answers in the prompt."
```

---

### Task 14: Run full test suite and final verification

- [ ] **Step 1: Run unit tests**

```bash
PLUGIN_DIR=plugins/writing bash tests/unit/test-pyramid-skill.sh 2>&1 | tail -30
```

Expected: all [PASS]. Any [FAIL] must be fixed before proceeding (either the SKILL.md phrasing, or the test's phrasing if the test is wrong).

- [ ] **Step 2: Run the writing skill's unit test (regression)**

```bash
PLUGIN_DIR=plugins/writing bash tests/unit/test-writing-skill.sh 2>&1 | tail -30
```

Expected: same pass rate as before the pyramid skill landed. The pyramid skill must not break the writing skill's recognition.

- [ ] **Step 3: Run all skill-triggering tests**

```bash
for prompt in tests/skill-triggering/prompts/pyramid-*.txt; do
    base=$(basename "$prompt" .txt)
    case "$base" in
        pyramid-negative-narrative)
            PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh writing "$prompt"
            ;;
        pyramid-negative-factual)
            output=$(PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh pyramid "$prompt" 2>&1)
            if echo "$output" | grep -q "FAIL"; then
                echo "  [PASS] pyramid correctly did NOT trigger on $base"
            else
                echo "  [FAIL] pyramid incorrectly triggered on $base"
            fi
            ;;
        *)
            PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh pyramid "$prompt"
            ;;
    esac
done
```

Expected: all [PASS].

- [ ] **Step 4: Final commit with any phrasing fixes**

If any assertions failed and required fixes to SKILL.md or prompt files, commit them:

```bash
git status
git add -p  # selectively stage changes
git commit -m "fix(pyramid): align skill phrasing with unit test assertions"
```

If no fixes were needed, skip this step.

- [ ] **Step 5: Show final diff summary**

```bash
git log --oneline origin/main..HEAD
git diff --stat origin/main..HEAD
```

Confirm the branch contains: the spec and research doc (already landed in an earlier commit on this branch), the plan (this file), and 11-14 commits covering plugin metadata, reference file, four audit prompts, two construct prompts, opener prompt, SKILL.md, unit test, skill-triggering prompts, and integration test.

---

## Self-Review Results

**Spec coverage check:**
- Phase 1 intake → Task 11 (SKILL.md Phase 1 subsection).
- Phase 2 construct (Mode A and B) → Tasks 8, 9.
- Phase 3 audit panel (4 auditors, parallel) → Tasks 4-7 (prompts) + Task 11 (orchestration).
- Phase 4 opener with MISMATCH → Task 10 (prompt) + Task 11 (orchestration).
- Phase 5 render → Task 11 (orchestrator-only).
- Artifacts schema → Tasks 8 (greenfield construction.md), 9 (restructure + notes), 10 (opener), 11 (pyramid.md).
- State file format → Task 11.
- Unit test → Tasks 2, 14.
- Skill-triggering tests → Task 12.
- Integration smoke test → Task 13.
- Marketplace + plugin.json + README → Task 1.
- Shipped reference file → Task 3.
- Editorial positions baked in → Task 3 (reference) + Tasks 4-10 (prompts inherit).
- Deferred items (Mode D, writing-skill dispatch) → noted in spec, no task (correctly out of scope).

**Placeholder check:** no TBDs, TODOs, "fill in", or "add error handling" gestures. Every step has concrete content (commands, code, or a structured description the executing agent can write from).

**Type consistency:**
- Phase names: intake, construct, audit, opener, render — consistent across all tasks.
- Mode names: greenfield, restructure — consistent.
- Verdict tokens: PASS, MINOR, CRITICAL — consistent (and MISMATCH for opener only).
- Artifact filenames consistent: intake.md, construction.md, restructure-notes.md, audit-{mece,so-what,qa,logic}.md, audit-summary.md, opener.md, pyramid.md, draft.md.
- Placeholder variables consistent: `{OUTPUT_PATH}`, `{REFERENCE_PATH}`, `{REVIEWER_FEEDBACK}`, `{YYYY-MM-DD}`.
- State file mode values: greenfield, restructure — consistent.

No issues found; plan is ready for execution.
