# Regression Strategy

Detailed reference for regression testing strategy using Playwright with TypeScript. Covers tier definitions, test selection approaches, risk-based prioritization, and naming conventions.

## Workflow

```
1. ANALYZE  → What changed? (git diff, impact analysis)
2. SELECT   → Which tests to run? (risk, change, history)
3. RUN      → Execute in priority order (smoke → selective → full)
4. OPTIMIZE → Parallel execution, sharding, caching
5. MONITOR  → Track suite health (flakiness, duration, detection)
```

## When to Run Regression Tests

| Trigger                     | Regression Type | Suite                             |
| --------------------------- | --------------- | --------------------------------- |
| Any code change (PR/commit) | Selective       | Smoke + changed + dependent tests |
| Before release (RC cut)     | Complete        | Full regression suite             |
| Dependency update           | Progressive     | Existing + integration tests      |
| Environment change          | Corrective      | Full suite on target environment  |
| Bug fix deployed            | Selective       | Related tests + smoke             |
| Major refactor              | Complete        | Everything across all browsers    |

## Regression Types

| Type            | When                                             | Scope                              |
| --------------- | ------------------------------------------------ | ---------------------------------- |
| **Corrective**  | No application code changed (infra, config, env) | Full suite to verify nothing broke |
| **Progressive** | New features added                               | Existing tests + new feature tests |
| **Selective**   | Specific code changes                            | Changed modules + dependent tests  |
| **Complete**    | Major refactor, release candidate, critical fix  | Run everything across all projects |

## Test Suite Structure — Tier Model

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
import { test, expect } from "@playwright/test";

test(
  "user can log in @smoke @auth",
  { tag: ["@smoke", "@regression"] },
  async ({ page }) => {
    await page.goto("/login");
    await page.getByLabel("Email").fill("user@example.com");
    await page.getByLabel("Password").fill("secure-password");
    await page.getByRole("button", { name: "Sign in" }).click();
    await expect(page).toHaveURL(/.*dashboard/);
  },
);

test(
  "user can reset password @regression @auth",
  { tag: ["@regression"] },
  async ({ page }) => {
    await page.goto("/forgot-password");
    await page.getByLabel("Email").fill("user@example.com");
    await page.getByRole("button", { name: "Reset Password" }).click();
    await expect(page.getByRole("alert")).toContainText("Check your email");
  },
);
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
// Tag tests with risk levels for prioritized execution
test.describe(
  "checkout flow @critical",
  { tag: ["@critical", "@regression"] },
  () => {
    test("user can complete purchase", async ({ page }) => {
      // Critical path — always part of smoke and regression
    });
  },
);

test.describe(
  "profile settings @medium",
  { tag: ["@medium", "@regression"] },
  () => {
    test("user can update avatar", async ({ page }) => {
      // Medium risk — nightly regression only
    });
  },
);
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
# Run critical tests within a 5-minute budget
npx playwright test --grep @critical --timeout 300000

# Run smoke + high-risk tests (skip medium/low)
npx playwright test --grep "@smoke|@critical|@high"
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

## Playwright Best Practices

### Locator Strategy (Priority Order)

| Priority | Locator                | Example                                   |
| -------- | ---------------------- | ----------------------------------------- |
| 1        | Role + accessible name | `getByRole('button', { name: 'Submit' })` |
| 2        | Label                  | `getByLabel('Email')`                     |
| 3        | Placeholder            | `getByPlaceholder('Search...')`           |
| 4        | Text                   | `getByText('Welcome back')`               |
| 5        | Test ID                | `getByTestId('checkout-btn')`             |
| 6        | CSS (last resort)      | `locator('.btn-primary')`                 |

### Web-First Assertions (Auto-Retry)

```typescript
// Web-first assertions — auto-retry until condition met
await expect(page.getByRole("heading")).toHaveText("Dashboard");
await expect(page.getByRole("alert")).toBeVisible();
await expect(page).toHaveURL(/.*\/dashboard/);

// Avoid — no auto-retry, causes flakiness
await page.waitForTimeout(3000);
const text = await page.textContent(".heading");
expect(text).toBe("Dashboard");
```

### Test Independence

Each test must be fully isolated. Never depend on execution order or shared state:

```typescript
// Each test sets up its own state
test("user sees order history", async ({ page }) => {
  // Authenticate via API (fast, no UI dependency)
  await page.request.post("/api/auth/login", {
    data: { email: "user@test.com", password: "pass" },
  });
  await page.goto("/orders");
  await expect(page.getByRole("table")).toBeVisible();
});

// Avoid: test depends on previous test having logged in
```

### Use `test.step()` for Readable Reports

```typescript
test(
  "checkout flow @smoke @checkout",
  { tag: ["@smoke", "@regression"] },
  async ({ page }) => {
    await test.step("Navigate to product page", async () => {
      await page.goto("/products/1");
      await expect(page.getByRole("heading")).toContainText("Product");
    });

    await test.step("Add item to cart", async () => {
      await page.getByRole("button", { name: "Add to Cart" }).click();
      await expect(page.getByTestId("cart-count")).toHaveText("1");
    });

    await test.step("Complete checkout", async () => {
      await page.goto("/checkout");
      await page.getByRole("button", { name: "Place Order" }).click();
      await expect(page.getByRole("heading")).toContainText("Order Confirmed");
    });
  },
);
```

## Example Playwright Test

A complete regression test file demonstrating the patterns from this skill:

```typescript
// tests/regression/checkout/cart.spec.ts
import { test, expect } from "@playwright/test";

test.describe(
  "shopping cart @regression @checkout",
  { tag: ["@regression"] },
  () => {
    test.beforeEach(async ({ page }) => {
      // Authenticate via stored state (setup dependency in config)
      await page.goto("/products");
    });

    test(
      "user can add item to cart @smoke",
      { tag: ["@smoke", "@critical"] },
      async ({ page }) => {
        await test.step("Select a product", async () => {
          await page.getByRole("link", { name: /Running Shoes/i }).click();
          await expect(page.getByRole("heading", { level: 1 })).toContainText(
            "Running Shoes",
          );
        });

        await test.step("Add to cart", async () => {
          await page.getByRole("button", { name: "Add to Cart" }).click();
          await expect(page.getByTestId("cart-count")).toHaveText("1");
        });

        await test.step("Verify cart contents", async () => {
          await page.goto("/cart");
          await expect(page.getByRole("table")).toContainText("Running Shoes");
        });
      },
    );

    test(
      "user can remove item from cart",
      { tag: ["@regression"] },
      async ({ page }) => {
        await test.step("Add an item first", async () => {
          await page.getByRole("link", { name: /Running Shoes/i }).click();
          await page.getByRole("button", { name: "Add to Cart" }).click();
          await expect(page.getByTestId("cart-count")).toHaveText("1");
        });

        await test.step("Remove item from cart", async () => {
          await page.goto("/cart");
          await page.getByRole("button", { name: "Remove" }).click();
          await expect(page.getByText("Your cart is empty")).toBeVisible();
        });
      },
    );

    test(
      "cart persists across page navigation",
      { tag: ["@regression"] },
      async ({ page }) => {
        await test.step("Add item and navigate away", async () => {
          await page.getByRole("link", { name: /Running Shoes/i }).click();
          await page.getByRole("button", { name: "Add to Cart" }).click();
          await page.goto("/");
        });

        await test.step("Return and verify cart", async () => {
          await page.goto("/cart");
          await expect(page.getByRole("table")).toContainText("Running Shoes");
        });
      },
    );
  },
);
```
