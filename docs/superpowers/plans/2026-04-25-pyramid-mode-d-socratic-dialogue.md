# Pyramid Mode D (Socratic Dialogue) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Mode D (interactive Socratic dialogue) to the pyramid skill so the writer builds the pyramid turn by turn through `AskUserQuestion`, with inline micro-audits and always-available escape hatches.

**Architecture:** New mode peer to Greenfield/Restructure. Phase 2 in Mode D is orchestrator-driven (no Agent dispatch); the orchestrator reads `construct-socratic-prompt.md` and runs an eleven-turn loop for a three-sibling pyramid. Hand-off to Mode A is supported via a new `{HANDOFF}` placeholder substituted into `construct-greenfield-prompt.md`. Phases 1 (intake mode picker), 3 (audit panel), 4 (opener), 5 (render) are unchanged in shape; intake gains a third mode option, the state file gains `socratic` as a recognised mode value, and the dispatch convention list gains `{HANDOFF}`.

**Tech Stack:** Bash, Markdown (skill prompts), Claude Code skills + `AskUserQuestion` tool, existing pyramid skill v1 scaffolding.

**Spec:** `docs/superpowers/specs/2026-04-25-pyramid-mode-d-socratic-dialogue-design.md`

---

## File Structure

| File | Action | Purpose |
|---|---|---|
| `tests/unit/test-pyramid-skill.sh` | Modify | Add assertions for Mode D recognition + greenfield Handoff mode |
| `plugins/writing/skills/pyramid/SKILL.md` | Modify | Add socratic to mode picker (Phase 1), Phase 2 socratic branch, `{HANDOFF}` to Dispatch conventions, state-file recognised values, edge cases |
| `plugins/writing/skills/pyramid/construct-socratic-prompt.md` | Create | Orchestrator playbook: turn sequence, micro-audit specs, block list, escape options, live render contract, hand-off contract |
| `plugins/writing/skills/pyramid/construct-greenfield-prompt.md` | Modify | Add `## Handoff mode` section keyed off `{HANDOFF}` substitution |
| `tests/skill-triggering/prompts/pyramid-socratic-walk-me-through.txt` | Create | Positive trigger #1 |
| `tests/skill-triggering/prompts/pyramid-socratic-interactive.txt` | Create | Positive trigger #2 |
| `tests/skill-triggering/prompts/pyramid-socratic-not-spit-it-out.txt` | Create | Positive trigger #3 |
| `tests/integration/test-pyramid-integration.sh` | Modify | Add Mode D end-to-end scenario with eleven embedded answers |

---

### Task 1: Add unit tests for Mode D recognition

**Files:**
- Modify: `tests/unit/test-pyramid-skill.sh` (append two new tests after Test 8)

- [ ] **Step 1: Open the existing test file and append two new tests**

Edit `tests/unit/test-pyramid-skill.sh`. Replace the existing closing line:

```bash
echo "=== pyramid skill tests complete ==="
```

with:

```bash
# Test 9: Mode D (Socratic) is documented in SKILL.md
echo "Test 9: Mode D (Socratic dialogue) recognition..."
output=$(run_claude "Does the pyramid skill support an interactive Socratic dialogue mode where it walks the writer through pyramid construction question by question? What is it called?" 30)
assert_contains "$output" "[Ss]ocratic|[Ii]nteractive|walk.me.through|question.by.question" "Mentions Mode D / Socratic / interactive dialogue" || true
assert_contains "$output" "AskUserQuestion|turn|dialogue|question.and.answer" "Mentions the dialogue mechanic" || true
echo ""

# Test 10: Greenfield prompt has Handoff mode for Mode D handoffs
echo "Test 10: Greenfield Handoff mode section..."
SKILL_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/plugins/writing/skills/pyramid"
GREENFIELD_PROMPT="$SKILL_DIR/construct-greenfield-prompt.md"
if [ -f "$GREENFIELD_PROMPT" ]; then
    if grep -qF '## Handoff mode' "$GREENFIELD_PROMPT"; then
        echo "  [PASS] construct-greenfield-prompt.md has '## Handoff mode' section"
    else
        echo "  [FAIL] construct-greenfield-prompt.md missing '## Handoff mode' section"
    fi
    if grep -qF '{HANDOFF}' "$GREENFIELD_PROMPT"; then
        echo "  [PASS] construct-greenfield-prompt.md references {HANDOFF} placeholder"
    else
        echo "  [FAIL] construct-greenfield-prompt.md missing {HANDOFF} placeholder reference"
    fi
else
    echo "  [FAIL] construct-greenfield-prompt.md not found at $GREENFIELD_PROMPT"
fi
echo ""

echo "=== pyramid skill tests complete ==="
```

- [ ] **Step 2: Run the test to confirm Test 9 and Test 10 fail**

Run:
```bash
PLUGIN_DIR=plugins/writing bash tests/unit/test-pyramid-skill.sh
```

