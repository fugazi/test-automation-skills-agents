# AI Testing Interrogation — Expanded Question Bank

When the grilling touches Dimension 4 (AI Integration), apply heightened scrutiny. AI in testing is powerful but introduces non-determinism, trust issues, and maintenance burdens that must be explicitly addressed.

> **Gate question (required first):** *"Are you using or planning to use AI tools for testing?"*
>
> - If **NO**: this dimension is **Resolved / Not Applicable**. Confirm with 1-2 quick validation questions (e.g., *"Is there a documented reason AI is excluded?"*, *"Is there a plan to revisit this in the next 6 months?"*), mark the dimension resolved, and move on. Do **not** spend the question budget here.
> - If **YES**: work through the **Core questions** below (4.1–4.4). The **Deep-dive** sections (4.5–4.7) are optional — use them only if a core answer surfaces a real risk or the user is operating AI tooling at scale.
> - If **AMBIGUOUS** ("evaluating", "partially", "ad-hoc", "developers use Copilot but nothing is automated"): treat as **YES** and work through 4.1–4.4 focused on the *actual current* usage. "Evaluated and decided against" → treat as **NO**, log the rationale.

**Core vs. deep-dive:** Questions 4.1–4.4 are the core interrogation — every team using AI in testing should resolve them. Questions 4.5–4.7 are for teams with a mature or high-volume AI practice. Skip them unless the core answers point to a gap.

---

## 4.1 Where does AI enter the testing workflow? *(core)*

### Interrogation points

- **Test generation:** Is AI generating test code from specs, Gherkin, or natural language descriptions?
- **Test healing:** Is AI auto-fixing broken selectors, assertions, or page structure changes?
- **Visual regression:** Is AI being used for intelligent visual diffing (vs pixel comparison)?
- **Triage & analysis:** Is AI analyzing test failures, grouping similar failures, or suggesting root causes?
- **Test selection:** Is AI selecting which tests to run based on code changes?
- **Test data generation:** Is AI generating test data, edge cases, or boundary values?

### Recommended answer

Adopt AI incrementally, lowest-risk first:

1. **Triage** (lowest risk) — AI analyzes failures and groups them. Wrong output wastes time, doesn't cause false confidence.
2. **Visual regression** — Mature technology. AI-assisted diffing reduces false positives vs pixel diff.
3. **Test generation** (medium risk) — AI generates test drafts. Mandatory human review before merge.
4. **Test healing** (higher risk) — Auto-fixing broken tests. Must be opt-in, logged, and reviewed.
5. **Test selection** (highest risk) — AI decides what to test. Always maintain a fallback to full suite.

Never deploy AI-based test selection without a safety net (random sampling of non-selected tests).

---

## 4.2 How are AI-generated tests validated for correctness? *(core)*

### Interrogation points

- Who reviews AI-generated tests before they are merged?
- What criteria define a "correct" AI-generated test?
- How do you verify the test is testing the right thing — not just passing?
- What is the mutation testing strategy? (Can the test catch intentional bugs?)
- How do you handle tests that pass for the wrong reason (tautological tests)?

### Recommended answer

Every AI-generated test must pass a four-gate review:

1. **Behavioral gate:** Does the test verify the intended behavior? (Reviewer reads the test and confirms it matches the spec.)
2. **Mutation gate:** Introduce a deliberate bug in the code under test. Does the test fail? If not, the test is worthless.
3. **Stability gate:** Run the test 10 times. If it flakes even once, it fails.
4. **Readability gate:** Can a new team member understand what the test does and why it exists without asking the author?

AI-generated tests that fail any gate are rejected, not patched. Re-prompt and regenerate.

---

## 4.3 What is the human-in-the-loop boundary? *(core)*

### Interrogation points

- What decisions can the AI make autonomously?
- What decisions require human approval?
- Is there a "trust threshold" after which the AI gets more autonomy?
- How is the audit trail maintained? (Who decided what, when?)
- What happens when the AI and the human disagree?

### Recommended answer

Define clear autonomy tiers:

| Tier | AI Action | Human Role |
|------|-----------|------------|
| 1 | Suggest | Human reviews and decides |
| 2 | Draft | Human reviews, edits, approves |
| 3 | Execute + log | Human reviews logs post-action, can revert |
| 4 | Autonomous | No human review (reserved for lowest-risk, well-established patterns) |

