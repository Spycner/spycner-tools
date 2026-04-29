# House: Links and cross-references

Sources:
- Google: https://developers.google.com/style/cross-references, https://developers.google.com/style/link-text (CC BY 4.0)
- Microsoft: https://learn.microsoft.com/en-us/style-guide/links-hyperlinks/ (paraphrased)
Merge policy: see SOURCES.md
Last refreshed: 2026-04-29

## Link text

Google and Microsoft agree on the core rule: link text must describe the destination. House adopts both in full.

- Use descriptive link text. The link text must work standalone for readers who navigate by links alone.
- Never use "click here", "here", "this", "this link", "this page", "this article", "more", or "learn more" as the complete link text.
- Match the destination title when possible. Shorten only when the full title is grammatically awkward in context.
- Fit the link naturally into the sentence. Avoid bolted-on phrases like "for more information, click [here](...)."
- Don't use a bare URL as link text in running prose. Bare URLs are acceptable in reference tables and when the URL itself is the subject.

Examples:

- Correct: "For the full parameter list, see [API reference](...)."
- Incorrect: "For more information, [click here](...)."
- Incorrect: "See [this page](...) for details."

## Cross-references

Both guides use "For more information, see [Title]" as the standard pattern. House adopts this and adds one tighter constraint.

- Standalone cross-reference: "For more information, see [Title](...)."
- Inline cross-reference: "see [Title](...)" embedded in a sentence.
- Prefer "see" over "refer to".
- Be specific: tell the reader what they will find. "For the complete syntax, see [Command reference](...)" beats "For more information, see [Command reference](...)."
- Place cross-references after the content they supplement, not before it.
- Same-document references: link to the anchor using the heading text: "See [Supported formats](#supported-formats)."

## See-also sections

Google uses "What's next" or "See also"; Microsoft uses "Related content" or "See also". House standardizes on "Related content" for docs sites and "See also" for embedded reference pages.

- Place at the end of the page, after all body content.
- Format as a bulleted list.
- Add a short descriptive phrase after each link if the title is not self-explanatory.
- Cap at five items. A longer list signals that the article lacks focus.
- Add the section only when you have multiple genuinely useful resources. Don't add it to fill space.

## External links

Both guides permit external links to authoritative, stable sources. House adds a freshness obligation.

- Link externally when the resource is authoritative and reproducing the content inline would be impractical.
- Verify the URL is reachable and accurate before merging.
- Prefer stable top-level or section URLs over deep links that are likely to move.
- Do not imply endorsement of third-party content.
- Do not annotate links with "(external link)" or "opens in a new tab" unless the context makes the distinction genuinely surprising for the reader.
- Flag links to content with known short lifespans (beta docs, versioned release notes) with a brief inline note: "as of version 2.1".

## Anchor names

Both guides agree on lowercase-hyphenated anchors derived from the heading. House treats anchors as a public API.

- Format: lowercase, hyphens between words, no punctuation: `#install-the-extension`.
- Derive from the heading text. Apply the same transformation consistently: lowercase, spaces to hyphens, strip symbols.
- Anchors on published pages are public API. Rename only when necessary. When a heading is renamed, add a redirect or alias for the old anchor so inbound links don't break.
- Anchor headings and named subsections only. Don't create mid-paragraph anchors.

## Link punctuation

Google and Microsoft agree on period placement. House enforces one rule with no exceptions.

- Sentence-ending punctuation falls outside the linked text: "See [Authentication overview](...)." (period after the closing bracket, not inside it).
- Do not include trailing punctuation inside the link unless it is part of the title.
- In bulleted lists, the terminal punctuation follows the closing bracket.
- In parentheticals: "(See [Authentication overview](...).)" where the period is inside the closing parenthesis but outside the link.
