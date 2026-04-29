# House — API reference conventions

Source: Union of Google developer style and Microsoft Writing Style Guide (house synthesis). Conflicts resolved per SOURCES.md: Google wins on code formatting; Microsoft wins on table structure for status codes and required/optional.
Last refreshed: 2026-04-29

## Parameter naming

Google wins.

- REST query parameters and JSON body fields: `snake_case`.
- JavaScript and TypeScript: `camelCase`.
- Python: `snake_case`.
- C# and .NET: `PascalCase` for members, `camelCase` for local parameters.
- PowerShell parameters: `PascalCase` (e.g., `-ResourceGroupName`).
- Spell parameter names exactly as the API or language contract defines them. Use backtick code font for all parameter names in prose.

## Type notation

Google wins on font; Microsoft wins on generic syntax.

- Use backtick code font for all type names: `string`, `boolean`, `integer`, `object`, `array`.
- Generics: follow the notation of the target language — `IList<string>` for C#, `array of string` in REST prose.
- Nullable types: use the language notation (`string?`) in language-specific sections; in REST prose, write "optional `string`".
- When a field accepts multiple types, write "`string` or `integer`" in prose.
- Do not use italics for type names. Reserve italics for placeholder values.

## Required vs optional

Microsoft wins on table structure; Google wins on prose wording.

- In a table: include a "Required" column with "Yes" / "No" values.
- In prose: write "Required." or "Optional." as the first word of the description, then continue.
- Never use symbols (asterisks, daggers, or color) as the sole indicator of required status.
- When all parameters in a section are optional, state it once at the top rather than repeating "Optional." on every row.

## Default values

Google wins on placement; Microsoft wins on label.

- State defaults as "Default: `<value>`." at the end of the parameter description (prose) or in a dedicated "Default" table column.
- Use code font for the default value: "Default: `null`."
- Omit the default sentence entirely when the parameter is required.
- If the default is conditional, state the condition plainly: "Default: `true` when `mode` is `sync`; omitted otherwise."

## Return values and response shape

- Open the return section with a sentence naming the return type and summarizing what it represents.
- Document every top-level field of the response object in a table with "Field", "Type", and "Description" columns.
- For deeply nested types, cross-reference a separate sub-section or type entry rather than inlining all levels.
- For `void` / empty responses, write "Returns an empty response body on success." (Google phrasing).
- For async methods, document the resolved value type and note that the call is asynchronous.
- For paginated responses, call out the continuation token field explicitly and show how to use it in an example.

## Status codes

Microsoft table structure; ascending numeric sort order (Google).

- List codes in ascending numeric order.
- Use a table with columns "HTTP code" and "Description".
- Format the code as `` `200 OK` `` (numeric code plus reason phrase in code font).
- For 4xx and 5xx codes, end the description with a "what to do" sentence.

| HTTP code | Description |
|---|---|
| `200 OK` | The request succeeded. |
| `400 Bad Request` | The request body is malformed or missing required fields. Correct the request and retry. |
| `401 Unauthorized` | The access token is missing or invalid. Acquire a new token and retry. |
| `404 Not Found` | No resource with the given identifier exists. Verify the identifier and retry. |
| `429 Too Many Requests` | Rate limit exceeded. Retry after the interval in the `Retry-After` header. |
| `500 Internal Server Error` | An unexpected server error occurred. Retry after a short delay. |

## Error documentation

- Document each error with: code (in backtick code font), cause, and remediation.
- Use a table for five or more error codes; use a list for fewer.
- State error message strings in code font when they are stable: "`PERMISSION_DENIED`".
- Avoid passive constructions: "The caller lacks permission" not "Permission was denied."
- Example: "`RATE_LIMIT_EXCEEDED` — The request rate exceeded the quota for this project. Wait for the interval in the `Retry-After` header, then retry."

## Deprecation notation

Microsoft label format; Google's alternative-always rule.

- Mark deprecated elements with "[Deprecated]" at the start of the description.
- State the version deprecated and, when known, the planned removal version.
- Always provide a replacement: "[Deprecated as of version 2.0. Use `new_field` instead.]"
- Do not remove deprecated items from the reference until the removal version ships and a migration guide is published.

## Versioning notes

- State availability as "Available in version X.Y and later." (Google phrasing).
- Use "version" (lowercase) in prose; do not use "Version" or "v" except inside code font where the API uses it.
- Do not use "new", "recently added", or "coming soon" without a version number.
- For edition or tier restrictions, state them explicitly: "Available in the Professional tier and higher."
- When behavior differs across versions, document each version's behavior in a versioned note or table.

## Examples

Google wins on block formatting and placeholder style; Microsoft wins on compilation requirement.

- Include at least one complete, runnable example per method or operation.
- Show request and response (or input and output) as separate labeled code blocks.
- Lead with the simplest realistic scenario. Add a second example only for a meaningfully different use case.
- Always compile and test code before publishing.
- Use `UPPERCASE_WITH_UNDERSCORES` placeholders, not angle-bracket style: `API_KEY` not `<your-api-key>`. Explain each placeholder immediately after the block.
- Never include real credentials, tokens, or personal data in examples.
- For long examples, break explanation into numbered steps and interleave code with prose.
- Language coverage: provide examples in every language that has a supported client library. When only one language is shown, prefer the primary audience language.
