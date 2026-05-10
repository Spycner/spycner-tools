---
name: crafting-html
description: Use when producing a standalone HTML artifact that is not already covered by another workbench skill (writing-spec, writing-plans, brainstorming, systematic-debugging) or by research:research. Covers PR walkthroughs, code explainers, slide decks, status and incident reports, design prototypes, SVG illustrations, custom editing interfaces, and similar single-file HTML outputs. Bundles 20 reference examples plus an index file (21 files total) for inspiration; read individual files lazily, not all at once.
---

# Crafting HTML Artifacts

HTML is the right medium for share-once expository content. It carries information density that markdown cannot match (tables with design, SVG diagrams, color-coded annotations, syntax-highlighted code blocks, expandable sections, mobile-responsive layout), it shares as a link without rendering tools, and it supports two-way interaction (sliders, copy-as-prompt buttons, drag-and-drop editors). Markdown's editability advantage does not apply to artifacts the reader does not edit.

This skill differs from `frontend-design`. `frontend-design` builds UI and components, where the artifact is part of a product. This skill produces single-file expository HTML documents, where the artifact is a communication.

## When NOT to use this skill

- Specs: use `workbench:writing-spec`.
- Plans: use `workbench:writing-plans`.
- Brainstorm summaries: use `workbench:brainstorming`.
- Debug reports: use `workbench:systematic-debugging`.
- Research reports: use `research:research`.
- UI or component code: use `frontend-design`.

## Five categories of HTML artifacts

| Category | Reference files |
|---|---|
| Specs, planning, exploration | `references/01-exploration-code-approaches.html`, `references/02-exploration-visual-designs.html`, `references/16-implementation-plan.html` |
| Code review and understanding | `references/03-code-review-pr.html`, `references/04-code-understanding.html`, `references/17-pr-writeup.html` |
| Design and prototypes | `references/05-design-system.html`, `references/06-component-variants.html`, `references/07-prototype-animation.html`, `references/08-prototype-interaction.html` |
| Reports, research, learning | `references/09-slide-deck.html`, `references/10-svg-illustrations.html`, `references/11-status-report.html`, `references/12-incident-report.html`, `references/13-flowchart-diagram.html`, `references/14-research-feature-explainer.html`, `references/15-research-concept-explainer.html` |
| Custom editing interfaces | `references/18-editor-triage-board.html`, `references/19-editor-feature-flags.html`, `references/20-editor-prompt-tuner.html` |

`references/index.html` is the upstream's gallery index page, kept as the 21st file for reference; it is not assigned to a category.

## Universal patterns

- Single-file HTML5; no external dependencies.
- Inline `<style>` block; no separate CSS files or CDN imports.
- Mobile-responsive viewport meta tag; layout works at narrow widths.
- Semantic HTML (`<section>`, `<article>`, `<nav>`, `<aside>`, `<figure>`).
- Inline `<svg>` for diagrams.
- For two-way interaction, include copy-link or copy-as-prompt buttons.
- No U+2014 or U+2013 codepoints in body copy. HTML entity forms (`&mdash;`, `&#8212;`, `&ndash;`, `&#8211;`) are permitted.
- Realistic placeholder content; do not leave `Lorem ipsum` or empty sections.

## How to use the references

Read one reference file matching the artifact type before generating. Do not load all 21 references; each is self-contained and roughly 10 to 25 KB. The category map above is the index. The host agent reads `references/<file>.html` on demand, not proactively.

## Output Format

When emitting HTML, also apply the active design system per `workbench:crafting-design-systems`. Resolution order: per-prompt override, then `.workbench/config.md` `## Design system` `Name:`, then no override (template defaults).
