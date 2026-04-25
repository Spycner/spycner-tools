# The Pyramid Principle as a Skill: An Operational Reference

*Date: 2026-04-24*

## Executive Summary

**Thesis.** The Pyramid Principle's real leverage is not the triangular diagram; it is a small set of audit questions (MECE, So-What, Why-Is-That-True, Q-A alignment, inductive/deductive classification) that force a writer's structure to match their actual logic. Teaching Claude the shape without the audits produces formally correct pyramids filled with "intellectually blank" summaries (Lethain, [Source 41, practitioner]). Teaching the audits produces pyramids that pass partner review.

**Key findings.** (1) Minto's own framework is *SCQ* (Situation, Complication, Question), with the Answer at the pyramid's apex rather than inside the opener (barbaraminto.com, [Source 4, vendor]); practitioners flatten this into SCQA and we recommend that convention externally while keeping Minto's distinction internally. (2) Grouping-size claims disagree substantially: 3 (Ranadive [Source 8]), 2-4 (Archbee [Source 51]), 3-5 (Kavanaugh [Source 50]), 4 deductive / 5 inductive (Phlix [Source 6]), 3-7 (Buteau [Source 5]). Minto invokes Miller's 7 plus-or-minus 2 as a ceiling, not a prescription; **we take the position that the default is 3, ceiling is 5, and 6+ is a MECE-failure signal until proven otherwise**. (3) The method's three dominant failure modes, each mappable to a named critic check, are: manufactured SCQA complications, MECE groupings that overlap or leave gaps, and summary nodes that name a category instead of stating a finding.

**Implications for the skill.** A 5-6 phase pyramid orchestrator should separate *structure discovery* (bottom-up when answer unknown; top-down when known) from *structure audit* (MECE, So-What, Q-A alignment) from *prose rendering*. The audits are where the quality gate lives. Audits and tables in sections 1-9 are named so phase prompts can invoke them literally ("Apply the Four MECE Audit Questions from section 4").

## Table of Contents