Expected: Tests 1-8 pass. Test 9 may PASS or FAIL on the soft `assert_contains` (since asserts use `|| true`, the script does not exit on these). Test 10 must report `[FAIL]` for the `## Handoff mode` section grep, since that section does not yet exist in `construct-greenfield-prompt.md`.

- [ ] **Step 3: Commit**

```bash
git add tests/unit/test-pyramid-skill.sh
git commit -m "test(pyramid): add unit tests for Mode D and greenfield Handoff section"
```

---

### Task 2: Update SKILL.md to add Mode D

**Files:**
- Modify: `plugins/writing/skills/pyramid/SKILL.md`

- [ ] **Step 1: Update the front-matter description to mention Mode D**

Find the description string in the YAML frontmatter (currently mentions "Two construction modes (greenfield, restructure)"). Replace `Two construction modes (greenfield, restructure).` with `Three construction modes (greenfield, restructure, socratic interactive dialogue).`

The full updated description (search for the exact existing string and replace; the trigger heuristic and writing-skill routing notes after it remain unchanged).

- [ ] **Step 2: Update Phase 1 mode picker (step 1 inside `### Phase 1: Intake`)**

Find:

```markdown
1. **Mode.** Ask via AskUserQuestion: *Greenfield (I have a topic and want a fresh pyramid outline) / Restructure (I have an existing draft and want to pyramid-ify it)*. Always ask, even if `--mode` was passed; the flag only pre-selects the option. This prevents "surprise wrong mode" failures.
```

Replace with:

```markdown
1. **Mode.** Ask via AskUserQuestion: *Greenfield (I have a topic and want a fresh pyramid outline) / Restructure (I have an existing draft and want to pyramid-ify it) / Socratic (walk me through it question by question, interactive dialogue)*. Always ask, even if `--mode` was passed; the flag only pre-selects the option. This prevents "surprise wrong mode" failures.
```

- [ ] **Step 3: Add Mode D inputs note inside Phase 1**

After the existing step 5 (Mode B inputs), insert a new step before step 6:

Find:

```markdown
5. **Mode B (Restructure) inputs.** Ask for the draft path (absolute path to a markdown file) OR accept the draft pasted inline. If pasted inline, write it to `{OUTPUT_PATH}/draft.md`. Either way, the construct agent reads `draft.md` from the working directory.
6. **Write intake.md** with fields: `mode`, `topic_or_draft_path`, `audience`, `reader_question`, `genre`, `domain_limits_acknowledged`, `genre_override`.
```

Replace with:

```markdown
5. **Mode B (Restructure) inputs.** Ask for the draft path (absolute path to a markdown file) OR accept the draft pasted inline. If pasted inline, write it to `{OUTPUT_PATH}/draft.md`. Either way, the construct agent reads `draft.md` from the working directory.
6. **Mode D (Socratic) inputs.** Same as Mode A: ask for topic, audience, and the reader question. The dialogue itself runs in Phase 2, not in intake. Do NOT collect a draft; Mode D builds the pyramid from scratch with the writer.
7. **Write intake.md** with fields: `mode`, `topic_or_draft_path`, `audience`, `reader_question`, `genre`, `domain_limits_acknowledged`, `genre_override`.
```

(Note the renumbering: the original step 6 becomes step 7. The existing step 7 ("Mark the Phase 1 task completed.") becomes step 8.)

Find:

```markdown
7. Mark the Phase 1 task completed.
```

Replace with:

```markdown
8. Mark the Phase 1 task completed.
```

- [ ] **Step 4: Update Phase 2 with the socratic branch**

Find the Phase 2 opening:

```markdown
### Phase 2: Construct

One Agent dispatch, mode-branched.

1. Read `construct-greenfield-prompt.md` if `mode == greenfield`, or `construct-restructure-prompt.md` if `mode == restructure`.
2. Inject: output path, reference path, empty reviewer feedback (on first dispatch; populated on re-dispatch), today's date.
3. Dispatch via Agent tool.
4. Verify `{OUTPUT_PATH}/construction.md` exists. For Mode B (restructure), also verify `{OUTPUT_PATH}/restructure-notes.md` exists.
5. Mark task completed.

On re-dispatch (after a CRITICAL audit gate), inject `audit-summary.md` content as `{REVIEWER_FEEDBACK}` so the construct agent updates `construction.md` in place to address the flagged issues rather than rebuilding from scratch.
```

Replace with:

```markdown
### Phase 2: Construct

Mode-branched. Modes A and B run as one Agent dispatch. Mode D runs as an orchestrator-only turn loop with no Agent dispatch.

**Modes A (Greenfield) and B (Restructure):**

1. Read `construct-greenfield-prompt.md` if `mode == greenfield`, or `construct-restructure-prompt.md` if `mode == restructure`.
2. Inject: output path, reference path, empty reviewer feedback (on first dispatch; populated on re-dispatch), `{HANDOFF}` set to `false`, today's date.
3. Dispatch via Agent tool.
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
```

