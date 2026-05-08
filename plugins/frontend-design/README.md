# frontend-design

Generate distinctive, production-grade frontend interfaces that avoid generic AI aesthetics.

The skill guides Claude (and Codex) to:

- Commit to a clear, bold aesthetic direction (brutalist, editorial, retro-futuristic, refined minimalism, etc.)
- Use distinctive typography and cohesive color palettes
- Apply high-impact motion, unexpected layouts, and atmospheric backgrounds
- Avoid the generic AI defaults (Inter on white, purple gradients, cookie-cutter components)

Triggered automatically when the user asks to build a web component, page, or application.

This plugin also exposes `emil-design-eng`, Emil Kowalski's design engineering philosophy: animation discipline, easing curves, component polish, and the invisible details that make UI feel right. It activates when the user asks to review UI craft, choose easing/duration values, build interaction-rich components, or audit motion.

## Usage

```
"Create a dashboard for a music streaming app"
"Build a landing page for an AI security startup"
"Design a settings panel with dark mode"
"Build a portfolio site with a brutalist aesthetic"
```

Claude picks a clear aesthetic direction and writes production code (HTML/CSS/JS, React, Vue, etc.) with meticulous attention to detail.

## Files

| File | Purpose |
|---|---|
| `skills/frontend-design/SKILL.md` | The creative-direction skill body (verbatim from Anthropic upstream) |
| `skills/emil-design-eng/SKILL.md` | Emil Kowalski's design engineering skill (verbatim from upstream, dashes substituted) |
| `LICENSE` | MIT license for original additions |
| `NOTICE` | Per-upstream attribution and license posture |

## Credits

The `frontend-design` skill is derived from Anthropic's [`frontend-design`](https://github.com/anthropics/claude-plugins/tree/main/plugins/frontend-design) plugin by Prithvi Rajasekaran and Alexander Bricken, licensed under Apache 2.0. The `skills/frontend-design/SKILL.md` body is imported verbatim.

The `emil-design-eng` skill is derived from Emil Kowalski's [`skill`](https://github.com/emilkowalski/skill) repository (commit `ecf66bb`), authored by Emil Kowalski. The `skills/emil-design-eng/SKILL.md` body is imported verbatim except em-dashes and en-dashes are substituted per this repo's no-dash lint. The upstream repo carries no declared license at time of port; the content is included under the upstream author's public publishing intent (`npx skills add emilkowalski/skill`). All rights to the original text remain with Emil Kowalski. See `NOTICE` for full attribution.

This plugin is licensed MIT (`LICENSE`) for original additions; preserved upstream content remains under each upstream author's terms.

## Learn More

See Anthropic's [Frontend Aesthetics Cookbook](https://github.com/anthropics/claude-cookbooks/blob/main/coding/prompting_for_frontend_aesthetics.ipynb) for detailed guidance on prompting for high-quality frontend design.
