# Agent System Management Rename Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fold `claude-code-management` (one skill: `creating-skills`) into a renamed `agent-system-management` plugin, rename the two existing AGENTS.md/CLAUDE.md skills to gerund-style names, and propagate the rename through every cross-reference (autopilot, marketplaces, root docs, tests) so the verification gate passes cleanly. One coordinated refactor commit.

**Architecture:** Filesystem moves first (`git mv`), then in-file edits inside the moved plugin directory, then cross-cutting references (top-level marketplaces, workbench autopilot, root docs, test scripts), then verification, then a single commit. The spec at `docs/workbench/specs/2026-05-05-agent-system-management-rename-design.md` is the source of truth; this plan adds execution order, exact edit pairs, and verification commands.

**Tech Stack:** Claude Code plugin manifests, Codex plugin manifests, `git mv`, `jq`, bash test harness.

**Spec reference:** `docs/workbench/specs/2026-05-05-agent-system-management-rename-design.md`. Anchors there are pre-edit line numbers; this plan uses content-pattern anchors that survive intermediate edits.

---

### Task 1: Move and rename plugin and skill directories

**Files:**
- Move: `plugins/agents-md-management/` -> `plugins/agent-system-management/`
- Move (within renamed plugin): `skills/agents-md-improver/` -> `skills/improving-instructions/`
- Move (within renamed plugin): `skills/agents-md-session-capture/` -> `skills/capturing-session-learnings/`
- Move: `plugins/claude-code-management/skills/creating-skills/` -> `plugins/agent-system-management/skills/creating-skills/`
- Delete: `plugins/claude-code-management/` (entire directory after `creating-skills` is moved out)

- [ ] **Step 1: Confirm pre-state on disk**

```bash
ls plugins/agents-md-management/skills/
ls plugins/claude-code-management/skills/
```

Expected first command: `agents-md-improver  agents-md-session-capture`. Expected second command: `creating-skills`.

- [ ] **Step 2: Rename the plugin directory**

```bash
git mv plugins/agents-md-management plugins/agent-system-management
```

- [ ] **Step 3: Rename the two existing skill directories**

```bash
git mv plugins/agent-system-management/skills/agents-md-improver \
       plugins/agent-system-management/skills/improving-instructions
git mv plugins/agent-system-management/skills/agents-md-session-capture \
       plugins/agent-system-management/skills/capturing-session-learnings
```

- [ ] **Step 4: Move `creating-skills` into the renamed plugin**

```bash
git mv plugins/claude-code-management/skills/creating-skills \
       plugins/agent-system-management/skills/creating-skills
```

- [ ] **Step 5: Delete the now-empty `claude-code-management` plugin**

```bash
git rm -r plugins/claude-code-management
```

After Steps 2-4 the only tracked content remaining in this directory is `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` (no LICENSE / README / NOTICE in this plugin). `git rm -r` removes both manifests and stages the deletions in one shot, which keeps the eventual commit clean. The spec is explicit: no shim, no redirect, no preserved content.

- [ ] **Step 6: Verify the post-move filesystem**

```bash
ls plugins/agent-system-management/skills/
test ! -e plugins/claude-code-management && echo "claude-code-management removed"
test ! -e plugins/agents-md-management && echo "agents-md-management removed"
git status --short | head -40
```

Expected `ls`: `capturing-session-learnings  creating-skills  improving-instructions`. Both `test` lines print their confirmation. `git status` shows the renames as `R  ` lines.

NOTE: do not commit. The plugin manifests and SKILL.md frontmatter inside still say `agents-md-management` / `agents-md-improver` / `agents-md-session-capture` and tests will fail until later tasks land.

---

### Task 2: Update plugin manifests inside the renamed plugin

**Files:**
- Modify: `plugins/agent-system-management/.claude-plugin/plugin.json`
- Modify: `plugins/agent-system-management/.codex-plugin/plugin.json`

- [ ] **Step 1: Replace the Claude Code manifest**

Overwrite `plugins/agent-system-management/.claude-plugin/plugin.json` with:

```json
{
  "name": "agent-system-management",
  "version": "0.2.0",
  "description": "Audit AGENTS.md / CLAUDE.md, capture session learnings, and create Claude Code / Codex skills.",
  "author": { "name": "Pascal Göllner" },
  "license": "MIT",
  "keywords": ["agents-md", "claude-md", "memory", "audit", "session-capture", "skill-creation", "skill-lifecycle", "plugin-development", "claude-code", "codex"]
}
```

- [ ] **Step 2: Replace the Codex manifest**

Overwrite `plugins/agent-system-management/.codex-plugin/plugin.json` with:

```json
{
  "name": "agent-system-management",
  "version": "0.2.0",
  "description": "Audit AGENTS.md / CLAUDE.md, capture session learnings, and create Claude Code / Codex skills.",
  "author": { "name": "Pascal Göllner" },
  "license": "MIT",
  "keywords": ["agents-md", "claude-md", "memory", "audit", "session-capture", "skill-creation", "skill-lifecycle", "plugin-development", "claude-code", "codex"],
  "skills": "./skills/",
  "interface": {
    "displayName": "Agent System Management",
    "shortDescription": "Manage agent instructions and create skills",
    "longDescription": "Audit and update AGENTS.md / CLAUDE.md across project and user scopes, capture session learnings, and scaffold/iterate/pressure-test new Claude Code and Codex skills.",
    "developerName": "Pascal Göllner",
    "category": "Productivity",
    "capabilities": ["Interactive", "Read", "Write"],
    "defaultPrompt": [
      "Audit my CLAUDE.md and AGENTS.md files",
      "Update AGENTS.md with what we learned this session",
      "Check if my agent instructions are up to date",
      "Scaffold a new skill for plugin X"
    ],
    "screenshots": []
  }
}
```

- [ ] **Step 3: Verify both manifests parse**

