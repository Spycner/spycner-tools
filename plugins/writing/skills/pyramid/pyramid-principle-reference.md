# Pyramid Principle Reference

Condensed operational reference shipped with the pyramid skill. Every phase prompt can cite this file by section.

## 1. The Three Rules [research §1]

1. **Summation.** Each non-leaf node is a finding, not a label. "Revenue grew 23% because of new SKUs" not "Three reasons revenue grew."
2. **Homogeneity.** Siblings are the same kind of idea at the same level of abstraction; one plural noun names the group (reasons, steps, risks, recommendations, causes).
3. **Logical Ordering.** Siblings are ordered chronologically, structurally, comparatively, or deductively. Arbitrary order signals a non-grouping.

## 2. The SCQA Opener [research §2]

External name: SCQA. Internal treatment: SCQ opens, Answer is the apex.

- **S (Situation):** noncontroversial context the reader already agrees with.
- **C (Complication):** the change making S unstable; identifies a cause, not a symptom.
- **Q (Question):** the falsifiable question C forces.
- **A (Answer):** the apex; the pyramid's top.

### The SCQA Opener Audit (four questions)
1. Would the intended reader nod at S without friction?
2. Does C identify a cause, not restate the symptom?
3. Does Q arise from C such that C without Q feels incomplete?
4. Would changing A also require changing C? If not, the opener is decorative.

### Three failure modes
- **Manufactured complication:** SCQA forced onto a document with no real trigger.
- **Question that restates the answer:** "How should we grow revenue?" paired with "By growing revenue."
- **Answer-first bleed:** writer leads with conclusion, backfills S to justify it.

## 3. The Q-A Dialogue Procedure [research §3]

Top-down procedure for greenfield construction:
1. State the Subject.
2. Define Reader and the Question you expect them to have.
3. State the Answer (the governing thought, the apex).
4. Work backwards to write the Situation.
5. Develop the Complication that triggers the Question.
6. Verify S+C produces Q and Q is answered by A.
7. Drop below A: ask "what question does A raise for this reader?" Children answer that one question.
8. Recurse: each new node raises a question the layer below must answer.

### The Q-A Alignment Audit
1. For each non-leaf node, name the question it raises.
2. Verify the grouping below it answers that question as a whole.
3. If children answer different questions, Rule 2 (Homogeneity) fails and Rule 1 (Summation) fails.

## 4. The Four MECE Audit Questions [research §4]

1. Does each sibling directly answer the parent's question? (CE of parent.)
2. Do any two siblings cover the same ground under different labels? (ME overlap.)
3. Is there an obvious case the grouping skips? (CE gap.)
4. Does reordering change meaning? (If yes, must then pass Rule 3 logical order.)

### Failed-grouping examples
- **Overlap:** "Millennials / Online shoppers" (a person can be both).
- **Gap:** "Under 18 / 18-35 / 36-65" (leaves out over 65).
- **Overlap and gap:** "Digital / Retail / B2B sales" (online B2B is in two, licensing missing).
- **Category mismatch:** Fish Sticks under "Baked."
- **Same-thing-twice:** "Plan your pipeline / Build your editorial calendar."

MECE is a direction, not a threshold. A grouping that is MECE relative to the parent's question passes, even if it is not MECE against a Platonic taxonomy.

## 5. Vertical vs Horizontal Logic (Inductive vs Deductive) [research §5]

- **Inductive:** siblings are members of a class; one plural noun names them.
- **Deductive:** siblings are argumentative steps connected by "therefore."

### The Inductive-or-Deductive Audit
1. What plural noun names this group? If answerable, inductive.
2. Can I read this as "X, therefore Y, therefore Z"? If yes, deductive.
3. If I delete one sibling, does the conclusion still hold? Survives = inductive; dies = deductive.

**Position:** default to inductive at every level above the leaves. Use deductive only where a causal chain is load-bearing.

## 6. The So-What Test and the Why-Is-That-True Test [research §6]

