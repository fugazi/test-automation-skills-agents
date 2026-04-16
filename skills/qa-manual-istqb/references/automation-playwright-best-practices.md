# Playwright automation best practices (practical + ISTQB-aligned)

## What to automate (and what not to)

- Automate stable, high-value flows: smoke/regression, critical paths, repeated checks.
- Prefer manual/exploratory for volatile UX, one-off checks, or areas without stable oracles.
- Document automation candidates in the test case set (traceability).

## Structure and readability

- Keep tests independent and deterministic.
- Use clear naming: include test case IDs and suite tags in titles.
- Avoid duplicating setup code; use fixtures/helpers where appropriate.

## Locators and flakiness

- Prefer `getByTestId` (or other stable attributes) over CSS/XPath.
- Avoid sleeps; rely on Playwright auto-waits and assert on observable outcomes.
- Assert on outcomes, not implementation details (ISTQB “test oracle” mindset).

## Data and environments

- Manage test data explicitly (seed/reset when needed; avoid cross-test coupling).
- Log key IDs or artifacts that help triage failures.

## Evidence for defect reporting

- On failures, capture screenshots/video/trace to speed triage.
- Link failures to test case IDs and requirements (traceability).
