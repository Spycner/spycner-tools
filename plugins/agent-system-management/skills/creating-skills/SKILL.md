---
name: creating-skills
description: Use when scaffolding, iterating on, pressure-testing, optimizing the description of, or extracting from a session a Claude Code or Codex skill in any plugin marketplace. Detects the marketplace shape automatically (Claude Code, Codex, or both) and adapts to the repo's own conventions for paths, author, license, test layout, and version-tracking. Triggers on phrases like "create a skill", "scaffold a skill", "iterate on this skill", "pressure-test", "optimize the description", or "turn this conversation into a skill".
---

# Creating Skills

Own the full lifecycle of a Claude Code or Codex plugin skill: scaffold, iterate, pressure-test, optimize description, or extract from session. This skill is **discovery-first**: it probes the current repo's marketplace shape before doing anything, then adapts to the conventions it finds (paths, author, license, test layout, version-tracking sites). Hardcoded values are out; everything that varies between marketplaces is resolved at runtime.

---

## Stage 0: Convention probes

Run these probes the first time the skill is invoked in a run, regardless of mode. Stash results in `/tmp/<plugin>-creating-skills/conventions.json` and reuse for the rest of the run.

### Variable table

These handlebars variables are referenced throughout the SKILL.md body and the reference docs. Each is filled in from a probe.

| Variable | Source probe | Example |
|---|---|---|
| `{{marketplace_claude_path}}` | Probe 1 | `.claude-plugin/marketplace.json` or absent |
| `{{marketplace_codex_path}}` | Probe 1 | `.agents/plugins/marketplace.json` or absent |
| `{{plugin_dir}}` | Probe 2 | `plugins/`, `.claude/plugins/`, etc. |
| `{{author}}` | Probe 3 | Whatever existing manifests use |
| `{{license}}` | Probe 3 | Whatever existing manifests use (often `MIT`) |
| `{{test_unit_dir}}` | Probe 4 | `tests/unit/` or absent |
| `{{test_triggering_dir}}` | Probe 4 | `tests/skill-triggering/` or absent |
| `{{test_integration_dir}}` | Probe 4 | `tests/integration/` or absent |
| `{{frontmatter_linter_path}}` | Probe 5 | `tests/unit/test-skill-frontmatter-yaml.sh` or absent |
| `{{plugin_index_doc}}` | Probe 6 | `README.md`, `CLAUDE.md`, `AGENTS.md`, or absent |
| `{{lockstep_files}}` | Probe 7 | List of files that mention an existing plugin's version string |
| `{{conventional_commits_scope}}` | Probe 6 + sample | Plugin name, used as scope in commits |

### Probe 1: Marketplace manifests

```bash
test -f .claude-plugin/marketplace.json && echo "claude=yes" || echo "claude=no"
test -f .agents/plugins/marketplace.json && echo "codex=yes" || echo "codex=no"
```

If both fail, also check for any nested `marketplace.json`:

```bash
find . -maxdepth 4 -name marketplace.json -not -path '*/node_modules/*' -not -path '*/.git/*'
```

If the find returns nothing and both fixed checks failed, **stop**. Print: "This skill targets Claude Code or Codex plugin marketplaces. No `.claude-plugin/marketplace.json` or `.agents/plugins/marketplace.json` was found. Bootstrap one of those first; the templates in `references/templates/` show the minimal shape." Exit cleanly.

### Probe 2: Plugin directory

```bash
for candidate in plugins .claude/plugins agents/plugins; do
  if [ -d "$candidate" ]; then
    if find "$candidate" -mindepth 2 -maxdepth 3 -name 'plugin.json' -path '*/.claude-plugin/*' -o -path '*/.codex-plugin/*' | head -1 | grep -q .; then
      echo "plugin_dir=$candidate"
      break
    fi
  fi
done
```

If no candidate matches, ask the user where their plugins live.

### Probe 3: Sample existing plugin

Pick the first directory under `{{plugin_dir}}` that contains a `.claude-plugin/plugin.json` or `.codex-plugin/plugin.json`. From its manifest:

