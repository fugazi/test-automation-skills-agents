---
name: qa-investigation
description: 'Investigate a specific test failure to its root cause and document the why. Detects whether a failing test is flaky (intermittent) or a deterministic bug during reproduction. Use when a test fails and you need the real cause, not just to make it green. Execution layer, not strategy review. Keywords: flaky test, intermittent failure, debugging tests, root cause analysis, test failure triage, bug hunt, why does this test fail.'
license: 'Complete terms in LICENSE.txt'
---

# QA Investigation

A persistent, file-backed investigation journal for **a specific failing test**. This is the **execution layer**: it resolves a concrete failure. It does **not** validate strategy or architecture (`grill-me-qa`) nor generate QA deliverables (`qa-manual-istqb`).

The core idea: your context window is volatile RAM; the filesystem is persistent disk. Writing goals, evidence, and decisions to markdown prevents context drift during a long investigation.

## When to Use This Skill

- A test fails intermittently (flaky) or deterministically (bug), and you need the root cause.
- The investigation spans many tool calls, multiple runs, or more than one session.
- You want a durable record of what you found, decided, and why.

## When NOT to Use This Skill

- **Authoring a test from scratch** — use the relevant automation/framework skill.
- **Designing a framework or coverage strategy** — strategy validation (`grill-me-qa`) or artifact generation (`qa-manual-istqb`).
- **Simple questions or quick lookups** (fewer than ~5 tool calls).
- **General review of non-test production code.**

The boundary is **not** "is it a selector / browser issue / timeout" — any of those can be worth investigating. The boundary is whether the request needs a **persistent, multi-step root-cause investigation** or is a one-shot tactical task. If uncovering the *why* takes evidence, runs, and iteration, use this skill.

## Tool Agnosticism

This method is independent of any test framework — web, API, mobile, embedded, unit, load. Terms like "browser", "selector", "network requests", or "CI vs local" are **illustrative, not requirements**; substitute the equivalent in your stack.

## Core Process

The phases are the same whether the failure is flaky or a deterministic bug. The skill **discovers** the classification during triage — it does not assume it up front.

### Phase 1: Reproduction & Triage
- Reproduce reliably; isolate variables (parallelism, repeat count, environment, data/state).
- Determine: **intermittent (flaky), deterministic (bug), or non-reproducible?** This is a finding, not an input.
- Record the classification and the evidence that supports it.
- **Goal:** a confirmed reproduction **or** a documented non-reproducible failure.

> **Non-reproducible path:** if the failure cannot be reproduced after a bounded number of attempts, do **not** force a label. Record it as non-reproducible with partial evidence, note the suspected nature (infrastructure, app logic, or test-side timing), and **escalate or flag for observation**. Log the decision and reason to `qa_investigation_findings.md`. See [Flow](./references/flow.md) for detail.

### Phase 2: Evidence Collection
- Capture logs, stack traces, screenshots, traces, retry counts, dependency activity, timings.
- Multimodal content (images, page/dependency data, PDFs) does not persist in context — write it to `qa_investigation_findings.md` as text immediately.
- **Redact sensitive data** (tokens, cookies, credentials, email addresses, PII) before persisting; do not write raw screenshots, traces, logs, or network captures verbatim — summarize them in text with sensitive parts masked.
- Note environment specifics: build/version, platform, device, data conditions, worker count.
- **Goal:** enough evidence for a defensible hypothesis.

### Phase 3: Hypothesis & Root Cause
- Form the leading hypothesis (race condition, timing, selector/view issue, app bug, environment, shared state, data flakiness).
- Test it in a way that can reject it; confirm or reject; record the confirmed cause and the evidence.
- **Goal:** a confirmed root cause, not a guess.

### Phase 4: Fix & Validation
- Decide the fix (test-side vs product-side) and, critically, the alternatives you rejected and why.
- Apply it, then validate stability over repeated runs.
- **Goal:** a stable, verified fix with a documented decision.

### Phase 5: Prevention
- Decide how to prevent recurrence: a shared helper, a lint rule, documentation, a regression guard.
- Record the preventive action(s).
- **Goal:** the failure does not come back silently.

## File Purposes

Scale the file scope to the investment level (triaged at the start — see [Flow](./references/flow.md)). Higher value = fuller record; lower value = leaner:

| Investment | Files in project root | How much to write |
|------------|----------------------|-------------------|
| **P1** high-value / blocking | All three: `plan` + `findings` + `progress` | Full pipeline: goal, phases, decisions, errors, run log |
| **P2** medium | `plan` + `findings` | Phases and the why; `progress` only if the session runs long |
| **P3** low-value / cosmetic flake | `findings` only | Evidence + classification + suspected cause; move on |

Each investigation creates the files above in the **project root**:

| File | Purpose | When to Update |
|------|---------|----------------|
| `qa_investigation_plan.md` | Goal, phases, decisions, error log | After each phase completes |
| `qa_investigation_findings.md` | Root cause, evidence, technical decisions | After ANY discovery |
| `qa_investigation_progress.md` | Session log, run/result records | Throughout the session |

## Critical Rules

1. **Create the plan first** — non-negotiable; the plan is your persistent memory. For a **P3** (low-value) case, the `findings` file is the plan — create that first.
2. **2-Action Rule** — after every 2 read/search ops, save key findings to `qa_investigation_findings.md`.
3. **Read before decide** — re-read the plan before major decisions.
4. **Update after act** — mark phase status, log errors, note files changed.
5. **Log ALL errors** — with attempt number and resolution.
6. **Never repeat failures** — if an action failed, the next must differ.
7. **Classify after reproducing, not before** — a wrong early label poisons the investigation.

## References

- [Flow](./references/flow.md) — methodology detail, effort triage, completion criteria, file lifecycle, error protocols, anti-patterns
- [Templates](./references/templates.md) — starter templates for the three investigation files
- [Examples](./references/examples.md) — flaky, bug, and non-reproducible cases
