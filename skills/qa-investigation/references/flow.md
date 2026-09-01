# QA Investigation — Methodology and Reference

> Part of the `qa-investigation` skill. See [SKILL.md](../SKILL.md) for full context.

Tool-agnostic: substitute the concepts for your own stack. Terms like "browser",
"selector", "CI vs local" are illustrative, not requirements.

## How the classification emerges

Do not decide "flaky vs bug" up front. It is a **finding of Phase 1**, derived
from evidence, not an input. The method is identical whether the outcome is
"flaky", "bug", or "non-reproducible" — only the recorded conclusion differs.

## Phase-by-phase detail

### Phase 1 — Reproduction & Triage

**Goal:** a reliably reproduced failure, or a documented non-reproducible one.

1. Run the failing test by itself (minimal noise) to confirm it fails.
2. Vary conditions to isolate the trigger:
   - parallelism (single worker vs many)
   - repeat count (does it fail 1/10, 5/10, 10/10?)
   - environment (the failing pipeline vs a local/other environment)
   - data / state (fresh vs shared vs reused)
3. Classify from evidence:
   - **Intermittent (flaky)** — fails sometimes, passes others, under changing conditions.
   - **Deterministic (bug)** — fails consistently under the same conditions.
   - **Non-reproducible** — fails here and there, can't be pinned down after N tries.

> **Non-reproducible path (mandatory, don't guess):** after a bounded number of
> attempts with varied conditions, record it as non-reproducible rather than
> forcing a label. Capture partial evidence (logs, stack trace, run id,
> environment snapshot). Note the suspected nature — infrastructure/environment,
> application logic, or test-side timing. Then **escalate or flag for
> observation** instead of pretending to have an answer. Log the decision and
> reason to `qa_investigation_findings.md`, so the effort is not lost even when the failure
> couldn't be pinned.

### Phase 2 — Evidence Collection

**Goal:** enough evidence to form a defensible hypothesis.

- Capture logs, stack traces, screenshots, traces, retry counts, dependency
  activity, timings, and the exact failing assertion.
- Multimodal content (screenshots, page/dependency data, PDFs) does not persist
  in context — write the key facts to `qa_investigation_findings.md` as text immediately.
- **Redact sensitive data** (tokens, cookies, credentials, email addresses, PII) before
  persisting; do not write raw screenshots, traces, logs, or network captures verbatim —
  summarize them in text with sensitive parts masked.
- Record environment specifics: build/version, OS/platform, device, data
  conditions, worker count, test-run id.

### Phase 3 — Hypothesis & Root Cause

**Goal:** a confirmed root cause, not a guess.

1. List candidate causes: race condition, timing, selector/view issue,
   application bug, environment, shared state, data flakiness.
2. Rank by likelihood given the evidence; pick the leading hypothesis.
3. Test it in a way that can reject it (not just confirm).
4. Write the confirmed cause and the evidence that proves it.
5. If the hypothesis is rejected, record why and move to the next candidate.

### Phase 4 — Fix & Validation

**Goal:** a stable, verified fix with a documented decision.

1. Decide the fix locus: **test-side** (fix the test/waits/cleanup) or
   **product-side** (fix the app, log a bug). Document the choice.
2. Record the alternatives you rejected and **why** — this is as valuable as
   the fix itself.
3. Apply the fix, then validate stability over repeated runs.
4. Confirm the fix did not just hide the symptom (no blanket timeouts, no fixed
   sleeps).

### Phase 5 — Prevention

**Goal:** the failure does not come back silently.

- Add a shared helper / wait utility to remove the repeated pattern.
- Add a lint rule or static check to reject the anti-pattern in new tests.
- Document the pattern in the repo's contributing / test guide.
- Add a regression guard or targeted test around the fixed behavior.

## Invest Judgement Early (Triage the Effort)

Not every failure warrants the full five-phase pipeline. Before starting, triage
the **investment**; it also sets the **file scope** (see SKILL.md File Purposes):

- **P1 — High value / blocking:** full investigation, fix, prevention. Files:
  `plan` + `findings` + `progress` (full record).
- **P2 — Medium value:** investigate to root cause and fix, keep scope tight.
  Files: `plan` + `findings`; add `progress` only if the session runs long.
- **P3 — Low value / cosmetic flake:** record the evidence and classification,
  capture the suspected cause, then move on. File: `findings` only (it serves as
  both the plan and the record).

Match the depth of the investigation — and the number of files — to the cost of
the failure. Do not over-document a trivial flake, and do not under-document a
blocking one. For a P3, the `findings` file is created first (it is the plan);
session log / run history is not required.

## Critical Rules (detail)

1. **Create the plan first** — non-negotiable; the plan is your persistent memory.
2. **2-Action Rule** — after every 2 read/search ops, save key findings to
   `qa_investigation_findings.md`; multimodal content does not persist in context.
3. **Read before decide** — re-read the plan before major decisions.
4. **Update after act** — mark phase status, log errors, note files changed.
5. **Log ALL errors** — with attempt number and resolution.
6. **Never repeat failures** — if an action failed, the next must differ.
7. **Classify after reproducing, not before** — a wrong early label poisons the
   investigation.

## 3-Strike Error Protocol

```text
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

## Completion (exit criteria)

The investigation is done when:

1. Every phase is complete (or explicitly closed as not applicable).
2. The root cause is recorded with evidence, or the failure is documented as
   non-reproducible with suspected nature and escalation.
3. The fix is applied and validated stable over repeated runs, **or** the issue is
   documented as requiring escalation or a product-owner handoff (for non-reproducible
   failures or product-owned bugs), with the owner and relevant evidence recorded.
4. A prevention action is recorded (even if deferred with a reason).

## File lifecycle

1. On completion, consolidate the durable conclusion into shared knowledge
   (runbook, known-issues doc, suite doc).
2. Close or archive the three `qa_investigation_*` files.
3. Do not leave orphaned plan files behind.
