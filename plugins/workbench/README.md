# Workbench

Workbench skills for design dialogue, skill routing, and profile driven feature shipping.

## Skills

- `brainstorming`: Turn ideas into clear design decisions.
- `using-workbench`: Load Workbench skill rules and routing.
- `terse-mode`: Explicit session switch for compact token-saving replies.
- `autopilot`: Ship a feature from brainstorm to PR using a project profile.
- `verification-before-completion`: Require fresh verification evidence before completion claims.

## Project profiles

Workbench owns reusable workflow kernels. Projects own local policy through small profile files at `.workbench/<skill>.md`. See [`skills/autopilot/references/profile-schema.md`](skills/autopilot/references/profile-schema.md) for the autopilot schema and [`skills/autopilot/references/example-project-profile.md`](skills/autopilot/references/example-project-profile.md) for examples.

Workbench ships the steps, audit, and invariants. The project profile carries PR behavior, hooks, and audit overrides. Project information that already lives in `CLAUDE.md` or `AGENTS.md` stays there.

## Coexistence

Workbench is designed to run alongside the upstream `superpowers` plugin. When a slug exists in both plugins (today: `brainstorming`), prefer the Workbench version.

The brainstorming skill's terminal handoff currently invokes `superpowers:writing-plans` cross-plugin. When `writing-plans` is later ported into Workbench, that reference will flip.

## Credits

This plugin includes content derived from the Superpowers plugin by Jesse Vincent (https://github.com/obra/superpowers), version 5.0.7, MIT-licensed. See the NOTICE file for the full list of derived files and the LICENSE file for the upstream license text.
