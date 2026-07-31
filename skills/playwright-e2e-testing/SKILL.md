---
name: playwright-e2e-testing
description: 'Author and maintain versioned Playwright (@playwright/test) TypeScript UI specs for browser user flows. Use when asked to create, run, debug, or refactor E2E tests, form/navigation/auth flows, responsive checks, UI mocking, fixtures, Page Objects, or visual comparisons. Use api-testing for standalone REST/GraphQL contracts and playwright-cli for live browser sessions. Keywords: E2E spec, Playwright test, POM, fixtures, UI regression.'
license: 'Complete terms in LICENSE.txt'
---

# Playwright E2E Testing (TypeScript)

Comprehensive toolkit for end-to-end testing of web applications using Playwright with TypeScript. Enables robust UI testing, UI-dependent API setup, and responsive design verification following best practices.

> **Activation:** This skill is triggered when authoring or maintaining versioned Playwright UI specs and their test infrastructure.

## When to Use This Skill

- **Write E2E tests** for user flows, forms, navigation, and authentication
- **UI-dependent API setup** via the `request` fixture or network interception
- **Responsive testing** across mobile, tablet, and desktop viewports
- **Debug flaky tests** using traces, screenshots, videos, and Playwright Inspector
- **Setup test infrastructure** with Page Object Model and fixtures
- **Mock/intercept APIs** for isolated, deterministic testing
- **Visual regression testing** with screenshot comparisons

### Do NOT Use For

- Standalone API/contract testing with no browser (use `api-testing`).
- Driving a live browser interactively for exploration or debugging (use `playwright-cli`).
- Governing a large regression suite, tiers, or CI sharding strategy (use `playwright-regression-testing`).
- Selenium/Java browser automation (use `webapp-selenium-testing`).

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

Prefer role-based locators (`getByRole`) with accessible names, then label → placeholder → text → test ID → CSS (last resort). XPath is never used.

➡️ **Full priority hierarchy, role reference, and examples:** [Locator Strategies: Priority](./references/locator-strategies-priority.md) — the single source of truth.

### 3. Auto-Waiting & Web-First Assertions

Playwright auto-waits for elements. Never use `sleep()` or arbitrary timeouts.

```typescript
// [ok] Web-first assertions (auto-retry)
await expect(page.getByRole("alert")).toBeVisible();
await expect(page).toHaveURL(/dashboard/);
await expect(page.getByTestId("status")).toHaveText("Success!");

// [no] Avoid manual waits
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

## Red Flags

- CSS/XPath locators when a role/label/testId is available — brittle and breaks on refactor.
- `waitForTimeout` / manual sleeps instead of web-first auto-retrying assertions.
- Tests sharing state and depending on execution order — flaky and order-coupled.
- Assertions only on status/URL with no visible-state check — hides render regressions.
- Inline page setup repeated across tests instead of fixtures — duplication and drift.

---

## References

| Document                                                                         | Content                                                    |
| -------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| [Snippets: Setup](./references/snippets-setup.md)                                | Config, auth setup, custom fixtures & logging              |
| [Snippets: Interactions](./references/snippets-interactions.md)                  | Form interactions, API testing & network interception      |
| [Snippets: Viewports & Auth](./references/snippets-viewports-auth.md)            | Responsive viewports & authentication patterns             |
| [Snippets: Assertions & Debug](./references/snippets-assertions-debugging.md)    | Assertions, debug commands & utility helpers               |
| [Locator Strategies: Priority](./references/locator-strategies-priority.md)      | Locator priority hierarchy & role-based locators           |
| [Locator Strategies: Text](./references/locator-strategies-text.md)              | Label, text, placeholder, alt-text & test-ID locators      |
| [Locator Strategies: Filtering](./references/locator-strategies-filtering.md)    | Filtering, chaining & complex locator patterns             |
| [Locator Strategies: Anti & Debug](./references/locator-strategies-anti-debug.md)| Anti-patterns, CSS last-resort, debugging & quick reference|
| [POM: Basics](./references/page-object-model-basics.md)                          | POM concepts, directory structure, base page & fluent API  |
| [POM: Components](./references/page-object-model-components.md)                  | Page object & reusable component object implementation     |
| [POM: Fixtures](./references/page-object-model-fixtures.md)                      | Custom & authenticated page-object fixtures                |
| [POM: Practices](./references/page-object-model-practices.md)                    | Best practices, anti-patterns & a complete worked example  |
| [Debugging: Tools & UI](./references/debugging-tools-ui.md)                      | Debugging tools, UI mode, Inspector & headed mode          |
| [Debugging: Tracing & Logs](./references/debugging-tracing-logging.md)           | Trace viewer, verbose logging, screenshots & videos        |
| [Debugging: Errors & Network](./references/debugging-errors-network.md)          | Console/page errors & network debugging                    |
| [Debugging: Flaky & Locators](./references/debugging-flaky-locators.md)          | Flaky-test fixes, locator debugging & quick commands       |

---

## Verification

- [ ] **Uses custom fixture injection** — No `new PageObject()` calls in spec files; all POMs injected via fixtures
- [ ] **Locators use recommended strategies** — All locators use `getByRole()`, `getByTestId()`, or `getByText()`; no CSS selectors for interactive elements
- [ ] **Tests are independent** — Each test sets up and tears down its own state; no `beforeAll` with shared mutable state
- [ ] **Error states covered** — At least one test verifies error/empty/loading states alongside happy path
