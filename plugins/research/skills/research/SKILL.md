---
name: research
description: Research complex topics with sources, synthesis, review, and a final report.
---

# Research Skill

Orchestrator-driven deep research. The skill plans the work itself, spawns parallel deep-research subagents per topic cluster, synthesizes findings under unbounded review, and produces a polished report.

---

## Auth Approach

No authentication required. Uses the host agent's web search and fetch or browse capability, and writes to the local filesystem.

## Tool Preference

1. **Subagent dispatch when available and permitted**: dispatch researcher, synthesis, writer, and reviewer agents.
2. **File read tools**: load prompt templates before dispatch.
3. **Shell**: directory creation, date generation, simple file globbing for verification.
4. **Progress list**: live loop bookkeeping.
5. **Web search and fetch or browse tools**: fallback only if subagent dispatch fails.

## Platform Adaptation

Use the host platform's equivalent tools without changing the workflow:

| Capability | Claude Code | Codex |
|---|---|---|
| Subagent dispatch | Agent tool | `spawn_agent` only when available and permitted. Otherwise run the phase inline. |
| Progress list | TaskCreate, TaskUpdate, TaskList | `update_plan` |
| Web research | WebSearch, WebFetch | `web.run` search and open calls, or the host browser/search tools |
| File reads | Read | shell reads such as `sed`, `rg`, or equivalent file read tools |
| Shell | Bash | shell command tool |

When a platform cannot dispatch subagents for the current request, keep the same artifact boundaries and run each phase inline in the orchestrator. Tell the user when this changes runtime or context cost.

## Workflow

### Step 1: Intake (lightweight clarify)

If the request is already concrete (specific topic + scope + audience clear), skip ahead. Otherwise, ask ONE consolidated question covering scope (timeframe, geography), audience, and purpose. No multi-question ladder.

After clarification, write a `brief.md` to the output directory capturing the consolidated brief.

### Step 2: Configure

Output path is the only knob. Default: `reports/{topic-slug}-{YYYY-MM-DD}/`. Allow user override.

Create directories:

```bash
mkdir -p {OUTPUT_PATH}/research
```

### Step 3: Plan (orchestrator-internal)

YOU plan, not an agent. Decompose the brief into sub-questions and cluster them into coherent topics. As many clusters as the brief demands; each cluster should be deep enough to warrant a dedicated researcher. Cluster slugs must be unique and avoid colliding with reserved names (`synthesis`, `gap-N-*`, `*-review-*`).

Write `{OUTPUT_PATH}/plan.md`:

```markdown
# Research Plan

## Brief
Topic: <topic>
Scope: <scope>
Audience: <audience>
Purpose: <purpose>

## Clusters

### Cluster: <cluster-slug-1>
Title: <human-readable title>
Sub-questions:
  - SQ1: <sub-question>
    - Search angles: <angle1>, <angle2>, <angle3>
    - Source types: <academic, industry, etc.>
  - SQ2: ...

### Cluster: <cluster-slug-2>
...
```

Use the progress list to seed: "Spawn researchers", "Synthesize", "Review synthesis", "Write report", "Review report". Mark tasks completed as the pipeline progresses.

### Step 4: Spawn parallel researchers

Each researcher does iterative deep search on its cluster (round-by-round breadth, depth, adversarial, then iterative deepening) until two consecutive rounds add no new evidence (saturation). The researcher produces one self-contained markdown with notes and inline sources (no separate sources or notes files). For each cluster in plan.md:

1. Read `researcher-prompt.md` from this skill directory.
2. Inject: BRIEF, OUTPUT_PATH, RECIPES_PATH (path to research-recipes.md), CLUSTER_SLUG, OUTPUT_FILE (`{OUTPUT_PATH}/research/{cluster-slug}.md`), TARGETED_GAP (empty).
3. Dispatch via the host subagent tool. Send all clusters in parallel when supported.
4. Wait for all to complete. Verify each cluster's output file exists and is non-empty.

If a researcher returns a near-empty file, treat as failed dispatch (re-dispatch once; if still thin, escalate to user as a likely cluster-boundary problem).

### Step 5: Synthesize (iteration N, starting at 1)

