---
name: playwright-regression-testing
description: 'Govern Playwright TypeScript regression suites across many tests. Use when asked to plan, select, tier, execute, or optimize suites with risk/change analysis, tags, CI/CD, sharding, flaky-test management, or suite-health metrics; not for authoring one UI spec. Keywords: regression strategy, smoke tests, test selection, CI pipeline, flaky tests, test sharding, impact analysis, git diff.'
license: 'Complete terms in LICENSE.txt'
---

# Playwright Regression Testing (TypeScript)

Strategy and best practices for automated regression testing of web applications using Playwright with TypeScript.

> **Activation:** This skill is triggered when working with regression test strategy, test suite selection, test prioritization, CI/CD pipeline testing, flaky test management, test sharding, or optimizing test execution for web applications using Playwright.

## When to Use This Skill

- **Plan regression suites** with risk-based and change-based test selection
- **Organize tests** into tiers (smoke, sanity, selective, full regression)
- **Optimize execution** with parallelization, sharding, and time-budget strategies
- **Integrate with CI/CD** using GitHub Actions pipelines
- **Manage flaky tests** with quarantine, retry policies, and root cause tracking
- **Monitor suite health** with execution time, flake rate, and detection metrics
- **Select tests after changes** using git diff analysis and impact mapping

### Do NOT Use For

- Authoring a single UI spec or page-object model (use `playwright-e2e-testing`).
- Driving a live browser interactively for debugging (use `playwright-cli`).
- Selenium/Java regression suites (use `webapp-selenium-testing`).
- API contract testing in isolation (use `api-testing`).

## Prerequisites

| Requirement    | Details                                  |
| -------------- | ---------------------------------------- |
| Node.js        | v18+ recommended                         |
| Playwright     | `@playwright/test` package               |
| TypeScript     | `typescript` configured in project       |
| Browsers       | Installed via `npx playwright install`   |
| Git            | Required for change-based test selection |
| GitHub Actions | Recommended CI/CD platform               |

---

## Quick Reference

**Tiers:** Smoke (<2min, every commit) → Sanity (<10min, every PR) → Selective (<30min, on merge) → Full (<60min, nightly/pre-release).

**Key tags:** `@smoke`, `@sanity`, `@regression`, `@e2e`, `@api`, `@destructive` — exactly one per test, never on `describe()` blocks. Domain-specific extensions (e.g., `@a11y` in accessibility skills) are allowed alongside, but only one execution tag per test.

**CLI:** `npx playwright test --grep @smoke` | `--grep @regression` | `--grep-invert @destructive` | `--shard=1/4` | `--last-failed`

For full tier model, regression types table, and tag taxonomy, see [`references/regression-catalogs.md`](references/regression-catalogs.md).

---

## Red Flags

- Treating flaky tests as "fixed" by adding retries or `waitForTimeout` — quarantine and root-cause instead.
- Running the full suite on every commit — use tiered selection (smoke on commit, full nightly).
- Quarantining tests silently with no tracking ticket — quarantine must be temporary and owned.
- No change-based selection — running everything regardless of what changed wastes CI budget.
- Ignoring suite-health metrics (rising duration, climbing flake rate) until they block releases.

---

## References

| Document                                                          | Content                                                                                                                                          |
| ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| [Regression Strategy](./references/regression-strategy.md)        | Tier model (smoke→full), regression types, triggers, directory layout, test tagging and tag taxonomy                                             |
| [Regression Selection](./references/regression-selection.md)      | Test selection (change-based, risk-based, historical, time-budget) and test naming conventions                                                  |
| [Regression Best Practices](./references/regression-best-practices.md) | Locator priority, web-first assertions, test independence, `test.step()` reporting, complete worked example test                          |
| [CI/CD Integration](./references/ci-cd-integration.md)           | GitHub Actions tiered pipeline, sharding, merge reports, Playwright config, performance optimization, CLI reference                             |
| [Flaky Management](./references/flaky-management.md)             | Retry policies, quarantine strategies, detection checklist, suite health metrics, troubleshooting                                               |

---

## Verification

- [ ] **Smoke test subset identified** — Tagged `@smoke` tests run in under 2 minutes
- [ ] **No test duplication** — Each scenario tested exactly once at the appropriate level
- [ ] **Test isolation verified** — Running tests in random order produces same results as sequential
- [ ] **Flaky test baseline established** — All tests pass 5/5 consecutive runs
