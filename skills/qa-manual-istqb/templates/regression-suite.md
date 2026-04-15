# Regression Suite Definition

## Purpose

- What this suite protects (critical user journeys, revenue flows, compliance)

## Scope

- In scope / out of scope
- Platforms/browsers/devices covered

## Suite tiers and intent

- **Smoke**: minimal critical-path checks (fast, gating)
- **Sanity**: build verification after change (targeted)
- **Regression**: broad coverage of stable, high-value areas
- **Full**: release-level coverage (may include extended non-functional)

## Selection criteria (risk-based)

- Risk exposure (impact × likelihood)
- Usage frequency and business criticality
- Defect history / escape rate
- Change hotspots and integration points
- Stability for automation (for automated subsets)

## Tags and execution

- Tag conventions (example): `@smoke`, `@sanity`, `@regression`, `@full`
- Playwright examples:
  - `npx playwright test --grep @smoke`
  - `npx playwright test --grep @regression`

## Maintenance rules

- Add a regression test when: a defect escapes, a high-risk feature ships, critical flow changes
- Remove or rewrite tests when: obsolete behavior, flaky/unstable areas, duplicated coverage
- Review cadence and ownership

## Ownership

- Suite owner:
- Contributors:

