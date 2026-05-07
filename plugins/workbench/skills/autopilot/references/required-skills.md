# Workbench Autopilot Required Skills

The universal table that the autopilot skill walks at the pre-PR audit. Profiles can extend or replace rows through a `## Required skills` section in `.workbench/autopilot.md`, but cannot remove rows.

## Universal table (defaults)

| Step | Skill | Notes |
|---|---|---|
| 0 | `workbench:using-workbench` | session-start meta, workbench-native fork |
| 2 | `workbench:brainstorming` | already ported into workbench |
| 3 | `workbench:writing-spec` | already ported into workbench |
| 4 | `workbench:writing-plans` | already ported into workbench |
| 5 | `workbench:test-driven-development` | ported into workbench |
| 5 | `superpowers:subagent-driven-development` | not yet ported |
| 6 | `agent-system-management:capturing-session-learnings` | cross-plugin |
| 6 | `agent-system-management:improving-instructions` | cross-plugin |
| pre-PR | `workbench:verification-before-completion` | verify before push and PR readiness claims |

These are the rows shipped with Workbench. As more skills are ported into workbench, this table flips them to `workbench:*`.

`fewer-permission-prompts` is intentionally not in the universal table. It is Claude-Code-specific (touches `.claude/settings.json`) and an optimization rather than a discipline gate. Projects that want it can add it via `additional` (see below).

## Replace and additional semantics

Profiles override the table through a `## Required skills` heading shaped like this:

```md
## Required skills
| Step | Skill | Action |
|---|---|---|
| <n> | <skill-id> | replaces <existing-skill-id> |
| <n> | <skill-id> | additional |
```

### Replace

A row whose `Action` column says `replaces <skill-id>` swaps which skill fulfills an existing step. The audit walks the replacement instead of the universal row.

Example:

```md
| 4 | my-project:writing-plans | replaces workbench:writing-plans |
```

This says "for step 4, audit `my-project:writing-plans` instead of `workbench:writing-plans`." The other six universal rows are unchanged.

### Additional

A row whose `Action` column is `additional` adds a new mandatory skill at a step. The audit walks the universal row(s) for that step AND the additional row.

Example:

```md
| 6 | my-project:custom-changelog | additional |
```

This says "at step 6, in addition to `capturing-session-learnings` and `improving-instructions`, also audit `my-project:custom-changelog`."

### Removal not supported

Profiles cannot remove a row from the universal table. The discipline floor is fixed across projects.

## Audit walk

At the pre-PR audit (between step 6 and step 7):

1. Read the universal table from this file.
2. Read the profile's `## Required skills` section if present.
3. For each universal row, if the profile has a `replaces` row matching the step and target, audit the replacement; otherwise audit the universal row.
4. Audit any `additional` rows from the profile.
5. Re-read the profile's `## Project-specific rules` section. If any rule names a skill or command that should have been invoked, confirm it was.
6. Re-read the project's `CLAUDE.md` and `AGENTS.md`. If either documents skill discipline naming a specific skill at a specific step, confirm it was invoked.

If any required invocation is missing: invoke the skill now, let it reshape the artifact it governs, commit the correction, and only then proceed to step 7.
