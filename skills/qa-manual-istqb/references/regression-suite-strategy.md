# Regression suite strategy (risk-based)

> Part of the `qa-manual-istqb` skill. See [SKILL.md](../SKILL.md) for full context.

## Principles

- Optimize for risk reduction, not maximum test count.
- Keep tiers fast-to-slow; use smoke as a gating suite.
- Rebalance when product risk changes (new features, incidents, high-change areas).

## Tagging approach (Playwright-friendly)

- Use Playwright's `tag` annotation (e.g., `{ tag: '@smoke' }`) — never in test titles — so CI can run subsets via `--grep`.
- Keep the tag taxonomy small: exactly one of `@smoke`, `@sanity`, `@regression`, `@e2e`, `@api`, `@destructive` per test; document it in the suite definition.

## Add/remove rules

- Add tests for:
  - Escaped defects (regression prevention)
  - High-risk areas with change
  - Critical integrations
- Remove or rewrite tests that are:
  - Duplicated coverage
  - Obsolete behavior
  - Flaky without a clear oracle

## Health metrics

- Suite duration per tier
- Flake rate (retries, non-deterministic failures)
- Defect detection effectiveness (escaped defect trends)
