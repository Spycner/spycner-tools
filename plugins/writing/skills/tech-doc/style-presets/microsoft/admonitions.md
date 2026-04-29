# Microsoft: Admonitions

Source: https://learn.microsoft.com/en-us/style-guide/procedures-instructions/notes-tips-important-cautions-warnings
Last refreshed: 2026-04-28

## Severity tiers

| Tier | When to use | Visual marker |
|------|-------------|---------------|
| Note | Supplementary information that helps the reader understand something but is not required to complete the task. | `> **Note**` block |
| Tip | Optional advice that makes a task faster, easier, or more effective. Best practices and efficiency shortcuts. | `> **Tip**` block |
| Important | Information the reader must know to avoid a misunderstanding or a failure that is not dangerous but would require significant rework. | `> **Important**` block |
| Caution | An action that could cause data loss, an error state, or other moderate harm. The consequence is recoverable but disruptive. | `> **Caution**` block |
| Warning | An action that could cause irreversible damage, a security breach, or physical harm. Use sparingly. | `> **Warning**` block |

## Usage rules

- Use the lowest tier that fits the actual severity.
- Prefer prose over admonitions when the information flows naturally from the surrounding text.
- Do not open a section with an admonition; establish context in prose first.
- Do not stack multiple admonitions consecutively. Merge or move to prose if you find yourself doing this.
- Destructive operations must have a Caution or Warning. This is non-negotiable.
- Avoid Tip overuse; too many tips suggest the UI or flow needs improvement, not more documentation.

## Format

```
> **Note**
>
> Text of the note. Starts on a new line after the label.
```

- Label is bold, on its own line, with no colon: `**Note**`, `**Tip**`, `**Important**`, `**Caution**`, `**Warning**`.
- Body follows on the next blockquote line, separated by a blank blockquote line.
- Prefer one paragraph. A second paragraph is acceptable when the content is tightly related and cannot be condensed.
- Do not nest admonitions.

## Tone inside admonitions

Admonitions follow the same prose rules as the surrounding document:

- Active voice, second person ("you"), present tense.
- No em-dashes or en-dashes.
- No hyphens used as sentence punctuation.
- No announcements of future features or planned changes.
- Be direct: state the risk or tip plainly without hedging.