```bash
sample=$(find "{{plugin_dir}}" -mindepth 2 -maxdepth 3 -name 'plugin.json' | head -1)
jq -r '.author.name // .author // "<unknown>"' "$sample"
jq -r '.license // "<unknown>"' "$sample"
```

Record both. If unknown, ask the user.

### Probe 4: Test layout

```bash
for d in tests/unit tests/skill-triggering tests/integration test/unit spec; do
  test -d "$d" && echo "found=$d"
done
```

If `tests/unit` exists, look for an existing skill test to confirm the naming convention:

```bash
ls tests/unit/test-*-skill.sh 2>/dev/null | head -1
```

If no test layout exists at all, the scaffold step will offer minimal infrastructure (see `references/test-patterns.md`).

### Probe 5: Frontmatter linter

```bash
find tests test scripts -maxdepth 3 -name '*frontmatter*.sh' -o -name '*lint*.sh' 2>/dev/null | head -1
```

Record the path or note absence.

### Probe 6: Top-level docs that index plugins

```bash
for f in README.md CLAUDE.md AGENTS.md; do
  if [ -f "$f" ] && grep -qiE '^#+.*(plugin|skill)' "$f"; then
    echo "indexes=$f"
  fi
done
```

Record each file that has a Plugins or Skills heading; the scaffold step updates only those.

### Probe 7: Version-tracking sites (lockstep set)

Take the sample plugin's name and version from probe 3. Record every file that mentions that exact version string scoped to relevant locations:

```bash
sample_name=$(jq -r .name "$sample")
sample_version=$(jq -r .version "$sample")
git grep -l "\"$sample_version\"" -- "{{plugin_dir}}/$sample_name/" '.claude-plugin/' '.agents/' 2>/dev/null | sort -u
```

The result is the lockstep set this marketplace uses (could be 2 files, 3 files, 4 files, or more). The skill never assumes a fixed number.

### Probe report

After running all 7 probes, write `/tmp/<plugin>-creating-skills/conventions.json` and present a one-block summary to the user:

```
Detected marketplace conventions:
- Claude Code marketplace: <path or "absent">
- Codex marketplace: <path or "absent">
- Plugin directory: <path>
- Author for new plugins: <author>
- License for new plugins: <license>
- Test layout: <unit dir, triggering dir, integration dir, or "no tests dir">
- Frontmatter linter: <path or "absent (will scaffold minimal one if needed)">
- Top-level plugin index docs: <list, or "none">
- Lockstep version files (sample = <plugin>): <list>

Confirm or correct? (autopilot mode: assume yes unless something is clearly wrong)
```

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

Branch on the answer to the matching mode below.

---

## Mode A: Scaffold

Goal: produce a runnable skill scaffold (SKILL.md, plugin manifests if a new plugin, marketplace registration, tests, top-level doc updates) so the user can immediately fill in the body and ship.

