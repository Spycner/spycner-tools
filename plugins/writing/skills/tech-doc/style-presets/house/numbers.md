# House: Numbers, units, dates, time

Source: Derived from Google developer style with project-specific overrides
Last refreshed: 2026-04-29

## Numerals vs spelled-out

- Spell out zero through nine in prose. Use numerals for 10 and above.
- Always use numerals for: technical quantities (memory, storage, latency, rate limits), version numbers, step numbers, prices, and numbers in math expressions.
- When a number below 10 appears alongside a number 10 or above in the same category, use numerals for both.
- When two numbers referring to different things must sit adjacent, spell out one: "fifteen 100-item batches."
- Do not begin a sentence with a numeral. Rephrase or spell out.

## Units of measurement

- Use a non-breaking space between numeral and unit: "64 GB," "200 ms," "10 Gbps."
- Use standard SI or widely accepted technical abbreviations. Do not invent shorthands.
- Do not pluralize unit abbreviations: "5 MB," not "5 MBs."
- Dimensions in prose: spell out "by". Example: "a 10-foot rack." In diagrams or tables, "×" with spaces is acceptable: "4 × 4."

## Dates

- Preferred prose format: spelled-out month, day, four-digit year. Example: "January 19, 2026."
- Machine-readable or log contexts: ISO 8601 only. Example: "2026-01-19."
- Never use purely numeric formats (1/19/26, 19/1/26) in documentation prose. Month/day order is ambiguous across locales.
- Month and year only: no comma. Example: "January 2026."
- When a full date appears mid-sentence, add a comma after the year: "The January 19, 2026, release…"
- Do not use ordinal numbers for dates: "June 1," not "June 1st."
- Do not reference seasons; use months or quarters instead.

## Time

- Use the 12-hour clock. Capitalize AM and PM; put one space before: "3:45 PM," "10:00 AM."
- Omit ":00" for whole hours unless alignment with other times in the same list requires it.
- Use "noon" and "midnight" rather than "12:00 PM" / "12:00 AM."
- When date and time appear together, lead with date: "January 19, 2026, at 3:00 PM."
- Time ranges: always write "to". Example: "9:00 AM to 5:00 PM." Do not use en dashes or hyphens as range separators.
- Time zones: include only when the audience spans zones. Spell out the zone name with UTC offset in parentheses: "Pacific Standard Time (UTC-8)." Do not abbreviate (not "PST") unless in a table or code sample.

## Currency

- Symbol immediately before the numeral, no space: "$1,024."
- Comma as thousands separator, period as decimal: "$10,000.00."
- Specify the currency when it could be ambiguous for an international reader.

## Ranges and percentages

- Always write ranges with "to" (never en dashes or hyphens in prose): "10 to 20 requests per second," "2024 to 2026."
- Percentages: numeral plus "%" with no space. Example: "40%." Spell out "percent" only when the number begins a sentence: "Forty percent of requests…"
- In tables or space-constrained contexts, the "%" symbol is always acceptable regardless of sentence position.

## Phone numbers, fractions, ordinals

**Phone numbers:** Use hyphens to separate parts. Example: "612-555-0175." No parentheses, periods, or spaces. For international numbers, include the country code with a leading plus: "+1-612-555-0175."

**Fractions:** Prefer decimals. Example: "0.75" rather than "three-quarters." When words are necessary, hyphenate: "two-thirds," "one and one-half." Do not use slash notation (3/4) in prose.

**Ordinals:** Spell out in running text. Example: "first," "second," "forty-third." Do not use numeric ordinals (1st, 43rd) in prose. Do not add "-ly" to ordinals.

**Negative numbers:** Use a minus sign, not a hyphen: "−79."

**Large round numbers:** Write out or combine numeral with word. Example: "65,000" or "65 thousand." Do not use K/M/B abbreviations in prose.
