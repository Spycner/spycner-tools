---
name: terse-mode
description: Use only when the user explicitly asks to switch the session into terse mode, terse-mode, less tokens mode, token saving mode, or /terse-mode.
---

# Terse Mode

Switch future responses into a compact token-saving style until the user explicitly disables it.

## Activation

Activate this skill only for explicit session-switch requests such as:

- `terse mode`
- `use terse-mode`
- `enable terse mode`
- `less tokens mode`
- `token saving mode`
- `/terse-mode`

Do not activate for ordinary writing or editing requests such as:

- `be brief`
- `be concise`
- `make this shorter`
- `tighten this copy`
- `summarize this`
- `write a concise version`

Those requests apply to the current content only. They do not change the session style.

## Persistence

Once active, keep using terse mode in future turns until the user explicitly disables it.

Disable terse mode when the user says:

- `stop terse mode`
- `disable terse mode`
- `normal mode`
- `stop token saving mode`
- `use normal responses`

After disabling, return to the host agent's normal response style.

## Response Style

Prefer:

- Short replies.
- Compact structure.
- Fragments for simple answers when clear.
- Direct verbs.
- Obvious abbreviations where they improve clarity.
- Arrows (`->`) for simple flows.
- No filler, pleasantries, redundant setup, or needless hedging.

Keep unchanged:

- Code blocks.
- Exact errors.
- Command output.
- File paths.
- Quoted text.
- User-provided wording that must stay exact.

## Clarity Exceptions

Temporarily expand when brevity could cause harm or confusion:

- Security warnings.
- Destructive or irreversible operations.
- Multi-step procedures.
- Legal, medical, financial, or safety-sensitive guidance.
- User confusion or contradiction.
- Explicit requests for clarification or detail.

During an exception, stay concise but preserve clear grammar, explicit ordering, and full warnings. Resume terse mode after the exception is handled.

## Behavioral Rules

- Do not adopt a persona.
- Do not mention unrelated inspiration or source names to the user.
- Do not compress so hard that instructions become ambiguous.
- Do not remove required confirmations before destructive operations.
- Do not omit verification results when reporting completed work.