- [ ] **Step 5: Update Dispatch conventions to include `{HANDOFF}`**

Find:

```markdown
- **Prompt file extraction.** Each prompt file documents the dispatched prompt inside a fenced block under the `**Dispatch:**` header. The simplest robust approach: read the entire prompt file as text, perform placeholder substitution (`{OUTPUT_PATH}`, `{REFERENCE_PATH}`, `{REVIEWER_FEEDBACK}`, `{YYYY-MM-DD}`), and pass the full result to the Agent tool. The dispatched agent ignores the surrounding commentary because the actionable instructions sit inside the visible prompt body.
```

Replace with:

```markdown
- **Prompt file extraction.** Each prompt file documents the dispatched prompt inside a fenced block under the `**Dispatch:**` header. The simplest robust approach: read the entire prompt file as text, perform placeholder substitution (`{OUTPUT_PATH}`, `{REFERENCE_PATH}`, `{REVIEWER_FEEDBACK}`, `{HANDOFF}`, `{YYYY-MM-DD}`), and pass the full result to the Agent tool. The dispatched agent ignores the surrounding commentary because the actionable instructions sit inside the visible prompt body.
- **`{HANDOFF}` default.** When dispatching `construct-greenfield-prompt.md` in fresh-build or re-dispatch (CRITICAL audit) cases, substitute `{HANDOFF}` with `false`. Substitute `true` only when handing off mid-Mode-D dialogue, or when re-dispatching a Mode-D-built pyramid after a CRITICAL audit. The greenfield prompt's `## Handoff mode` section keys off this value.
```

- [ ] **Step 6: Update state file format documentation**

Find:

```markdown
Recognised mode values: `greenfield`, `restructure`. Key by absolute working-directory path so multiple in-flight pyramids in the same project each have their own state.
```

Replace with:

```markdown
Recognised mode values: `greenfield`, `restructure`, `socratic`. Key by absolute working-directory path so multiple in-flight pyramids in the same project each have their own state. After a Mode-D-to-Mode-A hand-off, the `mode` field becomes `greenfield` and an optional `handoff_from: socratic` field is added.
```

- [ ] **Step 7: Add Mode D edge cases**

Find the Edge Cases section. After the existing bullet about "Mode B (Restructure) with an empty or missing draft" and before the bullet about "Domain-limits gate override", insert these new bullets:

Find:

```markdown
- **Mode B (Restructure) with an empty or missing draft**: if `draft.md` is empty (zero bytes) or the provided path does not exist, ask the user to supply the draft or bail to Mode A (Greenfield).
- **Domain-limits gate override**: the user chose *Proceed anyway* despite a mismatched genre. The pipeline continues normally. Phase 5 render prepends a caveat to the Audit notes section (see Phase 5 above).
```

Replace with:

```markdown
- **Mode B (Restructure) with an empty or missing draft**: if `draft.md` is empty (zero bytes) or the provided path does not exist, ask the user to supply the draft or bail to Mode A (Greenfield).
- **Mode D (Socratic) repeated block on the same turn**: after two failed attempts on a hard-blocked turn (apex is a label, sibling is a label, sibling count exceeds 5), soften to a warning on the third attempt: *"Letting this through. The audit panel will flag it formally."* Caps user frustration without abandoning the discipline.
- **Mode D with existing `construction.md` from a prior run**: ask via AskUserQuestion *Reset and rebuild via dialogue / Keep existing pyramid (no Mode D needed) / Cancel*. Honor the choice.
- **Mode D empty answer in the freeform field**: re-ask the question without consuming a turn.
- **Mode D phase-jump invocation (`--phase construct --mode socratic` on a directory without `intake.md`)**: same handling as Mode A; ask whether to run intake first.
- **Domain-limits gate override**: the user chose *Proceed anyway* despite a mismatched genre. The pipeline continues normally. Phase 5 render prepends a caveat to the Audit notes section (see Phase 5 above).
```

- [ ] **Step 8: Run the unit test to verify Mode D assertions pass**

Run:
```bash
PLUGIN_DIR=plugins/writing bash tests/unit/test-pyramid-skill.sh
```

Expected: Test 9 (Mode D recognition) reports `[PASS]` on both assertions. Test 10 still reports `[FAIL]` for the `## Handoff mode` section (that comes in Task 4).

- [ ] **Step 9: Commit**

```bash
git add plugins/writing/skills/pyramid/SKILL.md
git commit -m "feat(pyramid): add Mode D socratic dialogue branch to orchestrator"
```

---

### Task 3: Create `construct-socratic-prompt.md`

**Files:**
- Create: `plugins/writing/skills/pyramid/construct-socratic-prompt.md`

- [ ] **Step 1: Write the orchestrator playbook**

Create `plugins/writing/skills/pyramid/construct-socratic-prompt.md` with this content:

````markdown
# Construct (Socratic) Orchestrator Playbook

**Purpose:** Build a pyramid turn-by-turn through interactive dialogue with the user. Mode D of the construct phase.

