# Confluence XHTML Storage Format Reference

## When You Need This

Confluence stores page content in an XHTML-based format called "storage format." You must use this format when creating or updating pages via the REST API (curl). The `body.storage.value` field in API requests expects storage format XHTML, not Markdown or plain HTML.

Example API call context:

```bash
curl -s -X PUT \
  "https://${DOMAIN}.atlassian.net/wiki/rest/api/content/${PAGE_ID}" \
  -H "Authorization: Bearer ${CONFLUENCE_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "version": { "number": NEW_VERSION },
    "title": "Page Title",
    "type": "page",
    "body": {
      "storage": {
        "value": "<p>This is storage format XHTML.</p>",
        "representation": "storage"
      }
    }
  }'
```

## Key Rules

- Content must be valid XHTML (all tags closed, attributes quoted).
- Confluence-specific elements use the `ac:` and `ri:` XML namespaces.
- Self-closing tags must use `/>` syntax (e.g., `<br />`).
- Special characters must be XML-escaped: `&amp;` `&lt;` `&gt;` `&quot;`.

---

## Basic Elements

### Paragraphs

```xml
<p>This is a paragraph of text.</p>

<p>This is another paragraph with <strong>bold</strong> and <em>italic</em> text.</p>
```

### Headings

```xml
<h1>Heading 1</h1>
<h2>Heading 2</h2>
<h3>Heading 3</h3>
<h4>Heading 4</h4>
<h5>Heading 5</h5>
<h6>Heading 6</h6>
```

### Inline Formatting

```xml
<strong>Bold text</strong>
<em>Italic text</em>
<del>Strikethrough text</del>
<sub>Subscript</sub>
<sup>Superscript</sup>
<code>Inline code</code>
<u>Underlined text</u>
```

### Line Break

```xml
<p>Line one.<br />Line two.</p>
```

### Horizontal Rule

```xml
<hr />
```

---

## Links

### External Link

```xml
<a href="https://example.com">Link text</a>
```

### Link to Another Confluence Page

```xml
<ac:link>
  <ri:page ri:content-title="Target Page Title" ri:space-key="SPACEKEY" />
  <ac:plain-text-link-body><![CDATA[Display text]]></ac:plain-text-link-body>
</ac:link>
```

If the target page is in the same space, `ri:space-key` can be omitted:

```xml
<ac:link>
  <ri:page ri:content-title="Target Page Title" />
  <ac:plain-text-link-body><![CDATA[Display text]]></ac:plain-text-link-body>
</ac:link>
```

### Anchor Link

```xml
<ac:link ac:anchor="section-name">
  <ac:plain-text-link-body><![CDATA[Jump to section]]></ac:plain-text-link-body>
</ac:link>
```

---

## Lists

### Unordered List

```xml
<ul>
  <li>First item</li>
  <li>Second item</li>
  <li>Third item with <strong>bold</strong></li>
</ul>
```

### Ordered List

```xml
<ol>
  <li>Step one</li>
  <li>Step two</li>
  <li>Step three</li>
</ol>
```

### Nested List

```xml
<ul>
  <li>Parent item
    <ul>
      <li>Child item</li>
      <li>Another child</li>
    </ul>
  </li>
  <li>Another parent</li>
</ul>
```

### Task List

```xml
<ac:task-list>
  <ac:task>
    <ac:task-id>1</ac:task-id>
    <ac:task-status>incomplete</ac:task-status>
    <ac:task-body>Do this thing</ac:task-body>
  </ac:task>
  <ac:task>
    <ac:task-id>2</ac:task-id>
    <ac:task-status>complete</ac:task-status>
    <ac:task-body>Already done</ac:task-body>
  </ac:task>
</ac:task-list>
```

---

## Tables

### Basic Table

```xml
<table data-layout="default">
  <colgroup>
    <col style="width: 340.0px;" />
    <col style="width: 340.0px;" />
  </colgroup>
  <thead>
    <tr>
      <th><p>Header 1</p></th>
      <th><p>Header 2</p></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><p>Cell 1</p></td>
      <td><p>Cell 2</p></td>
    </tr>
    <tr>
      <td><p>Cell 3</p></td>
      <td><p>Cell 4</p></td>
    </tr>
  </tbody>
</table>
```

### Three-Column Table

```xml
<table data-layout="default">
  <colgroup>
    <col style="width: 226.67px;" />
    <col style="width: 226.67px;" />
    <col style="width: 226.67px;" />
  </colgroup>
  <thead>
    <tr>
      <th><p>Name</p></th>
      <th><p>Status</p></th>
      <th><p>Notes</p></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><p>Item A</p></td>
      <td><p>Active</p></td>
      <td><p>No issues</p></td>
    </tr>
  </tbody>
</table>
```

---

## Images

### Attached Image

```xml
<ac:image>
  <ri:attachment ri:filename="screenshot.png" />
</ac:image>
```

### Image with Size

```xml
<ac:image ac:height="300" ac:width="500">
  <ri:attachment ri:filename="diagram.png" />
</ac:image>
```

### External Image