1. The Three Rules of a Pyramid
2. The SCQA Opener (Minto's SCQ Plus the Apex)
3. Building the Pyramid Top-Down: Q-A Dialogue
4. The MECE Audit (Four Questions)
5. Vertical vs Horizontal Logic (Inductive vs Deductive)
6. The So-What Test and the Why-Is-That-True Test
7. Restructuring Existing Prose: Reverse-Engineering a Draft
8. Grouping-Size Guidance: A Position on 3-5
9. Failing-Pyramid Diagnostics (Prose Symptoms to Logic Causes)
10. Before/After Micro-Examples (Worked)
11. Domain Limits and When NOT to Use the Pyramid
12. References

## 1. The Three Rules of a Pyramid

Minto's three rules survive cleanly across practitioner restatements, despite minor wording drift (StrategyU [Source 1], Phlix [Source 6], ToSummarise [Source 7], Ranadive [Source 8], Buteau [Source 5], Lethain [Source 41]). We adopt the following canonical form.

- **Rule 1 (Summation).** Each node above the bottom row summarises the ideas grouped immediately beneath it. Summary is a finding, not a category label. "Revenue grew 23% because of new SKUs" is a summary; "Three reasons revenue grew" is a label.
- **Rule 2 (Homogeneity).** Sibling nodes inside a grouping are the same kind of idea, at the same level of abstraction, and nameable with one plural noun (reasons, steps, risks, recommendations, causes). If you cannot find that noun, the grouping is not homogeneous.
- **Rule 3 (Logical Ordering).** Siblings are ordered by exactly one of: chronological, structural, comparative (degree), or deductive order. Arbitrary order signals a non-grouping.

**Audit questions a phase prompt can cite:**

1. For Rule 1: *"If I read this summary alone, does it commit to a specific finding, or does it only announce that findings exist?"* (Lethain's intellectually-blank test, [Source 41].)
2. For Rule 2: *"What plural noun names this group?"* (Phlix's plural-noun test, [Source 6].) If the answer is "things" or "points," the grouping fails.
3. For Rule 3: *"Does reordering these siblings change meaning or just taste?"* (Animalz's sequence test, [Source 21].) Meaning-preserving reorder indicates genuine list order; meaning-changing reorder indicates logical order that must be justified.

These three rules are the skeleton. Sections 2-9 apply tests to them.

## 2. The SCQA Opener (Minto's SCQ Plus the Apex)

**Nomenclature position.** Minto's own material names the framework **SCQ** (Situation, Complication, Question), with the *Answer* being the pyramid's apex rather than part of the opener ([Source 4, vendor]). Most practitioner sources flatten this to SCQA (CFI [Source 30], Antonov [Source 31], SlideModel [Source 37, vendor], Analytic Storytelling [Source 34, vendor], Analyst Academy [Source 39, consulting]). **Use SCQA externally** (users will have read that) while internally treating A as the governing thought.

**Component definitions.**

- **Situation.** Noncontroversial context the reader already agrees with. Analyst Academy: *"introduction content must contain nothing new or controversial"* ([Source 39, consulting]).
- **Complication.** The change that makes the situation unstable. Analytic Storytelling's causal rule: *"The complication must identify what causes the problem, not merely describe it"* ([Source 34, vendor]). A C that only restates the symptom gives Q no handle.
- **Question.** A falsifiable question the C forces (StrategyU's hypothesis discipline, [Source 35, practitioner]).
- **Answer.** The governing thought; the pyramid's top.

**Three failure modes to flag inline.**

1. **Manufactured complication.** SCQA forced onto a document with no real trigger, producing throat-clearing: "Since 2002 the field has grown. However, more work remains." (adapted from BCG's Hewlett Foundation example, [Source 39]). Formally correct, informationally empty.
2. **Question that restates the answer.** "How should we grow revenue?" paired with "By growing revenue" (synthesised from Lethain's premature-question critique, [Source 41]).
3. **Answer-first bleed.** The writer leads with the conclusion, then backfills S to justify it, producing a tautological C ([Source 39, consulting]).

**The SCQA Opener Audit** (four questions):

1. Would the intended reader nod at S without friction?
2. Does C identify a *cause*, not restate the symptom?
3. Does Q arise from C such that C without Q feels incomplete?
4. Would changing A also require changing C? (If not, the opener is decorative.)

## 3. Building the Pyramid Top-Down: Q-A Dialogue

Minto's top-down procedure treats the pyramid as a hierarchical dialogue: each node *raises a question* and its children *answer that question* (Adrian.idv.hk [Source 12, practitioner]; Phlix [Source 6]; Lethain [Source 41]).

**The Q-A Dialogue Procedure:**

1. State the **Subject**.
2. Define the **Reader** and the **Question** you expect them to have.
3. State the **Answer** (the governing thought, the apex).
4. Work backwards to write the **Situation** (first noncontroversial fact for this reader).
5. Develop the **Complication** that triggers the Question.
6. Verify S plus C produces Q, and that Q is answered by A.
7. Drop below A: ask *"what question does A raise for this reader?"* Children at the next level must answer that one question.
8. Recurse: each new node raises a question the layer below must answer.

Adrian's discipline applies throughout: *"We should not raise the question in reader's mind until we are ready to write the answer"* ([Source 12, practitioner]). A node that invites an unanswered question is a leak.

**The Q-A Alignment Audit:**

1. For each non-leaf node, name the question it raises.
2. Verify the grouping below it answers *that* question *as a whole*, not as a sum of children answering different questions.
3. If the children answer different questions, the grouping violates Rule 2 (Homogeneity) and the node violates Rule 1 (Summation).

## 4. The MECE Audit (Four Questions)

MECE (Mutually Exclusive, Collectively Exhaustive) tests whether a grouping is *a grouping* or a list of heterogeneous points pretending to be one (Animalz [Source 21, practitioner], StrategyU [Source 22, practitioner], Slideworks [Source 17, consulting]).

**The Four MECE Audit Questions** (derived from Animalz [Source 21]):

1. **Does each sibling directly answer the parent's question?** (CE of the parent.)
2. **Do any two siblings cover the same ground under different labels?** (ME overlap.)
3. **Is there an obvious case the grouping skips?** (CE gap.)
4. **Does reordering change meaning?** (Logical-order grouping, must then pass Rule 3.)

**Failed-grouping examples (for critic prompts).**

- **Overlap.** "Millennials / Online shoppers": a person can be both ([Source 21]). Corrected: segment on one dimension.
- **Gap.** "Under 18 / 18-35 / 36-65": leaves out everyone over 65 ([Source 21]).
- **Overlap and gap.** "Digital / Retail / B2B sales": online B2B belongs in two, licensing missing ([Source 29]). Corrected: "Online / In-store / Wholesale / Licensing."
- **Category mismatch.** Fish Sticks under "Baked" fails. Fix: "Bakery / Frozen / Fresh" ([Source 22]).
- **Same-thing-twice.** "How to plan your content pipeline / How to build your editorial calendar": same activity described twice ([Source 21]).

**Position on "MECE is impossible."** Critics argue perfect MECE is unachievable in fuzzy domains ([Source 21], [Source 22]). Take the pragmatic line: MECE is a *direction*, not a threshold. A grouping with overlap or gap a reader would notice fails. A grouping that is MECE relative to the parent's question passes. Phase prompts should run the Four MECE Audit Questions *against the parent's question*, not against a Platonic taxonomy.

## 5. Vertical vs Horizontal Logic (Inductive vs Deductive)

(Operational form from Adrian [Source 12], Mossuz [Source 27], Product Mindset [Source 19].)

- **Inductive grouping.** Siblings are members of the same class, nameable by one plural noun. Example: "Three reasons revenue dropped: lost enterprise deal, SKU churn, seasonal softness."
- **Deductive grouping.** Siblings are argumentative steps connected by "therefore." Example: "All public venues suffer pandemic effects. Restaurants are public venues. Therefore restaurants suffer pandemic effects." ([Source 27]).

**Position.** Sources converge on the practical rule that inductive groupings are more robust (disproving one member does not collapse the conclusion); deductive is tighter but fragile (StrategyU [Source 1]; Mossuz [Source 27]). We recommend the skill **default to inductive at every level above the leaves**, using deductive only where a causal chain is load-bearing. This matches the McKinsey "here are three reasons" tradition over syllogistic decks and avoids the brittleness Lethain and StrategyU both flag.

**The Inductive-or-Deductive Audit:**

1. *"What plural noun names this group?"* If yes, inductive (apply Rule 2).
2. *"Can I read this as 'X, therefore Y, therefore Z'?"* If yes, deductive.
3. *"If I delete one sibling, does the conclusion still hold?"* Survives suggests inductive; dies suggests deductive.

## 6. The So-What Test and the Why-Is-That-True Test

The pyramid's vertical logic is tested in two directions. Top-down: *why is that true?* Bottom-up: *so what?*

**The So-What Test.** Adrian's form: summary nodes must avoid being "intellectually blank" ([Source 12]). Instead of "three reasons," specify the actual effect. Raybould's **Caveman Answer Test** is the simplest version: *"Can you reduce your position to 'Good or Bad? Happy or Sad?' If not, your core message lacks clarity"* ([Source 15, practitioner]).

**Worked example from GLOBIS (raise request, [Source 52]):**

- Brought in more clients. So what? Boosted company revenue.
- Built and trained new team. So what? Created alignment with mission.
- Upgraded critical thinking skills. So what? Enabled faster, higher-quality work.

Each child-level fact is not yet a summary-worthy finding. The So-What chain pushes each fact up until it names an effect the reader cares about.

**The Why-Is-That-True Test.** Applied top-down, it probes claims for support. Mental Models ([Source 43]): *"Inability to answer 'Why is that true?' indicates weak foundational claims."* Every non-leaf node should pass this test against its children.

**The So-What / Why Chain:**

1. Ask "so what?" upwards at every internal node: does the summary earn its place, or is it a category label?
2. Ask "why is that true?" downwards: do children supply evidence, or restate the parent?
3. If both fail, the node is a ghost; delete and regroup.

## 7. Restructuring Existing Prose: Reverse-Engineering a Draft

When the user brings a draft, the procedure inverts. Lethain's bottom-up ([Source 41, practitioner]) and StrategyU's top-down ([Source 47, practitioner]) combine into:

**The Reverse-Engineering Procedure:**

1. **Extract.** List every assertion in the draft as a one-line bullet.
2. **Cluster.** Group bullets that answer the same implicit question; tentatively name each cluster.
3. **Name the governing thought** for each cluster in one sentence. Ban category-label summaries. (Dry run of the So-What Test.)
4. **Identify the governing thought of the whole.** If it is not in the draft at all, the draft was exploring, not concluding.
5. **Test with MECE.** Run the Four MECE Audit Questions on the top-level grouping; collapse overlaps, name gaps.
6. **Test with Q-A alignment.** Does each cluster's governing thought answer a question the apex raises? If not, the cluster is orphaned evidence, either promote its question to a sibling of the apex's question or cut the cluster.
7. **Sequence.** Apply Rule 3: pick one of chronological / structural / comparative / deductive, then recurse.
8. **Rewrite the opener as SCQA last,** once the apex is stable, so you do not manufacture a complication to justify the answer.
9. **Re-render prose.** Write each node's summary first, then its evidence.

**Prose signs a draft needs this procedure** ([Source 41], [Source 43]):

- Conclusion appears in paragraph 3 or later (buried lede).
- Opening paragraph is throat-clearing without a complication.
- Argument shifts mid-document; the author changed their mind and did not rewrite.
- Summary sentences are labels ("There are three reasons...") rather than findings.

## 8. Grouping-Size Guidance: A Position on 3-5

**Sources disagree.** Numeric claims in the literature:

| Claim | Source | Status |
|---|---|---|
| 3 ("rule of three") | Ranadive [Source 8], Slideworks [Source 17, consulting] | McKinsey tradition |
| 2-4 | Archbee [Source 51] | Practitioner |
| 3-5 | Kavanaugh [Source 50] | Practitioner |
| 3-7 | Buteau [Source 5] | Invokes Miller's 7 plus-or-minus 2 |
| 4 deductive / 5 inductive | Phlix [Source 6] | Practitioner |
| ~4 chunks | Cowan 2001, e.g. [Source 1] | Cognitive science |

**Position. Default to 3, accept up to 5, treat 6+ as a MECE failure until proven otherwise.** When practitioners cap at 5, they do so because groupings that balloon past 5 almost always contain redundancy (ME failure) or heterogeneity (Rule 2 failure); cognitive limits are a secondary justification. A genuine list of seven quarterly KPIs is fine, but it is a list, not a MECE grouping. Skill prompt: *"If a grouping has more than 5 items, run the MECE Audit before defending the size."*

**On "never one subsection."** Phlix ([Source 6]): *"Never use only one subsection at any pyramid level."* A lone child means the parent was either trivial or not a grouping. Treat as a critic flag, not a hard error.

## 9. Failing-Pyramid Diagnostics (Prose Symptoms to Logic Causes)

Each prose-level symptom maps to a specific audit failure and a named repair.

| Prose Symptom | Logic Cause | Repair |
|---|---|---|
| Buried lede | Apex not stated first | Rewrite opener; promote Answer |
| Throat-clearing opener | Manufactured complication | Apply the SCQA Opener Audit; if C has no cause, either cut the opener or find the real C |
| Category-label summaries ("three reasons...") | Intellectually blank node | Apply the So-What Test; rewrite as finding |
| Two sections covering the same ground | ME failure | Apply MECE Audit Q2; merge or redefine boundaries |
| Obvious topic missing | CE failure | Apply MECE Audit Q3; add the gap or narrow the question |
| Section that does not answer the implied question | Rule 2 / Q-A alignment failure | Apply the Q-A Alignment Audit; re-parent or cut |
| Argument shifts mid-document | Mid-draft pivot not reconciled | Apply the Reverse-Engineering Procedure from scratch |
| Weak claim nobody would challenge | Apex is a truism | Apply the Caveman Answer Test |
| Claim with no evidence beneath it | Why-Is-That-True failure | Add children or cut the claim |
| Lone subsection under a parent | Parent is not a grouping | Collapse parent into its single child, or find real siblings |
| Formulaic feel despite correct structure | Emotion layer missing (see section 11) | Consider whether the pyramid is the right frame for this document |

A phase prompt implementing critic review can cite this table: *"For each prose symptom from section 9, check whether the draft exhibits it, and if so, apply the named repair."*

## 10. Before/After Micro-Examples (Worked)

### 10.1 Launch-Delay Memo ([Source 43])

**Before (buried lede):** "Hi team, Last week we met with the vendor to discuss timeline changes. After reviewing sprint capacity and two open integration tickets, we think the right call is to push the launch. We'll sync Tuesday. So we need to push the launch to March 15."

**After (pyramid):** "We need to push the launch to March 15. Three reasons: vendor sprint capacity cannot absorb remaining integration work by our target date; two open integration tickets block user-facing functionality; a Tuesday sync is scheduled to confirm. Next actions: (a) notify stakeholders, (b) update the roadmap, (c) confirm vendor commitment Tuesday."

*What the audit caught.* The apex was buried in paragraph 3. The Why-Is-That-True test produced the three reasons; one item (Tuesday sync) was evidence pretending to be a conclusion, so the So-What Test demoted it into next-actions.

### 10.2 Churn Memo ([Source 17, consulting])

**Before (inverted):** Churn memo led with charts, correlations, and segment deep-dives; the ask appeared at the end.

**After (pyramid):**
> I propose we dedicate our next strategic planning session to devising effective churn reduction initiatives for the car insurance division.
> - Car insurance churn is above average and is the single largest contributor to total churn.
> - Our existing retention initiatives do not target this division specifically.
> - Two candidate initiatives (pricing-band review; onboarding redesign) are sized and ready.

*What the audit caught.* The original was ordered by *evidence shape*, not *reasons to act*. Repartitioning into three importance-ordered siblings (severity, coverage gap, readiness) made the grouping answer the apex's implicit question: *why this division, why now?*

### 10.3 Raise Request ([Source 52])

**Before (category labels):** "I deserve a raise for three reasons: I brought in more clients, I built and trained a new team, and I upgraded my critical thinking skills."

**After (So-What chain applied):** "I am asking for a raise because I have increased the company's leverage across three dimensions: revenue (more clients, boosting company revenue), organisational capacity (a new team now aligned with the mission), and decision velocity (stronger critical thinking enabling faster, higher-quality work)."

*What the audit caught.* The before children are activities, not outcomes. The So-What Test promoted each to a business outcome (revenue, capacity, velocity). The apex shifted from "I deserve a raise for these three reasons" (a label) to "I have increased the company's leverage" (a finding the reader is actually being asked to concede).

## 11. Domain Limits and When NOT to Use the Pyramid

**The pyramid flattens emotional persuasion.** Ideas on Stage ([Source 46, practitioner]): the pyramid "doesn't really take into account how humans actually work" on feel/do axes. For keynote speeches, donor pitches, anything where pathos carries the argument, the pyramid is a subcomponent at best.

**The pyramid presents finished thinking; it does not produce it.** Lethain ([Source 41]) and Buteau ([Source 5]) both stress this. Applying it during exploration forces premature conclusions. The skill's first phase should check whether the user is *discovering* or *presenting*; if discovering, defer the pyramid phases.

**MECE can fail in fuzzy domains** (section 4) and **SCQA can produce manufactured complications** (section 2): both already addressed in context.

**Consultant's Mind's exceptions** ([Source 53, consulting]): do not use the pyramid for (a) interim presentations sharing raw information, or (b) comprehensive leave-behind decks written as references. Even MBB firms violate the pyramid in these genres.

**Scope recommendation:**

- **Works for:** executive memos, recommendation decks, problem-solution one-pagers, analytical reports, case-interview answers, project proposals, incident postmortems (partly).
- **Does not work for:** narrative longform, personal essays building to a realisation, exploratory or discovery documents, emotionally-driven persuasion, creative writing, in-progress thinking, pedagogical walk-throughs of a discovery arc.

The skill should detect the genre early and decline to apply the pyramid when the user is writing one of the second-list genres. Phase prompts can cite section 11 by name: *"Before applying the pyramid, check the domain limits in section 11."*

## 12. References

Source numbers match `sources.md`. Credibility tags travel inline with the source on each reuse above; full source list available in `sources.md`.

| # | Source | Credibility |
|---|---|---|
| 1 | [StrategyU Book Review Part 1](https://strategyu.co/pyramid-principle-partone/) | practitioner |
| 4 | [Barbara Minto official](https://www.barbaraminto.com/) | vendor |
| 5 | [Antoine Buteau](https://www.antoinebuteau.com/lessons-from-barbara-minto/) | practitioner |
| 6 | [Sebastien Phlix](https://www.sebastienphlix.com/book-summaries/minto-pyramid-principle) | practitioner |
| 7 | [Tosummarise](https://www.tosummarise.com/book-summary-the-pyramid-principle-by-barbara-minto/) | practitioner |
| 8 | [Ameet Ranadive](https://medium.com/lessons-from-mckinsey/the-pyramid-principle-f0885dd3c5c7) | practitioner |
| 12 | [Adrian.idv.hk, 2017](https://www.adrian.idv.hk/2017-12-20-minto/) | practitioner |
| 14 | [MyConsultingCoach](https://www.myconsultingcoach.com/case-interview-pyramid-principle) | consulting |
| 15 | [James Raybould](https://www.linkedin.com/pulse/whats-so-what-pyramid-principle-barbara-minto-james-raybould) | practitioner |
| 17 | [Slideworks](https://slideworks.io/resources/the-pyramid-principle-mckinsey-toolbox-with-examples) | consulting |
| 18 | [StrategyU Part 2](https://strategyu.co/pyramid-principle-2/) | practitioner |
| 19 | [Product Mindset](https://productmindset.substack.com/p/mckinseys-pyramid-framework) | practitioner |
| 20 | [Conversations on Careers, 2025](https://conversationsoncareers.com/2025/10/start-with-the-answer-the-minto-pyramid-principle/) | practitioner |
| 21 | [Animalz MECE](https://www.animalz.co/blog/mece-mutually-exclusive-collectively-exhaustive) | practitioner |
| 22 | [StrategyU MECE](https://strategyu.co/wtf-is-mece-mutually-exclusive-collectively-exhaustive/) | practitioner |
| 27 | [Mossuz](https://mossuz.com/Article/Pyramid.html) | practitioner |
| 29 | [StrategyU MECE examples](https://strategyu.co/mece-examples/) | practitioner |
| 30 | [Corporate Finance Institute](https://corporatefinanceinstitute.com/resources/career/scqa/) | independent |
| 31 | [Antonov](https://antonov.com.au/scqa-framework) | practitioner |
| 34 | [Analytic Storytelling](https://analytic-storytelling.com/scqa-what-is-it-how-does-it-work-and-how-can-it-help-me/) | vendor |
| 35 | [StrategyU SCQA](https://strategyu.co/scqa-a-framework-for-defining-problems-hypotheses/) | practitioner |
| 37 | [SlideModel](https://slidemodel.com/scqa-framework-guide/) | vendor |
| 39 | [Analyst Academy](https://www.theanalystacademy.com/powerpoint-storytelling/) | consulting |
| 41 | [Lethain](https://lethain.com/pyramid-principle/) | practitioner |
| 42 | [Untools](https://untools.co/minto-pyramid/) | independent |
| 43 | [Mental Models](https://mental-models.com/minto-pyramid/) | practitioner |
| 46 | [Ideas on Stage, 2019](https://www.ideasonstage.com/news/2019/04/16/2019-04-16-is-barbara-minto-s-pyramid-principle-outdated/) | practitioner |
| 47 | [StrategyU Top-Down](https://strategyu.co/pyramid-principle-part-2-communicate-top-down/) | practitioner |
| 50 | [Jeff Kavanaugh](https://jeffkavanaugh.net/pyramid-principle-craft-coherent-explanations/) | practitioner |
| 51 | [Archbee](https://www.archbee.com/blog/book-review-the-pyramid-principle-logic-in-writing-and-thinking-by-barbara-minto) | practitioner |
| 52 | [GLOBIS Insights](https://globisinsights.com/career-skills/critical-thinking/pyramid-principle/) | practitioner |
| 53 | [Consultant's Mind, 2012](https://www.consultantsmind.com/2012/06/21/pyramid-principle/) | consulting |
