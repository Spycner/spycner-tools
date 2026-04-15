# pgoell-claude-tools

A Claude Code plugin marketplace containing skill plugins for external services.

## Repository Structure

```
.claude-plugin/
  marketplace.json          # Plugin registry — lists all plugins with name, source, version
plugins/
  <plugin-name>/
    .claude-plugin/
      plugin.json           # Plugin metadata (name, description, author, license, keywords)
    agents/                 # Optional: agent definitions for long-running isolated tasks
      <agent-name>.md
    skills/
      <service>/
        SKILL.md            # Skill definition (THE core file — this is what Claude reads)
        <reference>.md      # Supporting reference docs (recipes, format guides)
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
| `research` | 1.3.0 | `research` (multi-agent pipeline with review gates) |

## How to Develop a New Skill

### 1. Plan the skill

- Identify the CLI tool or API the skill wraps
- Prefer invoking the CLI or `curl` directly in the skill — no wrapper scripts
- Define operation tiers: Tier 1 (Read), Tier 2 (Write), Tier 3 (Manage/Admin)

### 2. Create the plugin structure

If adding to an existing plugin, just add a new `skills/<service>/` directory. For a new plugin:

```bash
mkdir -p plugins/<plugin-name>/.claude-plugin
mkdir -p plugins/<plugin-name>/skills/<service>
```

Create `plugin.json`:
```json
{
  "name": "<plugin-name>",
  "description": "<one-line description>",
  "author": { "name": "Pascal Kraus" },
  "license": "MIT",
  "keywords": ["<relevant>", "<keywords>"]
}
```

Register in `.claude-plugin/marketplace.json` by adding to the `plugins` array.

### 3. Write SKILL.md

This is the most important file — it's what Claude reads to understand the skill. Follow this structure:

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

## Operations — Tier 1 (Read)
<Read-only operations with exact commands>

## Operations — Tier 2 (Write)
<Create/update operations with exact commands>

## Operations — Tier 3 (Manage)
<Admin/destructive operations with exact commands>

## Self-Healing
<What to do when commands fail — help flags, schema inspection, error codes>

## Behavioral Guidelines
<How Claude should infer intent and pick operations>
```

Key principles:
- **Exact commands** — show copy-pasteable commands, not pseudocode
- **Auth is lazy** — attempt the operation first, diagnose auth failures in Self-Healing. Never print credential values.
- **Prefer helpers over raw API** — if the CLI has convenience commands, use them
- **Confirm before destructive ops** — always ask the user before delete operations
- **Self-healing is critical** — tell Claude how to debug when things go wrong

### 4. Add reference docs

Create `<service>-<topic>.md` files for complex query syntaxes, format references, or recipe collections. Keep them in the same directory as SKILL.md. Reference them from SKILL.md with `See <filename>`.

Examples:
- `jql-recipes.md` — JQL query patterns for Jira
- `gmail-search-recipes.md` — Gmail search operators
- `calendar-recipes.md` — Calendar operation patterns

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

**Auth helpers** — add a `check_<tool>_auth()` function to `tests/test-helpers.sh` if your tool has its own auth mechanism.

### 6. Update README.md

Add the new plugin/skill to the Plugins section, Installation commands, and Setup instructions.

## Running Tests

```bash
# Unit tests (no auth required)
PLUGIN_DIR=plugins/<plugin> bash tests/unit/test-<service>-skill.sh

# Integration tests (requires live auth)
PLUGIN_DIR=plugins/<plugin> bash tests/integration/test-<service>-integration.sh

# Skill triggering
PLUGIN_DIR=plugins/<plugin> bash tests/skill-triggering/run-test.sh <skill> tests/skill-triggering/prompts/<prompt>.txt
```

## Design Decisions

- **No wrapper scripts.** Skills use the underlying CLI directly (`gws` for Google Workspace) or raw `curl` with env-var auth (for Atlassian). This keeps each skill self-contained — no extra bash layer to maintain, debug, or ship with the plugin.
- **One skill per service, one plugin per product family.** Gmail and Calendar are both under `google-workspace`. Jira and Confluence are both under `atlassian`.
- **Skills are self-contained.** Each SKILL.md should contain everything Claude needs to use the service without reading other files (except reference docs it explicitly links to).
- **Tests run Claude in a subprocess.** Unit tests use `run_claude` with `--dangerously-skip-permissions`. Integration tests use `run_claude_logged` with `--output-format stream-json` to capture tool usage.
- **Agents for long-running, context-heavy operations.** When a skill's execution would consume significant context (e.g. dozens of web pages for research), define an agent in `agents/` and have the skill dispatch it via the Agent tool. The agent runs in an isolated subagent context. Use skills for everything else.
- **Lazy auth, never print secrets.** Skills do not check authentication upfront. They attempt the operation and only diagnose auth issues when commands fail (in Self-Healing). Credentials, tokens, and API keys are NEVER printed or echoed — only check whether they are set (`test -n`), never display values.
