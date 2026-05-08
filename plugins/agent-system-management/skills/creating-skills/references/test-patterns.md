# Test patterns for skills in any plugin marketplace

Adapts to the host repo's test layout via the convention probes in `SKILL.md`. Paths in this file use handlebars (`{{test_unit_dir}}`, `{{plugin_dir}}`, etc.) that are resolved at runtime from probe results.

## Overview

Three categories of tests for skills. Unit tests are bash scripts that run filesystem and `jq` checks against plugin manifests and SKILL.md files. They are fast, deterministic, and require no network or auth, so write one for every new skill. Skill-triggering tests run a real Claude subprocess against a single natural-language prompt and verify the expected skill name appears in the model's tool-use trace, so write at least one per skill (more if the skill has distinct entry points). Integration tests exercise a live API or CLI end-to-end (create, read, update, delete) and are opt-in: write one only when the skill wraps an external service.

If the host repo has no test layout at all (`{{test_unit_dir}}` and `{{test_triggering_dir}}` were absent in Probe 4), see the **Bootstrap** section at the end for minimal scaffolds you can drop in.

## Unit tests (filesystem checks)

Unit tests verify static structure, not Claude behavior. They live at `{{test_unit_dir}}/test-<service>-skill.sh` and use `bash` plus `jq` plus `grep`. Always write a unit test for a new skill: it catches typos, broken references, missing manifests, and en-dash slips before any subprocess runs.

Standard structure (pattern after whichever existing skill test the probe found in `{{test_unit_dir}}`):

```bash
#!/usr/bin/env bash
# Test: <skill-name> skill structure
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PLUGIN_ROOT="$REPO_ROOT/{{plugin_dir}}/<plugin-name>"
SKILL_DIR="$PLUGIN_ROOT/skills/<skill-name>"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "=== Test: <skill-name> skill structure ==="
echo ""

# Test 1: Manifests exist and parse
echo "Test 1: Plugin manifests parse..."
for m in "$PLUGIN_ROOT/.claude-plugin/plugin.json" "$PLUGIN_ROOT/.codex-plugin/plugin.json"; do
    if [ -f "$m" ] && jq empty "$m" 2>/dev/null; then
        echo "  [PASS] $m parses"
    elif [ ! -f "$m" ]; then
        echo "  [SKIP] $m not present in this marketplace"
    else
        echo "  [FAIL] $m malformed"
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

Output convention: `[PASS]` or `[FAIL]` with two-space indent, `exit 1` on the first failure, and a final `=== Tests complete ===` line. Run with `PLUGIN_DIR={{plugin_dir}}/<plugin> bash {{test_unit_dir}}/test-<service>-skill.sh`.

## Skill-triggering tests (one prompt per file)

Each prompt lives at `{{test_triggering_dir}}/prompts/<skill>-<action>.txt` and contains a single realistic user message of one or two sentences. Action-led, with a concrete object (file path, project key, name) when realistic. The runner at `{{test_triggering_dir}}/run-test.sh` greps the stream-json log for `"skill":"...:<expected-skill>"`; pass means the skill triggered.

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
PLUGIN_DIR={{plugin_dir}}/<plugin> bash {{test_triggering_dir}}/run-test.sh <skill> {{test_triggering_dir}}/prompts/<file>.txt
```

If a skill has multiple entry paths (for example a slash-command form and a natural-language form), write one prompt file per path. Add no-trigger negative prompts (e.g. `autopilot-no-trigger-spec-only.txt`) when you need to verify the skill stays quiet on adjacent intent.

## Integration tests (opt-in)

Write an integration test only when the skill wraps a live API or CLI. Skills that only manipulate local files do not need one. Tests live at `{{test_integration_dir}}/test-<service>-integration.sh`. Use the auth helpers from the host repo's shared test helpers (often `{{test_unit_dir}}/../test-helpers.sh`, with functions like `check_acli_auth`, `check_env_auth`, `check_any_auth`, `check_gws_auth`) and skip gracefully when auth is missing. Use `run_claude_logged` with a log file plus `show_tools_used` for diagnostics. Always clean up created resources, including on failure (use `trap`). Pattern after whichever existing integration test the host repo already has.

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

## Frontmatter lint (always run if a linter exists)

If Probe 5 found a frontmatter linter at `{{frontmatter_linter_path}}`, every change to a SKILL.md must run:

```bash
bash {{frontmatter_linter_path}}
```

If it fails, surface the failure verbatim. Common failures:

