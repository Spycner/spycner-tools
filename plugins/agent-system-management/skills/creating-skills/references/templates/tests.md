# Test scaffolds

Three scaffolds, one per test category. See `../test-patterns.md` for which categories apply when.

## Unit test scaffold

Save as `{{test_unit_dir}}/test-<plugin>-<skill>-skill.sh` and `chmod +x`. (If `{{test_unit_dir}}` is absent, see the Bootstrap section in `../test-patterns.md`.)

```bash
#!/usr/bin/env bash
# Test: <plugin>:<skill> skill structure
# Verifies SKILL.md exists with frontmatter, references resolve,
# and plugin manifests have matching versions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$REPO_ROOT/{{plugin_dir}}/<plugin>/skills/<skill>"
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
CCM="$REPO_ROOT/{{plugin_dir}}/<plugin>/.claude-plugin/plugin.json"
CXM="$REPO_ROOT/{{plugin_dir}}/<plugin>/.codex-plugin/plugin.json"
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
MP_CC="$REPO_ROOT/{{marketplace_claude_path}}"
MP_CX="$REPO_ROOT/{{marketplace_codex_path}}"
if [ -f "$MP_CC" ] && jq -e '.plugins[] | select(.name == "<plugin>")' "$MP_CC" >/dev/null; then
    echo "  [PASS] Claude marketplace lists <plugin>"
elif [ ! -f "$MP_CC" ]; then
    echo "  [SKIP] Claude marketplace not present in this repo"
else
    echo "  [FAIL] Claude marketplace missing <plugin>"
    exit 1
fi
if [ -f "$MP_CX" ] && jq -e '.plugins[] | select(.name == "<plugin>")' "$MP_CX" >/dev/null; then
    echo "  [PASS] Codex marketplace lists <plugin>"
elif [ ! -f "$MP_CX" ]; then
    echo "  [SKIP] Codex marketplace not present in this repo"
else
    echo "  [FAIL] Codex marketplace missing <plugin>"
    exit 1
fi
echo ""

echo "=== Tests complete ==="
```

## Skill-triggering prompt template

Save as `{{test_triggering_dir}}/prompts/<skill>-<action>.txt`. One-line, action-led, realistic.

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
PLUGIN_DIR={{plugin_dir}}/<plugin> bash {{test_triggering_dir}}/run-test.sh <skill> {{test_triggering_dir}}/prompts/<skill>-<action>.txt
```

## Integration test scaffold

Save as `{{test_integration_dir}}/test-<plugin>-<skill>-integration.sh` and `chmod +x`. Skip cleanly when auth is missing.

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
