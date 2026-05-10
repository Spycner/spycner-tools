---
name: crafting-design-systems
description: Use when the user wants to create, edit, or apply a reusable design system (CSS variables, components, images) that themes the HTML output of workbench skills (writing-spec, writing-plans, brainstorming, systematic-debugging, crafting-html) or research:research. Design systems live at project scope (`.workbench/design-systems/<name>/`) or user scope (`~/.claude/workbench/design-systems/<name>/`); the active one is named in `.workbench/config.md` `## Design system`. Absence of config means template defaults render unchanged.
---

# Crafting Design Systems

A design system is a small directory of CSS overrides, optional components, and optional images that themes the HTML output of any workbench HTML-producing skill. The skill itself does not emit HTML; it documents and scaffolds the design systems consumed by the producers.

## When to use this skill

- Creating a new design system (brand palette, typography, components for a project).
- Editing an existing design system.
- Looking up which CSS variables a given template exposes for theming.

## When NOT to use this skill

- Producing a spec, plan, brainstorm, debug report, or research report: use the matching producer skill, which will apply the active design system automatically.
- Authoring a one-off HTML artifact: use `workbench:crafting-html`.
- Designing a UI or a product component: use `frontend-design`.

## Where design systems live

Two scopes, looked up in this order:

1. **Project**: `.workbench/design-systems/<name>/` at the repo root. Project design systems travel with the repo and apply to every contributor cloning it.
2. **User**: `~/.claude/workbench/design-systems/<name>/`. User-scope design systems are personal and cross every project the user works in.

If a name resolves at both scopes, project wins.

## How the active design system is selected

Resolution order (highest precedence first):

1. Per-prompt override. The user names the design system explicitly: `"render this with the brand-2026 design system"`, `"use my personal design system"`, etc.
2. `.workbench/config.md` `## Design system` section, `Name: <design-system-name>` field. Schema documented in `plugins/workbench/skills/autopilot/references/config-schema.md`.
3. No override. Templates render with their built-in styling, unchanged.

If the named design system is not found at either scope, the host agent reports the missing path and falls through to "no override" rather than failing the artifact. Do not fabricate a substitute.

## Directory structure of a design system

For any design system named `<name>`, the directory contains:

```
<name>/
  manifest.md          # required, one-paragraph overview and intended use
  colors.css           # required, :root { ... } CSS variable declarations
  typography.css       # optional, :root { ... } CSS variable declarations for fonts
  components/          # optional, individual HTML snippet files
    <component>.html
  images/              # optional, raw image files
    <image>.<ext>
```

`manifest.md` and `colors.css` are required. The other paths are optional; the host agent simply ignores axes that are absent.

## Per-template variable inventory

Each HTML-producing template declares its own CSS variables in a `:root` block. There is no shared schema. Design systems override whatever variable names match. Inventory of templates and the variables they expose at the time of writing this skill:

| Template (skill) | Variables declared in `:root` |
|---|---|
| `brainstorming` (`brainstorm-summary-template.html`) | `--ivory`, `--slate`, `--clay`, `--oat`, `--olive`, `--gray-100`, `--gray-150`, `--gray-300`, `--gray-500`, `--gray-700`, `--white`, `--serif`, `--sans`, `--mono`, `--radius-sm`, `--radius`, `--radius-lg` |
| `writing-spec` (`spec-template.html`) | `--bg`, `--bg-soft`, `--bg-code`, `--bg-row-alt`, `--bg-row-hover`, `--ink`, `--ink-soft`, `--ink-mute`, `--rule`, `--accent`, `--accent-soft`, `--warn`, `--sans`, `--serif`, `--mono`, `--measure` |
| `writing-plans` (`plan-template.html`) | `--bg`, `--surface`, `--ink`, `--muted`, `--rule`, `--rule-strong`, `--accent`, `--accent-soft`, `--good`, `--good-soft`, `--bad`, `--bad-soft`, `--warn`, `--warn-soft`, `--code-bg`, `--code-ink`, `--sans`, `--mono`, `--r-sm`, `--r-md`, `--r-lg` |
| `systematic-debugging` (`debug-report-template.html`) | `--ivory`, `--slate`, `--clay`, `--oat`, `--olive`, `--rust`, `--amber`, `--gray-100`, `--gray-300`, `--gray-500`, `--gray-700`, `--white`, `--serif`, `--sans`, `--mono`, `--radius-panel`, `--radius-row`, `--border` |
| `research:research` (`research-report-template.html`) | `--ivory`, `--slate`, `--clay`, `--oat`, `--olive`, `--gray-150`, `--gray-300`, `--gray-500`, `--gray-700`, `--serif`, `--sans`, `--mono` |

