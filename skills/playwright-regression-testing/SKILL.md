---
name: playwright-regression-testing
description: Automated regression testing strategy and best practices using Playwright with TypeScript. Use when asked to plan, organize, select, execute, or optimize regression test suites for web applications. Covers change-based and risk-based test selection, test tagging and prioritization, parallel execution, sharding, CI/CD pipeline integration with GitHub Actions, flaky test management, suite health monitoring, and regression types (corrective, progressive, selective, complete). Keywords: regression testing, test selection, smoke tests, test suite optimization, CI pipeline, flaky tests, test sharding, impact analysis, git diff.
---

# Playwright Regression Testing (TypeScript)

Comprehensive strategy and best practices for automated regression testing of web applications using Playwright with TypeScript. Covers test selection, suite organization, execution optimization, CI/CD integration, and suite health monitoring.

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

| Requirement | Details |
|-------------|---------|
| Node.js | v18+ recommended |
| Playwright | `@playwright/test` package |
| TypeScript | `typescript` configured in project |
| Browsers | Installed via `npx playwright install` |
| Git | Required for change-based test selection |
| GitHub Actions | Recommended CI/CD platform |

---

## Purpose

Regression testing validates that existing functionality continues to work after code changes, dependency updates, environment changes, or new feature additions. A well-structured regression strategy balances coverage, execution speed, and risk to catch defects early without slowing down delivery.

This skill provides a repeatable framework for:

1. Deciding **which tests to run** based on what changed
2. Organizing tests into **priority tiers** for incremental confidence
3. Running tests **efficiently** via parallelization and sharding
4. Integrating regression suites into **CI/CD pipelines**
5. Keeping the suite **healthy** over time

---

## Regression Testing Strategy

### Workflow

```
1. ANALYZE  → What changed? (git diff, impact analysis)
2. SELECT   → Which tests to run? (risk, change, history)
3. RUN      → Execute in priority order (smoke → selective → full)
4. OPTIMIZE → Parallel execution, sharding, caching
5. MONITOR  → Track suite health (flakiness, duration, detection)
```

### When to Run Regression Tests

| Trigger | Regression Type | Suite |
|---------|----------------|-------|
| Any code change (PR/commit) | Selective | Smoke + changed + dependent tests |
| Before release (RC cut) | Complete | Full regression suite |
| Dependency update | Progressive | Existing + integration tests |
| Environment change | Corrective | Full suite on target environment |
| Bug fix deployed | Selective | Related tests + smoke |
| Major refactor | Complete | Everything across all browsers |

### Regression Types

| Type | When | Scope |
|------|------|-------|
| **Corrective** | No application code changed (infra, config, env) | Full suite to verify nothing broke |
| **Progressive** | New features added | Existing tests + new feature tests |
| **Selective** | Specific code changes | Changed modules + dependent tests |
| **Complete** | Major refactor, release candidate, critical fix | Run everything across all projects |

---

## Test Suite Structure

### Tier Model

Organize tests into tiers that run from fastest/most-critical to slowest/broadest:

```
Tier 0 — Smoke       (< 2 min)   → Critical path, runs on every commit
Tier 1 — Sanity      (< 10 min)  → Core features, runs on every PR
Tier 2 — Selective   (< 30 min)  → Change-based + risk-based, runs on merge
Tier 3 — Full        (< 60 min)  → Complete regression, runs nightly/pre-release
```

### Recommended Directory Layout

```
tests/
├── smoke/                    # Tier 0: critical path tests
│   ├── auth.smoke.spec.ts
│   ├── checkout.smoke.spec.ts
│   └── navigation.smoke.spec.ts
├── regression/               # Tier 2-3: regression tests by feature
│   ├── auth/
│   │   ├── login.spec.ts
│   │   ├── registration.spec.ts
│   │   └── password-reset.spec.ts
│   ├── checkout/
│   │   ├── cart.spec.ts
│   │   ├── payment.spec.ts
│   │   └── shipping.spec.ts
│   └── search/
│       ├── search-results.spec.ts
│       └── filters.spec.ts
├── e2e/                      # End-to-end user journeys
│   ├── purchase-flow.spec.ts
│   └── onboarding-flow.spec.ts
└── fixtures/                 # Shared test fixtures and helpers
    ├── auth.fixture.ts
    └── test-data.ts
```

