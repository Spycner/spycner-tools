---
name: using-workbench
description: Use when starting any conversation alongside using-superpowers. Announces workbench's currently-shipped skills, defers meta-rules to using-superpowers, and resolves slug collisions in workbench's favor.
---

# Using Workbench

This skill is a thin companion to `using-superpowers`. Workbench layers on top of the upstream Superpowers plugin and forks individual skills as Pascal commits to owning them.

## Relationship to using-superpowers

The meta-rules for working with skills (when to invoke them, how to treat triggers, the "even 1% relevance" rule, the rule against rationalizing past skill use, the SUBAGENT-STOP block, the platform tool-name mapping) are owned by `using-superpowers`. This skill does NOT restate them.

If `superpowers` is not installed, see `references/using-superpowers-upstream.md` in this skill directory for the meta-rules in their original form, frozen at upstream version 5.0.7. Either install upstream, or promote that content into this skill body.

## Workbench skills

Today, Workbench ships:

- `brainstorming`: design dialogue that turns an idea into a spec, with a visual-companion mode

As more skills are forked into Workbench, add them to this list and promote relevant chunks from `references/using-superpowers-upstream.md` into this skill body.

## Slug collision rule

When a skill name exists in both Workbench and Superpowers, prefer the Workbench version. Today the only collision is `brainstorming`. The host agent should resolve the bare slug `brainstorming` to `workbench:brainstorming`.

## Reference file

`references/using-superpowers-upstream.md` is a verbatim snapshot of the upstream `using-superpowers/SKILL.md` at version 5.0.7. It exists so that, as more skills are ported, their corresponding chunks of meta-guidance can be lifted out of the snapshot and into this skill body.
