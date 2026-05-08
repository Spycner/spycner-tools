# frontend-design

Generate distinctive, production-grade frontend interfaces that avoid generic AI aesthetics.

The skill guides Claude (and Codex) to:

- Commit to a clear, bold aesthetic direction (brutalist, editorial, retro-futuristic, refined minimalism, etc.)
- Use distinctive typography and cohesive color palettes
- Apply high-impact motion, unexpected layouts, and atmospheric backgrounds
- Avoid the generic AI defaults (Inter on white, purple gradients, cookie-cutter components)

Triggered automatically when the user asks to build a web component, page, or application.

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
| `skills/frontend-design/SKILL.md` | The skill body (verbatim from upstream) |
| `LICENSE` | MIT license for original additions |
| `NOTICE` | Apache 2.0 attribution for upstream content |

## Credits

The `frontend-design` skill is derived from Anthropic's [`frontend-design`](https://github.com/anthropics/claude-plugins/tree/main/plugins/frontend-design) plugin by Prithvi Rajasekaran and Alexander Bricken, licensed under Apache 2.0. The `skills/frontend-design/SKILL.md` body is imported verbatim. See `NOTICE` for full attribution.

This plugin is licensed MIT (`LICENSE`).

## Learn More

See Anthropic's [Frontend Aesthetics Cookbook](https://github.com/anthropics/claude-cookbooks/blob/main/coding/prompting_for_frontend_aesthetics.ipynb) for detailed guidance on prompting for high-quality frontend design.
