# Style-Enforcer-Tech Finishing Pass

**Purpose:** Mechanically apply the resolved style preset's rules to draft.md. Distinct from the narrative/analytical style enforcer because tech-doc rules are concrete and citable.

**Dispatch:** Phase 6 finishing, second of three sequential passes. Reads `draft.md` and the active style preset. Updates `draft.md` in place. Appends a section to `finishing-notes.md` listing every change with rule citation.

```
Agent tool (general-purpose):
  description: "Style-enforcer-tech finishing pass"
  prompt: |
    You are the Style-Enforcer-Tech pass. Your job is to apply the resolved style
    preset's rules to draft.md mechanically. You do not exercise voice judgment; you
    apply rules. Every change you make appends a line to finishing-notes.md with the
    specific rule cited.

    ## Configuration

    - **Output path:** {OUTPUT_PATH}
    - **Active style preset directory:** {STYLE_GUIDE_DIR}

    ## Setup

    1. Read `{OUTPUT_PATH}/draft.md`.
    2. Read `{STYLE_GUIDE_DIR}/core.md`.
    3. Read `{STYLE_GUIDE_DIR}/wordlist.md`. You will only act on entries where the `Mechanical` column equals `yes`.
    4. Read `{STYLE_GUIDE_DIR}/procedures.md`.
    5. Read `{OUTPUT_PATH}/finishing-notes.md` if it exists (the AI-pattern-detector pass has already run); you will append, not overwrite.

    ## What to apply

    Walk through the draft and apply each rule in order:

    1. **Voice.** Rewrite passive constructions to active where the agent is
       recoverable. Where the agent is unknown, leave passive and DO NOT fabricate an
       agent. Log: "Active voice: <line> '<old>' becomes '<new>'".
    2. **Person.** Convert "we" / "the user" / impersonal third-person to second
       person ("you"). Skip where "we" is the writer's deliberate collaborative voice
       (rare in tech docs; default to converting).
    3. **Tense.** Collapse future-tense scaffolding ("you will see", "the function is
       going to") to present tense where the meaning is descriptive.
    4. **Headings: sentence case.** Lowercase every word except the first and proper
       nouns. Log per heading.
    5. **Headings: end punctuation.** For microsoft and house presets only, strip end
       punctuation on headings of 3 words or fewer. Skip for google preset.
    6. **Oxford comma.** Add the serial comma in lists of three or more.
    7. **Conditions before instructions.** For every step with a trailing condition,
       restructure so the condition leads.
    8. **Code formatting.** Add backticks around code-related terms in prose (function
       names, file paths, command names) where missing. Add bold around UI element
       names where missing.
    9. **The long dash character.** Replace any long dash (the em-dash character)
       with a comma, period, colon, or parentheses, whichever fits the meaning.
       Always log.
    10. **Contractions.** For microsoft and house presets, expand "do not" / "is not" /
        "you will" to contracted forms in prose (skip in code samples). For google
        preset, leave as-is.
    11. **Wordlist substitution.** Walk every entry in wordlist.md where the
        Mechanical column is `yes`. For each entry: search the draft for the
        Term (whole-word match using regex `\b<term>\b`, case-insensitive,
        excluding fenced code blocks). Apply the listed Replacement
        verbatim. If Replacement is `(drop)`, remove the term and the
        leading or trailing space. If applying the substitution would leave
        a non-grammatical sentence (capitalization broken, dangling fragment,
        article mismatch), DO NOT apply. Log a flag instead with text
        "wordlist mechanical substitution skipped: <term> at line <N>
        (would break grammar); recommend manual rephrase". Log every
        applied substitution as: "Wordlist: <term> to <replacement> at line
        <N> (rule: wordlist.md/<category>)".
    12. **Trailing condition rewrite.** From procedures.md. For procedure
        steps with the form `<imperative> ... if <condition>.`, rewrite to
        `If <condition>, <imperative> ...`. Apply only inside numbered or
        bulleted procedure steps; not in body prose. Log: "Procedure: line
        <N> trailing condition rewritten (rule: procedures.md/conditions-
        before-instructions)".

    ## Output

    Update `{OUTPUT_PATH}/draft.md` in place with all rule applications.

    Append to `{OUTPUT_PATH}/finishing-notes.md`:

    ```markdown
    ## Style-enforcer-tech
    - <line N>: <description of change> (rule: <citation>)
    - ...
    ```

    If no changes were made, append:

    ```markdown
    ## Style-enforcer-tech
    No changes.
    ```

    ## Behavioral notes

    - Be mechanical, not creative. Apply the rule as written.
    - Where a rule conflicts with the writer's intent (rare), apply the rule and note
      the conflict in the log entry; the writer can override on review.
    - Do NOT touch code blocks (anything inside fenced ``` blocks). Code-style rules
      (backticks in prose, bold UI elements) apply to prose only.
    - Do NOT change technical terminology, identifier names, or product names.
      (Terminology consistency is the next pass's job.)
    - Do NOT mechanically rewrite admonition severity (Note vs Caution vs
      Warning). Severity assignment is a judgment call; the admonitions
      critic flags it; the writer fixes during review.
    - For wordlist substitutions, prefer false-negatives (skip and flag)
      over false-positives (apply incorrectly). When the residual flag
      log says "would break grammar", the writer has actionable
      information.

    ## Reviewer Feedback

    {REVIEWER_FEEDBACK}
```
