# Atlassian Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Claude Code plugin marketplace (`spycner-tools`) with an `atlassian` plugin containing two skills — `jira` and `confluence` — for interacting with the Atlassian suite via `acli` and REST API.

**Architecture:** Single marketplace repo containing one plugin with two skills. Each skill is a SKILL.md with supporting reference files. No scripts, no dependencies — pure markdown that teaches Claude how to use `acli` (preferred) and curl (fallback).

**Tech Stack:** Claude Code plugin system, Markdown, `acli` CLI, Atlassian REST API v3 (Jira), Confluence REST API v1/v2

**Spec:** `docs/superpowers/specs/2026-03-18-atlassian-plugin-design.md`

---

## File Structure

| File | Responsibility |
|------|---------------|
| `.claude-plugin/marketplace.json` | Marketplace catalog — lists the atlassian plugin |
| `plugins/atlassian/.claude-plugin/plugin.json` | Plugin manifest — name, version, description |
| `plugins/atlassian/skills/jira/SKILL.md` | Jira skill — auth gate, tool detection, operations catalog, behavioral guidelines |
| `plugins/atlassian/skills/jira/jql-recipes.md` | JQL recipe reference — common query patterns |
| `plugins/atlassian/skills/jira/adf-format.md` | ADF reference — Atlassian Document Format for curl write operations |
| `plugins/atlassian/skills/confluence/SKILL.md` | Confluence skill — auth gate, tool detection, operations catalog, behavioral guidelines |
| `plugins/atlassian/skills/confluence/cql-recipes.md` | CQL recipe reference — common search patterns |
| `plugins/atlassian/skills/confluence/storage-format.md` | Storage format reference — XHTML format for Confluence page bodies |

---

### Task 1: Marketplace and Plugin Scaffolding

**Files:**
- Create: `.claude-plugin/marketplace.json`
- Create: `plugins/atlassian/.claude-plugin/plugin.json`

- [ ] **Step 1: Create marketplace.json**

```json
{
  "name": "spycner-tools",
  "owner": {
    "name": "Spycner"
  },
  "plugins": [
    {
      "name": "atlassian",
      "source": "./plugins/atlassian",
      "description": "Jira and Confluence skills for the Atlassian suite — search, create, update, and manage work items and pages",
      "version": "1.0.0"
    }
  ]
}
```

- [ ] **Step 2: Create plugin.json**

```json
{
  "name": "atlassian",
  "description": "Jira and Confluence skills for the Atlassian suite — search, create, update, and manage work items and pages",
  "version": "1.0.0",
  "author": {
    "name": "Spycner"
  },
  "keywords": ["jira", "confluence", "atlassian"]
}
```

- [ ] **Step 3: Validate the plugin structure**

