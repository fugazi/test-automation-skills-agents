---
name: qa-investigation
description: 'Investigate and resolve a specific test failure to its root cause, and hand off to the implementation skill. Detects whether a failing test is flaky (intermittent) or a deterministic bug during reproduction, then documents the evidence, the decision, and the why. Use when a test fails and you need the real cause rather than just making it green. Execution layer, not strategy review. Keywords: flaky test, intermittent failure, debugging tests, root cause analysis, test failure triage, bug hunt, stabilizing a suite, why does this test fail.'
license: 'Complete terms in LICENSE.txt'
---

# QA Investigation

A persistent, file-backed investigation journal for **a specific failing test**. Use it when a test fails and you need to find the root cause rather than just patch the symptom.

This is the **execution layer** for failure investigation. It resolves a concrete failure; it does **not** validate test strategy or architecture (that is `grill-me-qa`) and does not generate QA deliverables from requirements (that is `qa-manual-istqb`). If you are doing a full strategy/planning exercise instead of investigating one failure, use those skills.

The core idea: file-based planning as working memory. Your context window is volatile RAM; the filesystem is persistent disk. Writing goals, evidence, and decisions to markdown prevents context drift during a long, multi-step investigation.

## When to Use This Skill

- A test fails intermittently (flaky) or deterministically (bug), and you need the root cause.
- An investigation spans many tool calls, multiple runs, or more than one session.
- You want a durable record of what you found, decided, and why.

## When NOT to Use This Skill

This skill investigates a *specific failure*. It is not the right tool for:

- **Authoring a test from scratch** — this is creation, use the relevant automation/framework skill.
- **Designing a test framework or coverage strategy** — that is strategy validation (`grill-me-qa`) or artifact generation (`qa-manual-istqb`).
- **Simple questions or quick lookups** (fewer than ~5 tool calls) — no persistent investigation needed.
- **General review of non-test production code.**

The boundary is **not** "is it a selector / a browser issue / an API timeout" — any of those can be worth investigating. The boundary is whether the request needs a **persistent, multi-step root-cause investigation** or is a one-shot tactical task. If it is a single quick answer ("what does this error mean", "how do I write X"), hand off to the implementation skill. If uncovering the *why* will take evidence, runs, and iteration, use this skill.

## Tool Agnosticism

This method is independent of any test tool or framework — Playwright, Selenium, Cypress, REST/API tools, mobile (Appium), embedded, unit test runners, load tools, and so on. Terms that appear below like "browser", "selector", "network requests", or "CI vs local" are **illustrative, not requirements**. Substitute the equivalent concepts in your own stack:

- *browser / selector* → the UI or interface you drive (web page, native screen, API endpoint, device).
- *network requests* → any external dependency or mock the test relies on.
- *CI vs local* → the environments where the difference manifests (deploy pipeline, staging vs production, device farm vs workstation).

## Core Pattern

```
Context Window = RAM (volatile, limited)
Filesystem     = Disk (persistent, unlimited)

Anything important gets written to disk.
```

After many tool calls, the original goal drifts out of the attention window. Re-reading the plan brings it back. This is the single most important pattern in file-backed investigation.

## File Purposes

Each investigation creates three files in the **project root**:

| File | Purpose | When to Update |
|------|---------|----------------|
| `qa_investigation_plan.md` | Goal, phases, decisions, error log | After each phase completes |
| `qa_investigation_findings.md` | Root cause, evidence, technical decisions | After ANY discovery |
| `qa_investigation_progress.md` | Session log, run/result records | Throughout the session |

## The Investigation Flow

The phases are the same whether the failure is flaky or a deterministic bug. The skill **discovers** the classification during triage — it does not assume it up front.

### Phase 1: Reproduction & Triage
- Reproduce the failure reliably.
- **Determine: is it intermittent (flaky) or deterministic (bug)?** This is a finding, not an input.
- Isolate variables — e.g. run with/without parallelism, repeat N times, compare one environment vs another.
- Record the classification (including "non-reproducible") and the evidence that supports it.
- **Goal:** a confirmed reproduction **or** a documented non-reproducible failure.

**Non-reproducible path:** if the failure cannot be reproduced after a bounded number of attempts (e.g. 3 targeted runs with varied conditions), do **not** force a classification. Instead:
1. Record it as **non-reproducible** with the partial evidence captured (logs, stack trace, run ID, environment snapshot).
2. Note the suspected nature — infrastructure / environment, application logic, or test-side timing.
3. **Escalate or flag for observation** rather than guess: if it looks like an application or infrastructure issue, route to the owning team; if it may be test-side, keep it under watch with a documented reproduction method.
4. In every case, log the decision and the reason in `findings.md` so the knowledge is not lost even though the failure wasn't nailed.

### Phase 2: Evidence Collection
- Capture logs, stack traces, screenshots, traces, retry counts, network/dependency activity, timings.
- Multimodal content (images, browser/page data, PDFs) does not persist in context — write it to `findings.md` as text immediately.
- Note environment specifics: build/version, platform/OS, device, data conditions, worker count.
- **Goal:** enough evidence to form a defensible hypothesis.

### Phase 3: Hypothesis & Root Cause
- Form the leading hypothesis (race condition, timing, selector/view issue, app bug, environment, shared state, data flakiness).
- Test the hypothesis; confirm or reject it.
- Record the confirmed cause and the evidence that proves it.
- **Goal:** a confirmed root cause, not a guess.