1. Read `synthesis-prompt.md`.
2. Inject: BRIEF, OUTPUT_PATH, ITERATION, REVIEWER_FEEDBACK (empty on first pass; populated on re-dispatch).
3. Dispatch via the host subagent tool. Wait for completion.
4. Verify `{OUTPUT_PATH}/research/synthesis.md` exists.

### Step 6: Review synthesis (iteration N)

1. Read `synthesis-reviewer-prompt.md`.
2. Inject: BRIEF, OUTPUT_PATH, ITERATION, REVIEWER_FEEDBACK (empty for normal flow; populated only when re-dispatched from cross-loop branch in Step 10).
3. Dispatch via the host subagent tool. Wait for completion.
4. Read the verdict from agent response, or from `{OUTPUT_PATH}/research/synthesis-review-{N}.md` if response is unparseable.

If verdict is PASS: continue to Step 8.

If verdict is ISSUES with critical issues: classify and proceed to Step 7.

### Step 7: Address synthesis-review issues

Classify each critical issue:

- `evidence-gap`, `coverage`, `source-quality` → spawn gap-fill researcher per issue (or per coherent group of related issues).
- `logic`, `structure` → batch into a single re-synthesis with all such issues as feedback.

For each gap-fill issue:

1. Read `researcher-prompt.md`. Inject: BRIEF, OUTPUT_PATH, RECIPES_PATH, CLUSTER_SLUG=<best-fit existing cluster>, OUTPUT_FILE=`{OUTPUT_PATH}/research/gap-{N}-{issue-slug}.md`, TARGETED_GAP=<full issue description with location pointer>.
2. Dispatch in parallel for all gap-fill issues when supported. Wait for completion.

For batched logic/structure issues:

3. Re-dispatch synthesis with REVIEWER_FEEDBACK populated with the critical issue list. Wait for completion.

After all gap-fills and re-syntheses complete, return to Step 6 with iteration N+1.

### Loop safeguards (Steps 6-7)

**Stall detection.** After writing `synthesis-review-{N}.md`, compare its issue id set to `synthesis-review-{N-1}.md`. If identical, surface to user immediately.

**Check-in.** After synthesis-review iterations 3, 6, 9, ..., pause and surface:
- Open issue ids and one-line descriptions
- What was attempted (which gap-fills ran)
- What's been narrowed (issues closed since iteration 1)
- Options: `continue`, `ship as-is`, `intervene`

Update the progress list at every step so the user can inspect live status through the host platform.

### Step 8: Write (iteration M, starting at 1)

1. Read `writer-prompt.md`.
2. Inject: BRIEF, OUTPUT_PATH, TEMPLATE_PATH (path to report-template.md), REVIEWER_FEEDBACK (empty on first pass; populated on re-dispatch).
3. Dispatch via the host subagent tool. Wait for completion.
4. Verify `{OUTPUT_PATH}/report.md` exists.

### Step 9: Review report (iteration M)

1. Read `writer-reviewer-prompt.md`.
2. Inject: BRIEF, OUTPUT_PATH, TEMPLATE_PATH, ITERATION=M.
3. Dispatch via the host subagent tool. Wait for completion.
4. Read verdict.

If PASS: continue to Step 11.

If ISSUES with critical issues: classify and proceed to Step 10.

### Step 10: Address writer-review issues

Classify each critical issue:

- `prose`, `flow`, `accuracy`, `format` → batch into a single re-write with all such issues as feedback.
- `content-gap-suspected` → re-run synthesis-reviewer with this hypothesis (cross-loop).

For batched prose/flow/accuracy/format issues:

1. Re-dispatch writer with REVIEWER_FEEDBACK populated. Wait. Return to Step 9 with iteration M+1.

For any `content-gap-suspected` issues:

