# Iteration Loop

How to iterate on an existing Claude Code skill using a lightweight eval loop. The methodology is simple: dispatch the skill via the host agent's subagent tool with and without the skill present, present the diffs to the user, capture feedback, edit, repeat.

This is the lighter cousin of the upstream `skill-creator:skill-creator` eval pipeline. It uses the same conceptual loop without bundling Python scripts.

---

## When to iterate

Iteration is the right next step when:

- The skill misfires on real prompts (output is wrong shape, wrong tone, or wrong tool choice).
- The user has concrete feedback after first use of the skill.
- A behavioral change has been requested (e.g. "it should always confirm before deleting").

This is **not** the right mode when:

- The skill never triggers in the first place. That is a description problem, handled in Mode D (description optimization), not here.
- The skill is a discipline skill (TDD, brainstorming, verification) that you suspect Claude is rationalizing around. That is Mode C (pressure-test), which uses adversarial prompts rather than user-feedback evals.

Mode B (this file) is about behavior under realistic prompts, judged by the user.

---

## Prerequisites

- The skill exists at `{{plugin_dir}}/<plugin>/skills/<skill>/`.
- The user is willing to provide 2 to 3 realistic test prompts the skill should handle.
- The host agent has subagent dispatch available:
  - **Claude Code**: `Agent` tool with `subagent_type: "general-purpose"`.
  - **Codex**: equivalent general-purpose subagent dispatcher.
- If subagent dispatch is unavailable, fall back to running prompts via the host repo's test helpers (typically a `run_claude` function in `tests/test-helpers.sh` or equivalent) and pasting outputs back into the controller context. Output quality is the same; the controller just carries more context.

---

## Workspace layout

All iteration artifacts live under `/tmp/<skill>-iteration/`. Nothing in this workspace gets committed. Layout:

```
/tmp/<skill>-iteration/
  skill-snapshot/                    # Frozen pre-edit copy of the skill (baseline arm)
  evals.json                         # Test prompts (see schema below)
  iteration-1/
    eval-<id>/
      old/
        outputs/                     # Baseline run files
        transcript.txt               # Subagent's report
      new/
        outputs/                     # With-skill run files (after edits)
        transcript.txt
  iteration-2/
    eval-<id>/
      old/...
      new/...
```

The `skill-snapshot/` directory is copied once at the start and never modified. The "old" arm always points at the snapshot. The "new" arm always points at the live skill directory (which gets edited between iterations).

### evals.json schema

```json
{
  "skill_name": "<skill>",
  "evals": [
    {
      "id": "create-page",
      "prompt": "I need to add a new troubleshooting page for the deploy runbook in our Confluence space. Customer Support keeps asking why the rollout step is flaky.",
      "expected_output": "A page is created in the Runbooks space with a title like 'Deploy rollout flakiness troubleshooting' and sections for symptoms, diagnosis, and fix.",
      "files": []
    }
  ]
}
```

Fields:

- `id`: short string used in directory names. Keep it kebab-case.
- `prompt`: the user-facing prompt. Realistic phrasing with backstory, not a one-liner.
- `expected_output`: a sentence describing what success looks like, for orientation. Not graded automatically.
- `files`: array of input file paths the subagent should have access to. Empty if none.

---

## Step 1: Snapshot the current skill

Before any edits, freeze the baseline:

```bash
mkdir -p /tmp/<skill>-iteration
cp -r {{plugin_dir}}/<plugin>/skills/<skill> /tmp/<skill>-iteration/skill-snapshot
```

Why: the baseline arm always uses the pre-edit version, so user feedback compares apples to apples across iterations. If you skip this and edit the live skill, your "old" arm drifts and you lose the comparison.

The snapshot is read-only for the rest of the loop. Treat it as immutable.

---

## Step 2: Gather test prompts

Ask the user for 2 to 3 prompts that exercise the skill's **behavior**, not its description. The goal is to see whether the skill produces the right output, not whether it triggers.

Good prompts:

- Have realistic backstory (project names, file paths, casual phrasing).
- Match what a real user would actually type, not a clean test case.
- Cover different shapes of work the skill should handle (e.g. for a Confluence skill: create a new page, update an existing page, search for prior art).

Reuse `{{test_triggering_dir}}/prompts/<service>-*.txt` if those prompts cover real use cases. Otherwise write fresh ones with the user.

Save to `/tmp/<skill>-iteration/evals.json` using the schema above.

---

## Step 3: Dispatch baseline subagents (no-skill arm)

For each eval, dispatch one subagent against the **snapshot**. In Claude Code:

```
Tool: Agent
subagent_type: "general-purpose"
prompt: |
  Execute this task. Do not consult any other skills or use shortcuts.

  Skill path: /tmp/<skill>-iteration/skill-snapshot
  Read the SKILL.md at that path and follow its instructions.

  Task: <eval prompt verbatim>
  Input files: <list from evals.json, or "none">

  Save all output files to: /tmp/<skill>-iteration/iteration-<N>/eval-<id>/old/outputs/
  Save a short transcript of what you did to: /tmp/<skill>-iteration/iteration-<N>/eval-<id>/old/transcript.txt

  Report back what you did in under 200 words.
```

Why a subagent: the subagent does the work in an isolated context. The controller does not pollute its own context with the full execution trace. The subagent's report is the controller's view.

Dispatch all baseline subagents in parallel (one Agent call per eval, all in the same turn).

