---
name: calendar
description: Use when the user wants to view agenda, create and manage events, check availability, and manage calendars via the gws CLI.
---

# Calendar Skill

View agenda, create and manage events, check availability, and manage calendars using the `gws` CLI.

---

## Auth Gate

Before any operation, verify the gws CLI is available and authenticated:

1. Check gws is on PATH: `which gws`
2. Check auth is valid: `gws auth status`

If either check fails, stop and tell the user:
> "The gws CLI is not installed or not authenticated. Install and configure it: https://github.com/googleworkspace/cli"

---

## Tool Preference

All operations use the `gws` CLI directly. No wrapper scripts.

- **Helper commands** (prefixed with `+`): Use for common operations. These handle timezone detection, formatting, and attendee management automatically.
- **Raw API calls**: Use when no helper exists. Pass parameters via `--params '<JSON>'` and request bodies via `--json '<JSON>'`. Resource paths are space-separated (e.g., `gws calendar events list`).

Always prefer `+` helpers when one exists for the operation.

---

## Operations — Tier 1 (Read)

### View Agenda

```bash
gws calendar +agenda
gws calendar +agenda --today
gws calendar +agenda --tomorrow
gws calendar +agenda --week
gws calendar +agenda --days 3
gws calendar +agenda --calendar 'Work'
gws calendar +agenda --today --timezone America/New_York
```

### Get Event Details

```bash
gws calendar events get --params '{"calendarId": "primary", "eventId": "<id>"}'
```

### List Events (Filtered)

```bash
gws calendar events list --params '{"calendarId": "primary", "timeMin": "<iso>", "timeMax": "<iso>"}'
```

### Check Availability

```bash
gws calendar freebusy query --json '{"timeMin": "<iso>", "timeMax": "<iso>", "items": [{"id": "primary"}]}'
```

---

## Operations — Tier 2 (Write)

### Create Event

```bash
gws calendar +insert --summary '<title>' --start '<iso>' --end '<iso>'
gws calendar +insert --summary '<title>' --start '<iso>' --end '<iso>' --location '<place>'
gws calendar +insert --summary '<title>' --start '<iso>' --end '<iso>' --attendee alice@example.com --attendee bob@example.com
gws calendar +insert --summary '<title>' --start '<iso>' --end '<iso>' --meet
gws calendar +insert --summary '<title>' --start '<iso>' --end '<iso>' --description '<text>'
```

### Quick-Add Event

```bash
gws calendar events quickAdd --params '{"calendarId": "primary", "text": "<natural language>"}'
```

### Update Event

```bash
gws calendar events patch --params '{"calendarId": "primary", "eventId": "<id>"}' --json '<event-json>'
```

### Move Event

```bash
gws calendar events move --params '{"calendarId": "primary", "eventId": "<id>", "destination": "<calId>"}'
```

---

## Operations — Tier 3 (Manage)

### Delete Event

```bash
gws calendar events delete --params '{"calendarId": "primary", "eventId": "<id>"}'
```

Confirm with the user before deleting.

### List Calendars

```bash
gws calendar calendarList list
```

### Create / Delete Calendar

```bash
gws calendar calendars insert --json '{"summary": "<name>"}'
gws calendar calendars delete --params '{"calendarId": "<id>"}'
```

Confirm with the user before deleting a calendar.

### Access Control (ACL)

```bash
gws calendar acl list --params '{"calendarId": "<id>"}'
gws calendar acl insert --params '{"calendarId": "<id>"}' --json '{"role": "reader", "scope": {"type": "user", "value": "<email>"}}'
gws calendar acl delete --params '{"calendarId": "<id>", "ruleId": "<ruleId>"}'
```

---

## Common Calendar Recipes

See `calendar-recipes.md`

---

## Self-Healing

When a command fails:

- Check the command's help: `gws calendar <command> --help`
- Inspect the API schema: `gws schema calendar.<resource>.<method>`
- Use `--dry-run` to preview requests without executing
- Exit codes: 0=success, 1=API error, 2=auth error, 3=validation, 4=discovery, 5=internal
- Auth errors (exit 2): re-run `gws auth status` and direct user to https://github.com/googleworkspace/cli
- Validation errors (exit 3): check `--params` JSON syntax and required fields

---

## Behavioral Guidelines

- Prefer `+` helpers (`+agenda`, `+insert`) over raw API calls when available.
- Default to `"calendarId": "primary"` in `--params` unless the user specifies a different calendar.
- Use ISO 8601 / RFC 3339 format for all timestamps (e.g., `2026-03-18T14:00:00-04:00`).
- Use `--dry-run` to preview commands before executing destructive operations.
- Confirm with the user before deleting events or calendars.
- When creating events with `+insert`, include timezone offset in the ISO timestamp.
- When the user asks "what's on my calendar" or "meetings today", use `+agenda --today`.
- When the user gives a natural-language event description, prefer `quickAdd` for simple cases and `+insert` for structured cases.
