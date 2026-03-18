# Google Workspace Skill Design

**Date:** 2026-03-18
**Author:** Pascal Kraus
**Status:** Draft
**Version:** 1.0.0

---

## Overview

Add a `google-workspace` plugin to the `spycner-tools` marketplace with two skills — **Gmail** and **Calendar** — powered by the `gws` CLI. Follows the same plugin architecture as the existing `atlassian` plugin but without wrapper scripts, since the `gws` CLI already provides structured JSON output, auth management, and helper commands.

## Prerequisites

- `gws` CLI (v0.18+) installed and authenticated
- Setup reference: https://github.com/googleworkspace/cli

---

## Plugin Structure

```
plugins/google-workspace/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── gmail/
│   │   ├── SKILL.md
│   │   └── gmail-search-recipes.md
│   └── calendar/
│       ├── SKILL.md
│       └── calendar-recipes.md
```

No `scripts/` directory. Skills document `gws` commands directly in SKILL.md.

### plugin.json

```json
{
  "name": "google-workspace",
  "description": "Gmail and Calendar skills for Google Workspace via the gws CLI",
  "author": {
    "name": "Pascal Kraus"
  },
  "license": "MIT",
  "keywords": ["google", "workspace", "gmail", "calendar", "gws"]
}
```

---

## Auth Gate (shared pattern for both skills)

Both skills use the same auth check:

1. Verify `gws` is on PATH: `which gws`
2. Verify active session: `gws auth status`
3. If either fails, stop and instruct the user:
   > "The gws CLI is not installed or not authenticated. Install and configure it: https://github.com/googleworkspace/cli"

No scope-specific checks. No inline install commands. Point to the source of truth for setup.

---

## Gmail Skill

### SKILL.md

The SKILL.md file must include YAML frontmatter for plugin system recognition:

```yaml
---
name: gmail
description: Use when the user wants to search, read, send, or manage Gmail messages, drafts, labels, and filters via the gws CLI.
---
```

**Trigger:** User mentions email, inbox, sending mail, gmail, messages, drafts, labels.

### Operations

#### Tier 1 — Read

| Operation | Command |
|-----------|---------|
| Triage inbox | `gws gmail +triage` |
| Triage (filtered) | `gws gmail +triage --query 'from:boss' --max 5` |
| Triage (with labels) | `gws gmail +triage --labels` |
| Read a message | `gws gmail +read --id <messageId>` |
| Read with headers | `gws gmail +read --id <messageId> --headers` |
| Search/list messages | `gws gmail users messages list --params '{"userId": "me", "q": "<query>"}'` |
| List labels | `gws gmail users labels list --params '{"userId": "me"}'` |

#### Tier 2 — Write

| Operation | Command |
|-----------|---------|
| Send email | `gws gmail +send --to <addr> --subject '<subj>' --body '<body>'` |
| Send with CC/BCC | `gws gmail +send --to <addr> --subject '<subj>' --body '<body>' --cc <addr> --bcc <addr>` |
| Send with attachment | `gws gmail +send --to <addr> --subject '<subj>' --body '<body>' -a <filepath>` |
| Send HTML email | `gws gmail +send --to <addr> --subject '<subj>' --body '<html>' --html` |
| Reply | `gws gmail +reply --message-id <id> --body '<body>'` |
| Reply all | `gws gmail +reply-all --message-id <id> --body '<body>'` |
| Reply all (remove recipient) | `gws gmail +reply-all --message-id <id> --body '<body>' --remove <addr>` |
| Forward | `gws gmail +forward --message-id <id> --to <addr>` |
| Forward with note | `gws gmail +forward --message-id <id> --to <addr> --body 'FYI see below'` |
| Create draft | `gws gmail users drafts create --params '{"userId": "me"}' --json '<draft-json>'` |

#### Tier 3 — Manage

| Operation | Command |
|-----------|---------|
| Trash message | `gws gmail users messages trash --params '{"userId": "me", "id": "<id>"}'` |
| Delete message | `gws gmail users messages delete --params '{"userId": "me", "id": "<id>"}'` |
| Modify labels | `gws gmail users messages modify --params '{"userId": "me", "id": "<id>"}' --json '{"addLabelIds": ["STARRED"], "removeLabelIds": ["UNREAD"]}'` |
| Create label | `gws gmail users labels create --params '{"userId": "me"}' --json '{"name": "<label-name>"}'` |
| Delete label | `gws gmail users labels delete --params '{"userId": "me", "id": "<labelId>"}'` |
| List filters | `gws gmail users settings filters list --params '{"userId": "me"}'` |
| Create filter | `gws gmail users settings filters create --params '{"userId": "me"}' --json '<filter-json>'` |
| Delete filter | `gws gmail users settings filters delete --params '{"userId": "me", "id": "<filterId>"}'` |

### Behavioral Guidelines

