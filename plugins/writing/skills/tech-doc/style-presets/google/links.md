# Google: Links and cross-references

Source: https://developers.google.com/style/cross-references, https://developers.google.com/style/link-text
Last refreshed: 2026-04-29

## Link text

- Use descriptive link text that tells the reader where they are going.
- Never use "click here", "here", "this link", "this page", "this document", "more", or "learn more" alone as link text.
- The link text should fit naturally into the surrounding sentence without sounding like it was bolted on.
- Avoid using a URL as link text unless the URL itself is the subject being discussed.
- If you must display a URL (for example, in a print context or when showing a resource the reader needs to type), use the bare URL without extra punctuation.
- Don't include "the" as part of link text if the linked item is a proper noun.

Examples:

- Correct: "For details, see [Authentication overview](...)."
- Incorrect: "For details, [click here](...)."
- Incorrect: "See [this page](...) for details."

## Cross-references

- Use "For more information, see [Title](...)" for references to other documents or sections.
- Use "See [Title](...)" when the instruction is embedded in a sentence rather than a standalone call-out.
- Don't use "refer to" as the verb; prefer "see".
- Place cross-references at the end of the relevant section or sentence, not before the content they supplement.
- When referencing a section in the same document, link to the heading anchor: "See [Headings and capitalization](#headings-and-capitalization)."
- Spell out what the reader will find: "For the full list of supported parameters, see [Parameters reference](...)."

## See-also sections

- Use a "What's next" or "See also" section only when you have multiple related resources that don't fit naturally into the body text.
- Place it at the end of the page.
- Format as a bulleted list of links, each with a short descriptive phrase if the title alone is not self-explanatory.
- Don't add a See-also section just to add links; every item should be directly useful to the reader.

## External links

- Link to external resources when they are the authoritative source and the information would be too much to reproduce inline.
- Warn the reader when a link leaves the current site only if leaving is unexpected (for example, linking to a third-party support site from a first-party doc).
- Don't guarantee the accuracy or permanence of external content.
- Avoid deep-linking into pages that reorganize frequently; link to the stable top-level section instead when appropriate.
- No "opens in a new tab" annotations in the text; leave tab behavior to the user and the platform.

## Anchor names

- Use lowercase, hyphen-separated words for anchor IDs: `#authentication-overview`, not `#Authentication_Overview`.
- Derive anchor IDs from the heading text by lowercasing, replacing spaces with hyphens, and stripping punctuation.
- Keep anchors stable. If you rename a heading, add a redirect or alias for the old anchor so inbound links don't break.
- Don't create anchors for every paragraph; anchor headings and named subsections only.

## Link punctuation

- Place sentence-ending punctuation outside the hyperlink: "See [Authentication overview](...)." (period outside the closing parenthesis and bracket).
- Don't include trailing punctuation inside the linked text unless the punctuation is part of the title.
- When a link appears in a list item, follow the same rule: period or other terminal punctuation falls after the closing bracket.
- Parenthetical links follow standard parenthesis punctuation: "(See [Authentication overview](...).)" with the period inside the closing parenthesis.