```xml
<ac:image>
  <ri:url ri:value="https://example.com/image.png" />
</ac:image>
```

---

## Confluence Macros

All macros use the `<ac:structured-macro>` element. Parameters are passed with `<ac:parameter>`. Rich body content uses `<ac:rich-text-body>`. Plain text body uses `<ac:plain-text-body>`.

General macro structure:

```xml
<ac:structured-macro ac:name="macro-name" ac:schema-version="1">
  <ac:parameter ac:name="param-name">param-value</ac:parameter>
  <ac:rich-text-body>
    <p>Body content here.</p>
  </ac:rich-text-body>
</ac:structured-macro>
```

### Code Block

```xml
<ac:structured-macro ac:name="code" ac:schema-version="1">
  <ac:parameter ac:name="language">python</ac:parameter>
  <ac:parameter ac:name="title">Example Script</ac:parameter>
  <ac:parameter ac:name="linenumbers">true</ac:parameter>
  <ac:parameter ac:name="collapse">false</ac:parameter>
  <ac:plain-text-body><![CDATA[def hello():
    print("Hello, world!")

hello()]]></ac:plain-text-body>
</ac:structured-macro>
```

Common language values: `python`, `java`, `javascript`, `bash`, `sql`, `json`, `xml`, `yaml`, `go`, `rust`, `text`, `none`.

### Table of Contents

```xml
<ac:structured-macro ac:name="toc" ac:schema-version="1">
  <ac:parameter ac:name="maxLevel">3</ac:parameter>
</ac:structured-macro>
```

With additional options:

```xml
<ac:structured-macro ac:name="toc" ac:schema-version="1">
  <ac:parameter ac:name="maxLevel">4</ac:parameter>
  <ac:parameter ac:name="minLevel">2</ac:parameter>
  <ac:parameter ac:name="type">list</ac:parameter>
  <ac:parameter ac:name="outline">false</ac:parameter>
</ac:structured-macro>
```

### Info Panel

```xml
<ac:structured-macro ac:name="info" ac:schema-version="1">
  <ac:parameter ac:name="title">Note</ac:parameter>
  <ac:rich-text-body>
    <p>This is an informational message.</p>
  </ac:rich-text-body>
</ac:structured-macro>
```

### Note Panel (Yellow Warning)

```xml
<ac:structured-macro ac:name="note" ac:schema-version="1">
  <ac:parameter ac:name="title">Caution</ac:parameter>
  <ac:rich-text-body>
    <p>Pay attention to this important detail.</p>
  </ac:rich-text-body>
</ac:structured-macro>
```

### Warning Panel (Red)

```xml
<ac:structured-macro ac:name="warning" ac:schema-version="1">
  <ac:parameter ac:name="title">Warning</ac:parameter>
  <ac:rich-text-body>
    <p>This action is irreversible.</p>
  </ac:rich-text-body>
</ac:structured-macro>
```

### Tip Panel (Green)

```xml
<ac:structured-macro ac:name="tip" ac:schema-version="1">
  <ac:parameter ac:name="title">Pro Tip</ac:parameter>
  <ac:rich-text-body>
    <p>Use keyboard shortcuts to save time.</p>
  </ac:rich-text-body>
</ac:structured-macro>
```

### Expand (Collapsible Section)

```xml
<ac:structured-macro ac:name="expand" ac:schema-version="1">
  <ac:parameter ac:name="title">Click to expand</ac:parameter>
  <ac:rich-text-body>
    <p>This content is hidden by default.</p>
    <ul>
      <li>Detail one</li>
      <li>Detail two</li>
    </ul>
  </ac:rich-text-body>
</ac:structured-macro>
```

### Panel (Generic Colored Box)

```xml
<ac:structured-macro ac:name="panel" ac:schema-version="1">
  <ac:parameter ac:name="title">Panel Title</ac:parameter>
  <ac:parameter ac:name="borderStyle">solid</ac:parameter>
  <ac:parameter ac:name="borderColor">#ccc</ac:parameter>
  <ac:parameter ac:name="bgColor">#f5f5f5</ac:parameter>
  <ac:rich-text-body>
    <p>Content inside the panel.</p>
  </ac:rich-text-body>
</ac:structured-macro>
```

### No Format (Preformatted Plain Text)

```xml
<ac:structured-macro ac:name="noformat" ac:schema-version="1">
  <ac:plain-text-body><![CDATA[This text is rendered exactly as typed.
  Whitespace   is   preserved.]]></ac:plain-text-body>
</ac:structured-macro>
```

### Status Macro (Colored Lozenge)

```xml
<ac:structured-macro ac:name="status" ac:schema-version="1">
  <ac:parameter ac:name="title">IN PROGRESS</ac:parameter>
  <ac:parameter ac:name="colour">Blue</ac:parameter>
</ac:structured-macro>
```

Colour values: `Grey`, `Red`, `Yellow`, `Blue`, `Green`.

### Excerpt (Reusable Content Summary)