- Prefer `+` helper commands over raw API calls when a helper exists.
- JSON is the default output format. Only add `--format json` when overriding a helper that defaults to table (e.g., `+triage`).
- Use `--dry-run` to preview destructive operations before executing.
- Confirm with the user before destructive operations (delete). Trash is reversible, delete is not.
- Default `userId` to `me` in `--params` unless the user specifies otherwise.

### Self-Healing

When a command fails:

- Check the command's help: `gws gmail <command> --help`
- Inspect the API schema: `gws schema gmail.<resource>.<method>` (e.g., `gws schema gmail.users.messages.list`)
- Exit codes: 0=success, 1=API error, 2=auth error, 3=validation, 4=discovery, 5=internal
- Auth errors (exit code 2): re-run `gws auth status` and direct user to https://github.com/googleworkspace/cli
- Validation errors (exit code 3): check `--params` JSON syntax and required fields

### Reference: gmail-search-recipes.md

Common Gmail search operators with examples:

- `from:<address>` — messages from a sender
- `to:<address>` — messages to a recipient
- `subject:<text>` — subject line contains text
- `is:unread` / `is:read` — read state
- `is:starred` / `is:important` — flags
- `has:attachment` — messages with attachments
- `filename:<name>` — attachment filename
- `after:YYYY/MM/DD` / `before:YYYY/MM/DD` — date range
- `label:<name>` — messages with a specific label
- `in:inbox` / `in:sent` / `in:trash` / `in:spam` — location
- `larger:5M` / `smaller:1M` — size filters
- Combining: `from:alice subject:report after:2026/01/01 has:attachment`
- OR operator: `{from:alice from:bob}` — messages from either
- Negation: `-from:noreply` — exclude a sender

---

## Calendar Skill

### SKILL.md

The SKILL.md file must include YAML frontmatter for plugin system recognition:

```yaml
---
name: calendar
description: Use when the user wants to view agenda, create and manage events, check availability, and manage calendars via the gws CLI.
---
```

**Trigger:** User mentions calendar, events, meetings, schedule, agenda, availability, free time.

### Operations

#### Tier 1 — Read

| Operation | Command |
|-----------|---------|
| View agenda | `gws calendar +agenda` |
| Today's agenda | `gws calendar +agenda --today` |
| Tomorrow's agenda | `gws calendar +agenda --tomorrow` |
| This week's agenda | `gws calendar +agenda --week` |
| Next N days | `gws calendar +agenda --days <N>` |
| Specific calendar | `gws calendar +agenda --calendar '<name>'` |
| With timezone | `gws calendar +agenda --today --timezone America/New_York` |
| Get event details | `gws calendar events get --params '{"calendarId": "primary", "eventId": "<id>"}'` |
| List events (filtered) | `gws calendar events list --params '{"calendarId": "primary", "timeMin": "<iso>", "timeMax": "<iso>"}'` |
| Check availability | `gws calendar freebusy query --json '{"timeMin": "<iso>", "timeMax": "<iso>", "items": [{"id": "primary"}]}'` |

#### Tier 2 — Write

| Operation | Command |
|-----------|---------|
| Create event | `gws calendar +insert --summary '<title>' --start '<iso>' --end '<iso>'` |
| Create with location | `gws calendar +insert --summary '<title>' --start '<iso>' --end '<iso>' --location '<place>'` |
| Create with attendees | `gws calendar +insert --summary '<title>' --start '<iso>' --end '<iso>' --attendee alice@example.com --attendee bob@example.com` |
| Create with Meet link | `gws calendar +insert --summary '<title>' --start '<iso>' --end '<iso>' --meet` |
| Create with description | `gws calendar +insert --summary '<title>' --start '<iso>' --end '<iso>' --description '<text>'` |
| Quick-add event | `gws calendar events quickAdd --params '{"calendarId": "primary", "text": "<natural language>"}'` |
| Update event | `gws calendar events patch --params '{"calendarId": "primary", "eventId": "<id>"}' --json '<event-json>'` |
| Move event | `gws calendar events move --params '{"calendarId": "primary", "eventId": "<id>", "destination": "<calId>"}'` |

#### Tier 3 — Manage

| Operation | Command |
|-----------|---------|
| Delete event | `gws calendar events delete --params '{"calendarId": "primary", "eventId": "<id>"}'` |
| List calendars | `gws calendar calendarList list` |
| Create calendar | `gws calendar calendars insert --json '{"summary": "<name>"}'` |
| Delete calendar | `gws calendar calendars delete --params '{"calendarId": "<id>"}'` |
| Share calendar (ACL) | `gws calendar acl insert --params '{"calendarId": "<id>"}' --json '{"role": "reader", "scope": {"type": "user", "value": "<email>"}}'` |
| List ACL | `gws calendar acl list --params '{"calendarId": "<id>"}'` |
| Remove ACL entry | `gws calendar acl delete --params '{"calendarId": "<id>", "ruleId": "<ruleId>"}'` |

### Behavioral Guidelines