### Test Tagging with Annotations

Use Playwright's `tag` annotation to classify tests for selective execution:

```typescript
import { test, expect } from '@playwright/test';

test('user can log in @smoke @auth', { tag: ['@smoke', '@regression'] }, async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('secure-password');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page).toHaveURL(/.*dashboard/);
});

test('user can reset password @regression @auth', { tag: ['@regression'] }, async ({ page }) => {
  await page.goto('/forgot-password');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByRole('button', { name: 'Reset Password' }).click();
  await expect(page.getByRole('alert')).toContainText('Check your email');
});
```

Run tagged subsets from CLI:

```bash
# Run only smoke tests
npx playwright test --grep @smoke

# Run regression tests excluding slow tests
npx playwright test --grep @regression --grep-invert @slow

# Run tests for a specific feature
npx playwright test --grep @auth
```

---

## Test Selection Strategy

### 1. Change-Based Selection (Git Diff Analysis)

Map code changes to affected test files using module dependency analysis:

```bash
# Get changed files from the current branch vs main
git diff --name-only origin/main...HEAD

# Filter to source files only
git diff --name-only origin/main...HEAD -- 'src/**'
```

Example mapping script for CI:

```typescript
// scripts/select-tests.ts
import { execSync } from 'child_process';

const CHANGE_TO_TEST_MAP: Record<string, string[]> = {
  'src/auth/': ['tests/regression/auth/', 'tests/smoke/auth.smoke.spec.ts'],
  'src/checkout/': ['tests/regression/checkout/', 'tests/smoke/checkout.smoke.spec.ts'],
  'src/search/': ['tests/regression/search/'],
  'src/components/': ['tests/regression/', 'tests/smoke/'],
  'src/api/': ['tests/regression/', 'tests/e2e/'],
};

function getAffectedTests(): string[] {
  const changedFiles = execSync('git diff --name-only origin/main...HEAD')
    .toString()
    .trim()
    .split('\n');

  const testPaths = new Set<string>();
  for (const file of changedFiles) {
    for (const [srcPattern, tests] of Object.entries(CHANGE_TO_TEST_MAP)) {
      if (file.startsWith(srcPattern)) {
        tests.forEach(t => testPaths.add(t));
      }
    }
  }

  // Always include smoke tests
  testPaths.add('tests/smoke/');

  return [...testPaths];
}

const tests = getAffectedTests();
console.log(tests.join(' '));
```

### 2. Risk-Based Selection

Prioritize tests by business impact and failure probability:

| Risk Level | Criteria | Action |
|------------|----------|--------|
| **Critical** | Revenue-impacting flows (checkout, payments) | Always run, every PR |
| **High** | Core features (auth, search, navigation) | Run on every merge |
| **Medium** | Secondary features (profile, settings) | Run nightly or pre-release |
| **Low** | Edge cases, cosmetic flows | Run in full regression only |

```typescript
// Tag tests with risk levels for prioritized execution
test.describe('checkout flow @critical', { tag: ['@critical', '@regression'] }, () => {
  test('user can complete purchase', async ({ page }) => {
    // Critical path — always part of smoke and regression
  });
});

test.describe('profile settings @medium', { tag: ['@medium', '@regression'] }, () => {
  test('user can update avatar', async ({ page }) => {
    // Medium risk — nightly regression only
  });
});
```

### 3. Historical Selection (Failure-Prone Tests)

Track frequently failing tests and prioritize them in regression runs:

```typescript
// playwright.config.ts — capture test results metadata
import { defineConfig } from '@playwright/test';

export default defineConfig({
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/results.json' }],
  ],
});
```

Use CI artifacts to analyze failure trends and prioritize flaky or failure-prone areas.

### 4. Time-Budget Selection

