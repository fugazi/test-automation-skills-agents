# QA Investigation — Examples

> Part of the `qa-investigation` skill. See [SKILL.md](../SKILL.md) for full context.

Concrete examples of how the investigation plays out. Tool-agnostic: each shows
the reasoning, not a specific framework. The terms are illustrative — substitute
your own stack.

## Example 1 — Flaky (intermittent) failure

**Symptom:** a test fails ~30% of the time in the CI pipeline, but always passes
locally. The failure is a timeout waiting on a UI control.

**Phase 1 — Triage.** Reproduce by varying parallelism: with a single worker it
passes; with many workers it fails intermittently. This isolates the trigger and
classifies it as **flaky (intermittent)**, not a deterministic bug.

**Phase 2 — Evidence.** Capture a trace showing the click fired before the
control's handler was ready. Note the environment: CI with parallel workers.

**Phase 3 — Root cause.** A race condition: the test drove the action before the
application finished wiring the handler for the control. The click was lost.

**Phase 4 — Fix.** Wait on the dependency/state to be ready before acting, plus a
bounded retry with backoff. Rejected alternative: a blanket longer timeout (it
only hides the race) and a fixed sleep (it is fragile and machine-dependent).

**Phase 5 — Prevention.** Extract a shared "wait until ready" helper, add a lint
rule that rejects fixed sleeps in new tests, and document the pattern.

**Outcome:** stable — 0 fails over 100 runs.

---

## Example 2 — Deterministic bug

**Symptom:** a test fails every time under the same conditions, with a consistent
assertion mismatch.

**Phase 1 — Triage.** Reproduces consistently on repeat and regardless of
parallelism. Classified as **deterministic bug**, not flaky.

**Phase 2 — Evidence.** A clear, reproducible assertion failure with a stable
stack trace and the exact expected-vs-actual values.

**Phase 3 — Root cause.** An application logic error surfaced by the test — not a
test-side timing issue.

**Phase 4 — Fix.** The fix belongs in the product. Route to the owning team with
the evidence; the test stays as a regression guard.
> Decide test-side vs product-side fix explicitly. A product bug should not be
> papered over in the test.

**Phase 5 — Prevention.** Keep the test as a guard and add a targeted test around
the fixed behavior.

---

## Example 3 — Non-reproducible failure

**Symptom:** a failure appeared in CI once, with an incomplete log, and could not
be reproduced after several attempts.

**Phase 1 — Triage.** Cannot be reproduced after a bounded number of attempts
with varied conditions. **Do not force a label.** Record it as non-reproducible,
capture partial evidence (run id, partial log, environment snapshot), and note the
suspected nature (e.g. infrastructure or environment).

**Phase 2–5.** Because there is no reproduction and no confirmed cause, do not
fabricate a root cause. Escalate or flag for observation, and record the decision
and reason so the effort is not lost.

**Outcome:** documented as non-reproducible with suspected nature and an
escalation path, rather than a guessed answer.

---

## Using the files with these examples

Each example above would populate `qa_investigation_plan.md`,
`qa_investigation_findings.md`, and `qa_investigation_progress.md` following the
[templates](templates.md). Do not invent a root cause for a failure you could not
reproduce.
