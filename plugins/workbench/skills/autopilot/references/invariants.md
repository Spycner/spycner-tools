# Workbench Autopilot Invariants

Six non-negotiables that govern every autopilot run. Profiles can extend through `## Project-specific rules` but cannot weaken these.

## 1. PR behavior respects `Mode`

The `Mode` field in the project's `.workbench/autopilot.md` determines the post-CI behavior:

- `stop_at_green` (default): autopilot stops when CI is green and reports the PR URL.
- `automerge`: autopilot calls `gh pr merge --auto`, polls until merged, refreshes local default branch, deletes the feature branch.
- `request_review`: autopilot calls `gh pr ready` and stops.

Default never auto-merges. Autopilot never assumes automerge unless the profile explicitly opts in.

## 2. Never skip hooks

No `--no-verify`, no `--no-gpg-sign`, no `LEFTHOOK=0`, no environment variables that bypass git hooks. If a hook fails, investigate the underlying issue and fix it. Skipping the hook is never the right answer.

## 3. No AI attribution

No `Generated with`, no `Co-Authored-By: Claude`, no AI provenance lines anywhere in commit messages, PR titles, PR bodies, or code comments. The user prefers attribution to themselves.

## 4. Conventional Commits compliance

Every commit subject uses a Conventional Commits type. Allowed types (defaults; the profile may shrink the set via prose, never grow it):

`feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `perf`, `style`, `ci`, `build`, `revert`.

Lowercase subject after the colon. Scope is optional but recommended.

## 5. No em-dashes or en-dashes in prose

User global preference. Rewrite with commas, periods, colons, semicolons, parentheses, or by splitting into separate sentences. Hyphens in compound words (`spec-driven`, `AI-assisted`) are hyphenation, not punctuation, and stay. Markdown horizontal rules (`---`) are structural and stay.

## 6. Never synthesize a skill's output freehand

When a step names a skill, calling the `Skill` tool (or its runtime equivalent) and letting it return is mandatory before producing that step's artifact. Freehand output that looks like a skill ran is a process violation; the work must be redone after invoking the skill.

At the end of each turn, double-check that the skills required by the steps you just executed actually appear in your tool-call history. The pre-PR audit (between step 6 and step 7) re-walks the universal required-skills table and the profile's overrides; missing invocations block the push.