### The So-What / Why Chain
1. Ask "so what?" upwards at every internal node: does the summary earn its place, or is it a category label?
2. Ask "why is that true?" downwards: do children supply evidence or restate the parent?
3. If both fail, the node is a ghost; delete and regroup.

### The Caveman Answer Test
Can the position reduce to "Good or Bad? Happy or Sad?"? If not, the core message lacks clarity.

### Worked So-What chain (raise request)
- Brought in more clients. So what? Boosted company revenue.
- Built and trained new team. So what? Created alignment with mission.
- Upgraded critical thinking skills. So what? Enabled faster, higher-quality work.

## 7. The Reverse-Engineering Procedure [research §7]

Mode B (restructure) procedure, steps 1-7 for construction (steps 8 and 9 are handled by the opener and render phases):
1. **Extract.** List every assertion in the draft as a one-line bullet.
2. **Cluster.** Group bullets that answer the same implicit question; tentatively name each cluster.
3. **Name the governing thought** for each cluster in one sentence. Ban category-label summaries.
4. **Identify the governing thought of the whole.** If not in the draft, the draft was exploring, not concluding.
5. **Test with MECE.** Run Section 4's audit questions on the top-level grouping.
6. **Test with Q-A alignment.** Does each cluster's governing thought answer a question the apex raises?
7. **Sequence.** Pick one of chronological / structural / comparative / deductive.

Prose signs a draft needs this procedure:
- Conclusion appears in paragraph 3 or later (buried lede).
- Opening is throat-clearing without a complication.
- Argument shifts mid-document.
- Summary sentences are labels rather than findings.

## 8. Grouping Size [research §8]

Default 3. Ceiling 5. **Six or more items is a MECE-failure signal** until proven otherwise. Also flag: a lone subsection under a parent means the parent was either trivial or not a grouping.

## 9. Failing-Pyramid Diagnostics [research §9]

| Prose Symptom | Logic Cause | Repair |
|---|---|---|
| Buried lede | Apex not stated first | Promote Answer |
| Throat-clearing opener | Manufactured complication | SCQA Opener Audit |
| Category-label summaries | Intellectually blank node | So-What Test |
| Two sections covering same ground | ME failure | MECE Audit Q2 |
| Obvious topic missing | CE failure | MECE Audit Q3 |
| Section does not answer implied question | Q-A alignment failure | Q-A Alignment Audit |
| Argument shifts mid-document | Mid-draft pivot | Rerun Reverse-Engineering Procedure |
| Weak claim nobody would challenge | Apex is a truism | Caveman Answer Test |
| Claim with no evidence beneath | Why-Is-That-True failure | Add children or cut |
| Lone subsection under parent | Parent is not a grouping | Collapse parent or find siblings |
| Formulaic feel despite correct structure | Emotion layer missing | See section 11 domain limits |

## 10. Worked Before/After Examples [research §10]

(Full examples in the research doc section 10. Retained here as few-shot anchors.)

### 10.1 Launch-delay memo
- **Before:** buried lede, "push launch" in paragraph 3.
- **After:** apex first ("Push launch to March 15"), three reasons, next actions.

### 10.2 Churn memo
- **Before:** ordered by evidence shape (charts, correlations).
- **After:** ordered by reasons-to-act (severity, coverage gap, readiness).

### 10.3 Raise request
- **Before:** category labels ("more clients, new team, critical thinking").
- **After:** So-What-promoted outcomes (revenue, capacity, decision velocity).

## 11. Domain Limits: When NOT to Use the Pyramid [research §11]

**Works for:** executive memos, recommendation decks, problem-solution one-pagers, analytical reports, case-interview answers, project proposals, incident postmortems.

**Does not work for:** narrative longform, personal essays building to a realisation, exploratory or discovery documents, emotionally-driven persuasion, creative writing, in-progress thinking, pedagogical walk-throughs. Writers of these genres should be routed to the writing skill instead.
