# CLI Command Reference Schema

Schema for documenting a single CLI command or subcommand.

## Required fields

- **Name** (command name)
- **Synopsis** (one-line usage with placeholders)
- **Description** (one-paragraph summary)
- **Options** (table: Flag, Argument, Default, Description)
- **Arguments** (table: Name, Required, Description). If none, state explicitly.
- **Exit codes** (table: Code, Meaning). At minimum: 0 (success) and the documented non-zero codes.
- **Examples** (≥1 minimal, ≥1 with options).

## Optional fields

- **See also** (related commands).
- **Environment variables** (table: Name, Description, Default).
- **Files** (config files read or written).
- **Since** (version introduced).

## Output template

```markdown
# `<command-name>`

## Synopsis

\`\`\`
<command> [options] <required-arg> [optional-arg]
\`\`\`

## Description

<one-paragraph description>

## Options

| Flag | Argument | Default | Description |
|------|----------|---------|-------------|
| `--<flag>` | `<TYPE>` | `<value>` | <description> |

## Arguments

| Name | Required | Description |
|------|----------|-------------|
| `<NAME>` | Yes/No | <description> |

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | <meaning> |

## Examples

### Minimal

\`\`\`bash
<command>
\`\`\`

### With options

\`\`\`bash
<command> --flag value
\`\`\`
```
