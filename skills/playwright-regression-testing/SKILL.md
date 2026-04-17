---
name: playwright-regression-testing
description: 'Automated regression testing strategy and best practices using Playwright with TypeScript. Use when asked to plan, organize, select, execute, or optimize regression test suites for web applications. Covers change-based and risk-based test selection, test tagging and prioritization, parallel execution, sharding, CI/CD pipeline integration with GitHub Actions, flaky test management, suite health monitoring, and regression types (corrective, progressive, selective, complete). Keywords: regression testing, test selection, smoke tests, test suite optimization, CI pipeline, flaky tests, test sharding, impact analysis, git diff.'
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

### Tier Model

```
Tier 0 — Smoke       (< 2 min)   → Critical path, runs on every commit
Tier 1 — Sanity      (< 10 min)  → Core features, runs on every PR
Tier 2 — Selective   (< 30 min)  → Change-based + risk-based, runs on merge
Tier 3 — Full        (< 60 min)  → Complete regression, runs nightly/pre-release
```

### Regression Types

| Type            | When                                     | Scope                              |
| --------------- | ---------------------------------------- | ---------------------------------- |
| **Corrective**  | No app code changed (infra, config, env) | Full suite to verify nothing broke |
| **Progressive** | New features added                       | Existing tests + new feature tests |
| **Selective**   | Specific code changes                    | Changed modules + dependent tests  |
| **Complete**    | Major refactor, release candidate        | Run everything across all projects |

### Tag Taxonomy

| Tag           | Purpose                          | Tier          |
| ------------- | -------------------------------- | ------------- |
| `@smoke`      | Critical path, must always pass  | 0             |
| `@sanity`     | Core feature verification        | 1             |
| `@regression` | Standard regression coverage     | 2-3           |
| `@critical`   | Revenue/business-critical flows  | 0-1           |
| `@slow`       | Tests exceeding 30 seconds       | 3             |
| `@quarantine` | Known flaky, under investigation | Skipped in CI |
| `@a11y`       | Accessibility checks             | 2             |

### CLI Quick Reference

| Command                                         | Description              |
| ----------------------------------------------- | ------------------------ |
| `npx playwright test --grep @smoke`             | Run smoke tier only      |
| `npx playwright test --grep @regression`        | Run regression suite     |
| `npx playwright test --grep-invert @quarantine` | Skip quarantined tests   |
| `npx playwright test --shard=1/4`               | Run shard 1 of 4         |
| `npx playwright test --last-failed`             | Re-run only failed tests |

---

## Common Rationalizations

> Common shortcuts and "good enough" excuses that erode test quality — and the reality behind each.

| Rationalization                                    | Reality                                                                                                 |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| "Run all tests every time"                         | Change-based test selection reduces CI time 60-80%. Run the full suite nightly, not every commit.       |
| "Flaky tests are normal"                           | Flaky tests erode trust in the entire suite. Quarantine, investigate, and fix them.                     |
| "Regression testing is just re-running everything" | Strategic selection (risk-based, change-based) catches more defects in less time than brute-force runs. |
| "Test sharding is premature optimization"          | Parallel sharding cuts CI time linearly with workers. Start with 4 shards from day one.                 |
| "Smoke tests cover regression"                     | Smoke tests verify health; regression tests verify behavior. They serve different purposes.             |
| "Tagging tests is busywork"                        | Tags enable selective execution, prioritization, and suite analysis. Untagged suites are unmanageable.  |

---

## References

| Document                                                   | Content                                                                                                                                                                      |
| ---------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Regression Strategy](./references/regression-strategy.md) | Tier definitions, test selection (change-based, risk-based, historical, time-budget), directory layout, tagging, naming conventions, Playwright best practices, example test |
| [CI/CD Integration](./references/ci-cd-integration.md)     | GitHub Actions tiered pipeline, sharding, merge reports, Playwright config, performance optimization, CLI reference                                                          |
| [Flaky Management](./references/flaky-management.md)       | Retry policies, quarantine strategies, detection checklist, suite health metrics, troubleshooting                                                                            |

---

## Verification

After completing this skill's workflow, confirm:

- [ ] **Regression suite covers critical paths** — All priority-1 user flows have regression tests
- [ ] **Smoke test subset identified** — Tagged `@smoke` tests run in under 2 minutes
- [ ] **No test duplication** — Each scenario tested exactly once at the appropriate level
- [ ] **Test isolation verified** — Running tests in random order produces same results as sequential
- [ ] **Flaky test baseline established** — All tests pass 5/5 consecutive runs
- [ ] **CI pipeline configured** — GitHub Actions workflow runs regression on schedule
- [ ] **Allure or HTML report generated** — Test results available in human-readable format
