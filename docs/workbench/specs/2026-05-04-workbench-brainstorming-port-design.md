# Workbench plugin: initial port (brainstorming + meta-skill)

**Date:** 2026-05-04
**Status:** Approved, ready for implementation plan
**Owner:** Pascal Göllner

## Summary

Create a new `workbench` plugin in `pgoell-claude-tools` that holds Pascal's personal forks of skills he uses regularly. Initial scope: port `brainstorming` and a trimmed meta-skill `using-workbench` from the upstream `superpowers` plugin (v5.0.7), with full Claude Code and Codex parity per repo convention.

The plugin operates in fork-as-you-touch mode: workbench coexists with the upstream `superpowers` plugin, and only ports skills that have been explicitly adopted. The brainstorming skill's terminal handoff continues to invoke `superpowers:writing-plans` cross-plugin until that skill is also ported in a future wave.

## Motivation

Pascal wants to own all skills he uses rather than collecting them piecemeal from different sources. Workbench will be the long-term home for that ownership: today brainstorming + meta-skill, over time more skills as he commits to using them, and eventually general dev automations beyond what upstream provides.

## Decisions

These were resolved through brainstorming dialogue:

1. **Plugin name:** `workbench`. Activity-style name (matching `research`, `writing`) rather than vendor or personal namespace. Accommodates non-strictly-dev skills like brainstorming.
2. **Port mode:** Fork-as-you-touch. Workbench ships only skills Pascal has decided to adapt or own. Upstream `superpowers` remains installed and provides skills not yet ported.
3. **Meta-skill shape:** Trimmed companion. `using-workbench` is short (~30 lines), defers all "invoke skills, be disciplined" meta-rules to upstream `using-superpowers`, and announces the workbench skill list plus a collision-resolution rule. Full upstream content is preserved verbatim in `using-workbench/references/using-superpowers-upstream.md` for incremental promotion as more skills are ported.
4. **Adaptations:** Clean port today, no design changes. Pascal has no specific gripes with the upstream brainstorming skill yet. He will discover frictions through actual use and iterate from there.
5. **Hook coverage:** Dual-runtime. Both Claude Code (`hooks/hooks.json`) and Codex (`hooks.json` at plugin root) declare a SessionStart hook that injects `using-workbench/SKILL.md`. Claude Code support is upstream-equivalent and known-working. Codex support follows the schema demonstrated by the openai-curated `figma` plugin; the figma hook script self-describes as "draft for future plugin hook runtimes," so Codex may recognize the schema today without yet firing it. Either way, the parity cost is small and the hook fires automatically once Codex enables the runtime.

## Plugin shape

```
plugins/workbench/
  .claude-plugin/
    plugin.json                        # Claude Code manifest
  .codex-plugin/
    plugin.json                        # Codex manifest with full interface block
  LICENSE                              # MIT, copied from upstream
  NOTICE                               # upstream attribution per repo memory rule
  README.md                            # plugin overview with Credits section
  hooks/
    hooks.json                         # Claude Code hook config (uses ${CLAUDE_PLUGIN_ROOT})
    run-hook.cmd                       # platform dispatcher, ported from upstream
    session-start                      # bash script, ported from upstream
  hooks.json                           # Codex hook config at plugin root, uses relative ./hooks/session-start
  skills/
    using-workbench/
      SKILL.md                         # trimmed companion meta-skill
      references/
        using-superpowers-upstream.md  # frozen verbatim copy of upstream using-superpowers/SKILL.md @ v5.0.7
    brainstorming/
      SKILL.md                         # rebranded port
      visual-companion.md              # rebranded port
      spec-document-reviewer-prompt.md # straight copy
      scripts/
        frame-template.html            # rebranded
        helper.js                      # straight copy
        server.cjs                     # straight copy
        start-server.sh                # rebranded paths
        stop-server.sh                 # rebranded paths
```

Both runtimes read the same `skills/` tree. Claude Code reads `hooks/hooks.json` (and ignores the root `hooks.json`). Codex reads the root `hooks.json` (and ignores the nested one). Both invoke the same `hooks/session-start` script, which derives its plugin root from `$0` and works under either runtime.

## File-by-file adaptations from upstream

### `skills/brainstorming/SKILL.md`

