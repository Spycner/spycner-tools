# Google: Admonitions

Source: https://developers.google.com/style/admonitions
Last refreshed: 2026-04-28

## Severity tiers

Google uses three tiers. Tip and Important are not part of this style.

| Tier | When to use | Visual marker |
|------|-------------|---------------|
| Note | Supplementary information that is useful but not required reading. Clarifications, reminders, cross-references. | `> **Note:**` block |
| Caution | An action that could produce unexpected or undesirable results. Recoverable but potentially disruptive. | `> **Caution:**` block |
| Warning | An action that could cause irreversible damage, data loss, security exposure, or hardware harm. | `> **Warning:**` block |

## Usage rules

- Use the lowest tier that accurately fits. Reserve Warning for genuinely irreversible or dangerous situations.
- Limit admonitions to roughly one per 500 words. Overuse dilutes their signal value.
- Do not open a section with a Note; lead with prose that establishes context first.
- Destructive operations described in body text must be accompanied by a Caution or Warning.
- Each admonition should make a single point. Split multi-point callouts into separate admonitions or move content into prose.

## Format

```
> **Note:** Text starts immediately after the label on the same line.
> Continuation lines stay inside the blockquote.
```

- Label is bold, followed by a colon and a single space: `**Note:**`, `**Caution:**`, `**Warning:**`.
- Keep admonitions to one paragraph. A second paragraph is allowed only when the information genuinely cannot be condensed.
- Do not nest admonitions inside admonitions.
- Do not use admonitions to announce future features or upcoming changes.

## Tone inside admonitions

Admonitions follow the same prose rules as the surrounding document:

- Active voice, present tense.
- No em-dashes or en-dashes.
- No hyphens used as sentence punctuation.
- No pre-announcements of future features.
- Sentence-level concision: if the warning can be one sentence, make it one sentence.
