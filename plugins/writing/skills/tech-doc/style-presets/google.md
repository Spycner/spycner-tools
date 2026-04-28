# Google Developer Documentation Style Guide (curated subset)

Source: https://developers.google.com/style. CC BY 4.0. This is a curated subset for use by the tech-doc skill, not the full guide. When in doubt, defer to the source.

## Voice and tone

- Be conversational and friendly without being frivolous.
- Write for a global audience.
- Don't pre-announce upcoming features.

## Person

- Use second person ("you") rather than first-person plural ("we").
- Use "you" to address the reader directly.

## Voice and tense

- Use active voice. Make clear who's performing the action.
- Use present tense for timeless documentation.

## Sentence structure

- Put conditions before instructions, not after.
- Example: "On Linux, run X" not "Run X if you're on Linux."

## Headings and capitalization

- Use sentence case for document titles and section headings.
- Use descriptive headings that work as scannable signposts.

## Punctuation

- Use serial (Oxford) commas.
- Use standard American spelling and punctuation.

## Lists

- Numbered lists for sequences (steps).
- Bulleted lists for most other lists.
- Description lists for pairs of related data.

## Code samples

- Put code-related text in code font (backticks in prose, fenced blocks for samples).
- Use placeholder syntax `<UPPERCASE>` for variables the reader must replace.
- Examples should be runnable, idiomatic, and minimal.

## UI elements

- Put UI element names in bold.

## Accessibility

- Provide alt text for all images.
- Use descriptive link text (not "click here", not "this link").
- Don't rely on color alone to convey information.
- Provide high-resolution or vector images where practical.

## Inclusive language

- Replace legacy terms: "blacklist" → "blocklist", "whitelist" → "allowlist", "master/slave" → "primary/secondary" or "leader/follower", "sanity check" → "validation check".
- Avoid gendered language. Use "they" as a singular pronoun.
- Avoid ableist metaphors ("crazy", "insane", "blind to").

## Dates

- Use unambiguous date formatting. Prefer ISO format (YYYY-MM-DD) or spelled-out month (January 5, 2026).

## Future features

- Don't document features that don't exist yet.
- Don't use phrases like "soon", "in a future release", "we plan to", "coming", "will be supported".
- The exception: descriptive future tense ("the function will return X") is acceptable when describing runtime behavior, not roadmap intent.
