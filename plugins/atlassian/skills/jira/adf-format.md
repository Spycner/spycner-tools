# Atlassian Document Format (ADF) Reference

## When ADF Is Needed

ADF is required **only** for curl-based Jira REST API write operations:

- **Create issue** (`POST /rest/api/3/issue`) — the `description` field
- **Add comment** (`POST /rest/api/3/issue/{key}/comment`) — the `body` field
- **Update description** (`PUT /rest/api/3/issue/{key}`) — the `description` field inside `fields`

ADF is **not needed** when using `acli`. The CLI accepts plain text directly.

## Document Envelope

Every ADF value is wrapped in a top-level `doc` node:

```json
{
  "version": 1,
  "type": "doc",
  "content": []
}
```

All node types described below go inside the `content` array.

---

## Node Types

### Paragraph

The most basic block node. Contains inline content (text, links, mentions).

```json
{
  "type": "paragraph",
  "content": [
    {
      "type": "text",
      "text": "This is a simple paragraph."
    }
  ]
}
```

### Heading

Headings use levels 1 through 6 via the `level` attribute.

```json
{
  "type": "heading",
  "attrs": {
    "level": 2
  },
  "content": [
    {
      "type": "text",
      "text": "Section Title"
    }
  ]
}
```

### Unordered List (Bullet List)

```json
{
  "type": "bulletList",
  "content": [
    {
      "type": "listItem",
      "content": [
        {
          "type": "paragraph",
          "content": [
            {
              "type": "text",
              "text": "First item"
            }
          ]
        }
      ]
    },
    {
      "type": "listItem",
      "content": [
        {
          "type": "paragraph",
          "content": [
            {
              "type": "text",
              "text": "Second item"
            }
          ]
        }
      ]
    }
  ]
}
```

### Ordered List (Numbered List)

Same structure as bullet list but with `orderedList` type. The `order` attribute sets the starting number.

```json
{
  "type": "orderedList",
  "attrs": {
    "order": 1
  },
  "content": [
    {
      "type": "listItem",
      "content": [
        {
          "type": "paragraph",
          "content": [
            {
              "type": "text",
              "text": "Step one"
            }
          ]
        }
      ]
    },
    {
      "type": "listItem",
      "content": [
        {
          "type": "paragraph",
          "content": [
            {
              "type": "text",
              "text": "Step two"
            }
          ]
        }
      ]
    }
  ]
}
```

### Code Block

The `language` attribute is optional but recommended for syntax highlighting.

```json
{
  "type": "codeBlock",
  "attrs": {
    "language": "python"
  },
  "content": [
    {
      "type": "text",
      "text": "def hello():\n    print(\"Hello, world!\")"
    }
  ]
}
```

Code blocks contain **plain text nodes only** — no marks or inline formatting.

### Blockquote

```json
{
  "type": "blockquote",
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "This is a quoted passage."
        }
      ]
    }
  ]
}
```

### Rule (Horizontal Divider)

```json
{
  "type": "rule"
}
```

### Table

Tables require `table`, `tableRow`, `tableHeader`, and `tableCell` nodes.

