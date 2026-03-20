# Research Recipes

## Search Strategy Patterns

### Breadth Pass Queries

For each sub-question, vary the query framing across these angles:

| Angle | Query Pattern | Example |
|-------|--------------|---------|
| Academic | "{topic} research papers {year}" | "remote work productivity research papers 2025" |
| Industry | "{topic} industry analysis report" | "remote work industry analysis report" |
| Critical | "{topic} challenges limitations criticism" | "remote work challenges limitations criticism" |
| Adoption | "{topic} trends adoption statistics" | "remote work trends adoption statistics" |
| Future | "{topic} future predictions outlook" | "remote work future predictions outlook" |

### Adversarial Pass Queries

| Pattern | Example |
|---------|---------|
| "{topic} criticism problems" | "remote work criticism problems" |
| "{topic} failed why" | "remote work policies failed why" |
| "{topic} risks downsides" | "remote work risks downsides" |
| "{topic} debunked myth" | "remote work productivity debunked myth" |
| "{previous finding} contradicted" | "remote work increases productivity contradicted" |

## Perspective Discovery Patterns

For any research topic, consider these stakeholder categories:

| Category | Think about... |
|----------|---------------|
| Practitioners | People who do the thing daily |
| Decision-makers | People who decide whether/how to adopt |
| Regulators | People who govern or constrain |
| Researchers | People who study it academically |
| Critics | People who oppose or question it |
| End users | People affected by the outcomes |
| Economists | People who analyze costs/benefits |

Not all categories apply to every topic. Pick 3-5 that are most relevant.

## Self-Audit Checklist

Before synthesis, verify:

**Evidence quality:**
- [ ] Every section has at least one specific data point or direct quote
- [ ] Someone could fact-check this report using only the provided citations
- [ ] sources.md has 8+ entries (if fewer, breadth pass was too narrow — go back)
- [ ] Key claims have 2+ independent sources
- [ ] Recent sources (last 2 years) are prioritized where the topic is evolving

**Analytical rigor:**
- [ ] You can state your thesis in one sentence
- [ ] You identified at least one contradiction between sources and took a position on which is more credible
- [ ] Vendor/consulting sources are flagged where incentive bias may distort findings
- [ ] At least one perspective you personally find unconvincing is represented

**Report quality:**
- [ ] Findings are ranked by importance — the top 5-7 are front and center, not buried in a list of 30
- [ ] The Limitations section honestly addresses what your proposed solutions cannot solve
- [ ] Practical guidance exists for the most common starting point (no baselines, no infrastructure, limited resources)
- [ ] Analysis & Insights is the strongest section, not the thinnest — it synthesizes, compares, and judges rather than summarizing

**Source weight:**
- [ ] Every key finding either has 2+ independent sources OR explicitly flags its single-source status and justifies its prominence

**Threshold integrity:**
- [ ] Every numeric range, threshold, or benchmark has a cited empirical source
- [ ] Any author-derived numbers are labeled `[author estimate]` with reasoning shown

**Bias consistency:**
- [ ] Every reuse of a `[vendor]` or `[consulting]` data point includes a brief credibility tag (e.g., "83% (vendor data)")
- [ ] No biased-source figures appear untagged in later sections

**Creative synthesis (when `creative: true`):**
- [ ] Each proposed framework passes all three stress tests (novel prediction, different decision, actually new)
- [ ] Original frameworks are tagged `[original analysis]`
- [ ] If `creative: false`, the report does not contain original frameworks or novel conceptual models — any identified gaps are stated as observations, not solutions
