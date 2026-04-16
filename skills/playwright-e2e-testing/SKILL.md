---
name: playwright-e2e-testing
description: End-to-end, API, and responsive testing for web applications using Playwright with TypeScript. Use when asked to write, run, debug, or maintain Playwright (@playwright/test) TypeScript tests for UI behavior, form submissions, user flows, API validation, responsive design, or visual regression. Covers browser automation, network interception, mocking, Page Object Model, fixtures, and parallel execution.
---

# Playwright E2E Testing (TypeScript)

Comprehensive toolkit for end-to-end testing of web applications using Playwright with TypeScript. Enables robust UI testing, API validation, and responsive design verification following best practices.

> **Activation:** This skill is triggered when working with Playwright tests, browser automation, E2E testing, API testing with Playwright, or test infrastructure setup.

## When to Use This Skill

- **Write E2E tests** for user flows, forms, navigation, and authentication
- **API testing** via `request` fixture or network interception during UI tests
- **Responsive testing** across mobile, tablet, and desktop viewports
- **Debug flaky tests** using traces, screenshots, videos, and Playwright Inspector
- **Setup test infrastructure** with Page Object Model and fixtures
- **Mock/intercept APIs** for isolated, deterministic testing
- **Visual regression testing** with screenshot comparisons

## Prerequisites

| Requirement     | Details                                             |
| --------------- | --------------------------------------------------- |
| Node.js         | v18+ recommended                                    |
| Package Manager | npm, yarn, or pnpm                                  |
| Playwright      | `@playwright/test` package                          |
| TypeScript      | `typescript` + `ts-node` (optional but recommended) |
| Browsers        | Installed via `npx playwright install`              |

### Quick Setup

```bash
# Initialize new project
npm init playwright@latest

# Or add to existing project
npm install -D @playwright/test
npx playwright install
```

## First Questions to Ask

Before writing tests, clarify:

1. **App URL**: Local dev server command + port, or staging URL?
2. **Critical flows**: Which user journeys must be covered (happy path + error states)?
3. **Browsers/devices**: Chrome, Firefox, Safari? Mobile viewports?
4. **API strategy**: Real backend, mocked responses, or hybrid?
5. **Test data**: Seed data available? Reset/cleanup strategy?

---

## Core Principles

### 1. Test Runner & TypeScript

Always use `@playwright/test` with TypeScript for type safety and better IDE support.

```typescript
import { test, expect } from "@playwright/test";

test("user can login", async ({ page }) => {
  await page.goto("/login");
  await page.getByLabel("Email").fill("user@test.com");
  await page.getByLabel("Password").fill("password123");
  await page.getByRole("button", { name: "Sign in" }).click();
  await expect(page).toHaveURL(/.*dashboard/);
});
```

### 2. Locator Strategy (Priority Order)

| Priority | Locator                | Example                                   |
| -------- | ---------------------- | ----------------------------------------- |
| 1        | Role + accessible name | `getByRole('button', { name: 'Submit' })` |
| 2        | Label                  | `getByLabel('Email')`                     |
| 3        | Placeholder            | `getByPlaceholder('Enter email')`         |
| 4        | Text                   | `getByText('Welcome')`                    |
| 5        | Test ID                | `getByTestId('submit-btn')`               |
| 6        | CSS (avoid)            | `locator('.btn-primary')`                 |

See [Locator Strategies Guide](./references/locator_strategies.md) for detailed patterns.

### 3. Auto-Waiting & Web-First Assertions

Playwright auto-waits for elements. Never use `sleep()` or arbitrary timeouts.

```typescript
// ✅ Web-first assertions (auto-retry)
await expect(page.getByRole("alert")).toBeVisible();
await expect(page).toHaveURL(/dashboard/);
await expect(page.getByTestId("status")).toHaveText("Success!");

// ❌ Avoid manual waits
await page.waitForTimeout(2000); // Bad practice
```

### 4. Test Structure with Steps

Use `test.step()` for readable reports and failure localization:

```typescript
test("checkout flow", async ({ page }) => {
  await test.step("Add item to cart", async () => {
    await page.goto("/products/1");
    await page.getByRole("button", { name: "Add to Cart" }).click();
  });

  await test.step("Complete checkout", async () => {
    await page.goto("/checkout");
    await page.getByRole("button", { name: "Pay Now" }).click();
  });

  await test.step("Verify confirmation", async () => {
    await expect(page.getByRole("heading")).toContainText("Order Confirmed");
  });
});
```

---

## Key Workflows

### Forms & Navigation

```typescript
// Form submit and wait for navigation (auto-waiting)
await page.getByRole("button", { name: "Login" }).click();
await expect(page).toHaveURL(/.*dashboard/);

// Form with API response validation
const responsePromise = page.waitForResponse(
  (r) => r.url().includes("/api/login") && r.status() === 200,
);
await page.getByRole("button", { name: "Login" }).click();
const response = await responsePromise;
```

### API Testing (Request Fixture)

```typescript
test("API health check", async ({ request }) => {
  const response = await request.get("/api/health");
  expect(response.ok()).toBeTruthy();
  expect(await response.json()).toMatchObject({ status: "ok" });
});
```

### API Mocking & Interception

```typescript
test("handles API error", async ({ page }) => {
  await page.route("**/api/users", (route) =>
    route.fulfill({
      status: 500,
      body: JSON.stringify({ error: "Server error" }),
    }),
  );
  await page.goto("/users");
  await expect(page.getByRole("alert")).toContainText("Something went wrong");
});
```

