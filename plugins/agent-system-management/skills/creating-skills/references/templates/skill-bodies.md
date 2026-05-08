# SKILL.md body templates

Three templates for the SKILL.md body, one per skill type. Pick the one matching the user's classification in Mode A step 4.

## API/CLI wrapper (Tier 1/2/3)

````markdown
---
name: <service>
description: Use when the user wants to <one-line trigger description>.
---

# <Service> Skill

<One-line summary of what this skill does.>

---

## Auth Approach

Do NOT check authentication upfront. Just run the command. If it fails with an auth error, see Self-Healing.

NEVER print, echo, or log credential values. Only check whether they are set (`test -n "$<VAR>"`), never display contents.

## Tool Preference

Prefer `<primary-tool>` for all operations. Fall back to `<secondary-tool>` only when `<reason>`.

Pattern for all `<primary-tool>` requests:

```bash
<primary-tool> <subcommand> --json
```

## Operations: Tier 1 (Read)

### <Read operation name>

```bash
acli <product> <noun> view --key <KEY> --json
```

```bash
curl -s -u "$<USER>:$<TOKEN>" \
  -H "Accept: application/json" \
  "https://<host>/api/v1/<resource>/<id>"
```

## Operations: Tier 2 (Write)

### <Write operation name>

```bash
acli <product> <noun> create --project <KEY> --summary "<text>"
```

```bash
curl -s -u "$<USER>:$<TOKEN>" \
  -H "Content-Type: application/json" \
  -X POST "https://<host>/api/v1/<resource>" \
  -d '{"<field>": "<value>"}'
```

## Operations: Tier 3 (Manage)

Confirm with the user before running any Tier 3 command.

### <Destructive operation name>

```bash
acli <product> <noun> delete --key <KEY> --yes
```

```bash
curl -s -u "$<USER>:$<TOKEN>" \
  -X DELETE "https://<host>/api/v1/<resource>/<id>"
```

## Self-Healing

When a command fails:

1. Inspect the error code and message. `<tool> --help` and `<tool> <subcommand> --help` reveal flag names.
2. Auth errors (`401`, `403`): check that `$<USER>` and `$<TOKEN>` are set (`test -n`), never print them. Direct the user to refresh credentials.
3. Schema errors (`400`): re-read the request body shape from the API reference, then retry.
4. Rate limits (`429`): back off, then retry.

## Behavioral Guidelines

- Infer the user's intent from the verb (search, create, update, delete) and pick the matching operation.
- Default to read operations unless the user clearly asked to write.
- Always confirm before Tier 3.
- Keep responses short. Show the resulting object or a summary, not the raw response envelope.
````

## Workflow

````markdown
---
name: <workflow-name>
description: Use when the user wants to <trigger phrase>.
---

# <Workflow Name>

<One-line summary of what the workflow accomplishes.>

## Overview

<Two or three sentences. What gets produced, what state the repo ends in, what the user has to do at the end.>

## Steps

### Step 0: <prepare>

- <Imperative bullet, one line.>
- <Another imperative bullet.>

### Step 1: <gather inputs>

- <Imperative bullet.>

### Step 2: <do the thing>

- <Imperative bullet.>

### Step 3: <verify>

- <Imperative bullet.>

## Subagent dispatch (optional)

If a step would consume a lot of context, dispatch it to a subagent. Pass the inputs as a structured prompt and require the subagent to return a single artifact path.

## Verify

- <How to confirm the workflow ran. Exact command to check state.>
- <Second check.>

## Report

End with a one-paragraph summary: what changed, files touched, follow-ups.
````

## Reference

````markdown
---
name: <topic>
description: Use when the user wants reference material on <topic>.
---

# <Topic> Reference

<One-line summary.>

## Overview

<What this reference covers and what it does NOT cover.>

## Schema

<Type definitions, field tables, or example structures.>

## Recipes

### <Recipe name>

<Short description, then a copy-pasteable command or snippet.>

## Source-of-truth pointers

- <Canonical doc URL or file path.>
- <Second canonical source.>
````