**This file is read by the orchestrator, NOT dispatched as an agent prompt.** Naming keeps symmetry with `construct-greenfield-prompt.md` and `construct-restructure-prompt.md`, but no `{OUTPUT_PATH}` substitution happens at dispatch time and no Agent tool is called. The orchestrator owns the loop end to end.

---

## Inputs

- `intake.md` (mode `socratic`, topic, audience, reader question, genre)
- The shipped reference (`pyramid-principle-reference.md`)
- The working directory `{OUTPUT_PATH}` (the orchestrator already knows this)

## Output

- `{OUTPUT_PATH}/construction.md` in the standard schema, written incrementally turn-by-turn with `<pending>` placeholders for unanswered nodes; the placeholders are replaced as turns complete and absent from the final pyramid.

## Turn Sequence (medium granularity)

Eleven turns for a three-sibling pyramid. Sibling and evidence turns scale with sibling count.

| Turn | AskUserQuestion text | Micro-audit |
|---|---|---|
| 1 | *"What question do you expect the reader to have?"* (pre-fill from `intake.md`'s `reader_question`; the user can edit) | Question ends with `?` and is a real question, not a topic label. **Warn** otherwise. |
| 2 | *"What is the apex, the one-sentence finding that answers that question?"* | **BLOCK:** Apex must be a sentence with a verb, not a noun phrase. |
| 3 | *"Below the apex, what one question does the apex raise for the reader?"* | Question downward must be distinct from Turn 1's reader question. **Warn** if identical. |
| 4 | *"What plural noun names the children that will answer that question? (reasons, risks, steps, recommendations, causes, ...)"* | Noun must be plural; pre-flags inductive vs deductive. **Warn** otherwise. |
| 5 | *"State the first finding."* | **BLOCK:** label-vs-finding (must be a sentence with a verb). **Warn:** So-What ("would the reader say 'so what?' to this?"). |
| 6 | *"State the second finding."* | **BLOCK:** label-vs-finding. **Warn:** ME overlap with finding 1. |
| 7 | *"State the third finding."* | **BLOCK:** label-vs-finding. **Warn:** CE gap ("any obvious case missing?"). |
| 8 | *"Add a fourth finding, or stop here?"* (structured options: *Add one more / Stop at three / Add and stop at five*) | **BLOCK:** Cap at 5; refuse 6+ with the MECE prompt below. |
| 9..N | *"For finding 1, what evidence supports it? (one bullet per line)"* (repeats per finding) | **Warn:** Why-Is-That-True (each bullet is evidence, not restatement of the parent). |

For four- or five-sibling pyramids, the sibling and evidence turns expand. Total turns scale with sibling count.

## Standard Escape Options on Every Turn

Every turn's `AskUserQuestion` carries these structured options alongside the freeform answer field:

- *Other (type my answer)*: primary path, where the user's answer goes.
- *Hand off remaining tiers to Mode A*: orchestrator updates state to `mode: greenfield, handoff_from: socratic`, dispatches `construct-greenfield-prompt.md` with `{HANDOFF}` set to `true`. The greenfield agent fills in the `<pending>` nodes only.
- *Pause and resume later*: orchestrator writes the state file with `mode: socratic`, `last_completed_phase: intake`. Emits a one-line confirmation and exits.
- *Cancel*: working directory artifacts left in place; state file entry removed.

Always present, every turn. No sentinel strings.

## Block List (the only blocking failures)

Three blocking failures. Everything else warns and accepts.

1. **Apex is a noun-phrase label, not a sentence with a verb (Turn 2).** Diagnostic:
   > *"That looks like a label, not a finding. A label names a topic ('Series B considerations'); a finding makes a claim ('We should raise Series B in Q1 2027'). What is your finding?"*
2. **Any sibling is a noun-phrase label (Turns 5-8).** Diagnostic: same shape as the apex one, customised to the sibling.
3. **Sibling count exceeds 5 (Turn 8 with *Add one more* picked beyond five).** Diagnostic:
   > *"Six or more findings is a MECE-failure signal until proven otherwise. Apply the Four MECE Audit Questions (reference section 4) before defending the size: do any two findings overlap? Is there an obvious case missing? Could you consolidate or push some down a level?"*

After two failed attempts on the same hard-blocked turn (the user keeps tripping the same block), soften to a warning on the third attempt and accept the answer: *"Letting this through. The audit panel will flag it formally."* Caps user frustration without abandoning the discipline.

## Soft-Warn Diagnostic Templates

For warnings that do NOT block, surface a single line, then accept the answer.

- **So-What (Turn 5+):** *"Would the reader say 'so what?' to this finding? If yes, push the consequence up a level."*
- **ME overlap (Turn 6+):** *"Does this overlap with a previous finding? If you described both to the reader, would they recognise two distinct ideas?"*
- **CE gap (Turn 7+):** *"Any obvious case the grouping skips? The audit panel runs a Four MECE Audit Questions check at the end."*
- **Why-Is-That-True (Turns 9+):** *"Each bullet should be evidence, not a restatement of the finding. Would the reader read this and say 'yes, because of that'?"*
- **Question downward not distinct from reader question (Turn 3):** *"The downward question should be distinct from the reader's. The reader asks 'should we raise?'; the apex answers 'yes, in Q1.' What new question does that answer raise?"*
- **Plural noun missing or singular (Turn 4):** *"A grouping of one or 'thoughts' usually signals the parent is not really a grouping. What plural noun names this group?"*

## Live Render Contract

After each accepted turn, write `construction.md` in this schema. `<pending>` placeholders mark nodes not yet reached.

```markdown
# Pyramid (construction)

**Mode:** socratic
**Apex (governing thought):** <user's answer from Turn 2, or `<pending>`>
**Reader question:** <user's answer from Turn 1, or `<pending>`>
**Top-level grouping noun:** <user's answer from Turn 4, or `<pending>`>
**Top-level logic:** inductive

## Subject
<from intake.md>

## Reader
<from intake.md>

## Siblings

### 1. <user's answer from Turn 5, or `<pending>`>
- Evidence:
  - <user's evidence from Turn 9, or `<pending>`>

### 2. <user's answer from Turn 6, or `<pending>`>
- Evidence:
  - <user's evidence from Turn 10, or `<pending>`>

### 3. <user's answer from Turn 7, or `<pending>`>
- Evidence:
  - <user's evidence from Turn 11, or `<pending>`>
```

After writing, emit a one-line progress summary to the user:

> *"Pyramid so far: apex + 2 of 3 siblings + 0 evidence rows. Next: finding 3."*

Single line. No full re-render in chat. The full pyramid is in `construction.md` for the user to inspect.

## Hand-Off Contract

When the user picks *Hand off remaining tiers to Mode A* at any turn:

1. The orchestrator's live `construction.md` already has the locked nodes (with `<pending>` placeholders for unfinished ones), so no new write is needed.
2. Update the state file: `mode: greenfield`, add `handoff_from: socratic`.
3. Read `construct-greenfield-prompt.md`. Substitute the placeholders, with `{HANDOFF}` set to `true` and `{REVIEWER_FEEDBACK}` empty.
4. Dispatch via the Agent tool.
5. Verify `{OUTPUT_PATH}/construction.md` exists with no `<pending>` placeholders. The greenfield agent's `## Handoff mode` section is responsible for completing the missing nodes without modifying locked ones.
6. Mark Phase 2 task completed; proceed to Phase 3 (audit panel) as normal.

## Resume Contract

When the orchestrator detects a state file with `mode: socratic` and `last_completed_phase: intake`, ask via AskUserQuestion:

> *"In-flight Socratic dialogue found. Resume from <next-turn description>?"*

The `<next-turn description>` is inferred by reading `construction.md` and counting populated nodes vs `<pending>` placeholders. Examples:

- Apex `<pending>` → "Resume from Turn 2: state your apex"
- Apex populated, sibling 1 `<pending>` → "Resume from Turn 3: question the apex raises"
- All siblings populated, evidence-1 `<pending>` → "Resume from Turn 9: evidence for finding 1"

On yes, re-enter the turn loop at the inferred turn. On no, ask whether to start fresh, hand off the partial work to Mode A, or cancel.

## Behavioural Guidelines

- Inputs are FREEFORM only. Do NOT generate candidate findings, candidate apexes, or candidate evidence for the user to pick from. The whole reason Mode D exists is the writer's voice and thinking shaping every node.
- Block list is short and explicit. Do NOT block on So-What, ME, CE, Why-Is-That-True, downward question distinctness, or plural noun. Those warn and accept; the audit panel is the formal gate.
- After each accepted turn, the live render contract MUST run before the next `AskUserQuestion`. The user should always be able to inspect `construction.md` and see the current state of the pyramid.
- The escape options are always present. Every `AskUserQuestion`, every turn.
- The dialogue does NOT generate the SCQA opener. Phase 4 does that against the stable apex, like Modes A and B.
````

- [ ] **Step 2: Verify the file is readable and well-formed**

Run:
```bash
test -f plugins/writing/skills/pyramid/construct-socratic-prompt.md && wc -l plugins/writing/skills/pyramid/construct-socratic-prompt.md
```

Expected: file exists, contains roughly 130-160 lines.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/pyramid/construct-socratic-prompt.md
git commit -m "feat(pyramid): add construct-socratic-prompt orchestrator playbook"
```

---

### Task 4: Add `## Handoff mode` to `construct-greenfield-prompt.md`

**Files:**
- Modify: `plugins/writing/skills/pyramid/construct-greenfield-prompt.md`

- [ ] **Step 1: Add the Handoff mode section**

Find:

```markdown
    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}

    If reviewer feedback is provided above, the audit phase flagged CRITICAL
    issues with the previous construction. Read `{OUTPUT_PATH}/construction.md`
    and `{OUTPUT_PATH}/audit-summary.md`, address the specific CRITICAL issues
    (MECE gaps or overlaps, Q-A alignment failures, intellectually blank nodes,
    mixed inductive/deductive groupings), and update construction.md in place.
    Do NOT start from scratch; preserve working siblings and fix what is broken.
```

Replace with:

```markdown
    ## Handoff mode

    **Handoff flag:** {HANDOFF}

    If `{HANDOFF}` is `true`, an existing `construction.md` is present in
    `{OUTPUT_PATH}` because the user started the pyramid in Mode D (Socratic
    dialogue) and chose to hand off the remaining tiers. Read it.

    Locked nodes (any node value that is not the literal placeholder `<pending>`)
    are FIXED: do NOT modify them. The user wrote them; preserve them verbatim.

    Fill in only `<pending>` nodes by running the Q-A Dialogue Procedure from the
    apex downward, treating all locked nodes as given. The apex, the reader
    question, the plural noun, and any populated siblings or evidence rows are
    all locked input.

    Verify the pyramid as a whole still passes the rules (apex is a finding,
    siblings are MECE relative to the apex's downward question, grouping noun is
    consistent across siblings). If a locked node violates a rule, do NOT rewrite
    it; instead, append a `## Handoff notes` section at the end of
    `construction.md` flagging the inconsistency for the audit panel.

    If `{HANDOFF}` is `false`, ignore this section entirely and proceed with the
    Q-A Dialogue Procedure for a fresh build.

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}

    If reviewer feedback is provided above, the audit phase flagged CRITICAL
    issues with the previous construction. Read `{OUTPUT_PATH}/construction.md`
    and `{OUTPUT_PATH}/audit-summary.md`, address the specific CRITICAL issues
    (MECE gaps or overlaps, Q-A alignment failures, intellectually blank nodes,
    mixed inductive/deductive groupings), and update construction.md in place.
    Do NOT start from scratch; preserve working siblings and fix what is broken.

    If both `{HANDOFF}` is `true` AND `{REVIEWER_FEEDBACK}` is non-empty
    (re-dispatch of a Mode-D-built pyramid after CRITICAL audit), apply both:
    locked nodes from Mode D stay locked unless they are the specific cause
    cited by the audit summary; everything else gets the in-place repair
    treatment.
