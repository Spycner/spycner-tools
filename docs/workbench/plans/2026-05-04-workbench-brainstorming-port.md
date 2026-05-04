# Workbench plugin: brainstorming port implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the initial `workbench` plugin in `pgoell-claude-tools` with two ported skills (`brainstorming`, `using-workbench`), full Claude Code + Codex parity, dual-runtime SessionStart hook, license attribution to upstream `superpowers` v5.0.7, and marketplace registration in both registries.

**Architecture:** Fork-as-you-touch port from upstream `superpowers` plugin (cached at `/home/pascal/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/`). Brainstorming files are copied verbatim with surgical rebrand edits documented in the spec. `using-workbench` is freshly authored as a trimmed companion meta-skill that defers most rules to upstream `using-superpowers`. Hook config is duplicated to support Claude Code (`hooks/hooks.json`, uses `${CLAUDE_PLUGIN_ROOT}`) and Codex (`hooks.json` at plugin root, plugin-root-relative path) per the figma plugin precedent. Marketplace entries follow existing patterns in `.claude-plugin/marketplace.json` (Claude) and `.agents/plugins/marketplace.json` (Codex with `interface` block).

**Tech Stack:** Bash (hook scripts, test runners), JSON (manifests, hook configs, marketplace registries), Markdown (skills, references, docs). No build step. No package dependencies.

**Worktree:** This plan executes in `.worktrees/workbench` on branch `feat/workbench`. The spec doc `docs/workbench/specs/2026-05-04-workbench-brainstorming-port-design.md` is already in the worktree as untracked content (carried over from main).

**Reference paths used throughout:**
- Upstream cache: `/home/pascal/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/`
- Worktree root: `/home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/`
- Spec: `docs/workbench/specs/2026-05-04-workbench-brainstorming-port-design.md` (worktree-relative)

---

## Task 1: Add design spec and implementation plan to feature branch

**Files:**
- Add: `docs/workbench/specs/2026-05-04-workbench-brainstorming-port-design.md`
- Add: `docs/workbench/plans/2026-05-04-workbench-brainstorming-port.md`

- [ ] **Step 1: Verify both files are present in worktree**

```bash
ls -la /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/docs/workbench/specs/
ls -la /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/docs/workbench/plans/
```

Expected: spec file and plan file both listed (each with the `2026-05-04-...` prefix).

- [ ] **Step 2: Stage the spec and plan together**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench && git add docs/workbench/specs/ docs/workbench/plans/
```

- [ ] **Step 3: Commit**

```bash
git -C /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench commit -m "docs(workbench): add brainstorming port design spec and implementation plan"
```

- [ ] **Step 4: Verify commit landed**

```bash
git -C /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench log --oneline -1
```

Expected: most recent line shows the new commit message.

---

## Task 2: Scaffold workbench plugin (directories, manifests, attribution)

**Files:**
- Create: `plugins/workbench/.claude-plugin/plugin.json`
- Create: `plugins/workbench/.codex-plugin/plugin.json`
- Create: `plugins/workbench/LICENSE`
- Create: `plugins/workbench/NOTICE`
- Create: `plugins/workbench/README.md`
- Create directories: `plugins/workbench/{hooks,skills/{using-workbench/references,brainstorming/scripts}}`

- [ ] **Step 1: Create directory tree**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
mkdir -p plugins/workbench/.claude-plugin
mkdir -p plugins/workbench/.codex-plugin
mkdir -p plugins/workbench/hooks
mkdir -p plugins/workbench/skills/using-workbench/references
mkdir -p plugins/workbench/skills/brainstorming/scripts
```

- [ ] **Step 2: Write `.claude-plugin/plugin.json`**

Path: `plugins/workbench/.claude-plugin/plugin.json`

```json
{
  "name": "workbench",
  "version": "0.1.0",
  "description": "Personal fork-as-you-touch skill collection (brainstorming + meta-skill, more to come)",
  "author": {
    "name": "Pascal Göllner"
  },
  "license": "MIT",
  "keywords": [
    "personal",
    "brainstorming",
    "design",
    "specs",
    "workflow"
  ]
}
```

- [ ] **Step 3: Write `.codex-plugin/plugin.json`**

Path: `plugins/workbench/.codex-plugin/plugin.json`