- Missing required field (`name`, `description`).
- `name` contains characters other than letters, numbers, or hyphens.
- YAML frontmatter not at file start (line 1 is not `---`).
- Unbalanced `---` delimiters (missing closing fence).

If Probe 5 returned absent, drop the minimal scaffold from the Bootstrap section below into `{{test_unit_dir}}/test-skill-frontmatter-yaml.sh`.

## How tests integrate with autopilot

If the host repo uses `workbench:autopilot`, the autopilot profile (per that skill's docs) declares which lints run during PR review. Frontmatter lint and unit tests run there because they are fast and offline. Integration tests are opt-in: run them locally when you have credentials, or in CI under a guarded job. Skill-triggering tests use a real Claude subprocess and are slow (one prompt costs tens of seconds), so they typically run only at PR review time, not on every commit.

## Bootstrap: minimal infrastructure

Use these scaffolds when the convention probes returned no existing infrastructure for the host repo.

### Frontmatter validator scaffold

Save as `{{test_unit_dir}}/test-skill-frontmatter-yaml.sh` (create the directory if absent) and `chmod +x`:

```bash
#!/usr/bin/env bash
# Minimal frontmatter linter.
# Verifies every SKILL.md has valid YAML frontmatter with name and description.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
fail=0

while IFS= read -r f; do
  if ! head -1 "$f" | grep -q '^---$'; then
    echo "[FAIL] $f: missing frontmatter delimiter on line 1"
    fail=1
    continue
  fi
  if ! grep -q '^name: ' "$f"; then
    echo "[FAIL] $f: missing 'name:' field"
    fail=1
  fi
  if ! grep -q '^description: ' "$f"; then
    echo "[FAIL] $f: missing 'description:' field"
    fail=1
  fi
  name=$(grep '^name: ' "$f" | head -1 | sed 's/^name: //')
  if ! echo "$name" | grep -qE '^[a-z0-9-]+$'; then
    echo "[FAIL] $f: name '$name' is not kebab-case"
    fail=1
  fi
done < <(find "$REPO_ROOT/{{plugin_dir}}" -name 'SKILL.md' 2>/dev/null)

[ "$fail" -eq 0 ] && echo "[PASS] frontmatter lint"
exit "$fail"
```

### Skill-triggering runner scaffold

Save as `{{test_triggering_dir}}/run-test.sh` and `chmod +x`. Requires `claude --output-format stream-json` available on PATH. Greps the trace for `"skill":"...:<expected-skill>"`.

```bash
#!/usr/bin/env bash
# Skill triggering test, verifies Claude auto-triggers the expected skill
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
export PLUGIN_DIR="${PLUGIN_DIR:-$REPO_DIR/{{plugin_dir}}/<default-plugin>}"
cd "$REPO_DIR"

NEGATIVE=false
if [ "${1:-}" = "--not" ]; then
    NEGATIVE=true
    shift
fi

EXPECTED_SKILL="$1"
PROMPT_FILE="$2"
PROMPT="$(cat "$PROMPT_FILE")"
LOG_FILE=$(mktemp)

trap "rm -f $LOG_FILE" EXIT

local_plugin_flag=""
if [ -n "$PLUGIN_DIR" ]; then
    local_plugin_flag="--plugin-dir $PLUGIN_DIR"
fi

if command -v gtimeout &>/dev/null; then _to=gtimeout; elif command -v timeout &>/dev/null; then _to=timeout; else _to=""; fi

if [ -n "$_to" ]; then
    "$_to" 60 bash -c "claude -p \"$PROMPT\" $local_plugin_flag --verbose --output-format stream-json" > "$LOG_FILE" 2>&1 || true
else
    bash -c "claude -p \"$PROMPT\" $local_plugin_flag --verbose --output-format stream-json" > "$LOG_FILE" 2>&1 || true
fi

SKILL_PATTERN="\"skill\":\"([^\"]*:)?${EXPECTED_SKILL}\""
if grep -qE "$SKILL_PATTERN" "$LOG_FILE"; then
    if $NEGATIVE; then
        echo "  [FAIL] Skill '$EXPECTED_SKILL' was triggered"
        head -c 500 "$LOG_FILE" | sed 's/^/    /'
        exit 1
    fi
    echo "  [PASS] Skill '$EXPECTED_SKILL' was triggered"
else
    if $NEGATIVE; then
        echo "  [PASS] Skill '$EXPECTED_SKILL' was not triggered"
    else
        echo "  [FAIL] Skill '$EXPECTED_SKILL' was NOT triggered"
        head -c 500 "$LOG_FILE" | sed 's/^/    /'
        exit 1
    fi
fi
```
