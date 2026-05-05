# Workbench

Personal fork-as-you-touch skill collection.

## Skills

- `brainstorming`: Design dialogue that turns an idea into a spec, with a visual-companion mode for browser-based mockups. Forked from upstream Superpowers and adapted with Workbench-specific paths.
- `using-workbench`: Trimmed meta-skill that announces what Workbench ships and resolves slug collisions in Workbench's favor. Defers core meta-rules to the upstream `using-superpowers` skill.

## Project profiles

Workbench owns reusable agent workflows. Projects own their local policy through small profile files at `.workbench/<skill>.md`. Today this convention is documented for the upcoming `autopilot` skill (PR 2 in the autopilot port); see [`skills/autopilot/references/profile-schema.md`](skills/autopilot/references/profile-schema.md) for the schema and [`skills/autopilot/references/example-project-profile.md`](skills/autopilot/references/example-project-profile.md) for examples.

The split: workbench ships the kernel (steps, audit, invariants); the project profile carries autopilot-specific bits (PR behavior, hooks, audit-table overrides). Project information that already lives in `CLAUDE.md` or `AGENTS.md` is sourced from session context, not duplicated in the profile.

## Coexistence

Workbench is designed to run alongside the upstream `superpowers` plugin. When a slug exists in both plugins (today: `brainstorming`), prefer the Workbench version.

The brainstorming skill's terminal handoff currently invokes `superpowers:writing-plans` cross-plugin. When `writing-plans` is later ported into Workbench, that reference will flip.

## Credits

This plugin includes content derived from the Superpowers plugin by Jesse Vincent (https://github.com/obra/superpowers), version 5.0.7, MIT-licensed. See the NOTICE file for the full list of derived files and the LICENSE file for the upstream license text.
