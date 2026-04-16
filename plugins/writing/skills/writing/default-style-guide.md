# Default Writing Style Guide

This is the style guide that ships with the writing skill. It reflects opinionated defaults. Any project can override by placing its own `style-guide.md` or `CLAUDE.md` at the project root, or by passing `--style-guide` when invoking the skill.

## 1. Voice and tone

- Declarative, specific, skeptical, no hype
- Short sentences. Long sentences earn their length.
- First person is fine; use it where the writer's experience anchors a claim
- Minimal hedging; take positions
- Conversational with rigor. Optimistic without naïveté. Critical without cynicism.

## 2. Structure

- Thesis lands in the first 150 words
- Each section opens with friction, scene, or stakes (not throat-clearing)
- Scenes ground claims; one citation per scene is enough
- Closing extends the idea or reframes it. Never summarises.

## 3. Sentence-level preferences

- Vary sentence length. Real writing has rhythm.
- Prefer concrete nouns and verbs over abstract framing
- Prefer active voice
- One idea per sentence. Compound thoughts get split.

## 4. Signature moves

- Claim → concrete scene → tradeoff named explicitly
- Receipts inline, not in footnotes
- Counterargument acknowledged then defeated, never strawmanned

(Project-level style guides should grow this list over time.)

## 5. Anti-patterns and blacklist

| Pattern | Solution |
|---|---|
| Em-dashes (the long horizontal character) | Rewrite with comma, period, colon, parentheses, or split into separate sentences |
| En-dashes (the medium horizontal character) | Same as em-dashes |
| Hyphens used as sentence punctuation (e.g., " - " standing in for a comma) | Same |
| "leverage", "navigate the complexities", "harness the power", "robust", "seamless", "unlock", "empower" | Delete or rewrite with concrete language |
| "in conclusion", "to sum up", "at the end of the day" | Delete; let the closing land on its own |
| "some argue that", "many would say", "it's worth noting that" | Delete or attribute the argument specifically |
| Rhetorical questions the author answers in the next sentence | Flip to assertion |
| Correlative constructions: "not X, but Y" | Rewrite as direct claim |
| "Here's the thing", "the truth is", "let's be honest" | Delete |
| Italic emphasis on every key term | Use sparingly; only for genuine emphasis |
| "delve" as a verb | Replace with "dig into", "examine", or remove |

Hyphens in compound words (spec-driven, AI-assisted, two-week) are hyphenation, not punctuation. They stay.

## 6. Positive and negative examples

**Positive (this sounds like the voice):**

> "SDD works. But not for the reason Kiro, Spec Kit, and Tessl sell it. It works because authoring a spec forces you to think before you let an agent write two thousand lines. The spec itself is a crutch. Not a source of truth. If you treat it as one, you will pay for it in six months."

Why this works: declarative, takes a position immediately, short sentences, specific names, threat lands in the closer.

**Negative (this sounds AI-shaped):**

> "It's worth noting that spec-driven development represents an interesting evolution in modern software engineering practices. While there are certainly benefits to consider, it's also important to acknowledge the various tradeoffs that practitioners must navigate when adopting this approach in today's fast-paced development landscape."

Why this fails: hedges ("it's worth noting", "certainly", "various"), abstractions ("interesting evolution", "modern", "today's fast-paced"), takes no position, says nothing.

## 7. Revision checklist

- Does the thesis land in the first 150 words?
- Are there any em-dashes, en-dashes, or hyphens used as sentence punctuation?
- Does each section have a concrete scene or example, not just a citation?
- Is there at least one first-person anchor in the piece?
- Does the closing extend the idea, or does it summarise?
- Are italics used only where they do real emphasis work?
- Would a reader say "I'm not alone in feeling this" or "I learned something specific"?
- Are there any blacklist patterns left in the draft?
