# Workbench

Workbench skills for design dialogue, skill routing, and profile driven feature shipping.

## Skills

- `brainstorming`: Turn ideas into clear design decisions.
- `using-workbench`: Load Workbench skill rules and routing.
- `terse-mode`: Explicit session switch for compact token-saving replies.
- `autopilot`: Ship a feature from brainstorm to PR using a project profile.
- `verification-before-completion`: Require fresh verification evidence before completion claims.
- `writing-plans`: Turn approved specs into concrete implementation plans.
- `test-driven-development`: Enforce test-first RED-GREEN-REFACTOR implementation discipline.
- `dispatching-parallel-agents`: Split independent tasks across concurrent agents.
- `subagent-driven-development`: Execute implementation plans with fresh agents and review gates.

## Project profiles

Workbench owns reusable workflow kernels. Projects own local policy through small profile files at `.workbench/<skill>.md`. See [`skills/autopilot/references/profile-schema.md`](skills/autopilot/references/profile-schema.md) for the autopilot schema and [`skills/autopilot/references/example-project-profile.md`](skills/autopilot/references/example-project-profile.md) for examples.

Workbench ships the steps, audit, and invariants. The project profile carries PR behavior, hooks, and audit overrides. Project information that already lives in `CLAUDE.md` or `AGENTS.md` stays there.

## Coexistence

Workbench is designed to run alongside the upstream `superpowers` plugin. When a slug exists in both plugins, prefer the Workbench version.

## Credits

This plugin includes content derived from the Superpowers plugin by Jesse Vincent (https://github.com/obra/superpowers), version 5.0.7, MIT-licensed. See the NOTICE file for the full list of derived files and the LICENSE file for the upstream license text.

This plugin also includes content derived from [`ThariqS/html-effectiveness`](https://github.com/ThariqS/html-effectiveness) at commit `5d64f68`. It provides the 21-file HTML artifact gallery vendored under `skills/crafting-html/references/`. The upstream repository carries no declared license at time of port; the content is vendored under the upstream author's public publishing intent (see `NOTICE` for full attribution). U+2014 and U+2013 codepoints were substituted at port time per this repo's lint convention.
