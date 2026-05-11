# playground

Generate interactive single-file HTML playgrounds: control panel + live preview + copy-out prompt.

A playground is a self-contained HTML file with controls on one side, a live preview on the other, and a generated prompt at the bottom that the user copies back into Claude. Useful when the input space is large, visual, or structural and hard to express as plain text.

## Usage

```
"Use the playground skill to tweak my button component's hover and shadow"
"Build me an interactive SQL query builder I can paste back to Claude"
"Show me the email-agent architecture as an interactive diagram I can comment on"
"Help me balance the 'Inferno' hero's deck"
```

The host agent picks the closest template, writes the HTML file, opens it in the user's default browser, and lets the user iterate until they copy the generated prompt back into the conversation.

## Templates

The skill bundles six template files at `skills/playground/templates/`:

- `design-playground.md`: visual design decisions (components, layouts, spacing, color, typography)
- `data-explorer.md`: data and query building (SQL, APIs, pipelines, regex)
- `concept-map.md`: learning and exploration (concept maps, knowledge gaps, scope mapping)
- `document-critique.md`: document review (suggestions with approve/reject/comment workflow)
- `diff-review.md`: code review (git diffs, commits, PRs with line-by-line commenting)
- `code-map.md`: codebase architecture (component relationships, data flow, layer diagrams)

If the user's topic does not fit a template cleanly, the skill picks the closest one and adapts.

## Files

| File | Purpose |
|---|---|
| `skills/playground/SKILL.md` | The playground skill body (verbatim from Anthropic upstream) |
| `skills/playground/templates/*.md` | Six template files referenced by SKILL.md |
| `LICENSE` | MIT license for original additions |
| `NOTICE` | Per-upstream attribution and license posture |

## Credits

Derived from Anthropic's [`playground`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/playground) plugin (commit `aecd4c852f10b466245f18383fa6aad8c0b10d57`), licensed under Apache 2.0. The skill body and template files are imported verbatim with em-dashes and en-dashes substituted to satisfy this marketplace's punctuation lint. See `NOTICE` for full attribution and the substitution rules.
