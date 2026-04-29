# Google — Code samples

Source: https://developers.google.com/style/code-samples, https://developers.google.com/style/code-in-text, https://developers.google.com/style/placeholders
Last refreshed: 2026-04-29

## Placeholders

Placeholders represent values the reader must supply.

- Format: `UPPERCASE_WITH_UNDERSCORES` — no `MY_` or `YOUR_` prefixes.
- Never use single letters or repeated `x` characters except where a standard form exists (e.g., HTTP `2xx` ranges).
- In Markdown inline code: italicize inside backticks — `*`PLACEHOLDER`*` renders as *`PLACEHOLDER`*.
- In fenced code blocks: no special markup is available; rely on the surrounding explanation.
- Document every placeholder immediately after the code block:
  - Single placeholder: "Replace `PLACEHOLDER` with [description]."
  - Multiple placeholders: "Replace the following:" followed by a bulleted list where each item is `` `NAME` ``: description.
- Possessive forms: rephrase to avoid `'s` on code elements. Write "the value of `PROJECT_ID`" not "`PROJECT_ID`'s value".

## Line length

- Wrap at 80 characters. Go shorter when readers may print content or use narrow windows.
- Use two spaces per indentation level. Do not use tabs.
- Prefer spaces over tabs in all languages unless the language requires tabs (e.g., Makefiles).

## Code blocks

- Use fenced code blocks (triple backticks) in Markdown. Do not use four-space indentation for block-level samples.
- Always add a language identifier on the opening fence:

  ````
  ```python
  def greet(name):
    print(f"Hello, {name}!")
  ```
  ````

- Precede every code block with an introductory sentence or paragraph:
  - End with a colon when the block follows immediately.
  - End with a period when a note or other material falls between the introduction and the block.
- Example intro: "The following example shows how to initialize the client:"
- Do not use click-to-copy formatting on blocks that contain omissions.
- Caption placement: if a caption or filename label is needed, place it directly above the fence as plain text or a bold label, not inside the block.

## Output formatting

- Show terminal output in its own fenced code block, separate from the command that produced it.
- Do not include a shell prompt character (`$`, `#`, `%`) in command blocks that readers copy and run. Include the prompt only in output blocks where it is part of the recorded session.
- When a prompt is necessary in a command block (e.g., to distinguish root from user commands), use `$` for user and `#` for root. Keep the prompt outside the range of copyable text with a note, or use a separate block.
- Label output blocks explicitly: "The output looks like the following:" or a similar sentence before the block.

  ```
  Hello, world!
  ```

## Comments in code

- Add comments to explain non-obvious logic. Do not comment obvious statements.
- Use the comment syntax of the language in use.
- Comments inside samples should be complete sentences: capitalize the first word, end with a period.
- Do not use comments as a substitute for good naming.
- Keep comment lines within the 80-character limit; wrap long comments across multiple comment lines.

## Omission indicators

- Use a language-appropriate comment to show omitted code. Never use three dots, the ellipsis character (`…`), or `[...]`.
- Examples by language:

  | Language | Omission indicator |
  |---|---|
  | Python | `# ...` |
  | JavaScript / TypeScript | `// ...` |
  | Java, Go, C, C++ | `// ...` |
  | Shell / Bash | `# ...` |
  | SQL | `-- ...` |
  | HTML | `<!-- ... -->` |
  | CSS | `/* ... */` |

- A block that contains omissions must not be marked as click-to-copy.

## Code in prose

- Use backtick code font for all verbatim technical strings: identifiers, filenames, paths, commands, environment variables, HTTP verbs, status codes, data types, query parameters, port numbers, and package names.
- Examples: `kubectl`, `POST`, `400 Bad Request`, `pg_hba.conf`, `/etc/postgresql/13/main`, `CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES`.
- Do not use code font for product names, service names, domain names used as hyperlinks, or URLs the reader navigates to in a browser.
- Boolean literals in code context: `true`, `false`. In general prose about conditions, no code font.
- Do not inflect code elements grammatically. Add a noun instead: "send a `POST` request" not "`POST` the data"; "the value of `ADDRESS`" not "`ADDRESS`'s value".
- For file paths, use the exact separators the OS uses: `/` on Unix-like systems, `\` on Windows.

## UI elements mixed with code

When instructing readers to type a value that appears verbatim in the UI (such as a resource name they created), use both bold and code font: **`my-instance`**. Bold signals it is a UI element; code signals it is verbatim text.
