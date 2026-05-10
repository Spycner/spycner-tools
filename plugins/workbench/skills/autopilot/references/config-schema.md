# Workbench Config Schema

Defines `.workbench/config.md` for projects that want to override per-artifact format defaults and output paths in the workbench skills `writing-spec`, `writing-plans`, `brainstorming`, and `systematic-debugging`.

`research:research` does not consult this file. It uses its own hard-coded default (HTML, `reports/<topic-slug>-<YYYY-MM-DD>/report.html`).

## Discovery (v1)

The four workbench skills look for `.workbench/config.md` in the repo root. Missing file means defaults apply. Empty file is valid.

## Markdown-first stance (no parser)

Headings are conventions, not contracts. Both Claude Code and Codex consume the file as prompt context; there is no parser. Skills extract values section by section. YAML support is deferred until a concrete parser-consuming use case exists, paralleling the autopilot profile schema's stance.

## Schema

```md
# Workbench Config

## Output formats
Specs: <md | html>
Plans: <md | html>
Brainstorm summaries: <md | html>
Debug reports: <md | html>

## Output paths
Specs: <directory path>
Plans: <directory path>
Brainstorm summaries: <directory path>
Debug reports: <directory path>
```

All sections optional. All fields within a section optional.

## Defaults when a section or field is absent

| Field | Default format | Default path |
|---|---|---|
| Specs | md | `docs/specs` |
| Plans | md | `docs/plans` |
| Brainstorm summaries | html | `.workbench/brainstorms` |
| Debug reports | html | `.workbench/debug-reports` |

Filenames within the directory follow `YYYY-MM-DD-<topic>-<artifact>.<ext>`, where `<ext>` is `md` or `html` per resolved format.

## Resolution order

For each artifact, format and path resolve independently.

**Format resolution** (highest precedence first):
1. Per-invocation override in the user's prompt. Phrases like `"an HTML <artifact>"`, `"in markdown"`, `"as a markdown <artifact>"`, `"give me HTML"`, and equivalents are recognized.
2. `.workbench/config.md` `## Output formats` entry for the artifact.
3. Per-skill hard-coded default (table above).

**Path resolution** (highest precedence first):
1. `.workbench/autopilot.md` `## Documentation paths` entry for the artifact (existing convention; specs and plans only today).
2. `.workbench/config.md` `## Output paths` entry for the artifact.
3. Per-skill hard-coded default (table above).

The two resolutions never interact. A user can set `Specs: html` in `config.md` while `autopilot.md` already pins `Specs: docs/architecture/` for paths.

## Relationship to `.workbench/autopilot.md`

`.workbench/autopilot.md` is autopilot-specific (PR behavior, hooks, audit-table overrides, plus existing path convention). `.workbench/config.md` is shared workbench config that applies whenever a workbench skill runs, including outside autopilot. The two files coexist; neither replaces the other.
