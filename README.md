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
| `research` | research | Orchestrator-driven deep research: parallel cluster researchers, synthesis under independent review, polished report with citations |
| `writing` | writing | Multi-phase prose pipeline (interview, outline, throughline gate, draft, seven-critic panel, finishing), with format-aware Smart-Brevity critic |
| `pyramid` | writing | Barbara Minto pyramid-principle outlines or restructures, with a parallel MECE / So-What / Q-A / Inductive-Deductive audit panel and SCQA opener |
| `tech-doc` | writing | Diátaxis-aware technical documentation pipeline (tutorials, how-tos, references, explanations) with Microsoft and Google style-guide presets |

## Plugins

### atlassian

Jira and Confluence skills for the Atlassian suite — search, create, update, and manage work items and pages.

**Skills:**
- `/pgoell-claude-tools:jira` — Search issues, create/update tickets, transition status, add comments, manage sprints
- `/pgoell-claude-tools:confluence` — Search pages, read documentation, create/update pages, browse spaces

### google-workspace

Gmail and Calendar skills for Google Workspace — powered by the `gws` CLI.

**Skills:**
- `/pgoell-claude-tools:gmail` — Search, read, send, and manage Gmail messages, drafts, labels, and filters
- `/pgoell-claude-tools:calendar` — View agenda, create and manage events, check availability, manage calendars

### research

Orchestrator-driven deep research with parallel cluster researchers, synthesis under independent review, and a writer pass that produces a polished report.

**Skills:**
- `/pgoell-claude-tools:research`: orchestrator-driven pipeline. Plans the work internally, spawns parallel deep-research subagents (one per topic cluster, iterative until saturation, single-md output with inline sources), synthesizes findings, and writes the final report. Two independent review gates (synthesis-reviewer for substance, writer-reviewer for prose) with unbounded review loops, periodic check-ins, and stall detection.

### writing

Multi-phase writing pipeline modelled on Katie Parrott's process. Interview, outline, throughline gate (≤10-word compression), draft, panel review (seven critics including steel-man preemption audit), and finishing passes for blog posts and longer-form prose. Format-aware: opt-in Smart-Brevity critic for memos, newsletters, and announcements. Also ships a dedicated Pyramid Principle skill for memos, recommendations, and analytical documents, and a Diátaxis-aware tech-doc skill for tutorials, how-to guides, references, and explanations.

**Skills:**
- `/pgoell-claude-tools:writing`: orchestrates the full pipeline with phase-selectable resume. For analytical formats (memo, briefing, announcement), dispatches to the pyramid skill for the outline phase and runs an analytical draft prompt. Ships with a default style guide that any project can override.
- `/pgoell-claude-tools:pyramid`: produces a pyramid-structured outline (greenfield) or restructures an existing draft into pyramid form. Five phases (intake, construct, audit, opener, render) with a parallel audit panel (MECE, So-What, Q-A Alignment, Inductive-Deductive).
- `/pgoell-claude-tools:tech-doc`: Diátaxis-aware technical writing pipeline. Drafts and reviews tutorials, how-to guides, API and CLI references, and conceptual explanations. Bundles full transcriptions of the Microsoft Writing Style Guide and Google Developer Documentation Style Guide as selectable presets (with a merged `house` default), each preset structured as eight topic-scoped sidecars. Six-phase pipeline (intake, outline, throughline, draft, panel, finishing) with eight-critic panel per quadrant and three sequential finishing passes (AI-pattern-detector, style-enforcer-tech, terminology-consistency).

## Installation

### Claude Code

```
/plugin marketplace add pgoell/pgoell-claude-tools
/plugin install atlassian@pgoell-claude-tools
/plugin install google-workspace@pgoell-claude-tools
/plugin install research@pgoell-claude-tools
/plugin install writing@pgoell-claude-tools
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

In the picker, install `atlassian`, `google-workspace`, `research`, and `writing`.

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
