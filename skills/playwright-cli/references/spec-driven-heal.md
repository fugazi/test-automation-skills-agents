# Spec-driven testing — Heal phase

> Part of the `playwright-cli` skill. See [SKILL.md](../SKILL.md) for full context.
>
> **Related:** this is the Heal phase, split from [spec-driven-testing.md](spec-driven-testing.md). See that file for the Planning and Generate phases.

Goal: fix failing tests, and update the spec if the app's intended behaviour changed.

### 3.1 Find failing tests

```bash
PLAYWRIGHT_HTML_OPEN=never npx playwright test
```

Record the list of failing `<file>:<line>` entries and process them one at a time. Do not attempt parallel fixes — shared state and the single CLI session make that fragile.

### 3.2 Debug one failure

Run the single failing test in debug mode in the background, then attach:

```bash
PLAYWRIGHT_HTML_OPEN=never npx playwright test tests/<group>/<scenario>.spec.ts:<line> --debug=cli
# wait for "Debugging Instructions" and the tw-XXXX session name
playwright-cli attach tw-XXXX
```

The test is paused at the start. Step forward or run to until just before the failing action or assertion, then diagnose:

```bash
playwright-cli snapshot                # did the element change / move / rename?
playwright-cli console                 # app-side errors?
playwright-cli requests                # failed request? wrong payload?
playwright-cli show --annotate         # ask the user to point somewhere
```

Common causes: selector drift, new wrapper element, label/ARIA rename, timing (transition, async load), assertion text updated in the app, test data leaking between runs.

Rehearse the corrected interaction with `playwright-cli` — the generated code in the output is what you paste back into the test.

### 3.3 Apply the fix

Edit the test file: update the locator, assertion, step order, or inputs to match the corrected behaviour. Stop the background debug run. Rerun the single test to confirm green.

Never skip hooks or add sleeps as a fix. Never use `networkidle`.

### 3.4 Reconcile with the spec

Open the spec referenced by the `// spec:` header in the test file and locate the scenario that matches the test.

- **Fix was purely technical** (locator drift, better assertion shape) and the spec's user-level behaviour still matches the app → leave the spec alone.
- **Fix changed user-visible steps, inputs, order, or expected outcomes** that the spec describes → update the spec to match reality. Keep the scenario id and file path stable; only the step / expect lines change.
- **Unclear whether the app change is intentional** (spec is stale) **or a regression** (test was right, app is wrong) → **stop and ask the user**. Provide:
  - the scenario id (e.g. `2.3`),
  - the spec lines that no longer match,
  - the observed app behaviour (quote a snapshot excerpt or a concrete outcome).

Only after the user answers, either update the spec (intentional change) or file/flag the test as covering a bug (regression).

### 3.5 Iteration and giving up

- Fix failures one at a time; rerun after each.
- If after thorough investigation you are confident the test is correct but the app is wrong *and* the user has confirmed it's a bug: mark the test `test.fixme(...)` with a comment pointing at the user's decision or issue link. Never silently skip.