When CI time is constrained, select tests to fit within a time window:

```bash
# Run critical tests within a 5-minute budget
npx playwright test --grep @critical --timeout 300000

# Run smoke + high-risk tests (skip medium/low)
npx playwright test --grep "@smoke|@critical|@high"
```

---

## Playwright Best Practices

### Locator Strategy (Priority Order)

| Priority | Locator | Example |
|----------|---------|---------|
| 1 | Role + accessible name | `getByRole('button', { name: 'Submit' })` |
| 2 | Label | `getByLabel('Email')` |
| 3 | Placeholder | `getByPlaceholder('Search...')` |
| 4 | Text | `getByText('Welcome back')` |
| 5 | Test ID | `getByTestId('checkout-btn')` |
| 6 | CSS (last resort) | `locator('.btn-primary')` |

### Web-First Assertions (Auto-Retry)

```typescript
// ✅ Web-first assertions — auto-retry until condition met
await expect(page.getByRole('heading')).toHaveText('Dashboard');
await expect(page.getByRole('alert')).toBeVisible();
await expect(page).toHaveURL(/.*\/dashboard/);

// ❌ Avoid — no auto-retry, causes flakiness
await page.waitForTimeout(3000);
const text = await page.textContent('.heading');
expect(text).toBe('Dashboard');
```

### Test Independence

Each test must be fully isolated. Never depend on execution order or shared state:

```typescript
// ✅ Each test sets up its own state
test('user sees order history', async ({ page }) => {
  // Authenticate via API (fast, no UI dependency)
  await page.request.post('/api/auth/login', {
    data: { email: 'user@test.com', password: 'pass' },
  });
  await page.goto('/orders');
  await expect(page.getByRole('table')).toBeVisible();
});

// ❌ Avoid: test depends on previous test having logged in
```

### Use `test.step()` for Readable Reports

```typescript
test('checkout flow @smoke @checkout', { tag: ['@smoke', '@regression'] }, async ({ page }) => {
  await test.step('Navigate to product page', async () => {
    await page.goto('/products/1');
    await expect(page.getByRole('heading')).toContainText('Product');
  });

  await test.step('Add item to cart', async () => {
    await page.getByRole('button', { name: 'Add to Cart' }).click();
    await expect(page.getByTestId('cart-count')).toHaveText('1');
  });

  await test.step('Complete checkout', async () => {
    await page.goto('/checkout');
    await page.getByRole('button', { name: 'Place Order' }).click();
    await expect(page.getByRole('heading')).toContainText('Order Confirmed');
  });
});
```

---

## Parallelization and Performance

### Parallel Workers

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

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

| Technique | Impact | How |
|-----------|--------|-----|
| Parallel workers | High | `fullyParallel: true` in config |
| Sharding | High | `--shard=N/M` across CI machines |
| API authentication | Medium | Skip UI login; use API tokens or `storageState` |
| Selective test runs | High | Tag-based `--grep` with change analysis |
| Browser reuse | Medium | `reuseExistingServer: true` for dev server |
| Headed vs headless | Low | Always headless in CI |
| Dependency caching | Medium | Cache `node_modules` and browser binaries in CI |

### Storage State for Auth Reuse

Avoid repeating login UI in every test:

```typescript
// auth.setup.ts — run once, save auth state
import { test as setup } from '@playwright/test';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('admin@example.com');
  await page.getByLabel('Password').fill('password');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('**/dashboard');
  await page.context().storageState({ path: '.auth/user.json' });
});
```

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    { name: 'setup', testDir: './', testMatch: 'auth.setup.ts' },
    {
      name: 'regression',
      dependencies: ['setup'],
      use: { storageState: '.auth/user.json' },
    },
  ],
});
```

---

## CI/CD Integration

### GitHub Actions — Tiered Regression Pipeline

```yaml
# .github/workflows/regression.yml
name: Regression Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * *'  # Nightly full regression at 2 AM UTC
  workflow_dispatch:
    inputs:
      suite:
        description: 'Test suite to run'
        required: false
        default: 'smoke'
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
          fetch-depth: 0  # Full history for git diff
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

