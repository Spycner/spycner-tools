# Atlassian Plugin Design — spycner-tools Marketplace

**Date:** 2026-03-18
**Status:** Draft
**Plugin:** atlassian (v1.0.0)
**Marketplace:** spycner-tools (`Spycner/claude`)

## Overview

A Claude Code plugin that provides two skills — `/spycner-tools:jira` and `/spycner-tools:confluence` — for interacting with the Atlassian suite. Pure markdown skills with no scripts or dependencies. Claude uses `acli` (Atlassian CLI) as the preferred tool where supported, falling back to REST API via curl for operations the CLI cannot handle.

## Repository Structure

```
claude/
├── .claude-plugin/
│   └── marketplace.json              # spycner-tools marketplace catalog
├── plugins/
│   └── atlassian/
│       ├── .claude-plugin/
│       │   └── plugin.json           # plugin manifest (name, version, description)
│       └── skills/
│           ├── jira/
│           │   ├── SKILL.md          # main skill definition
│           │   ├── adf-format.md     # Atlassian Document Format reference
│           │   └── jql-recipes.md    # common JQL patterns
│           └── confluence/
│               ├── SKILL.md          # main skill definition
│               ├── storage-format.md # Confluence XHTML storage format reference
│               └── cql-recipes.md    # common CQL patterns
└── README.md
```

## Authentication & Configuration

### Dual Auth Model

The plugin supports two authentication paths depending on available tooling:

**Path 1 — `acli` (preferred when available):**
- Uses OAuth via `acli auth login` (browser-based, interactive)
- Check status with `acli auth status`
- No environment variables needed for CLI operations
- Handles domain/account automatically once logged in

**Path 2 — REST API via curl (fallback, always available):**
- Requires three environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `ATLASSIAN_DOMAIN` | Atlassian subdomain | `mycompany` (for `mycompany.atlassian.net`) |
| `ATLASSIAN_EMAIL` | Atlassian account email | `user@company.com` |
| `ATLASSIAN_API_TOKEN` | Classic API token | Generated at https://id.atlassian.com/manage/api-tokens |

One token covers both Jira and Confluence — it is tied to the Atlassian account, not a specific product.

### Auth Gate

Each skill starts with a two-step auth gate:

1. Check if `acli` is available (`command -v acli`) and authenticated (`acli auth status`)
2. If `acli` is not available or not authenticated, check env vars (`ATLASSIAN_DOMAIN`, `ATLASSIAN_EMAIL`, `ATLASSIAN_API_TOKEN`)
3. If neither path is available, stop and guide the user through setup — offer both options:
   - `acli auth login` for OAuth (simpler, recommended)
   - Environment variable setup with token generation URL for curl

No API calls are made until at least one auth path is confirmed.

### Curl Pattern (when using REST API fallback)

```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/..."
```

## Tool Preference Strategy

### Jira Skill — `acli` preferred

`acli` (v1.3.14+) provides comprehensive Jira coverage. It should be the **preferred** tool for all Jira operations because:

- **Transitions by status name** — `acli jira workitem transition --key KEY-1 --status "Done"` vs. needing to fetch transition IDs via REST API
- **`@me` shorthand** — `acli jira workitem assign --key KEY-1 --assignee "@me"` for self-assignment
- **Plain text descriptions** — no ADF required for create/edit via CLI
- **Built-in pagination** — `--paginate` flag handles multi-page results
- **Output formats** — `--json` and `--csv` flags for structured output
- **Bulk operations** — edit/transition/assign via JQL or filter across multiple issues

Fall back to curl for:
- Operations `acli` doesn't support (e.g., reading specific field metadata)
- When `acli` is not installed or not authenticated
- When more granular control over the API request is needed

### Confluence Skill — curl primary, `acli` supplementary

`acli` Confluence support is limited (v1.3.14):
- **Supported:** page view (by ID), space list/view/create/update, blog create/list/view
- **Not supported:** page create, page update, page search (CQL)

Therefore curl remains the primary tool for Confluence. `acli` can be used for quick page views by ID and space operations.

## Jira Skill

### Frontmatter

```yaml
---
name: jira
description: Use when the user wants to interact with Jira — search issues, create/update tickets, transition status, add comments, or check sprint work
---
```

### Capabilities

Operations are listed with both `acli` and curl approaches. Claude should prefer `acli` when available.

#### Tier 1 — Read

