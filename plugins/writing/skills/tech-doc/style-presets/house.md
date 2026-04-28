# House Style (merged Google + Microsoft default)

This is the default preset for the tech-doc skill. It takes the union of Google and Microsoft style guidance, resolving conflicts toward the more prescriptive choice. For strict adherence to one guide, select `--style-preset google` or `--style-preset microsoft` instead.

Sources:
- Google: https://developers.google.com/style (CC BY 4.0)
- Microsoft: https://learn.microsoft.com/en-us/style-guide/welcome/

## Voice and tone

- Conversational and friendly without being frivolous.
- Warm, relaxed, crisp, clear (MS).
- Write for a global audience (Google).

## Person

- Second person ("you").
- Avoid first-person plural ("we") except where the writer's voice is genuinely collaborative.

## Voice and tense

- Active voice. Make the actor explicit.
- Present tense for timeless documentation.
- Avoid future-tense scaffolding ("will be able to", "is going to").

## Sentence structure

- Conditions before instructions.
- Bigger ideas, fewer words. Prune every excess word.
- Write like you speak. Read text aloud.
- Start statements with verbs where possible.
- Edit out "you can" and "there is/are/were".

## Contractions

- Use contractions (it's, you'll, you're, we're, let's) to project friendliness.

## Headings and capitalization

- Sentence case for all titles, headings, subheadings.
- Skip end punctuation on headings ≤3 words.
- Front-load keywords.

## Punctuation

- Oxford comma in lists of three or more.
- One space after periods, question marks, colons.
- No em-dashes (banned project-wide).

## Lists

- Numbered lists for sequences.
- Bulleted lists for unordered items.
- Description lists for pairs of related data.
- Each list item starts with a verb where possible.

## Code formatting

- Code in code font (backticks in prose, fenced blocks for samples).
- UI elements in bold.
- Placeholders use `<UPPERCASE>` syntax (Google convention).
- Code samples should be runnable, idiomatic, and minimal.

## Accessibility

- Alt text on all meaningful images.
- Descriptive link text. Never "click here" or "this link".
- Color-independent instructions. Never "the green button".
- High-resolution or vector images where practical.

## Inclusive language

- Replace legacy terms: blacklist to blocklist, whitelist to allowlist, master/slave to primary/secondary or leader/follower, sanity check to validation check.
- Avoid gendered language. Use "they" as singular.
- Avoid ableist metaphors (crazy, insane, blind to, lame).
- Avoid cultural assumptions, idioms, sports metaphors.

## Dates

- ISO format (YYYY-MM-DD) or spelled-out month (January 5, 2026).

## Future features

- Don't document features that don't exist yet.
- Avoid "soon", "in a future release", "we plan to", "coming", "will be supported".
- Exception: descriptive future tense for runtime behavior is fine ("the function will return X").

## Global audience

- Avoid idioms, regional expressions, sports metaphors.
- Short sentences. Simple constructions.
