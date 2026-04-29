# Google: API reference conventions

Source: https://developers.google.com/style/api-reference-comments, https://developers.google.com/style/code-in-text, https://developers.google.com/style/parameters
Last refreshed: 2026-04-29

## Parameter naming

- REST query parameters and JSON body fields: `snake_case`.
- JavaScript and TypeScript parameters: `camelCase`.
- Python parameters: `snake_case`.
- Proto field names: `snake_case` (proto3 convention).
- Never invent casing that contradicts the language or protocol convention.
- Spell parameter names exactly as they appear in the API; use backtick code font inline.

## Type notation

- Use backtick code font for all type names: `string`, `integer`, `boolean`, `object`, `array`.
- Generic/parameterized types: `array of string`, `map<string, object>`. Follow the notation the language or schema format uses.
- Do not use italics for type names. Reserve italics for placeholders.
- For proto types, use the unqualified name where unambiguous: `Timestamp`, `Duration`.
- When a field accepts multiple types, list each with a vertical bar inside backticks or prose: "`string` or `integer`".

## Required vs optional

- Mark required parameters with "Required." as the first sentence of the description, in plain text (not bold, not a label).
- Mark optional parameters with "Optional." as the first word, then continue the description.
- Do not use symbols (asterisks, daggers) or column headers to convey required/optional status; use the word.
- When all parameters in a table are optional, you may note that at the table level instead of repeating "Optional." on each row.

## Default values

- State defaults as "Default: `<value>`." at the end of the parameter description.
- Use code font for the default value: "Default: `true`."
- If there is no default (the field is required), omit the default sentence entirely.
- If the default depends on a condition, state the condition plainly: "Default: `null` when `mode` is `async`; `0` otherwise."

## Return values and response shape

- Open each return-value section with a description of the response object, not just its type.
- Document every top-level field of the response object, even if its semantics are obvious.
- Use a definition list or table with columns "Field", "Type", and "Description".
- For nested objects, document the parent field, then add a sub-section or sub-table for the child fields.
- For paginated responses, call out the pagination token field explicitly and explain how to use it.
- If the method returns nothing on success, write "Returns an empty response body on success."

## Status codes

- List HTTP status codes in ascending numeric order.
- Format each entry as: `200 OK` followed by a brief summary sentence.
- Add a "Description" or "When returned" sentence after the summary for any non-obvious code.
- Standard success codes need only a summary; error codes always get a cause and remediation sentence.

Example format:

| Code | Summary | When returned |
|---|---|---|
| `200 OK` | Success | Request completed normally. |
| `400 Bad Request` | Invalid parameters | One or more required fields are missing or malformed. |
| `404 Not Found` | Resource missing | No resource with the given `name` exists. |
| `429 Too Many Requests` | Rate limit exceeded | Retry after the interval in the `Retry-After` header. |

## Error documentation

- Document each error code as: code + cause + remediation.
- State the error code first in backtick code font, then a plain-English cause, then what the caller should do.
- Provide the error message string when it is stable; quote it in code font.
- Group related error codes under a sub-heading when there are more than five distinct codes.
- Example: "`PERMISSION_DENIED`: The caller does not have the required IAM role. Grant the `roles/storage.objectViewer` role and retry."

## Deprecation notation

- Mark a deprecated element with a "Deprecated." sentence as the first line of its description.
- State the version in which the element was deprecated and the element's planned removal version if known.
- Always provide an alternative: "Deprecated. Use `new_field` instead."
- Do not remove deprecated elements from the reference without a migration guide.
- If a whole method is deprecated, add a top-level "Deprecated" note before the description section.

## Versioning notes

- State availability with "Available in version X.Y and later." as a sentence in the description.
- For fields added in a patch release, use the full version: "Available in version 2.3.1 and later."
- Do not use vague phrases like "recently added" or "new in this release".
- When a field changes behavior between versions, document each version's behavior separately with the version label.

## Examples

- Place at least one complete, functional example for each method.
- Show request and response as separate code blocks, each preceded by an introductory sentence.
- Use a realistic but non-sensitive payload. Never use real keys, tokens, or personal data.
- Cover the common case first, then add examples for non-obvious options or edge cases.
- Language coverage: provide examples in every language for which a client library exists; if only one language is shown, prefer the language of the primary audience.
- Keep examples short enough to read in one screen. Link to a longer sample in a GitHub repository when the realistic example is necessarily long.
- Do not mix request and response in a single block. Show them as two labeled blocks.
