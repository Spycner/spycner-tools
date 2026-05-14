---
name: crafting-presentations
description: Use when the user wants to build a multi-slide HTML presentation with slide-type templates, a deck-stage engine, and an optional two-window presenter view for live sharing in Teams, Zoom, or Meet. For one-off single-file slide artifacts, see workbench:crafting-html. For brand theming, see workbench:crafting-design-systems.
---

# Crafting Presentations

Multi-slide HTML decks with deck-stage navigation, slide-type composition, and a two-window presenter mode. Bundles a complete example deck (Deloitte x Databricks Alliance) under `references/`.

## When to use this skill

Reach for `crafting-presentations` when the deck is more than two or three slides, when speaker notes will be presented live, or when the user wants a presenter-view sidecar window during a Teams, Zoom, or Meet share. For a quick one-off single-file slide deck without presenter mode, use `workbench:crafting-html` and its `references/09-slide-deck.html` template. For theming a deck to a brand, layer `workbench:crafting-design-systems` on top of this skill.

## The stage

Every slide is a `<section>` inside a `<deck-stage>` custom element. The authored canvas is 1920 x 1080 (16:9). `deck-stage.js` fits the canvas to the viewport via CSS transform scaling, so the deck looks the same in a 4K display and in a Zoom share. Slides are addressed by index (1-based on the URL hash, e.g. `#3`) and by `data-screen-label` for the agenda strip.

Layout grammar:

- Outer padding 80 to 120 pixels. The empty space is part of the brand.
- 12-column grid with 32-pixel gutters as a soft guide.
- One idea per slide. If you need three, make three slides.
- Footer band on every non-title slide, with a brand wordmark left and slide number right.

## Slide-type catalog

| Type | When to reach for it | Reference |
|---|---|---|
| Title | Cover / hero, opens the deck. Contains the deck title, subtitle, and a meta row (audience, date, version). | `references/deloitte-databricks-alliance/slides/TitleSlide.html` |
| SectionDivider | Major chapter break inside a long deck. Dark variant by default for visual rhythm. | `references/deloitte-databricks-alliance/slides/SectionDivider.html` |
| AgendaSlide | Multi-item list with an optional "current" highlight as the deck progresses. | `references/deloitte-databricks-alliance/slides/AgendaSlide.html` |
| ContentSlide | Two-column layout, a lede on top and supporting points below. The workhorse content slide. | `references/deloitte-databricks-alliance/slides/ContentSlide.html` |
| StatSlide | One or more hero numbers with captions. Use when the number IS the message. | `references/deloitte-databricks-alliance/slides/StatSlide.html` |
| CapabilitiesSlide | Three or four feature cards with icon, headline, body. | `references/deloitte-databricks-alliance/slides/CapabilitiesSlide.html` |
| ComparisonSlide | Side-by-side "before / after" or "us / them" two-column compare. | `references/deloitte-databricks-alliance/slides/ComparisonSlide.html` |
| QuoteSlide | Pull quote with attribution; clean dark background. | `references/deloitte-databricks-alliance/slides/QuoteSlide.html` |
| TimelineSlide | Linear sequence with phase labels and milestones. | `references/deloitte-databricks-alliance/slides/TimelineSlide.html` |
| ClosingSlide | Call to action, contact, next steps; mirrors the title slide visually. | `references/deloitte-databricks-alliance/slides/ClosingSlide.html` |

## Composing the deck

Use `references/deloitte-databricks-alliance/slides/index.html` as the canonical starting point. It composes all ten slide types in one HTML file with `<deck-stage>` wrapping them. Adapt the content to the user's topic; do not move slides between the `<deck-stage>` and the page body, the deck-stage element drives scaling and navigation.

## Speaker notes

Speaker notes live in a JSON island inside the deck HTML:

```html
<script type="application/json" id="speaker-notes">
{
  "1": "Open with the value prop. Twenty seconds.",
  "2": "Set up the section: what we are about to cover."
}
</script>
```

