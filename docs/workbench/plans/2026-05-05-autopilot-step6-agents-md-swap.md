# Autopilot Step 6: agents-md-management swap implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `claude-md-management:*` skill invocations in workbench autopilot step 6 with this repo's `agents-md-management:*` skills, rewrite step 6's body to match the new dispatch architecture (orchestrator-inline session-capture + general-purpose-subagent improver), drop the obsolete auto-memory and doc-drift bullets, lock the swap in via the existing structural unit test, and bump workbench to 0.3.0.

**Architecture:** Pure documentation change inside `plugins/workbench/skills/autopilot/`. The autopilot skill is a discipline-skill (instructions to the host agent), so "implementation" is editing two markdown files. Verification is the existing structural unit test at `tests/unit/test-workbench-autopilot-skill.sh`, extended to grep for the new skill IDs and the absence of the old ones. Version bump and marketplace registration follow the existing workbench pattern.

**Tech Stack:** Markdown (skills, references, plan), JSON (plugin manifests, marketplaces), Bash (test runner), `jq` (manifest assertions), `grep` (string presence/absence assertions).

**Spec:** `docs/workbench/specs/2026-05-05-autopilot-step6-agents-md-swap-design.md` (already committed at `7e2870c`).

**No worktree assumed.** The change is contained to four files and one test; the executing sub-skill decides whether to set up a worktree. All paths in this plan are repo-root relative.

---

## Task 1: Add this implementation plan to the feature branch

**Files:**
- Add: `docs/workbench/plans/2026-05-05-autopilot-step6-agents-md-swap.md` (this file)

- [ ] **Step 1: Verify plan file exists**

```bash
ls -la docs/workbench/plans/2026-05-05-autopilot-step6-agents-md-swap.md
```

Expected: file is listed (size greater than 0).

- [ ] **Step 2: Stage the plan**

```bash
git add docs/workbench/plans/2026-05-05-autopilot-step6-agents-md-swap.md
```

- [ ] **Step 3: Commit**

```bash
git commit -m "docs(workbench): add autopilot step 6 agents-md swap implementation plan"
```

- [ ] **Step 4: Verify commit landed**

```bash
git log --oneline -1
```

Expected: most recent line shows the new commit message.

---

## Task 2: Add failing test assertions for the skill-ID swap

This is the TDD-red step. We extend `tests/unit/test-workbench-autopilot-skill.sh` to assert the new skill IDs (Test 5 swap) and the absence of the old IDs in both SKILL.md and required-skills.md (new Test 13). The test will fail because the source files still carry the old IDs.

**Files:**
- Modify: `tests/unit/test-workbench-autopilot-skill.sh`

- [ ] **Step 1: Swap the universal-skill IDs in Test 5**

Use the Edit tool to replace this exact line in `tests/unit/test-workbench-autopilot-skill.sh` (currently line 70):

`old_string`:
```
for skill in 'workbench:using-workbench' 'workbench:brainstorming' 'superpowers:writing-plans' 'superpowers:test-driven-development' 'superpowers:subagent-driven-development' 'claude-md-management:revise-claude-md' 'claude-md-management:claude-md-improver'; do
```

`new_string`:
```
for skill in 'workbench:using-workbench' 'workbench:brainstorming' 'superpowers:writing-plans' 'superpowers:test-driven-development' 'superpowers:subagent-driven-development' 'agents-md-management:agents-md-session-capture' 'agents-md-management:agents-md-improver'; do
```

- [ ] **Step 2: Add a new Test 13 that asserts absence of old skill IDs in both files**

Use the Edit tool to insert a new test block before the final `echo "=== Tests complete ==="` line. Find this exact line in `tests/unit/test-workbench-autopilot-skill.sh`:

`old_string`:
```
echo "=== Tests complete ==="
```

