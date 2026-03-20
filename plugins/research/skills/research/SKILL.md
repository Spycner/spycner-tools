---
name: research
description: Use when the user wants to research a topic, investigate something, conduct a deep dive, find sources and citations, write a research report, or craft an optimized research prompt for external AI tools like OpenAI or Gemini. Triggers on research intent — not simple factual questions Claude can answer directly.
---

# Research Skill

Universal entry point for all research requests. Refines the user's intent, then either dispatches the deep-research agent or generates an optimized prompt for external tools.

---

## Auth Approach

No authentication required. Uses WebSearch and WebFetch (no credentials needed) and writes to the local filesystem.

## Tool Preference

1. **Agent tool** — to dispatch the deep-research agent for execution
2. **WebSearch** — for inline research if agent dispatch fails
3. **WebFetch** — for inline content retrieval if agent dispatch fails
4. **Write** — for saving prompts to file when requested
5. **Read** — for reading the agent definition and reference files
6. **Bash** — for directory creation and date generation

## Workflow

### Step 1: Clarify

Ask scoping questions one at a time or in small batches:
- Main research questions / what specifically to explore
- Timeframe (last 2 years? historical?)
- Geographic scope (if relevant)
- Audience (who will read this?)
- Purpose (what decisions will this inform?)
- Source preferences (academic, industry, news, docs)
- Specific angles, perspectives, or controversies to explore

If the request is already clearly scoped (e.g. "research the impact of tariffs on EU automotive exports since 2024"), skip redundant questions — just confirm scope and proceed.

### Step 2: Route

Once intent is clear, ask: "Should I run this research now, or generate an optimized prompt you can use in another tool (OpenAI, Gemini, etc.)?"

- **Run now** → proceed to Step 3 (dispatch agent)
- **Generate prompt** → proceed to Prompt Output section below

### Step 3: Configure & Dispatch

Before dispatching, allow overrides:
- **Output path** — default: `reports/{topic-slug}-{YYYY-MM-DD}/`
- **Mode** — deep (default) or quick
- **Creative** — true or false (default: false). Enables original framework generation via Phase 5.5 in the agent. Works with both deep and quick modes.

Default to deep mode unless the user signals quick: "quick look at", "brief overview of", "what's the deal with".

Then dispatch the deep-research agent:

1. Read `agents/deep-research.md` from this plugin directory
2. Use the **Agent tool** to spawn a subagent with a prompt containing:
   - The refined research query
   - The selected mode (deep/quick)
   - The creative flag (true/false)
   - The output path (absolute)
   - Any user-specified constraints (timeframe, source preferences, etc.)
3. When the agent completes, report the output path and a brief summary to the user

## Prompt Output

When the user wants a prompt for external tools, generate a structured prompt:

```
### TASK
[Clear, specific research objective]

### CONTEXT/BACKGROUND
[Why this matters and how it will be used]

### SPECIFIC QUESTIONS OR SUBTASKS
1. [First specific question]
2. [Second specific question]
...

### KEYWORDS
[Relevant search terms and concepts]

### CONSTRAINTS
- Timeframe: [specified timeframe]
- Geography: [specified scope]
- Source Types: [preferred sources]

### OUTPUT FORMAT
[Preferred format with specific requirements]

### FINAL INSTRUCTIONS
Remain concise, reference sources accurately, and provide evidence-based analysis.
```

Output directly in conversation. Optionally save to a file if the user requests it.

## Self-Healing

- **Agent dispatch fails:** Fall back to running the research workflow inline (in the main conversation). Warn the user that context may get heavy. Follow the same phases described in the agent definition.
- **User changes mind mid-research:** The agent runs independently. They can start a new research request with revised scope.
- **Output directory not writable:** Check permissions, suggest an alternative path, or ask the user where to save.

## Behavioral Guidelines

- Trigger on research intent (investigate, deep dive, report, sources) — not simple factual questions Claude can answer from training data
- When in doubt: "Would you like me to do a thorough research investigation, or just answer from what I know?"
- If the user asks for both a research run AND a prompt, do both — run the agent and also output the prompt
- See `report-template.md` for report structure and `research-recipes.md` for search patterns
