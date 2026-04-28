# Error Codes Reference Schema

Schema for documenting an error code or error class. May be one error per page (full reference) or a table of many errors (consolidated reference).

## Required fields per error

- **Code** (numeric or string identifier, exact)
- **Message** (the literal message text the system emits)
- **Cause** (one-paragraph explanation of when and why)
- **Resolution** (concrete steps the reader takes to fix it)

## Optional fields

- **Severity** (info, warning, error, critical).
- **Related codes** (similar errors).
- **Since** (version introduced).
- **HTTP status** (if applicable).

## Output template (single error)

```markdown
# Error `<code>`: <short-name>

## Message

\`\`\`
<literal message text>
\`\`\`

## Cause

<one-paragraph explanation>

## Resolution

1. <step>
2. <step>
3. <step>

## Related

- `<related-code>`: <relationship>
```

## Output template (consolidated)

```markdown
# Error reference

| Code | Message | Cause | Resolution |
|------|---------|-------|------------|
| `<code>` | <message> | <cause> | <resolution> |
```
