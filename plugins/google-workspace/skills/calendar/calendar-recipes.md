# Calendar Recipes

Common patterns for Google Calendar operations via the `gws` CLI.

---

## Agenda Shortcuts

```bash
# Today's events
gws calendar +agenda --today

# Tomorrow
gws calendar +agenda --tomorrow

# This week
gws calendar +agenda --week

# Next 3 days
gws calendar +agenda --days 3

# Specific calendar only
gws calendar +agenda --calendar 'Work'

# With timezone override
gws calendar +agenda --today --timezone America/New_York
```

## Listing Events with Date Ranges

Use ISO 8601 / RFC 3339 timestamps:

```bash
# Events today (construct timeMin/timeMax for the day)
gws calendar events list --params '{"calendarId": "primary", "timeMin": "2026-03-18T00:00:00Z", "timeMax": "2026-03-18T23:59:59Z"}'

# Events this week
gws calendar events list --params '{"calendarId": "primary", "timeMin": "2026-03-16T00:00:00Z", "timeMax": "2026-03-22T23:59:59Z"}'

# Single events only (expand recurring)
gws calendar events list --params '{"calendarId": "primary", "timeMin": "2026-03-18T00:00:00Z", "timeMax": "2026-03-18T23:59:59Z", "singleEvents": true, "orderBy": "startTime"}'
```

## Finding Free Slots

```bash
# Check availability for a single calendar
gws calendar freebusy query --json '{"timeMin": "2026-03-18T09:00:00Z", "timeMax": "2026-03-18T17:00:00Z", "items": [{"id": "primary"}]}'

# Check multiple calendars
gws calendar freebusy query --json '{"timeMin": "2026-03-18T09:00:00Z", "timeMax": "2026-03-18T17:00:00Z", "items": [{"id": "primary"}, {"id": "colleague@example.com"}]}'
```

## Creating Events

```bash
# Basic event
gws calendar +insert --summary 'Team Standup' --start '2026-03-19T09:00:00-04:00' --end '2026-03-19T09:30:00-04:00'

# With attendees and Meet link
gws calendar +insert --summary 'Sprint Review' --start '2026-03-20T14:00:00-04:00' --end '2026-03-20T15:00:00-04:00' --attendee alice@example.com --attendee bob@example.com --meet

# With location and description
gws calendar +insert --summary 'Lunch' --start '2026-03-19T12:00:00-04:00' --end '2026-03-19T13:00:00-04:00' --location 'Conference Room A' --description 'Weekly team lunch'

# Quick-add from natural language
gws calendar events quickAdd --params '{"calendarId": "primary", "text": "Lunch with Alice tomorrow at noon"}'
```

## Recurring Events

Create via raw API with `recurrence` field:

```bash
gws calendar events insert --params '{"calendarId": "primary"}' --json '{
  "summary": "Daily Standup",
  "start": {"dateTime": "2026-03-18T09:00:00-04:00", "timeZone": "America/New_York"},
  "end": {"dateTime": "2026-03-18T09:15:00-04:00", "timeZone": "America/New_York"},
  "recurrence": ["RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"]
}'
```

Common RRULE patterns:
- `RRULE:FREQ=DAILY` — every day
- `RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR` — Mon/Wed/Fri
- `RRULE:FREQ=MONTHLY;BYMONTHDAY=1` — first of every month
- `RRULE:FREQ=WEEKLY;COUNT=10` — weekly for 10 occurrences
- `RRULE:FREQ=WEEKLY;UNTIL=20261231T000000Z` — weekly until end of year

## All-Day Events

Use `date` instead of `dateTime`:

```bash
gws calendar events insert --params '{"calendarId": "primary"}' --json '{
  "summary": "Company Holiday",
  "start": {"date": "2026-03-20"},
  "end": {"date": "2026-03-21"}
}'
```

Note: end date is exclusive (March 21 means the event covers only March 20).

## Updating Events

```bash
# Change title
gws calendar events patch --params '{"calendarId": "primary", "eventId": "<id>"}' --json '{"summary": "New Title"}'

# Add attendee
gws calendar events patch --params '{"calendarId": "primary", "eventId": "<id>"}' --json '{"attendees": [{"email": "new@example.com"}]}'

# Change time
gws calendar events patch --params '{"calendarId": "primary", "eventId": "<id>"}' --json '{"start": {"dateTime": "2026-03-19T10:00:00-04:00"}, "end": {"dateTime": "2026-03-19T11:00:00-04:00"}}'
```

## Setting Reminders

```bash
# Custom reminders (override calendar defaults)
gws calendar events patch --params '{"calendarId": "primary", "eventId": "<id>"}' --json '{"reminders": {"useDefault": false, "overrides": [{"method": "popup", "minutes": 10}, {"method": "email", "minutes": 30}]}}'

# Use calendar default reminders
gws calendar events patch --params '{"calendarId": "primary", "eventId": "<id>"}' --json '{"reminders": {"useDefault": true}}'
```

Reminder methods: `popup` (notification) or `email`. Minutes must be 0-40320 (up to 4 weeks).

## Timezone Handling

- `+agenda` auto-detects your Google account timezone; override with `--timezone <IANA>`
- Always include timezone offset in ISO timestamps: `2026-03-18T14:00:00-04:00`
- Set `timeZone` field in event JSON for recurring events: `"timeZone": "America/New_York"`
- Use `Z` suffix for UTC: `2026-03-18T18:00:00Z`
