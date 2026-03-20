# Research v3: Multi-Agent Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the monolithic deep-research agent with a 5-agent pipeline orchestrated by the main session, with independent review gates.

**Architecture:** The research SKILL.md becomes a pipeline orchestrator that dispatches specialized agents (planner, researcher, writer) and independent reviewers (source-reviewer, report-reviewer) via prompt templates. Agents communicate through files in the output directory. Review failures trigger re-dispatch loops (max 3 iterations).

**Tech Stack:** Claude Code Agent tool, markdown prompt templates, file-based artifact passing.

**Spec:** `docs/superpowers/specs/2026-03-20-research-v3-design.md`

---

### Task 1: Create planner-prompt.md

**Files:**
- Create: `plugins/research/skills/research/planner-prompt.md`

- [ ] **Step 1: Write planner prompt template**

```markdown
# Planner Agent Prompt Template

**Purpose:** Decompose a research brief into a structured research plan.

**Dispatch:** First agent in the pipeline. Receives the research brief in the prompt.

\```
Agent tool (research:deep-research):
  description: "Create research plan"
  prompt: |
    You are a research planner. Your job is to decompose a research topic into
    investigable sub-questions with specific search angles.

    ## Research Brief
    {BRIEF}

    ## Mode
    {MODE} (deep or quick)

    ## Your Task

    Create a research plan and save it to `{OUTPUT_PATH}/research/plan.md`.

    Create the directory structure first:
    ```bash
    mkdir -p {OUTPUT_PATH}/research
    ```

    The plan must follow this exact format:

    ```markdown
    # Research Plan

    ## Brief
    Topic: {topic}
    Scope: {scope}
    Audience: {audience}
    Purpose: {purpose}
    Mode: {mode}
    Creative: {creative}

    ## Sub-Questions
    1. <question>
       - Search angles: <angle1>, <angle2>, <angle3>
       - Source types: <academic, industry, practitioner, etc.>
    2. ...
    (3-5 sub-questions total)

    ## Perspectives (deep mode only)
    - <stakeholder>: <what they care about>
    - ...
    (3-5 perspectives)
    ```

    Rules:
    - Deep mode: 3 search angles per sub-question, include Perspectives section
    - Quick mode: 2 search angles per sub-question, omit Perspectives section
    - Sub-questions should be specific and investigable, not vague
    - Each sub-question should address a different dimension of the topic
    - Search angles should vary framing (academic, industry, critical, adoption, future)

    ## Reviewer Feedback (if any)
    {REVIEWER_FEEDBACK}

    If reviewer feedback is provided, read the existing plan.md, address the
    specific issues raised, and save the updated plan.
\```
```

- [ ] **Step 2: Verify file exists and is well-formed**

Run: `cat plugins/research/skills/research/planner-prompt.md | head -5`
Expected: Shows the header lines

- [ ] **Step 3: Commit**

```bash
git add plugins/research/skills/research/planner-prompt.md
git commit -m "feat(research): add planner agent prompt template"
```

---

### Task 2: Create researcher-prompt.md

**Files:**
- Create: `plugins/research/skills/research/researcher-prompt.md`

- [ ] **Step 1: Write researcher prompt template**

The researcher prompt must include:
- Instructions to read `plan.md` for sub-questions, angles, and perspectives
- Reference to `research-recipes.md` for search query patterns
- Breadth pass instructions (WebSearch per sub-question × angle)
- Depth pass instructions (WebFetch on promising sources, extract data/quotes)
- Adversarial pass instructions (deep mode only)
- Source credibility tagging rules (`[independent]`, `[consulting]`, `[vendor]`, `[practitioner]`, `[journalism]`)
- Threshold integrity rule (`[author estimate]` for derived numbers)
- Exact `sources.md` and `notes.md` format contracts from the spec
- The `{REVIEWER_FEEDBACK}` injection section for fix-mode re-dispatches
- Explicit instruction: do NOT synthesize, form a thesis, or write prose — evidence gathering only

Pull the breadth/depth/adversarial phase instructions from the current `agents/deep-research.md` (lines 33-69), the credibility tagging rules (lines 49-54), and the threshold integrity rule (line 60). Adapt them to reference file paths instead of inline context.

- [ ] **Step 2: Verify file exists**

Run: `wc -l plugins/research/skills/research/researcher-prompt.md`
Expected: File exists with substantial content

- [ ] **Step 3: Commit**

```bash
git add plugins/research/skills/research/researcher-prompt.md
git commit -m "feat(research): add researcher agent prompt template"
```

---

### Task 3: Create source-reviewer-prompt.md