```bash
jq empty plugins/agent-system-management/.claude-plugin/plugin.json && echo "claude OK"
jq empty plugins/agent-system-management/.codex-plugin/plugin.json && echo "codex OK"
jq -r '.name, .version' plugins/agent-system-management/.claude-plugin/plugin.json
jq -r '.name, .version' plugins/agent-system-management/.codex-plugin/plugin.json
```

Expected: both `jq empty` calls succeed. Both `jq -r` calls print `agent-system-management` then `0.2.0`.

---

### Task 3: Update SKILL.md frontmatter for the two renamed skills

**Files:**
- Modify: `plugins/agent-system-management/skills/improving-instructions/SKILL.md`
- Modify: `plugins/agent-system-management/skills/capturing-session-learnings/SKILL.md`

The skill bodies (descriptions, headings, sections) stay verbatim. Only the frontmatter `name:` field changes.

- [ ] **Step 1: Rename the `improving-instructions` skill in frontmatter**

Find:

```
name: agents-md-improver
```

Replace with:

```
name: improving-instructions
```

In `plugins/agent-system-management/skills/improving-instructions/SKILL.md`.

- [ ] **Step 2: Rename the `capturing-session-learnings` skill in frontmatter**

Find:

```
name: agents-md-session-capture
```

Replace with:

```
name: capturing-session-learnings
```

In `plugins/agent-system-management/skills/capturing-session-learnings/SKILL.md`.

- [ ] **Step 3: Verify `creating-skills` frontmatter is unchanged**

```bash
grep '^name:' plugins/agent-system-management/skills/creating-skills/SKILL.md
```

Expected: `name: creating-skills` (unchanged; the skill ID did not change, only its plugin moved).

- [ ] **Step 4: Verify all three frontmatters**

```bash
for s in improving-instructions capturing-session-learnings creating-skills; do
  grep '^name:' "plugins/agent-system-management/skills/$s/SKILL.md"
done
```

Expected:

```
name: improving-instructions
name: capturing-session-learnings
name: creating-skills
```

---

### Task 4: Rewrite plugin README.md and refresh NOTICE

**Files:**
- Modify: `plugins/agent-system-management/README.md` (full rewrite for the broader three-skill scope)
- Modify: `plugins/agent-system-management/NOTICE` (header rename, skill paths refreshed; upstream attribution preserved verbatim)
- Unchanged: `plugins/agent-system-management/LICENSE` (MIT, no edits)

- [ ] **Step 1: Replace the README**

Overwrite `plugins/agent-system-management/README.md` with:

````markdown
# agent-system-management

Manage the host agent's instruction layer and skill layer in any runtime: audit and update `AGENTS.md` / `CLAUDE.md` files (and their variants), capture session learnings, and scaffold or iterate on Claude Code / Codex skills.

Three skills:

| | Purpose | Triggered by |
|---|---|---|
| `improving-instructions` | Periodic cold audit of agent-instruction files | "audit my CLAUDE.md", "check if AGENTS.md is up to date" |
| `capturing-session-learnings` | End-of-session warm capture of learnings | "/revise-agents-md", "update AGENTS.md with what we learned this session" |
| `creating-skills` | Full skill lifecycle (scaffold, iterate, pressure-test, optimize description, extract from session) | "scaffold a new skill", "iterate on this skill", "pressure-test", "turn this conversation into a skill" |

Works in Claude Code and Codex CLI. Files are deduped via `realpath`, so `CLAUDE.md` symlinked to `AGENTS.md` counts as one logical file.

## Files in scope (instruction skills)

- `AGENTS.md`, `AGENTS.local.md`
- `CLAUDE.md`, `CLAUDE.local.md`
- `.claude.md`, `.claude.local.md` (legacy lowercase from upstream)
- `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` (user-global, included so generalizable rules can be hoisted)

`GEMINI.md` and other runtime variants are out of scope.

## Usage

```text
audit my CLAUDE.md files
check if AGENTS.md is up to date
update AGENTS.md with what we learned this session
/revise-agents-md
/revise-claude-md
scaffold a new skill in this marketplace
iterate on this skill until it triggers reliably
pressure-test this discipline skill
turn this conversation into a reusable skill
```

## Credits

The `improving-instructions` and `capturing-session-learnings` skills are derived from Anthropic's [`claude-md-management`](https://github.com/anthropics/claude-plugins/tree/main/plugins/claude-md-management) plugin by Isabella He, licensed under Apache 2.0. The reference docs under `skills/improving-instructions/references/` are imported verbatim. See `NOTICE` for full attribution.

This plugin is licensed MIT (`LICENSE`).
````

- [ ] **Step 2: Update NOTICE**

In `plugins/agent-system-management/NOTICE`, apply these substitutions:

Find:

```
agents-md-management
Copyright 2026 Pascal Göllner
```

Replace with:

```
agent-system-management
Copyright 2026 Pascal Göllner
```

Find:

```
  - skills/agents-md-improver/SKILL.md
      (workflow phases, quality rubric structure, report format)
  - skills/agents-md-improver/references/quality-criteria.md (verbatim)
  - skills/agents-md-improver/references/templates.md         (verbatim)
  - skills/agents-md-improver/references/update-guidelines.md (verbatim)
  - skills/agents-md-session-capture/SKILL.md
      (adapted from upstream's /revise-claude-md slash command)
```

Replace with:

```
  - skills/improving-instructions/SKILL.md
      (workflow phases, quality rubric structure, report format)
  - skills/improving-instructions/references/quality-criteria.md (verbatim)
  - skills/improving-instructions/references/templates.md         (verbatim)
  - skills/improving-instructions/references/update-guidelines.md (verbatim)
  - skills/capturing-session-learnings/SKILL.md
      (adapted from upstream's /revise-claude-md slash command)
```

The Apache 2.0 attribution paragraph and the trailing licensing paragraph stay verbatim.

