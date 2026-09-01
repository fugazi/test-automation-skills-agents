# QA Investigation — Methodology (Flow)

This expands the five-phase investigation into a working procedure. It is
tool-agnostic: substitute the concepts for your own stack.

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
> reason to `findings.md`, so the effort is not lost even when the failure
> couldn't be pinned.

### Phase 2 — Evidence Collection

**Goal:** enough evidence to form a defensible hypothesis.

- Capture logs, stack traces, screenshots, traces, retry counts, dependency
  activity, timings, and the exact failing assertion.
- Multimodal content (screenshots, page/dependency data, PDFs) does not persist
  in context — write the key facts to `findings.md` as text immediately.
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

## Triage the effort first

Not every failure needs the full pipeline. Before starting, judge the depth:

- **High value / blocking (P1):** full investigation + fix + prevention.
- **Medium value:** investigate to root cause and fix, scope tight.
- **Low value / cosmetic flake:** record the evidence and classification,
  capture the suspected cause, then move on without gold-plating.

Match the depth of the investigation to the cost of the failure.

## Completion (exit criteria)

The investigation is done when:

1. Every phase is complete (or explicitly closed as not applicable).
2. The root cause is recorded with evidence, or the failure is documented as
   non-reproducible with suspected nature and escalation.
3. The fix is applied and validated stable over repeated runs.
4. A prevention action is recorded (even if deferred with a reason).

## File lifecycle

1. On completion, consolidate the durable conclusion into shared knowledge
   (runbook, known-issues doc, suite doc).
2. Close or archive the three `qa_investigation_*` files.
3. Do not leave orphaned plan files behind.
