# Autopilot Plugin Extraction Design

*Date: 2026-04-23*

## Problem

Klassenzeit's `.claude/commands/autopilot.md` encodes a full end-to-end feature flow (brainstorm → spec → plan → implementation → PR → green CI) with strict discipline: mandatory skill invocations per step, a pre-PR skill audit, never-merge / never-skip-hooks invariants, Conventional Commits, and a self-review pass at the end. It is the backbone of how the owner ships work on that project.

A new project (`sieve`, https://github.com/pgoell/sieve) now needs the same workflow. Copying `autopilot.md` into each new repo produces drift: the 10-step sequence, the skill audit table, and the invariants are universal, but in Klassenzeit they are entangled with project-specific details (`master` default branch, `docs/superpowers/` paths, `mise run …` commands, `/tmp/kz-brainstorm/` scratch dir, the `post_brainstorm_comments.py` sidecar script). Updating one project's autopilot and not the others means the workflow diverges across projects.

The repo currently has no workflow plugin. The closest analog is `plugins/writing/skills/writing/`, which orchestrates a multi-phase pipeline via prompt files under one `SKILL.md`.

## Design Goal

An `/pgoell-claude-tools:autopilot` skill in a new `plugins/autopilot/` plugin that captures the universal Klassenzeit workflow (step sequence, skill audit, invariants) and reads per-project specifics from a small declarative config file. One source of truth for the workflow; each project contributes only what varies.

Personal-use first, with Klassenzeit and sieve as the initial consumers. Marketplace-shareable later if it earns polish.

## Scope

**In scope for v1:**

- A new plugin `plugins/autopilot/` with one skill `skills/autopilot/SKILL.md`.
- A declarative per-project config file at `.claude/autopilot.local.md` (YAML frontmatter plus optional markdown notes), following the `plugin-settings` convention.
- A thin wrapper pattern at `.claude/commands/autopilot.md` in each consumer project that invokes the skill.
- Support for optional per-project extension hooks (scripts or commands that run at named points in the flow).
- A migration plan for Klassenzeit (replace its inline autopilot with the wrapper) and an integration plan for sieve (add the wrapper when it reaches Phase 0).
- Skill-triggering and smoke tests under `tests/`.

**Out of scope for v1:**

- Non-Git VCS support (Mercurial, Fossil).
- Multi-repo / monorepo-specific flows (branching per package, coordinated PRs across repos).
- Web-based dashboard or TUI.
- GitHub Enterprise-specific auth flows (assumes `gh` is already authenticated).
- Replacing the `post_brainstorm_comments.py` script itself (kept per-project; surfaced via extension hook).

## Universal vs project-specific

The core abstraction is this table. Everything in the "universal" column lives in the skill; everything in the "project-specific" column lives in the per-project config.

| Axis | Universal | Project-specific |
|---|---|---|
| 10-step sequence | yes | no |
| Required skill invocations table | yes | can ADD via config, cannot REMOVE |
| Invariants (never merge, never skip hooks, no AI attribution, Conventional Commits, no em-dashes) | yes | no |
| Skill audit pre-PR | yes | no |
| Default branch | no | `default_branch: main` (detectable fallback) |
| Branch prefix map (`feat/`, `fix/`, etc.) | defaults provided | `branch_prefixes: {feat, fix, docs, chore, refactor, test, perf, style, ci, build, revert}` |
| Spec path | `docs/superpowers/specs/` default | `paths.specs` override |
| Plan path | `docs/superpowers/plans/` default | `paths.plans` override |
| Tracker path | `docs/superpowers/OPEN_THINGS.md` default | `paths.open_things` override |
| Scratch dir | `/tmp/<project_slug>-brainstorm` default (derived from `project_name`) | `scratch_dir` override |
| Task runner | `mise run` default (detectable) | `tools.task_runner`, `tools.lint`, `tools.test`, `tools.fmt` overrides |
| Allowed commit types | standard Conventional Commits default | `commit.allowed_types` override |
| Remote + base branch | `origin` / config default | `git.remote`, `git.pr_base` |
| Extension hooks (post_brainstorm, post_plan, post_pr) | hook framework is universal | hook commands/scripts are project-specific |

## Approach

One orchestrator skill at `plugins/autopilot/skills/autopilot/SKILL.md`. The skill contains:

1. The full 10-step workflow prose, with placeholders where project-specific values appear (e.g. `{{paths.specs}}/<today>-<topic>-design.md`).
2. The required skill invocations table (universal).
3. The skill audit step (universal).
4. The invariants block (universal).
5. A bootstrap section that reads `.claude/autopilot.local.md` from the invoking project, applies defaults and detection for missing fields, and resolves the final config in memory before executing.

Project wrapper commands are trivial:

```markdown
---
description: Run the autopilot workflow for <project>.
argument-hint: <topic description>
---

# /autopilot

Invoke `pgoell-claude-tools:autopilot` with the topic `$ARGUMENTS` and the config at `.claude/autopilot.local.md`.
```

That is close to all the project contributes. Any customization beyond a new tool runner or new extension hook should go into the shared skill so every project benefits.

## File Layout

```
plugins/autopilot/
├── README.md                             # plugin overview, install, config schema reference
└── skills/
    └── autopilot/
        ├── SKILL.md                      # the orchestrator (workflow + audit + invariants)
        ├── step-templates/
        │   ├── 00-using-superpowers.md   # skill-discipline bootstrap
        │   ├── 01-workspace-prep.md      # branch creation, clean checkout
        │   ├── 02-brainstorm.md          # Q&A rhythm, scratch-dir convention
        │   ├── 03-spec.md                # spec template + self-review gate
        │   ├── 04-plan.md                # plan template + checkbox syntax
        │   ├── 05-execute.md             # TDD + subagent-driven execution
        │   ├── 06-finalize-docs.md       # CLAUDE.md + ADR + OPEN_THINGS updates
        │   ├── 07-skill-audit.md         # pre-PR blocking audit
        │   ├── 08-ci-loop.md             # gh pr checks + failure triage
        │   ├── 09-do-not-merge.md        # explicit stop
        │   └── 10-self-review.md         # post-CI reflection + memory update
        ├── config-schema.md              # YAML schema for .claude/autopilot.local.md
        ├── default-branch-prefixes.md    # the default branch-prefix map
        └── invariants.md                 # the non-negotiable rules, one place
```

Marketplace registration in `.claude-plugin/marketplace.json`:

```json
{
  "name": "autopilot",
  "source": "./plugins/autopilot",
  "description": "Autonomous feature-flow workflow: brainstorm, spec, plan, implement, PR, green CI, with strict skill-audit discipline and per-project config",
  "version": "1.0.0"
}
```

## Project config schema

File: `.claude/autopilot.local.md` in the consumer project.

Format: YAML frontmatter plus optional markdown body for free-form project notes that the skill should keep in mind.

```yaml
---
project_name: sieve
default_branch: main

paths:
  specs: docs/superpowers/specs
  plans: docs/superpowers/plans
  open_things: docs/superpowers/OPEN_THINGS.md
  adr: docs/adr

scratch_dir: /tmp/sieve-brainstorm     # optional; defaults to /tmp/{project_name}-brainstorm

tools:
  task_runner: mise run                 # verb prefix; commands below append
  lint: lint                            # final command is "mise run lint"
  test: test
  fmt: fmt
  install: install                       # one-shot bootstrap task, optional

commit:
  allowed_types: [feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert]
  # PR title subject must start lowercase; enforced by pr-title.yml if present.

git:
  remote: origin
  pr_base: main

hooks:
  # Optional extension points. Each value is either a shell command or a slash-command reference.
  # Omit a key to skip that hook.
  post_brainstorm: "python3 .claude/commands/post_brainstorm_comments.py {{pr}}"
  post_spec: null
  post_plan: null
  post_implementation: null
  post_pr: null

additional_required_skills:
  # Projects can ADD skill invocations that are mandatory for this project.
  # They cannot remove items from the universal required-skills table.
  - step: 6
    name: "my-project:custom-changelog-skill"
    purpose: "Regenerate the CHANGELOG.md from commit history."
---

# Notes

Free-form project notes the autopilot skill should respect. Not required; useful for small caveats like "this project's pre-push also runs e2e, so CI can be shorter."
```

**Detection** (when fields are omitted): the skill will try to infer sensible defaults.

- `default_branch`: `git symbolic-ref refs/remotes/origin/HEAD` parsed to the branch name; fallback `main`.
- `tools.task_runner`: presence of `mise.toml` → `mise run`; else `Makefile` → `make`; else `package.json` → `pnpm run` (or `npm run`); else error and ask the user.
- `paths.*`: existence of `docs/superpowers/specs/` etc.
- `project_name`: repo directory basename.

Detection is best-effort. Explicit config in `.claude/autopilot.local.md` always wins.

## Step sequence (universal, parameterized)

The skill's ten steps are identical to Klassenzeit's `autopilot.md` today (reference: `/home/pascal/Code/Klassenzeit/.claude/commands/autopilot.md`). Abbreviated:

0. **Establish skill discipline.** Invoke `superpowers:using-superpowers`.
1. **Prepare workspace.** Ensure clean branch off `{{default_branch}}`.
2. **Brainstorm** (sequential, self-answered). Wipe `{{scratch_dir}}`; invoke `superpowers:brainstorming`; work the Q&A into `{{scratch_dir}}/brainstorm.md`; format-verify gate.
3. **Write the spec.** Path `{{paths.specs}}/YYYY-MM-DD-<topic>-design.md`. Self-review. Commit `docs: add <topic> design spec`.
4. **Write the plan.** Invoke `superpowers:writing-plans`. Path `{{paths.plans}}/YYYY-MM-DD-<topic>.md`. Commit `docs: add <topic> implementation plan`.
5. **Execute.** Invoke `superpowers:test-driven-development`, then `superpowers:subagent-driven-development`. Every plan task runs in a fresh subagent; `{{tools.task_runner}} {{tools.lint}}` + `{{tools.task_runner}} {{tools.test}}` before each commit.
6. **Finalize docs.** Invoke `claude-md-management:revise-claude-md` then `claude-md-management:claude-md-improver`. Update ADRs, architecture docs, README commands table, and `{{paths.open_things}}`.
7. **Skill audit, then open PR.** Re-read the required-skill-invocations table; confirm each was called this session; fix any missing before pushing. `git push -u {{git.remote}} <branch>`; `gh pr create --base {{git.pr_base}}`. Run `hooks.post_brainstorm` if defined.
8. **CI loop.** Poll `gh pr checks`; diagnose failures via `gh run view`; fix and push until green.
9. **DO NOT MERGE.** Stop. Report the PR URL. Do not run `gh pr merge` unless the user explicitly asks.
10. **Self-review + improvement pass.** Invoke `claude-md-management:revise-claude-md`, then `claude-md-management:claude-md-improver`, then `less-permission-prompts`. Note workflow improvements back into `plugins/autopilot/skills/autopilot/SKILL.md` in a follow-up PR.

## Required skill invocations (universal table)

The skill ships with this table hard-coded. Projects can `additional_required_skills` via config; they cannot remove rows.

| Step | Skill | Purpose |
|---|---|---|
| 0 | `superpowers:using-superpowers` | Establish skill discipline |
| 2 | `superpowers:brainstorming` | Structure Q&A and spec template |
| 4 | `superpowers:writing-plans` | Structure the implementation plan |
| 5 | `superpowers:test-driven-development` | Enforce red-green-refactor per chunk |
| 5 | `superpowers:subagent-driven-development` | Dispatch every plan task to a fresh subagent |
| 6 | `claude-md-management:revise-claude-md` | Capture session learnings into CLAUDE.md files |
| 6 | `claude-md-management:claude-md-improver` | Audit CLAUDE.md files after revision |
| 10 | `claude-md-management:revise-claude-md` | Capture post-CI learnings |
| 10 | `claude-md-management:claude-md-improver` | Second audit pass |
| 10 | `less-permission-prompts` | Scan transcript, tighten `.claude/settings.json` |

If any listed skill is unavailable in the current environment, the skill says so explicitly in the end-of-turn summary and skips only that entry. Never silently drop a row.

## Invariants (universal, non-negotiable)

Codified in `plugins/autopilot/skills/autopilot/invariants.md` and referenced from `SKILL.md`:

1. **Never merge the PR.** End on green CI and ping the user.
2. **Never skip hooks** (`--no-verify`, `--no-gpg-sign`, `LEFTHOOK=0`). Fix the underlying issue.
3. **Never add AI attribution.** No "Generated with", no "Co-Authored-By: Claude".
4. **Every commit is Conventional Commits compliant** (types from `commit.allowed_types`, subject lowercase).
5. **No em-dashes or en-dashes in prose.** Per the owner's global style.
6. **Never synthesize a skill's output freehand.** Calling the `Skill` tool is mandatory for any step that names a skill.

Projects can add further invariants via the markdown body of `.claude/autopilot.local.md`, but they cannot weaken these.

## Extension hooks

Five extension points, all optional, all configured in `hooks:`:

| Hook | Fires when | Typical use |
|---|---|---|
| `post_spec` | After the spec commit in step 3 | Extra validation, post the spec to Confluence |
| `post_plan` | After the plan commit in step 4 | Notify a PM, generate a Linear ticket |
| `post_implementation` | After the last implementation commit in step 5 | Run a project-specific smoke test beyond `{{tools.test}}` |
| `post_pr` | After `gh pr create` succeeds in step 7 | Klassenzeit's `post_brainstorm_comments.py`, notify Slack |
| `post_ci_green` | After step 8 turns green | Optional tag, optional auto-deploy trigger |

Each hook value is either a shell command or a slash-command reference. The skill templates `{{pr}}`, `{{branch}}`, `{{spec_path}}`, `{{plan_path}}` variables into the command before invocation. Hook failures are reported but do not block the workflow unless marked `fail_fast: true` on the hook.

## Migration plan

### Klassenzeit

1. Land the plugin in `pgoell-claude-tools` (feature PR; keeps Klassenzeit untouched).
2. Install the plugin locally (`/plugin install autopilot@pgoell-claude-tools`).
3. In Klassenzeit, add `.claude/autopilot.local.md` with Klassenzeit's specifics:
   - `default_branch: master`
   - `scratch_dir: /tmp/kz-brainstorm`
   - `project_name: klassenzeit`
   - `hooks.post_pr: "python3 .claude/commands/post_brainstorm_comments.py {{pr}}"`
4. Replace `.claude/commands/autopilot.md` with the thin wrapper that invokes `pgoell-claude-tools:autopilot`.
5. Smoke-test on a trivial topic (e.g. a docs-only commit) before the next real `autopilot` run.
6. Delete the old inline `autopilot.md` body; keep only the wrapper.

### sieve

1. Wait until sieve's Phase 0 is ready to begin (the repo needs at least `.claude/CLAUDE.md`, which it now has).
2. Add `.claude/autopilot.local.md` with sieve's specifics:
   - `default_branch: main`
   - `project_name: sieve`
   - No `post_pr` hook needed for v1.
3. Add the thin wrapper at `.claude/commands/autopilot.md`.
4. First autopilot run is the Phase 0 repo-scaffold item from OPEN_THINGS.

## Testing

- **Skill-triggering test** in `tests/skill-triggering/`: verify `/autopilot`-style prompts ("run the autopilot for X", "autonomously ship a feature that...", "use autopilot to...") trigger the skill, and that adjacent prompts ("brainstorm X", "write a plan for X" on its own) do NOT.
- **Smoke test** in `tests/integration/`: a minimal end-to-end run against a disposable git repo (`/tmp/autopilot-smoke-<timestamp>/`), seeded with a fake `.claude/autopilot.local.md`, with all skill invocations stubbed to noops and all shell commands captured. Asserts: correct branch created, spec + plan files created at the right paths, skill audit table enumerated, no hooks skipped, commit types valid.
- **Config schema test** in `tests/unit/`: the skill parses a matrix of valid and invalid configs; reports sensible errors for unknown fields, missing required fields, invalid hook syntax.
- **No live-run test against Klassenzeit or sieve in CI.** Those are manual validations during migration.

## Non-goals for v1

- **Arbitrary workflow replacement.** Autopilot assumes the 10-step shape. Projects that want a different workflow write their own skill.
- **Cross-repo orchestration.** Changes to sieve AND pgoell-claude-tools in one autopilot run: not supported; run autopilot twice.
- **GUI config editor.** Config is YAML in a markdown file; hand-edited.
- **Non-git VCS.** Assumes `git` + `gh`.
- **Complex conditional flows.** Hooks are simple commands; there is no DSL for branching logic.

## Future work

- **More workflow skills in the same plugin.** If `/review-pr` or `/ship` emerge as useful, co-locate them in `plugins/autopilot/skills/` so they share config and hook infrastructure.
- **Config inheritance.** Allow `.claude/autopilot.local.md` to `extends: ../shared/autopilot.local.md` for monorepo-like setups.
- **Dry-run mode.** A `--dry-run` flag that prints each step's planned action without executing, to help Pascal audit changes to the skill itself.
- **Marketplace polish.** Generic README, sample config, third-party friendly defaults. Useful if the skill ever becomes shareable.
- **Workflow telemetry** (opt-in). Count of autopilot runs per project, PR-to-green-CI time, skill-audit-catch rate. Useful for tuning the workflow itself.

## Open questions

1. **Where do step templates live: inline in `SKILL.md` or separate files?** The writing skill uses separate phase prompts; autopilot's steps are smaller but still distinct. Separate files cleaner; one file easier to read. Suggest: start inline in `SKILL.md`, split when `SKILL.md` passes ~500 lines.
2. **Should the universal required-skills table be in `SKILL.md` or its own file?** Same tradeoff. If in its own file, easier to diff across plugin versions. Suggest: own file (`required-skills.md`), sourced from `SKILL.md`.
3. **Does the skill own the `.claude/commands/autopilot.md` wrapper template, and if so, how does a new project get it?** Options: (a) manual copy-paste from the plugin README; (b) a `plugin-dev:install` helper that scaffolds the wrapper into the current project; (c) a `/pgoell-claude-tools:autopilot init` subcommand. (a) is fine for v1.
4. **What happens if a project is in a git worktree?** Step 1 currently assumes a simple branch checkout. Worktree support likely needs different handling. Flag as a non-goal for v1; add in a minor follow-up if it bites.

## Success criteria for v1

- `plugins/autopilot/` plugin exists in `pgoell-claude-tools` with a passing `superpowers:plugin-validator` check.
- Klassenzeit's next autopilot run uses the plugin's skill (not its inline `autopilot.md`) and produces the same PR shape (spec + plan + implementation + brainstorm comments + green CI).
- Klassenzeit's `.claude/commands/autopilot.md` is shrunk to the thin wrapper shape; no step logic remains in the project.
- Sieve's Phase 0 scaffold PR is shipped via `/autopilot` using the plugin, with only `.claude/autopilot.local.md` as sieve-specific config.
- Skill-triggering tests pass for both positive and negative prompts.
- Smoke test produces the expected branch, commits, and hook invocations on a disposable repo.