- [ ] **Step 3: Verify**

```bash
head -1 plugins/agent-system-management/NOTICE
grep -c 'skills/improving-instructions/' plugins/agent-system-management/NOTICE
grep -c 'skills/capturing-session-learnings/' plugins/agent-system-management/NOTICE
grep -c 'agents-md-' plugins/agent-system-management/NOTICE
grep -c 'agents-md-' plugins/agent-system-management/README.md
```

Expected: header is `agent-system-management`. Counts: 4, 1, 0, 0.

---

### Task 5: Update top-level marketplaces

**Files:**
- Modify: `.claude-plugin/marketplace.json`
- Modify: `.agents/plugins/marketplace.json`

- [ ] **Step 1: Update the Claude Code marketplace**

In `.claude-plugin/marketplace.json`, swap the `agents-md-management` plugin entry for an `agent-system-management` entry, and delete the `claude-code-management` entry.

Find:

```json
    {
      "name": "agents-md-management",
      "source": "./plugins/agents-md-management",
      "description": "Audit AGENTS.md and CLAUDE.md files, then capture session learnings.",
      "version": "0.1.1"
    },
    {
      "name": "workbench",
      "source": "./plugins/workbench",
      "description": "Personal Workbench skills for design and autonomous feature work.",
      "version": "0.4.0"
    },
    {
      "name": "claude-code-management",
      "source": "./plugins/claude-code-management",
      "description": "Manage Claude Code customization assets across plugins and marketplaces.",
      "version": "0.1.0"
    }
```

Replace with:

```json
    {
      "name": "agent-system-management",
      "source": "./plugins/agent-system-management",
      "description": "Audit AGENTS.md / CLAUDE.md, capture session learnings, and create Claude Code / Codex skills.",
      "version": "0.2.0"
    },
    {
      "name": "workbench",
      "source": "./plugins/workbench",
      "description": "Personal Workbench skills for design and autonomous feature work.",
      "version": "0.4.1"
    }
```

(The workbench version bump from 0.4.0 to 0.4.1 is included here so the marketplace block lands in one edit; Task 6 covers the matching plugin manifest bumps.)

- [ ] **Step 2: Update the Codex marketplace**

In `.agents/plugins/marketplace.json`, swap the `agents-md-management` entry's `name`, `source.path`, and `interface` for the renamed plugin, and delete the entire `claude-code-management` entry.

Find:

```json
    {
      "name": "agents-md-management",
      "source": {
        "source": "local",
        "path": "./plugins/agents-md-management"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity",
      "interface": {
        "displayName": "Agents.md Management",
        "shortDescription": "Audit agent instructions and capture learnings"
      }
    },
    {
      "name": "workbench",
      "source": {
        "source": "local",
        "path": "./plugins/workbench"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity",
      "interface": {
        "displayName": "Workbench",
        "shortDescription": "Design and ship with Workbench skills"
      }
    },
    {
      "name": "claude-code-management",
      "source": {
        "source": "local",
        "path": "./plugins/claude-code-management"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity",
      "interface": {
        "displayName": "Claude Code Management",
        "shortDescription": "Scaffold, iterate, and optimize Claude Code skills"
      }
    }
```

Replace with:

```json
    {
      "name": "agent-system-management",
      "source": {
        "source": "local",
        "path": "./plugins/agent-system-management"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity",
      "interface": {
        "displayName": "Agent System Management",
        "shortDescription": "Manage agent instructions and create skills"
      }
    },
    {
      "name": "workbench",
      "source": {
        "source": "local",
        "path": "./plugins/workbench"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity",
      "interface": {
        "displayName": "Workbench",
        "shortDescription": "Design and ship with Workbench skills"
      }
    }
```

- [ ] **Step 3: Verify both marketplaces**

```bash
jq empty .claude-plugin/marketplace.json && echo "claude marketplace OK"
jq empty .agents/plugins/marketplace.json && echo "codex marketplace OK"
jq -r '.plugins[].name' .claude-plugin/marketplace.json | sort
jq -r '.plugins[].name' .agents/plugins/marketplace.json | sort
jq '.plugins | length' .agents/plugins/marketplace.json
```

Expected: both `jq empty` succeed. Both name lists contain `agent-system-management` and `workbench`, and neither contains `agents-md-management` or `claude-code-management`. The Codex plugin count is `7` (was 8: minus `claude-code-management`, plus the renamed entry which replaces `agents-md-management`).

---

### Task 6: Update workbench autopilot cross-plugin references and bump workbench version

**Files:**
- Modify: `plugins/workbench/skills/autopilot/SKILL.md`
- Modify: `plugins/workbench/skills/autopilot/references/required-skills.md`
- Modify: `plugins/workbench/.claude-plugin/plugin.json`
- Modify: `plugins/workbench/.codex-plugin/plugin.json`

The autopilot skill mentions both AGENTS.md skills by ID in four spots (table row, two skill invocations, one inline prompt) inside SKILL.md, and three more spots inside `required-skills.md`. Each old ID swaps to the new ID.

- [ ] **Step 1: Update the autopilot SKILL.md**

In `plugins/workbench/skills/autopilot/SKILL.md`, do four targeted swaps. Each occurrence is unique because the surrounding context differs.

Swap A (the universal table row, around line 49):

Find:

```
| 6 | `agents-md-management:agents-md-session-capture` and `agents-md-management:agents-md-improver` |
```

Replace with:

```
| 6 | `agent-system-management:capturing-session-learnings` and `agent-system-management:improving-instructions` |
```

Swap B (Step 6 first sentence, around line 157):

Find:

```
1. Invoke `agents-md-management:agents-md-session-capture` via the `Skill` tool in the main session.
```

Replace with:

```
1. Invoke `agent-system-management:capturing-session-learnings` via the `Skill` tool in the main session.
```

Swap C (Step 6 second sentence, around line 158):

Find:

