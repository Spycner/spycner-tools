# Agent System Management — Plugin Rename Design

**Status:** Approved by Pascal Göllner on 2026-05-05.
**Branch:** `feat/claude-code-management-creating-skills`.
**PR:** [#31](https://github.com/pgoell/pgoell-claude-tools/pull/31) (in-flight; this design refactors that PR).

## Why

PR #31 introduces a new `claude-code-management` plugin housing one `creating-skills` skill, parallel to the existing `agents-md-management` plugin. Two plugins overlap in scope ("things you do to configure and extend the host agent"). Folding them into one plugin keeps the marketplace tidy and gives future siblings (`creating-agents`, `creating-hooks`, `creating-commands`, `creating-mcp-servers`) a natural home.

## Decisions

### Plugin name and version

- Rename `agents-md-management` to `agent-system-management`.
- Bump `agent-system-management` from `0.1.1` to `0.2.0` (minor, pre-1.0 — meaningful new skill plus rename).
- Delete `plugins/claude-code-management/` outright (no shim, no redirect — neither plugin has shipped at `1.0.0`).
- Bump `workbench` from `0.4.0` to `0.4.1` (patch, autopilot's internal references updated; external behavior unchanged).

### Skill names (gerund-style throughout)

| Old skill ID | New skill ID |
|---|---|
| `claude-code-management:creating-skills` | `agent-system-management:creating-skills` |
| `agents-md-management:agents-md-improver` | `agent-system-management:improving-instructions` |
| `agents-md-management:agents-md-session-capture` | `agent-system-management:capturing-session-learnings` |

Skill body content (descriptions, headings, sections) preserved. Only the frontmatter `name:` field and the directory name change. The two existing skills still target AGENTS.md / CLAUDE.md files; that focus stays in the description text.

### Slash-command triggers (unchanged)

`/revise-agents-md` and `/revise-claude-md` stay as trigger phrases inside the `capturing-session-learnings` skill description. They are user-facing muscle memory, not skill identifiers.

## Target plugin layout

```
plugins/agent-system-management/
  .claude-plugin/plugin.json          # name: agent-system-management, version: 0.2.0
  .codex-plugin/plugin.json           # name + interface refreshed
  LICENSE                             # unchanged (MIT)
  NOTICE                              # plugin name + skill names refreshed; upstream attribution preserved
  README.md                           # rewritten: broader scope, three skills
  skills/
    creating-skills/                  # moved from plugins/claude-code-management/
      SKILL.md
      references/{templates,test-patterns,iteration-loop,pressure-testing,description-optimization}.md
    improving-instructions/           # renamed from agents-md-improver
      SKILL.md                        # frontmatter name: updated; body preserved
    capturing-session-learnings/      # renamed from agents-md-session-capture
      SKILL.md                        # frontmatter name: updated; body preserved
```

## Manifests

`plugins/agent-system-management/.claude-plugin/plugin.json`:

```json
{
  "name": "agent-system-management",
  "version": "0.2.0",
  "description": "Audit AGENTS.md / CLAUDE.md, capture session learnings, and create Claude Code / Codex skills.",
  "author": { "name": "Pascal Göllner" },
  "license": "MIT",
  "keywords": ["agents-md", "claude-md", "memory", "audit", "session-capture",
               "skill-creation", "skill-lifecycle", "plugin-development",
               "claude-code", "codex"]
}
```

`plugins/agent-system-management/.codex-plugin/plugin.json`: same root fields plus `"skills": "./skills/"` and `interface` block:

- `displayName`: `"Agent System Management"`
- `shortDescription`: `"Manage agent instructions and create skills"`
- `longDescription`: `"Audit and update AGENTS.md / CLAUDE.md across project and user scopes, capture session learnings, and scaffold/iterate/pressure-test new Claude Code and Codex skills."`
- `developerName`: `"Pascal Göllner"`
- `category`: `"Productivity"`
- `capabilities`: `["Interactive", "Read", "Write"]`
- `defaultPrompt`: existing three audit/capture prompts plus `"Scaffold a new skill for plugin X"`
- `screenshots`: `[]`

## Marketplace registries

`.claude-plugin/marketplace.json`:
- Update `agents-md-management` entry to `name: "agent-system-management"`, `source: "./plugins/agent-system-management"`, refreshed description and keywords if those fields are present in the entry.
- Delete the `claude-code-management` entry entirely.

`.agents/plugins/marketplace.json`:
- Update `agents-md-management` entry: `name`, `path`, plus inline `interface.displayName` (`"Agent System Management"`) and `interface.shortDescription` (`"Manage agent instructions and create skills"`).
- Delete the `claude-code-management` entry and its inline interface block.

## Autopilot updates (cross-plugin references)

`plugins/workbench/skills/autopilot/SKILL.md`:
- Line 49 (table row): `agents-md-management:agents-md-session-capture` -> `agent-system-management:capturing-session-learnings`; `agents-md-management:agents-md-improver` -> `agent-system-management:improving-instructions`.
- Lines 157, 158 (skill invocations): same swap.
- Line 168 (inline prompt referencing both skills): same swap.

`plugins/workbench/skills/autopilot/references/required-skills.md`:
- Lines 14, 15 (cross-plugin table rows): same swap.
- Line 55 (example section): same swap.

`plugins/workbench/.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`: bump version `0.4.0` to `0.4.1`.

## Root documentation

`AGENTS.md` (canonical; `CLAUDE.md` symlinks to it):
- Plugins table line 47: row updated to `agent-system-management | 0.2.0 | creating-skills, improving-instructions, capturing-session-learnings`.
- Plugins table line 49: `claude-code-management` row deleted.
- Tip line 53: `claude-code-management:creating-skills` -> `agent-system-management:creating-skills`.

`README.md`:
- Skills index table (lines 9, 20, 24): three rows refreshed with new plugin name and new skill names.
- `### agents-md-management` section header (line 67) -> `### agent-system-management`.
- Skills under it: add `creating-skills`, rename the other two.
- `### claude-code-management` section (line 86): deleted, content merged into the section above.
- `/plugin install` blocks (lines 104, 106): consolidated to one command, `/plugin install agent-system-management@pgoell-claude-tools`.
- Picker list (line 125): replace both old plugin names with single `agent-system-management` entry.

## Tests

Renames and edits:
- `tests/unit/test-agents-md-skills.sh` -> `tests/unit/test-instruction-skills.sh`. Internal references updated to `agent-system-management:improving-instructions` and `agent-system-management:capturing-session-learnings`. Both skills stay in one file (shared domain).
- `tests/unit/test-creating-skills-skill.sh`: filename unchanged; internal references updated from `claude-code-management:creating-skills` to `agent-system-management:creating-skills`.
- `tests/unit/test-workbench-autopilot-skill.sh` (lines 70, 186 to 188): old skill IDs swapped to new ones.
- `tests/unit/test-codex-plugin-structure.sh` (line 23 plugin loop): replace `agents-md-management` with `agent-system-management`; remove `claude-code-management` from the list.
- `tests/skill-triggering/prompts/creating-skills-*.txt`: contents unchanged; the skill name did not change.

## Spec and plan docs

`docs/superpowers/specs/2026-05-05-workbench-autopilot-port-design.md` and `docs/superpowers/plans/2026-05-05-workbench-autopilot-pr2-autopilot-skill.md`:
- Update old `agents-md-management:*` ID references to new `agent-system-management:*` IDs. These are this week's working specs that future plans will build on, so they reflect current truth.
- Upstream Anthropic `claude-md-management:*` references in those docs are unrelated to this rename and stay as-is.

## Verification gate (run before pushing the refactor commit)

1. `bash tests/unit/test-skill-frontmatter-yaml.sh` passes for every SKILL.md in `plugins/agent-system-management/skills/`.
2. `bash tests/unit/test-instruction-skills.sh` (renamed file) passes.
3. `bash tests/unit/test-creating-skills-skill.sh` passes with new plugin ID.
4. `bash tests/unit/test-workbench-autopilot-skill.sh` passes (autopilot now references new IDs).
5. `bash tests/unit/test-codex-plugin-structure.sh` passes for renamed plugin, no entry for the deleted plugin.
6. `jq` parses cleanly: both manifests in `plugins/agent-system-management/`, both marketplace files.
7. Grep gate: zero hits for the strings `agents-md-management`, `agents-md-improver`, `agents-md-session-capture`, `claude-code-management` anywhere outside `.git/`, `.claude/plugins/cache/` (read-only upstream snapshot), `.worktrees/`, and this design doc itself.

## Out of scope

- No new `/improve-instructions` or `/create-skill` slash-command aliases.
- No edits to skill bodies beyond frontmatter `name:` fields. Internal headings, descriptions, and sections preserved.
- No upstream attribution changes. The AGENTS.md improver and session-capture lineage from Anthropic's `claude-md-management` (Isabella He, MIT) holds.
- No version bumps for any other plugin in the marketplace.
- Future siblings `creating-agents`, `creating-hooks`, `creating-commands`, `creating-mcp-servers` are mentioned as fitting the new plugin's scope but are not built in this PR.
