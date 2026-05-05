# Skill scaffolding templates

Boilerplate for new skills in the pgoell-claude-tools repo. Copy a section to the target location, then fill in `<placeholder>` values.

## SKILL.md template: API/CLI wrapper (Tier 1/2/3)

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

## SKILL.md template: workflow

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

## SKILL.md template: reference

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

## .claude-plugin/plugin.json template

```json
{
  "name": "<plugin-name>",
  "version": "0.1.0",
  "description": "<one-line description>",
  "author": { "name": "Pascal Göllner" },
  "license": "MIT",
  "keywords": ["<keyword-1>", "<keyword-2>", "<keyword-3>"]
}
```

## .codex-plugin/plugin.json template

```json
{
  "name": "<plugin-name>",
  "version": "0.1.0",
  "description": "<one-line description>",
  "author": { "name": "Pascal Göllner" },
  "license": "MIT",
  "keywords": ["<keyword-1>", "<keyword-2>", "<keyword-3>"],
  "skills": "./skills/",
  "interface": {
    "displayName": "<Plugin Display Name>",
    "shortDescription": "<short human-facing description>",
    "longDescription": "<longer human-facing description, two or three sentences>",
    "developerName": "Pascal Göllner",
    "category": "Productivity",
    "capabilities": ["Interactive", "Read", "Write"],
    "defaultPrompt": [
      "<starter prompt 1>",
      "<starter prompt 2>"
    ],
    "screenshots": []
  }
}
```

## Claude Code marketplace entry template

Insert into the `plugins` array of `.claude-plugin/marketplace.json`:

```json
{
  "name": "<plugin-name>",
  "source": "./plugins/<plugin-name>",
  "description": "<one-line description>",
  "version": "0.1.0"
}
```

## Codex marketplace entry template

Insert into the `plugins` array of `.agents/plugins/marketplace.json`:

```json
{
  "name": "<plugin-name>",
  "source": {
    "source": "local",
    "path": "./plugins/<plugin-name>"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Productivity",
  "interface": {
    "displayName": "<Plugin Display Name>",
    "shortDescription": "<short human-facing description>"
  }
}
```

## README.md plugin row template

Insert into the Skills table in `README.md`. One row per skill in the new plugin:

```markdown
| `<skill-name>` | <plugin-name> | <what the skill does, one short clause> |
```

If the plugin needs its own section under Plugins, follow this shape:

```markdown
### <plugin-name>

<One-line description of the plugin.>

**Skills:**
- `/pgoell-claude-tools:<skill-name>`: <what the skill does>
```

## CLAUDE.md "Current Plugins" row template

Insert into the Current Plugins table in `CLAUDE.md`:

```markdown
| `<plugin-name>` | 0.1.0 | `<skill-1>`, `<skill-2>` |
```

## Unit test scaffold template

Save as `tests/unit/test-<plugin>-<skill>-skill.sh` and `chmod +x`.

