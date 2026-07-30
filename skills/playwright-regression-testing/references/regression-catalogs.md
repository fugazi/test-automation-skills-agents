# Regression Catalogs

> Part of the `playwright-regression-testing` skill. See [SKILL.md](../SKILL.md) for full context.

## Tier Model

```
Tier 0 — Smoke       (< 2 min)   → Critical path, runs on every commit
Tier 1 — Sanity      (< 10 min)  → Core features, runs on every PR
Tier 2 — Selective   (< 30 min)  → Change-based + risk-based, runs on merge
Tier 3 — Full        (< 60 min)  → Complete regression, runs nightly/pre-release
```

## Regression Types

| Type            | When                                     | Scope                              |
| --------------- | ---------------------------------------- | ---------------------------------- |
| **Corrective**  | No app code changed (infra, config, env) | Full suite to verify nothing broke |
| **Progressive** | New features added                       | Existing tests + new feature tests |
| **Selective**   | Specific code changes                    | Changed modules + dependent tests  |
| **Complete**    | Major refactor, release candidate        | Run everything across all projects |

## Tag Taxonomy

| Tag           | Purpose                          | Tier          |
| ------------- | -------------------------------- | ------------- |
| `@smoke`      | Critical path, must always pass  | 0             |
| `@sanity`     | Core feature verification        | 1             |
| `@regression` | Standard regression coverage     | 2-3           |
| `@critical`   | Revenue/business-critical flows  | 0-1           |
| `@slow`       | Tests exceeding 30 seconds       | 3             |
| `@quarantine` | Known flaky, under investigation | Skipped in CI |
| `@a11y`       | Accessibility checks             | 2             |