### Responsive Testing

```typescript
const viewports = [
  { width: 375, height: 667, name: "mobile" },
  { width: 768, height: 1024, name: "tablet" },
  { width: 1280, height: 720, name: "desktop" },
];

for (const vp of viewports) {
  test(`navigation works on ${vp.name}`, async ({ page }) => {
    await page.setViewportSize(vp);
    await page.goto("/");
    // Mobile: hamburger menu
    if (vp.width < 768) {
      await page.getByRole("button", { name: /menu/i }).click();
    }
    await page.getByRole("link", { name: "About" }).click();
    await expect(page).toHaveURL(/about/);
  });
}
```

---

## Configuration

Use `playwright.config.ts` for project-wide settings:

```typescript
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./tests",
  retries: process.env.CI ? 2 : 0,
  reporter: [["html"], ["junit", { outputFile: "results.xml" }]],
  use: {
    baseURL: "http://localhost:3000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },
  projects: [
    { name: "chromium", use: devices["Desktop Chrome"] },
    { name: "mobile", use: devices["Pixel 5"] },
  ],
  webServer: {
    command: "npm run dev",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
  },
});
```

---

## Troubleshooting

| Problem                | Cause                         | Solution                                                |
| ---------------------- | ----------------------------- | ------------------------------------------------------- |
| Element not found      | Wrong locator or not rendered | Use `PWDEBUG=1` to inspect, verify with `getByRole`     |
| Timeout waiting        | Element hidden or slow load   | Check for overlays, increase timeout, use `waitFor()`   |
| Flaky tests            | Race conditions, animations   | Add `test.step()`, use proper waits, disable animations |
| Strict mode violation  | Multiple elements match       | Use `.first()`, `.filter()`, or more specific locator   |
| Screenshots differ     | Dynamic content               | Mask dynamic areas, use deterministic data              |
| CI fails, local passes | Environment differences       | Check `baseURL`, timeouts, `webServer` config           |
| API mock not working   | Route pattern mismatch        | Use `**/api/...` glob, verify with `page.on('request')` |

---

## CLI Quick Reference

| Command                                  | Description                   |
| ---------------------------------------- | ----------------------------- |
| `npx playwright test`                    | Run all tests headless        |
| `npx playwright test --ui`               | Open UI mode (interactive)    |
| `npx playwright test --headed`           | Run with visible browser      |
| `npx playwright test --debug`            | Run with Playwright Inspector |
| `npx playwright test -g "login"`         | Run tests matching pattern    |
| `npx playwright test --project=chromium` | Run specific project          |
| `npx playwright show-report`             | Open HTML report              |
| `npx playwright codegen`                 | Generate tests by recording   |
| `PWDEBUG=1 npx playwright test`          | Debug with Inspector          |
| `DEBUG=pw:api npx playwright test`       | Verbose API logging           |

---

## Common Rationalizations

> Common shortcuts and "good enough" excuses that erode test quality — and the reality behind each.

| Rationalization                     | Reality                                                                                                      |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| "I'll add assertions later"         | A test without assertions is a script, not a test. Add meaningful assertions now — later never comes.        |
| "This selector is stable enough"    | CSS selectors break on refactor. Use `data-testid` or role-based locators for stability.                     |
| "The test passes on my machine"     | Local passes don't guarantee CI passes. Always validate in the target environment.                           |
| "Skip the edge cases for now"       | Edge cases are where production bugs live. Test them first, not last.                                        |
| "Visual tests aren't needed"        | Visual regression catches CSS/layout bugs that functional assertions miss entirely.                          |
| "This API won't change"             | APIs evolve constantly. Contract tests prevent silent downstream failures.                                   |
| "One browser is enough"             | Cross-browser issues are real and common. Test at least Chromium and Firefox.                                |
| "`networkidle` is fine for waiting" | `networkidle` is deprecated and unreliable. Wait for specific conditions (elements, responses, URL changes). |

---

## References

| Document                                                 | Content                                |
| -------------------------------------------------------- | -------------------------------------- |
| [Snippets](./references/snippets.md)                     | Ready-to-use code patterns             |
| [Locator Strategies](./references/locator_strategies.md) | Complete locator guide                 |
| [Page Object Model](./references/page_object_model.md)   | POM implementation patterns            |
| [Debugging Guide](./references/debugging.md)             | Troubleshooting & debugging techniques |

---

## Verification

After completing this skill's workflow, confirm:

- [ ] **Test file follows naming convention** — File named `*.spec.ts` in the appropriate directory
- [ ] **Uses custom fixture injection** — No `new PageObject()` calls in spec files; all POMs injected via fixtures
- [ ] **Locators use recommended strategies** — All locators use `getByRole()`, `getByTestId()`, or `getByText()`; no CSS selectors for interactive elements
- [ ] **Auto-waiting patterns used** — No `page.waitForTimeout()` or `sleep()` calls; all waits use `waitForSelector()`, `waitForURL()`, or built-in auto-waiting
- [ ] **Tests are independent** — Each test sets up and tears down its own state; no `beforeAll` with shared mutable state
- [ ] **Error states covered** — At least one test verifies error/empty/loading states alongside happy path
- [ ] **All tests pass** — `npx playwright test` exits with code 0
- [ ] **No skipped tests** — `grep -R -E "test\.skip|test\.fixme" --include="*.spec.ts" .` returns no results