If subagent dispatch is unavailable, run the prompts inline via the host repo's `run_claude` helper (typically `tests/test-helpers.sh` or equivalent):

```bash
source {{test_unit_dir}}/../test-helpers.sh   # or wherever the host repo keeps shared helpers
PLUGIN_DIR=/tmp/<skill>-iteration/skill-snapshot run_claude "<eval prompt>"
```

Capture the output to the same `old/outputs/` directory by hand.

---

## Step 4: Dispatch with-skill subagents (live-skill arm)

Same template as Step 3, but point at the live skill directory and write to `new/`:

```
Skill path: {{plugin_dir}}/<plugin>/skills/<skill>
...
Save all output files to: /tmp/<skill>-iteration/iteration-<N>/eval-<id>/new/outputs/
Save a short transcript to: /tmp/<skill>-iteration/iteration-<N>/eval-<id>/new/transcript.txt
```

For iteration 1, the live skill equals the snapshot, so the `old` and `new` arms should be roughly identical (modulo run-to-run variance). That is fine: iteration 1 just establishes a baseline. Real divergence shows up in iteration 2 onward, after the first round of edits.

Dispatch all with-skill subagents in parallel.

---

## Step 5: Present results to the user

Read both arms' outputs and present them side-by-side. The presentation depends on output type:

- **Text outputs** (markdown, code, plain text): use `diff -u old/outputs/<file> new/outputs/<file>` for a unified diff. For prose, also paste both versions in full so the user can read them.
- **File outputs** (`.docx`, `.xlsx`, `.pdf`): tell the user the absolute paths to both files and ask them to open both. Do not try to render binary files inline.
- **Tool-call traces**: if the interesting difference is *what the skill did*, not *what it produced*, show the transcripts side-by-side instead of (or in addition to) the outputs.

Then ask explicitly:

> "Does the new version do what you wanted? What is missing, wrong, or worse than the old version?"

Empty feedback ("looks fine") is a signal too, not a failure. It means that eval is no longer a useful pressure point.

---

## Step 6: Apply user feedback

Edit `SKILL.md` or the relevant `references/*.md` based on what the user said.

Generalize from the feedback. Do not overfit to one prompt:

- If the same fix would help across multiple prompts, that signals a real skill improvement. Apply it.
- If the fix only helps one prompt and would regress others, ask the user whether the prompt is realistic, or whether the skill is genuinely missing a branch for that case.

Prefer explanations over rules. If you find yourself writing `ALWAYS` or `NEVER` in caps to enforce something, reframe it as the reasoning behind the behavior. The model is smart; it follows reasoning better than it follows shouting.

Edits land in the live skill directory (`{{plugin_dir}}/<plugin>/skills/<skill>/`). The snapshot stays untouched.

---

## Step 7: Repeat

Go back to Step 3 with `iteration-<N+1>/`. The snapshot is the baseline forever, so the `old` arm is reproducible across iterations.

The `new` arm gets the latest version of the skill each iteration. That is what the user is judging.

Stop when:

- The user says they are happy.
- All feedback fields are empty (everything looks good).
- No meaningful progress over 2 iterations (the same complaints recur and edits are not landing).

---

## Stop conditions

Hard stops, in order of preference:

1. The user is satisfied. Ship it.
2. All feedback in the latest iteration is empty.
3. No meaningful progress across 2 consecutive iterations: the user keeps reporting the same problem, and your edits are not moving the needle. Step out, ask the user what they actually want, or escalate to a structural rewrite of the skill.
4. The user has run out of test prompts and the existing ones are all green. Adding more prompts is the next step, not more iteration.
5. You have iterated 5 times. Sanity cap. If the loop has not converged in 5 rounds, the skill probably needs a rewrite, not another tweak.

---

## Anti-patterns

Five common mistakes to avoid:

1. **Overfitting.** Removing useful content because one prompt produced bad output. The skill must work across many prompts; pull content only when you can argue it hurts more cases than it helps.
2. **Heavy-handed MUSTs.** Stacking rigid rules instead of explaining why. Today's models follow reasoning better than they follow imperatives. If a `MUST` is doing real work, explain the why next to it; if the why is hard to articulate, the rule is probably wrong.
3. **Iterating on the description in this mode.** The description controls *whether* the skill triggers, not *what it does* once triggered. Description tuning belongs in Mode D (description optimization), with its own eval set of trigger / no-trigger queries. This mode is about behavior.
4. **Skipping the snapshot.** If you do not freeze the pre-edit version, you cannot tell whether your edit improved or regressed. The "old" arm becomes a moving target and the loop loses its anchor.
5. **Pasting transcripts into SKILL.md.** Keep SKILL.md general and pattern-focused. Specific run transcripts belong in the workspace, not in the skill. If a transcript reveals a real pattern, abstract it into a reference file (e.g. `references/recipes.md`); do not paste the literal trace.

---

## Attribution

Methodology adapted from the upstream `skill-creator:skill-creator` skill (MIT). This file describes the conceptual loop in marketplace-agnostic form; no scripts are bundled.

The upstream uses Python helpers (`scripts/aggregate_benchmark.py`, `eval-viewer/generate_review.py`) to manage the eval workspace and render results. This file relies on the host agent's subagent dispatch and the host repo's test helpers (`run_claude`, `run_claude_logged` or equivalent) for the same effect at lower complexity. If you need quantitative benchmarking with grading and variance analysis, reach for the upstream skill instead.