```
2. After session-capture has returned and its commits have landed, dispatch `agents-md-management:agents-md-improver` to a general-purpose subagent
```

Replace with:

```
2. After session-capture has returned and its commits have landed, dispatch `agent-system-management:improving-instructions` to a general-purpose subagent
```

Swap D (inline-prompt B, around line 168):

Find:

```
> "You are running inside workbench autopilot as a subagent, on the feature branch in the current working directory. Invoke `agents-md-management:agents-md-improver` via the `Skill` tool.
```

Replace with:

```
> "You are running inside workbench autopilot as a subagent, on the feature branch in the current working directory. Invoke `agent-system-management:improving-instructions` via the `Skill` tool.
```

- [ ] **Step 2: Update required-skills.md**

In `plugins/workbench/skills/autopilot/references/required-skills.md`, three swaps.

Swap A (table row 14):

Find:

```
| 6 | `agents-md-management:agents-md-session-capture` | cross-plugin |
```

Replace with:

```
| 6 | `agent-system-management:capturing-session-learnings` | cross-plugin |
```

Swap B (table row 15):

Find:

```
| 6 | `agents-md-management:agents-md-improver` | cross-plugin |
```

Replace with:

```
| 6 | `agent-system-management:improving-instructions` | cross-plugin |
```

Swap C (the "Additional" example around line 55):

Find:

```
This says "at step 6, in addition to `agents-md-session-capture` and `agents-md-improver`, also audit `my-project:custom-changelog`."
```

Replace with:

```
This says "at step 6, in addition to `capturing-session-learnings` and `improving-instructions`, also audit `my-project:custom-changelog`."
```

- [ ] **Step 3: Bump workbench plugin version 0.4.0 -> 0.4.1**

In `plugins/workbench/.claude-plugin/plugin.json`, find:

```json
  "version": "0.4.0",
```

Replace with:

```json
  "version": "0.4.1",
```

In `plugins/workbench/.codex-plugin/plugin.json`, the same edit.

(The matching marketplace bump in `.claude-plugin/marketplace.json` already landed in Task 5 Step 1.)

- [ ] **Step 4: Verify autopilot edits and version bump**

```bash
grep -c 'agents-md-management:' plugins/workbench/skills/autopilot/SKILL.md
grep -c 'agents-md-management:' plugins/workbench/skills/autopilot/references/required-skills.md
grep -c 'agent-system-management:' plugins/workbench/skills/autopilot/SKILL.md
grep -c 'agent-system-management:' plugins/workbench/skills/autopilot/references/required-skills.md
jq -r .version plugins/workbench/.claude-plugin/plugin.json
jq -r .version plugins/workbench/.codex-plugin/plugin.json
```

Expected: first two counts are `0`. SKILL.md count of new IDs is `4`, required-skills.md count is `2` (the third example reference no longer carries the plugin prefix, by design). Both versions print `0.4.1`.

---

### Task 7: Update root AGENTS.md (and via symlink, CLAUDE.md)

**Files:**
- Modify: `AGENTS.md` (canonical; `CLAUDE.md` is a symlink)

- [ ] **Step 1: Update the plugins table and tip**

In `AGENTS.md`, find:

```
| `agents-md-management` | 0.1.1 | `agents-md-improver`, `agents-md-session-capture` |
| `workbench` | 0.4.0 | `brainstorming`, `using-workbench`, `autopilot` |
| `claude-code-management` | 0.1.0 | `creating-skills` |
```

Replace with:

```
| `agent-system-management` | 0.2.0 | `improving-instructions`, `capturing-session-learnings`, `creating-skills` |
| `workbench` | 0.4.1 | `brainstorming`, `using-workbench`, `autopilot` |
```

(Skill order inside the new row: existing two skills first, then `creating-skills` last, so the lineage from the old `agents-md-management` plugin is visible. Workbench version bump rides along.)

Then find:

```
> **Tip:** The `claude-code-management:creating-skills` skill automates this entire workflow.
```

Replace with:

```
> **Tip:** The `agent-system-management:creating-skills` skill automates this entire workflow.
```

- [ ] **Step 2: Verify**

```bash
grep -c 'agents-md-management' AGENTS.md
grep -c 'claude-code-management' AGENTS.md
grep -c 'agent-system-management' AGENTS.md
test "$(readlink CLAUDE.md)" = "AGENTS.md" && echo "symlink intact"
```

Expected: first two counts are `0`. Third is at least `2` (table row plus tip; possibly more if the file has additional mentions). Symlink check passes.

---

### Task 8: Update root README.md

**Files:**
- Modify: `README.md`

The top-level README has the old IDs in the skills index, in two plugin sections, in the install commands, in the picker list, and in the setup section. The two sibling plugin sections (`### agents-md-management` and `### claude-code-management`) merge into one `### agent-system-management` section.

- [ ] **Step 1: Update the "Skills at a glance" table**

In `README.md`, find:

```
| `agents-md-improver` | agents-md-management | Audit and improve agent instruction files |
| `agents-md-session-capture` | agents-md-management | Capture session learnings into the right instruction file |
| `brainstorming` | workbench | Turn ideas into clear design decisions |
| `using-workbench` | workbench | Load Workbench skill rules and routing |
| `creating-skills` | claude-code-management | Scaffold, iterate, pressure-test, and tune skills across the full lifecycle |
```

Replace with:

```
| `improving-instructions` | agent-system-management | Audit and improve agent instruction files |
| `capturing-session-learnings` | agent-system-management | Capture session learnings into the right instruction file |
| `brainstorming` | workbench | Turn ideas into clear design decisions |
| `using-workbench` | workbench | Load Workbench skill rules and routing |
| `creating-skills` | agent-system-management | Scaffold, iterate, pressure-test, and tune skills across the full lifecycle |
```

- [ ] **Step 2: Merge the two plugin sections into one**

