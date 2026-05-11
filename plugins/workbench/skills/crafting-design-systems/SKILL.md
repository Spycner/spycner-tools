---
name: crafting-design-systems
description: Use when the user wants to create or edit a workbench design system, a directory of CSS variable overrides, optional components, and optional images that themes HTML output from workbench producer skills.
---

# Crafting Design Systems

Create or edit a design system that themes HTML output from workbench producer skills. Producers (`writing-spec`, `writing-plans`, `brainstorming`, `systematic-debugging`, `crafting-html`, `research:research`) apply the active design system on their own; this skill is for authoring the design system itself.

## When to use this skill

- Create a new design system at project or user scope.
- Edit an existing design system.

## When NOT to use this skill

- Producing any HTML artifact: the producer skill applies the active design system on its own.
- Designing a UI or product component: use `frontend-design`.

## Steps

1. **Pick scope.** Project (`.workbench/design-systems/<name>/` at repo root) for repo-wide themes that travel with the codebase. User (`~/.claude/workbench/design-systems/<name>/`) for personal themes that cross every project. Project wins if the same name exists at both scopes.
2. **Pick a kebab-case name.** Examples: `brand-2026`, `dark-print`, `personal`.
3. **Create the directory and copy the starter CSS:**

   ```bash
   NAME=<your-name>
   DSDIR=.workbench/design-systems/$NAME   # or ~/.claude/workbench/design-systems/$NAME
   mkdir -p "$DSDIR"
   cp <path-to-skill>/references/starter-colors.css "$DSDIR/colors.css"
   ```

   `<path-to-skill>` resolves to wherever the skill is installed (Claude Code: `~/.claude/plugins/cache/pgoell-claude-tools/workbench/<version>/skills/crafting-design-systems`).

4. **Edit `colors.css`.** Keep variable names; change values. Variables a producer's template does not reference are silently ignored at render time, so the union starter is safe to ship even when targeting one producer.
5. **Write `manifest.md`** (one paragraph: who this is for, what palette/style it embodies):

   ```markdown
   # <Name>

   <One-paragraph description.>
   ```

6. **(Optional) Add `typography.css`** with `:root { --serif: ...; --sans: ...; --mono: ...; }` overrides. Producers inline this file after `colors.css` if present.
7. **(Optional) Add `components/<name>.html` snippets.** Each is a self-contained HTML fragment (markup plus scoped `<style>` block). Contract: references only CSS variables declared by the active producer's template or variables the component declares itself; no external scripts, fonts, or images; safe to paste into any artifact body. Document the intended use in an HTML comment at the top of the file.
8. **(Optional) Add `images/<name>.<ext>`** for logos, illustrations, photographs. Producers base64-encode and inline by default. SVG is text and inlines naturally.
9. **Wire it as the active design system.** Add to `.workbench/config.md` (or create the file):

   ```markdown
   ## Design system

   Name: <name>
   ```

   Per-prompt overrides ("render with the `<name>` design system") work without editing config.

10. **Verify.** Run any producer skill (e.g., ask for a brainstorm summary) and inspect the generated HTML. Check that the design system's variable values appear in the `<style>` block after the template's own `:root`.

## Directory shape

```
<name>/
  manifest.md          # required
  colors.css           # required, :root { ... } CSS variable declarations
  typography.css       # optional, :root { ... } font stack overrides
  components/          # optional
    <component>.html
  images/              # optional
    <image>.<ext>
```

## Per-template variable inventory

When editing `colors.css`, knowing which variables each producer template declares helps you decide what to override. The starter file declares the union; this table shows which variables each template actually consults.

| Producer template | Variables declared in `:root` |
|---|---|
| `brainstorming` | `--ivory`, `--slate`, `--clay`, `--oat`, `--olive`, `--gray-100`, `--gray-150`, `--gray-300`, `--gray-500`, `--gray-700`, `--white`, `--serif`, `--sans`, `--mono`, `--radius-sm`, `--radius`, `--radius-lg` |
| `writing-spec` | `--bg`, `--bg-soft`, `--bg-code`, `--bg-row-alt`, `--bg-row-hover`, `--ink`, `--ink-soft`, `--ink-mute`, `--rule`, `--accent`, `--accent-soft`, `--warn`, `--sans`, `--serif`, `--mono`, `--measure` |
| `writing-plans` | `--bg`, `--surface`, `--ink`, `--muted`, `--rule`, `--rule-strong`, `--accent`, `--accent-soft`, `--good`, `--good-soft`, `--bad`, `--bad-soft`, `--warn`, `--warn-soft`, `--code-bg`, `--code-ink`, `--sans`, `--mono`, `--r-sm`, `--r-md`, `--r-lg` |
| `systematic-debugging` | `--ivory`, `--slate`, `--clay`, `--oat`, `--olive`, `--rust`, `--amber`, `--gray-100`, `--gray-300`, `--gray-500`, `--gray-700`, `--white`, `--serif`, `--sans`, `--mono`, `--radius-panel`, `--radius-row`, `--border` |
| `research:research` | `--ivory`, `--slate`, `--clay`, `--oat`, `--olive`, `--gray-150`, `--gray-300`, `--gray-500`, `--gray-700`, `--serif`, `--sans`, `--mono` |

`crafting-html` ships 21 templates with varied styling; inspect the chosen reference before authoring overrides for that producer.

## Bundled

- `references/starter-colors.css`: union of every variable above, populated with the templates' current values. Copy as the starting point for `colors.css`.
- `references/example-design-system/`: a fully-populated twilight example (`manifest.md`, `colors.css`, `typography.css`). Read for shape reference; do not copy as the active system.

## No em-dashes / en-dashes

Per repo rule, no U+2014 or U+2013 codepoints in this skill's tree, including bundled `references/*.css` and `references/*.md`. In HTML body copy, entity forms `&mdash;`, `&#8212;`, `&ndash;`, `&#8211;` are permitted.