`new_string`:
```
# Test 13: Old claude-md-management skill IDs are absent from SKILL.md and required-skills.md
echo "Test 13: Old claude-md-management skill IDs absent from autopilot files..."
RS="$SKILL_DIR/references/required-skills.md"
for old_id in 'claude-md-management:revise-claude-md' 'claude-md-management:claude-md-improver'; do
    if grep -qF "$old_id" "$SKILL_MD"; then
        echo "  [FAIL] SKILL.md still references $old_id (should have been swapped to agents-md-management)"
        exit 1
    else
        echo "  [PASS] SKILL.md does not reference $old_id"
    fi
    if grep -qF "$old_id" "$RS"; then
        echo "  [FAIL] required-skills.md still references $old_id (should have been swapped to agents-md-management)"
        exit 1
    else
        echo "  [PASS] required-skills.md does not reference $old_id"
    fi
done
echo ""

echo "=== Tests complete ==="
```

(Note: Test 7 already declares `INV="$SKILL_DIR/references/invariants.md"` and Test 8 already declares `RS="$SKILL_DIR/references/required-skills.md"`. Re-declaring `RS` in Test 13 is harmless and keeps the block self-contained.)

- [ ] **Step 3: Run the test and confirm it fails**

```bash
bash tests/unit/test-workbench-autopilot-skill.sh
```

Expected: The script exits non-zero. Test 5 should FAIL on the first new ID it checks (`agents-md-management:agents-md-session-capture` is not in SKILL.md yet). Confirm at least one `[FAIL]` line is present in the output before continuing. Do NOT commit yet; the test stays red until the source changes land.

---

## Task 3: Update SKILL.md (universal table row + step 6 body rewrite)

Make two edits to `plugins/workbench/skills/autopilot/SKILL.md`: swap the step 6 row in the universal table (line 49 in the current file), and replace the entire step 6 body (lines 151 through 164) with the new content from the spec.

**Files:**
- Modify: `plugins/workbench/skills/autopilot/SKILL.md`

- [ ] **Step 1: Swap the universal table row for step 6**

Use the Edit tool with this exact replacement.

`old_string`:
```
| 6 | `claude-md-management:revise-claude-md` and `claude-md-management:claude-md-improver` |
```

`new_string`:
```
| 6 | `agents-md-management:agents-md-session-capture` and `agents-md-management:agents-md-improver` |
```

- [ ] **Step 2: Replace the entire step 6 body**

Use the Edit tool to replace the current step 6 body (from `### Step 6: Finalize docs and improvement pass` through `- Refresh user auto-memory entries for this project.`) with the spec's rewrite.

`old_string`:
```
### Step 6: Finalize docs and improvement pass

**First actions, in order:** invoke `claude-md-management:revise-claude-md`, then `claude-md-management:claude-md-improver`. Both via the `Skill` tool. (Replace either if the profile says so.)

**Autonomous mode: apply every skill's proposed edits directly.** Do not pause for approval; running autopilot is the approval. Briefly report the edits in the end-of-turn summary so the user can see what landed.

All edits land on the feature branch in this run. CLAUDE.md updates, ADRs, OPEN_THINGS updates, auto-memory updates: each one a commit on the current branch with a matching Conventional-Commits type. No follow-up chore PRs.

Then:

- Update `<paths.adr>/NNNN-<short-title>.md` for load-bearing decisions if the path exists in the project. Index in `<paths.adr>/README.md`.
- Update `<paths.open_things>` if it exists: remove resolved items, add follow-ups ordered by importance.
- Update other project doc files that drifted (architecture overview, README commands table).
- Refresh user auto-memory entries for this project.
```

