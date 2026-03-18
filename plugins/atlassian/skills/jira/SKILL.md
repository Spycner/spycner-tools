---
name: jira
description: Use when the user wants to interact with Jira — search issues, create/update tickets, transition status, add comments, or check sprint work
---

# Jira Skill

Interact with Jira Cloud: search issues, create and update tickets, transition workflows, add comments, manage sprints, and perform bulk operations.

---

## Auth Gate

You MUST confirm authentication before making any API calls. Run both checks in order.

### Check 1 — acli (preferred)

```bash
command -v acli && acli auth status
```

If both succeed, set `acli` as the preferred tool for this session. Skip to the **Tool Preference** section.

### Check 2 — Environment variables (curl fallback)

```bash
test -n "$ATLASSIAN_DOMAIN" && test -n "$ATLASSIAN_EMAIL" && test -n "$ATLASSIAN_API_TOKEN" && echo "ENV OK"
```

If this succeeds, use curl as the tool for this session. Skip to the **Tool Preference** section.

### Neither available — STOP

Do not proceed. Tell the user:

> I cannot connect to Jira. You need one of these:
>
> **Option A (recommended):** Install and authenticate the Atlassian CLI:
> ```
> acli auth login
> ```
>
> **Option B:** Set these environment variables:
> - `ATLASSIAN_DOMAIN` — your subdomain (e.g., `mycompany` for `mycompany.atlassian.net`)
> - `ATLASSIAN_EMAIL` — your Atlassian account email
> - `ATLASSIAN_API_TOKEN` — generate one at https://id.atlassian.com/manage/api-tokens

This is a hard gate. No API calls without auth.

---

## Tool Preference

### When acli is authenticated — prefer it for ALL operations

Key advantages over curl:

| Feature | acli | curl |
|---------|------|------|
| Descriptions/comments | Plain text | Requires ADF JSON |
| Transitions | By status name (`--status "Done"`) | Must fetch transition IDs first |
| Self-assignment | `--assignee "@me"` | Must look up account ID |
| Bulk operations | `--jql` + `--yes` flags | Manual loop |
| Structured output | `--json` flag | Already JSON |
| Tabular output | `--csv` flag | Must format yourself |

### When only env vars are available — use curl with Basic Auth

Pattern for all curl requests:

```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/..."
```

For write operations, add:

```bash
-H "Content-Type: application/json" -X POST -d '...'
```

---

## Operations — Tier 1 (Read)

### Search Issues

**acli:**
```bash
acli jira workitem search --jql "assignee = currentUser() AND resolution = Unresolved" --json
```

**curl:**
```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -X POST "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/search/jql" \
  -d '{"jql": "assignee = currentUser() AND resolution = Unresolved", "maxResults": 50}'
```

### View Issue

**acli:**
```bash
acli jira workitem view KEY-123 --json
```

**curl:**
```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/issue/KEY-123"
```

### List Projects

**acli:**
```bash
acli jira project list
```

**curl:**
```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/project/search"
```

### View Comments

**acli:**
```bash
acli jira workitem comment list --key KEY-123
```

**curl:**
```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/issue/KEY-123/comment"
```

### Sprints

**List sprints for a board:**
```bash
acli jira board list-sprints --board-id {id}
```

**List work items in a sprint:**
```bash
acli jira sprint list-workitems --sprint-id {id}
```

For sprint operations without acli, use the Jira Agile REST API (`/rest/agile/1.0/...`).

---

## Operations — Tier 2 (Write)

### Create Issue

**acli** (plain text, no ADF needed):
```bash
acli jira workitem create \
  --project PROJ \
  --type Task \
  --summary "Implement rate limiting" \
  --description "Add rate limiting to auth endpoints to prevent brute-force attacks."
```

**curl** (requires ADF body for description):
```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -X POST "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/issue" \
  -d '{
  "fields": {
    "project": {"key": "PROJ"},
    "summary": "Implement rate limiting",
    "issuetype": {"name": "Task"},
    "description": {
      "version": 1,
      "type": "doc",
      "content": [
        {
          "type": "paragraph",
          "content": [{"type": "text", "text": "Add rate limiting to auth endpoints to prevent brute-force attacks."}]
        }
      ]
    }
  }
}'
```

### Add Comment

**acli** (plain text):
```bash
acli jira workitem comment create --key KEY-123 --body "Investigated the issue. Root cause identified. Fix incoming."
```

