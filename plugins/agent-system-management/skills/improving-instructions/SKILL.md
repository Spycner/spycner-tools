---
name: improving-instructions
description: Audit and improve AGENTS.md and CLAUDE.md files across project and user scopes.
tools: Read, Glob, Grep, Bash, Edit
---

# Agents.md Improver

Audit, evaluate, and improve agent-instruction files (AGENTS.md, CLAUDE.md, and variants) across a codebase to ensure the host agent has optimal project context.

**This skill can write to agent-instruction files.** After presenting a quality report and getting user approval, it updates files with targeted improvements.

## Platform Adaptation

| Capability | Claude Code | Codex |
|---|---|---|
| Find files | `Glob` / `Grep` | `shell` (`find`, `grep`) |
| Read a file | `Read` | `shell` (`cat`) |
| Edit a file | `Edit` | `apply_patch` / `shell` heredoc |
| User confirmation | `AskUserQuestion` | `ask_user` / built-in approval prompt |
| Shell commands | `Bash` | `shell` |

The skill body refers to actions abstractly ("read the file", "apply the diff"). The host agent maps to its own tool inventory.

## Workflow

### Phase 1: Discovery

Find every agent-instruction file in scope (project + user-global), dedupe symlinked pairs via `realpath`:

```bash
{
  find . \( \
      -name "AGENTS.md" \
      -o -name "AGENTS.local.md" \
      -o -name "CLAUDE.md" \
      -o -name "CLAUDE.local.md" \
      -o -name ".claude.md" \
      -o -name ".claude.local.md" \
    \) -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null
  ls ~/.claude/CLAUDE.md ~/.codex/AGENTS.md 2>/dev/null
} | xargs -I{} realpath {} | sort -u
```

**File Types & Locations:**

| Type | Location | Purpose |
|------|----------|---------|
| Project-shared | `./AGENTS.md`, `./CLAUDE.md`, `./.claude.md` | Primary project context, in git, shared with team |
| Project-local | `./AGENTS.local.md`, `./CLAUDE.local.md`, `./.claude.local.md` | Personal overrides, gitignored |
| User-global | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` | User-wide defaults across all projects |
| Package-specific | `./packages/*/AGENTS.md`, `./packages/*/CLAUDE.md` | Module-level context in monorepos |
| Subdirectory | Any nested location | Feature/domain-specific context |

**Note:** The host agent auto-discovers agent-instruction files in parent directories, making monorepo setups work automatically. When two paths share the same `realpath` (typical when CLAUDE.md is a symlink to AGENTS.md), audit them as one logical file and edit the canonical realpath target.

### Phase 2: Quality Assessment

For each unique file, evaluate against quality criteria. See [references/quality-criteria.md](references/quality-criteria.md) for detailed rubrics.

**Scope-aware lens:** the assessment lens shifts per scope. For project files: "is this codebase well-documented for an agent?". For user-global files: "are these rules organized, non-contradictory, at the right abstraction level, and not duplicated across projects?".

**Quick Assessment Checklist:**

| Criterion | Weight | Check |
|-----------|--------|-------|
| Commands/workflows documented | High | Are build/test/deploy commands present? |
| Architecture clarity | High | Can the host agent understand the codebase structure? |
| Non-obvious patterns | Medium | Are gotchas and quirks documented? |
| Conciseness | Medium | No verbose explanations or obvious info? |
| Currency | High | Does it reflect current codebase state? |
| Actionability | High | Are instructions executable, not vague? |

**Quality Scores:**
- **A (90-100)**: Comprehensive, current, actionable
- **B (70-89)**: Good coverage, minor gaps
- **C (50-69)**: Basic info, missing key sections
- **D (30-49)**: Sparse or outdated
- **F (0-29)**: Missing or severely outdated

### Phase 3: Quality Report Output

**ALWAYS output the quality report BEFORE making any updates.**

Format:

```
## Agents.md Quality Report