**Files:**
- Create: `plugins/research/skills/research/source-reviewer-prompt.md`

- [ ] **Step 1: Write source reviewer prompt template**

The source reviewer prompt must include:
- Instructions to read `plan.md`, `sources.md`, `notes.md` from `{OUTPUT_PATH}/research/`
- The 6 checks from the spec:
  1. Coverage — every sub-question has sources
  2. Credibility balance — not over-reliant on one source type, 2+ independent per key area
  3. Tag consistency — every vendor/consulting source tagged, tags on every reuse
  4. Threshold integrity — numeric claims cited or `[author estimate]`
  5. Ghost check — notes don't reference sources missing from sources.md
  6. Source count — minimum 8 (deep) or 5 (quick)
- Mode parameter (`{MODE}`) to adjust source count threshold
- Calibration: only flag CRITICAL issues that indicate missing evidence or systematic tagging failures. IMPORTANT for advisory items.
- Exact output format (Verdict: PASS/FAIL, Issues list, Summary)
- No `{REVIEWER_FEEDBACK}` section — reviewers are never re-dispatched with feedback, they just re-run

- [ ] **Step 2: Verify file exists**

Run: `wc -l plugins/research/skills/research/source-reviewer-prompt.md`
Expected: File exists

- [ ] **Step 3: Commit**

```bash
git add plugins/research/skills/research/source-reviewer-prompt.md
git commit -m "feat(research): add source reviewer agent prompt template"
```

---

### Task 4: Create writer-prompt.md

**Files:**
- Create: `plugins/research/skills/research/writer-prompt.md`

- [ ] **Step 1: Write writer prompt template**

The writer prompt must include:
- Instructions to read `plan.md` and `notes.md` from `{OUTPUT_PATH}/research/`
- Instructions to read `report-template.md` from the skill directory (provide absolute path)
- Thesis formulation instructions (from current `deep-research.md` line 89)
- All writing guidelines from current `deep-research.md` lines 103-111:
  - Argue, don't survey
  - Prioritize ruthlessly (top 5-7 findings)
  - Address common starting point
  - Flag source credibility
  - Confront hard problems inline
  - Falsifiable claims in Future Outlook
  - Bias consistency on reuse (credibility tags travel with data)
  - Source weight transparency
- Creative synthesis instructions (Phase 5.5 from current `deep-research.md` lines 71-85), gated by `{CREATIVE}` flag
- Mode-aware template selection (deep vs quick report structure)
- Explicit instruction: do NOT do any web searching — work only from notes.md
- The `{REVIEWER_FEEDBACK}` injection section for fix-mode re-dispatches
- Output: write to `{OUTPUT_PATH}/report.md`

- [ ] **Step 2: Verify file exists**

Run: `wc -l plugins/research/skills/research/writer-prompt.md`
Expected: File exists with substantial content

- [ ] **Step 3: Commit**

```bash
git add plugins/research/skills/research/writer-prompt.md
git commit -m "feat(research): add writer agent prompt template"
```

---

### Task 5: Create report-reviewer-prompt.md

**Files:**
- Create: `plugins/research/skills/research/report-reviewer-prompt.md`

- [ ] **Step 1: Write report reviewer prompt template**

The report reviewer prompt must include:
- Instructions to read `report.md` from `{OUTPUT_PATH}/`, and `sources.md`, `notes.md` from `{OUTPUT_PATH}/research/`
- Instructions to read `report-template.md` from the skill directory (provide absolute path)
- The 10 checks from the spec:
  1. Template compliance — all required sections present
  2. Citation integrity — every claim has inline citation, traceable to sources.md
  3. Tag survival — `[author estimate]`, `[original analysis]`, credibility tags present
  4. Thesis clarity — one-sentence thesis in executive summary first paragraph
  5. Vendor caveating — caveated on every use, not just first mention
  6. Section quality — Analysis & Insights is analytical, no listicle sections
  7. Ghost sources — report doesn't reference anything not in sources.md
  8. Findings ranking — top findings ranked by importance
  9. Creative checks (if enabled) — frameworks pass stress tests, tagged
  10. Creative checks (if disabled) — no original frameworks, gaps as observations
- `{CREATIVE}` flag to toggle creative checks
- `{MODE}` flag to know which template structure to check against
- Calibration: CRITICAL = structural failures (missing sections, ghost sources, no thesis). IMPORTANT = quality issues (weak analysis section, inconsistent tags).
- Exact output format (same as source reviewer)

- [ ] **Step 2: Verify file exists**