Find the entire block from the `### agents-md-management` heading through the end of the `### claude-code-management` section's "Skills:" list:

```
### agents-md-management

Audit agent instruction files and capture session learnings across project and user scopes.

**Skills:**
- `/pgoell-claude-tools:agents-md-improver`: Audit and improve AGENTS.md and CLAUDE.md files.
- `/pgoell-claude-tools:agents-md-session-capture`: Capture session learnings into the right instruction file.

### workbench

Workbench skills for design dialogue, skill routing, and profile driven feature shipping.

**Skills:**
- `/pgoell-claude-tools:brainstorming`: Turn ideas into clear design decisions.
- `/pgoell-claude-tools:using-workbench`: Load Workbench skill rules and routing.
- `/pgoell-claude-tools:autopilot`: Ship a feature from brainstorm to PR using a project profile.

Autopilot profiles are documented in `plugins/workbench/skills/autopilot/references/profile-schema.md`.

### claude-code-management

Owns the full Claude Code skill lifecycle: scaffold, iterate, pressure-test, optimize description, or extract from session.

**Skills:**
- `/pgoell-claude-tools:creating-skills`: Scaffold a new skill in a Claude Code or Codex marketplace, iterate on an existing one with eval loops, pressure-test discipline skills, optimize triggering, or extract a skill from this conversation.
```

Replace with:

```
### agent-system-management

Manage the host agent's instruction layer and skill layer: audit AGENTS.md / CLAUDE.md, capture session learnings, and scaffold or iterate on Claude Code / Codex skills.

**Skills:**
- `/pgoell-claude-tools:improving-instructions`: Audit and improve AGENTS.md and CLAUDE.md files.
- `/pgoell-claude-tools:capturing-session-learnings`: Capture session learnings into the right instruction file.
- `/pgoell-claude-tools:creating-skills`: Scaffold a new skill in a Claude Code or Codex marketplace, iterate on an existing one with eval loops, pressure-test discipline skills, optimize triggering, or extract a skill from this conversation.

### workbench

Workbench skills for design dialogue, skill routing, and profile driven feature shipping.

**Skills:**
- `/pgoell-claude-tools:brainstorming`: Turn ideas into clear design decisions.
- `/pgoell-claude-tools:using-workbench`: Load Workbench skill rules and routing.
- `/pgoell-claude-tools:autopilot`: Ship a feature from brainstorm to PR using a project profile.

Autopilot profiles are documented in `plugins/workbench/skills/autopilot/references/profile-schema.md`.
```

(Plugin section order changes: `agent-system-management` lands where `agents-md-management` was, and `workbench` slides up to follow it; the old `### claude-code-management` block disappears entirely.)

- [ ] **Step 3: Update the Claude Code install commands**

Find:

```
/plugin install agents-md-management@pgoell-claude-tools
/plugin install workbench@pgoell-claude-tools
/plugin install claude-code-management@pgoell-claude-tools
```

Replace with:

```
/plugin install agent-system-management@pgoell-claude-tools
/plugin install workbench@pgoell-claude-tools
```

- [ ] **Step 4: Update the Codex picker list**

Find:

```
In the picker, install `atlassian`, `google-workspace`, `research`, `writing`, `runtime-bridge`, `agents-md-management`, `workbench`, and `claude-code-management`.
```

Replace with:

```
In the picker, install `atlassian`, `google-workspace`, `research`, `writing`, `runtime-bridge`, `agent-system-management`, and `workbench`.
```

- [ ] **Step 5: Merge the Setup section**

Find:

```
### agents-md-management

No setup required. In any project, ask either skill: "audit my CLAUDE.md files" (cold audit) or "update AGENTS.md with what we learned this session" (warm capture). Operates on local agent-instruction files only; no network or auth.

### claude-code-management

No setup required. In any plugin marketplace, invoke the skill with phrases like "scaffold a new skill in this marketplace", "iterate on this skill until it triggers reliably", "pressure-test this discipline skill", "optimize the description for triggering", or "turn this conversation into a reusable skill". The skill detects the marketplace shape (Claude Code, Codex, or both) and adapts.
```

Replace with:

```
### agent-system-management

No setup required. Three skills in one plugin: ask `improving-instructions` to "audit my CLAUDE.md files" (cold audit), `capturing-session-learnings` to "update AGENTS.md with what we learned this session" (warm capture), or `creating-skills` to "scaffold a new skill in this marketplace", "iterate on this skill until it triggers reliably", "pressure-test this discipline skill", "optimize the description for triggering", or "turn this conversation into a reusable skill". The instruction skills operate on local agent-instruction files only (no network); the lifecycle skill detects the marketplace shape (Claude Code, Codex, or both) and adapts.
```

- [ ] **Step 6: Verify the README**

```bash
grep -c 'agents-md-management' README.md
grep -c 'agents-md-improver' README.md
grep -c 'agents-md-session-capture' README.md
grep -c 'claude-code-management' README.md
grep -c 'agent-system-management' README.md
grep -c 'improving-instructions' README.md
grep -c 'capturing-session-learnings' README.md
```

Expected: first four counts are `0`. The three remaining counts are non-zero (table row plus install command plus picker list plus section heading plus setup paragraph for the plugin name; one table row and one bullet each for the two new skill names).

---

### Task 9: Rename and update the AGENTS.md skills test

**Files:**
- Rename: `tests/unit/test-agents-md-skills.sh` -> `tests/unit/test-instruction-skills.sh`
- Modify: the renamed file (skill IDs, plugin paths, prompt strings)

- [ ] **Step 1: Rename the file**

```bash
git mv tests/unit/test-agents-md-skills.sh tests/unit/test-instruction-skills.sh
```

- [ ] **Step 2: Update the header comment and the `PLUGIN_ROOT` path**

In `tests/unit/test-instruction-skills.sh`, find:

