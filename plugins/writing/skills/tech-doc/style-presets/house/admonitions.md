# House: Admonitions

Source: Union of Google developer style and Microsoft Writing Style Guide (house synthesis)
Last refreshed: 2026-04-28

## Severity tiers

House style uses all five tiers (the Microsoft superset). The Google subset (Note, Caution, Warning) maps cleanly to the same tiers here.

| Tier | When to use | Visual marker |
|------|-------------|---------------|
| Note | Supplementary information that is useful but not required reading. Clarifications, cross-references, reminders. | `> **Note:**` block |
| Tip | Optional advice that makes a task faster or more effective. Best practices and shortcuts. | `> **Tip:**` block |
| Important | Required reading to avoid a misunderstanding or a failure that is not dangerous but costly to recover from. | `> **Important:**` block |
| Caution | An action that could cause data loss, broken state, or other recoverable-but-disruptive harm. | `> **Caution:**` block |
| Warning | An action that could cause irreversible damage, a security breach, or physical harm. Reserve for genuine danger. | `> **Warning:**` block |

## Usage rules

- Use the lowest tier that fits the actual severity. Do not elevate a Note to Important for emphasis.
- Cap admonitions at three per 500 words. Beyond that, restructure the content.
- Prefer one-paragraph admonitions. A second paragraph is acceptable only when the two ideas are inseparable and cannot be condensed.
- Never open a section with a Note (or any admonition). Lead with prose that establishes context, then add the callout.
- Do not stack multiple admonitions back-to-back. If you reach for a second consecutive callout, merge them or move the content into prose.
- Destructive operations described in body text must have a Caution or Warning. This is non-negotiable.
- Avoid Tip inflation: if every other paragraph has a Tip, the tips lose meaning.

## Format

```
> **Note:** Text starts immediately after the label on the same line.
> Continuation lines stay inside the blockquote.
```

- Label is bold, followed by a colon and a single space: `**Note:**`, `**Tip:**`, etc.
- Body starts on the same line as the label (Google convention), not a separate line.
- Do not nest admonitions inside admonitions.
- Do not use admonitions to announce future features or upcoming changes; that belongs in a changelog or release note.

## Tone inside admonitions

Admonitions follow all the same prose rules as the surrounding document:

- Active voice, second person ("you"), present tense.
- No em-dashes or en-dashes.
- No hyphens used as sentence punctuation.
- No pre-announcements of future features.
- One clear point per admonition. If you need to say two things, use two admonitions or prose.
- Concision: if the callout can be one sentence, make it one sentence.