```xml
<ac:structured-macro ac:name="excerpt" ac:schema-version="1">
  <ac:parameter ac:name="hidden">true</ac:parameter>
  <ac:rich-text-body>
    <p>This text can be pulled into other pages via the excerpt-include macro.</p>
  </ac:rich-text-body>
</ac:structured-macro>
```

### Anchor (Bookmark Target)

```xml
<ac:structured-macro ac:name="anchor" ac:schema-version="1">
  <ac:parameter ac:name="">section-name</ac:parameter>
</ac:structured-macro>
```

### Children Display (List Child Pages)

```xml
<ac:structured-macro ac:name="children" ac:schema-version="1">
  <ac:parameter ac:name="depth">2</ac:parameter>
  <ac:parameter ac:name="sort">title</ac:parameter>
</ac:structured-macro>
```

---

## Markdown to Storage Format Mapping

| Markdown | Storage Format |
|---|---|
| `# Heading 1` | `<h1>Heading 1</h1>` |
| `## Heading 2` | `<h2>Heading 2</h2>` |
| `**bold**` | `<strong>bold</strong>` |
| `*italic*` | `<em>italic</em>` |
| `~~strikethrough~~` | `<del>strikethrough</del>` |
| `` `inline code` `` | `<code>inline code</code>` |
| `[text](url)` | `<a href="url">text</a>` |
| `![alt](image.png)` | `<ac:image><ri:url ri:value="image.png" /></ac:image>` |
| `- item` | `<ul><li>item</li></ul>` |
| `1. item` | `<ol><li>item</li></ol>` |
| `> blockquote` | `<blockquote><p>blockquote</p></blockquote>` |
| `---` | `<hr />` |
| `` ``` code block ``` `` | `<ac:structured-macro ac:name="code">...</ac:structured-macro>` (see Code Block above) |
| `\| table \|` | `<table>...</table>` (see Tables above) |
| `- [ ] task` | `<ac:task-list><ac:task>...</ac:task></ac:task-list>` (see Task List above) |

---

## Composing a Full Page

A realistic page combining multiple elements:

```xml
<ac:structured-macro ac:name="toc" ac:schema-version="1">
  <ac:parameter ac:name="maxLevel">3</ac:parameter>
</ac:structured-macro>

<h1>Project Overview</h1>

<ac:structured-macro ac:name="info" ac:schema-version="1">
  <ac:parameter ac:name="title">Status</ac:parameter>
  <ac:rich-text-body>
    <p>Last updated: 2026-03-18.
    Status: <ac:structured-macro ac:name="status" ac:schema-version="1"><ac:parameter ac:name="title">ACTIVE</ac:parameter><ac:parameter ac:name="colour">Green</ac:parameter></ac:structured-macro></p>
  </ac:rich-text-body>
</ac:structured-macro>

<p>This page describes the project architecture and key decisions.</p>

<h2>Architecture</h2>

<p>The system consists of three services:</p>

<ul>
  <li><strong>API Gateway</strong> &mdash; handles authentication and routing</li>
  <li><strong>Core Service</strong> &mdash; business logic</li>
  <li><strong>Data Store</strong> &mdash; persistence layer</li>
</ul>

<h2>Configuration</h2>

<ac:structured-macro ac:name="code" ac:schema-version="1">
  <ac:parameter ac:name="language">yaml</ac:parameter>
  <ac:parameter ac:name="title">config.yaml</ac:parameter>
  <ac:plain-text-body><![CDATA[server:
  port: 8080
  host: 0.0.0.0
database:
  url: postgres://localhost:5432/mydb]]></ac:plain-text-body>
</ac:structured-macro>

<h2>Decision Log</h2>

<table data-layout="default">
  <colgroup>
    <col style="width: 170.0px;" />
    <col style="width: 340.0px;" />
    <col style="width: 170.0px;" />
  </colgroup>
  <thead>
    <tr>
      <th><p>Date</p></th>
      <th><p>Decision</p></th>
      <th><p>Owner</p></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><p>2026-03-01</p></td>
      <td><p>Adopt PostgreSQL for persistence</p></td>
      <td><p>Engineering</p></td>
    </tr>
    <tr>
      <td><p>2026-03-10</p></td>
      <td><p>Use gRPC for inter-service communication</p></td>
      <td><p>Platform</p></td>
    </tr>
  </tbody>
</table>

<ac:structured-macro ac:name="expand" ac:schema-version="1">
  <ac:parameter ac:name="title">Archived Decisions</ac:parameter>
  <ac:rich-text-body>
    <p>No archived decisions yet.</p>
  </ac:rich-text-body>
</ac:structured-macro>
```

---

## Tips

- Wrap all cell and header content in `<p>` tags inside `<td>` and `<th>`.
- Use `<![CDATA[...]]>` inside `<ac:plain-text-body>` to avoid escaping issues with code content.
- The `ac:schema-version="1"` attribute is required on all `<ac:structured-macro>` elements.
- When building storage format strings in shell variables, use heredocs or files to avoid quoting nightmares with nested quotes and angle brackets.
- To include literal `]]>` inside a CDATA section, split it: `]]]]><![CDATA[>`.