1. **Run convention probes** (Stage 0). Skip if already run earlier in this session.
2. **Confirm probe results.** One round trip with the user.
3. **Scope the new skill.** Ask: new plugin or extending an existing one? (offer pick-list from `{{plugin_dir}}`). If new: plugin name, one-line description, keywords. Skill name, one-line skill description. Validate names: kebab-case only.
4. **Classify type.** Ask: A. API or CLI wrapper, B. workflow, C. reference. Each maps to a SKILL.md template in `references/templates/skill-bodies.md`.
5. **Gather details.** Trigger phrases (3 to 5). Optional reference doc list. Per type: tier 1/2/3 operations, or numbered workflow steps, or source-of-truth pointers.
6. **Scaffold the plugin** (only if new). Use templates from `references/templates/manifests.md`. Write only the manifests this marketplace uses (Claude only, Codex only, or both, per Probe 1). Both manifests start at `0.1.0`, author `{{author}}`, license `{{license}}`.
7. **Scaffold SKILL.md.** Use `{{plugin_dir}}/<plugin>/skills/<skill>/SKILL.md` from the chosen template.
8. **Scaffold reference docs** (optional). One stub per reference doc the user listed.
9. **Wire marketplaces.** Use `Edit` (NOT `Write`). Insert into `{{marketplace_claude_path}}` and `{{marketplace_codex_path}}` only where they exist (probe 1). The lockstep version invariant: the value in every file from `{{lockstep_files}}` (probe 7) plus the new files just created must agree.
10. **Scaffold tests.** Always create a unit test in `{{test_unit_dir}}` if it exists. If `{{test_unit_dir}}` is absent, offer a minimal scaffold (see `references/test-patterns.md` for the bootstrap section). Always create one skill-triggering prompt in `{{test_triggering_dir}}` if it exists. Opt-in: ask whether to scaffold an integration test.
11. **Update top-level docs.** Only if `{{plugin_index_doc}}` is non-empty (probe 6). Edit each indexed doc: add a row for the new plugin or update the skill list for an existing plugin.
12. **Verify.** Run `{{frontmatter_linter_path}}` if it exists. Run the new unit test if `{{test_unit_dir}}` exists. Surface failures verbatim.
13. **Report.** Summarize the files written and updated. Suggest next steps.

Reference: see `references/templates/` for boilerplate (handlebars-templated; index in `references/templates/README.md`) and `references/test-patterns.md` for the testing conventions.

---

## Mode B: Iterate

Goal: improve a skill's behavior on real prompts using a with-skill vs no-skill subagent eval loop.

1. **Snapshot the current skill** to `/tmp/<skill>-iteration/skill-snapshot/` (source path = `{{plugin_dir}}/<plugin>/skills/<skill>/`).
2. **Gather 2 to 3 realistic test prompts** and save to `/tmp/<skill>-iteration/evals.json`.
3. **Dispatch baseline subagents** (no-skill arm) for each prompt, pointed at the snapshot. Save outputs under `iteration-N/eval-<id>/old/`.
4. **Dispatch with-skill subagents** (live-skill arm). Save outputs under `iteration-N/eval-<id>/new/`.
5. **Present results side-by-side** to the user. Ask: "Does the new version do what you wanted? What is missing or wrong?"
6. **Apply user feedback** by editing SKILL.md or references. Generalize from feedback; do not overfit.
7. **Repeat** until the user is satisfied, feedback is empty, or no progress over 2 iterations.

Reference: see `references/iteration-loop.md` for the full workflow, evals.json schema, subagent dispatch templates, and anti-patterns.

---

## Mode C: Pressure-test

Goal: verify a discipline-enforcing skill (TDD, verification-before-completion, designing-before-coding) holds under maximum pressure. RED-GREEN-REFACTOR for documentation.

1. **Design pressure scenarios.** Combine 3 or more pressures (time, sunk cost, authority, exhaustion, social, scarcity) per scenario.
2. **RED: baseline run** without the skill. Dispatch subagents and capture verbatim rationalizations.
3. **GREEN: write or edit the skill** to address those captured rationalizations.
4. **Re-run with the skill loaded.** Verify compliance.
5. **REFACTOR: close loopholes.**
6. **Repeat** until no new rationalizations emerge under maximum combined pressure.

Reference: see `references/pressure-testing.md` for the full methodology and bulletproofing patterns.

---

## Mode D: Optimize description

Goal: tune the `description` field in YAML frontmatter so the skill triggers on the right prompts.

