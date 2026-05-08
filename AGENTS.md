# pgoell-claude-tools

A plugin marketplace containing shared skills for Claude Code and Codex.

Claude Code and Codex use separate plugin metadata, but they must reuse the same skill directories. Do not duplicate `SKILL.md` files for another runtime.

## Repository Structure

```
AGENTS.md                   # Shared host-agent instructions (canonical file)
CLAUDE.md                   # Symlink to AGENTS.md, kept for Claude Code discovery
.claude-plugin/
  marketplace.json          # Claude Code plugin registry, lists all plugins with name, source, version
.agents/
  plugins/
    marketplace.json        # Codex plugin registry, lists all plugins with local source and policy metadata
plugins/
  <plugin-name>/
    .claude-plugin/
      plugin.json           # Claude Code plugin metadata
    .codex-plugin/
      plugin.json           # Codex plugin metadata, must set "skills": "./skills/"
    agents/                 # Optional: agent definitions for long-running isolated tasks
      <agent-name>.md
    hooks/                  # Optional: hook scripts plus hooks.json (e.g. workbench session-start)
    skills/
      <service>/
        SKILL.md            # Shared skill definition, used by Claude Code and Codex
        <reference>.md      # Supporting reference docs (recipes, format guides)
    LICENSE                 # Required for ported plugins: this repo's MIT license
    NOTICE                  # Required for ported plugins: per-file upstream attribution
    README.md               # Required for ported plugins: human-facing overview with Credits section
tests/
  test-helpers.sh           # Shared test utilities (run_claude, assertions, auth checks)
  unit/                     # Skill recognition and capability tests
  integration/              # Live API tests (require auth)
  skill-triggering/         # Verify correct skill activates for prompts
    prompts/                # One .txt file per test case
    run-test.sh             # Test runner
```

## Current Plugins

| Plugin | Version | Skills |
|--------|---------|--------|
| `atlassian` | 2.0.0 | `jira`, `confluence` |
| `google-workspace` | 1.0.0 | `gmail`, `calendar` |
| `research` | 2.0.0 | `research` (multi-agent pipeline with review gates) |
| `writing` | 1.6.1 | `writing`, `pyramid`, `tech-doc` |
| `runtime-bridge` | 0.1.0 | `claude-codex-bridge` |
| `agent-system-management` | 0.3.0 | `improving-instructions`, `capturing-session-learnings`, `creating-skills` |
| `workbench` | 0.10.0 | `brainstorming`, `writing-spec`, `writing-plans`, `visualizing-options`, `using-workbench`, `terse-mode`, `autopilot`, `verification-before-completion`, `test-driven-development`, `dispatching-parallel-agents`, `subagent-driven-development`, `systematic-debugging` |
| `terminal` | 0.1.0 | `tmux` |
| `frontend-design` | 0.2.0 | `frontend-design` (ported from Anthropic, Apache 2.0 upstream), `emil-design-eng` (ported from emilkowalski/skill, no upstream license declared) |

## How to Develop a New Skill

> **Tip:** The `agent-system-management:creating-skills` skill automates this entire workflow. Invoke it for greenfield scaffolding, iteration with eval loops, pressure-testing discipline skills, description optimization, or extraction from a session. The steps below remain the canonical reference.

### 1. Plan the skill

- Identify the CLI tool or API the skill wraps
- Prefer invoking the CLI or `curl` directly in the skill (no wrapper scripts)
- Define operation tiers: Tier 1 (Read), Tier 2 (Write), Tier 3 (Manage/Admin)

### 2. Create the plugin structure

If adding to an existing plugin, just add a new `skills/<service>/` directory. For a new plugin:

```bash
mkdir -p plugins/<plugin-name>/.claude-plugin
mkdir -p plugins/<plugin-name>/skills/<service>
```

Create `.claude-plugin/plugin.json`:
```json
{
  "name": "<plugin-name>",
  "version": "0.1.0",
  "description": "<one-line description>",
  "author": { "name": "Pascal Göllner" },
  "license": "MIT",
  "keywords": ["<relevant>", "<keywords>"]
}
```

Create `.codex-plugin/plugin.json` for the same plugin. It must point to the existing skills directory:

```json
{
  "name": "<plugin-name>",
  "version": "<same-version-as-claude-plugin>",
  "description": "<one-line description>",
  "author": { "name": "Pascal Göllner" },
  "license": "MIT",
  "keywords": ["<relevant>", "<keywords>"],
  "skills": "./skills/",
  "interface": {
    "displayName": "<Plugin Display Name>",
    "shortDescription": "<short human-facing description>",
    "longDescription": "<long human-facing description>",
    "developerName": "Pascal Göllner",
    "category": "Productivity",
    "capabilities": ["Interactive", "Write"],
    "defaultPrompt": ["<starter prompt>"],
    "screenshots": []
  }
}
```

Register the plugin in both marketplaces:

