#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MARKETPLACE="$REPO_ROOT/.agents/plugins/marketplace.json"

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

[ -f "$MARKETPLACE" ] || fail "Codex marketplace missing at .agents/plugins/marketplace.json"

jq empty "$MARKETPLACE" || fail "Codex marketplace is not valid JSON"

marketplace_name="$(jq -r '.name' "$MARKETPLACE")"
[ "$marketplace_name" = "pgoell-claude-tools" ] || fail "Unexpected marketplace name: $marketplace_name"

plugin_count="$(jq '.plugins | length' "$MARKETPLACE")"
[ "$plugin_count" -eq 5 ] || fail "Expected 5 Codex marketplace plugins, got $plugin_count"

for plugin in atlassian google-workspace research writing runtime-bridge; do
    plugin_dir="$REPO_ROOT/plugins/$plugin"
    manifest="$plugin_dir/.codex-plugin/plugin.json"

    [ -d "$plugin_dir/skills" ] || fail "$plugin skills directory missing"
    [ -f "$manifest" ] || fail "$plugin Codex manifest missing"
    jq empty "$manifest" || fail "$plugin Codex manifest is not valid JSON"

    manifest_name="$(jq -r '.name' "$manifest")"
    [ "$manifest_name" = "$plugin" ] || fail "$plugin manifest name mismatch: $manifest_name"

    skills_path="$(jq -r '.skills' "$manifest")"
    [ "$skills_path" = "./skills/" ] || fail "$plugin manifest must reuse ./skills/, got $skills_path"

    display_name="$(jq -r '.interface.displayName // empty' "$manifest")"
    [ -n "$display_name" ] || fail "$plugin manifest missing interface.displayName"

    short_description="$(jq -r '.interface.shortDescription // empty' "$manifest")"
    [ -n "$short_description" ] || fail "$plugin manifest missing interface.shortDescription"

    marketplace_path="$(jq -r --arg plugin "$plugin" '.plugins[] | select(.name == $plugin) | .source.path' "$MARKETPLACE")"
    [ "$marketplace_path" = "./plugins/$plugin" ] || fail "$plugin marketplace path mismatch: $marketplace_path"

    marketplace_source="$(jq -r --arg plugin "$plugin" '.plugins[] | select(.name == $plugin) | .source.source' "$MARKETPLACE")"
    [ "$marketplace_source" = "local" ] || fail "$plugin marketplace source must be local"

    installation="$(jq -r --arg plugin "$plugin" '.plugins[] | select(.name == $plugin) | .policy.installation' "$MARKETPLACE")"
    [ "$installation" = "AVAILABLE" ] || fail "$plugin marketplace installation policy mismatch: $installation"

    authentication="$(jq -r --arg plugin "$plugin" '.plugins[] | select(.name == $plugin) | .policy.authentication' "$MARKETPLACE")"
    [ "$authentication" = "ON_INSTALL" ] || fail "$plugin marketplace authentication policy mismatch: $authentication"

    category="$(jq -r --arg plugin "$plugin" '.plugins[] | select(.name == $plugin) | .category' "$MARKETPLACE")"
    [ -n "$category" ] || fail "$plugin marketplace category missing"

    marketplace_display_name="$(jq -r --arg plugin "$plugin" '.plugins[] | select(.name == $plugin) | .interface.displayName // empty' "$MARKETPLACE")"
    [ -n "$marketplace_display_name" ] || fail "$plugin marketplace entry missing interface.displayName"
done

[ -L "$REPO_ROOT/CLAUDE.md" ] || fail "Root CLAUDE.md must be a symlink to AGENTS.md"
[ "$(readlink "$REPO_ROOT/CLAUDE.md")" = "AGENTS.md" ] || fail "CLAUDE.md symlink must target AGENTS.md"
[ -f "$REPO_ROOT/AGENTS.md" ] || fail "AGENTS.md missing at repo root"

for skill in \
    "$REPO_ROOT/plugins/research/skills/research/SKILL.md" \
    "$REPO_ROOT/plugins/writing/skills/writing/SKILL.md" \
    "$REPO_ROOT/plugins/writing/skills/pyramid/SKILL.md" \
    "$REPO_ROOT/plugins/writing/skills/tech-doc/SKILL.md"; do
    grep -q "## Platform Adaptation" "$skill" || fail "$skill missing Platform Adaptation section"
    grep -q "Codex" "$skill" || fail "$skill missing Codex tool mapping"
done

if rg -q "Agent tool \\(general-purpose\\):" "$REPO_ROOT/plugins/research" "$REPO_ROOT/plugins/writing"; then
    fail "Prompt templates still contain Claude specific Agent tool headers"
fi

echo "Codex plugin structure OK"