```

- [ ] **Step 2: Run the unit test to verify Test 10 passes**

Run:
```bash
PLUGIN_DIR=plugins/writing bash tests/unit/test-pyramid-skill.sh
```

Expected: Test 10 reports `[PASS]` for both the `## Handoff mode` section grep and the `{HANDOFF}` placeholder grep.

- [ ] **Step 3: Commit**

```bash
git add plugins/writing/skills/pyramid/construct-greenfield-prompt.md
git commit -m "feat(pyramid): add greenfield Handoff mode for Mode D handoffs"
```

---

### Task 5: Add skill-triggering prompts for Mode D

**Files:**
- Create: `tests/skill-triggering/prompts/pyramid-socratic-walk-me-through.txt`
- Create: `tests/skill-triggering/prompts/pyramid-socratic-interactive.txt`
- Create: `tests/skill-triggering/prompts/pyramid-socratic-not-spit-it-out.txt`

- [ ] **Step 1: Create the three prompt files**

`tests/skill-triggering/prompts/pyramid-socratic-walk-me-through.txt`:

```
Walk me through building a pyramid for this memo question by question. I want to think through each tier myself, not have you produce the whole thing.
```

`tests/skill-triggering/prompts/pyramid-socratic-interactive.txt`:

```
Help me build a pyramid interactively in a Socratic dialogue. Ask me one question at a time and I'll answer; the pyramid should emerge from the conversation.
```

