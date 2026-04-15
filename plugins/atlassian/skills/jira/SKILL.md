---
name: jira
description: Use when the user wants to interact with Jira — search issues, create/update tickets, transition status, add comments, or check sprint work
---

# Jira Skill

Interact with Jira Cloud: search issues, create and update tickets, transition workflows, add comments, manage sprints, and perform bulk operations.

---

## Auth Approach

Do NOT check authentication upfront. Just run the command. If it fails with an auth error, see the **Self-Healing** section for diagnostics.

**NEVER print, echo, or log the values of `ATLASSIAN_API_TOKEN`, `ATLASSIAN_EMAIL`, or any credentials.** Only check whether they are set (e.g., `test -n`), never display their contents.

---

## Tool Preference

**Prefer raw curl for all operations.** It has the fewest dependencies and the clearest behavior. Only fall back to `acli` for the handful of things curl can't do ergonomically — bulk transitions (`--jql` + `--yes`) and some sprint operations.

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

**curl:**
```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -X POST "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/search/jql" \
  -d '{"jql": "assignee = currentUser() AND resolution = Unresolved", "maxResults": 50}'
```

**acli (fallback):**
```bash
acli jira workitem search --jql "assignee = currentUser() AND resolution = Unresolved" --json
```

### View Issue

**curl:**
```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/issue/KEY-123"
```

**acli (fallback):**
```bash
acli jira workitem view KEY-123 --json
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

**Before creating a user story, task, or research/design ticket, ask the user:**

> Do you have a ticket template or writing guide you'd like me to follow (e.g., a team standard for Description + Acceptance Criteria)?
>
> If not, I can use the default template in `ticket-template.md` — it structures Context, Deliverable, Scope, Stakeholders, Timebox, References, and Acceptance Criteria checkboxes.

If the user has their own template, follow it. If they opt into the default (or don't have one), read `ticket-template.md` and structure the `--summary`, `--description`, and acceptance criteria fields according to it. For trivial bug reports or quick one-line tasks, skip the prompt unless the user explicitly asks for a structured ticket.

**curl** (requires ADF body for description — see `adf-format.md`):
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

**acli (fallback, plain text — no ADF needed):**
```bash
acli jira workitem create \
  --project PROJ \
  --type Task \
  --summary "Implement rate limiting" \
  --description "Add rate limiting to auth endpoints to prevent brute-force attacks."
```

### Add Comment

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

**acli (fallback, plain text):**
```bash
acli jira workitem comment create --key KEY-123 --body "Investigated the issue. Root cause identified. Fix incoming."
```

### Edit Fields

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

**acli (fallback):**
```bash
acli jira workitem edit --key KEY-123 --summary "Updated summary" --description "New description" --labels "backend,urgent"
```

---

## Operations — Tier 3 (Workflow)

### Transition Issue

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

**acli (fallback, uses status name directly):**
```bash
acli jira workitem transition --key KEY-123 --status "Done"
```

### Assign Issue

**curl:**
```bash
curl -s -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -X PUT "https://$ATLASSIAN_DOMAIN.atlassian.net/rest/api/3/issue/KEY-123/assignee" \
  -d '{"accountId": "5b10ac8d82e05b22cc7d4ef5"}'
```

Note: with curl, you must know the user's `accountId`. Use `GET /rest/api/3/myself` to get the current user's account ID for self-assignment.

**acli (fallback):**
```bash
acli jira workitem assign --key KEY-123 --assignee "@me"
```

### Link Issues

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

**acli (fallback):**
```bash
acli jira workitem link create --inward-key KEY-123 --outward-key KEY-456 --type "Blocks"
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

## Ticket Writing Template

See `ticket-template.md` for the default structure to use when creating user stories, research tickets, or design tickets (Description + Acceptance Criteria). Always ask the user first whether they have their own template before falling back to this one.

---

## ADF Format Reference

See `adf-format.md` for the Atlassian Document Format reference.

ADF is required for curl write operations (create issue descriptions, add comments, update descriptions). When falling back to `acli`, pass plain text directly — no ADF required.

---

## Self-Healing

When an API call or acli command fails:

### Auth Errors (401, 403, or "not authenticated")

Check which auth paths are available — **never print token or credential values**:

```bash
# Check if acli is available and authenticated
command -v acli && acli auth status
```

```bash
# Check if env vars are set (NOT their values)
test -n "${ATLASSIAN_DOMAIN:-}" && echo "ATLASSIAN_DOMAIN is set" || echo "ATLASSIAN_DOMAIN is NOT set"
test -n "${ATLASSIAN_EMAIL:-}" && echo "ATLASSIAN_EMAIL is set" || echo "ATLASSIAN_EMAIL is NOT set"
test -n "${ATLASSIAN_API_TOKEN:-}" && echo "ATLASSIAN_API_TOKEN is set" || echo "ATLASSIAN_API_TOKEN is NOT set"
```

If neither auth path is available, tell the user:

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

### Other Errors

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
- **Prefer raw curl.** Fall back to `acli` only for bulk operations (`--jql` + `--yes`) and sprint management.
- **Use `--json` with acli** when you need to parse structured output programmatically.
- **Map natural language to operations directly (curl-first):**
  - "Move PROJ-123 to done" = GET `/issue/PROJ-123/transitions`, then POST the matching transition ID
  - "Assign this to me" = GET `/myself` for accountId, then PUT `/issue/PROJ-123/assignee`
  - "What am I working on?" = POST `/search/jql` with `assignee = currentUser() AND statusCategory = 'In Progress'`
  - "Create a bug for the login issue" = POST `/issue` with ADF description
- **Before creating a story, task, or research/design ticket, ask if the user has their own ticket template.** If not, offer the default in `ticket-template.md` and structure the description + acceptance criteria accordingly. Skip this prompt for trivial bugs or one-line tasks.
