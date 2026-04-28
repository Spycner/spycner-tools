# Configuration Reference Schema

Schema for documenting a configuration option, environment variable, or settings field.

## Required fields

- **Name** (key/variable name, exact)
- **Type** (string, integer, boolean, list, object, etc.)
- **Default** (value or "no default")
- **Description** (what it controls)
- **Allowed values** (enum list, range, regex, or "any <type>")

## Optional fields

- **Example** (one or more concrete values).
- **Required** (Yes/No, if applicable to context).
- **Effect when changed** (does the service restart? hot-reload?).
- **Related** (other config keys that interact).
- **Since** (version introduced).
- **Deprecated** (if applicable).

## Output template

```markdown
# `<config-key>`

| Field | Value |
|-------|-------|
| Type | `<type>` |
| Default | `<default>` |
| Required | Yes/No |
| Allowed values | <enum or range> |
| Since | `<version>` |

## Description

<one-paragraph description>

## Example

\`\`\`<format>
<config-key>: <example-value>
\`\`\`

## Effect when changed

<does service restart, hot-reload, etc.>

## Related

- `<related-key>`: <relationship>
```