**curl** (requires ADF body):
```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -X POST "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/issue/KEY-123/comment" \
  -d '{
  "body": {
    "version": 1,
    "type": "doc",
    "content": [
      {
        "type": "paragraph",
        "content": [{"type": "text", "text": "Investigated the issue. Root cause identified. Fix incoming."}]
      }
    ]
  }
}'
```

### Edit Fields

**acli:**
```bash
acli jira workitem edit --key KEY-123 --summary "Updated summary" --description "New description" --labels "backend,urgent"
```

**curl:**
```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -X PUT "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/issue/KEY-123" \
  -d '{
  "fields": {
    "summary": "Updated summary",
    "labels": ["backend", "urgent"]
  }
}'
```

---

## Operations — Tier 3 (Workflow)

### Transition Issue

**acli** (uses status name directly):
```bash
acli jira workitem transition --key KEY-123 --status "Done"
```

**curl** (must fetch transition IDs first, then POST):
```bash
# Step 1: Get available transitions
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/issue/KEY-123/transitions"

# Step 2: POST with the transition ID from step 1
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -X POST "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/issue/KEY-123/transitions" \
  -d '{"transition": {"id": "31"}}'
```

### Assign Issue

**acli:**
```bash
acli jira workitem assign --key KEY-123 --assignee "@me"
```

**curl:**
```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -X PUT "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/issue/KEY-123/assignee" \
  -d '{"accountId": "5b10ac8d82e05b22cc7d4ef5"}'
```

Note: with curl, you must know the user's `accountId`. Use `GET /rest/api/3/myself` to get the current user's account ID for self-assignment.

### Link Issues

**acli:**
```bash
acli jira workitem link create --inward-key KEY-123 --outward-key KEY-456 --type "Blocks"
```

**curl:**
```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -X POST "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/issueLink" \
  -d '{
  "type": {"name": "Blocks"},
  "inwardIssue": {"key": "KEY-123"},
  "outwardIssue": {"key": "KEY-456"}
}'
```

### Bulk Operations

**acli** (transition all matching issues at once):
```bash
acli jira workitem transition \
  --jql "project = PROJ AND status = 'To Do'" \
  --status "In Progress" \
  --yes
```

Bulk operations are an acli-only feature. With curl, loop over search results and POST transitions individually.

---

## Common JQL Recipes

See `jql-recipes.md` for common JQL patterns including:

- My open issues, team issues, sprint filters
- Status, priority, and date-based queries
- Text search, labels, and component filters
- Daily workflow patterns (standup, backlog grooming, sprint review)

---

## ADF Format Reference

See `adf-format.md` for the Atlassian Document Format reference.

ADF is **only needed when using curl** for write operations (create issue descriptions, add comments, update descriptions). When using `acli`, pass plain text directly — no ADF required.

---

## Self-Healing

When an API call or acli command fails:

1. **For acli errors:** check `acli [command] --help` for current flags and syntax
2. **For REST API errors:** check the response body for error details and verify the endpoint
3. **Search live docs** if the error is unclear:
   - Jira REST API v3: `https://developer.atlassian.com/cloud/jira/platform/rest/v3/`
   - acli reference: `https://developer.atlassian.com/cloud/acli/reference/commands/`

### Field Discovery

When you need to find available fields or issue types:

```bash
# Available issue types and fields for a project
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/issue/createmeta/PROJ/issuetypes"

# All available fields in the instance
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/field"
```

---

## Behavioral Guidelines

- **Infer intent from natural language.** "Show me my tickets" becomes a JQL search for `assignee = currentUser() AND resolution = Unresolved`. "What's in the current sprint?" becomes `sprint in openSprints()`.
- **Construct all JQL and ADF from user intent.** Never ask the user to write raw JQL or ADF JSON.
- **Prefer acli when available.** It is simpler, avoids ADF complexity, and supports bulk operations natively.
- **Use `--json` with acli** when you need to parse structured output programmatically.
- **Use `--yes` for bulk operations** to skip interactive confirmation prompts.
- **Map natural language to operations directly:**
  - "Move PROJ-123 to done" = `acli jira workitem transition --key PROJ-123 --status "Done"`
  - "Assign this to me" = `acli jira workitem assign --key PROJ-123 --assignee "@me"`
  - "What am I working on?" = `acli jira workitem search --jql "assignee = currentUser() AND statusCategory = 'In Progress'" --json`
  - "Create a bug for the login issue" = `acli jira workitem create --project PROJ --type Bug --summary "..."`
