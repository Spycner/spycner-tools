# Runtime-bridge manifest schema

The scout subagent returns a manifest matching this JSON schema. The apply subagent consumes it and writes an apply-log. The reviewer subagent consumes both manifest and apply-log and writes a verdict.

## Manifest (from scout)

```jsonc
{
  "direction": "claude_to_codex" | "codex_to_claude" | "bidirectional_drift",
  "trust_warning": true,                         // present and true if any op writes into .codex/
  "ops": [ /* see Op shape below */ ],
  "skip": [ /* see Skip shape below */ ],
  "plugin_report": [ /* see Plugin shape below */ ],
  "notes": [ "free-form strings surfaced to the user" ]
}
```

### Op shape

Five op kinds. The `op_index` field referenced by the reviewer is this op's position in the `ops` array.

| kind | required fields | meaning |
|---|---|---|
| `symlink` | `from`, `to` | Create a symlink at `from` pointing to `to`. Both paths are repo-relative. If `from` already exists as a regular file, it is preserved on disk and the op fails with `wrong_target`. |
| `translate` | `from`, `to`, `diff` | Read source at `from`, transform to target format, write at `to`. `diff` is a unified diff preview (informational only) showing what would change. |
| `drift` | `paths`, `newer`, `diff` | Both files at `paths` exist with different content. `newer` is the path with the newer mtime, suggested as canonical. Apply rewires the non-canonical side as a symlink to the canonical side. |
| `rewire-symlink` | `from`, `to` | An existing symlink at `from` points elsewhere; replace its target with `to`. |
| `already-aligned` | `path` | No-op. Recorded so the reviewer can confirm the filesystem is correct. |

### Skip shape

```jsonc
{ "path": "<repo-relative path>", "reason": "<one-line reason>", "suggested_followup": "<one-line user instruction>" }
```

### Plugin shape

```jsonc
{ "name": "<plugin name>", "claude": true | false, "codex": true | false, "source": "<absolute path on disk>" }
```

## Apply-log (from apply)

```jsonc
{
  "executed": [
    { "op": <op_index>, "status": "ok" },
    { "op": <op_index>, "status": "error", "message": "<error text>" }
  ],
  "skipped": [
    { "op": <op_index>, "reason": "<why apply did not perform this op>" }
  ]
}
```

Apply MUST NOT touch any path not in the manifest. If a write requires creating intermediate directories, those directory creations are implicit and not recorded as ops.

## Verdict (from reviewer)

```jsonc
{
  "verdict": "pass" | "issues",
  "issues": [
    {
      "op_index": <int> | null,
      "kind": "missing" | "wrong_target" | "semantic_drift" | "unauthorized_change",
      "detail": "<observation>",
      "suggested_fix": "<what apply should do next round>"
    }
  ]
}
```

### Issue kinds

- `missing`: manifest had op X, post-apply filesystem state does not reflect it.
- `wrong_target`: op X was performed but to the wrong path or with wrong content.
- `semantic_drift`: a `translate` op's output is syntactically valid but lost information (a key from source was not represented in target).
- `unauthorized_change`: filesystem changed in a way not described by any op. The orchestrator MUST stop the loop on this kind.