`tests/skill-triggering/prompts/pyramid-socratic-not-spit-it-out.txt`:

```
Build the pyramid for my memo with me, not for me. Ask me questions instead of writing it out yourself, so I learn the method while we go.
```

- [ ] **Step 2: Run each skill-triggering test**

Run all three:
```bash
PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh pyramid tests/skill-triggering/prompts/pyramid-socratic-walk-me-through.txt
PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh pyramid tests/skill-triggering/prompts/pyramid-socratic-interactive.txt
PLUGIN_DIR=plugins/writing bash tests/skill-triggering/run-test.sh pyramid tests/skill-triggering/prompts/pyramid-socratic-not-spit-it-out.txt
```

Expected: each run reports the pyramid skill activates. Look for the test runner's `[PASS]` confirmation that the skill name `pyramid` was invoked.

If any of the three fails to trigger, do NOT modify the prompt files yet. Report the failure to the user; the trigger heuristic in `SKILL.md` may need a tweak (handled in a follow-up task or tightening of the description).

- [ ] **Step 3: Commit**

```bash
git add tests/skill-triggering/prompts/pyramid-socratic-walk-me-through.txt \
        tests/skill-triggering/prompts/pyramid-socratic-interactive.txt \
        tests/skill-triggering/prompts/pyramid-socratic-not-spit-it-out.txt
git commit -m "test(pyramid): add Mode D socratic skill-triggering prompts"
```

