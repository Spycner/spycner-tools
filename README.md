# pgoell-claude-tools

A personal plugin marketplace for Claude Code and Codex.

The two runtimes use separate plugin metadata, but the skills are single sourced. Claude Code reads `.claude-plugin` metadata. Codex reads `.codex-plugin` metadata and `.agents/plugins/marketplace.json`. Both point at the same `plugins/<plugin>/skills/` directories.

## Skills at a glance

| Skill | Plugin | What it does |
|---|---|---|
| `jira` | atlassian | Search Jira issues, create and update tickets, transition workflows, comment, manage sprints, run bulk operations |
| `confluence` | atlassian | Search Confluence pages, read documentation, create and update pages, browse spaces |
| `gmail` | google-workspace | Triage inbox, search and read messages, send mail, manage drafts, labels, and filters via the `gws` CLI |
| `calendar` | google-workspace | View agenda, create and manage events, check availability, manage calendars via the `gws` CLI |
| `research` | research | Research complex topics and produce sourced reports |
| `writing` | writing | Draft, review, and finish long form prose |
| `pyramid` | writing | Structure analytical documents with the Pyramid Principle |
| `tech-doc` | writing | Draft, review, and finish technical documentation |
| `claude-codex-bridge` | runtime-bridge | Align Claude Code and Codex project files |
| `improving-instructions` | agent-system-management | Audit and improve agent instruction files |
| `capturing-session-learnings` | agent-system-management | Capture session learnings into the right instruction file |
| `brainstorming` | workbench | Turn ideas into clear design decisions |
| `using-workbench` | workbench | Load Workbench skill rules and routing |
| `creating-skills` | agent-system-management | Scaffold, iterate, pressure-test, and tune skills across the full lifecycle |

## Plugins

### atlassian

Jira and Confluence skills for Atlassian Cloud.

**Skills:**
- `/pgoell-claude-tools:jira`: Search issues, update tickets, transition status, add comments, and manage sprints
- `/pgoell-claude-tools:confluence`: Search pages, read documentation, update pages, and browse spaces

### google-workspace

Gmail and Calendar skills for Google Workspace, powered by the `gws` CLI.

**Skills:**
- `/pgoell-claude-tools:gmail`: Search, read, send, and manage Gmail messages, drafts, labels, and filters
- `/pgoell-claude-tools:calendar`: View agendas, manage events, check availability, and manage calendars

### research

Research complex topics and produce sourced reports.

**Skills:**
- `/pgoell-claude-tools:research`: Plan focused investigations, gather sources, synthesize findings, review conclusions, and write reports.

### writing

Writing skills for prose, analytical structure, and technical documentation.

**Skills:**
- `/pgoell-claude-tools:writing`: Draft, review, and finish long form prose.
- `/pgoell-claude-tools:pyramid`: Structure memos, recommendations, briefings, and decision documents with the Pyramid Principle.
- `/pgoell-claude-tools:tech-doc`: Draft, review, and finish tutorials, how to guides, references, and explanations.

### runtime-bridge

Aligns Claude Code and Codex project configuration.

**Skills:**
- `/pgoell-claude-tools:claude-codex-bridge`: Align project files, settings, hooks, agents, and plugin availability

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

## Installation

### Claude Code

```
/plugin marketplace add pgoell/pgoell-claude-tools
/plugin install atlassian@pgoell-claude-tools
/plugin install google-workspace@pgoell-claude-tools
/plugin install research@pgoell-claude-tools
/plugin install writing@pgoell-claude-tools
/plugin install runtime-bridge@pgoell-claude-tools
/plugin install agent-system-management@pgoell-claude-tools
/plugin install workbench@pgoell-claude-tools
```

### Codex

Add the marketplace from your shell:

```
codex plugin marketplace add pgoell/pgoell-claude-tools
```

Then install plugins from inside Codex:

```
codex
/plugins
```

In the picker, install `atlassian`, `google-workspace`, `research`, `writing`, `runtime-bridge`, `agent-system-management`, and `workbench`.

`codex plugin marketplace add` accepts `owner/repo[@ref]`, an HTTPS or SSH Git URL, or a local marketplace root directory. The marketplace file lives at `.agents/plugins/marketplace.json` and the per-plugin Codex manifests live at `plugins/<plugin>/.codex-plugin/plugin.json`. Both reuse the same `plugins/<plugin>/skills/` directories as Claude Code, single sourced.

To pick up changes, run `codex plugin marketplace upgrade pgoell-claude-tools` and re-install the affected plugins from `/plugins` inside Codex. Codex does not poll for updates; it uses the cached snapshot from `add` time until you upgrade.

## Setup

### Atlassian

The plugin supports two authentication paths:

**Option 1 — Atlassian CLI (recommended):**
```bash
brew install atlassian/tap/acli
acli auth login
```

**Option 2 — API token (for curl fallback):**

Generate a token at https://id.atlassian.com/manage/api-tokens, then set:

```bash
export ATLASSIAN_DOMAIN="your-domain"    # e.g. mycompany (for mycompany.atlassian.net)
export ATLASSIAN_EMAIL="you@company.com"
export ATLASSIAN_API_TOKEN="your-token"
```

### Google Workspace

Install and authenticate the `gws` CLI:

```bash
npm i -g @anthropic-ai/gws
gws auth login -s gmail,calendar
```

For full setup instructions, see: https://github.com/googleworkspace/cli

### Research Plugin

No authentication required. The research plugin uses the host agent's web search and fetch or browse tools.

### runtime-bridge

No setup required. In any project, ask the skill to align Claude Code and Codex artifacts (e.g. "make this project work with both Claude Code and Codex"). After the first apply that writes into `.codex/`, run `codex` once in that project and accept the trust prompt.

### agent-system-management

No setup required. Three skills in one plugin: ask `improving-instructions` to "audit my CLAUDE.md files" (cold audit), `capturing-session-learnings` to "update AGENTS.md with what we learned this session" (warm capture), or `creating-skills` to "scaffold a new skill in this marketplace", "iterate on this skill until it triggers reliably", "pressure-test this discipline skill", "optimize the description for triggering", or "turn this conversation into a reusable skill". The instruction skills operate on local agent-instruction files only (no network); the lifecycle skill detects the marketplace shape (Claude Code, Codex, or both) and adapts.
