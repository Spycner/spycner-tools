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
    agents/                 # Optional, currently unused: forward-looking slot for agent definitions
      <agent-name>.md       #   that long-running, context-heavy skills could dispatch as subagents.
                            #   No plugin uses this directory yet; see the matching Design Decision.
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
containers/
  dev/                      # Podman-first dev container for running Claude or Codex
                            # with bypass permissions in host-isolated mode
    Dockerfile
    entrypoint.sh
    run-dev                 # wrapper script
    README.md               # usage and manual acceptance checklist
```

## Current Plugins

| Plugin | Version | Skills |
|--------|---------|--------|
| `atlassian` | 2.0.0 | `jira`, `confluence` |
| `google-workspace` | 1.0.0 | `gmail`, `calendar` |
| `research` | 2.1.1 | `research` (multi-agent pipeline with review gates) |
| `writing` | 1.6.1 | `writing`, `pyramid`, `tech-doc` |
| `runtime-bridge` | 0.1.0 | `claude-codex-bridge` |
| `agent-system-management` | 0.4.2 | `improving-instructions`, `capturing-session-learnings`, `creating-skills` |
| `workbench` | 0.12.0 | `brainstorming`, `writing-spec`, `writing-plans`, `visualizing-options`, `using-workbench`, `terse-mode`, `autopilot`, `verification-before-completion`, `test-driven-development`, `dispatching-parallel-agents`, `subagent-driven-development`, `systematic-debugging`, `crafting-html`, `crafting-design-systems` |
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

When adding a new plugin, the documentation lockstep set is six sites: five in `README.md` and one in `AGENTS.md`. (1) `README.md` "Skills at a glance" table at the top. (2) `README.md` per-plugin "Plugins" section. (3) `README.md` "Installation > Claude Code" `/plugin install` list. (4) `README.md` "Installation > Codex" `/plugins` picker line. (5) `README.md` "Setup" subsection for the new plugin (even if "no setup required"). (6) `AGENTS.md` "Current Plugins" table (CLAUDE.md is a symlink, so it updates automatically).

This is separate from, and additional to, the version-bump lockstep documented under Design Decisions ("Every plugin change bumps version"). Adding a new plugin requires both lockstep sets in the same commit: the six docs sites here, plus the five version-pinned sites listed there.

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
- **One skill per service, one plugin per product family.** Gmail and Calendar are both under `google-workspace`. Jira and Confluence are both under `atlassian`. Workbench is the exception: its skills (`brainstorming`, `writing-spec`, `writing-plans`, `visualizing-options`, `using-workbench`, `terse-mode`, `autopilot`, `verification-before-completion`, `test-driven-development`, `dispatching-parallel-agents`, `subagent-driven-development`, `systematic-debugging`, `crafting-html`, `crafting-design-systems`) are peer workflow and session-control capabilities rather than separate services, so they ship together but stay split so the host agent (or autopilot) can invoke each phase independently. Terminal capabilities that depend on local Unix tools belong in the `terminal` plugin, so Windows users can skip them unless they use WSL.
- **Every plugin change bumps version.** Any change to a plugin's skills, metadata, docs, hooks, agents, or tests must bump that plugin's version in lockstep across every site that records the version. New skills are minor bumps; fixes, docs, tests, and description changes are patch bumps unless they change behavior materially. The full lockstep set is: (1) `.claude-plugin/plugin.json`, (2) `.codex-plugin/plugin.json`, (3) the `version` field of the plugin's entry in `.claude-plugin/marketplace.json`, (4) the plugin's row in the AGENTS.md "Current Plugins" table (CLAUDE.md is a symlink to AGENTS.md, so it updates automatically), and (5) every per-plugin test under `tests/unit/test-<plugin>-*-skill.sh` that pins the version with a `jq -e '.version == "X.Y.Z"'` assertion or a literal grep. The Codex marketplace entry (`.agents/plugins/marketplace.json`) does not record a version field. Forgetting any one of these members leaves CI red on the next run, or worse, ships a misleading version number to consumers reading the table.
- **`tests/unit/test-codex-plugin-structure.sh` pins the plugin count and the plugin name list.** Two coupled assertions: a `plugin_count -eq N` literal and a `for plugin in <space-separated names>` list. Adding or removing a plugin requires updating both in the same commit; updating just one leaves the suite either red or asserting a stale set. Note: this is a separate pin from the per-plugin version pins in the version-bump lockstep above. The version pins assert "this plugin is at version X.Y.Z"; the structure pin asserts "this repo contains exactly these N plugins". A plugin add/remove touches both, but a version bump only touches the version pin.
- **Skills are self-contained.** Each SKILL.md should contain everything the host agent needs to use the service without reading other files (except reference docs it explicitly links to).
- **Codex compatibility is metadata plus platform mapping.** Codex manifests live beside Claude Code manifests and point at the same `skills` directory. Platform-specific tool differences belong in the shared skill body as a mapping, not in duplicated skill files.
- **Workflow skills are execution protocols.** When a user invokes a workflow skill such as `workbench:autopilot`, follow its required sequence as an operational workflow, including branch setup, brainstorm, spec, plan, pressure-test, implementation, and verification where applicable. Do not treat the skill body as informal guidance.
- **Tests run Claude in a subprocess.** Unit tests use `run_claude` with `--dangerously-skip-permissions`. Integration tests use `run_claude_logged` with `--output-format stream-json` to capture tool usage.
- **Prefer filesystem-check unit tests over `run_claude` for structure verification.** When verifying a skill exists, has valid frontmatter, references its bundled docs, or hits required headings, use `jq`, `grep`, `head`, and `[ -s "$f" ]` (see `tests/unit/test-workbench-autopilot-skill.sh` for the canonical shape). Reserve `run_claude` for cases where actual model output must be exercised. Filesystem checks are fast, deterministic, and run without spawning Claude Code subprocesses.
- **Per-artifact format and path resolution via `.workbench/config.md`.** Four workbench skills (`writing-spec`, `writing-plans`, `brainstorming`, `systematic-debugging`) consult an optional `.workbench/config.md` at repo root for per-artifact output format (`md` or `html`) and output directory. Format resolution order is per-prompt override, then `.workbench/config.md` `## Output formats`, then per-skill hard-coded default. Path resolution order is `.workbench/autopilot.md` `## Documentation paths` (specs and plans only), then `.workbench/config.md` `## Output paths`, then per-skill default. Format and path resolve independently. Per-skill defaults are: specs `md` in `docs/specs`, plans `md` in `docs/plans`, brainstorm summaries `html` in `.workbench/brainstorms`, debug reports `html` in `.workbench/debug-reports`. `research:research` deliberately opts out: it has its own hard-coded default (HTML, `reports/<topic-slug>-<YYYY-MM-DD>/report.html`) and never consults `.workbench/config.md`. Full schema in `plugins/workbench/skills/autopilot/references/config-schema.md`.
- **HTML artifact output is a first-class skill mode.** Five skills (`writing-spec`, `writing-plans`, `brainstorming`, `systematic-debugging`, `research:research`) ship an `## Output Format` section plus a `references/<artifact>-template.html` and can emit either markdown or HTML. The `workbench:crafting-html` skill is the catch-all for standalone HTML artifacts not covered by another skill (PR walkthroughs, slide decks, status reports, design prototypes, custom editing interfaces); it bundles 21 reference files under `references/` and instructs lazy reads. Each of the five HTML-producing skills cross-references `crafting-html` for out-of-scope artifact types. To add an HTML output mode to a sixth skill, follow the same pattern: an `## Output Format` section with the format and path resolution order, a bundled `references/<artifact>-template.html`, a cross-reference to `crafting-html`, and per-skill em-dash lint coverage over `references/*.html`. The companion skill `workbench:crafting-design-systems` supplies the optional theming layer (CSS variables, components, images) that any of the producers (the five plus `crafting-html`) inlines into its artifact when a design system is configured via per-prompt override or `.workbench/config.md` `## Design system`. The five templates do not share a canonical CSS variable schema; each declares its own set in its `:root` block. The per-template variable inventory lives in `plugins/workbench/skills/crafting-design-systems/SKILL.md`. If you rename, add, or remove a CSS variable in any producer's `references/<artifact>-template.html` `:root` block, update the inventory in `crafting-design-systems` in the same commit.
- **Em-dash lint and instruction text:** when a markdown file needs to describe the forbidden em-dash or en-dash characters (e.g., a SKILL.md that explains the no-em-dash rule), reference them by Unicode codepoint (`U+2014`, `U+2013`) instead of including the literal characters. Otherwise the em-dash lint matches on the description itself. The lint also runs over bundled `references/*.html` template files; in HTML body copy, the entity forms `&mdash;`, `&#8212;`, `&ndash;`, `&#8211;` are permitted as the escape hatch (the lint matches the raw codepoints, not the entities).
- **Verbatim ports must substitute em-dashes/en-dashes inline at port time.** When porting a SKILL.md verbatim from an upstream that contains em-dashes (U+2014) or en-dashes (U+2013), substitute them before committing. Comma is the safe mechanical default for the ` — ` (space-dash-space) form (yields `, `); the global writing-style rule on the user side allows commas, periods, colons, semicolons, parentheses, or sentence splits. Record the substitution explicitly in the plugin's `NOTICE` ("body verbatim except em-dashes/en-dashes substituted") so a later upstream diff is reproducible. The `emil-design-eng` port is the canonical example of this clause; see `plugins/frontend-design/NOTICE` for the exact wording. The Anthropic `frontend-design` port did not need a substitution clause because the upstream contained no em-dashes or en-dashes; if a future re-port encounters them, add the clause to its `NOTICE` block.
- **Agents for long-running, context-heavy operations (forward-looking, currently unused).** When a skill's execution would consume significant context (e.g. dozens of web pages), the intended layout is to define an agent in the plugin's `agents/` directory and have the skill dispatch it via the host subagent tool so the agent runs in an isolated subagent context. No plugin in this repo currently uses an `agents/` directory; the `research` plugin orchestrates subagents from prompt templates inside `skills/research/` instead. Treat `agents/` as a reserved, documented slot rather than a populated convention. Use skills for everything else.
- **Lazy auth, never print secrets.** Skills do not check authentication upfront. They attempt the operation and only diagnose auth issues when commands fail (in Self-Healing). Credentials, tokens, and API keys are NEVER printed or echoed. Only check whether they are set (`test -n`), never display values.
- **Upstream-port attribution.** When a plugin ports a skill from a non-MIT upstream (e.g. Anthropic's Apache 2.0 `frontend-design`), the plugin directory must ship `LICENSE` (this repo's MIT license), `NOTICE` (per-file upstream attribution and original license), and a plugin-level `README.md` with a Credits section linking back to the source. Normalize the SKILL.md frontmatter to drop upstream-only fields like `license:`. See `plugins/frontend-design/` for the canonical layout.
- **Upstream with no declared license.** If the upstream repo declares no license (GitHub API reports `license: null`, no `LICENSE` file), do not silently relicense and do not refuse to port. Vendor verbatim and disclose the license absence explicitly in `NOTICE`: capture the upstream commit SHA at port time, document the upstream author's publishing intent (e.g. "distributed via `npx skills add <user>/<repo>` for AI agent use, per its README"), and state that all rights to the original text remain with the upstream author. Note that adaptations (such as the em-dash substitution) are mechanical and add no original authorship. The `emil-design-eng` port is the canonical example.