- Prefer `+` helpers (`+agenda`, `+insert`) over raw API calls when available.
- Default to `"calendarId": "primary"` in `--params` unless the user specifies a different calendar.
- Use ISO 8601 / RFC 3339 format for all timestamps (e.g., `2026-03-18T14:00:00-04:00`).
- Use `--dry-run` to preview commands before executing destructive operations.
- Confirm with the user before deleting events or calendars.
- When creating events with `+insert`, include timezone in the ISO timestamp.

### Self-Healing

When a command fails:

- Check the command's help: `gws calendar <command> --help`
- Inspect the API schema: `gws schema calendar.<resource>.<method>` (e.g., `gws schema calendar.events.list`)
- Exit codes: 0=success, 1=API error, 2=auth error, 3=validation, 4=discovery, 5=internal
- Auth errors (exit code 2): re-run `gws auth status` and direct user to https://github.com/googleworkspace/cli
- Validation errors (exit code 3): check `--params` JSON syntax and required fields

### Reference: calendar-recipes.md

Common patterns and examples:

- **Today's events:** `gws calendar +agenda --today` or `events list --params '{"calendarId": "primary", "timeMin": "<today-start>", "timeMax": "<today-end>"}'`
- **This week's events:** `gws calendar +agenda --week`
- **Next N days:** `gws calendar +agenda --days 3`
- **Find free slots:** `gws calendar freebusy query --json '{"timeMin": "<iso>", "timeMax": "<iso>", "items": [{"id": "primary"}]}'`
- **Recurring events:** set `recurrence` field with RRULE in event JSON (e.g., `"recurrence": ["RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR"]`)
- **All-day events:** use `date` instead of `dateTime` in start/end (e.g., `"start": {"date": "2026-03-18"}`)
- **Add attendees:** use `--attendee` flag with `+insert` (repeatable) or include `attendees` array in `--json`
- **Set reminders:** include `"reminders": {"useDefault": false, "overrides": [{"method": "popup", "minutes": 10}]}` in event JSON
- **Timezone handling:** include timezone in ISO timestamps; use `--timezone` with `+agenda`; set `timeZone` field in event JSON
- **Filter by calendar:** use `--calendar '<name>'` with `+agenda`, or `"calendarId": "<id>"` in `--params` for raw API calls
- **Move between calendars:** `events move --params '{"calendarId": "primary", "eventId": "<id>", "destination": "<targetCalendarId>"}'`

---

## Root-Level Updates

### .claude-plugin/marketplace.json

Add new plugin entry to the existing `plugins` array in `.claude-plugin/marketplace.json`:

```json
{
  "name": "google-workspace",
  "source": "./plugins/google-workspace",
  "description": "Google Workspace skills (Gmail, Calendar) powered by the gws CLI",
  "version": "1.0.0"
}
```

### README.md

Update to reflect both plugins:

- Add a Google Workspace section alongside the existing Atlassian section
- List available skills: `gmail`, `calendar`
- Document prerequisites: `gws` CLI installed and authenticated
- Link to https://github.com/googleworkspace/cli for setup
- Update the installation command to reference the full plugin set

---

## Tests

All tests reuse the existing `tests/test-helpers.sh` infrastructure.

### Unit Tests (`tests/unit/`)

**`test-gmail-skill.sh`:**
- Skill is recognized when prompted about email/gmail
- Describes its capabilities (send, read, triage, labels, etc.)
- References `gws` as the tool to use
- Mentions correct operations per tier

**`test-calendar-skill.sh`:**
- Skill is recognized when prompted about calendar/events/meetings
- Describes its capabilities (agenda, create events, availability, etc.)
- References `gws` as the tool to use
- Mentions correct operations per tier

### Integration Tests (`tests/integration/`)

Require a live `gws auth status` session.

**`test-gmail-integration.sh`:**
- Triage inbox (verify structured output)
- Search messages with a query
- Read a specific message
- Send an email (to self for safety)
- Create and delete a label

**`test-calendar-integration.sh`:**
- View agenda
- Create a test event
- Get the created event details
- Update the event (change title)
- Delete the test event
- List calendars

### Skill Triggering Tests (`tests/skill-triggering/prompts/`)

Prompt files to verify correct skill activation:

| File | Prompt | Expected Skill |
|------|--------|---------------|
| `gmail-send.txt` | "Send an email to bob@example.com about the project update" | gmail |
| `gmail-triage.txt` | "What's in my inbox?" | gmail |
| `gmail-search.txt` | "Find emails from alice about the report" | gmail |
| `calendar-agenda.txt` | "What meetings do I have today?" | calendar |
| `calendar-create.txt` | "Schedule a meeting with the team tomorrow at 2pm" | calendar |
| `calendar-availability.txt` | "When am I free this week?" | calendar |

---

## Future Expansion

Additional services can be added as sibling skill directories under `plugins/google-workspace/skills/`:
- `drive/` — file management
- `sheets/` — spreadsheet operations
- `docs/` — document editing
- `tasks/` — task management
- `chat/` — messaging

Each follows the same pattern: `SKILL.md` + optional reference docs, no wrapper scripts.
