# Workbench Autopilot Profile

## Project name
pgoell-claude-tools

## Branching
Default branch: master
Branch prefixes: feat, fix, docs, chore, refactor, test, perf, style, ci, build, revert

## Commands
Task runner: bash
Lint: tests/unit/test-skill-frontmatter-yaml.sh

## Documentation paths
Specs: don't commit
Plans: don't commit

## PR behavior
Mode: stop_at_green
Base branch: master
Squash: yes

## Project-specific rules

Use `uv` instead of direct `python` commands.
Do not duplicate skill directories between Claude Code and Codex. Runtime metadata must point at the same `skills` directory.