---

## Flaky Test Management

### Retry Policy

```typescript
// playwright.config.ts
export default defineConfig({
  retries: process.env.CI ? 2 : 0, // Retry only in CI
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/results.json' }],
  ],
  use: {
    trace: 'on-first-retry',       // Capture trace on retry
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
});
```

### Quarantine Flaky Tests

Isolate known flaky tests to prevent blocking the pipeline while tracking them for fixes:

```typescript
// Mark flaky tests with fixme — skipped but tracked
test.fixme('intermittent timeout on slow network @flaky', async ({ page }) => {
  // TODO: investigate — see issue #1234
});

// Or use a dedicated tag for quarantine reporting
test('payment callback race condition @quarantine', {
  tag: ['@quarantine', '@regression'],
  annotation: { type: 'issue', description: 'https://github.com/org/repo/issues/1234' },
}, async ({ page }) => {
  test.skip(!!process.env.CI, 'Quarantined — flaky in CI, see linked issue');
  // Test body here
});
```

### Flaky Test Detection Checklist

| Symptom | Common Cause | Fix |
|---------|-------------|-----|
| Passes locally, fails in CI | Timing, environment differences | Use web-first assertions; match CI env settings |
| Fails intermittently | Race condition, animation, network | Add `test.step()`, wait for specific state, mock APIs |
| Different results per browser | Browser-specific rendering | Add browser-specific assertions or skip with `test.skip()` |
| Order-dependent failures | Shared state between tests | Ensure full test isolation; use fixtures for setup |
| Timeout errors | Slow element rendering | Check for overlays/loaders; use `waitFor` on specific elements |

### Suite Health Metrics

Track these metrics to maintain regression suite quality:

| Metric | Target | Action if Exceeded |
|--------|--------|--------------------|
| Smoke suite duration | < 2 min | Split or move slow tests to Tier 2 |
| Full regression duration | < 60 min | Add sharding, reduce redundant coverage |
| Flake rate (retried tests) | < 2% | Quarantine and fix; investigate root causes |
| Test pass rate | > 98% | Triage failures within 24 hours |
| Escaped defects per sprint | < 2 | Add regression tests for escaped bugs |

---

## Test Naming Conventions

Follow consistent naming for readability and grep-ability:

```typescript
// Pattern: <feature>.<scope>.spec.ts
// Examples:
// auth.login.spec.ts
// checkout.payment.spec.ts
// search.filters.spec.ts

// Test title pattern: <user action> + <expected outcome>
test.describe('checkout flow', () => {
  test('user can add item to cart', async ({ page }) => { /* ... */ });
  test('user sees error for invalid card', async ({ page }) => { /* ... */ });
  test('user can complete purchase with valid payment', async ({ page }) => { /* ... */ });
});
```

### Tag Taxonomy

Keep the tag set small and well-defined:

| Tag | Purpose | Tier |
|-----|---------|------|
| `@smoke` | Critical path, must always pass | 0 |
| `@sanity` | Core feature verification | 1 |
| `@regression` | Standard regression coverage | 2-3 |
| `@critical` | Revenue/business-critical flows | 0-1 |
| `@slow` | Tests exceeding 30 seconds | 3 |
| `@quarantine` | Known flaky, under investigation | Skipped in CI |
| `@a11y` | Accessibility checks | 2 |

---

## Example Playwright Test

A complete regression test file demonstrating the patterns from this skill:

