# Regression Testing — Playwright Best Practices

> Part of the `playwright-regression-testing` skill. See [SKILL.md](../SKILL.md) for full context.
>
> **Related:** split from [regression-strategy.md](regression-strategy.md). See that file for the tier model and triggers; see [regression-selection.md](regression-selection.md) for test selection approaches.

Locator strategy, web-first assertions, test independence, step-based reporting, and a complete worked example test file.

## Playwright Best Practices

### Locator Strategy (Priority Order)

Prefer role-based locators (`getByRole`) with accessible names, then label → placeholder → text → test ID → CSS (last resort); never XPath.

> The canonical priority hierarchy and role reference live in the `playwright-e2e-testing` skill (`references/locator-strategies-priority.md`). Do not duplicate it here — reference that source for the full table.

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
  "checkout flow",
  { tag: "@smoke" },
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

test.describe("shopping cart", () => {
    test.beforeEach(async ({ page }) => {
      // Authenticate via stored state (setup dependency in config)
      await page.goto("/products");
    });

    test(
      "user can add item to cart",
      { tag: "@smoke" },
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
      { tag: "@regression" },
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
      { tag: "@regression" },
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
