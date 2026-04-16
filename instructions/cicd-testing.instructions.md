---
description: "CI/CD test pipeline configuration for automated testing. Defines GitHub Actions workflows, test tiers, parallel execution, reporting, and deployment gates. Apply when creating or modifying CI/CD pipeline files for test automation."
applyTo: "**/.github/workflows/*.yml, **/.github/workflows/*.yaml, **/Jenkinsfile, **/.gitlab-ci.yml"
---

# CI/CD Test Pipeline Configuration

Instructions for setting up automated test pipelines using GitHub Actions. Covers test tier organization, parallel execution, reporting, deployment gates, and flaky test handling.

## Test Tier System

Organize tests into tiers that run from fastest/most-critical to slowest/broadest:

| Tier                  | Scope                       | Duration | Trigger               | Browsers              |
| --------------------- | --------------------------- | -------- | --------------------- | --------------------- |
| **Tier 0: Smoke**     | Critical path (5-10 tests)  | < 2 min  | Every commit          | 1 browser (chromium)  |
| **Tier 1: Sanity**    | Core features (20-50 tests) | < 10 min | Every PR              | 2 browsers            |
| **Tier 2: Selective** | Change-based                | < 30 min | On merge              | All browsers          |
| **Tier 3: Full**      | Complete regression         | < 60 min | Nightly / pre-release | All browsers + mobile |

## Tagging Strategy

Tag tests by tier for selective execution:

```typescript
// In test files, tag tests by tier
test('login works @smoke @sanity', async ({ loginPage }) => { ... });
test('full checkout flow @regression', async ({ checkoutPage }) => { ... });
test('search filters @sanity @regression', async ({ searchPage }) => { ... });
```

Run by tag from CLI:

```bash
npx playwright test -g "@smoke"       # Tier 0
npx playwright test -g "@sanity"      # Tier 1
npx playwright test                    # All — includes @regression
```

## Smoke Pipeline (Tier 0)

Runs on every commit. Fast feedback loop for developers.

```yaml
name: Smoke Tests
on: [push]

jobs:
  smoke:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npx playwright test --project=chromium -g "@smoke"
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: smoke-results
          path: test-results/
```

## Full Regression Pipeline (Tier 3)

Runs nightly and on-demand. Cross-browser, sharded for speed.

```yaml
name: Full Regression
on:
  schedule:
    - cron: "0 2 * * *" # 2 AM UTC daily
  workflow_dispatch:

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        project: [chromium, firefox, webkit]
        shard: [1/4, 2/4, 3/4, 4/4]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test --project=${{ matrix.project }} --shard=${{ matrix.shard }}
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: results-${{ matrix.project }}-${{ matrix.shard }}
          path: test-results/

  report:
    needs: test
    if: always()
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with:
          path: test-results/
      - run: npx playwright show-report
```

## Parallel Execution with Sharding

Split tests across multiple CI runners for faster execution:

```yaml
strategy:
  fail-fast: false
  matrix:
    shard: [1/4, 2/4, 3/4, 4/4]
```

```bash
# Each runner executes its shard
npx playwright test --shard=${{ matrix.shard }}
```

## Playwright Reporter Configuration

Configure reporters for CI and local environments:

```typescript
// playwright.config.ts
export default defineConfig({
  reporter: process.env.CI
    ? [
        ["html", { open: "never" }],
        ["json", { outputFile: "test-results/results.json" }],
        ["github"],
      ]
    : [["list"]],
});
```

## Deployment Gates

Enforce test quality before promoting to higher environments:

- **Smoke must pass** before deploy to staging
- **Full regression must pass** before deploy to production
- **Performance thresholds** must be met for production releases

Example gate in workflow:

```yaml
deploy-staging:
  needs: smoke
  runs-on: ubuntu-latest
  steps:
    - run: echo "Deploying to staging..."

deploy-production:
  needs: [smoke, full-regression]
  runs-on: ubuntu-latest
  steps:
    - run: echo "Deploying to production..."
```

## Test Data Management in CI

- Use **environment variables** for secrets (never hardcode)
- Use **CI-specific test data** (never production data)
- **Clean up test data** after each run
- **Seed database** before test suite, truncate after

```yaml
env:
  BASE_URL: http://localhost:3000
  TEST_USER_EMAIL: ${{ secrets.TEST_USER_EMAIL }}
  TEST_USER_PASSWORD: ${{ secrets.TEST_USER_PASSWORD }}
```

## Flaky Test Handling in CI

Configure retries and artifact capture for CI-only:

```typescript
// playwright.config.ts
export default defineConfig({
  retries: process.env.CI ? 2 : 0, // Retry only in CI
  use: {
    trace: "on-first-retry", // Capture trace on retry
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },
});
```

## Failure Notifications

Alert the team when tests fail in CI:

```yaml
- name: Notify on failure
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "Test suite failed on ${{ github.ref }}",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*Test Failure*\nBranch: ${{ github.ref }}\nCommit: ${{ github.sha }}\n<${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}|View Run>"
            }
          }
        ]
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```
