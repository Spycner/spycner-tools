# Workbench Autopilot Profile Schema

This document defines the convention for `.workbench/autopilot.md` files in projects that use the `workbench:autopilot` skill.

## What goes in the profile

Workbench owns the reusable autopilot loop (the ten steps, the audit, the invariants). Projects own their local reality through this profile. The profile is intentionally small: most project information that autopilot needs (default branch, task runner, paths) is already documented in `CLAUDE.md` or `AGENTS.md` and reaches the agent through regular session context. The profile carries the autopilot-specific bits that don't naturally belong in a project's root memory file: PR behavior, hooks, audit-table overrides.

## Discovery (v1)

The autopilot skill looks for **one** file: `.workbench/autopilot.md` in the repo root. Missing file is a hard stop; autopilot refuses to run and points the user at the example profile.

The broader fallback chain enumerated in issue 23 (`AGENTS.md`, `CLAUDE.md`, `README.md`, `.workbench/autopilot.yaml|yml`) is **deferred**. None of those branches are walked in v1. They are documented here as future enumerations:

- `.workbench/autopilot.yaml` and `.workbench/autopilot.yml`: enable when there is a concrete parser-consuming use case (validation script, profile linter).
- `AGENTS.md` / `CLAUDE.md` / `README.md` fallback: enable when there is demand for "autopilot in a repo without a `.workbench/` directory."

Until then, projects that want autopilot create `.workbench/autopilot.md` explicitly.

## Markdown-first stance (no parser)

Headings are conventions, not contracts. Both Claude Code and Codex consume the profile as prompt context; there is no parser anywhere. The autopilot skill reads the recommended shape and extracts what it needs section by section.

YAML support is deferred until a concrete parser-consuming use case exists.

## Profile shape

### Recommended minimum

```md
# Workbench Autopilot Profile

## PR behavior
Mode: stop_at_green
```

This is the suggested starting point. Adoption is explicit (you opted in by creating the file); the body is overrides on defaults.

### Truly minimal (also valid)

An empty `.workbench/autopilot.md` is valid. Presence of the file is the opt-in signal.

### Full heading vocabulary (all optional)

```md
# Workbench Autopilot Profile

## Project name
<short slug; defaults to repo dir basename>

## Branching
Default branch: <name>
Branch prefixes: <feat, fix, docs, chore, refactor, test, perf, style, ci, build, revert>

## Commands
Task runner: <mise run | make | pnpm run | npm run>
Lint: <command suffix>
Test: <command suffix>
Format: <command suffix>

## Documentation paths
Specs: <path | don't commit>
Plans: <path | don't commit>
Open things: <file>
ADRs: <dir>

## PR behavior
Mode: <stop_at_green | automerge | request_review>
Base branch: <name; defaults to default branch>
Squash: <yes | no; defaults to yes>

Hooks:
- post_spec: <command>
- post_plan: <command>
- post_implementation: <command>
- post_pr: <command>
- post_ci_green: <command>

## Required skills
| Step | Skill | Action |
|---|---|---|
| <n> | <skill-id> | replaces <existing-skill-id> |
| <n> | <skill-id> | additional |

## Project-specific rules
<free prose; rules autopilot must respect during the run>
```

## Defaults when a section is absent

| Section | Default |
|---|---|
| `## PR behavior` | `Mode: stop_at_green`, `Base branch:` = default branch, `Squash: yes`, no hooks |
| `## Required skills` | universal table only, no overrides, no additions |
| `## Project name` | repo dir basename |
| `## Branching` | default branch detected via `git symbolic-ref refs/remotes/origin/HEAD`, fallback `master`; standard Conventional Commits prefixes |
| `## Commands` | task runner detected from `mise.toml` / `Makefile` / `package.json`; lint and test commands inferred from runner conventions |
| `## Documentation paths` | `docs/superpowers/specs`, `docs/superpowers/plans`, `docs/superpowers/OPEN_THINGS.md`, `docs/adr`; each used only if it exists. Use `don't commit` to keep generated specs or plans out of the repo. |
| `## Project-specific rules` | none beyond what `CLAUDE.md` or `AGENTS.md` provides |

## Bootstrap precedence

When the autopilot skill needs project information, it resolves each field in this order:

1. Profile section in `.workbench/autopilot.md`.
2. Session context (`CLAUDE.md`, `AGENTS.md`, both already loaded into the agent).
3. Git or filesystem detection (`git symbolic-ref`, presence of `mise.toml`, etc.).
4. Ask the user. Never guess.

A field that no source provides and the active step needs (for example, a test command in a project with neither `mise.toml` nor `Makefile` nor `package.json`) stops the workflow with a question, not a guess.

## PR behavior modes

| Mode | Behavior |
|---|---|
| `stop_at_green` | Default. Autopilot stops once CI is green and reports the PR URL. The user merges manually. |
| `automerge` | Autopilot runs `gh pr merge <pr> --auto --squash` (or `--merge` if `Squash: no`), polls until the PR state is `MERGED`, refreshes local default branch, deletes the feature branch, reports the merged commit hash. |
| `request_review` | Autopilot runs `gh pr ready <pr>` and posts a reviewer note; merge stays manual. |

## Hooks

Each hook value is a shell command. The autopilot skill substitutes `{{pr}}`, `{{branch}}`, `{{spec_path}}`, `{{plan_path}}` into the command before invocation. Hook failures are reported but do not block the workflow unless the project's `## Project-specific rules` section says otherwise.

| Hook | Fires when |
|---|---|
| `post_spec` | After the spec commit in step 3 |
| `post_plan` | After the plan commit in step 4 |
| `post_implementation` | After the last implementation commit in step 5 |
| `post_pr` | After `gh pr create` succeeds in step 7 |
| `post_ci_green` | After step 8 turns green |

## Required-skills overrides

The profile's `## Required skills` table supports two operations on the autopilot skill's universal required-skills table (defined in `references/required-skills.md` once PR 2 lands):

- **Replace.** A row matching an existing step swaps which skill fulfills it. Example: `Step 4 | workbench:writing-plans | replaces superpowers:writing-plans`. The audit walks the replacement instead of the universal row.
- **Additional.** A row marked `additional` adds a new mandatory skill at a step. Example: `Step 6 | my-project:custom-changelog | additional`. The audit walks the universal row and the additional row.

Removal is not supported. The profile cannot weaken the universal discipline floor.

## Audit semantics

When the autopilot skill walks its pre-PR audit, it covers:

1. The universal required-skills table merged with profile `## Required skills` overrides.
2. Skill or command references in the profile's `## Project-specific rules` section.
3. Skill discipline rules in the project's `CLAUDE.md` or `AGENTS.md` that name a skill.

Anything mentioned in any of those three sources must have been invoked during the run, or the audit blocks the push.

## Authoring tips

- Omit a heading if the project's `CLAUDE.md` or `AGENTS.md` already documents the same information; the autopilot skill will source it from session context.
- Use `## Project-specific rules` for autopilot-coupled rules that don't naturally belong in `CLAUDE.md`, for example "before pytest, rebuild the PyO3 binding via `mise run solver:rebuild`."
- Keep the profile small. The kitchen-sink example exists to show all the dials, not as a target.

## See also

- `example-project-profile.md`: minimal and kitchen-sink examples.
- `../SKILL.md` (lands in PR 2): the autopilot skill that consumes the profile.
- Issue 23 in this repo's tracker: the strategic motivation for the kernel-vs-policy split.
