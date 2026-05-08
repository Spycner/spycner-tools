# Bootstrap scaffolds: minimal test infrastructure

Use these when the convention probes returned no existing infrastructure for the host repo (no frontmatter linter, no skill-triggering runner). Drop them in as a starting point; the host repo's contributors can iterate on them later.

## Frontmatter validator scaffold

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

## Skill-triggering runner scaffold

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
