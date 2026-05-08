# Plugin manifest templates

One per runtime. Write only the manifests this marketplace uses (per Probe 1: Claude Code, Codex, or both). Both manifests start at `0.1.0` for new plugins.

## .claude-plugin/plugin.json

```json
{
  "name": "<plugin-name>",
  "version": "0.1.0",
  "description": "<one-line description>",
  "author": { "name": "{{author}}" },
  "license": "{{license}}",
  "keywords": ["<keyword-1>", "<keyword-2>", "<keyword-3>"]
}
```

## .codex-plugin/plugin.json

```json
{
  "name": "<plugin-name>",
  "version": "0.1.0",
  "description": "<one-line description>",
  "author": { "name": "{{author}}" },
  "license": "{{license}}",
  "keywords": ["<keyword-1>", "<keyword-2>", "<keyword-3>"],
  "skills": "./skills/",
  "interface": {
    "displayName": "<Plugin Display Name>",
    "shortDescription": "<short human-facing description>",
    "longDescription": "<longer human-facing description, two or three sentences>",
    "developerName": "{{author}}",
    "category": "Productivity",
    "capabilities": ["Interactive", "Read", "Write"],
    "defaultPrompt": [
      "<starter prompt 1>",
      "<starter prompt 2>"
    ],
    "screenshots": []
  }
}
```
