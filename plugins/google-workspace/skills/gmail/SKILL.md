---
name: gmail
description: Search, read, send, and manage Gmail messages, drafts, labels, and filters with gws.
---

# Gmail Skill

Search, read, send, and manage Gmail messages, drafts, labels, and filters using the `gws` CLI.

---

## Auth Approach

Do NOT check authentication upfront. Just run the command. If it fails with an auth error (exit code 2), see the **Self-Healing** section for diagnostics.

---

## Tool Preference

All operations use the `gws` CLI directly. No wrapper scripts.

- **Helper commands** (prefixed with `+`): Use for common operations. These handle formatting, threading, and MIME encoding automatically.
- **Raw API calls**: Use when no helper exists. Pass parameters via `--params '<JSON>'` and request bodies via `--json '<JSON>'`. Resource paths are space-separated (e.g., `gws gmail users messages list`).

Always prefer `+` helpers when one exists for the operation.

---

## Operations — Tier 1 (Read)

### Triage Inbox

Show unread inbox summary:
```bash
gws gmail +triage
```

Filtered/customized:
```bash
gws gmail +triage --query 'from:boss' --max 5
gws gmail +triage --labels
gws gmail +triage --format table
```

### Read a Message

```bash
gws gmail +read --id <messageId>
gws gmail +read --id <messageId> --headers
gws gmail +read --id <messageId> --format json
```

### Search / List Messages

```bash
gws gmail users messages list --params '{"userId": "me", "q": "<query>"}'
```

See `gmail-search-recipes.md` for query syntax.

### List Labels

```bash
gws gmail users labels list --params '{"userId": "me"}'
```

---

## Operations — Tier 2 (Write)

### Send Email

```bash
gws gmail +send --to <addr> --subject '<subj>' --body '<body>'
gws gmail +send --to <addr> --subject '<subj>' --body '<body>' --cc <addr> --bcc <addr>
gws gmail +send --to <addr> --subject '<subj>' --body '<body>' -a <filepath>
gws gmail +send --to <addr> --subject '<subj>' --body '<html>' --html
```

### Reply

```bash
gws gmail +reply --message-id <id> --body '<body>'
```

### Reply All

```bash
gws gmail +reply-all --message-id <id> --body '<body>'
gws gmail +reply-all --message-id <id> --body '<body>' --remove <addr>
```

### Forward

```bash
gws gmail +forward --message-id <id> --to <addr>
gws gmail +forward --message-id <id> --to <addr> --body 'FYI see below'
```

### Create Draft

```bash
gws gmail users drafts create --params '{"userId": "me"}' --json '<draft-json>'
```

---

## Operations — Tier 3 (Manage)

### Trash / Delete Message

```bash
gws gmail users messages trash --params '{"userId": "me", "id": "<id>"}'
gws gmail users messages delete --params '{"userId": "me", "id": "<id>"}'
```

Trash is reversible. Delete is permanent — confirm with the user first.

### Modify Labels on a Message

```bash
gws gmail users messages modify --params '{"userId": "me", "id": "<id>"}' --json '{"addLabelIds": ["STARRED"], "removeLabelIds": ["UNREAD"]}'
```

### Create / Delete Label

```bash
gws gmail users labels create --params '{"userId": "me"}' --json '{"name": "<label-name>"}'
gws gmail users labels delete --params '{"userId": "me", "id": "<labelId>"}'
```

### Filters

```bash
gws gmail users settings filters list --params '{"userId": "me"}'
gws gmail users settings filters create --params '{"userId": "me"}' --json '<filter-json>'
gws gmail users settings filters delete --params '{"userId": "me", "id": "<filterId>"}'
```

---

## Common Gmail Search Recipes

See `gmail-search-recipes.md`

---

## Self-Healing

When a command fails:

### Auth Errors (exit code 2)

Check if gws is available and authenticated:

```bash
which gws && gws auth status
```

If gws is not installed or not authenticated, tell the user:
> "The gws CLI is not installed or not authenticated. Install and configure it: https://github.com/googleworkspace/cli"

### Other Errors

- Check the command's help: `gws gmail <command> --help`
- Inspect the API schema: `gws schema gmail.<resource>.<method>`
- Use `--dry-run` to preview requests without executing
- Exit codes: 0=success, 1=API error, 2=auth error, 3=validation, 4=discovery, 5=internal
- Validation errors (exit 3): check `--params` JSON syntax and required fields

---

## Behavioral Guidelines

- Prefer `+` helper commands over raw API calls when a helper exists.
- JSON is the default output format for all commands including helpers. Use `--format table` for human-readable output when needed.
- Use `--dry-run` to preview destructive operations before executing.
- Confirm with the user before destructive operations (delete). Trash is reversible, delete is not.
- Default `userId` to `me` in `--params` unless the user specifies otherwise.
- When the user asks to "check email" or "what's new", use `+triage`.
- When the user provides a search query, construct the Gmail search string and use `users messages list`.
