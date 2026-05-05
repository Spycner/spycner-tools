# Test patterns for skills in pgoell-claude-tools

## Overview

Three categories of tests live in this repo. Unit tests are bash scripts that run filesystem and `jq` checks against plugin manifests and SKILL.md files. They are fast, deterministic, and require no network or auth, so write one for every new skill. Skill-triggering tests run a real Claude subprocess against a single natural-language prompt and verify the expected skill name appears in the model's tool-use trace, so write at least one per skill (more if the skill has distinct entry points). Integration tests exercise a live API or CLI end-to-end (create, read, update, delete) and are opt-in: write one only when the skill wraps an external service.

## Unit tests (filesystem checks)

Unit tests verify static structure, not Claude behavior. They live at `tests/unit/test-<service>-skill.sh` and use `bash` plus `jq` plus `grep`. Always write a unit test for a new skill: it catches typos, broken references, missing manifests, and en-dash slips before any subprocess runs.

Standard structure, modeled on `tests/unit/test-workbench-autopilot-skill.sh`:

```bash
#!/usr/bin/env bash
# Test: <skill-name> skill structure
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PLUGIN_ROOT="$REPO_ROOT/plugins/<plugin-name>"
SKILL_DIR="$PLUGIN_ROOT/skills/<skill-name>"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: <skill-name> skill structure ==="
echo ""

# Test 1: Manifests exist and parse
echo "Test 1: Plugin manifests parse..."
for m in "$PLUGIN_ROOT/.claude-plugin/plugin.json" "$PLUGIN_ROOT/.codex-plugin/plugin.json"; do
    if [ -f "$m" ] && jq empty "$m" 2>/dev/null; then
        echo "  [PASS] $m parses"
    else
        echo "  [FAIL] $m missing or malformed"
        exit 1
    fi
done
echo ""

# Test 2: SKILL.md exists with frontmatter delimiter
echo "Test 2: SKILL.md exists with frontmatter..."
if [ -s "$SKILL_MD" ] && head -1 "$SKILL_MD" | grep -q '^---$'; then
    echo "  [PASS] SKILL.md exists with frontmatter"
else
    echo "  [FAIL] SKILL.md missing or has no frontmatter"
    exit 1
fi
echo ""

# Test 3: Frontmatter has required name and description fields
echo "Test 3: Frontmatter has name and description..."
for field in 'name:' 'description:'; do
    if grep -qE "^${field}" "$SKILL_MD"; then
        echo "  [PASS] frontmatter has $field"
    else
        echo "  [FAIL] frontmatter missing $field"
        exit 1
    fi
done
echo ""

# Test 4: Reference files exist and SKILL.md mentions each
echo "Test 4: Reference files..."
for ref in <ref-1> <ref-2>; do
    f="$SKILL_DIR/references/$ref.md"
    if [ -s "$f" ] && grep -qF "$ref" "$SKILL_MD"; then
        echo "  [PASS] references/$ref.md exists and is referenced"
    else
        echo "  [FAIL] references/$ref.md missing, empty, or not referenced"
        exit 1
    fi
done
echo ""

# Test 5: No em-dashes or en-dashes in SKILL.md
echo "Test 5: No em-dashes or en-dashes..."
if grep -nP '[\x{2014}\x{2013}]' "$SKILL_MD"; then
    echo "  [FAIL] SKILL.md contains em-dash or en-dash"
    exit 1
else
    echo "  [PASS] no em-dashes or en-dashes"
fi
echo ""

echo "=== Tests complete ==="
```

When the skill wraps an API or CLI, also assert tier sections are present:

```bash
for tier in '## Operations: Tier 1' '## Operations: Tier 2' '## Operations: Tier 3'; do
    grep -qF "$tier" "$SKILL_MD" || { echo "  [FAIL] $tier missing"; exit 1; }
done
```

When the skill is workflow-shaped (numbered steps), assert all step headings:

```bash
for n in 0 1 2 3 4 5; do
    grep -qE "^### Step $n[: ]" "$SKILL_MD" || { echo "  [FAIL] Step $n missing"; exit 1; }
done
```