Keys match the 1-based slide index. `presenter.js` reads this block and renders it in the presenter window. A slide without a notes entry shows "No notes for this slide" in presenter view.

## Presenter mode

Open the deck in Edge, Chrome, or Arc. Keys (from the deck window):

- `P` opens the presenter window. Allow the popup once.
- `B` blacks out the audience screen. Press again to resume.
- Arrow keys, Space, Home, End, click move both windows.

Keys (from the presenter window):

- `T` resets the timer.
- `.` or `K` blacks out the presenter view itself.

Sync uses `BroadcastChannel`, same-origin, no server required.

Sharing in Teams, Zoom, or Meet: open the deck, press `P`, then pick **Share to Window** and select the deck window only. Never **Share screen**, or the presenter notes leak. The presenter window is invisible to the audience even though it is on the same machine.

## Single-file vs multi-file output

Multi-file is the default. Keep the upstream layout: `slides/index.html` plus `slides/slides.css` plus `slides/deck-stage.js` plus `slides/presenter.js` plus `assets/*.svg`. This is the right shape for a deck that lives in a repo and benefits from editability.

Single-file is the right call when the deck must travel as one attachment (email, Teams DM, archive). Inline `slides.css`, `deck-stage.js`, `presenter.js` into the head of a single HTML file. Replace `<img src="../assets/...">` with `<svg>` markup inline (the SVGs are small text). The presenter window cannot run in single-file mode unless the file is served over HTTP, because `BroadcastChannel` requires same-origin.

## Applying a design system

Before emitting HTML, check for an active design system and inline its overrides into the deck's style:

1. Resolve the design-system name: per-prompt override (e.g., "render with the `brand-2026` design system"), then `.workbench/config.md` `## Design system` `Name:`, then no override.
2. Locate the directory: `.workbench/design-systems/<name>/` (project scope), then `~/.claude/workbench/design-systems/<name>/` (user scope). If a name resolves but no directory is found at either scope, report the missing path to the user and emit with the bundled defaults; do not fabricate a substitute.
3. Inline `colors.css` (and `typography.css` if present) into the deck's `<head>` as a `<style>` block AFTER the bundled `colors_and_type.css` link or inline. This makes the design system's values win the cascade.
4. For any referenced component, paste `components/<name>.html` markup and scoped style into the deck slide where it belongs.
5. For any referenced image, base64-encode (`base64 -w 0 <file>`) and inline as `data:image/<type>;base64,<payload>`. SVG is text and can be inlined directly. Use relative paths only when the deck and the design system co-exist in the same git tree and the deck will not travel.

To create or edit a design system, see `workbench:crafting-design-systems`.

## CSS variable surface

The bundled `references/deloitte-databricks-alliance/colors_and_type.css` and `references/deloitte-databricks-alliance/slides/slides.css` declare the `:root` variables the deck reads. The full inventory is documented in `workbench:crafting-design-systems` under its per-template variable inventory section. Override any subset via your design system's `colors.css` and `typography.css`.

## Cross-references

- `workbench:crafting-html` is the catch-all for non-presentation HTML artifacts and ships a simpler single-file `09-slide-deck.html` for quick one-off decks.
- `workbench:crafting-design-systems` is the theming layer. It supplies the CSS variable overrides this skill consumes.
- `workbench:writing-spec`, `workbench:writing-plans`, `workbench:brainstorming`, `workbench:systematic-debugging`, and `research:research` are the other HTML producers in the wider plugin family, each with their own artifact shape.

## Caveats

- The bundled deck loads Lucide icons from `https://unpkg.com/lucide@latest`. The deck breaks offline. If the deck must run offline, vendor Lucide into the slides directory and update the script reference.
- The bundled logos are stylized recreations of the Deloitte and Databricks wordmarks, not the official assets. Replace from the user's brand portal before any external-facing use. The bundled `README.md` documents this clearly.
- The bundled `slides.css` uses DM Sans via Google Fonts. Vendoring `.woff2` or swapping for the user's licensed typeface is the right call for production decks.
