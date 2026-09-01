# QA Investigation — File Templates

> Part of the `qa-investigation` skill. See [SKILL.md](../SKILL.md) for full context.

Starter templates for the three planning files. Copy to your project root and
fill in the bracketed sections. Use these with the `qa-investigation` skill.

All three files are tool-agnostic. Terms like "browser", "selector", "CI vs
local" are illustrative — substitute the equivalent concept in your stack.

## qa_investigation_plan.md

```markdown
# QA Investigation Plan — [Brief description]

## Goal
[One sentence describing the end state, e.g. "stabilize the failing checkout test"]

## Investigation

| Phase | Status | Notes |
|-------|--------|-------|
| 1. Reproduction & Triage | [ ] in_progress | |
| 2. Evidence Collection | [ ] pending | |
| 3. Hypothesis & Root Cause | [ ] pending | |
| 4. Fix & Validation | [ ] pending | |
| 5. Prevention | [ ] pending | |

## Classification (discovered in Phase 1, not assumed)
Select exactly one outcome below; fill in the evidence fields for the one chosen.
- [ ] Flaky (intermittent) — evidence:
- [ ] Deterministic bug — evidence:
- [ ] Non-reproducible — evidence / suspected nature / escalation:

## Decisions
| Date | Decision | Rationale | Alternative rejected |
|------|----------|-----------|----------------------|
|      |          |           |                      |

## Errors Encountered
| Date | Error | Attempt | Resolution |
|------|-------|---------|------------|
|      |       |         |            |
```

## qa_investigation_findings.md

```markdown
# QA Investigation Findings

> This is the most valuable file. Record the WHY, not just the WHAT.

## Subject — [test id / description]

- **Symptom:** [what fails, frequency, contexts where it passes/fails]
- **Root cause:** [confirmed cause, proved by evidence]
- **Evidence:**
  - [log / trace / screenshot / run id / reproducer -- summarize in text, redact
    tokens, cookies, credentials, email addresses, and PII before persisting]
  - [environment specifics: build, platform, data, worker count]
- **Fix applied / decision:** [what changed and why]
- **Alternatives rejected:**
  - [option] — [why it was wrong / would mask the issue]
- **Prevention:** [helper, lint rule, regression guard, documentation]

## Decision record — [topic]

| Decision | Rationale | Alternative rejected |
|----------|-----------|----------------------|
|          |           |                      |
```

## qa_investigation_progress.md

```markdown
# QA Investigation Progress

> Append as the investigation advances. Time/results for each step.

## Session — [DATE]
### Step [n] — [phase]
- **Action:** [what you ran / did]
- **Result:** [pass/fail counts, key observation]
- **Files created/modified:**
  -

### Test run results
| Run | Environment/Type | Pass | Fail | Notes |
|-----|------------------|------|------|-------|
|     |                  |      |      |       |

## Open items / next steps
- [ ]
```
