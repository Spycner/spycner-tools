# Skill scaffolding templates

Boilerplate for new skills in any plugin marketplace. Pick the file matching the artifact you're scaffolding, copy the section out, then fill in `{{handlebars}}` from probe results (see the variable table at the top of `SKILL.md`) and `<placeholder>` from user input. The two intents stay distinguishable on purpose: handlebars are filled at runtime by the convention probes; angle-bracket placeholders are filled by the user.

## Index

- `skill-bodies.md`: three SKILL.md template types: API/CLI wrapper (Tier 1/2/3), workflow, reference.
- `manifests.md`: `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`.
- `marketplace-entries.md`: Claude Code and Codex marketplace entries.
- `index-doc-rows.md`: top-level plugin-index doc rows (skills-table row, per-plugin section, current-plugins table row).
- `tests.md`: unit test scaffold, skill-triggering prompt template, integration test scaffold.
- `bootstrap.md`: minimal frontmatter validator and skill-triggering runner for repos with no test infrastructure (used when Probes 4 and 5 came up empty).