`new_string`:
```
### Step 6: Finalize docs and improvement pass

**First actions, in order:**

1. Invoke `agents-md-management:agents-md-session-capture` via the `Skill` tool in the main session. This skill reads the conversation transcript, so it must run inline in the orchestrator. Pass **inline-prompt A** below. Wait for it to return and verify its commits exist on the feature branch via `git log` before proceeding.
2. After session-capture has returned and its commits have landed, dispatch `agents-md-management:agents-md-improver` to a general-purpose subagent (Claude Code: `Agent` tool, `general-purpose` subagent_type, no model override. Codex: equivalent general-purpose subagent.) Pass **inline-prompt B** below. The improver does a cold audit and does not need session context; running it in a subagent keeps the orchestrator's context lean.

Either skill can be replaced via the profile.

**Inline-prompt A (orchestrator pastes into the session-capture Skill invocation):**

> "You are running inside workbench autopilot in the main orchestrator session, on the feature branch in the current working directory. Skip the approval prompt at the end of your skill. After deciding what to change, apply the edits directly. Commit each logical change on the feature branch with a Conventional Commits message. Report back: every file you edited and a one-line summary per file."

**Inline-prompt B (orchestrator pastes into the improver subagent dispatch):**

> "You are running inside workbench autopilot as a subagent, on the feature branch in the current working directory. Invoke `agents-md-management:agents-md-improver` via the `Skill` tool. Skip the approval prompt at the end of the skill. After deciding what to change, apply the edits directly. Commit each logical change on the feature branch with a Conventional Commits message (`docs(agents-md): ...`). Report back: every file you edited, a one-line summary per file, and the commit hashes you created."

**All edits land on the feature branch in this run.** AGENTS.md, CLAUDE.md, `*.local.md`, user-global agent-instruction files, ADRs, OPEN_THINGS updates: each one a commit on the current branch with a matching Conventional Commits type. No follow-up chore PRs.

After the subagent returns, the orchestrator:

1. Reads the subagent's summary.
2. Verifies the commits exist via `git log <feature-branch> --oneline`.
3. Includes both skills' summaries in the end-of-turn report.

Then, **the orchestrator** updates the following inline (it does not delegate to a subagent), committing each as a separate Conventional Commits entry on the feature branch:

- Update `<paths.adr>/NNNN-<short-title>.md` for load-bearing decisions if the path exists in the project. Index in `<paths.adr>/README.md`.
- Update `<paths.open_things>` if it exists: remove resolved items, add follow-ups ordered by importance.
```

(Note the explicit drops vs. the old text: the "Refresh user auto-memory entries for this project" bullet is gone, and the "Update other project doc files that drifted" bullet is gone. The "auto-memory updates" item from the old line 157 enumeration is also gone, replaced by the broader file list `AGENTS.md, CLAUDE.md, *.local.md, user-global agent-instruction files, ADRs, OPEN_THINGS updates`.)

- [ ] **Step 3: Verify the edits with grep**

```bash
grep -n 'agents-md-management:agents-md-session-capture' plugins/workbench/skills/autopilot/SKILL.md
grep -n 'agents-md-management:agents-md-improver' plugins/workbench/skills/autopilot/SKILL.md
grep -n 'inline-prompt A' plugins/workbench/skills/autopilot/SKILL.md
grep -n 'inline-prompt B' plugins/workbench/skills/autopilot/SKILL.md
grep -c 'claude-md-management' plugins/workbench/skills/autopilot/SKILL.md
```

Expected: the first four `grep -n` calls each print at least one match. The last `grep -c` prints `0` (no remaining old IDs in this file).

---

## Task 4: Update required-skills.md (table rows + example prose)

Two edits in `plugins/workbench/skills/autopilot/references/required-skills.md`: swap the two step-6 rows in the universal table (lines 14-15), and update the example prose that names the two skills (line 55).

**Files:**
- Modify: `plugins/workbench/skills/autopilot/references/required-skills.md`

- [ ] **Step 1: Swap the two step-6 table rows**

Use the Edit tool with this exact replacement.

`old_string`:
```
| 6 | `claude-md-management:revise-claude-md` | cross-plugin |
| 6 | `claude-md-management:claude-md-improver` | cross-plugin |
```

`new_string`:
```
| 6 | `agents-md-management:agents-md-session-capture` | cross-plugin |
| 6 | `agents-md-management:agents-md-improver` | cross-plugin |
```

- [ ] **Step 2: Update the "additional" example prose**

Use the Edit tool with this exact replacement.

`old_string`:
```
This says "at step 6, in addition to `revise-claude-md` and `claude-md-improver`, also audit `my-project:custom-changelog`."
```

