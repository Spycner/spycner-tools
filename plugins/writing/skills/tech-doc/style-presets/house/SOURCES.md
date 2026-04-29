# House — Sources

## Primary sources
- Google: see ../google/SOURCES.md
- Microsoft: see ../microsoft/SOURCES.md

## License
House combines:
- Google: CC BY 4.0 (attribution: "Adapted from the Google Developer Documentation Style Guide, used under CC BY 4.0.")
- Microsoft: paraphrased for fair-use reference.

## Merge policy

When Google and Microsoft entries conflict:
1. Default: take the more-prescriptive choice (forbids more, specifies more precisely).
2. Voice/tone: Microsoft wins (more nuanced).
3. Code formatting: Google wins (deeper code-sample guidance).
4. Capitalization: sentence case (both agree).
5. Future-features: strictest reading (no pre-announcement under any condition).
6. Em-dashes: banned entirely (project-wide rule; overrides both).

Conflicts not resolved by these rules are documented inline in the relevant
sidecar with an HTML comment block giving the conflict and the resolution.

## Refresh process

Quarterly:
1. Update `<preset>/SOURCES.md` last-refreshed date for the changed preset.
2. Update the relevant sidecar files for that preset directly.
3. Re-merge house: walk topic-by-topic, dedupe, apply merge policy, document deviations inline.
4. Update `house/SOURCES.md` last-merged date below.

## Last refreshed
- core.md: 2026-04-29
- wordlist.md: 2026-04-29
- procedures.md: 2026-04-29
- admonitions.md: 2026-04-29
- code-samples.md: 2026-04-29
- links.md: 2026-04-29
- numbers.md: 2026-04-29
- api-reference.md: 2026-04-29
