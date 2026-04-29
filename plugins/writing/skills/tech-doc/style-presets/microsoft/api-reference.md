# Microsoft — API reference conventions

Source: https://learn.microsoft.com/en-us/style-guide/developer-content/api-reference, https://learn.microsoft.com/en-us/style-guide/developer-content/formatting-developer-text-elements
Last refreshed: 2026-04-29

## Parameter naming

- .NET (C#, VB): `PascalCase` for methods and properties; `camelCase` for parameters and local variables.
- REST query parameters and JSON body fields: `camelCase` (follow the API contract exactly).
- PowerShell cmdlet parameters: `PascalCase` with a leading hyphen at the call site: `-ResourceGroupName`.
- Python: `snake_case`.
- Spell parameter names exactly as they appear in the API. Use code formatting (backticks in Markdown) for all parameter names in prose.

## Type notation

- Use code font for type names: `string`, `bool`, `int`, `object`.
- For generic types, follow the notation of the language: `IList<string>`, `Dictionary<string, int>`.
- Nullable types: `string?` (C# notation) or "optional `string`" in prose.
- Prefer the language alias over the runtime type: `string` not `System.String`; `int` not `System.Int32`.
- When a field accepts multiple types, write "`string` or `number`" in prose.

## Required vs optional

- Mark each parameter "Required" or "Optional" in a dedicated column or as the first word of the description.
- In a table, use a "Required" column with "Yes" / "No" values for scannability.
- In a prose description, write "Required." or "Optional." as the first word, then continue.
- Do not rely on formatting (bold, asterisks) alone to convey required status; always use the word.

## Default values

- State defaults as "Default value: `<value>`" in the parameter description or table.
- Use code font for the default value: "Default value: `false`."
- Omit the default sentence when the parameter is required.
- If the default depends on a condition, state it plainly in a follow-on sentence.

## Return values and response shape

- Open the return section with a sentence naming the return type and summarizing what it represents.
- Document every property of the return object. Use a table with "Property", "Type", and "Description" columns.
- For complex nested types, cross-reference the type's own reference entry rather than inlining all fields.
- For `void` / no-return methods, write "This method doesn't return a value."
- For async methods returning a `Task<T>`, document the type `T` unwrapped, and note that the method is asynchronous.
- For paginated REST responses, identify the continuation token field and describe how to use it.

## Status codes

- List HTTP status codes in ascending numeric order.
- Format each entry with the numeric code plus the standard reason phrase in code font, then a description.
- Provide a "What to do" or remediation note for all 4xx and 5xx codes.

Example format:

| HTTP code | Description |
|---|---|
| `200 OK` | The request succeeded. The response body contains the requested resource. |
| `400 Bad Request` | The request body is malformed or missing required properties. Correct the request and retry. |
| `401 Unauthorized` | The access token is missing or invalid. Acquire a new token and retry. |
| `404 Not Found` | The specified resource doesn't exist. Verify the identifier and retry. |
| `500 Internal Server Error` | An unexpected error occurred on the server. Retry after a short delay. |

## Error documentation

- Document each error response with: error code or property, cause, and what the caller should do.
- Use a table when there are many codes; use a list when there are fewer than four.
- State error codes in code font. State messages in quotation marks if they are stable strings.
- Avoid passive constructions: "The server rejected the request because..." not "The request was rejected."
- Example: "`AuthorizationFailed` — The caller doesn't have permission for this operation. Assign the required role and retry."

## Deprecation notation

- Mark deprecated elements with a "[Deprecated]" label at the start of the description.
- State when the element was deprecated and, if known, when it will be removed.
- Always provide a migration path: "[Deprecated as of version 3.0. Use `NewMethod` instead.]"
- For deprecated REST endpoints, include a `Deprecation` header reference if the API surfaces one.
- Do not silently remove deprecated items from documentation before the removal version ships.

## Versioning notes

- State the version in which a feature became available: "Available starting in version 2.1."
- Use "version" (lowercase) not "Version" in prose.
- Do not use "new" or "recently added" without a version number.
- For features available only in specific tiers or editions, note the edition requirement explicitly: "Available in the Standard tier and higher."
- When behavior changes across versions, use a versioned note block or table showing version ranges and behavior.

## Examples

- Include at least one full, runnable example per method or operation.
- Lead with the simplest realistic scenario. Add a second example only for a meaningfully different use case.
- Show request and response (or input and output) as separate, labeled code blocks.
- Always compile and test code before publishing.
- Use C# for .NET APIs as the primary example language. Add other languages when client libraries exist for them.
- Never include real credentials, tokens, or personal information in examples. Use named placeholders: `<your-api-key>`.
- For long examples, break the explanation into numbered steps and interleave code with prose.