```json
{
  "name": "workbench",
  "version": "0.1.0",
  "description": "Personal fork-as-you-touch skill collection (brainstorming + meta-skill, more to come)",
  "author": {
    "name": "Pascal Göllner"
  },
  "license": "MIT",
  "keywords": [
    "personal",
    "brainstorming",
    "design",
    "specs",
    "workflow"
  ],
  "skills": "./skills/",
  "interface": {
    "displayName": "Workbench",
    "shortDescription": "Personal forks of skills Pascal uses regularly",
    "longDescription": "Personal fork-as-you-touch skill collection. Today: brainstorming (with visual companion) and a meta-skill that layers on top of using-superpowers. More skills will be added as Pascal commits to owning them.",
    "developerName": "Pascal Göllner",
    "category": "Productivity",
    "capabilities": [
      "Interactive",
      "Write"
    ],
    "defaultPrompt": [
      "Help me brainstorm a new feature",
      "Turn my idea into a spec",
      "Run the design dialogue for this project"
    ],
    "screenshots": []
  }
}
```

- [ ] **Step 4: Copy LICENSE from upstream**

```bash
cp /home/pascal/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/LICENSE /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/plugins/workbench/LICENSE
```

Verify the file is MIT:

```bash
head -3 /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/plugins/workbench/LICENSE
```

Expected: `MIT License` in the first line.

- [ ] **Step 5: Write NOTICE**

Path: `plugins/workbench/NOTICE`

```
Workbench

This plugin is a personal fork of skills derived from the upstream
Superpowers plugin by Jesse Vincent.

Upstream: https://github.com/obra/superpowers
Upstream version at fork time: 5.0.7
Upstream license: MIT (see LICENSE file in this directory)

Files derived from upstream Superpowers:

  skills/brainstorming/SKILL.md
  skills/brainstorming/visual-companion.md
  skills/brainstorming/spec-document-reviewer-prompt.md
  skills/brainstorming/scripts/frame-template.html
  skills/brainstorming/scripts/helper.js
  skills/brainstorming/scripts/server.cjs
  skills/brainstorming/scripts/start-server.sh
  skills/brainstorming/scripts/stop-server.sh
  skills/using-workbench/references/using-superpowers-upstream.md
  hooks/hooks.json
  hooks/run-hook.cmd
  hooks/session-start

Adaptations from upstream are documented in
docs/workbench/specs/2026-05-04-workbench-brainstorming-port-design.md.
```

- [ ] **Step 6: Write README.md**

Path: `plugins/workbench/README.md`

```markdown
# Workbench

Personal fork-as-you-touch skill collection.

## Skills

- `brainstorming`: Design dialogue that turns an idea into a spec, with a visual-companion mode for browser-based mockups. Forked from upstream Superpowers and adapted with Workbench-specific paths.
- `using-workbench`: Trimmed meta-skill that announces what Workbench ships and resolves slug collisions in Workbench's favor. Defers core meta-rules to the upstream `using-superpowers` skill.

## Coexistence

Workbench is designed to run alongside the upstream `superpowers` plugin. When a slug exists in both plugins (today: `brainstorming`), prefer the Workbench version.

The brainstorming skill's terminal handoff currently invokes `superpowers:writing-plans` cross-plugin. When `writing-plans` is later ported into Workbench, that reference will flip.

## Credits

This plugin includes content derived from the Superpowers plugin by Jesse Vincent (https://github.com/obra/superpowers), version 5.0.7, MIT-licensed. See the NOTICE file for the full list of derived files and the LICENSE file for the upstream license text.
```

- [ ] **Step 7: Verify JSON files parse**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
python3 -c "import json; json.load(open('plugins/workbench/.claude-plugin/plugin.json'))" && echo "claude plugin.json OK"
python3 -c "import json; json.load(open('plugins/workbench/.codex-plugin/plugin.json'))" && echo "codex plugin.json OK"
```

Expected: both lines print `OK`.

- [ ] **Step 8: Stage and commit**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
git add plugins/workbench/.claude-plugin plugins/workbench/.codex-plugin plugins/workbench/LICENSE plugins/workbench/NOTICE plugins/workbench/README.md
git commit -m "feat(workbench): scaffold plugin structure with manifests and license attribution"
```

---

## Task 3: Add using-workbench meta-skill

**Files:**
- Create: `plugins/workbench/skills/using-workbench/SKILL.md`
- Create: `plugins/workbench/skills/using-workbench/references/using-superpowers-upstream.md`

- [ ] **Step 1: Write using-workbench/SKILL.md**

Path: `plugins/workbench/skills/using-workbench/SKILL.md`

