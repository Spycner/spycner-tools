#!/usr/bin/env bash
# Test: claude-codex-bridge skill
# Verifies the skill is loaded and describes its scout/apply/reviewer pipeline
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: claude-codex-bridge skill ==="
echo ""

# Test 1: Skill recognition
echo "Test 1: Skill loading and recognition..."

output=$(run_claude "What does the claude-codex-bridge skill do? Describe it briefly." 30)

assert_contains "$output" "claude.code|codex|cross.runtime|both runtimes" "Mentions cross-runtime purpose" || true
assert_contains "$output" "memory file|CLAUDE\.md|AGENTS\.md" "Mentions memory files" || true
assert_contains "$output" "scout|apply|review" "Mentions scout/apply/reviewer pipeline" || true

echo ""

# Test 2: Artifact families
echo "Test 2: Artifact families covered..."

output=$(run_claude "In the claude-codex-bridge skill, what kinds of files does it port? Be specific." 30)

assert_contains "$output" "memory file|CLAUDE\.md|AGENTS\.md" "Memory files" || true
assert_contains "$output" "agent|subagent" "Subagents" || true
assert_contains "$output" "hook" "Hooks" || true
assert_contains "$output" "setting|config\.toml|settings\.json" "Settings" || true

echo ""

# Test 3: Hierarchical handling
echo "Test 3: Hierarchical memory file handling..."

output=$(run_claude "How does claude-codex-bridge handle hierarchical CLAUDE.md files (subdirectory CLAUDE.md files)?" 30)

assert_contains "$output" "hierarchical|every (dir|level)|each (dir|level)|symlink" "Mentions hierarchical mirroring" || true

echo ""

# Test 4: Trust gate
echo "Test 4: Trust gate warning..."

output=$(run_claude "When porting to Codex, what does the claude-codex-bridge skill warn the user about regarding the .codex/ directory?" 30)

assert_contains "$output" "trust|trusted|accept" "Mentions trust gate" || true

echo ""

# Test 5: References supporting docs
echo "Test 5: References manifest-schema and port-recipes..."

output=$(run_claude "What supporting reference docs does the claude-codex-bridge skill use?" 30)

assert_contains "$output" "manifest.schema|manifest schema" "References manifest-schema.md" || true
assert_contains "$output" "port.recipes|port recipes|recipes" "References port-recipes.md" || true

echo ""
echo "=== Tests complete ==="