Start everything at Tier 1-2. A task can only advance to Tier 3 after 95%+ accuracy over 100+ executions with human verification. Tier 4 is reserved for deterministic, reversible actions (e.g., formatting test output).

Maintain a complete audit log: every AI action records what was done, what prompt triggered it, what model was used, and what the outcome was.

---

## 4.4 How are hallucinations and non-deterministic outputs mitigated? *(core)*

### Interrogation points

- What temperature/decoding settings are used for test generation?
- How are AI outputs validated against the actual application behavior?
- What happens when the AI generates code that doesn't compile or references non-existent elements?
- How do you handle AI tests that pass today and fail tomorrow (semantic drift)?

### Recommended answer

- Use low-temperature settings (0.0-0.3) for test generation to reduce randomness.
- Validate every AI-generated selector/assertion against the live application during review. Never trust AI descriptions of UI structure.
- For semantic drift: run AI-generated tests in a "canary" mode for 7 days before promoting to the main suite. If the test flakes or fails during canary, it is not ready.
- Maintain a feedback loop: track AI test quality metrics (rejection rate, post-merge flakiness, mutation score) and feed back into prompt engineering.

---

## 4.5 What is the cost/token budget for AI-assisted testing? *(deep dive — optional)*

### Interrogation points

- What is the per-PR cost of AI test generation?
- What is the monthly cost of AI triage/analysis?
- How is cost tracked and attributed?
- What happens when the budget is exceeded?
- Are there fallback strategies when AI is unavailable (rate limits, outages)?

### Recommended answer

- Track AI cost per category: generation, triage, healing, selection.
- Set a monthly budget with alerts at 50%, 75%, and 100%.
- When budget is exceeded: generation stops (falls back to manual), triage continues (low cost), healing continues (high value).
- Always maintain a non-AI fallback path for every workflow. If the AI provider is down, tests must still run, triage must still happen (manually), and the pipeline must not break.
- Cost efficiency metric: cost per valid test generated. If AI generates 100 tests at $50, but only 20 pass all four gates, the real cost is $2.50 per valid test. Track this.

---

## 4.6 What AI tools are selected and why? *(deep dive — optional)*

### Interrogation points

- What tools were evaluated? (GitHub Copilot, Cursor, Claude, ChatGPT, specialized tools)
- What are the selection criteria? (accuracy, integration, cost, ecosystem, security)
- Does the tool support the team's framework and language?
- Is the tool's output deterministic enough for CI use?
- What is the vendor lock-in risk?
- How does the tool handle proprietary or sensitive code?

### Recommended answer

Document a tool comparison matrix with these criteria:

1. **Accuracy** — Mutation score of generated tests (objective metric)
2. **Integration** — Does it work with the existing framework/CI/IDE?
3. **Cost** — Per-developer or per-request pricing
4. **Security** — Does the tool train on your code? Is data sent to external servers?
5. **Determinism** — Same input, same output? (Critical for CI reproducibility)
6. **Portability** — Can you switch tools without rewriting all tests?

Prefer tools that integrate with the existing IDE and CI pipeline over standalone tools. Avoid tools that require sending proprietary code to external servers without explicit security review. For test generation specifically, evaluate with a standardized benchmark (e.g., generate tests for 10 known features and score the output).

---

## 4.7 Ownership: Who owns the test — the human or the AI tool? *(deep dive — optional)*

### Interrogation points

- If an AI-generated test fails in production, who is responsible?
- Is there a code ownership header or annotation on AI-generated tests?
- How are AI-generated tests maintained over time?
- Can the same AI tool update the test later, or must a human do it?

### Recommended answer

- **Humans own all tests, regardless of how they were created.** AI is a tool, not an author.
- Every AI-generated test must have a human owner (code ownership annotation or team assignment).
- Tag AI-generated tests in the test metadata (e.g., `@ai-generated @reviewed-by:username`) for tracking quality over time.
- When an AI-generated test breaks, the human owner is responsible for fixing it — not delegating back to the AI tool. If the human cannot understand the test well enough to fix it, the test should be deleted and rewritten.
- Track AI vs human test quality metrics separately: flakiness rate, bug detection rate, maintenance cost. If AI tests are consistently lower quality, adjust the generation strategy.