2. Re-dispatch synthesis-reviewer (Step 6) with REVIEWER_FEEDBACK populated with the writer-reviewer's content-gap-suspected issue list. The next synthesis-review file is `synthesis-review-{prior-N+1}.md` (synthesis loop counter resumes monotonically).
3. Branch on synthesis-reviewer verdict:
   - PASS → re-dispatch writer with prose-only feedback (drop the content-gap notes from the writer-reviewer's issue list). Return to Step 9.
   - ISSUES → return to Step 7's classification logic (`evidence-gap` / `coverage` / `source-quality` route to gap-fill research; `logic` / `structure` route to re-synthesize). When the synthesis loop closes again, re-dispatch writer with the original prose feedback (if any) plus a fresh writer review. Return to Step 9.

### Loop safeguards (Steps 9-10)

Same as synthesis loop. Stall detection on consecutive identical id sets in `report-review-{M}.md` and `report-review-{M-1}.md`. Check-in every 3 iterations of writer-review. Same options.

### Step 11: Present

Surface output path + brief summary: total iterations of each loop, final artifact paths, any minor (non-blocking) issues from the final reviews.

## File Layout (output directory)

```
{output-path}/
├── brief.md
├── plan.md
├── research/
│   ├── {cluster-slug}.md         (one per cluster, notes + inline sources)
│   ├── gap-{n}-{slug}.md         (gap-fill research)
│   ├── synthesis.md              (overwritten each iteration)
│   └── synthesis-review-{n}.md
├── report.md                     (overwritten each iteration)
└── report-review-{n}.md
```

## Verdict Parsing

Both reviewers return verdicts in this format:

```
VERDICT: PASS | ISSUES
ISSUES:
  - id: <stable-id>
    severity: critical | minor
    category: <category>
    description: <one line>
    location: <pointer>
SUMMARY: <text>
```

A verdict of PASS with critical issues is malformed; re-dispatch the reviewer once with a format reminder. Stable ids enable stall detection: same id set in consecutive reviews means surface to user.

## Self-Healing

- Agent dispatch fails: fall back to running that step inline. Warn user about context cost.
- Artifact file missing: re-dispatch once. Surface if still missing.
- Verdict unparseable: re-dispatch reviewer once with format reminder.
- Researcher returns empty: re-dispatch once. Surface if still thin (likely bad cluster boundary).
- Stall detected: surface to user immediately. Don't auto-retry.
- Check-in interval reached: pause, present status, await user choice.
- Output dir not writable: suggest alternative path, ask user.

## Behavioral Guidelines

- Trigger on research intent, not simple factual questions.
- When in doubt: ask "Would you like me to run a thorough research investigation, or just answer from what I know?"
- Never pass session history to agents. Construct each dispatch fresh from the template + injected values.
- Each prompt template has placeholders. Researcher: BRIEF, OUTPUT_PATH, RECIPES_PATH, CLUSTER_SLUG, OUTPUT_FILE, TARGETED_GAP. Synthesis: BRIEF, OUTPUT_PATH, ITERATION, REVIEWER_FEEDBACK. Synthesis-reviewer: BRIEF, OUTPUT_PATH, ITERATION, REVIEWER_FEEDBACK (cross-loop only). Writer: BRIEF, OUTPUT_PATH, TEMPLATE_PATH, REVIEWER_FEEDBACK. Writer-reviewer: BRIEF, OUTPUT_PATH, TEMPLATE_PATH, ITERATION.
- Credentials/secrets never appear in templates or injected values.
- See `report-template.md` for report structure (use Deep Mode section) and `research-recipes.md` for search patterns.

## Output Format

Default for this artifact: **html**.

Override resolution order, highest precedence first:

1. Per-invocation override in the user prompt. Recognize phrases like `"a markdown research report"`, `"in HTML"`, `"as a markdown report"`, and equivalents.
2. Per-skill hard-coded default (html).

For format and path, `research:research` does not consult `.workbench/config.md`. It is in a different plugin and has no project-level config knob for those two axes; format and path are determined by per-invocation override or the hard-coded default. (Design system selection is the exception: the cross-reference at the end of this section honors `.workbench/config.md` `## Design system` so a project-wide design-system pin affects research reports too.)

Path: `reports/<topic-slug>-<YYYY-MM-DD>/report.<ext>` by default, where `<ext>` resolves from format.

When emitting HTML, follow `references/research-report-template.html` in this skill's directory. Read the template lazily. Do not introduce U+2014 or U+2013 codepoints in body copy; HTML entity forms are permitted.

For other HTML artifact types not covered by a workbench or research skill, see `workbench:crafting-html`.

When emitting HTML, also apply the active design system per `workbench:crafting-design-systems`. Resolution order: per-prompt override, then `.workbench/config.md` `## Design system` `Name:`, then no override (template defaults).