- `.claude-plugin/marketplace.json` for Claude Code
- `.agents/plugins/marketplace.json` for Codex (each plugin entry must include `interface.displayName` and `interface.shortDescription` so the picker label is explicit)

### 3. Write SKILL.md

This is the most important file. Both Claude Code and Codex read it to understand the skill. Follow this structure:

```markdown
---
name: <service>
description: Use when the user wants to <what this skill does>
---

# <Service> Skill

<One-line description>

---

## Auth Approach
<Lazy auth: do not check upfront, just run the command. Diagnose auth failures in Self-Healing>

## Tool Preference
<What tools to use and in what priority order>

## Operations: Tier 1 (Read)
<Read-only operations with exact commands>

## Operations: Tier 2 (Write)
<Create/update operations with exact commands>

## Operations: Tier 3 (Manage)
<Admin/destructive operations with exact commands>

## Self-Healing
<What to do when commands fail (help flags, schema inspection, error codes)>

## Behavioral Guidelines
<How Claude should infer intent and pick operations>
```

Key principles:
- **Exact commands.** Show copy-pasteable commands, not pseudocode.
- **Auth is lazy.** Attempt the operation first, diagnose auth failures in Self-Healing. Never print credential values.
- **Prefer helpers over raw API.** If the CLI has convenience commands, use them.
- **Confirm before destructive ops.** Always ask the user before delete operations.
- **Platform-aware tool names.** When a skill uses orchestration tools, include a short mapping for Claude Code and Codex instead of hardcoding one runtime only.
- **Self-healing is critical.** Tell the host agent how to debug when things go wrong.

### 4. Add reference docs

Create `<service>-<topic>.md` files for complex query syntaxes, format references, or recipe collections. Keep them in the same directory as SKILL.md. Reference them from SKILL.md with `See <filename>`.

Examples:
- `jql-recipes.md`: JQL query patterns for Jira
- `gmail-search-recipes.md`: Gmail search operators
- `calendar-recipes.md`: Calendar operation patterns

### 5. Write tests

Follow the existing patterns in `tests/`:

**Unit tests** (`tests/unit/test-<service>-skill.sh`):
- Verify skill loads and is recognized
- Check it describes its capabilities
- Verify it mentions the correct tool
- Check supporting references are mentioned
- Pattern: `run_claude "<prompt>" | assert_contains "<pattern>"`

**Integration tests** (`tests/integration/test-<service>-integration.sh`):
- Require live auth (skip gracefully if not available)
- Test the full CRUD lifecycle: create → read → update → delete
- Use `run_claude_logged` + `show_tools_used` for diagnostics
- Clean up after yourself (delete test resources)

**Skill triggering tests** (`tests/skill-triggering/prompts/<service>-<action>.txt`):
- One natural-language prompt per file
- Run with: `PLUGIN_DIR=plugins/<plugin> bash tests/skill-triggering/run-test.sh <skill-name> tests/skill-triggering/prompts/<file>.txt`

**Auth helpers.** Add a `check_<tool>_auth()` function to `tests/test-helpers.sh` if your tool has its own auth mechanism.

### 6. Update README.md and AGENTS.md

When adding a new plugin, edit five places in `README.md` and one in `AGENTS.md`:

- `README.md` "Skills at a glance" table at the top.
- `README.md` per-plugin "Plugins" section.
- `README.md` "Installation > Claude Code" `/plugin install` list.
- `README.md` "Installation > Codex" `/plugins` picker line.
- `README.md` "Setup" subsection for the new plugin (even if "no setup required").
- `AGENTS.md` "Current Plugins" table.

When adding only a new skill to an existing plugin, the "Skills at a glance" table and per-plugin section are usually the only required edits.

## Running Tests

```bash
# Unit tests (no auth required)
PLUGIN_DIR=plugins/<plugin> bash tests/unit/test-<service>-skill.sh
bash tests/unit/test-skill-frontmatter-yaml.sh

# Codex plugin structure
bash tests/unit/test-codex-plugin-structure.sh

# Integration tests (requires live auth)
PLUGIN_DIR=plugins/<plugin> bash tests/integration/test-<service>-integration.sh

# Skill triggering
PLUGIN_DIR=plugins/<plugin> bash tests/skill-triggering/run-test.sh <skill> tests/skill-triggering/prompts/<prompt>.txt
PLUGIN_DIR=plugins/<plugin> bash tests/skill-triggering/run-test.sh --not <skill> tests/skill-triggering/prompts/<prompt>.txt
```

## Design Decisions