`new_string`:
```
This says "at step 6, in addition to `agents-md-session-capture` and `agents-md-improver`, also audit `my-project:custom-changelog`."
```

- [ ] **Step 3: Verify the edits with grep**

```bash
grep -n 'agents-md-management:agents-md-session-capture' plugins/workbench/skills/autopilot/references/required-skills.md
grep -n 'agents-md-management:agents-md-improver' plugins/workbench/skills/autopilot/references/required-skills.md
grep -n 'agents-md-session-capture` and `agents-md-improver' plugins/workbench/skills/autopilot/references/required-skills.md
grep -c 'claude-md-management' plugins/workbench/skills/autopilot/references/required-skills.md
grep -c 'revise-claude-md\|claude-md-improver' plugins/workbench/skills/autopilot/references/required-skills.md
```

Expected: the first three `grep -n` calls each print one match. Both `grep -c` calls print `0`.

---

## Task 5: Confirm the unit test now passes and commit the swap

The test from Task 2, the SKILL.md edits from Task 3, and the required-skills.md edits from Task 4 should all be staged together and land in a single commit. After this commit, the unit test goes green for everything except the version assertions (Tests 11 and 12), which still expect 0.2.0 and will be updated in Task 6.

**Files:**
- (Verify only) `tests/unit/test-workbench-autopilot-skill.sh`
- (Verify only) `plugins/workbench/skills/autopilot/SKILL.md`
- (Verify only) `plugins/workbench/skills/autopilot/references/required-skills.md`

- [ ] **Step 1: Run the unit test and confirm Tests 5 and 13 now pass**

```bash
bash tests/unit/test-workbench-autopilot-skill.sh
```

Expected: Tests 1 through 10 PASS, Test 13 PASSES (all four PASS lines for absent old IDs). Tests 11 and 12 PASS only if the manifests are still at 0.2.0 (they should be, since we have not bumped them yet). Overall script exits 0.

If the script exits non-zero: read the failing test number, jump back to the corresponding task (Task 2 for Test 5/13, Task 3 for SKILL.md content, Task 4 for required-skills.md content), and re-verify the edit landed exactly.

- [ ] **Step 2: Stage the three changed files**

```bash
git add tests/unit/test-workbench-autopilot-skill.sh plugins/workbench/skills/autopilot/SKILL.md plugins/workbench/skills/autopilot/references/required-skills.md
```

- [ ] **Step 3: Confirm the staged diff matches expectations**

```bash
git diff --cached --stat
```

Expected: exactly three files listed (the test script, `SKILL.md`, `required-skills.md`). No other files staged.

- [ ] **Step 4: Commit**

```bash
git commit -m "$(cat <<'EOF'
docs(workbench): swap autopilot step 6 to agents-md-management skills

Replace `claude-md-management:revise-claude-md` and
`claude-md-management:claude-md-improver` with
`agents-md-management:agents-md-session-capture` and
`agents-md-management:agents-md-improver` across the autopilot SKILL.md
and required-skills.md. Rewrite step 6's body to dispatch
session-capture inline in the orchestrator and improver in a
general-purpose subagent, with explicit inline prompts for each. Drop
the auto-memory bullet (Claude-specific per-project memory) and the
doc-drift bullet (replaced by a future generic doc-drift skill). Extend
the structural unit test to assert the new skill IDs and the absence of
the old ones.
EOF
)"
```

- [ ] **Step 5: Verify the commit landed**

```bash
git log --oneline -1
```

Expected: most recent line shows the new commit message.

---

## Task 6: Update version assertions in the test, then bump workbench to 0.3.0

Step 6's behavior shifts (different dispatch architecture, different file scope), so the spec calls for a minor bump from 0.2.0 to 0.3.0. Three files carry the version: both plugin manifests and the workbench entry in the Claude Code marketplace. The Codex marketplace entry for workbench has no `version` field (verified before plan was written), so it does not need an edit.

