# Regression Strategy

> Part of the `playwright-regression-testing` skill. See [SKILL.md](../SKILL.md) for full context.

Detailed reference for regression testing strategy using Playwright with TypeScript. This file covers the tier model, triggers, and regression types. For **test selection approaches** (change-based, risk-based, historical, time-budget) and naming conventions, see [regression-selection.md](regression-selection.md). For **locator and assertion best practices** plus a worked example, see [regression-best-practices.md](regression-best-practices.md).

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
  "user can log in",
  { tag: "@smoke" },
  async ({ page }) => {
    await page.goto("/login");
    await page.getByLabel("Email").fill("user@example.com");
    await page.getByLabel("Password").fill("secure-password");
    await page.getByRole("button", { name: "Sign in" }).click();
    await expect(page).toHaveURL(/.*dashboard/);
  },
);

test(
  "user can reset password",
  { tag: "@regression" },
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

# Run regression tests excluding destructive tests
npx playwright test --grep @regression --grep-invert @destructive

# Run tests for a specific feature
npx playwright test --grep @api
```

### Tag Taxonomy

| Tag           | Purpose                          | Tier          |
| ------------- | -------------------------------- | ------------- |
| `@smoke`      | Critical path, must always pass  | 0             |
| `@sanity`     | Core feature verification        | 1             |
| `@regression` | Standard regression coverage     | 2-3           |
| `@e2e`        | Full user-journey flows          | 2-3           |
| `@api`        | API-level tests                  | 1-2           |
| `@destructive`| Mutates shared/global state      | Sequential    |

> Only these six tags are allowed. Exactly one per test — never combined, never on `describe()` blocks. Tags outside this set (e.g., `@a11y` in accessibility skills) are domain-specific extensions, not execution tags.