Run: `wc -l plugins/research/skills/research/report-reviewer-prompt.md`
Expected: File exists

- [ ] **Step 3: Commit**

```bash
git add plugins/research/skills/research/report-reviewer-prompt.md
git commit -m "feat(research): add report reviewer agent prompt template"
```

---

### Task 6: Rewrite SKILL.md as pipeline orchestrator

**Files:**
- Modify: `plugins/research/skills/research/SKILL.md`

- [ ] **Step 1: Rewrite SKILL.md**

Keep the frontmatter (lines 1-4), Auth Approach section (lines 12-14), and the Prompt Output section (lines 67-98) unchanged.

Rewrite these sections:

**Tool Preference** — update to reflect orchestrator role:
1. **Agent tool** — to dispatch pipeline agents (planner, researcher, writer) and reviewers
2. **Read** — to load prompt templates before dispatch
3. **Bash** — for directory creation and date generation
4. **Write** — for saving prompts to file when requested
5. **WebSearch/WebFetch** — fallback only if agent dispatch fails

**Workflow Step 3: Configure & Dispatch** — replace the single agent dispatch with the full pipeline:

```markdown
### Step 3: Configure & Dispatch

Before dispatching, allow overrides:
- **Output path** — default: `reports/{topic-slug}-{YYYY-MM-DD}/`
- **Mode** — deep (default) or quick
- **Creative** — true or false (default: false)

Default to deep mode unless the user signals quick.

### Step 4: Execute Pipeline

Run the multi-agent pipeline. Each agent communicates through files in the output directory.

**4.1: Plan**
1. Read `planner-prompt.md` from this skill directory
2. Inject: research brief, mode, creative flag, output path
3. Dispatch via Agent tool → wait for completion
4. Verify `{output-path}/research/plan.md` exists and has sub-questions

**4.2: Research**
1. Read `researcher-prompt.md` from this skill directory
2. Inject: research brief, mode, output path, path to `research-recipes.md`
3. Dispatch via Agent tool → wait for completion
4. Verify `{output-path}/research/sources.md` and `{output-path}/research/notes.md` exist

**4.3: Source Review Gate**
1. Read `source-reviewer-prompt.md` from this skill directory
2. Inject: mode, output path
3. Dispatch via Agent tool → wait for completion
4. Parse verdict from agent response
5. If FAIL with CRITICAL issues:
   - Re-read `researcher-prompt.md`, inject original context + reviewer's CRITICAL issues into the `{REVIEWER_FEEDBACK}` section
   - Re-dispatch researcher → wait → re-dispatch source reviewer
   - Repeat up to 3 times. If still failing, present issues to user and ask how to proceed
6. If PASS: continue

**4.4: Write**
1. Read `writer-prompt.md` from this skill directory
2. Inject: research brief, mode, creative flag, output path, path to `report-template.md`
3. Dispatch via Agent tool → wait for completion
4. Verify `{output-path}/report.md` exists

**4.5: Report Review Gate**
1. Read `report-reviewer-prompt.md` from this skill directory
2. Inject: mode, creative flag, output path, path to `report-template.md`
3. Dispatch via Agent tool → wait for completion
4. Parse verdict from agent response
5. If FAIL with CRITICAL issues:
   - Re-read `writer-prompt.md`, inject original context + reviewer's CRITICAL issues into the `{REVIEWER_FEEDBACK}` section
   - Re-dispatch writer → wait → re-dispatch report reviewer
   - Repeat up to 3 times. If still failing, present issues to user and ask how to proceed
6. If PASS: continue

**4.6: Present**
Report the output path and a brief summary to the user.
```

**Self-Healing** — update to reflect pipeline:
- **Agent dispatch fails for any step:** Fall back to running that step inline. Warn user about context usage.
- **Review loop exhausted (3 iterations):** Present the reviewer's remaining issues to the user and ask whether to proceed with the current output or manually intervene.
- **Artifact file missing after agent completes:** Re-dispatch the agent once. If still missing, report error to user.
- **Output directory not writable:** Check permissions, suggest alternative path.

**Behavioral Guidelines** — add:
- Each prompt template has a `{REVIEWER_FEEDBACK}` placeholder. On first dispatch, leave it empty. On fix-mode re-dispatch, inject the reviewer's CRITICAL issues.
- Never pass session history to agents. Construct each dispatch prompt fresh from the template + injected values.

- [ ] **Step 2: Verify the rewritten SKILL.md**

Run: `grep -c "Step 4" plugins/research/skills/research/SKILL.md`
Expected: Shows at least 1 match (the pipeline step)

