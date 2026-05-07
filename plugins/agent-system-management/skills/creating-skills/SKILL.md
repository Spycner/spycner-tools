---
name: creating-skills
description: Use when scaffolding, iterating on, pressure-testing, optimizing the description of, or extracting from a session a Claude Code skill in a plugin marketplace following the dual Claude Code and Codex manifest pattern with three-tier operations and three-category test scaffolding. Owns the entire skill lifecycle without deferring to external skills. Triggers on phrases like "create a skill", "scaffold a skill", "iterate on this skill", "pressure-test", "optimize the description", or "turn this conversation into a skill".
---

# Creating Skills

Own the full lifecycle of a Claude Code skill in a plugin marketplace: scaffold, iterate, pressure-test, optimize description, or extract from session. This skill assumes a marketplace following the pgoell-claude-tools conventions: dual Claude Code and Codex manifests, both registered in their respective marketplace files, skills bodies under 500 lines, and tests organized into unit (filesystem checks), skill-triggering (one prompt per file), and integration (opt-in, live API).

---

## Mode selection

Open with one question to the user. Use `AskUserQuestion` (Claude Code) or the equivalent in other runtimes:

> Where in the skill lifecycle are you?
>
> A. Scaffold a brand-new skill (no SKILL.md exists yet).
> B. Iterate on an existing skill with an eval loop and user feedback.
> C. Pressure-test a discipline-enforcing skill with subagent scenarios.
> D. Optimize the description for triggering accuracy.
> E. Extract a skill from this conversation's workflow.

Branch on the answer to the matching mode below. Each mode is a short summary of steps; the heavy content lives in `references/`.

---

## Mode A: Scaffold

Goal: produce a runnable skill scaffold (SKILL.md, plugin manifests if a new plugin, marketplace registration, tests, README and CLAUDE.md updates) so the user can immediately fill in the body and ship.

1. **Detect marketplace shape.** Run:

   ```bash
   test -f .claude-plugin/marketplace.json && echo "claude-marketplace=yes"
   test -f .agents/plugins/marketplace.json && echo "codex-marketplace=yes"
   ```

   Branch:

   - Both present: dual-runtime scaffolding.
   - Only Claude Code present: skip Codex manifest and entry.
   - Only Codex present: skip Claude Code manifest and entry.
   - Neither present: stop. This skill targets plugin marketplaces.

2. **Scope the skill.** Ask the user (`AskUserQuestion`):

   - New plugin or extending an existing one? (offer pick-list from `plugins/` if existing).
   - If new: plugin name (kebab-case), one-line description, keywords array.
   - Skill name (kebab-case, gerund or service slug).
   - One-line skill description.

   Validate names: kebab-case, letters and numbers and hyphens only. Reject anything else.

3. **Classify the skill type.** Ask:

   - A. API or CLI wrapper (Jira, Gmail, Stripe). Use the three-tier (read, write, manage) template.
   - B. Workflow or process skill (autopilot, brainstorming). Use the workflow template.
   - C. Reference skill (recipes, format guides, schemas). Use the reference template.

   Each maps to a SKILL.md template in `references/templates.md`.

4. **Gather details.**

   Common: 3 to 5 trigger phrases the user would say to invoke the skill, optional reference docs (free-form list).

   Per-type:

   - API/CLI wrapper: CLI binary or curl base URL, auth env-var name(s), Tier 1 read operations, Tier 2 write operations, Tier 3 manage operations (often empty).
   - Workflow: numbered step list, whether the skill calls subagents.
   - Reference: source-of-truth docs to summarize.

5. **Scaffold the plugin** (only if new plugin). Use the templates in `references/templates.md`:

   - `plugins/<plugin>/.claude-plugin/plugin.json`.
   - `plugins/<plugin>/.codex-plugin/plugin.json` (with full `interface` block, only if Codex marketplace was detected).

   Both manifests use the same starting version `0.1.0`, author `Pascal Göllner`, license `MIT`.

6. **Scaffold the skill.** Write `plugins/<plugin>/skills/<skill>/SKILL.md` from the chosen template. The host agent fills the placeholders from gathered details.

7. **Scaffold reference docs** (optional). For each reference doc the user listed in step 4, create `plugins/<plugin>/skills/<skill>/<reference>.md` as a stub with a one-line purpose and a `## ` outline.

