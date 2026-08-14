# Regression Test Selection Strategy

> Part of the `playwright-regression-testing` skill. See [SKILL.md](../SKILL.md) for full context.
>
> **Related:** split from [regression-strategy.md](regression-strategy.md). See that file for the tier model and triggers; see [regression-best-practices.md](regression-best-practices.md) for locator and assertion patterns.

How to choose which tests to run for a given change: change-based (git diff), risk-based, historical (failure-prone), and time-budget selection, plus test naming conventions.

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
import { execSync } from "child_process";

const CHANGE_TO_TEST_MAP: Record<string, string[]> = {
  "src/auth/": ["tests/regression/auth/", "tests/smoke/auth.smoke.spec.ts"],
  "src/checkout/": [
    "tests/regression/checkout/",
    "tests/smoke/checkout.smoke.spec.ts",
  ],
  "src/search/": ["tests/regression/search/"],
  "src/components/": ["tests/regression/", "tests/smoke/"],
  "src/api/": ["tests/regression/", "tests/e2e/"],
};

function getAffectedTests(): string[] {
  const changedFiles = execSync("git diff --name-only origin/main...HEAD")
    .toString()
    .trim()
    .split("\n");

  const testPaths = new Set<string>();
  for (const file of changedFiles) {
    for (const [srcPattern, tests] of Object.entries(CHANGE_TO_TEST_MAP)) {
      if (file.startsWith(srcPattern)) {
        tests.forEach((t) => testPaths.add(t));
      }
    }
  }

  // Always include smoke tests
  testPaths.add("tests/smoke/");

  return [...testPaths];
}

const tests = getAffectedTests();
console.log(tests.join(" "));
```

### 2. Risk-Based Selection

Prioritize tests by business impact and failure probability:

| Risk Level   | Criteria                                     | Action                      |
| ------------ | -------------------------------------------- | --------------------------- |
| **Critical** | Revenue-impacting flows (checkout, payments) | Always run, every PR        |
| **High**     | Core features (auth, search, navigation)     | Run on every merge          |
| **Medium**   | Secondary features (profile, settings)       | Run nightly or pre-release  |
| **Low**      | Edge cases, cosmetic flows                   | Run in full regression only |

```typescript
// Risk levels are decision inputs (see table above); execution tags stay single:
// use exactly one of @smoke/@sanity/@regression/@e2e/@api/@destructive per test.
test.describe("checkout flow", () => {
  test("user can complete purchase", { tag: "@smoke" }, async ({ page }) => {
    // Critical path — runs on every commit via @smoke
  });
});

test.describe("profile settings", () => {
  test("user can update avatar", { tag: "@regression" }, async ({ page }) => {
    // Medium risk — runs via @regression
  });
});
```

### 3. Historical Selection (Failure-Prone Tests)

Track frequently failing tests and prioritize them in regression runs:

```typescript
// playwright.config.ts — capture test results metadata
import { defineConfig } from "@playwright/test";

export default defineConfig({
  reporter: [["html"], ["json", { outputFile: "test-results/results.json" }]],
});
```

Use CI artifacts to analyze failure trends and prioritize flaky or failure-prone areas.

### 4. Time-Budget Selection

When CI time is constrained, select tests to fit within a time window:

```bash
# Run smoke tests within a 5-minute budget
npx playwright test --grep @smoke --global-timeout 300000

# Run smoke + regression (skip medium/low risk)
npx playwright test --grep "@smoke|@regression"
```

## Test Naming Conventions

Follow consistent naming for readability and grep-ability:

```typescript
// Pattern: <feature>.<scope>.spec.ts
// Examples:
// auth.login.spec.ts
// checkout.payment.spec.ts
// search.filters.spec.ts

// Test title pattern: <user action> + <expected outcome>
test.describe("checkout flow", () => {
  test("user can add item to cart", async ({ page }) => {
    /* ... */
  });
  test("user sees error for invalid card", async ({ page }) => {
    /* ... */
  });
  test("user can complete purchase with valid payment", async ({ page }) => {
    /* ... */
  });
});
```