```markdown
---
name: using-workbench
description: Use when starting any conversation alongside using-superpowers. Announces workbench's currently-shipped skills, defers meta-rules to using-superpowers, and resolves slug collisions in workbench's favor.
---

# Using Workbench

This skill is a thin companion to `using-superpowers`. Workbench layers on top of the upstream Superpowers plugin and forks individual skills as Pascal commits to owning them.

## Relationship to using-superpowers

The meta-rules for working with skills (when to invoke them, how to treat triggers, the "even 1% relevance" rule, the rule against rationalizing past skill use, the SUBAGENT-STOP block, the platform tool-name mapping) are owned by `using-superpowers`. This skill does NOT restate them.

If `superpowers` is not installed, see `references/using-superpowers-upstream.md` in this skill directory for the meta-rules in their original form, frozen at upstream version 5.0.7. Either install upstream, or promote that content into this skill body.

## Workbench skills

Today, Workbench ships:

- `brainstorming`: design dialogue that turns an idea into a spec, with a visual-companion mode

As more skills are forked into Workbench, add them to this list and promote relevant chunks from `references/using-superpowers-upstream.md` into this skill body.

## Slug collision rule

When a skill name exists in both Workbench and Superpowers, prefer the Workbench version. Today the only collision is `brainstorming`. The host agent should resolve the bare slug `brainstorming` to `workbench:brainstorming`.

## Reference file

`references/using-superpowers-upstream.md` is a verbatim snapshot of the upstream `using-superpowers/SKILL.md` at version 5.0.7. It exists so that, as more skills are ported, their corresponding chunks of meta-guidance can be lifted out of the snapshot and into this skill body.
```

- [ ] **Step 2: Copy upstream using-superpowers as reference**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
cp /home/pascal/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/using-superpowers/SKILL.md \
   plugins/workbench/skills/using-workbench/references/using-superpowers-upstream.md
```

- [ ] **Step 3: Prepend snapshot header to reference file**

Use the Edit tool to add a header note at the top of `plugins/workbench/skills/using-workbench/references/using-superpowers-upstream.md`. Find the existing first line of the file (which begins with `---` for frontmatter) and prepend an HTML comment block above it.

Insert at the very top of the file (before any other content):

```html
<!--
SNAPSHOT NOTE
=============
Source: superpowers plugin v5.0.7
Origin path: skills/using-superpowers/SKILL.md
Snapshot date: 2026-05-04
Purpose: Frozen reference for the using-workbench skill. As Workbench
forks more skills from upstream, lift the corresponding chunks of
meta-guidance out of this file and into using-workbench/SKILL.md.
This file is intentionally NOT a skill (no frontmatter recognized as
skill metadata; subdirectory `references/` is by convention not loaded
as a skill).
-->

```

(Note the trailing blank line so the original frontmatter stays at column 1 of its own line.)

- [ ] **Step 4: Verify both files exist and are non-empty**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
test -s plugins/workbench/skills/using-workbench/SKILL.md && echo "SKILL.md OK"
test -s plugins/workbench/skills/using-workbench/references/using-superpowers-upstream.md && echo "reference OK"
head -5 plugins/workbench/skills/using-workbench/references/using-superpowers-upstream.md
```

Expected: both `OK` lines, and head shows the snapshot note comment first.

- [ ] **Step 5: Stage and commit**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
git add plugins/workbench/skills/using-workbench/
git commit -m "feat(workbench): add using-workbench meta-skill with upstream reference snapshot"
```

---

## Task 4: Port brainstorming skill files (verbatim copies)

**Files:**
- Create: `plugins/workbench/skills/brainstorming/SKILL.md`
- Create: `plugins/workbench/skills/brainstorming/visual-companion.md`
- Create: `plugins/workbench/skills/brainstorming/spec-document-reviewer-prompt.md`
- Create: `plugins/workbench/skills/brainstorming/scripts/frame-template.html`
- Create: `plugins/workbench/skills/brainstorming/scripts/helper.js`
- Create: `plugins/workbench/skills/brainstorming/scripts/server.cjs`
- Create: `plugins/workbench/skills/brainstorming/scripts/start-server.sh`
- Create: `plugins/workbench/skills/brainstorming/scripts/stop-server.sh`

This task is verbatim copies. Rebrand edits happen in Task 5.

- [ ] **Step 1: Copy all brainstorming files**

```bash
SRC=/home/pascal/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/brainstorming
DST=/home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/plugins/workbench/skills/brainstorming