### Summary
- Files found: X (Y unique after realpath dedup)
- Average score: X/100
- Files needing update: X

### File-by-File Assessment

#### 1. ./AGENTS.md (Project-shared, also reachable as ./CLAUDE.md symlink)
**Score: XX/100 (Grade: X)**

| Criterion | Score | Notes |
|-----------|-------|-------|
| Commands/workflows | X/20 | ... |
| Architecture clarity | X/20 | ... |
| Non-obvious patterns | X/15 | ... |
| Conciseness | X/15 | ... |
| Currency | X/15 | ... |
| Actionability | X/15 | ... |

**Issues:**
- [List specific problems]

**Recommended additions:**
- [List what should be added]

#### 2. ./packages/api/AGENTS.md (Package-specific)
...
```

### Phase 4: Targeted Updates

After outputting the quality report, ask user for confirmation before updating.

**Update Guidelines (Critical):**

1. **Propose targeted additions only**: focus on genuinely useful info:
   - Commands or workflows discovered during analysis
   - Gotchas or non-obvious patterns found in code
   - Package relationships that weren't clear
   - Testing approaches that work
   - Configuration quirks

2. **Keep it minimal**: avoid:
   - Restating what's obvious from the code
   - Generic best practices already covered
   - One-off fixes unlikely to recur
   - Verbose explanations when a one-liner suffices

3. **Show diffs**: for each change, show:
   - Which file to update (use the canonical realpath)
   - The specific addition (as a diff or quoted block)
   - Brief explanation of why this helps future sessions

**Diff Format:**

````markdown
### Update: ./AGENTS.md

**Why:** Build command was missing, causing confusion about how to run the project.

```diff
+ ## Quick Start
+
+ ```bash
+ npm install
+ npm run dev  # Start development server on port 3000
+ ```
```
````

### Phase 5: Apply Updates

After user approval, apply changes (see Platform Adaptation for the right edit tool). Preserve existing content structure. Edit the canonical realpath target only; symlinks update automatically.

## Templates

See [references/templates.md](references/templates.md) for templates by project type.

## Update Guidelines Reference

See [references/update-guidelines.md](references/update-guidelines.md) for full do's and don'ts.

## Common Issues to Flag

1. **Stale commands**: build commands that no longer work
2. **Missing dependencies**: required tools not mentioned
3. **Outdated architecture**: file structure that's changed
4. **Missing environment setup**: required env vars or config
5. **Broken test commands**: test scripts that have changed
6. **Undocumented gotchas**: non-obvious patterns not captured
7. **Scope mismatch**: project-specific rules in the user-global file (or vice versa)
8. **Duplicate rules**: same rule stated in both project and user-global file

## User Tips to Share

When presenting recommendations, remind users:

- **`#` key shortcut (Claude Code)**: during a Claude Code session, press `#` to have Claude auto-incorporate learnings into the project memory file
- **Keep it concise**: agent-instruction files should be human-readable; dense is better than verbose
- **Actionable commands**: all documented commands should be copy-paste ready
- **Use `*.local.md`**: for personal preferences not shared with team (add to `.gitignore`)
- **Global defaults**: put user-wide preferences in `~/.claude/CLAUDE.md` or `~/.codex/AGENTS.md`
- **Symlink for cross-runtime parity**: if you use both Claude Code and Codex, symlink `CLAUDE.md` → `AGENTS.md` so a single file serves both

## What Makes a Great Agent-Instruction File

**Key principles:**
- Concise and human-readable
- Actionable commands that can be copy-pasted
- Project-specific patterns, not generic advice
- Non-obvious gotchas and warnings

**Recommended sections** (use only what's relevant):
- Commands (build, test, dev, lint)
- Architecture (directory structure)
- Key Files (entry points, config)
- Code Style (project conventions)
- Environment (required vars, setup)
- Testing (commands, patterns)
- Gotchas (quirks, common mistakes)
- Workflow (when to do what)