- **No wrapper scripts.** Skills use the underlying CLI directly (`gws` for Google Workspace) or raw `curl` with env-var auth (for Atlassian). This keeps each skill self-contained, with no extra bash layer to maintain, debug, or ship with the plugin.
- **One skill per service, one plugin per product family.** Gmail and Calendar are both under `google-workspace`. Jira and Confluence are both under `atlassian`. Workbench is the exception: its skills (`brainstorming`, `writing-spec`, `writing-plans`, `visualizing-options`, `using-workbench`, `terse-mode`, `autopilot`, `verification-before-completion`, `test-driven-development`, `dispatching-parallel-agents`, `subagent-driven-development`, `systematic-debugging`) are peer workflow and session-control capabilities rather than separate services, so they ship together but stay split so the host agent (or autopilot) can invoke each phase independently. Terminal capabilities that depend on local Unix tools belong in the `terminal` plugin, so Windows users can skip them unless they use WSL.
- **Every plugin change bumps version.** Any change to a plugin's skills, metadata, docs, hooks, agents, or tests must bump that plugin's version in lockstep across both runtime manifests and every marketplace entry that records a version. New skills are minor bumps; fixes, docs, tests, and description changes are patch bumps unless they change behavior materially. The Claude marketplace entry (`.claude-plugin/marketplace.json`) carries a `version` field per plugin; the Codex marketplace entry (`.agents/plugins/marketplace.json`) does not, so version assertions only apply to the Claude marketplace and the two runtime manifests. Several `tests/unit/test-workbench-*-skill.sh` files pin the workbench plugin version with `jq -e '.version == "X.Y.Z"'`; bumping the workbench version requires updating those literal pins in the same commit, otherwise the next test run fails on stale assertions.
- **`tests/unit/test-codex-plugin-structure.sh` pins the plugin count and the plugin name list.** Two coupled assertions: a `plugin_count -eq N` literal and a `for plugin in <space-separated names>` list. Adding or removing a plugin requires updating both in the same commit; updating just one leaves the suite either red or asserting a stale set.
- **Skills are self-contained.** Each SKILL.md should contain everything the host agent needs to use the service without reading other files (except reference docs it explicitly links to).
- **Codex compatibility is metadata plus platform mapping.** Codex manifests live beside Claude Code manifests and point at the same `skills` directory. Platform-specific tool differences belong in the shared skill body as a mapping, not in duplicated skill files.
- **Workflow skills are execution protocols.** When a user invokes a workflow skill such as `workbench:autopilot`, follow its required sequence as an operational workflow, including branch setup, brainstorm, spec, plan, pressure-test, implementation, and verification where applicable. Do not treat the skill body as informal guidance.
- **Tests run Claude in a subprocess.** Unit tests use `run_claude` with `--dangerously-skip-permissions`. Integration tests use `run_claude_logged` with `--output-format stream-json` to capture tool usage.
- **Prefer filesystem-check unit tests over `run_claude` for structure verification.** When verifying a skill exists, has valid frontmatter, references its bundled docs, or hits required headings, use `jq`, `grep`, `head`, and `[ -s "$f" ]` (see `tests/unit/test-workbench-autopilot-skill.sh` for the canonical shape). Reserve `run_claude` for cases where actual model output must be exercised. Filesystem checks are fast, deterministic, and run without spawning Claude Code subprocesses.
- **Em-dash lint and instruction text:** when a markdown file needs to describe the forbidden em-dash or en-dash characters (e.g., a SKILL.md that explains the no-em-dash rule), reference them by Unicode codepoint (`U+2014`, `U+2013`) instead of including the literal characters. Otherwise the em-dash lint matches on the description itself.
- **Verbatim ports must substitute em-dashes/en-dashes inline at port time.** When porting a SKILL.md verbatim from an upstream that contains em-dashes (U+2014) or en-dashes (U+2013), substitute them before committing. Comma is the safe mechanical default for the ` — ` (space-dash-space) form (yields `, `); the global writing-style rule on the user side allows commas, periods, colons, semicolons, parentheses, or sentence splits. Record the substitution explicitly in the plugin's `NOTICE` ("body verbatim except em-dashes/en-dashes substituted") so a later upstream diff is reproducible. The Anthropic `frontend-design` port and the `emil-design-eng` port both follow this pattern; see their `NOTICE` files for the canonical wording.
- **Agents for long-running, context-heavy operations.** When a skill's execution would consume significant context (e.g. dozens of web pages for research), define an agent in `agents/` and have the skill dispatch it via the host subagent tool. The agent runs in an isolated subagent context. Use skills for everything else.
- **Lazy auth, never print secrets.** Skills do not check authentication upfront. They attempt the operation and only diagnose auth issues when commands fail (in Self-Healing). Credentials, tokens, and API keys are NEVER printed or echoed. Only check whether they are set (`test -n`), never display values.
- **Upstream-port attribution.** When a plugin ports a skill from a non-MIT upstream (e.g. Anthropic's Apache 2.0 `frontend-design`), the plugin directory must ship `LICENSE` (this repo's MIT license), `NOTICE` (per-file upstream attribution and original license), and a plugin-level `README.md` with a Credits section linking back to the source. Normalize the SKILL.md frontmatter to drop upstream-only fields like `license:`. See `plugins/frontend-design/` for the canonical layout.
