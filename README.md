# spycner-tools

A personal Claude Code plugin marketplace.

## Plugins

### atlassian

Jira and Confluence skills for the Atlassian suite — search, create, update, and manage work items and pages.

**Skills:**
- `/spycner-tools:jira` — Search issues, create/update tickets, transition status, add comments, manage sprints
- `/spycner-tools:confluence` — Search pages, read documentation, create/update pages, browse spaces

## Installation

```
/plugin marketplace add Spycner/claude
/plugin install atlassian@spycner-tools
```

## Setup

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