Run: `grep "planner-prompt\|researcher-prompt\|writer-prompt\|source-reviewer\|report-reviewer" plugins/research/skills/research/SKILL.md | wc -l`
Expected: Multiple matches (all 5 prompt templates referenced)

- [ ] **Step 3: Commit**

```bash
git add plugins/research/skills/research/SKILL.md
git commit -m "feat(research): rewrite SKILL.md as multi-agent pipeline orchestrator"
```

---

### Task 7: Update research-recipes.md — remove self-audit checklist

**Files:**
- Modify: `plugins/research/skills/research/research-recipes.md`

- [ ] **Step 1: Remove the self-audit checklist**

Delete the entire "## Self-Audit Checklist" section (lines 43-81 of the current file). These checks have moved to the source-reviewer and report-reviewer prompt templates.

Keep everything above it:
- Search Strategy Patterns (lines 1-25)
- Adversarial Pass Queries (lines 17-25) — note: the researcher-prompt.md references this file
- Perspective Discovery Patterns (lines 27-40)

- [ ] **Step 2: Verify the checklist is gone but recipes remain**

Run: `grep "Self-Audit" plugins/research/skills/research/research-recipes.md`
Expected: No output (checklist removed)

Run: `grep "Breadth Pass" plugins/research/skills/research/research-recipes.md`
Expected: Shows match (search patterns still present)

- [ ] **Step 3: Commit**

```bash
git add plugins/research/skills/research/research-recipes.md
git commit -m "refactor(research): move self-audit checklist to reviewer agents"
```

---

### Task 8: Delete deep-research.md agent definition

**Files:**
- Delete: `plugins/research/agents/deep-research.md`

- [ ] **Step 1: Verify nothing else references this file directly**

Run: `grep -r "deep-research.md" plugins/research/ --include="*.md" -l`
Expected: Only `agents/deep-research.md` itself (or the old SKILL.md which was already rewritten in Task 6)

If SKILL.md still references it, that's a bug from Task 6 — fix it first.

- [ ] **Step 2: Delete the file**

```bash
rm plugins/research/agents/deep-research.md
```

- [ ] **Step 3: Check if agents/ directory is now empty and clean up**

```bash
ls plugins/research/agents/
```

If empty, remove the directory:
```bash
rmdir plugins/research/agents/
```

- [ ] **Step 4: Commit**

```bash
git add -A plugins/research/agents/
git commit -m "refactor(research): remove monolithic deep-research agent"
```

---

### Task 9: Update version numbers

**Files:**
- Modify: `plugins/research/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Bump plugin.json version to 1.3.0**

In `plugins/research/.claude-plugin/plugin.json`, change `"version": "1.2.0"` to `"version": "1.3.0"`.

- [ ] **Step 2: Bump marketplace.json version**

In `.claude-plugin/marketplace.json`, change the research plugin version from `"1.1.0"` to `"1.3.0"`.

- [ ] **Step 3: Verify versions match**

Run: `grep -A1 '"version"' plugins/research/.claude-plugin/plugin.json`
Expected: `"version": "1.3.0"`

Run: `grep -A1 'research' .claude-plugin/marketplace.json | grep version`
Expected: `"version": "1.3.0"`

- [ ] **Step 4: Commit**

```bash
git add plugins/research/.claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore(research): bump version to 1.3.0 for multi-agent pipeline"
```

---

### Task 10: Update unit tests

**Files:**
- Modify: `tests/unit/test-research-skill.sh`

- [ ] **Step 1: Update tests to reflect multi-agent architecture**

The existing tests (lines 1-83) check for skill recognition, tool preference, workflow, and supporting references. Update:

- **Test 2 (Tool preference):** Change `agent|Agent|subagent` assertion to also match "pipeline" or "orchestrat" since the skill now describes itself as a pipeline orchestrator
- **Add new test:** "Test: Research skill describes multi-agent pipeline" — ask about the research pipeline and assert it mentions "planner", "researcher", "writer", "reviewer" or similar
- **Add new test:** "Test: Research skill mentions review gates" — ask about quality checks and assert it mentions "review" or "gate" or "reviewer"
- **Keep existing tests** for author estimate, creative synthesis, bias consistency, single-source, threshold integrity, creative parameter — these rules still exist, just in different agents

- [ ] **Step 2: Verify tests are syntactically valid**

Run: `bash -n tests/unit/test-research-skill.sh`
Expected: No output (no syntax errors)

- [ ] **Step 3: Commit**

```bash
git add tests/unit/test-research-skill.sh
git commit -m "test(research): update unit tests for multi-agent pipeline"
```