cp "$SRC/SKILL.md" "$DST/SKILL.md"
cp "$SRC/visual-companion.md" "$DST/visual-companion.md"
cp "$SRC/spec-document-reviewer-prompt.md" "$DST/spec-document-reviewer-prompt.md"
cp "$SRC/scripts/frame-template.html" "$DST/scripts/frame-template.html"
cp "$SRC/scripts/helper.js" "$DST/scripts/helper.js"
cp "$SRC/scripts/server.cjs" "$DST/scripts/server.cjs"
cp "$SRC/scripts/start-server.sh" "$DST/scripts/start-server.sh"
cp "$SRC/scripts/stop-server.sh" "$DST/scripts/stop-server.sh"
```

- [ ] **Step 2: Preserve executable bits on shell scripts**

```bash
DST=/home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/plugins/workbench/skills/brainstorming/scripts
chmod +x "$DST/start-server.sh" "$DST/stop-server.sh"
ls -la "$DST"/*.sh
```

Expected: `start-server.sh` and `stop-server.sh` show `-rwxr-xr-x` (or equivalent with x bit).

- [ ] **Step 3: Verify all eight files copied with non-zero size**

```bash
DST=/home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/plugins/workbench/skills/brainstorming
for f in SKILL.md visual-companion.md spec-document-reviewer-prompt.md scripts/frame-template.html scripts/helper.js scripts/server.cjs scripts/start-server.sh scripts/stop-server.sh; do
  test -s "$DST/$f" && echo "$f OK" || echo "$f MISSING"
done
```

Expected: 8 lines all ending in `OK`.

- [ ] **Step 4: Stage and commit**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
git add plugins/workbench/skills/brainstorming/
git commit -m "feat(workbench): port brainstorming skill files verbatim from superpowers v5.0.7"
```

---

## Task 5: Apply brainstorming rebrand edits

**Files (all paths worktree-relative):**
- Modify: `plugins/workbench/skills/brainstorming/SKILL.md` (spec output path + terminal handoff target)
- Modify: `plugins/workbench/skills/brainstorming/scripts/start-server.sh` (lines 9, 81)
- Modify: `plugins/workbench/skills/brainstorming/scripts/stop-server.sh` (line 6)
- Modify: `plugins/workbench/skills/brainstorming/scripts/frame-template.html` (line 199)
- Modify: `plugins/workbench/skills/brainstorming/visual-companion.md` (multiple `.superpowers/brainstorm/` references)

These are surgical edits. Use the Edit tool with the exact strings shown.

- [ ] **Step 1: Edit SKILL.md, spec output path**

File: `plugins/workbench/skills/brainstorming/SKILL.md`

Find:

```
- Write the validated design (spec) to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
```

Replace with:

```
- Write the validated design (spec) to `docs/workbench/specs/YYYY-MM-DD-<topic>-design.md`
```

- [ ] **Step 2: Edit SKILL.md, terminal handoff target**

File: `plugins/workbench/skills/brainstorming/SKILL.md`

Find:

```
- Invoke the writing-plans skill to create a detailed implementation plan
- Do NOT invoke any other skill. writing-plans is the next step.
```

Replace with:

```
- Invoke the `superpowers:writing-plans` skill to create a detailed implementation plan
- Do NOT invoke any other skill. `superpowers:writing-plans` is the next step. (When `writing-plans` is later ported into Workbench, this reference flips to `workbench:writing-plans`.)
```

Also find any other line that references `writing-plans` without the plugin prefix and update similarly. Specifically look for these existing strings in the SKILL.md and update them too:

Find:

```
"The terminal state is invoking writing-plans.** Do NOT invoke frontend-design, mcp-builder, or any other implementation skill. The ONLY skill you invoke after brainstorming is writing-plans."
```

Replace with:

```
"The terminal state is invoking `superpowers:writing-plans`.** Do NOT invoke frontend-design, mcp-builder, or any other implementation skill. The ONLY skill you invoke after brainstorming is `superpowers:writing-plans`."
```

And:

Find (in the dot graph):

```
"Invoke writing-plans skill" [shape=doublecircle];
```

Replace with:

```
"Invoke superpowers:writing-plans skill" [shape=doublecircle];
```

And:

Find:

```
    "User reviews spec?" -> "Invoke writing-plans skill" [label="approved"];
```

Replace with:

```
    "User reviews spec?" -> "Invoke superpowers:writing-plans skill" [label="approved"];
```

Also update the checklist line:

Find:

```
9. **Transition to implementation** — invoke writing-plans skill to create implementation plan
```

Replace with:

```
9. **Transition to implementation** — invoke `superpowers:writing-plans` skill to create implementation plan
```

- [ ] **Step 3: Edit start-server.sh, comment on line 9**

File: `plugins/workbench/skills/brainstorming/scripts/start-server.sh`

Find:

```
#   --project-dir <path>  Store session files under <path>/.superpowers/brainstorm/
```

Replace with:

```
#   --project-dir <path>  Store session files under <path>/.workbench/brainstorm/
```

- [ ] **Step 4: Edit start-server.sh, session dir on line 81**

File: `plugins/workbench/skills/brainstorming/scripts/start-server.sh`

Find:

```
  SESSION_DIR="${PROJECT_DIR}/.superpowers/brainstorm/${SESSION_ID}"
```

Replace with:

```
  SESSION_DIR="${PROJECT_DIR}/.workbench/brainstorm/${SESSION_ID}"
```

- [ ] **Step 5: Edit stop-server.sh, comment on line 6**

File: `plugins/workbench/skills/brainstorming/scripts/stop-server.sh`

Find:

```
# under /tmp (ephemeral). Persistent directories (.superpowers/) are
```

Replace with:

```
# under /tmp (ephemeral). Persistent directories (.workbench/) are
```

- [ ] **Step 6: Edit frame-template.html, page header**

File: `plugins/workbench/skills/brainstorming/scripts/frame-template.html`

Find:

```
    <h1><a href="https://github.com/obra/superpowers" style="color: inherit; text-decoration: none;">Superpowers Brainstorming</a></h1>
```

Replace with:

```
    <h1><a href="https://github.com/pgoell/pgoell-claude-tools" style="color: inherit; text-decoration: none;">Workbench Brainstorming</a></h1>
```

- [ ] **Step 7: Edit visual-companion.md, replace all .superpowers/ path references**

File: `plugins/workbench/skills/brainstorming/visual-companion.md`

Replace all four references. Each replacement uses the Edit tool with `replace_all: true` since the same path appears in multiple locations.

Find (use `replace_all: true`):

```
.superpowers/brainstorm/
```

Replace with:

```
.workbench/brainstorm/
```

Then find:

```
add `.superpowers/`
```

Replace with:

```
add `.workbench/`
```

- [ ] **Step 8: Verify rebrand completeness**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/plugins/workbench/skills/brainstorming
echo "--- residual superpowers references in code paths ---"
grep -rn "superpowers" . | grep -v "writing-plans" | grep -v "obra"
echo "--- (the only acceptable hits should be the deliberate superpowers:writing-plans handoff in SKILL.md and the github.com/obra/superpowers attribution in NOTICE-style content if any) ---"
```

Expected: only matches are inside the SKILL.md, referencing `superpowers:writing-plans` (the deliberate cross-plugin handoff). If `frame-template.html` or scripts show any remaining `superpowers` strings, fix them and re-grep.

- [ ] **Step 9: Stage and commit**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
git add plugins/workbench/skills/brainstorming/
git commit -m "feat(workbench): rebrand brainstorming skill paths and references for workbench"
```

---

## Task 6: Add hook scripts and configs (Claude + Codex)

**Files:**
- Create: `plugins/workbench/hooks/run-hook.cmd`
- Create: `plugins/workbench/hooks/session-start`
- Create: `plugins/workbench/hooks/hooks.json`
- Create: `plugins/workbench/hooks.json`

- [ ] **Step 1: Copy run-hook.cmd verbatim**

```bash
cp /home/pascal/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/hooks/run-hook.cmd \
   /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/plugins/workbench/hooks/run-hook.cmd
```

The file is a generic cross-platform polyglot wrapper with no upstream-specific references; no edits needed.

- [ ] **Step 2: Copy session-start as a starting point**

```bash
cp /home/pascal/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/hooks/session-start \
   /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/plugins/workbench/hooks/session-start
```

- [ ] **Step 3: Edit session-start, header comment**

File: `plugins/workbench/hooks/session-start`

Find:

```
# SessionStart hook for superpowers plugin
```

Replace with:

```
# SessionStart hook for workbench plugin
```

- [ ] **Step 4: Edit session-start, drop legacy-skills-warning block**

File: `plugins/workbench/hooks/session-start`

Find (this is the entire block including the variable initialization, the if-statement, and the warning message string):

```bash
# Check if legacy skills directory exists and build warning
warning_message=""
legacy_skills_dir="${HOME}/.config/superpowers/skills"
if [ -d "$legacy_skills_dir" ]; then
    warning_message="\n\n<important-reminder>IN YOUR FIRST REPLY AFTER SEEING THIS MESSAGE YOU MUST TELL THE USER:⚠️ **WARNING:** Superpowers now uses Claude Code's skills system. Custom skills in ~/.config/superpowers/skills will not be read. Move custom skills to ~/.claude/skills instead. To make this message go away, remove ~/.config/superpowers/skills</important-reminder>"
fi
```

Replace with: (empty, just remove the block).

- [ ] **Step 5: Edit session-start, skill path read**

File: `plugins/workbench/hooks/session-start`

Find:

```bash
# Read using-superpowers content
using_superpowers_content=$(cat "${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md" 2>&1 || echo "Error reading using-superpowers skill")
```

Replace with:

```bash
# Read using-workbench content
using_workbench_content=$(cat "${PLUGIN_ROOT}/skills/using-workbench/SKILL.md" 2>&1 || echo "Error reading using-workbench skill")
```

- [ ] **Step 6: Edit session-start, variable rename in escape block**

File: `plugins/workbench/hooks/session-start`

Find:

```bash
using_superpowers_escaped=$(escape_for_json "$using_superpowers_content")
warning_escaped=$(escape_for_json "$warning_message")
session_context="<EXTREMELY_IMPORTANT>\nYou have superpowers.\n\n**Below is the full content of your 'superpowers:using-superpowers' skill - your introduction to using skills. For all other skills, use the 'Skill' tool:**\n\n${using_superpowers_escaped}\n\n${warning_escaped}\n</EXTREMELY_IMPORTANT>"
```

Replace with:

```bash
using_workbench_escaped=$(escape_for_json "$using_workbench_content")
session_context="<EXTREMELY_IMPORTANT>\nYou have workbench skills.\n\n**Below is the full content of your 'workbench:using-workbench' skill, your introduction to using Workbench skills alongside the upstream Superpowers meta-rules. For all other skills, use the 'Skill' tool:**\n\n${using_workbench_escaped}\n</EXTREMELY_IMPORTANT>"
```

This change does three things at once: drops `warning_escaped` (no longer used), renames the content variable, and rebrands the wrapper text.

- [ ] **Step 7: Verify session-start has no remaining `superpowers` references and is syntactically valid bash**

```bash
SESSION_START=/home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/plugins/workbench/hooks/session-start
echo "--- residual superpowers in session-start ---"
grep -n "superpowers" "$SESSION_START" || echo "(none)"
echo "--- bash syntax check ---"
bash -n "$SESSION_START" && echo "syntax OK"
```

Expected: `(none)` for the grep (or only an `obra/superpowers` URL if any survived; that's acceptable since it would be inside a comment), and `syntax OK` for the bash check.

- [ ] **Step 8: Make scripts executable**

```bash
HOOKS=/home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/plugins/workbench/hooks
chmod +x "$HOOKS/session-start" "$HOOKS/run-hook.cmd"
ls -la "$HOOKS"
```

Expected: both `session-start` and `run-hook.cmd` show executable bits.

- [ ] **Step 9: Write hooks/hooks.json (Claude Code)**

Path: `plugins/workbench/hooks/hooks.json`

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start",
            "async": false
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 10: Write hooks.json at plugin root (Codex)**

Path: `plugins/workbench/hooks.json`

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "./hooks/session-start"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 11: Verify both hook configs parse**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
python3 -c "import json; json.load(open('plugins/workbench/hooks/hooks.json'))" && echo "claude hooks.json OK"
python3 -c "import json; json.load(open('plugins/workbench/hooks.json'))" && echo "codex hooks.json OK"
```

Expected: both lines print `OK`.

- [ ] **Step 12: Stage and commit**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
git add plugins/workbench/hooks/ plugins/workbench/hooks.json
git commit -m "feat(workbench): add SessionStart hook for Claude Code and Codex"
```

---

## Task 7: Register workbench in marketplaces

**Files:**
- Modify: `.claude-plugin/marketplace.json` (add workbench entry to `plugins` array)
- Modify: `.agents/plugins/marketplace.json` (add workbench entry to `plugins` array)

- [ ] **Step 1: Edit `.claude-plugin/marketplace.json`**

File: `.claude-plugin/marketplace.json`

Append a new entry to the `plugins` array. Find the closing `]` of the existing plugins array (the last entry currently is `agents-md-management`). Add a comma after the closing brace of the agents-md-management entry, then insert the new workbench object before the closing `]`.

Find:

```json
    {
      "name": "agents-md-management",
      "source": "./plugins/agents-md-management",
      "description": "Audit and maintain AGENTS.md / CLAUDE.md files across project and user-global scopes; capture session learnings into the right file by scope",
      "version": "0.1.0"
    }
  ]
```

Replace with:

```json
    {
      "name": "agents-md-management",
      "source": "./plugins/agents-md-management",
      "description": "Audit and maintain AGENTS.md / CLAUDE.md files across project and user-global scopes; capture session learnings into the right file by scope",
      "version": "0.1.0"
    },
    {
      "name": "workbench",
      "source": "./plugins/workbench",
      "description": "Personal fork-as-you-touch skill collection (brainstorming + meta-skill, more to come)",
      "version": "0.1.0"
    }
  ]
```

- [ ] **Step 2: Edit `.agents/plugins/marketplace.json`**

File: `.agents/plugins/marketplace.json`

Same pattern: insert the new workbench entry as the last item in the `plugins` array.

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
        "shortDescription": "Audit AGENTS.md/CLAUDE.md and capture session learnings"
      }
    }
  ]
```

Replace with:

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
        "shortDescription": "Audit AGENTS.md/CLAUDE.md and capture session learnings"
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
        "shortDescription": "Personal forks of skills Pascal uses regularly"
      }
    }
  ]
```

- [ ] **Step 3: Verify both marketplace files parse**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
python3 -c "import json; data=json.load(open('.claude-plugin/marketplace.json')); print('claude marketplace OK,', len(data['plugins']), 'plugins')"
python3 -c "import json; data=json.load(open('.agents/plugins/marketplace.json')); print('codex marketplace OK,', len(data['plugins']), 'plugins')"
```

Expected: both report `OK` with plugin count of 7 (was 6, added workbench).

- [ ] **Step 4: Stage and commit**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
git add .claude-plugin/marketplace.json .agents/plugins/marketplace.json
git commit -m "feat(workbench): register plugin in Claude Code and Codex marketplaces"
```

---

## Task 8: Update repo README.md

**Files:**
- Modify: `README.md` (Plugins section + Installation section)

- [ ] **Step 1: Add Workbench to the Plugins section**

File: `README.md`

The existing Plugins section lists six plugins as `### <name>` subsections, in this order: atlassian, google-workspace, research, writing, runtime-bridge, agents-md-management.

Find the last subsection `### agents-md-management` and the content beneath it. Find the line that ends that subsection (whatever follows before the next `## ` top-level heading begins). Append a new `### workbench` subsection.

Concretely, find the closing line of the agents-md-management subsection. To make the edit unambiguous, locate the heading `### agents-md-management` by reading lines 60 through 72 of `README.md` to see what follows. Then append:

```markdown
### workbench

Personal fork-as-you-touch skill collection. Today: brainstorming (a design dialogue that turns ideas into specs, with a browser-based visual companion) and a trimmed meta-skill that layers on top of upstream `superpowers:using-superpowers`. More skills will be added as Pascal commits to owning them.

**Skills:**
- `/pgoell-claude-tools:brainstorming`: Design dialogue from idea to spec, with a visual-companion mode
- `/pgoell-claude-tools:using-workbench`: Meta-skill announcing Workbench skills, defers core meta-rules to upstream
```

Insert this `### workbench` block immediately before the next top-level heading (`## Installation`).

- [ ] **Step 2: Add Workbench to the Installation section (Claude Code)**

File: `README.md`

Find:

```
/plugin install agents-md-management@pgoell-claude-tools
```

Replace with:

```
/plugin install agents-md-management@pgoell-claude-tools
/plugin install workbench@pgoell-claude-tools
```

- [ ] **Step 3: Verify the README still renders sensibly**

```bash
head -100 /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/README.md
grep -n "workbench" /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench/README.md
```

Expected: at least three matches for `workbench` (heading, skill listings, install command).

- [ ] **Step 4: Stage and commit**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
git add README.md
git commit -m "docs(workbench): document workbench plugin in repo README"
```

---

## Task 9: Final verification

**Files:** None modified. This task is read-only verification.

- [ ] **Step 1: All JSON files in workbench parse**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
for f in $(find plugins/workbench .claude-plugin/marketplace.json .agents/plugins/marketplace.json -name "*.json" 2>/dev/null); do
  python3 -c "import json; json.load(open('$f'))" 2>/dev/null && echo "$f OK" || echo "$f FAILED"
done
```

Expected: every file ends in `OK`. (Files checked: workbench plugin manifests, both hook configs, both marketplace files.)

- [ ] **Step 2: All shell scripts in workbench are executable**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
for f in plugins/workbench/hooks/session-start plugins/workbench/hooks/run-hook.cmd plugins/workbench/skills/brainstorming/scripts/start-server.sh plugins/workbench/skills/brainstorming/scripts/stop-server.sh; do
  if [ -x "$f" ]; then echo "$f executable"; else echo "$f NOT executable"; fi
done
```

Expected: all four files marked `executable`.

- [ ] **Step 3: All shell scripts in workbench have valid bash syntax**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
for f in plugins/workbench/hooks/session-start plugins/workbench/skills/brainstorming/scripts/start-server.sh plugins/workbench/skills/brainstorming/scripts/stop-server.sh; do
  bash -n "$f" && echo "$f syntax OK" || echo "$f SYNTAX ERROR"
done
```

Expected: all three files report `syntax OK`.

- [ ] **Step 4: Audit residual `superpowers` references**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
echo "--- All superpowers references inside plugins/workbench (excluding the snapshot reference file) ---"
grep -rn "superpowers" plugins/workbench --exclude-dir=references
echo ""
echo "--- Acceptable remaining hits should be: ---"
echo "  * superpowers:writing-plans (deliberate cross-plugin handoff in brainstorming SKILL.md)"
echo "  * obra/superpowers (upstream attribution URL in NOTICE)"
echo "  * 'using-superpowers' inside using-workbench/SKILL.md text discussing the upstream relationship"
```

Expected: only the documented acceptable hits appear.

- [ ] **Step 5: Verify Codex plugin structure test passes (if applicable)**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
if [ -f tests/unit/test-codex-plugin-structure.sh ]; then
  bash tests/unit/test-codex-plugin-structure.sh
else
  echo "(no codex structure test script in repo)"
fi
```

Expected: test passes (or, if the test does not yet exist in this repo state, the message about missing script). If the test exists and fails, investigate the failure: it likely indicates a manifest field mismatch.

- [ ] **Step 6: Inspect commit graph**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
git log --oneline main..HEAD
```

Expected: roughly 8 commits ahead of main. The exact list, top to bottom (most recent first):

1. docs(workbench): document workbench plugin in repo README
2. feat(workbench): register plugin in Claude Code and Codex marketplaces
3. feat(workbench): add SessionStart hook for Claude Code and Codex
4. feat(workbench): rebrand brainstorming skill paths and references for workbench
5. feat(workbench): port brainstorming skill files verbatim from superpowers v5.0.7
6. feat(workbench): add using-workbench meta-skill with upstream reference snapshot
7. feat(workbench): scaffold plugin structure with manifests and license attribution
8. docs(workbench): add brainstorming port design spec and implementation plan

If commits are missing or out of order, do not auto-fix; pause and report to the user.

- [ ] **Step 7: Inspect file inventory matches the spec**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
find plugins/workbench -type f | sort
```

Expected file list (compare against the spec's `## Plugin shape` section):

```
plugins/workbench/.claude-plugin/plugin.json
plugins/workbench/.codex-plugin/plugin.json
plugins/workbench/LICENSE
plugins/workbench/NOTICE
plugins/workbench/README.md
plugins/workbench/hooks.json
plugins/workbench/hooks/hooks.json
plugins/workbench/hooks/run-hook.cmd
plugins/workbench/hooks/session-start
plugins/workbench/skills/brainstorming/SKILL.md
plugins/workbench/skills/brainstorming/scripts/frame-template.html
plugins/workbench/skills/brainstorming/scripts/helper.js
plugins/workbench/skills/brainstorming/scripts/server.cjs
plugins/workbench/skills/brainstorming/scripts/start-server.sh
plugins/workbench/skills/brainstorming/scripts/stop-server.sh
plugins/workbench/skills/brainstorming/spec-document-reviewer-prompt.md
plugins/workbench/skills/brainstorming/visual-companion.md
plugins/workbench/skills/using-workbench/SKILL.md
plugins/workbench/skills/using-workbench/references/using-superpowers-upstream.md
```

If any file is missing, identify which task should have created it and fix that task.

- [ ] **Step 8: Optional skill-triggering smoke test**

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
if [ -f tests/skill-triggering/run-test.sh ]; then
  echo "Brainstorming auto-trigger test would run here. Skipping execution since the spec defers tests as IOUs and the runner depends on live Claude invocations."
fi
```

This step is informational only; do not block on it.

- [ ] **Step 9: Final summary**

If all prior steps passed: print a short summary of what was built, ready for handoff to PR creation.

```bash
cd /home/pascal/Code/pgoell-claude-tools/.worktrees/workbench
echo "=== Workbench port complete ==="
echo "Branch: $(git branch --show-current)"
echo "Commits ahead of main: $(git rev-list --count main..HEAD)"
echo "Plugin file count: $(find plugins/workbench -type f | wc -l)"
echo "Marketplaces updated: claude + codex"
echo ""
echo "Ready for PR creation."
```

---

## Cleanup note (post-merge, not part of this plan)

After this PR merges, the original spec file at `/home/pascal/Code/pgoell-claude-tools/docs/workbench/specs/2026-05-04-workbench-brainstorming-port-design.md` (in the main working tree, copied here at worktree creation) becomes redundant. Once the worktree is finished, that copy can be removed from the main working tree. This is not required for the PR itself; it's a tidy-up note.

---

## Self-review notes (for the author of this plan)

Spec coverage check:
- Plugin shape: covered by Task 2 (scaffold) + Tasks 3, 4, 6 (skills + hooks).
- File-by-file adaptations: every file listed in the spec has a corresponding step.
- Marketplace metadata: covered by Task 7.
- License and attribution: covered by Task 2 (LICENSE, NOTICE, README skeleton).
- Out-of-scope IOUs: deliberately omitted from execution; documented in spec only.

Placeholder scan:
- No "TBD", "TODO", "implement later".
- All edits show explicit find/replace strings.
- All commands have explicit expected output.

Type/identifier consistency:
- Variable rename `using_superpowers_*` to `using_workbench_*` is applied in two consecutive steps (Step 5 and Step 6 of Task 6) to keep the file consistent.
- `superpowers:writing-plans` cross-plugin reference is used identically wherever it appears.

Style:
- No em-dashes in newly authored prose.
- No en-dashes.
- No sentence-hyphen punctuation.
- Verbatim upstream content is not edited for style; that is part of the "clean port today" decision in the spec.