| Operation | acli command | curl fallback |
|-----------|-------------|---------------|
| Search issues (JQL) | `acli jira workitem search --jql "..." --json` | `POST /rest/api/3/search/jql` |
| Get issue details | `acli jira workitem view KEY-123 --json` | `GET /rest/api/3/issue/{key}` |
| List projects | `acli jira project list` | `GET /rest/api/3/project/search` |
| View comments | `acli jira workitem comment list --key KEY-123` | `GET /rest/api/3/issue/{key}/comment` |
| List sprints | `acli jira board list-sprints --board-id {id}` | N/A (use acli or Agile REST API) |
| Sprint work items | `acli jira sprint list-workitems --sprint-id {id}` | N/A (use acli or Agile REST API) |

#### Tier 2 — Basic Writes

| Operation | acli command | curl fallback | Notes |
|-----------|-------------|---------------|-------|
| Create issue | `acli jira workitem create --summary "..." --project KEY --type Task` | `POST /rest/api/3/issue` | acli accepts plain text; curl requires ADF body |
| Add comment | `acli jira workitem comment create --key KEY-123 --body "..."` | `POST /rest/api/3/issue/{key}/comment` | acli accepts plain text; curl requires ADF body |
| Update fields | `acli jira workitem edit --key KEY-123 --summary "..."` | `PUT /rest/api/3/issue/{key}` | acli supports `--summary`, `--description`, `--assignee`, `--labels`, `--type` |

#### Tier 3 — Workflow

| Operation | acli command | curl fallback | Notes |
|-----------|-------------|---------------|-------|
| Transition issue | `acli jira workitem transition --key KEY-123 --status "Done"` | `GET transitions` then `POST transitions` | acli uses status name directly; curl requires transition ID lookup |
| Assign/unassign | `acli jira workitem assign --key KEY-123 --assignee "@me"` | `PUT /rest/api/3/issue/{key}/assignee` | acli supports `@me` and `--remove-assignee` |
| Link issues | `acli jira workitem link create` | `POST /rest/api/3/issueLink` | |
| Bulk transition | `acli jira workitem transition --jql "..." --status "Done" --yes` | N/A (loop in curl) | acli handles bulk via JQL |

### Supporting Files

**`jql-recipes.md`** — Common JQL patterns:

- `assignee = currentUser()` — my open issues
- `reporter = currentUser()` — reported by me
- `assignee in membersOf("team-name")` — team's issues
- `sprint in openSprints()` — current sprint
- `sprint in futureSprints()` — next sprint
- `sprint is EMPTY` — backlog
- Combined patterns: `project = X AND sprint in openSprints() AND assignee = currentUser()`
- Status filters, priority filters, date-based queries

**`adf-format.md`** — Atlassian Document Format reference (curl fallback only):

- Minimal paragraph: `{"version":1,"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"..."}]}]}`
- Headings, ordered/unordered lists, code blocks, links, tables
- How to convert markdown-like intent into ADF JSON nodes
- Claude constructs ADF from user intent — user never writes JSON
- Note: ADF is only needed when using curl for write operations. `acli` accepts plain text.

### Behavioral Guidelines

- Claude infers intent: "show me my open tickets" becomes JQL + search
- Claude constructs all JQL — user describes intent in natural language
- "Move PROJ-123 to done" means: `acli jira workitem transition --key PROJ-123 --status "Done"` (or fetch transitions + POST if using curl)
- Never ask the user to write JQL or ADF manually
- Prefer `acli` for all operations when available — it's simpler, handles plain text, and avoids ADF complexity
- Use `--json` flag with `acli` when Claude needs to parse structured output
- Use `--yes` flag for bulk operations to skip confirmation prompts

## Confluence Skill

### Frontmatter

```yaml
---
name: confluence
description: Use when the user wants to interact with Confluence — search pages, read documentation, create or update pages, or browse spaces
---
```

### Capabilities

#### Read Operations

| Operation | acli command | curl command | Notes |
|-----------|-------------|-------------|-------|
| Search pages (CQL) | N/A | `GET /wiki/rest/api/search?cql=...` | v1 only, no acli support |
| Get page by ID | `acli confluence page view --id {id} --body-format storage --json` | `GET /wiki/api/v2/pages/{id}?body-format=storage` | acli available |
| List pages in space | N/A | `GET /wiki/api/v2/spaces/{id}/pages` | No acli support |
| List spaces | `acli confluence space list --json` | `GET /wiki/api/v2/spaces` | acli available |
| View space | `acli confluence space view --key KEY --json` | `GET /wiki/api/v2/spaces/{id}` | acli available |
| Get page comments | N/A | `GET /wiki/api/v2/pages/{id}/footer-comments` | No acli support |