```bash
#!/usr/bin/env bash
# Test: <plugin>:<skill> skill structure
# Verifies SKILL.md exists with frontmatter, references resolve,
# and plugin manifests have matching versions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/<plugin>/skills/<skill>"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: <plugin>:<skill> skill structure ==="
echo ""

# Test 1: SKILL.md exists with frontmatter
echo "Test 1: SKILL.md exists with frontmatter..."
if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "  [PASS] SKILL.md exists with frontmatter"
else
    echo "  [FAIL] SKILL.md missing or no frontmatter"
    exit 1
fi
echo ""

# Test 2: Reference files exist
echo "Test 2: Reference files exist..."
for ref in <ref-1> <ref-2>; do
    f="$SKILL_DIR/references/$ref.md"
    if [ -s "$f" ]; then
        echo "  [PASS] references/$ref.md exists"
    else
        echo "  [FAIL] references/$ref.md missing or empty"
        exit 1
    fi
done
echo ""

# Test 3: SKILL.md mentions every reference
echo "Test 3: SKILL.md references all reference files..."
for ref in <ref-1> <ref-2>; do
    if grep -qF "$ref" "$SKILL_MD"; then
        echo "  [PASS] SKILL.md mentions $ref"
    else
        echo "  [FAIL] SKILL.md missing reference to $ref"
        exit 1
    fi
done
echo ""

# Test 4: Description trigger phrases
echo "Test 4: Description trigger phrases..."
desc=$(awk '/^description:/{flag=1;sub(/^description:[ ]*/,"")} /^---$/{flag=0} flag' "$SKILL_MD")
if echo "$desc" | grep -qiE '<trigger-keyword>'; then
    echo "  [PASS] description mentions trigger keyword"
else
    echo "  [FAIL] description missing trigger keyword"
    exit 1
fi
echo ""

# Test 5: Plugin manifests valid JSON and at expected version
echo "Test 5: Plugin manifests valid and at <expected-version>..."
CCM="$REPO_ROOT/plugins/<plugin>/.claude-plugin/plugin.json"
CXM="$REPO_ROOT/plugins/<plugin>/.codex-plugin/plugin.json"
if jq empty "$CCM" >/dev/null 2>&1 && jq empty "$CXM" >/dev/null 2>&1; then
    echo "  [PASS] both manifests are valid JSON"
else
    echo "  [FAIL] one or both manifests are invalid JSON"
    exit 1
fi
if jq -e '.version == "<expected-version>"' "$CCM" >/dev/null && jq -e '.version == "<expected-version>"' "$CXM" >/dev/null; then
    echo "  [PASS] both manifests at <expected-version>"
else
    echo "  [FAIL] manifests not at <expected-version>"
    exit 1
fi
echo ""

# Test 6: Marketplace entries present
echo "Test 6: Marketplace entries present..."
MP_CC="$REPO_ROOT/.claude-plugin/marketplace.json"
MP_CX="$REPO_ROOT/.agents/plugins/marketplace.json"
if jq -e '.plugins[] | select(.name == "<plugin>")' "$MP_CC" >/dev/null; then
    echo "  [PASS] Claude marketplace lists <plugin>"
else
    echo "  [FAIL] Claude marketplace missing <plugin>"
    exit 1
fi
if jq -e '.plugins[] | select(.name == "<plugin>")' "$MP_CX" >/dev/null; then
    echo "  [PASS] Codex marketplace lists <plugin>"
else
    echo "  [FAIL] Codex marketplace missing <plugin>"
    exit 1
fi
echo ""

echo "=== Tests complete ==="
```

## Skill-triggering prompt template

Save as `tests/skill-triggering/prompts/<skill>-<action>.txt`. One-line, action-led, realistic.

Good (concrete verb, names the artifact):

```
Search Jira for tickets assigned to me that are still open.
```

Bad (vague, no domain anchor; will not trigger reliably):

```
Find some stuff for me please.
```

Run with:

```bash
PLUGIN_DIR=plugins/<plugin> bash tests/skill-triggering/run-test.sh <skill> tests/skill-triggering/prompts/<skill>-<action>.txt
```

## Integration test scaffold template

Save as `tests/integration/test-<plugin>-<skill>-integration.sh` and `chmod +x`. Skip cleanly when auth is missing.

```bash
#!/usr/bin/env bash
# Integration test: <plugin>:<skill> live CRUD lifecycle
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Integration: <plugin>:<skill> ==="
echo ""

# Auth gate: skip cleanly if not configured
if ! check_<tool>_auth; then
    echo "  [SKIP] <tool> auth not configured. Set <ENV_VARS> or run <tool> login."
    exit 0
fi

LOG=$(mktemp)
TEST_ID="autotest-$(date +%s)"
trap 'rm -f "$LOG"' EXIT

# Lifecycle: create, read, update, delete

# 1. Create
echo "Step 1: create..."
out=$(run_claude_logged "Create a <resource> named $TEST_ID for testing." "$LOG" 120)
show_tools_used "$LOG"
assert_contains "$out" "$TEST_ID" "create returned the new id" || exit 1

# 2. Read
echo "Step 2: read..."
out=$(run_claude_logged "Show me the <resource> $TEST_ID." "$LOG" 60)
assert_contains "$out" "$TEST_ID" "read returned the test resource" || exit 1

# 3. Update
echo "Step 3: update..."
out=$(run_claude_logged "Update <resource> $TEST_ID, set <field> to updated." "$LOG" 60)
assert_contains "$out" "updated" "update reflected the change" || exit 1

# 4. Delete (cleanup)
echo "Step 4: delete..."
out=$(run_claude_logged "Delete <resource> $TEST_ID." "$LOG" 60)
assert_contains "$out" "(deleted|removed|gone)" "delete confirmed" || {
    echo "  [WARN] delete unconfirmed. Manual cleanup may be needed for $TEST_ID."
    exit 1
}

echo ""
echo "=== Integration complete ==="
```
