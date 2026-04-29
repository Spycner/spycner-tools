# Microsoft — Code samples

Source: https://learn.microsoft.com/en-us/style-guide/developer-content/code-examples, https://learn.microsoft.com/en-us/style-guide/developer-content/formatting-developer-text-elements
Last refreshed: 2026-04-29

## Placeholders

Placeholders represent values the reader must supply.

- Format: italic inside angle brackets when angle brackets are not part of the language syntax — `/v: <version>`.
- For UI text placeholders (values a reader types in a UI field): italic without angle brackets — Enter *password*.
- In running prose: use italic for placeholders. Example: "Replace *connection-string* with your database connection string."
- Capitalization of placeholders follows the conventions of the language or API being documented. Microsoft does not mandate a single casing convention for all placeholders.
- Document all placeholders near the code block. Explain what each one represents and any constraints (format, allowed values, required permissions).
- Do not hard-code passwords, tokens, or secrets in code examples, even as placeholders. Use a named placeholder instead: `<your-api-key>`.

## Line length

- No single mandatory character limit. Aim for lines that fit without horizontal scrolling on a typical screen.
- Break long lines before a slash in URLs. Do not hyphenate line breaks in URLs.
- Indentation follows the conventions of the language. Document any indentation choice that departs from the language norm.

## Code blocks

- Use fenced code blocks in Markdown. Always include a language identifier:

  ````
  ```csharp
  Console.WriteLine("Hello, world!");
  ```
  ````

- Precede every code block with an introductory sentence that describes the scenario:
  - End with a colon when the block follows immediately.
  - End with a period when a note or other content separates the introduction from the block.
- List requirements and dependencies before the code block, not inside it.
- Create concise examples. Start simple; add complexity only after covering common scenarios.
- Always compile and test code before publishing.
- If an example demonstrates interactive or animated behavior, consider providing a way to run it directly from the page.
- For long samples illustrating multiple features, consider a tutorial or walkthrough format with step-by-step explanation rather than an isolated block.

## Output formatting

- Show expected output in a separate section after the code example, or inline as code comments.
- Label output blocks with a heading or sentence: "The output looks like the following:" or "The command produces this output:".
- Use a plain code block (no language tag, or `text` or `console`) for terminal output.
- Do not mix commands and their output in a single block without clear visual separation (e.g., prompt characters or blank lines).
- Show the prompt character (`>` for PowerShell, `$` for bash) in session-style output blocks to distinguish input from output.

## Comments in code

- Add comments to explain non-obvious logic. Do not comment obvious statements ("don't state the obvious").
- Use comments to identify what the reader should modify to adapt the example to their needs.
- Keep comments concise. Use the comment syntax of the language.
- Comments count toward code quality: they should be accurate, up to date, and grammatically correct.
- Show exception handling in comments or separate sections only when it is intrinsic to the example. Do not add boilerplate exception handling that distracts from the demonstrated concept.

## Omission indicators

- Use language-appropriate comment syntax to indicate omitted code. Do not use bare ellipsis characters (`...` or `…`) outside a comment.
- Examples:

  | Language | Omission indicator |
  |---|---|
  | C# / C++ / Java | `// ...` |
  | PowerShell / Bash | `# ...` |
  | SQL | `-- ...` |
  | XML / HTML | `<!-- ... -->` |
  | CSS | `/* ... */` |

- When an example is intentionally incomplete, note this in the introductory sentence so readers understand the block is not meant to be run as-is.

## Code in prose

- Use code style (backticks in Markdown) for: attribute names and values, class names, command-line commands and options, constants, data types, environment variables, event names, file name extensions, function and method names, keywords, operators, parameters, properties, registry settings, statements, structure names, variables, and XML/HTML tags.
- File names and folder names: use code style when referenced in code context; use plain or bold text when referenced as UI elements.
- URLs: all lowercase. Use code style when the URL appears in code. Use plain hyperlinked text for navigable URLs.
- User input: bold. Use italic only for placeholder values.
- Do not use code font for product names, service names, or trademarked terms.
- Capitalization inside code font follows the API or language, not sentence casing.
- File name extensions: all lowercase — `.docx`, `.json`, `.md`.

## UI elements mixed with code

- When a UI label and a code value appear together, apply the appropriate formatting to each part separately.
- UI labels: bold — click **Save**.
- Code or verbatim values typed into a UI field: bold for the action, italic for the placeholder — Enter *project-name*.
- If a value the reader created appears verbatim in the UI, bold it as a UI element rather than adding code font, unless it appears in code syntax.