```typescript
// tests/regression/checkout/cart.spec.ts
import { test, expect } from '@playwright/test';

test.describe('shopping cart @regression @checkout', { tag: ['@regression'] }, () => {

  test.beforeEach(async ({ page }) => {
    // Authenticate via stored state (setup dependency in config)
    await page.goto('/products');
  });

  test('user can add item to cart @smoke', { tag: ['@smoke', '@critical'] }, async ({ page }) => {
    await test.step('Select a product', async () => {
      await page.getByRole('link', { name: /Running Shoes/i }).click();
      await expect(page.getByRole('heading', { level: 1 })).toContainText('Running Shoes');
    });

    await test.step('Add to cart', async () => {
      await page.getByRole('button', { name: 'Add to Cart' }).click();
      await expect(page.getByTestId('cart-count')).toHaveText('1');
    });

    await test.step('Verify cart contents', async () => {
      await page.goto('/cart');
      await expect(page.getByRole('table')).toContainText('Running Shoes');
    });
  });

  test('user can remove item from cart', { tag: ['@regression'] }, async ({ page }) => {
    await test.step('Add an item first', async () => {
      await page.getByRole('link', { name: /Running Shoes/i }).click();
      await page.getByRole('button', { name: 'Add to Cart' }).click();
      await expect(page.getByTestId('cart-count')).toHaveText('1');
    });

    await test.step('Remove item from cart', async () => {
      await page.goto('/cart');
      await page.getByRole('button', { name: 'Remove' }).click();
      await expect(page.getByText('Your cart is empty')).toBeVisible();
    });
  });

  test('cart persists across page navigation', { tag: ['@regression'] }, async ({ page }) => {
    await test.step('Add item and navigate away', async () => {
      await page.getByRole('link', { name: /Running Shoes/i }).click();
      await page.getByRole('button', { name: 'Add to Cart' }).click();
      await page.goto('/');
    });

    await test.step('Return and verify cart', async () => {
      await page.goto('/cart');
      await expect(page.getByRole('table')).toContainText('Running Shoes');
    });
  });
});
```

---

## Playwright Config for Regression

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 4 : undefined,
  reporter: [
    ['html', { open: 'never' }],
    ['json', { outputFile: 'test-results/results.json' }],
    ...(process.env.CI ? [['github' as const]] : []),
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    // Auth setup — runs first
    { name: 'setup', testDir: './', testMatch: 'auth.setup.ts' },
    // Smoke — fast, critical path
    {
      name: 'smoke',
      dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], storageState: '.auth/user.json' },
      grep: /@smoke/,
    },
    // Regression — cross-browser
    {
      name: 'chromium',
      dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], storageState: '.auth/user.json' },
    },
    {
      name: 'firefox',
      dependencies: ['setup'],
      use: { ...devices['Desktop Firefox'], storageState: '.auth/user.json' },
    },
    {
      name: 'webkit',
      dependencies: ['setup'],
      use: { ...devices['Desktop Safari'], storageState: '.auth/user.json' },
    },
    // Mobile regression
    {
      name: 'mobile',
      dependencies: ['setup'],
      use: { ...devices['Pixel 5'], storageState: '.auth/user.json' },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

---

## CLI Quick Reference

| Command | Description |
|---------|-------------|
| `npx playwright test --grep @smoke` | Run smoke tier only |
| `npx playwright test --grep @regression` | Run regression suite |
| `npx playwright test --grep-invert @quarantine` | Skip quarantined tests |
| `npx playwright test --shard=1/4` | Run shard 1 of 4 |
| `npx playwright test --project=chromium` | Run on Chromium only |
| `npx playwright test --reporter=html` | Generate HTML report |
| `npx playwright test --last-failed` | Re-run only failed tests |
| `npx playwright show-report` | Open HTML report |

---

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Smoke suite too slow | Too many tests tagged `@smoke` | Keep smoke under 10 tests; move others to `@regression` |
| Shards unbalanced | Test durations vary widely | Use `--shard` with `fullyParallel: true`; split large describe blocks |
| CI flakes not local | Environment or timing differences | Match CI config locally; use `trace: 'on-first-retry'` |
| Tag not filtering | Missing `tag` annotation | Use `{ tag: ['@smoke'] }` in test options, not just title |
| Merge reports fail | Artifact names mismatch | Ensure consistent `upload-artifact` naming pattern per shard |
| Auth setup fails | Login page changed | Update `auth.setup.ts`; check `storageState` path |
| Tests run out of order | Missing `dependencies` in config | Set project `dependencies: ['setup']` for auth |