### Phase 4: Fix & Validation
- Decide the fix (test fix vs product fix) and, critically, the alternatives you rejected and why.
- Apply it, then validate with repeated runs to confirm stability.
- **Goal:** a stable, verified fix with a documented decision.

### Phase 5: Prevention
- Decide how to prevent recurrence: a shared helper, a lint rule, documentation, a regression guard.
- Record the preventive action(s) in the plan.
- **Goal:** the failure does not come back silently.

## Critical Rules

1. **Create the plan first.** Never start a complex investigation without the plan file. This is non-negotiable — the plan is your persistent memory.
2. **The 2-Action Rule.** After every 2 search/browse/read operations, immediately save key findings to `findings.md`. Multimodal content (images, browser results, PDF contents) does not persist in context — capture it as text before it is lost.
3. **Read before decide.** Before any major decision, re-read `qa_investigation_plan.md`. This pushes goals back into the recent attention window, counteracting the "lost in the middle" effect after many tool calls.
4. **Update after act.** After completing any phase, mark its status (`in_progress` -> `complete`), log errors, and note files created/modified in `progress.md`.
5. **Log ALL errors.** Every error goes in the plan, with the attempt number and resolution.
6. **Never repeat failures.** If an action failed, the next action must be different. Track what you tried and mutate the approach.
7. **Classify after reproducing, not before.** Never label a failure as "flaky" or "bug" until Phase 1 evidence supports it. A wrong early classification poisons the whole investigation.

## Invest Judgement Early (Triage the Effort)

Not every failure warrants the full five-phase pipeline. Before starting, triage the **investment**:

- **High value / blocking** (P1): repeat, full investigation, fix, prevention. This is a critical path or a suite-bloking failure.
- **Medium value**: investigate to root cause and fix, but keep scope tight.
- **Low value / cosmetic flake**: record the evidence and classification, capture the suspected cause, and move on without building the full pipeline or gold-plating the fix.

Match the depth of the investigation to the cost of the failure. A cosmetic flake is a note; a suite-bloking flake is a project.

## Investigation Completion (Exit Criteria)

The investigation is **done** when all of the following are true:

1. Every phase is marked complete (or explicitly closed as not applicable).
2. The root cause is recorded with supporting evidence, or the failure is documented as non-reproducible with the suspected nature and escalation.
3. The fix is applied and validated stable over repeated runs.
4. A prevention action is recorded (even if deferred with a reason).

## File Lifecycle (Close or Archive)

Investigations generate three files each. Do not let them pile up. When an investigation completes:

1. **Consolidate** the durable conclusion into the shared suite knowledge (e.g. a runbook, a known-issues doc) so the learning outlives the session.
2. **Close or archive** the three `qa_investigation_*` files — rename/archive them under a done/ directory or remove them if no longer needed.
3. **Do not** leave orphaned plan files behind; an active, stale plan is noise. Only keep a plan file open for an investigation that is genuinely in progress.

## 3-Strike Error Protocol

```
ATTEMPT 1: Diagnose & Fix
  -> Read the error carefully
  -> Identify root cause
  -> Apply a targeted fix

ATTEMPT 2: Alternative Approach
  -> Same error? Try a different method
  -> Different tool? Different technique?
  -> NEVER repeat the exact same failing action

ATTEMPT 3: Broader Rethink
  -> Question assumptions
  -> Search for solutions
  -> Consider updating the plan

AFTER 3 FAILURES: Escalate to User
  -> Explain what you tried (with an attempt log)
  -> Share the specific error
  -> Ask for guidance
```

## Read vs Write Decision Matrix

| Situation | Action | Reason |
|-----------|--------|--------|
| Just wrote a file | Don't read it | Content still in context |
| Viewed an image/screenshot/PDF | Write findings NOW | Multimodal content does not persist |
| Page/dependency data returned | Write to file | Transient state does not persist |
| Starting a new phase | Read plan/findings | Re-orient if context is stale |
| Error occurred | Read relevant file | Need current state to fix |
| Resuming after a gap | Read all planning files | Recover full state |

## 5-Question Reboot Test

If you can answer these from your planning files, context is solid:

| Question | Answer Source |
|----------|--------------|
| Where am I? | Current phase in `qa_investigation_plan.md` |
| Where am I going? | Remaining phases |
| What is the goal? | Goal statement in plan |
| What have I learned? | `qa_investigation_findings.md` |
| What have I done? | `qa_investigation_progress.md` |

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| State the goal once and forget | Re-read plan before decisions |
| Hide errors and retry silently | Log every error to the plan |
| Stuff everything in context | Store large content in files |
| Start executing immediately | Create the plan file FIRST |
| Repeat failed actions | Track attempts, mutate approach |
| Assume flaky or bug before reproducing | Classify in Phase 1 from evidence |
| Mask a race with a longer timeout | Fix the root cause |
| Use fixed sleeps to "stabilize" | Use conditional waits (state/response/availability) |
| Label a non-reproducible failure | Record it as non-reproducible and escalate/flag |
| Leave orphaned plan files | Close or archive them on completion |

## References

- [Templates](references/templates.md) — starter templates for all three files
- [Flow](references/flow.md) — the investigation methodology in detail
- [Examples](references/examples.md) — real flaky and bug cases
