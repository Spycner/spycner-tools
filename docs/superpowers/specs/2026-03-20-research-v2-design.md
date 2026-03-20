# Research Skill v2 — Analytical Rigor & Creative Synthesis

*Date: 2026-03-20*

## Problem

The research skill (v1.1) produces thesis-driven, well-sourced reports with credibility tagging and falsifiable predictions. Feedback from a real research run identified four remaining weaknesses:

1. **Single-source overweight** — A key finding ("decision velocity") was promoted based on one practitioner blog post with no acknowledgment of its thin sourcing.
2. **Invented thresholds** — The report presented a "10-30% optimal override rate" as if empirically grounded, but the range was the agent's own invention with no cited basis.
3. **Bias-flag-then-ignore** — Vendor/consulting source data was correctly flagged on first mention, then reused at face value in later sections without any credibility reminder.
4. **Synthesis ceiling** — The system is an excellent analyst (judges between sources well) but does not generate original frameworks or concepts. It synthesizes others' thinking but doesn't produce its own.

## Design

### Approach: Phase-Level Guards + Audit Expansion

Rules are placed where the work happens (Phases 4, 5.5, 6), not just at audit time. The self-audit checklist is the safety net, not the primary enforcement. Creative synthesis is opt-in via a separate parameter.

### Change 1: Phase 4 (Depth Pass) — Invented Threshold Rule

Added to Phase 4 in `deep-research.md`:

Never present a numeric range, threshold, or benchmark without citing its empirical source. If you derived a number yourself (from reasoning, interpolation, or synthesis), label it explicitly as `[author estimate]` with the reasoning shown. "The optimal range is 10-30%" without citation is forbidden. "Based on [Source]'s finding of X and [Source]'s finding of Y, a reasonable range might be 10-30% [author estimate]" is acceptable.

### Change 2: Phase 5.5 — Creative Synthesis (opt-in)

New phase between Adversarial Pass (Phase 5) and Synthesis (Phase 6). Gated by `creative: true` parameter. Independent of `mode` — works with both `deep` and `quick`.

When active:
1. Review all notes and identify gaps — "What question does no existing framework answer?"
2. Attempt to generate 1-2 original concepts, frameworks, or mental models that address those gaps
3. Stress-test each invention against three questions:
   - Does this make a prediction that existing frameworks don't?
   - Could someone use this to make a different decision than they would without it?
   - Is this actually novel, or am I renaming something that already exists?
4. If an invention fails any test, cut it. No partial credit.
5. Surviving frameworks get included in the report with an explicit `[original analysis]` tag.
6. In quick + creative mode: one framework attempt max (less source material to synthesize from).

When inactive (default): The agent flags gaps it notices — "No existing framework addresses X" — as observations in the analysis. It does not try to fill them.

### Change 3: Phase 6 (Synthesis) — Bias Consistency Rule

Added to the writing guidelines in Phase 6 of `deep-research.md`:

- First mention: flag source type and incentive (already happens today)
- Subsequent mentions: keep exact figures, attach a brief credibility reminder — "Larridin's 83% (vendor data)" or "McKinsey's 55% (consulting sample)"
- Do NOT replace exact figures with vague language. Precision is valuable. The reader sees the number and its provenance and judges for themselves.
- If an independent source corroborates the figure, cite both — that's how a vendor number earns extra weight.

The credibility tag travels with the number. The number stays exact.

### Change 4: Phase 6 (Synthesis) — Source Weight Transparency

Added to the writing guidelines in Phase 6 of `deep-research.md`:

A concept can be promoted to "What Matters Most" with a single source, but it must:
- Explicitly flag that it rests on a single source
- Note the source type (peer-reviewed? blog post? vendor report?)
- State why it's promoted despite thin sourcing ("included because it addresses a gap no other source covers")

The problem was not that thinly-sourced concepts appeared — it was that they appeared without acknowledging the weakness. Importance justifies prominence; transparency justifies the reader's trust.

### Change 5: Self-Audit Checklist Additions

New items added to `research-recipes.md`:

**Source weight:**
- Every key finding either has 2+ independent sources OR explicitly flags its single-source status and justifies its prominence

**Threshold integrity:**
- Every numeric range, threshold, or benchmark has a cited empirical source
- Any author-derived numbers are labeled `[author estimate]` with reasoning shown

**Bias consistency:**
- Every reuse of a `[vendor]` or `[consulting]` data point includes a brief credibility tag
- No biased-source figures appear untagged in later sections

**Creative synthesis (when `creative: true`):**
- Each proposed framework passes all three stress tests
- Original frameworks are tagged `[original analysis]`
- In non-creative mode: gaps are flagged but not filled

### Change 6: SKILL.md — New Creative Parameter

The `mode` parameter stays as `deep | quick`. A new `creative` parameter (boolean, default false) is added. The dispatch step passes both to the agent.

## Files Changed

| File | Change |
|------|--------|
| `plugins/research/agents/deep-research.md` | Phase 4 threshold rule, new Phase 5.5, Phase 6 bias + source weight rules |
| `plugins/research/skills/research/research-recipes.md` | Four new self-audit checklist groups |
| `plugins/research/skills/research/SKILL.md` | New `creative` parameter, updated dispatch instructions |
| `plugins/research/skills/research/report-template.md` | No changes needed |