8. **Wire marketplaces.** Use `Edit` (NOT `Write`) on:

   - `.claude-plugin/marketplace.json`: insert a Claude Code marketplace entry.
   - `.agents/plugins/marketplace.json`: insert a Codex marketplace entry with `policy` and `interface`.

   **Lockstep version invariant:** the four files (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.claude-plugin/marketplace.json`'s entry version, `.agents/plugins/marketplace.json`'s entry version if it has one) must agree. If you bump one, bump all.

9. **Scaffold tests.** Always create:

   - `tests/unit/test-<skill>-skill.sh` (filesystem-check style, modeled on `tests/unit/test-workbench-autopilot-skill.sh`).
   - `tests/skill-triggering/prompts/<skill>-<action>.txt` (one prompt per file, action-led, realistic).

   Opt-in (ask the user): `tests/integration/test-<skill>-integration.sh` for skills wrapping a live API or CLI.

   See `references/test-patterns.md` for full structure.

10. **Update docs.** Use `Edit`:

    - `README.md`: add a row to the plugins table for the new plugin or update the skill list for an existing plugin.
    - `CLAUDE.md`: add a row to the "Current Plugins" table.

11. **Verify.** Run:

    ```bash
    bash tests/unit/test-skill-frontmatter-yaml.sh
    bash tests/unit/test-<skill>-skill.sh
    ```

    The frontmatter lint must pass. The unit test must pass (filesystem checks, no Claude subprocess).

12. **Report.** Summarize the files written and updated. Suggest next steps:

    - Edit the skill body to fill in operations and self-healing.
    - Run the new skill-triggering prompts via `tests/skill-triggering/run-test.sh`.
    - If integration test scaffolded, add live API smoke tests.
    - When ready to iterate or optimize triggering, restart this skill in Mode B or D.

Reference: see `references/templates.md` for all boilerplate and `references/test-patterns.md` for the testing conventions.

---

## Mode B: Iterate

Goal: improve a skill's behavior on real prompts using a with-skill vs no-skill subagent eval loop. The skill exists; the body or references need to evolve.

1. **Snapshot the current skill** to `/tmp/<skill>-iteration/skill-snapshot/`.
2. **Gather 2 to 3 realistic test prompts** and save to `/tmp/<skill>-iteration/evals.json`.
3. **Dispatch baseline subagents** (no-skill arm) for each prompt, pointed at the snapshot. Save outputs under `iteration-N/eval-<id>/old/`.
4. **Dispatch with-skill subagents** (live-skill arm) for the same prompts. Save outputs under `iteration-N/eval-<id>/new/`.
5. **Present results side-by-side** to the user. Ask: "Does the new version do what you wanted? What is missing or wrong?"
6. **Apply user feedback** by editing SKILL.md or references. Generalize from the feedback; do not overfit to one prompt.
7. **Repeat** with iteration-N+1 until the user is satisfied, feedback is empty, or no progress is made over 2 iterations.

Reference: see `references/iteration-loop.md` for the full workflow, the evals.json schema, subagent dispatch templates, and anti-patterns.

---

## Mode C: Pressure-test

Goal: verify a discipline-enforcing skill (TDD, verification-before-completion, designing-before-coding) holds under maximum pressure. RED-GREEN-REFACTOR for documentation.

1. **Design pressure scenarios.** Combine 3 or more pressures (time, sunk cost, authority, exhaustion, social, scarcity) per scenario.
2. **RED: baseline run** without the skill. Dispatch subagents and capture verbatim rationalizations.
3. **GREEN: write or edit the skill** to address those captured rationalizations. Do not pre-empt hypothetical violations.
4. **Re-run with the skill loaded.** Verify compliance.
5. **REFACTOR: close loopholes.** Capture any new rationalization and add an explicit counter (rationalization table row, red-flag list entry, spirit-vs-letter framing).
6. **Repeat** until no new rationalizations emerge under maximum combined pressure.

Reference: see `references/pressure-testing.md` for pressure types, scenario design, the RED-GREEN-REFACTOR mapping, bulletproofing patterns, and attribution to `superpowers:writing-skills`.

---

## Mode D: Optimize description

Goal: tune the `description` field in YAML frontmatter so the skill triggers on the right prompts and stays out of the way on adjacent ones.

1. **Generate eval queries.** 8 to 10 should-trigger and 8 to 10 shouldn't-trigger. Realistic, with backstory, occasional typos.
2. **User review** of the eval set before running.
3. **Train/test split** 60/40. Hold out the test split.
4. **Measure trigger rate** on the train set: dispatch the host model 3 times per query via subagents, record whether the skill is named.
5. **Rewrite description** based on misses. Constraints: under 1024 chars, third person, leads with "Use when", explicit triggers, no workflow summary.
6. **Re-measure on train.** Stop when train converges (5 iterations or 2 with no progress).
7. **Final test-set evaluation.** The winner is the description with the highest test-set score, not the highest train score.
8. **Apply.** Write the winning description into SKILL.md frontmatter and commit with `chore` scope.

Reference: see `references/description-optimization.md` for query generation, train/test discipline, anti-patterns, and attribution to `skill-creator:skill-creator`.

---

## Mode E: Extract from session

Goal: turn the workflow the user just executed in this conversation into a reusable skill.

1. **Read conversation history.** Identify the workflow: tools used, sequence of steps, corrections, input and output formats, edge cases the user surfaced.
2. **Confirm the extraction with the user.** Present the inferred workflow and ask: "Did I capture the workflow correctly? What steps am I missing?"
3. **Hand off to Mode A.** Use the captured workflow as the input for the SKILL.md body. Continue with Mode A from step 1 (detect marketplace) onward, skipping step 4's "gather details" because the details are already captured.

If the runtime cannot read conversation history, fall back: ask the user to paste the workflow steps as a numbered list, then enter Mode A.

---

## Cross-mode invariants

These hold for every mode, in every runtime:

- **Frontmatter lint must pass.** After any change to a SKILL.md, run `bash tests/unit/test-skill-frontmatter-yaml.sh`. Surface failures verbatim.
- **No em-dashes in prose.** Forbid the Unicode characters at codepoints `U+2014` (em-dash) and `U+2013` (en-dash) anywhere in markdown files. Use commas, colons, periods, parentheses, or sentence splits instead. Hyphens (`U+002D`) in compound words are fine.
- **Author = "Pascal Göllner"** (umlaut, not "Kraus") in every manifest, marketplace entry, and README.
- **Conventional Commits.** Each commit uses an appropriate type (`feat`, `fix`, `docs`, `chore`, `test`, `refactor`) and a scope matching the plugin or area. No AI attribution lines in commits, PRs, or code.
- **Version bump required for every plugin change.** Creating, editing, or testing a plugin skill is a plugin change. Bump the plugin version in the same commit or an adjacent release commit. New skills are minor bumps; fixes, docs, tests, and description changes are patch bumps unless they change behavior materially.
- **Lockstep version.** When a plugin's version changes, update all four places that track it: both plugin manifests and both marketplace entries (where the marketplace tracks per-plugin versions).
- **No wrapper scripts.** Skills call the underlying CLI or `curl` directly. No bundled bash or Python wrappers around CLIs the user already has.
- **Lazy auth, never print secrets.** Skills attempt the operation first and diagnose auth failures only on error. Credentials, tokens, and API keys are never echoed or logged.

---

## Reference files

- `references/templates.md`: all boilerplate for Mode A. SKILL.md per type (api, workflow, reference), `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json` with full interface block, both marketplace entries, README and CLAUDE.md row templates, unit test scaffold (filesystem-check style), skill-triggering prompt template, integration test scaffold.
- `references/test-patterns.md`: testing conventions for Mode A. Three test categories (unit, skill-triggering, integration), filesystem-check unit test structure, opt-in integration with auth guards, frontmatter lint procedure.
- `references/iteration-loop.md`: Mode B methodology. Workspace layout, evals.json schema, subagent dispatch templates, side-by-side result presentation, stop conditions, anti-patterns.
- `references/pressure-testing.md`: Mode C methodology. Pressure types, scenario design, RED-GREEN-REFACTOR mapping, bulletproofing patterns (rationalization tables, red-flag lists, spirit-vs-letter framing), attribution to upstream `superpowers:writing-skills`.
- `references/description-optimization.md`: Mode D methodology. Eval query generation, train/test split discipline, trigger rate measurement via subagents, description rewrite constraints, attribution to upstream `skill-creator:skill-creator`.