`crafting-html` ships 21 reference templates with varied styling; theming a `crafting-html` artifact uses the same override mechanism, but the variable surface depends on the chosen reference and is not enumerated here. Inspect the chosen template before authoring.

The bundled `references/starter-colors.css` declares the union of all variables above with the templates' current values, ready for editing.

## Component contract

Each component file is a self-contained HTML fragment (markup plus a scoped `<style>` block). Contract:

- References only CSS variables declared by the active template, or variables the component declares itself in its scoped `<style>`.
- Does not require any external script, font, or image to render.
- Is safe to paste into any artifact body without conflicting with surrounding styles.
- Documents its intended use in an HTML comment at the top of the file.

The host agent reads the component file, optionally adapts copy to the artifact's context, and inlines the snippet into the artifact body.

## How a producer applies the active design system

When a producer skill (writing-spec, writing-plans, brainstorming, systematic-debugging, crafting-html, or research:research) emits HTML:

1. Resolve the active design system name via the chain above.
2. If a name is resolved, locate its directory (project then user scope).
3. Inline the design system's `colors.css` (and optional `typography.css`) into the artifact's `<style>` block, **after** the template's own `:root` declarations, so the design system's variable values win in the cascade.
4. For any component referenced by the artifact, paste the component file's markup and scoped style into the artifact body.
5. For any image referenced by the artifact, base64-encode and inline by default; opt into relative paths only when the artifact and design system co-exist in the same git tree and the artifact will not travel.

If no design system is resolved, skip steps 2 to 5; the artifact emits with the template's baked-in styling.

## Recipe: create a new design system

1. Decide scope:
   - Repo-wide: project scope, target `.workbench/design-systems/<name>/`.
   - Personal across projects: user scope, target `~/.claude/workbench/design-systems/<name>/`.
2. Pick a short, descriptive name (kebab-case): `brand-2026`, `dark-print`, `personal`.
3. Create the directory and copy the starter CSS:

   ```bash
   # project scope example
   NAME=brand-2026
   mkdir -p .workbench/design-systems/$NAME
   cp <path-to-skill>/references/starter-colors.css .workbench/design-systems/$NAME/colors.css
   ```

   `<path-to-skill>` resolves to wherever the skill is installed (Claude Code: `~/.claude/plugins/cache/pgoell-claude-tools/workbench/<version>/skills/crafting-design-systems`).

4. Write `manifest.md`:

   ```markdown
   # <Name>

   <One-paragraph description: who this is for, what palette/style it embodies, when to apply it.>
   ```

5. Edit `colors.css`. Keep variable names; change values. Variables not relevant to your palette can be left as-is (they are no-ops in templates that do not reference them).
6. (Optional) Add `typography.css` with `--serif`, `--sans`, `--mono`, or any other typography variables the templates use. See the example bundled with this skill.
7. (Optional) Add `components/<name>.html` snippets and `images/<name>.<ext>` files.
8. Wire it as the active design system by adding to `.workbench/config.md` (or creating it):

   ```markdown
   ## Design system

   Name: <name>
   ```

9. Verify by running any HTML-producing skill and inspecting the generated artifact.

## Recipe: inline an image as base64

```bash
ENCODED=$(base64 -w 0 path/to/image.png)
echo "<img src=\"data:image/png;base64,$ENCODED\" alt=\"...\">"
```

The host agent runs this when an artifact references an image from the active design system. Use the appropriate MIME type (`image/png`, `image/jpeg`, `image/svg+xml`, `image/webp`) based on the file extension.

For SVG specifically, prefer inlining the SVG markup directly rather than base64-encoding; SVG is text and inlines naturally.

## Bundled examples

- `references/starter-colors.css`: union of every variable declared by the five HTML-producing templates, populated with the templates' current values. Copy this as the starting point for a new `colors.css`.
- `references/example-design-system/`: a fully-populated example design system (manifest, colors, typography) demonstrating the full structure. Read for reference, do not copy as the active system; create your own under `.workbench/design-systems/` or `~/.claude/workbench/design-systems/`.

## Em-dashes and en-dashes

Per project-wide rule, no U+2014 or U+2013 codepoints in this skill's tree, including bundled `references/*.html`, `references/*.css`, and `references/*.md`. HTML entity forms `&mdash;`, `&#8212;`, `&ndash;`, `&#8211;` are permitted in HTML body copy as the escape hatch; CSS files have no equivalent and must avoid both characters entirely.