```
# Test: agents-md-improver and agents-md-session-capture skills
# Verifies the skills load, mention both AGENTS.md and CLAUDE.md, include
# realpath dedup, the Platform Adaptation table, and reference docs.
```

Replace with:

```
# Test: improving-instructions and capturing-session-learnings skills
# Verifies the skills load, mention both AGENTS.md and CLAUDE.md, include
# realpath dedup, the Platform Adaptation table, and reference docs.
```

Then find:

```
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)/plugins/agents-md-management"
```

Replace with:

```
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)/plugins/agent-system-management"
```

Then find:

```
echo "=== Test: agents-md-management plugin structure ==="
```

Replace with:

```
echo "=== Test: agent-system-management plugin structure ==="
```

- [ ] **Step 3: Replace skill IDs in `for` loops and per-skill checks**

Find every `for skill in agents-md-improver agents-md-session-capture` (Tests 2, 4, 5, 6, 8 use this pattern):

Replace each with:

```
for skill in improving-instructions capturing-session-learnings; do
```

(The `do` keeps the same line. There are five occurrences. Use `replace_all` if your editor supports it; otherwise replace each in turn.)

Find:

```
    f="$PLUGIN_ROOT/skills/agents-md-improver/references/$ref"
```

Replace with:

```
    f="$PLUGIN_ROOT/skills/improving-instructions/references/$ref"
```

Find:

```
echo "Test 7: agents-md-improver references all three docs..."
body="$(cat "$PLUGIN_ROOT/skills/agents-md-improver/SKILL.md")"
```

Replace with:

```
echo "Test 7: improving-instructions references all three docs..."
body="$(cat "$PLUGIN_ROOT/skills/improving-instructions/SKILL.md")"
```

Find:

```
improver_body="$(cat "$PLUGIN_ROOT/skills/agents-md-improver/SKILL.md")"
capture_body="$(cat "$PLUGIN_ROOT/skills/agents-md-session-capture/SKILL.md")"
```

Replace with:

```
improver_body="$(cat "$PLUGIN_ROOT/skills/improving-instructions/SKILL.md")"
capture_body="$(cat "$PLUGIN_ROOT/skills/capturing-session-learnings/SKILL.md")"
```

(All other strings inside the file, e.g. `improver_body` / `capture_body` variable names, `[PASS] improver`, `[FAIL] capture`, are local variables/labels, not skill IDs; they can stay so the file keeps its terse internal vocabulary. Only the on-disk paths and the skill IDs need to track the rename.)

- [ ] **Step 4: Verify the renamed test runs cleanly**

```bash
bash tests/unit/test-instruction-skills.sh
```

Expected: every `[PASS]` line prints, no `[FAIL]`, exit code 0, final line `=== Tests complete ===`.

---

### Task 10: Update the creating-skills test