The unit test's Tests 11 and 12 currently assert `0.2.0`; updating those to `0.3.0` is a TDD-red step (test fails first), then bumping the manifests and marketplace entry greens it.

**Files:**
- Modify: `tests/unit/test-workbench-autopilot-skill.sh`
- Modify: `plugins/workbench/.claude-plugin/plugin.json`
- Modify: `plugins/workbench/.codex-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Update Test 11 version assertion to 0.3.0 (TDD-red)**

Use the Edit tool to update the jq predicate in Test 11 of `tests/unit/test-workbench-autopilot-skill.sh`.

`old_string`:
```
if jq -e '.version == "0.2.0"' "$CCM" >/dev/null && jq -e '.version == "0.2.0"' "$CXM" >/dev/null; then
    echo "  [PASS] both plugin manifests at 0.2.0"
else
    echo "  [FAIL] plugin manifests not at 0.2.0"
```

`new_string`:
```
if jq -e '.version == "0.3.0"' "$CCM" >/dev/null && jq -e '.version == "0.3.0"' "$CXM" >/dev/null; then
    echo "  [PASS] both plugin manifests at 0.3.0"
else
    echo "  [FAIL] plugin manifests not at 0.3.0"
```

- [ ] **Step 2: Update Test 12 version assertion to 0.3.0 (TDD-red)**

Use the Edit tool to update Test 12.

`old_string`:
```
if jq -e '.plugins[] | select(.name == "workbench") | .version == "0.2.0"' "$MP" >/dev/null; then
    echo "  [PASS] Claude marketplace workbench at 0.2.0"
else
    echo "  [FAIL] Claude marketplace workbench not at 0.2.0"
```

`new_string`:
```
if jq -e '.plugins[] | select(.name == "workbench") | .version == "0.3.0"' "$MP" >/dev/null; then
    echo "  [PASS] Claude marketplace workbench at 0.3.0"
else
    echo "  [FAIL] Claude marketplace workbench not at 0.3.0"
```

- [ ] **Step 3: Run the unit test and confirm it now fails on Tests 11 and 12**

```bash
bash tests/unit/test-workbench-autopilot-skill.sh
```

Expected: Tests 1 through 10 and 13 PASS. Test 11 FAILS with `plugin manifests not at 0.3.0`. Script exits non-zero before Test 12 runs (because of `set -euo pipefail` and the explicit `exit 1`). This is the expected red state.

- [ ] **Step 4: Bump the Claude Code plugin manifest to 0.3.0**

Use the Edit tool on `plugins/workbench/.claude-plugin/plugin.json`. The exact `old_string` depends on the current line; read the file first to find the version line, then swap `"version": "0.2.0"` to `"version": "0.3.0"`. There is exactly one `version` field in this file.

```bash
grep -n '"version"' plugins/workbench/.claude-plugin/plugin.json
```

Then use the Edit tool with `old_string: "version": "0.2.0"` and `new_string: "version": "0.3.0"`.

- [ ] **Step 5: Bump the Codex plugin manifest to 0.3.0**

Same operation on `plugins/workbench/.codex-plugin/plugin.json`. Exactly one `version` field in this file.

```bash
grep -n '"version"' plugins/workbench/.codex-plugin/plugin.json
```

Use the Edit tool with `old_string: "version": "0.2.0"` and `new_string: "version": "0.3.0"`.

- [ ] **Step 6: Bump the workbench entry in the Claude Code marketplace**

The Claude marketplace at `.claude-plugin/marketplace.json` has multiple plugin entries, so `"version": "0.2.0"` is not unique on its own. The workbench entry is at lines 43-48 in the current file. Verify shape first:

```bash
grep -n -B1 -A4 '"name": "workbench"' .claude-plugin/marketplace.json
```

Expected output: the four-line block `name` / `source` / `description` / `version`, with `version` as the last field (no trailing comma).

Then use the Edit tool with the workbench-specific four-line block (the `description` line makes it unique):

`old_string`:
```
      "name": "workbench",
      "source": "./plugins/workbench",
      "description": "Personal fork-as-you-touch skill collection: brainstorming, using-workbench meta-skill, and the autopilot autonomous feature-flow skill (kernel + project profile at .workbench/autopilot.md)",
      "version": "0.2.0"
