# House — Code samples

Source: Union of Google developer style and Microsoft Writing Style Guide (house synthesis). Code-formatting conflicts: Google wins.
Last refreshed: 2026-04-29

## Placeholders

House style follows Google on code-formatting. Placeholder syntax: `UPPERCASE_WITH_UNDERSCORES`.

- Format: `UPPERCASE_WITH_UNDERSCORES` in code contexts. No `MY_` or `YOUR_` prefixes.
- In Markdown inline code: render as italic backtick — *`PLACEHOLDER_NAME`*.
- In fenced code blocks: use the uppercase form directly; explain it outside the block.
- Do not use bare angle brackets as the placeholder delimiter (Google wins over Microsoft `<version>` style), except where the language itself uses angle brackets (e.g., C++ templates, generics).
- Document every placeholder immediately after its code block:
  - One placeholder: "Replace `PLACEHOLDER` with [description]."
  - Multiple placeholders: "Replace the following:" followed by a bulleted list of `` `NAME` ``: description pairs.
- Do not hard-code passwords, tokens, or secrets. Use a named placeholder: `API_KEY`.
- Possessive forms: rephrase to avoid `'s` on code elements — "the value of `PROJECT_ID`" not "`PROJECT_ID`'s value".

## Line length

Google wins. Wrap at 80 characters.

- Use two spaces per indentation level. Do not use tabs unless the language requires them.
- For languages with a community standard that differs (e.g., 4-space Python in some orgs), follow the project's own style guide and note the deviation.

## Code blocks

Google wins on fence style. Microsoft content planning guidelines apply.

- Use fenced code blocks (triple backticks). Do not use four-space indentation for block-level samples.
- Always include a language identifier on the opening fence:

  ````
  ```python
  def greet(name):
    print(f"Hello, {name}!")
  ```
  ````

- Precede every code block with an introductory sentence:
  - End with a colon when the block follows immediately.
  - End with a period when a note, list, or paragraph falls between the introduction and the block.
- List requirements and dependencies before the block, not inside it.
- Always compile and test code before publishing.
- Start with the simplest example that illustrates the concept; add complexity only for scenarios that genuinely require it.
- Do not use click-to-copy markup on blocks that contain omissions.
- Caption or filename labels go directly above the fence as plain text or a bold line, not inside the block.

## Output formatting

- Show terminal output in its own separate fenced code block.
- Do not include shell prompt characters (`$`, `#`) in command blocks the reader will copy and run. Include prompts only in session-style output blocks.
- In session-style blocks (showing a full terminal session), use `$` for user and `#` for root to distinguish input from output lines.
- Label output blocks explicitly before the block: "The output looks like the following:"
- Use a plain or `text`-tagged fence for output; do not apply a language syntax highlighter to raw terminal output.

## Comments in code

- Add comments to explain non-obvious logic. Do not comment obvious statements.
- Use the comment syntax of the language.
- Comments should be complete sentences: capitalize the first word, end with a period.
- Keep comment lines within the 80-character limit; wrap across multiple comment lines if needed.
- Use comments to identify what the reader should modify to adapt the example. Do not add boilerplate error handling that obscures the demonstrated concept.

## Omission indicators

Google wins. Use language-appropriate comment syntax. Never use bare ellipsis characters (`...` or `…`) outside a comment construct.

| Language | Omission indicator |
|---|---|
| Python | `# ...` |
| JavaScript / TypeScript | `// ...` |
| Java, Go, C, C++ | `// ...` |
| C# | `// ...` |
| Shell / Bash / PowerShell | `# ...` |
| SQL | `-- ...` |
| HTML | `<!-- ... -->` |
| CSS | `/* ... */` |

A block that contains omissions must not be presented as copy-runnable. Note in the introductory sentence that the block is partial.

## Code in prose

Google wins on the category list. Use backtick code font for all verbatim technical strings:

- Identifiers: attribute names and values, class names, constants, data types, environment variables, event names, function and method names, keywords, operators, parameters, properties, variables.
- Commands and CLI tools: `kubectl`, `gcloud`, `dotnet`.
- HTTP verbs and status codes: `POST`, `GET`, `400 Bad Request`.
- File names and paths: `pg_hba.conf`, `/etc/postgresql/13/main`, `.\config\settings.json`.
- Package names, port numbers, query parameters: `beautifulsoup4`, TCP port `50000`, `recursive=true`.
- Strings used in commands or code: `https://api.example.com/v1`.

Do not use code font for:

- Product names, service names, trademarked terms.
- Domain names used as prose hyperlinks.
- URLs the reader navigates to in a browser (use a hyperlink).

Capitalization inside code font follows the API or language, not sentence casing. File name extensions: all lowercase — `.json`, `.yaml`, `.md`.

User input in prose: bold (Microsoft convention kept here since Google does not specify). Use italic only for placeholder values.

## UI elements mixed with code

When a UI element displays a value the user typed verbatim, apply both bold and code font: **`my-instance`**. Bold signals UI element; code font signals verbatim text.

For pure UI labels with no code involvement, bold only: click **Save**.
