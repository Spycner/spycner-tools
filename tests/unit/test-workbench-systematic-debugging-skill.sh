#!/usr/bin/env bash
# Unit test for the workbench systematic-debugging skill.
# Filesystem-check style: jq + grep, no run_claude.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKILL_DIR="$ROOT/plugins/workbench/skills/systematic-debugging"
SKILL_MD="$SKILL_DIR/SKILL.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

# 1. SKILL.md exists with valid YAML frontmatter and correct name.
[ -s "$SKILL_MD" ] || fail "SKILL.md missing or empty"
NAME="$(awk '/^---$/{c++;next} c==1' "$SKILL_MD" | grep '^name:' | head -1 | awk '{print $2}')"
[ "$NAME" = "systematic-debugging" ] || fail "frontmatter name is '$NAME', expected 'systematic-debugging'"
pass "SKILL.md frontmatter name"

# 2. SKILL.md anchors discipline phrase.
grep -q "NO FIXES WITHOUT ROOT CAUSE" "$SKILL_MD" || fail "missing 'NO FIXES WITHOUT ROOT CAUSE' anchor"
pass "discipline anchor present"

# 3. SKILL.md mentions all four phases.
for phase in "Phase 1" "Phase 2" "Phase 3" "Phase 4"; do
  grep -q "$phase" "$SKILL_MD" || fail "missing '$phase' marker"
done
pass "four phases mentioned"

# 4. No em-dash (U+2014) or en-dash (U+2013) in any ported file.
if grep -RnP "[\x{2013}\x{2014}]" "$SKILL_DIR" >/dev/null 2>&1; then
  grep -RnP "[\x{2013}\x{2014}]" "$SKILL_DIR" >&2
  fail "em-dash or en-dash present"
fi
pass "no em/en-dashes in ported files"

# 5-6. Bundled references + TS example exist and are non-empty.
for ref in root-cause-tracing.md defense-in-depth.md condition-based-waiting.md; do
  [ -s "$SKILL_DIR/references/$ref" ] || fail "references/$ref missing or empty"
done
[ -s "$SKILL_DIR/references/condition-based-waiting-example.ts" ] || fail "condition-based-waiting-example.ts missing or empty"
pass "all bundled references present"

# 7. find-polluter.sh exists, non-empty, executable.
[ -s "$SKILL_DIR/find-polluter.sh" ] || fail "find-polluter.sh missing or empty"
[ -x "$SKILL_DIR/find-polluter.sh" ] || fail "find-polluter.sh not executable"
pass "find-polluter.sh shipped and executable"

# 8. SKILL.md links to each reference filename.
for ref in root-cause-tracing.md defense-in-depth.md condition-based-waiting.md; do
  grep -q "$ref" "$SKILL_MD" || fail "SKILL.md does not reference $ref"
done
pass "SKILL.md links to all references"

# 9. Peer-skill routing uses workbench: prefix, not superpowers:.
if grep -q "superpowers:test-driven-development\|superpowers:verification-before-completion" "$SKILL_MD"; then
  fail "SKILL.md still uses superpowers: prefix for peer skills"
fi
grep -q "workbench:test-driven-development" "$SKILL_MD" || fail "SKILL.md missing workbench:test-driven-development reference"
grep -q "workbench:verification-before-completion" "$SKILL_MD" || fail "SKILL.md missing workbench:verification-before-completion reference"
pass "peer-skill routing rewritten to workbench:"

# 10. README.md mentions the skill.
grep -q "systematic-debugging" "$ROOT/README.md" || fail "README.md does not mention systematic-debugging"
pass "README mentions skill"

# 11. AGENTS.md mentions the skill.
grep -q "systematic-debugging" "$ROOT/AGENTS.md" || fail "AGENTS.md does not mention systematic-debugging"
pass "AGENTS.md mentions skill"

# 12. NOTICE credits the skill.
grep -q "systematic-debugging" "$ROOT/plugins/workbench/NOTICE" || fail "NOTICE does not credit systematic-debugging"
pass "NOTICE attribution present"

# 13. Plugin manifests at 0.10.0.
CC_VER="$(jq -r '.version' "$ROOT/plugins/workbench/.claude-plugin/plugin.json")"
CDX_VER="$(jq -r '.version' "$ROOT/plugins/workbench/.codex-plugin/plugin.json")"
[ "$CC_VER" = "0.10.0" ] || fail "claude-plugin version is $CC_VER, expected 0.10.0"
[ "$CDX_VER" = "0.10.0" ] || fail "codex-plugin version is $CDX_VER, expected 0.10.0"
pass "plugin manifests at 0.10.0"

# 14. Marketplace entries at 0.10.0.
CC_MP_VER="$(jq -r '.plugins[] | select(.name=="workbench") | .version' "$ROOT/.claude-plugin/marketplace.json")"
CDX_MP_VER="$(jq -r '.plugins[] | select(.name=="workbench") | .version' "$ROOT/.agents/plugins/marketplace.json")"
[ "$CC_MP_VER" = "0.10.0" ] || fail "claude marketplace workbench version is $CC_MP_VER, expected 0.10.0"
[ "$CDX_MP_VER" = "0.10.0" ] || fail "codex marketplace workbench version is $CDX_MP_VER, expected 0.10.0"
pass "marketplaces at 0.10.0"

echo "OK"