1. **Generate eval queries** (8 to 10 should-trigger and 8 to 10 shouldn't-trigger).
2. **User review** of the eval set.
3. **Train/test split** 60/40.
4. **Measure trigger rate** on train (3 dispatches per query).
5. **Rewrite description** based on misses.
6. **Re-measure on train.** Stop when train converges (5 iterations or 2 with no progress).
7. **Final test-set evaluation.**
8. **Apply.** Write the winner into SKILL.md frontmatter and commit with `chore({{conventional_commits_scope}})` scope.

Reference: see `references/description-optimization.md`.

---

## Mode E: Extract from session

1. **Read conversation history.** Identify the workflow.
2. **Confirm the extraction** with the user.
3. **Hand off to Mode A.** Start at Stage 0; skip step 5 because details are already captured.

If the runtime cannot read conversation history, ask the user to paste the workflow as a numbered list, then enter Mode A.

---

## Universal invariants

These hold for every mode, in every runtime, in every marketplace:

- **No wrapper scripts.** Skills call the underlying CLI or `curl` directly. No bundled bash or Python wrappers around CLIs the user already has.
- **Lazy auth, never print secrets.** Skills attempt the operation first and diagnose auth failures only on error. Credentials, tokens, and API keys are never echoed or logged.
- **Conventional Commits.** Each commit uses an appropriate type (`feat`, `fix`, `docs`, `chore`, `test`, `refactor`) and a scope matching the plugin or area. (If `git log` shows the host repo does not use Conventional Commits, the skill says so but still recommends them.)
- **Version bump required for every plugin change.** Creating, editing, or testing a plugin skill is a plugin change. Bump the plugin version in the same commit or an adjacent release commit. New skills are minor bumps; fixes, docs, tests, and description changes are patch bumps unless they change behavior materially.
- **Frontmatter lint must pass** *if a linter was discovered* in Probe 5. After any change to a SKILL.md, run `{{frontmatter_linter_path}}` and surface failures verbatim. If absent, suggest the minimal scaffold from `references/test-patterns.md`.

## Project conventions resolved from probes

These are filled in from Stage 0; the skill never hardcodes a value:

- **Author** = `{{author}}` (Probe 3).
- **License** = `{{license}}` (Probe 3).
- **Lockstep version set** = `{{lockstep_files}}` (Probe 7). When a plugin's version changes, every file in this set must update in the same commit.
- **Em-dash rule.** If `CLAUDE.md` or `AGENTS.md` documents a no-em-dash / no-en-dash rule, follow it. Forbid Unicode codepoints `U+2014` (em-dash) and `U+2013` (en-dash) anywhere in markdown. Use commas, colons, periods, parentheses, or sentence splits instead. Hyphens (`U+002D`) in compound words are fine. (See: this very SKILL.md and the files under `references/templates/` reference these codepoints, not the literal characters, to avoid lint false positives.)
- **AI attribution.** No AI attribution lines (`Co-Authored-By: Claude`, `Generated with X`) in commits, PRs, or code, unless the host repo's `CLAUDE.md` or `AGENTS.md` says otherwise.

---

## Reference files

- `references/templates/`: handlebars-templated boilerplate for Mode A, split by artifact. Index in `references/templates/README.md`. Files: `skill-bodies.md` (api, workflow, reference SKILL.md types), `manifests.md` (both plugin.json files), `marketplace-entries.md` (both marketplace entries), `index-doc-rows.md` (top-level plugin-index doc row variants), `tests.md` (unit, skill-triggering, integration scaffolds). Templates accept the variables from the variable table above as inputs.
- `references/test-patterns.md`: testing conventions for Mode A. Three test categories (unit, skill-triggering, integration). Uses handlebars for paths. Includes a minimal bootstrap section with a 30-line frontmatter validator and a `run-test.sh` for repos without testing infrastructure.
- `references/iteration-loop.md`: Mode B methodology. Workspace layout, evals.json schema, subagent dispatch templates, side-by-side result presentation, stop conditions, anti-patterns. Source paths are handlebars-resolved.
- `references/pressure-testing.md`: Mode C methodology. Pressure types, scenario design, RED-GREEN-REFACTOR mapping, bulletproofing patterns (rationalization tables, red-flag lists, spirit-vs-letter framing). Attribution to upstream `superpowers:writing-skills`.
- `references/description-optimization.md`: Mode D methodology. Eval query generation, train/test split discipline, trigger rate measurement via subagents, description rewrite constraints. Attribution to upstream `skill-creator:skill-creator`.