Run: `claude plugin validate ./plugins/atlassian`
Expected: No errors (may warn about missing skills, which we'll add next)

- [ ] **Step 4: Commit**

```bash
jj new
jj describe -m "feat: scaffold spycner-tools marketplace and atlassian plugin"
```

---

### Task 2: JQL Recipes Reference

**Files:**
- Create: `plugins/atlassian/skills/jira/jql-recipes.md`

- [ ] **Step 1: Write jql-recipes.md**

Common JQL patterns organized by use case. Include:
- My issues: `assignee = currentUser()`, `reporter = currentUser()`
- Team issues: `assignee in membersOf("team-name")`
- Sprint filters: `sprint in openSprints()`, `sprint in futureSprints()`, `sprint is EMPTY`
- Combined patterns for daily workflow
- Status, priority, and date-based filters
- Notes on using JQL with both `acli jira workitem search --jql` and `POST /rest/api/3/search/jql`

Structure: heading, then recipes grouped by category, each with the JQL and a one-line description.

No frontmatter — this is a reference file, not a skill.

- [ ] **Step 2: Commit**

```bash
jj new
jj describe -m "feat: add JQL recipes reference for jira skill"
```

---

### Task 3: ADF Format Reference

**Files:**
- Create: `plugins/atlassian/skills/jira/adf-format.md`

- [ ] **Step 1: Write adf-format.md**

Atlassian Document Format reference for curl write operations. Include:
- When ADF is needed: only curl write operations (create issue, add comment, update description). Not needed when using `acli`.
- Minimal paragraph structure
- Headings (h1-h6)
- Ordered and unordered lists
- Code blocks (with language)
- Links and mentions
- Tables
- Complete examples for each node type
- A "markdown to ADF" mapping table so Claude can convert intent to ADF

Structure: heading, brief overview of when to use, then a section per node type with JSON example.

No frontmatter — reference file.

- [ ] **Step 2: Commit**

```bash
jj new
jj describe -m "feat: add ADF format reference for jira skill"
```

---

### Task 4: Jira SKILL.md

**Files:**
- Create: `plugins/atlassian/skills/jira/SKILL.md`

- [ ] **Step 1: Write the Jira SKILL.md**

Follow superpowers conventions. Structure:

1. **Frontmatter:**
   ```yaml
   ---
   name: jira
   description: Use when the user wants to interact with Jira — search issues, create/update tickets, transition status, add comments, or check sprint work
   ---
   ```

2. **Auth gate section:**
   - Check `command -v acli` and `acli auth status`
   - If acli not available/authenticated, check `ATLASSIAN_DOMAIN`, `ATLASSIAN_EMAIL`, `ATLASSIAN_API_TOKEN`
   - If neither available, stop with setup instructions for both paths
   - Provide token generation URL: https://id.atlassian.com/manage/api-tokens

3. **Tool preference section:**
   - If `acli` authenticated: prefer `acli` for all operations, fall back to curl when needed
   - If only env vars: use curl with Basic Auth
   - Explain the key advantages of `acli`: plain text (no ADF), transitions by status name, `@me` shorthand, bulk via JQL

4. **Operations catalog — Tier 1 (Read):**
   - Search issues: `acli jira workitem search --jql "..." --json` / `POST /rest/api/3/search/jql`
   - View issue: `acli jira workitem view KEY-123 --json` / `GET /rest/api/3/issue/{key}`
   - List projects: `acli jira project list` / `GET /rest/api/3/project/search`
   - View comments: `acli jira workitem comment list --key KEY-123` / `GET /rest/api/3/issue/{key}/comment`
   - Sprints: `acli jira board list-sprints` and `acli jira sprint list-workitems`

5. **Operations catalog — Tier 2 (Write):**
   - Create issue: `acli jira workitem create --summary --project --type` / curl with ADF
   - Add comment: `acli jira workitem comment create` / curl with ADF
   - Edit fields: `acli jira workitem edit --key --summary` / `PUT /rest/api/3/issue/{key}`

6. **Operations catalog — Tier 3 (Workflow):**
   - Transition: `acli jira workitem transition --key --status "Done"` / GET transitions then POST
   - Assign: `acli jira workitem assign --key --assignee "@me"` / `PUT assignee`
   - Link: `acli jira workitem link create` / `POST /rest/api/3/issueLink`
   - Bulk operations: `acli` with `--jql` and `--yes` flags

7. **Common recipes reference:** Point to `jql-recipes.md`

8. **ADF format reference:** Point to `adf-format.md`, note it's only needed for curl writes

9. **Self-healing section:**
   - On errors, check `acli [command] --help` or web search Atlassian docs
   - Canonical doc URLs for Jira v3 and acli reference
   - Use `GET /rest/api/3/issue/createmeta/{projectIdOrKey}/issuetypes` for field discovery
   - Use `GET /rest/api/3/field` for available fields

10. **Behavioral guidelines:**
    - Infer intent from natural language
    - Construct JQL/ADF — never ask user to write it
    - Prefer `acli` when available
    - Use `--json` for structured output, `--yes` for bulk confirmations

- [ ] **Step 2: Review the SKILL.md against the spec**

Read the spec and the written SKILL.md side by side. Verify:
- All Tier 1-3 operations are covered
- Both `acli` and curl paths are documented for each operation
- Auth gate matches the dual auth model in the spec
- Self-healing section includes updated `createmeta` endpoint

- [ ] **Step 3: Commit**

```bash
jj new
jj describe -m "feat: add jira skill with acli and REST API support"
```

---

### Task 5: CQL Recipes Reference

**Files:**
- Create: `plugins/atlassian/skills/confluence/cql-recipes.md`

- [ ] **Step 1: Write cql-recipes.md**

Common CQL search patterns. Include:
- Title search: `type = page AND title ~ "search term"`
- Space filter: `type = page AND space = "SPACEKEY"`
- My pages: `type = page AND creator = currentUser()`
- Recently updated: `type = page AND lastModified > "2026-01-01"`
- Child pages: `type = page AND ancestor = 12345`
- Combined patterns
- Notes on CQL being v1 only: `GET /wiki/rest/api/search?cql=...`

Structure: heading, then recipes grouped by category, each with CQL and description.

No frontmatter — reference file.

- [ ] **Step 2: Commit**

```bash
jj new
jj describe -m "feat: add CQL recipes reference for confluence skill"
```

---

### Task 6: Storage Format Reference

**Files:**
- Create: `plugins/atlassian/skills/confluence/storage-format.md`

- [ ] **Step 1: Write storage-format.md**

Confluence XHTML storage format reference. Include:
- When storage format is needed: creating/updating pages via curl
- Basic elements: `<p>`, `<h1>`-`<h6>`, `<ul>`/`<ol>`/`<li>`, `<a>`, `<code>`, `<table>`
- Confluence-specific macros: `<ac:structured-macro>` for code blocks, TOC, panels, etc.
- Macro parameter syntax: `<ac:parameter ac:name="...">value</ac:parameter>`
- Complete examples for each element type
- A "markdown to storage format" mapping table

Structure: heading, overview, then a section per element type with XHTML example.

No frontmatter — reference file.

- [ ] **Step 2: Commit**

```bash
jj new
jj describe -m "feat: add Confluence storage format reference"
```

---

### Task 7: Confluence SKILL.md

**Files:**
- Create: `plugins/atlassian/skills/confluence/SKILL.md`

- [ ] **Step 1: Write the Confluence SKILL.md**

Follow superpowers conventions. Structure:

1. **Frontmatter:**
   ```yaml
   ---
   name: confluence
   description: Use when the user wants to interact with Confluence — search pages, read documentation, create or update pages, or browse spaces
   ---
   ```

2. **Auth gate section:**
   - Same dual auth model as Jira skill
   - Check `acli` first, then env vars
   - Note: most Confluence operations require curl, so env vars are important even if `acli` is available

3. **Tool preference section:**
   - Curl is primary for Confluence — `acli` only handles page view and space operations
   - List what `acli` can do: `confluence page view`, `confluence space list/view`
   - List what requires curl: page search (CQL), page create/update, comments

4. **Operations catalog — Read:**
   - Search pages (CQL): curl only, `GET /wiki/rest/api/search?cql=...` (v1)
   - Get page by ID: `acli confluence page view --id {id} --body-format storage --json` / `GET /wiki/api/v2/pages/{id}?body-format=storage`
   - List pages in space: curl only, `GET /wiki/api/v2/spaces/{id}/pages`
   - List spaces: `acli confluence space list --json` / `GET /wiki/api/v2/spaces`
   - Get comments: curl only, `GET /wiki/api/v2/pages/{id}/footer-comments`

5. **Operations catalog — Write:**
   - Create page: curl only, `POST /wiki/api/v2/pages` with storage format body
   - Update page: curl only, `PUT /wiki/api/v2/pages/{id}` — must GET first for version number
   - Add comment: curl only, `POST /wiki/api/v2/pages/{id}/footer-comments`

6. **Key gotchas:**
   - v2 doesn't return body by default — add `?body-format=storage`
   - Update requires `version.number + 1`
   - CQL is v1 only, everything else is v2

7. **Common recipes reference:** Point to `cql-recipes.md`

8. **Storage format reference:** Point to `storage-format.md`

9. **Confluence curl patterns:**
   - v1 base: `https://$ATLASSIAN_DOMAIN.atlassian.net/wiki/rest/api/...`
   - v2 base: `https://$ATLASSIAN_DOMAIN.atlassian.net/wiki/api/v2/...`
   - Note the different base paths for v1 vs v2

10. **Self-healing section:**
    - On errors, check live docs via web search
    - Canonical doc URLs for Confluence v2 and acli reference
    - Check `acli confluence [command] --help` for CLI operations

11. **Behavioral guidelines:**
    - Infer intent from natural language
    - Construct CQL and storage format — never ask user to write it
    - For page updates: always GET first (for version), then PUT
    - Use `acli` for page view and space operations when available

- [ ] **Step 2: Review the SKILL.md against the spec**

Read the spec and the written SKILL.md side by side. Verify:
- All read and write operations are covered
- Both `acli` and curl paths documented where applicable
- Curl patterns show both v1 and v2 base URLs
- Auth gate matches dual auth model
- Gotchas from spec are included

- [ ] **Step 3: Commit**

```bash
jj new
jj describe -m "feat: add confluence skill with REST API and acli support"
```

---

### Task 8: Validate and Test Plugin

**Files:**
- Modify: Any files with issues found during validation

- [ ] **Step 1: Validate the complete plugin**

Run: `claude plugin validate ./plugins/atlassian`
Expected: No errors, no warnings about missing components

- [ ] **Step 2: Test locally with --plugin-dir**

Run: `claude --plugin-dir ./plugins/atlassian`
Then: `/atlassian:jira` and `/atlassian:confluence` should be available
Verify: Skills load, frontmatter is parsed correctly, reference files are accessible

- [ ] **Step 3: Test marketplace add locally**

Run: `/plugin marketplace add ./`
Then: `/plugin install atlassian@spycner-tools`
Verify: Plugin installs, skills are namespaced as `/spycner-tools:jira` and `/spycner-tools:confluence`

- [ ] **Step 4: Fix any issues found**

Address validation errors, missing files, or namespace problems.

- [ ] **Step 5: Commit any fixes**

```bash
jj new
jj describe -m "fix: address plugin validation issues"
```

---

### Task 9: Final Review and Cleanup

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update README.md**

Brief description of the marketplace, what's in it, and how to install:
- What is spycner-tools
- Available plugins (atlassian)
- Installation instructions
- Required setup (auth)

- [ ] **Step 2: Final review**

Read through all files one more time:
- `marketplace.json` — plugin name and source correct
- `plugin.json` — metadata matches marketplace entry
- Both SKILL.md files — auth gate, operations, references
- All reference files — complete and accurate
- README — accurate installation instructions

- [ ] **Step 3: Commit**

```bash
jj new
jj describe -m "docs: add README with installation instructions"
```
