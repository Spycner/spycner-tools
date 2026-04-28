# REST Endpoint Reference Schema

Schema for documenting a single REST API endpoint.

## Required fields

- **Method** (GET, POST, PUT, PATCH, DELETE, etc.)
- **Path** (with path parameters as `{param}`)
- **Description** (one-paragraph summary)
- **Path parameters** (table: Name, Type, Description). If none, omit.
- **Query parameters** (table: Name, Type, Required, Default, Description). If none, omit.
- **Request body** (schema or "No body"). If schema, JSON or YAML example.
- **Response body** (schema). JSON or YAML example.
- **Status codes** (table: Code, Meaning). At minimum the documented non-2xx codes.

## Optional fields

- **Headers** (table: Name, Required, Description). Only document custom or required headers.
- **Authentication** (one-line: how to authenticate).
- **Rate limits** (per-minute, per-hour, etc.).
- **Examples** (curl, language-specific clients).
- **Since** (version introduced).

## Output template

```markdown
# `<METHOD> <path>`

<one-paragraph description>

## Authentication

<auth scheme>

## Path parameters

| Name | Type | Description |
|------|------|-------------|
| `<name>` | `<type>` | <description> |

## Query parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `<name>` | `<type>` | Yes/No | `<default>` | <description> |

## Request body

\`\`\`json
{
  "<field>": "<value>"
}
\`\`\`

## Response body

\`\`\`json
{
  "<field>": "<value>"
}
\`\`\`

## Status codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 4xx | <meaning> |

## Example

\`\`\`bash
curl -X <METHOD> '<base-url><path>' \
  -H 'Authorization: Bearer <TOKEN>' \
  -d '<body>'
\`\`\`
```
