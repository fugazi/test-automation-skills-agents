---
description: 'CI/CD test pipeline essentials — test tiers, GitHub Actions patterns, sharding, reporting gates, flaky handling. Applied to CI/CD workflow files.'
applyTo: '**/.github/workflows/*.yml, **/.github/workflows/*.yaml, **/Jenkinsfile, **/.gitlab-ci.yml'
---

# CI/CD Test Pipeline Essentials

## Test Tier System (fastest/most-critical → slowest/broadest)

| Tier | Scope | Trigger |
| --- | --- | --- |
| **0 Smoke** | Critical path (5–10) | Every commit |
| **1 Sanity** | Core features (20–50) | Every PR |
| **2 Selective** | Change-based | On merge |
| **3 Full** | Complete regression | Nightly / pre-release |

## Non-Negotiable Rules

- **Tag by tier** for selective execution: `@smoke`, `@sanity`, `@regression` (e.g., `test('login works @smoke', ...)`)
- **Shard for speed**: matrix `shard: [1/4, 2/4, 3/4, 4/4]` + `--shard=${{ matrix.shard }}`; `fail-fast: false`
- **Reporter split**: HTML + JSON in CI, `list` locally; `reporter` keyed on `process.env.CI`
- **Retries CI-only**: `retries: process.env.CI ? 2 : 0`; capture `trace: "on-first-retry"`, `screenshot: "only-on-failure"`, `video: "retain-on-failure"`
- **Deployment gates**: smoke must pass before staging; full regression before production (`needs:` in workflow)
- **Test data in CI**: environment variables for secrets (never hardcode); CI-specific data; seed before / truncate after
- **Artifacts on failure**: `actions/upload-artifact@v4` with `if: failure()`

## References

For full workflow templates (smoke pipeline, sharded full regression, deployment gates, Slack notifications, reporter config): use the `playwright-regression-testing` skill (`references/ci-cd-integration.md`, `references/flaky-management.md`).