```

`new_string`:
```
      "name": "workbench",
      "source": "./plugins/workbench",
      "description": "Personal fork-as-you-touch skill collection: brainstorming, using-workbench meta-skill, and the autopilot autonomous feature-flow skill (kernel + project profile at .workbench/autopilot.md)",
      "version": "0.3.0"
```

If the `grep` output above shows the `description` text differs from the snippet here (e.g. it has been edited since this plan was written), use the actual current text in `old_string` instead. The only intent is to swap `0.2.0` → `0.3.0` inside the workbench block, leaving every other field byte-identical.

- [ ] **Step 7: Run the unit test and confirm it now passes end-to-end**

```bash
bash tests/unit/test-workbench-autopilot-skill.sh
```

Expected: every test PASSES. Script exits 0. `=== Tests complete ===` prints at the end.

- [ ] **Step 8: Stage and commit the version bump**

```bash
git add tests/unit/test-workbench-autopilot-skill.sh plugins/workbench/.claude-plugin/plugin.json plugins/workbench/.codex-plugin/plugin.json .claude-plugin/marketplace.json
git diff --cached --stat
```

Expected: exactly four files listed.

```bash
git commit -m "$(cat <<'EOF'
chore(workbench): bump to 0.3.0 for autopilot step 6 swap

Step 6 of the autopilot skill now invokes
agents-md-management:agents-md-session-capture and
agents-md-management:agents-md-improver instead of the
claude-md-management variants. The dispatch architecture also shifts
(orchestrator-inline session-capture, general-purpose-subagent
improver) and two bullets are dropped (auto-memory refresh, doc-drift
sweep). Both behavioral shifts justify a minor bump.

Existing downstream profiles with `replaces` or `additional` rows
referencing `claude-md-management:*` IDs will silently fail the audit
after this change. No such profile exists in this repo, but this
commit notes the rename for any downstream user.
EOF
)"
```

- [ ] **Step 9: Verify the commit landed**

```bash
git log --oneline -3
```

Expected: top three lines are (newest first) the version bump commit, the swap commit from Task 5, and the plan commit from Task 1.

---

## Task 7: Final verification

Run the full unit test suite for the autopilot skill plus the related profile-schema test, and the autopilot skill-triggering test, to confirm no adjacent test regressed.

**Files:** none modified.

- [ ] **Step 1: Run the autopilot unit test one more time**

```bash
bash tests/unit/test-workbench-autopilot-skill.sh
```

Expected: every test PASSES. Script exits 0.

- [ ] **Step 2: Run the workbench profile-schema unit test**

```bash
bash tests/unit/test-workbench-profile-schema.sh
```

Expected: every test PASSES. Script exits 0. (This test does not reference `claude-md-management` per the pre-plan check, so it should be unaffected; running it confirms.)

- [ ] **Step 3: Run the Codex plugin structure test**

```bash
bash tests/unit/test-codex-plugin-structure.sh
```

Expected: every test PASSES. Script exits 0. The version bump in `plugins/workbench/.codex-plugin/plugin.json` could in principle break this; verify it does not.

- [ ] **Step 4: Verify branch state matches expectations**

```bash
git status --short
git log --oneline -4
```

Expected: clean working tree (no uncommitted changes from the plan). Top four log lines are (newest first): the version bump commit, the swap commit, the plan commit, and the previous tip (`7e2870c docs(workbench): tighten step 6 swap spec from review feedback`).

---

## Out of scope (per spec)

Three follow-ups surfaced during brainstorm and are not part of this plan:

1. Pluggable issue tracking (OPEN_THINGS / GitHub issues / Linear / other).
2. Optional or configurable ADRs (profile flag).
3. Generic doc-drift skill (replaces the dropped "doc files that drifted" bullet).

These ship as separate plans/PRs.
