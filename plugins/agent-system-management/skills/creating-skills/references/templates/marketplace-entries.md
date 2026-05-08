# Marketplace entry templates

Insert into the `plugins` array of the matching marketplace manifest. Only edit the manifests Probe 1 found.

## Claude Code marketplace entry

Insert into `{{marketplace_claude_path}}` (only if probe 1 found this manifest):

```json
{
  "name": "<plugin-name>",
  "source": "./{{plugin_dir}}/<plugin-name>",
  "description": "<one-line description>",
  "version": "0.1.0"
}
```

## Codex marketplace entry

Insert into `{{marketplace_codex_path}}` (only if probe 1 found this manifest):

```json
{
  "name": "<plugin-name>",
  "source": {
    "source": "local",
    "path": "./{{plugin_dir}}/<plugin-name>"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Productivity",
  "interface": {
    "displayName": "<Plugin Display Name>",
    "shortDescription": "<short human-facing description>"
  }
}
```