---

### Task 6: Add Mode D integration test scenario

**Files:**
- Modify: `tests/integration/test-pyramid-integration.sh`

- [ ] **Step 1: Add the Mode D scenario block at the end of the script**

Open `tests/integration/test-pyramid-integration.sh`. Find the last line:

```bash
echo "=== pyramid integration test complete ==="
```

Replace with:

```bash
echo ""
echo "=== Mode D (Socratic) end-to-end smoke ==="
echo ""

TEST_DIR_D=$(mktemp -d)
LOG_FILE_D=$(mktemp)
trap 'rm -rf "$TEST_DIR" "$LOG_FILE" "$TEST_DIR_D" "$LOG_FILE_D"' EXIT

echo "Working dir (Mode D): $TEST_DIR_D"
echo ""

echo "Test D1: Mode D pipeline runs end-to-end with embedded answers..."
PROMPT_D="Run the pyramid skill in Mode D (Socratic dialogue) in $TEST_DIR_D. Use --phase intake to start. Topic: 'We should raise Series B in Q1 2027.' Audience: 'board of directors.' Reader question: 'should we raise now or wait?' Genre: 'recommendation.' Domain-limits gate: proceed anyway. Now run the eleven-turn Socratic dialogue. Answer each turn yourself with the answers I will give you below; do NOT actually emit AskUserQuestion calls because the answers are pre-supplied. Turn 1 (reader question): 'Should we raise Series B now, or wait until later in 2027?' Turn 2 (apex): 'We should raise Series B in Q1 2027 rather than wait.' Turn 3 (downward question the apex raises): 'Why Q1 specifically and not later?' Turn 4 (plural noun): 'reasons.' Turn 5 (sibling 1): 'Our runway tightens past Q2 without it.' Turn 6 (sibling 2): 'Market timing favors Q1 launch over later quarters.' Turn 7 (sibling 3): 'Comparable rounds in Q1 closed faster than Q3 last year.' Turn 8 (add or stop): stop at three. Turn 9 (evidence for sibling 1): 'Burn rate is 1.2M/month; current cash buys us through July; closing a round takes 3-4 months.' Turn 10 (evidence for sibling 2): 'Two key competitors announce in Q2; press cycle is favorable through April; product launch is dated for Feb.' Turn 11 (evidence for sibling 3): 'Q1 2026 round comparables (Acme, Beta) closed in 8 weeks; Q3 2025 comparables took 14+ weeks; sentiment data shows H1 fundraising velocity is 2x H2.' Now continue through audit, opener, and render. Do not ask follow-up questions; proceed with the answers given."

output=$(run_claude_logged "$PROMPT_D" "$LOG_FILE_D" 600)

echo ""
echo "Test D2: All nine artifacts exist..."
for artifact in intake.md construction.md audit-mece.md audit-so-what.md audit-qa.md audit-logic.md audit-summary.md opener.md pyramid.md; do
    if [ -f "$TEST_DIR_D/$artifact" ]; then
        echo "  [PASS] $artifact created"
    else
        echo "  [FAIL] $artifact not found"
    fi
done

echo ""
echo "Test D3: pyramid.md contains required top-level sections..."
if [ -f "$TEST_DIR_D/pyramid.md" ]; then
    for section in 'Opener (SCQA)' '## Apex' '## Supporting findings' '## Audit notes'; do
        if grep -qF "$section" "$TEST_DIR_D/pyramid.md"; then
            echo "  [PASS] pyramid.md contains: $section"
        else
            echo "  [FAIL] pyramid.md missing: $section"
        fi
    done
fi

echo ""
echo "Test D4: construction.md records mode: socratic..."
if [ -f "$TEST_DIR_D/construction.md" ]; then
    if grep -qE '^\*\*Mode:\*\* *socratic' "$TEST_DIR_D/construction.md"; then
        echo "  [PASS] construction.md records Mode: socratic"
    else
        echo "  [FAIL] construction.md does not record Mode: socratic"
    fi
fi

echo ""
echo "Test D5: construction.md has no <pending> placeholders left..."
if [ -f "$TEST_DIR_D/construction.md" ]; then
    pending_count=$(grep -c '<pending>' "$TEST_DIR_D/construction.md" || true)
    if [ "$pending_count" = "0" ]; then
        echo "  [PASS] construction.md has no <pending> placeholders"
    else
        echo "  [FAIL] construction.md still has $pending_count <pending> placeholders"
    fi
fi

echo ""
echo "Test D6: State file records mode: socratic and last_completed_phase: render..."
STATE_FILE_D="$HOME/.claude/projects/$(echo "$TEST_DIR_D" | sed 's|/|-|g; s|^-||')/pyramid-skill-state.json"
if [ -f "$STATE_FILE_D" ]; then
    if grep -q '"mode": "socratic"' "$STATE_FILE_D" && grep -q '"last_completed_phase": "render"' "$STATE_FILE_D"; then
        echo "  [PASS] state file records mode=socratic AND last_completed_phase=render"
    else
        echo "  [FAIL] state file does not record both mode=socratic and last_completed_phase=render"
        cat "$STATE_FILE_D" | sed 's/^/    /'
    fi
else
    echo "  [WARN] state file not found at $STATE_FILE_D"
fi

echo ""
echo "Test D7: Apex in pyramid.md is a finding mentioning the user-supplied content..."
if [ -f "$TEST_DIR_D/pyramid.md" ]; then
    apex_line=$(grep -A1 '^## Apex' "$TEST_DIR_D/pyramid.md" | tail -1)
    if echo "$apex_line" | grep -qiE "raise|Series B|Q1 2027"; then
        echo "  [PASS] Apex contains user-supplied finding (raise/Series B/Q1 2027)"
    else
        echo "  [FAIL] Apex does not contain expected finding keywords"
        echo "    Apex line: $apex_line"
    fi
fi

echo ""
echo "=== pyramid integration test complete ==="
```

