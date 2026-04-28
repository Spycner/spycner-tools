# Function Reference Schema

Schema for documenting a function, method, or class member. Required fields must be populated; missing values are written as `<unknown>` and surfaced at the throughline gate.

## Required fields

- **Name** (function/method name)
- **Signature** (full signature with types, in code font)
- **Description** (one-paragraph summary, present tense, no future-tense scaffolding)
- **Parameters table** (Name, Type, Required, Description). One row per parameter. If no parameters, omit the table and state "Takes no parameters."
- **Return value** (type and description). If void/none, state explicitly.
- **Examples** (≥1 minimal, ≥1 idiomatic). Code blocks. No placeholder values like "your_data_here"; use realistic-but-generic values.

## Optional fields

- **Exceptions / errors raised** (table: Exception, When raised, How to handle).
- **See also** (cross-references to related functions, conceptual docs, tutorials).
- **Since** (version when introduced).
- **Deprecated** (if applicable: version deprecated, replacement, removal date).

## Output template

```markdown
# `<function-name>`

`<full-signature>`

<one-paragraph description>

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | `<type>` | Yes/No | <description> |

## Returns

`<type>`: <description>

## Exceptions

| Exception | When raised | How to handle |
|-----------|-------------|---------------|
| `<Exception>` | <condition> | <recommendation> |

## Examples

### Minimal

\`\`\`<language>
<minimal example>
\`\`\`

### Idiomatic

\`\`\`<language>
<idiomatic example>
\`\`\`

## See also

- `<related-function>`
- [<related-doc>](<link>)
```
