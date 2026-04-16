# CI/CD Integration

Detailed reference for integrating Playwright regression tests with GitHub Actions. Covers parallelization, sharding, pipeline configuration, and reporting.

## Parallelization and Performance

### Parallel Workers

```typescript
// playwright.config.ts
import { defineConfig } from "@playwright/test";

export default defineConfig({
  fullyParallel: true,
  workers: process.env.CI ? 4 : undefined, // limit in CI, auto-detect locally
});
```

### Sharding Across CI Machines

Split tests across multiple CI runners for faster execution:

```bash
# Machine 1
npx playwright test --shard=1/4

# Machine 2
npx playwright test --shard=2/4

# Machine 3
npx playwright test --shard=3/4

# Machine 4
npx playwright test --shard=4/4
```

### Performance Optimization Checklist

| Technique           | Impact | How                                             |
| ------------------- | ------ | ----------------------------------------------- |
| Parallel workers    | High   | `fullyParallel: true` in config                 |
| Sharding            | High   | `--shard=N/M` across CI machines                |
| API authentication  | Medium | Skip UI login; use API tokens or `storageState` |
| Selective test runs | High   | Tag-based `--grep` with change analysis         |
| Browser reuse       | Medium | `reuseExistingServer: true` for dev server      |
| Headed vs headless  | Low    | Always headless in CI                           |
| Dependency caching  | Medium | Cache `node_modules` and browser binaries in CI |

### Storage State for Auth Reuse

Avoid repeating login UI in every test:

```typescript
// auth.setup.ts — run once, save auth state
import { test as setup } from "@playwright/test";

setup("authenticate", async ({ page }) => {
  await page.goto("/login");
  await page.getByLabel("Email").fill("admin@example.com");
  await page.getByLabel("Password").fill("password");
  await page.getByRole("button", { name: "Sign in" }).click();
  await page.waitForURL("**/dashboard");
  await page.context().storageState({ path: ".auth/user.json" });
});
```

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    { name: "setup", testDir: "./", testMatch: "auth.setup.ts" },
    {
      name: "regression",
      dependencies: ["setup"],
      use: { storageState: ".auth/user.json" },
    },
  ],
});
```

## GitHub Actions — Tiered Regression Pipeline

```yaml
# .github/workflows/regression.yml
name: Regression Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: "0 2 * * *" # Nightly full regression at 2 AM UTC
  workflow_dispatch:
    inputs:
      suite:
        description: "Test suite to run"
        required: false
        default: "smoke"
        type: choice
        options:
          - smoke
          - regression
          - full

jobs:
  smoke:
    name: Smoke Tests (Tier 0)
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npx playwright test --grep @smoke --project=chromium
      - uses: actions/upload-artifact@v4
        if: ${{ !cancelled() }}
        with:
          name: smoke-report
          path: playwright-report/
          retention-days: 7

  regression:
    name: Selective Regression (Tier 2)
    needs: smoke
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    timeout-minutes: 30
    strategy:
      fail-fast: false
      matrix:
        shard: [1, 2, 3]
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 # Full history for git diff
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npx playwright install --with-deps
      - name: Run regression tests (shard ${{ matrix.shard }}/3)
        run: npx playwright test --grep @regression --shard=${{ matrix.shard }}/3
      - uses: actions/upload-artifact@v4
        if: ${{ !cancelled() }}
        with:
          name: regression-report-${{ matrix.shard }}
          path: playwright-report/
          retention-days: 7

  full-regression:
    name: Full Regression (Tier 3)
    if: github.event_name == 'schedule' || github.event.inputs.suite == 'full'
    runs-on: ubuntu-latest
    timeout-minutes: 60
    strategy:
      fail-fast: false
      matrix:
        project: [chromium, firefox, webkit]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npx playwright install --with-deps
      - name: Run full regression (${{ matrix.project }})
        run: npx playwright test --project=${{ matrix.project }}
      - uses: actions/upload-artifact@v4
        if: ${{ !cancelled() }}
        with:
          name: full-report-${{ matrix.project }}
          path: playwright-report/
          retention-days: 14
```

### Merge Reports from Shards

```yaml
merge-reports:
  name: Merge Shard Reports
  needs: regression
  if: ${{ !cancelled() }}
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with:
        node-version: 20
        cache: npm
    - run: npm ci
    - uses: actions/download-artifact@v4
      with:
        pattern: regression-report-*
        path: all-reports
        merge-multiple: true
    - run: npx playwright merge-reports --reporter=html all-reports
    - uses: actions/upload-artifact@v4
      with:
        name: merged-regression-report
        path: playwright-report/
        retention-days: 14
```

## Playwright Config for Regression

```typescript
// playwright.config.ts
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./tests",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 4 : undefined,
  reporter: [
    ["html", { open: "never" }],
    ["json", { outputFile: "test-results/results.json" }],
    ...(process.env.CI ? [["github" as const]] : []),
  ],
  use: {
    baseURL: process.env.BASE_URL || "http://localhost:3000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },
  projects: [
    // Auth setup — runs first
    { name: "setup", testDir: "./", testMatch: "auth.setup.ts" },
    // Smoke — fast, critical path
    {
      name: "smoke",
      dependencies: ["setup"],
      use: { ...devices["Desktop Chrome"], storageState: ".auth/user.json" },
      grep: /@smoke/,
    },
    // Regression — cross-browser
    {
      name: "chromium",
      dependencies: ["setup"],
      use: { ...devices["Desktop Chrome"], storageState: ".auth/user.json" },
    },
    {
      name: "firefox",
      dependencies: ["setup"],
      use: { ...devices["Desktop Firefox"], storageState: ".auth/user.json" },
    },
    {
      name: "webkit",
      dependencies: ["setup"],
      use: { ...devices["Desktop Safari"], storageState: ".auth/user.json" },
    },
    // Mobile regression
    {
      name: "mobile",
      dependencies: ["setup"],
      use: { ...devices["Pixel 5"], storageState: ".auth/user.json" },
    },
  ],
  webServer: {
    command: "npm run dev",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
  },
});
```

## CLI Quick Reference

| Command                                         | Description              |
| ----------------------------------------------- | ------------------------ |
| `npx playwright test --grep @smoke`             | Run smoke tier only      |
| `npx playwright test --grep @regression`        | Run regression suite     |
| `npx playwright test --grep-invert @quarantine` | Skip quarantined tests   |
| `npx playwright test --shard=1/4`               | Run shard 1 of 4         |
| `npx playwright test --project=chromium`        | Run on Chromium only     |
| `npx playwright test --reporter=html`           | Generate HTML report     |
| `npx playwright test --last-failed`             | Re-run only failed tests |
| `npx playwright show-report`                    | Open HTML report         |
