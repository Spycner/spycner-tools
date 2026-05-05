# Description Optimization

Iterate on a skill's `description` field in YAML frontmatter to improve triggering accuracy. The skill should fire on prompts where the user actually wants it, and not fire on adjacent prompts where another tool fits better.

The methodology is: generate eval queries, measure trigger rate, rewrite the description, re-measure, iterate.

## When to optimize

Reach for this loop when the description (not the body) is the problem. Signals:

- The skill rarely triggers when users ask for it. The description is too narrow or too vague.
- The skill triggers on prompts where another tool fits better. The description is too broad.
- Users say "I asked for X and you ignored my skill."

Distinguish from neighboring modes:

- Mode B "Iterate" addresses output quality (the skill triggers, but produces poor results). Fix the body, not the description.
- Mode C "Pressure-test" addresses rule compliance under pressure (the skill triggers and runs, but the host bypasses its rules). Fix the body or add explicit guardrails.

If users get the right outputs but the skill never fires, you are in description optimization. If the skill fires but produces wrong outputs, you are not.

## How skill triggering works

Each installed skill exposes metadata (name plus description) in the host agent's `available_skills` list. The host decides whether to load the skill body based on that description. The body is not consulted until the description matches.

Two consequences shape eval design:

1. Simple, one-step queries may not trigger any skill, even with a perfect description. The host can handle "read this file" directly without loading skill bodies. This is correct behavior, not a triggering failure.
2. Complex or specialized queries reliably trigger skills when the description matches. These are where description quality matters.

Good eval queries are substantive enough that the host would actually benefit from loading the skill. Trivial queries test nothing.

## Step 1: Generate eval queries

Generate 16 to 20 queries total. Aim for 8 to 10 should-trigger and 8 to 10 shouldn't-trigger.

**Realism rules.** Use concrete file paths, named columns, company names, casual phrasing, occasional typos, and mixed lengths. Not "extract text from PDF" but: "ok so my boss just sent me this xlsx file (its in my downloads, called something like 'Q4 sales final FINAL v2.xlsx') and she wants me to add a column for profit margin".

**Should-trigger coverage.** Include:

- Different phrasings of the same intent (formal and casual).
- Cases where the user does not name the skill or file type explicitly.
- Edge cases where the skill competes with another but should win.

**Shouldn't-trigger coverage.** Include:

- Near-misses (queries sharing keywords with the skill but needing something else).
- Adjacent domains.
- Ambiguous phrasing where a naive keyword match would fire but shouldn't.

**Avoid obviously irrelevant negatives.** "Write a fibonacci function" tells you nothing about a PDF skill's discrimination. The skill never matched on that prompt regardless of description quality. Tricky negatives surface real overtriggering.

## Step 2: User review of eval queries

Present the eval set to the user before running anything. Bad eval queries lead to bad descriptions, so this gate matters.

Allow the user to edit queries, toggle the `should_trigger` flag, add new ones, and remove weak ones. Save the approved set to:

```
/tmp/<skill>-trigger-eval/eval-set.json
```

Shape:

```json
[
  { "query": "the user prompt", "should_trigger": true },
  { "query": "another prompt", "should_trigger": false }
]
```

Treat this file as the ground truth for the rest of the loop.

## Step 3: Train/test split

Split the approved set 60/40 into train and test. Hold out the test split for the end. The user does not see the test split until the final iteration.

The final description is selected by test-split score, not train-split score. This avoids overfitting: a description tuned exclusively against train queries can score perfectly there and still regress on unseen prompts.

## Step 4: Measure trigger rate

For each query in the train set, dispatch the host model 3 times via subagents.

Platform mapping:

- Claude Code: `Agent` tool with `subagent_type: general-purpose`.
- Codex: equivalent subagent dispatch.

The subagent prompt:

```
Read this user message: "<query>".
Without responding to the user, list which skills (if any)
you would load to handle this. Return only the skill names
you would load.
```

For each query:

- Record whether the skill in question is named in the response.
- Trigger rate per query = (invocations) / 3.

For the run as a whole:

- A query is "correctly handled" when `should_trigger` matches actual trigger > 0.5.
- Score = sum of correct decisions / total queries.

Record per-query results. They drive the next step.

## Step 5: Rewrite description

Look at the misses:

- Should-trigger queries that did not fire (description too narrow or too vague).
- Shouldn't-trigger queries that did fire (description too broad).

Propose a new description that addresses those misses. Constraints:

- **Under 1024 characters total.** Frontmatter limit.
- **Third person.** "Use when the user wants to..." not "I help with...".
- **Lead with explicit triggers.** Specific phrases users say, file types, named tools.
- **Do NOT summarize the skill's workflow.** Workflow summaries create a shortcut: the host follows the description and skips the body. Triggers only.
- **Cover the misses.** If "scaffold" prompts missed, add "scaffold" as a trigger phrase. If "format my data" triggered wrongly, add a non-trigger or sharpen the domain.

Each iteration's description should be a targeted change, not a rewrite from scratch. Track which misses motivated each edit.

## Step 6: Re-measure on train

Run the same procedure as Step 4 with the new description. Compare train-set scores between iterations.

If the new description improves train score, hold it as a candidate for test eval. If it regresses, discard and try a different angle on the same misses.

## Step 7: Final test-set evaluation

Move to the held-out test set only when train has converged. Convergence means:

- 5 iterations maximum, OR
- No improvement across 2 consecutive iterations.

Run the held-out test set against each candidate description that improved on train. The winning description is the one with the highest test-set score, not the highest train score. A description that scored 0.9 on train and 0.6 on test loses to one that scored 0.8 on train and 0.8 on test.

## Step 8: Apply the winner

Write the winning description into SKILL.md frontmatter.

Show the user a before/after side-by-side and report:

- Final train score for the winner.
- Final test score for the winner.
- Number of iterations.

Commit with the `chore` scope:

```
chore(<plugin>): tune <skill> description for triggering
```

## Anti-patterns

Five concrete failure modes, each one we have actually seen:

1. **Over-broad descriptions.** "For any text task" triggers on adjacent topics and pulls the skill into prompts it has no business handling. Sharpen the domain.
2. **Over-narrow descriptions.** "For files named *.csv only" misses legitimate use ("my data file", "the spreadsheet from finance"). Cover the phrasings real users actually type.
3. **Workflow-summary descriptions.** "Use when implementing plans, dispatch subagent per task, review between tasks" creates a shortcut. The host reads the description, follows the workflow it implies, and skips the body. The body becomes documentation no one reads. Keep descriptions to triggers; put workflow in the body.
4. **Iterating only on the train set.** Over time the description overfits to train queries and test score regresses. The test split exists precisely to catch this. Use it.
5. **Skipping user review of eval queries.** The eval set is the ground truth for the whole loop. If it is wrong (mislabeled, unrealistic, missing edge cases) every downstream score is meaningless. The Step 2 gate is not optional.

## Attribution

Methodology adapted from the upstream `skill-creator:skill-creator` skill by Anthropic, MIT-licensed.

The upstream provides a Python script (`run_loop.py`) that automates this loop using `claude -p` subprocess calls, with extended thinking for description proposals and an HTML report at the end. This file describes the same conceptual loop in the pgoell-claude-tools repo's voice and uses the host agent's subagent dispatch instead of bundling Python.

For the upstream's full take, including extended thinking and per-query reliability analysis, see that skill directly.