**Files:**
- Modify: `tests/unit/test-creating-skills-skill.sh` (filename unchanged; the skill name didn't change, only its plugin)

- [ ] **Step 1: Update the header comment**

Find:

```
# Test: claude-code-management:creating-skills skill structure
```

Replace with:

```
# Test: agent-system-management:creating-skills skill structure
```

- [ ] **Step 2: Update the plugin root path**

Find:

```
PLUGIN_ROOT="$REPO_ROOT/plugins/claude-code-management"
```

Replace with:

```
PLUGIN_ROOT="$REPO_ROOT/plugins/agent-system-management"
```

- [ ] **Step 3: Update the section header echo**

Find:

```
echo "=== Test: claude-code-management:creating-skills skill structure ==="
```

Replace with:

```
echo "=== Test: agent-system-management:creating-skills skill structure ==="
```

- [ ] **Step 4: Update the marketplace registration check**

Find:

```
    if jq -r '.plugins[].name' "$REPO_ROOT/$mkt" | grep -q '^claude-code-management$'; then
        echo "  [PASS] $mkt registers claude-code-management"
    else
        echo "  [FAIL] $mkt does not register claude-code-management"
        exit 1
    fi
```

Replace with:

```
    if jq -r '.plugins[].name' "$REPO_ROOT/$mkt" | grep -q '^agent-system-management$'; then
        echo "  [PASS] $mkt registers agent-system-management"
    else
        echo "  [FAIL] $mkt does not register agent-system-management"
        exit 1
    fi
```

- [ ] **Step 5: Update the Test 1 expected version**

The plugin version is now `0.2.0`, not `0.1.0`. Find:

```
# Test 1: Plugin manifests exist, parse, and are at 0.1.0
```

Replace with:

```
# Test 1: Plugin manifests exist, parse, and are at 0.2.0
```

Find:

```
echo "Test 1: Plugin manifests at 0.1.0..."
```

Replace with:

```
echo "Test 1: Plugin manifests at 0.2.0..."
```

Find:

```
    if [ "$version" != "0.1.0" ]; then
        echo "  [FAIL] $manifest version is $version, expected 0.1.0"
        exit 1
    fi
    echo "  [PASS] $manifest exists, parses, version 0.1.0"
```

Replace with:

```
    if [ "$version" != "0.2.0" ]; then
        echo "  [FAIL] $manifest version is $version, expected 0.2.0"
        exit 1
    fi
    echo "  [PASS] $manifest exists, parses, version 0.2.0"
```

(This version-bump update is implied by the plugin version bump and is necessary for the verification gate to pass; the spec covers it under "Test 11 marketplace registration" but the version assertions in Test 1 also need to track the new version. Without this edit Test 1 fails on the version comparison.)

- [ ] **Step 6: Run the test to verify**

```bash
bash tests/unit/test-creating-skills-skill.sh
```

Expected: every `[PASS]` line prints, exit code 0.

---

### Task 11: Update the workbench autopilot test

**Files:**
- Modify: `tests/unit/test-workbench-autopilot-skill.sh`

- [ ] **Step 1: Update the universal skill loop in Test 5**

Find:

```
for skill in 'workbench:using-workbench' 'workbench:brainstorming' 'superpowers:writing-plans' 'superpowers:test-driven-development' 'superpowers:subagent-driven-development' 'agents-md-management:agents-md-session-capture' 'agents-md-management:agents-md-improver'; do
```

Replace with:

```
for skill in 'workbench:using-workbench' 'workbench:brainstorming' 'superpowers:writing-plans' 'superpowers:test-driven-development' 'superpowers:subagent-driven-development' 'agent-system-management:capturing-session-learnings' 'agent-system-management:improving-instructions'; do
```

- [ ] **Step 2: Update the FAIL message strings in Test 13**

Find:

```
        echo "  [FAIL] SKILL.md still references $old_id (should have been swapped to agents-md-management)"
```

Replace with:

```
        echo "  [FAIL] SKILL.md still references $old_id (should have been swapped to agent-system-management)"
```

Find:

```
        echo "  [FAIL] required-skills.md still references $old_id (should have been swapped to agents-md-management)"
```

Replace with:

```
        echo "  [FAIL] required-skills.md still references $old_id (should have been swapped to agent-system-management)"
```

(These are only hint strings naming the destination plugin; Test 13 itself still grep-checks for the upstream `claude-md-management:*` IDs from the original autopilot port and that absence assertion is unchanged.)

- [ ] **Step 3: Bump the version assertion in Test 11 from 0.3.0 to 0.4.1**

This step is not in the spec. Test 11 has been failing against `master` since the workbench bump to 0.4.0; the rename's verification gate requires it green. Update both literals to `0.4.1`.

Find:

```
# Test 11: Plugin manifests at 0.3.0
echo "Test 11: Plugin manifests at 0.3.0..."
CCM="$REPO_ROOT/plugins/workbench/.claude-plugin/plugin.json"
CXM="$REPO_ROOT/plugins/workbench/.codex-plugin/plugin.json"
if jq -e '.version == "0.3.0"' "$CCM" >/dev/null && jq -e '.version == "0.3.0"' "$CXM" >/dev/null; then
    echo "  [PASS] both plugin manifests at 0.3.0"
else
    echo "  [FAIL] plugin manifests not at 0.3.0"
    exit 1
fi
```

Replace with:

```
# Test 11: Plugin manifests at 0.4.1
echo "Test 11: Plugin manifests at 0.4.1..."
CCM="$REPO_ROOT/plugins/workbench/.claude-plugin/plugin.json"
CXM="$REPO_ROOT/plugins/workbench/.codex-plugin/plugin.json"
if jq -e '.version == "0.4.1"' "$CCM" >/dev/null && jq -e '.version == "0.4.1"' "$CXM" >/dev/null; then
    echo "  [PASS] both plugin manifests at 0.4.1"
else
    echo "  [FAIL] plugin manifests not at 0.4.1"
    exit 1
fi
```

- [ ] **Step 4: Bump the version assertion in Test 12 from 0.3.0 to 0.4.1**

Find:

```
# Test 12: Marketplace entries at 0.3.0
echo "Test 12: Marketplace entries..."
MP="$REPO_ROOT/.claude-plugin/marketplace.json"
if jq -e '.plugins[] | select(.name == "workbench") | .version == "0.3.0"' "$MP" >/dev/null; then
    echo "  [PASS] Claude marketplace workbench at 0.3.0"
else
    echo "  [FAIL] Claude marketplace workbench not at 0.3.0"
    exit 1
fi
```

Replace with:

```
# Test 12: Marketplace entries at 0.4.1
echo "Test 12: Marketplace entries..."
MP="$REPO_ROOT/.claude-plugin/marketplace.json"
if jq -e '.plugins[] | select(.name == "workbench") | .version == "0.4.1"' "$MP" >/dev/null; then
    echo "  [PASS] Claude marketplace workbench at 0.4.1"
else
    echo "  [FAIL] Claude marketplace workbench not at 0.4.1"
    exit 1
fi
```

- [ ] **Step 5: Verify**

```bash
bash tests/unit/test-workbench-autopilot-skill.sh
```

Expected: all 13 tests print `[PASS]`, exit code 0.

---

### Task 12: Update the Codex plugin structure test

**Files:**
- Modify: `tests/unit/test-codex-plugin-structure.sh`

- [ ] **Step 1: Update the plugin loop and the expected count**

Find:

```
plugin_count="$(jq '.plugins | length' "$MARKETPLACE")"
[ "$plugin_count" -eq 7 ] || fail "Expected 7 Codex marketplace plugins, got $plugin_count"

for plugin in atlassian google-workspace research writing runtime-bridge agents-md-management workbench; do
```

Replace with:

```
plugin_count="$(jq '.plugins | length' "$MARKETPLACE")"
[ "$plugin_count" -eq 7 ] || fail "Expected 7 Codex marketplace plugins, got $plugin_count"

for plugin in atlassian google-workspace research writing runtime-bridge agent-system-management workbench; do
```

(The count stays `7`: the marketplace had eight plugins after PR #31 added `claude-code-management`; this rename folds it back so the count is again `7`. The literal `agents-md-management` in the loop swaps to `agent-system-management`. There is no `claude-code-management` to remove from the loop because PR #31 never added one to this test.)

- [ ] **Step 2: Verify**

```bash
bash tests/unit/test-codex-plugin-structure.sh
```

Expected: `Codex plugin structure OK`, exit code 0.

---

### Task 13: Run the full verification gate

This is the gate the spec defines. Run every check before committing.

- [ ] **Step 1: Frontmatter YAML test for the renamed plugin's three skills**

```bash
bash tests/unit/test-skill-frontmatter-yaml.sh
```

Expected: passes (covers every plugin's SKILL.md).

- [ ] **Step 2: Instruction skills test (renamed)**

```bash
bash tests/unit/test-instruction-skills.sh
```

Expected: all `[PASS]`, no `[FAIL]`.

- [ ] **Step 3: Creating-skills test (new plugin path)**

```bash
bash tests/unit/test-creating-skills-skill.sh
```

Expected: all `[PASS]`, no `[FAIL]`.

- [ ] **Step 4: Workbench autopilot test (new IDs)**

```bash
bash tests/unit/test-workbench-autopilot-skill.sh
```

Expected: all `[PASS]`, no `[FAIL]`.

- [ ] **Step 5: Codex plugin structure**

```bash
bash tests/unit/test-codex-plugin-structure.sh
```

Expected: `Codex plugin structure OK`.

- [ ] **Step 6: jq parses every touched JSON**

```bash
jq empty plugins/agent-system-management/.claude-plugin/plugin.json
jq empty plugins/agent-system-management/.codex-plugin/plugin.json
jq empty plugins/workbench/.claude-plugin/plugin.json
jq empty plugins/workbench/.codex-plugin/plugin.json
jq empty .claude-plugin/marketplace.json
jq empty .agents/plugins/marketplace.json
```

Expected: all six exit with code 0 and no output.

- [ ] **Step 7: Grep gate**

For each old name, no hit may exist anywhere outside the documented exclusion list.

```bash
for needle in agents-md-management agents-md-improver agents-md-session-capture claude-code-management; do
  echo "=== $needle ==="
  grep -rn --binary-files=without-match \
    --exclude-dir=.git \
    --exclude-dir=.worktrees \
    --exclude-dir=node_modules \
    "$needle" . \
    | grep -v '^\./\.claude/plugins/cache/' \
    | grep -v '^\./docs/workbench/specs/2026-05-05-agent-system-management-rename-design.md:' \
    | grep -v '^\./docs/workbench/plans/2026-05-05-agent-system-management-rename.md:' \
    | grep -v '^\./docs/superpowers/specs/2026-05-05-workbench-autopilot-port-design.md:' \
    | grep -v '^\./docs/superpowers/plans/2026-05-05-workbench-autopilot-pr2-autopilot-skill.md:' \
    || echo "(clean)"
done
```

Expected: every `=== <needle> ===` block prints `(clean)`. Any other line is a leak; investigate before committing.

(This plan file itself is excluded because it references the old names by definition. The two `docs/superpowers/...` files only contain the upstream `claude-md-management:*` references the spec called out, but they're listed defensively so a literal substring like `claude-code-management` cannot leak through them either.)

If a leak shows up: read the offending file, decide whether the reference is live (must be updated) or historical/quoted (acceptable; if so, add it to the exclusion list of the grep command for this run only, do not commit a new exclusion). Re-run the grep loop until every block prints `(clean)`.

---

### Task 14: Commit the refactor in one Conventional Commits message

**Files:** all changes from Tasks 1-13 staged together.

- [ ] **Step 1: Inspect the staged change set**

```bash
git status --short
git diff --stat
```

Expected: rename lines (`R  `) for the moved directories, modified lines for the in-place edits, deleted lines for `plugins/claude-code-management/` content. No untracked files outside `.claude/` that aren't part of this refactor.

- [ ] **Step 2: Stage every in-place edit on top of the renames and deletions**

The `git mv` calls in Task 1 staged the renames; `git rm -r` staged the deletions. This step stages every content edit applied to the renamed-or-modified files in Tasks 2-12.

```bash
git add plugins/agent-system-management
git add plugins/workbench/.claude-plugin/plugin.json
git add plugins/workbench/.codex-plugin/plugin.json
git add plugins/workbench/skills/autopilot/SKILL.md
git add plugins/workbench/skills/autopilot/references/required-skills.md
git add .claude-plugin/marketplace.json
git add .agents/plugins/marketplace.json
git add AGENTS.md
git add README.md
git add tests/unit/test-instruction-skills.sh
git add tests/unit/test-creating-skills-skill.sh
git add tests/unit/test-workbench-autopilot-skill.sh
git add tests/unit/test-codex-plugin-structure.sh
git add docs/workbench/plans/2026-05-05-agent-system-management-rename.md
```

Then verify nothing is left unstaged:

```bash
git status --short
```

Expected: every line starts with `R`, `M`, `D`, or `A` in the staged column (first character) and a space in the worktree column (second character). Any `??` (untracked) lines outside the pre-existing `.claude/` entry, or any `M`/`D` in the worktree column, means a file slipped through — re-stage it before the commit.

- [ ] **Step 3: Commit**

```bash
git commit -m "$(cat <<'EOF'
refactor: fold claude-code-management into agent-system-management

Rename the agents-md-management plugin to agent-system-management, fold
the claude-code-management plugin's creating-skills skill into it, and
rename the two existing AGENTS.md / CLAUDE.md skills to gerund form
(improving-instructions, capturing-session-learnings). Bump
agent-system-management to 0.2.0 and workbench to 0.4.1 to track the
autopilot cross-plugin reference updates. Spec at
docs/workbench/specs/2026-05-05-agent-system-management-rename-design.md.
EOF
)"
```

- [ ] **Step 4: Verify the commit landed**

```bash
git log --oneline -1
git status
```

Expected: top commit's subject is the refactor message. `git status` shows a clean working tree (or only untracked entries that pre-date this work).

- [ ] **Step 5: Re-run the verification gate one last time on the committed state**

```bash
bash tests/unit/test-skill-frontmatter-yaml.sh
bash tests/unit/test-instruction-skills.sh
bash tests/unit/test-creating-skills-skill.sh
bash tests/unit/test-workbench-autopilot-skill.sh
bash tests/unit/test-codex-plugin-structure.sh
```

Expected: every script exits 0 with no `[FAIL]` lines.

Do not push. The spec ships this work as a refactor of in-flight PR #31; the orchestrator (or the user) decides when to push and whether to open a fresh PR or amend the branch HEAD on top of PR #31. This plan stops at a clean local commit.