* Spec output path: `docs/superpowers/specs/` becomes `docs/workbench/specs/`.
* Terminal handoff text: explicitly invokes `superpowers:writing-plans` (cross-plugin reference, honest about today's dependency). When `writing-plans` is later ported into workbench, this reference flips to `workbench:writing-plans` as part of that port.
* All other content kept verbatim. No tone changes, no workflow changes, no checkpoint changes.

### `skills/brainstorming/scripts/start-server.sh`

* Line 9 comment: `.superpowers/` becomes `.workbench/`.
* Line 81 path: `${PROJECT_DIR}/.superpowers/brainstorm/${SESSION_ID}` becomes `${PROJECT_DIR}/.workbench/brainstorm/${SESSION_ID}`.

### `skills/brainstorming/scripts/stop-server.sh`

* Line 6 comment: `.superpowers/` becomes `.workbench/`.

### `skills/brainstorming/scripts/frame-template.html`

* Line 199: rebrand the page header. The upstream string `Superpowers Brainstorming` linked to `https://github.com/obra/superpowers` becomes `Workbench Brainstorming` linked to `https://github.com/pgoell/pgoell-claude-tools`.

### `skills/brainstorming/visual-companion.md`

* All `.superpowers/brainstorm/` references become `.workbench/brainstorm/`.
* `.gitignore` advice references `.workbench/` instead of `.superpowers/`.

### `skills/brainstorming/spec-document-reviewer-prompt.md`

* Straight copy. No upstream-specific references to fix.

### `skills/brainstorming/scripts/helper.js`, `server.cjs`

* Straight copies. No upstream-specific references to fix.

### `skills/using-workbench/SKILL.md` (new)

Frontmatter:

```yaml
---
name: using-workbench
description: Use when starting any conversation alongside using-superpowers. Announces workbench's currently-shipped skills, defers meta-rules to using-superpowers, and resolves slug collisions in workbench's favor.
---
```

Body covers, in this order:

1. **Relationship to using-superpowers.** Workbench layers on top of upstream superpowers. Meta-rules ("invoke relevant skills before responding," "even 1% relevance is enough," etc.) are owned by `using-superpowers`. This skill does not restate them. If `superpowers` is not installed, see `references/using-superpowers-upstream.md` for the meta-rules in their original form and consider whether to install upstream or to promote that content here.
2. **Workbench skills inventory.** Today: `brainstorming`. As skills are ported, add them here.
3. **Slug collision rule.** When a skill name exists in both workbench and superpowers (today: `brainstorming`), prefer the workbench version. The host agent should resolve the slug `brainstorming` to `workbench:brainstorming`.
4. **Pointer to upstream snapshot.** `references/using-superpowers-upstream.md` holds the full upstream `using-superpowers/SKILL.md` content frozen at v5.0.7. When a new skill is ported into workbench, lift the relevant chunks from that file into this skill's body.

### `skills/using-workbench/references/using-superpowers-upstream.md`

Verbatim copy of upstream `superpowers/skills/using-superpowers/SKILL.md` at v5.0.7. Header note documents the snapshot version, the original path, and the purpose of the file. Used as a source for incremental promotion into the trimmed companion above.

### `hooks/hooks.json` (Claude Code)

Mirrors upstream superpowers' `hooks/hooks.json` exactly, except the rebrand of the script invocation if needed (the script name `run-hook.cmd session-start` stays the same). Schema:

```jsonc
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start",
            "async": false
          }
        ]
      }
    ]
  }
}
```

### `hooks.json` (Codex, plugin root)

```jsonc
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          { "type": "command", "command": "./hooks/session-start" }
        ]
      }
    ]
  }
}
```

The relative path is plugin-root-relative, matching the figma plugin precedent. If Codex does not yet fire SessionStart hooks at runtime, this file sits inert until the runtime enables it. The cost of including it is negligible.

### `hooks/run-hook.cmd`

Verbatim copy of upstream. Generic cross-platform polyglot wrapper with no upstream-specific references.

### `hooks/session-start`

Ported from upstream with these adjustments:

1. **Header comment.** `# SessionStart hook for superpowers plugin` becomes `# SessionStart hook for workbench plugin`.
2. **Drop the legacy-skills-warning block.** The block that checks `${HOME}/.config/superpowers/skills` and builds `warning_message` is upstream-specific (a migration aid for old superpowers users) and not relevant to workbench. Remove the block, the `warning_message` variable, and its later inclusion in `session_context`.
3. **Skill path read.** `${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md` becomes `${PLUGIN_ROOT}/skills/using-workbench/SKILL.md`.
4. **Rebrand `session_context` wrapper text.** The injected wrapper currently reads `<EXTREMELY_IMPORTANT>\nYou have superpowers.\n\n**Below is the full content of your 'superpowers:using-superpowers' skill ...`. Rewrite to reference workbench: e.g. `<EXTREMELY_IMPORTANT>\nYou have workbench skills.\n\n**Below is the full content of your 'workbench:using-workbench' skill ...`.
5. **Variable renames (cosmetic).** `using_superpowers_content` and `using_superpowers_escaped` become `using_workbench_content` and `using_workbench_escaped` for clarity. Functional equivalence preserved.

The platform-detection block at the bottom (Cursor / Claude Code / Copilot CLI / SDK-standard else branch) is kept verbatim. Codex is expected to fall into the SDK-standard `additionalContext` else branch since no `CODEX_PLUGIN_ROOT` env var is documented and the figma plugin precedent uses plugin-root-relative paths without any env-var reference. This is an assumption to verify when Codex hooks are confirmed firing; if Codex needs different output framing, add a `CODEX_PLUGIN_ROOT` (or equivalent) check.

## Marketplace metadata

### `.claude-plugin/plugin.json`

```json
{
  "name": "workbench",
  "version": "0.1.0",
  "description": "Personal fork-as-you-touch skill collection (brainstorming + meta-skill, more to come)",
  "author": { "name": "Pascal Göllner" },
  "license": "MIT",
  "keywords": ["personal", "brainstorming", "design", "specs", "workflow"]
}
```

### `.codex-plugin/plugin.json`

Same fields as Claude manifest plus the Codex-mandated extras per repo `CLAUDE.md`:

```json
{
  "name": "workbench",
  "version": "0.1.0",
  "description": "Personal fork-as-you-touch skill collection (brainstorming + meta-skill, more to come)",
  "author": { "name": "Pascal Göllner" },
  "license": "MIT",
  "keywords": ["personal", "brainstorming", "design", "specs", "workflow"],
  "skills": "./skills/",
  "interface": {
    "displayName": "Workbench",
    "shortDescription": "Personal forks of skills Pascal uses regularly",
    "longDescription": "Personal fork-as-you-touch skill collection. Today: brainstorming (with visual companion) and a meta-skill that layers on top of using-superpowers. More skills will be added as Pascal commits to owning them.",
    "developerName": "Pascal Göllner",
    "category": "Productivity",
    "capabilities": ["Interactive", "Write"],
    "defaultPrompt": [
      "Help me brainstorm a new feature",
      "Turn my idea into a spec",
      "Run the design dialogue for this project"
    ],
    "screenshots": []
  }
}
```

### Marketplace registration

Add a `workbench` entry to both:

* `.claude-plugin/marketplace.json` (Claude Code registry)
* `.agents/plugins/marketplace.json` (Codex registry, with `interface.displayName` and `interface.shortDescription` per repo convention)

## License and attribution

Per the saved memory rule "Preserve upstream license attribution when porting":

* `LICENSE`: MIT, copied verbatim from upstream `superpowers/LICENSE`.
* `NOTICE`: credits upstream Superpowers (Jesse Vincent, https://github.com/obra/superpowers), version 5.0.7, with a link to the upstream LICENSE. Notes the files ported and adapted.
* `README.md`: includes a "Credits" section pointing at upstream and naming the skills derived from it.

## Out of scope today (deferred IOUs)

Tracked for the next porting wave so they do not get lost:

1. **Port `writing-plans` and `executing-plans`.** They are the natural next pair: `writing-plans` is brainstorming's terminal handoff target, and `executing-plans` is `writing-plans`' downstream. When done, the brainstorming SKILL.md flips its terminal reference from `superpowers:writing-plans` to `workbench:writing-plans`, and `using-workbench/SKILL.md` adds them to its inventory.
2. **Port additional superpowers skills as Pascal commits to using them.** Candidates flagged by his actual workflow: `systematic-debugging`, `test-driven-development`, `verification-before-completion`, `using-git-worktrees`. Each is a separate fork decision.
3. **Promote chunks of `using-superpowers-upstream.md` into `using-workbench/SKILL.md`** as more skills land in workbench. The reference file is the source; the skill body is the curated view.
4. **Tests.** Per repo `CLAUDE.md` convention, plugins ship unit tests (skill recognition), skill-triggering tests (auto-trigger via natural prompts), and integration tests where applicable. Today's port deliberately ships without tests so the implementation plan covers a single coherent unit. Tests are tracked as a follow-up before workbench is considered production-ready, not as part of the initial port.
5. **Investigate Codex hook firing.** The figma plugin precedent labels its hook "draft for future plugin hook runtimes." Once Codex hooks are confirmed firing in some version, document the verified-working version in this spec or a follow-up note. If they never fire, the dual-hook layout is harmless.

## Open questions

None at design time. All decisions are explicit above.

## Implementation plan

To be produced by the `superpowers:writing-plans` skill in the next phase. The plan should cover, in roughly this order: scaffold plugin directories, copy upstream files, apply the rebrand edits listed above, write the new `using-workbench` skill, write hook configs for both runtimes, write LICENSE/NOTICE/README, register in both marketplaces, and verify the manifest files parse via the existing repo unit-test runners.