Output convention: `[PASS]` or `[FAIL]` with two-space indent, `exit 1` on the first failure, and a final `=== Tests complete ===` line. Run with `PLUGIN_DIR=plugins/<plugin> bash tests/unit/test-<service>-skill.sh`.

## Skill-triggering tests (one prompt per file)

Each prompt lives at `tests/skill-triggering/prompts/<skill>-<action>.txt` and contains a single realistic user message of one or two sentences. Action-led, with a concrete object (file path, project key, name) when realistic. The runner at `tests/skill-triggering/run-test.sh` greps the stream-json log for `"skill":"...:<expected-skill>"`; pass means the skill triggered.

Good examples:

```
Create a new bug ticket in the TEST project about a login page error
```

```
Audit the AGENTS.md files in this repo and tell me what's missing
```

Bad example (too vague, no action verb, no object):

```
help with jira
```

Run command:

```bash
PLUGIN_DIR=plugins/<plugin> bash tests/skill-triggering/run-test.sh <skill> tests/skill-triggering/prompts/<file>.txt
```

If a skill has multiple entry paths (for example a slash-command form and a natural-language form), write one prompt file per path. Add no-trigger negative prompts (e.g. `autopilot-no-trigger-spec-only.txt`) when you need to verify the skill stays quiet on adjacent intent.

## Integration tests (opt-in)

Write an integration test only when the skill wraps a live API or CLI. Skills that only manipulate local files do not need one. Tests live at `tests/integration/test-<service>-integration.sh`. Use the auth helpers in `tests/test-helpers.sh` (`check_acli_auth`, `check_env_auth`, `check_any_auth`, `check_gws_auth`) and skip gracefully when auth is missing. Use `run_claude_logged` with a log file plus `show_tools_used` for diagnostics. Always clean up created resources, including on failure (use `trap`). See `tests/integration/test-jira-integration.sh` as the canonical model.

Outline:

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

LOG_DIR=$(mktemp -d)
CREATED_KEY=""
cleanup() {
    [ -n "$CREATED_KEY" ] && run_claude_logged "Delete $CREATED_KEY." "$LOG_DIR/cleanup.json" 60 || true
    rm -rf "$LOG_DIR"
}
trap cleanup EXIT

check_<tool>_auth || { echo "  [SKIP] No auth configured"; exit 0; }

# Create
output=$(run_claude_logged "Create a test resource ..." "$LOG_DIR/create.json" 180)
CREATED_KEY=$(echo "$output" | grep -oE '<id-pattern>' | head -1 || true)
assert_contains "$output" "<id-pattern>" "Returns an id"
show_tools_used "$LOG_DIR/create.json"

# Read
output=$(run_claude_logged "Show me $CREATED_KEY." "$LOG_DIR/read.json" 120)
assert_contains "$output" "$CREATED_KEY" "Read returns the resource"

# Update
output=$(run_claude_logged "Update $CREATED_KEY: ..." "$LOG_DIR/update.json" 120)
assert_not_contains "$output" "401|403|unauthorized" "Update without auth errors"

# Delete handled by the trap.
echo "=== Integration tests complete ==="
```

## Frontmatter lint (always run)

Every change to a SKILL.md must run:

```bash
bash tests/unit/test-skill-frontmatter-yaml.sh
```

If it fails, surface the failure verbatim. Common failures:

- Missing required field (`name`, `description`).
- `name` contains characters other than letters, numbers, or hyphens.
- YAML frontmatter not at file start (line 1 is not `---`).
- Unbalanced `---` delimiters (missing closing fence).

## How tests integrate with autopilot

The workbench autopilot profile at `.workbench/autopilot.md` declares which lints run locally during step 7 (PR review). Frontmatter lint and unit tests run there because they are fast and offline. Integration tests are opt-in: run them locally when you have credentials, or in CI under a guarded job. Skill-triggering tests use a real Claude subprocess and are slow (one prompt costs tens of seconds), so they typically run only at PR review time, not on every commit.
