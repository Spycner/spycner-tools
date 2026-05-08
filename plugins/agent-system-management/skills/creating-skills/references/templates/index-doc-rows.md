# Top-level plugin index doc templates

Edit `{{plugin_index_doc}}` (only the docs Probe 6 found). Use whichever shape your existing index doc already follows.

## Variant A: skills table row

When the index doc uses a markdown table per skill:

```markdown
| `<skill-name>` | <plugin-name> | <what the skill does, one short clause> |
```

## Variant B: per-plugin section

When the index doc uses a section per plugin:

```markdown
### <plugin-name>

<One-line description of the plugin.>

**Skills:**
- `<skill-name>`: <what the skill does>
```

## Variant C: current-plugins table row

When the index doc tracks plugin versions in a table:

```markdown
| `<plugin-name>` | 0.1.0 | `<skill-1>`, `<skill-2>` |
```

The version field is bumped in lockstep with the plugin manifests; see Probe 7's `{{lockstep_files}}` set.