```json
{
  "type": "table",
  "attrs": {
    "isNumberColumnEnabled": false,
    "layout": "default"
  },
  "content": [
    {
      "type": "tableRow",
      "content": [
        {
          "type": "tableHeader",
          "attrs": {},
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Name"
                }
              ]
            }
          ]
        },
        {
          "type": "tableHeader",
          "attrs": {},
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Status"
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "tableRow",
      "content": [
        {
          "type": "tableCell",
          "attrs": {},
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Auth service"
                }
              ]
            }
          ]
        },
        {
          "type": "tableCell",
          "attrs": {},
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Done"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

### Panel

Panels provide colored callout boxes. Types: `info`, `note`, `warning`, `error`, `success`.

```json
{
  "type": "panel",
  "attrs": {
    "panelType": "warning"
  },
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "This will cause downtime during deployment."
        }
      ]
    }
  ]
}
```

---

## Inline Nodes

### Link

Links are text nodes with a `link` mark.

```json
{
  "type": "text",
  "text": "Confluence page",
  "marks": [
    {
      "type": "link",
      "attrs": {
        "href": "https://mysite.atlassian.net/wiki/spaces/ENG/pages/12345"
      }
    }
  ]
}
```

### Mention

Mentions reference a Jira user by their account ID.

```json
{
  "type": "mention",
  "attrs": {
    "id": "5b10ac8d82e05b22cc7d4ef5",
    "text": "@John Smith",
    "accessLevel": ""
  }
}
```

### Inline Code

Inline code is a text node with a `code` mark.

```json
{
  "type": "text",
  "text": "myVariable",
  "marks": [
    {
      "type": "code"
    }
  ]
}
```

### Emoji

```json
{
  "type": "emoji",
  "attrs": {
    "shortName": ":thumbsup:",
    "id": "1f44d",
    "text": "\ud83d\udc4d"
  }
}
```

### Hard Break (Line Break)

Forces a newline within a paragraph (equivalent to `<br>`).

```json
{
  "type": "hardBreak"
}
```

---

## Text Marks (Formatting)

Marks are applied to text nodes to add formatting. Multiple marks can be combined on a single text node.

| Mark | JSON |
|------|------|
| Bold | `{"type": "strong"}` |
| Italic | `{"type": "em"}` |
| Strikethrough | `{"type": "strike"}` |
| Underline | `{"type": "underline"}` |
| Inline code | `{"type": "code"}` |
| Link | `{"type": "link", "attrs": {"href": "https://..."}}` |
| Text color | `{"type": "textColor", "attrs": {"color": "#ff0000"}}` |
| Subscript | `{"type": "subsup", "attrs": {"type": "sub"}}` |
| Superscript | `{"type": "subsup", "attrs": {"type": "sup"}}` |

Example — bold and italic combined:

```json
{
  "type": "text",
  "text": "important note",
  "marks": [
    {"type": "strong"},
    {"type": "em"}
  ]
}
```

---

## Markdown to ADF Mapping

Use this table to convert markdown intent into ADF node types.

| Markdown | ADF Node / Mark |
|----------|----------------|
| Plain text | `paragraph` > `text` |
| `# Heading` | `heading` with `attrs.level: 1` |
| `## Heading` | `heading` with `attrs.level: 2` |
| `### Heading` | `heading` with `attrs.level: 3` |
| `**bold**` | `text` with mark `strong` |
| `*italic*` | `text` with mark `em` |
| `~~strikethrough~~` | `text` with mark `strike` |
| `` `inline code` `` | `text` with mark `code` |
| `[text](url)` | `text` with mark `link` |
| `- item` / `* item` | `bulletList` > `listItem` > `paragraph` > `text` |
| `1. item` | `orderedList` > `listItem` > `paragraph` > `text` |
| ` ```lang ` | `codeBlock` with `attrs.language` |
| `> quote` | `blockquote` > `paragraph` > `text` |
| `---` | `rule` |
| `\| table \|` | `table` > `tableRow` > `tableHeader`/`tableCell` |
| `@user` | `mention` with `attrs.id` (account ID required) |

---

## Complete Examples

### Create an Issue with ADF Description

```bash
curl -s -X POST \
  "https://${JIRA_DOMAIN}/rest/api/3/issue" \
  -H "Authorization: Bearer ${JIRA_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
  "fields": {
    "project": {"key": "ENG"},
    "summary": "Implement rate limiting on auth endpoints",
    "issuetype": {"name": "Task"},
    "description": {
      "version": 1,
      "type": "doc",
      "content": [
        {
          "type": "heading",
          "attrs": {"level": 2},
          "content": [{"type": "text", "text": "Overview"}]
        },
        {
          "type": "paragraph",
          "content": [
            {"type": "text", "text": "Add rate limiting to the "},
            {"type": "text", "text": "/auth/*", "marks": [{"type": "code"}]},
            {"type": "text", "text": " endpoints to prevent brute-force attacks."}
          ]
        },
        {
          "type": "heading",
          "attrs": {"level": 2},
          "content": [{"type": "text", "text": "Acceptance Criteria"}]
        },
        {
          "type": "bulletList",
          "content": [
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [{"type": "text", "text": "Rate limit of 10 requests per minute per IP"}]
                }
              ]
            },
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [{"type": "text", "text": "Return HTTP 429 with Retry-After header"}]
                }
              ]
            },
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [{"type": "text", "text": "Log rate-limited requests to observability stack"}]
                }
              ]
            }
          ]
        }
      ]
    }
  }
}'
```

### Add a Comment with ADF Body

```bash
curl -s -X POST \
  "https://${JIRA_DOMAIN}/rest/api/3/issue/ENG-1234/comment" \
  -H "Authorization: Bearer ${JIRA_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
  "body": {
    "version": 1,
    "type": "doc",
    "content": [
      {
        "type": "paragraph",
        "content": [
          {"type": "text", "text": "Investigated the failing tests. Root cause: the "},
          {"type": "text", "text": "TokenValidator", "marks": [{"type": "code"}]},
          {"type": "text", "text": " was not handling expired refresh tokens."}
        ]
      },
      {
        "type": "paragraph",
        "content": [
          {"type": "text", "text": "Fix is in "},
          {
            "type": "text",
            "text": "PR #482",
            "marks": [{"type": "link", "attrs": {"href": "https://github.com/org/repo/pull/482"}}]
          },
          {"type": "text", "text": " — ready for review."}
        ]
      },
      {
        "type": "codeBlock",
        "attrs": {"language": "java"},
        "content": [
          {"type": "text", "text": "if (token.isExpired()) {\n    return refreshTokenService.rotate(token);\n}"}
        ]
      }
    ]
  }
}'
```

### Update a Description

```bash
curl -s -X PUT \
  "https://${JIRA_DOMAIN}/rest/api/3/issue/ENG-1234" \
  -H "Authorization: Bearer ${JIRA_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
  "fields": {
    "description": {
      "version": 1,
      "type": "doc",
      "content": [
        {
          "type": "paragraph",
          "content": [
            {"type": "text", "text": "Updated description goes here."}
          ]
        }
      ]
    }
  }
}'
```
