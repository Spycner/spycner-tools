#!/usr/bin/env bash
# Test: workbench autopilot profile schema reference docs
# Verifies PR 1 of the autopilot port: profile-schema.md and example-project-profile.md
# exist, contain the documented heading skeleton, and READMEs link to them.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCHEMA="$REPO_ROOT/plugins/workbench/skills/autopilot/references/profile-schema.md"
EXAMPLE="$REPO_ROOT/plugins/workbench/skills/autopilot/references/example-project-profile.md"
WORKBENCH_README="$REPO_ROOT/plugins/workbench/README.md"
ROOT_README="$REPO_ROOT/README.md"

echo "=== Test: workbench autopilot profile foundation ==="
echo ""

# Test 1: Both reference files exist and are non-empty
echo "Test 1: Reference files exist..."
for f in "$SCHEMA" "$EXAMPLE"; do
    if [ -s "$f" ]; then
        echo "  [PASS] $(basename "$f") exists"
    else
        echo "  [FAIL] $(basename "$f") missing or empty"
        exit 1
    fi
done
echo ""

# Test 2: profile-schema.md documents the heading skeleton
echo "Test 2: profile-schema.md documents heading skeleton..."
for heading in 'PR behavior' 'Required skills' 'Project name' 'Branching' 'Commands' 'Documentation paths' 'Project-specific rules'; do
    if grep -qF "## $heading" "$SCHEMA"; then
        echo "  [PASS] schema mentions '## $heading'"
    else
        echo "  [FAIL] schema missing '## $heading'"
        exit 1
    fi
done
echo ""

# Test 3: profile-schema.md documents discovery and Markdown-first stance
echo "Test 3: profile-schema.md documents discovery rules..."
for term in 'Discovery' 'Markdown-first' 'YAML' 'Bootstrap precedence' 'replaces' 'additional'; do
    if grep -qiF "$term" "$SCHEMA"; then
        echo "  [PASS] schema mentions '$term'"
    else
        echo "  [FAIL] schema missing '$term'"
        exit 1
    fi
done
echo ""

# Test 4: example-project-profile.md contains both examples
echo "Test 4: example-project-profile.md contains both examples..."
for label in 'Example 1' 'Example 2' 'Recommended minimum' 'Kitchen sink'; do
    if grep -qiF "$label" "$EXAMPLE"; then
        echo "  [PASS] example mentions '$label'"
    else
        echo "  [FAIL] example missing '$label'"
        exit 1
    fi
done
echo ""

# Test 5: example mentions stop_at_green and automerge modes
echo "Test 5: example shows PR behavior modes..."
for mode in 'stop_at_green' 'automerge'; do
    if grep -qF "$mode" "$EXAMPLE"; then
        echo "  [PASS] example mentions '$mode'"
    else
        echo "  [FAIL] example missing '$mode'"
        exit 1
    fi
done
echo ""

# Test 6: workbench README links to the schema
echo "Test 6: workbench README links to profile-schema.md..."
if grep -qF 'profile-schema.md' "$WORKBENCH_README"; then
    echo "  [PASS] workbench README links to profile-schema.md"
else
    echo "  [FAIL] workbench README missing link to profile-schema.md"
    exit 1
fi
if grep -qF 'example-project-profile.md' "$WORKBENCH_README"; then
    echo "  [PASS] workbench README links to example-project-profile.md"
else
    echo "  [FAIL] workbench README missing link to example-project-profile.md"
    exit 1
fi
echo ""

# Test 7: workbench README explains kernel-vs-policy split
echo "Test 7: workbench README explains the split..."
if grep -qiE 'kernel|reusable|generic workflow' "$WORKBENCH_README" \
   && grep -qiE 'profile|local policy|local reality' "$WORKBENCH_README"; then
    echo "  [PASS] workbench README explains the split"
else
    echo "  [FAIL] workbench README missing kernel-vs-policy explanation"
    exit 1
fi
echo ""

# Test 8: root README mentions the profile schema
echo "Test 8: root README mentions profile-schema..."
if grep -qF 'profile-schema' "$ROOT_README"; then
    echo "  [PASS] root README mentions profile-schema"
else
    echo "  [FAIL] root README missing profile-schema reference"
    exit 1
fi
echo ""

# Test 9: schema notes deferred fallbacks
echo "Test 9: schema notes deferred fallback chain..."
for deferred in 'AGENTS.md' 'CLAUDE.md' 'README.md' 'autopilot.yaml'; do
    if grep -qF "$deferred" "$SCHEMA"; then
        echo "  [PASS] schema mentions deferred '$deferred'"
    else
        echo "  [FAIL] schema missing mention of deferred '$deferred'"
        exit 1
    fi
done
echo ""

# Test 10: schema documents bootstrap precedence
echo "Test 10: schema documents bootstrap precedence..."
if grep -qiF 'profile' "$SCHEMA" \
   && grep -qiE 'CLAUDE\.md.*AGENTS\.md|AGENTS\.md.*CLAUDE\.md' "$SCHEMA" \
   && grep -qiE 'detection|symbolic-ref|filesystem' "$SCHEMA"; then
    echo "  [PASS] schema documents precedence chain"
else
    echo "  [FAIL] schema missing precedence chain"
    exit 1
fi
echo ""

echo "=== Tests complete ==="