#### Write Operations

| Operation | acli command | curl command | Notes |
|-----------|-------------|-------------|-------|
| Create page | N/A | `POST /wiki/api/v2/pages` | Storage format body, no acli support |
| Update page | N/A | `PUT /wiki/api/v2/pages/{id}` | Requires current version number + 1, no acli support |
| Add comment | N/A | `POST /wiki/api/v2/pages/{id}/footer-comments` | No acli support |

### Supporting Files

**`storage-format.md`** — Confluence storage format (XHTML-based) reference:

- Confluence uses XHTML-based storage format for page bodies, not ADF
- Basic elements: `<p>`, `<h1>`-`<h6>`, `<ul>`/`<ol>`/`<li>`, `<a href="...">`, `<code>`, `<table>`
- Confluence-specific macros: `<ac:structured-macro>` for code blocks, TOC, etc.
- How to convert markdown-like intent into storage format XHTML
- Claude constructs storage format from user intent — user never writes XHTML

**`cql-recipes.md`** — Common CQL search patterns:

- `type = page AND title ~ "search term"` — search by title
- `type = page AND space = "SPACEKEY"` — pages in a space
- `type = page AND creator = currentUser()` — my pages
- `type = page AND lastModified > "2026-01-01"` — recently updated
- `type = page AND ancestor = 12345` — pages under a parent

### Key Gotchas

- Confluence v2 does not return page body by default — must add `?body-format=storage`
- Updating a page requires passing `version.number + 1` — always GET first, then PUT
- CQL search is v1 only (`/wiki/rest/api/search`), everything else uses v2 (`/wiki/api/v2/`)
- `acli` Confluence support is limited — use it for page view and space operations, curl for everything else

### Behavioral Guidelines

- Claude infers intent: "find the onboarding doc" becomes a CQL search
- "Update the design page" means: GET page (with body + version), modify content, PUT with incremented version
- Never ask user to write CQL manually
- Use `acli confluence page view` for quick page lookups when ID is known
- Use `acli confluence space list` for space discovery

## Self-Healing Pattern

Both skills include a self-healing approach for when the API changes or something fails:

1. If an API call or `acli` command returns an error, check the live Atlassian docs via web search before retrying
2. For `acli` errors, also check `acli [command] --help` for current flags and syntax
3. Canonical documentation URLs:
   - Jira v3: `https://developer.atlassian.com/cloud/jira/platform/rest/v3/`
   - Confluence v2: `https://developer.atlassian.com/cloud/confluence/rest/v2/`
   - acli reference: `https://developer.atlassian.com/cloud/acli/reference/commands/`
4. Use self-describing API endpoints for discovery:
   - `GET /rest/api/3/issue/createmeta` — available fields/issue types for creation
   - `GET /rest/api/3/field` — all available fields
   - `GET /rest/api/3/issue/{key}/transitions` — available transitions

## Skill Structure Pattern

Both skills follow superpowers conventions:

1. **Frontmatter** — `name` + `description` starting with "Use when..."
2. **Auth gate** — check `acli` auth status first, then env vars as fallback; stop with setup instructions if neither available
3. **Tool detection** — determine `acli` availability and set tool preference for the session
4. **Operations catalog** — each operation with both `acli` and curl approaches; Claude picks the best available tool
5. **Common recipes** — reference to supporting file (jql-recipes.md / cql-recipes.md)
6. **Format reference** — reference to ADF format file (Jira curl only) or storage format (Confluence)
7. **Self-healing** — on errors, check `acli --help` and/or live docs; canonical URLs included
8. **Behavioral guidelines** — infer intent, construct queries/formats, never ask user for raw syntax

## Installation

```bash
# Add the marketplace
/plugin marketplace add Spycner/claude

# Install the plugin
/plugin install atlassian@spycner-tools
```

Skills become available as `/spycner-tools:jira` and `/spycner-tools:confluence`.

## Future Considerations

- Helper scripts (shell wrappers around common curl patterns) if curl-only becomes cumbersome
- Expanded `acli` Confluence support as Atlassian adds it (page create/update/search)
- Additional Atlassian products (Bitbucket) as separate skills in the same plugin
- Tier 4 Jira operations (bulk ops, sprint management) — partially covered by `acli` already