- [ ] **Step 2: Run the integration test**

Run:
```bash
PLUGIN_DIR=plugins/writing bash tests/integration/test-pyramid-integration.sh
```

Expected: both the original Mode A scenario and the new Mode D scenario complete successfully. Mode D's seven assertions (D1 outputs, D2 artifacts, D3 sections, D4 mode socratic, D5 no pending placeholders, D6 state file, D7 apex content) all report `[PASS]` (with possibly `[WARN]` on D6 if the orchestrator chose a different state path).

The full run takes 8-15 minutes total (Mode A ~4-8 min, Mode D ~4-8 min).

If any assertion fails, capture the log file path that the script printed and inspect it. Common failure modes: orchestrator emitted a real `AskUserQuestion` despite the embedded answers (the prompt instruction needs strengthening), or a `<pending>` placeholder leaked into the final pyramid (the live-render flush logic in the orchestrator playbook is missing a final-turn cleanup).

- [ ] **Step 3: Commit**

```bash
git add tests/integration/test-pyramid-integration.sh
git commit -m "test(pyramid): add Mode D socratic end-to-end smoke test"
```

---

### Task 7: Final verification and PR update

**Files:**
- No code changes; verification and PR-body update only

- [ ] **Step 1: Re-run the full unit test suite**

Run:
```bash
PLUGIN_DIR=plugins/writing bash tests/unit/test-pyramid-skill.sh
```

Expected: Tests 1-10 all show `[PASS]` on their assertions (Test 9 and Test 10 are the new ones for Mode D).

- [ ] **Step 2: Confirm git log**

Run:
```bash
git log --oneline 14e75e2..HEAD
```

Expected: six new commits on top of `14e75e2`, in this order:
1. `docs(pyramid): design spec for Mode D socratic dialogue (issue #12)` (already committed)
2. `test(pyramid): add unit tests for Mode D and greenfield Handoff section`
3. `feat(pyramid): add Mode D socratic dialogue branch to orchestrator`
4. `feat(pyramid): add construct-socratic-prompt orchestrator playbook`
5. `feat(pyramid): add greenfield Handoff mode for Mode D handoffs`
6. `test(pyramid): add Mode D socratic skill-triggering prompts`
7. `test(pyramid): add Mode D socratic end-to-end smoke test`

- [ ] **Step 3: Push and update PR description**

Run:
```bash
git push
gh pr view 13 --json body -q .body > /tmp/pr-body-current.md
```

Inspect `/tmp/pr-body-current.md`. Append a section noting Mode D was added in this PR (closing issue #12), and update the PR with:

```bash
gh pr edit 13 --body-file /tmp/pr-body-updated.md
```

(Where `/tmp/pr-body-updated.md` is the current body plus a new section like `## Mode D (issue #12): Socratic dialogue` summarising what was added.)

- [ ] **Step 4: Confirm PR is up to date**

Run:
```bash
gh pr view 13 --json title,state,headRefName,body
```

Expected: PR is open, branch is `feat/pyramid-skill`, body mentions Mode D / issue #12.

---

## Self-Review Checklist (already run, recorded for reference)

1. **Spec coverage:** Each spec section has a task. Phase 1 mode picker → Task 2 Step 2; Phase 2 socratic branch → Task 2 Step 4; turn sequence + micro-audits + block list + escape options + live render contract + hand-off contract → Task 3 (the playbook file); state file changes → Task 2 Step 6; greenfield Handoff mode → Task 4; edge cases → Task 2 Step 7; tests → Tasks 1, 5, 6.
2. **Placeholder scan:** No "TBD", "TODO", "implement later". Every code/markdown block is complete.
3. **Type consistency:** `{HANDOFF}` placeholder name is consistent across SKILL.md (Task 2), the playbook (Task 3), the greenfield prompt (Task 4), and the integration test does not need it. State file field name `handoff_from` is consistent (Tasks 2, 3).
