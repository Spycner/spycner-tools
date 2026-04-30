# Microsoft: Links and cross-references

Source: https://learn.microsoft.com/en-us/style-guide/links-hyperlinks/
Last refreshed: 2026-04-29

## Link text

- Write meaningful link text that describes the destination, not the act of clicking.
- Never use "click here", "here", "this", "this article", "this page", or "more information" as the complete link text.
- Link text should work as a standalone label; readers who tab through links should understand each destination from the link text alone.
- Match the link text to the title of the destination page when possible. If the full title is awkward in context, use a shortened but still accurate version.
- Don't use raw URLs as link text in running prose. Bare URLs are acceptable in reference lists where the URL is the point.
- For UI-based docs, describe what the link leads to, not what the user does: "For setup instructions, see [Install the extension](...)" not "Click here to install."

## Cross-references

- Use "For more information, see [Title](...)" as the default pattern for standalone cross-reference sentences.
- Use "see [Title](...)" when the reference is embedded in a sentence.
- Prefer "see" over "refer to".
- Put cross-references after the relevant content, not before it.
- When linking within the same article, use the section heading text as the link text: "see [Supported formats](#supported-formats)."
- Be specific about what the reader will find: "For the complete syntax, see [Command reference](...)" rather than just "For more information, see [Command reference](...)."

## See-also sections

- Use a "Related content" or "See also" section for grouped resources that don't fit in the body.
- Place it at the bottom of the article.
- Use a bulleted list. Add a parenthetical or short phrase after each link if the title is not self-explanatory.
- Keep the list short; five or fewer items is the target. A long list signals that the article lacks focus.
- Don't add the section just to fill space. Each item must be genuinely useful to the reader who finished the article.

## External links

- Link to external sites when they are the authoritative source and the content is stable.
- Verify that the external resource is accessible and accurate before linking.
- Avoid deep links that are likely to rot; prefer stable section or top-level page URLs.
- Don't imply Microsoft endorsement of third-party content.
- Don't add "(external link)" annotations unless the audience would find the distinction surprising; let context carry it.

## Anchor names

- Use lowercase, hyphen-separated words: `#install-the-extension`, not `#InstallTheExtension`.
- Derive from the heading text: lowercase, spaces to hyphens, strip punctuation.
- Treat anchors as a public API: rename them only when necessary, and provide redirects for any published anchor that changes.
- Anchor headings and named subsections; avoid mid-paragraph anchors.

## Link punctuation

- Punctuation that ends the sentence falls outside the linked text: "See [Set up authentication](...)." (period after the closing bracket).
- Don't include punctuation inside the link unless it is part of the title.
- In bulleted lists, the period or other terminal mark follows the closing bracket, not inside it.
- Parenthetical: close the link before closing the parenthesis: "(See [Set up authentication](...).)"
