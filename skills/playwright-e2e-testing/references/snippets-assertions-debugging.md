# Snippets: Assertions, Debugging & Utilities

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `snippets.md`. See the other `snippets-*.md` files in this folder for related sections.

## Assertions

### Common Web-First Assertions

```typescript
// Visibility
await expect(page.getByRole("button")).toBeVisible();
await expect(page.getByRole("dialog")).toBeHidden();

// Text content
await expect(page.getByRole("heading")).toHaveText("Welcome");
await expect(page.getByRole("heading")).toContainText("Welcome");

// URL
await expect(page).toHaveURL(/.*dashboard/);
await expect(page).toHaveURL("https://example.com/dashboard");

// Input values
await expect(page.getByLabel("Name")).toHaveValue("John");
await expect(page.getByLabel("Name")).toBeEmpty();

// Checkbox/radio state
await expect(page.getByRole("checkbox")).toBeChecked();
await expect(page.getByRole("checkbox")).not.toBeChecked();

// Enabled/disabled
await expect(page.getByRole("button")).toBeEnabled();
await expect(page.getByRole("button")).toBeDisabled();

// Focus
await expect(page.getByLabel("Email")).toBeFocused();

// Count
await expect(page.getByRole("listitem")).toHaveCount(5);

// Attributes
await expect(page.getByRole("link")).toHaveAttribute("href", "/about");

// CSS class
await expect(page.getByRole("button")).toHaveClass(/active/);

// Screenshot comparison
await expect(page).toHaveScreenshot("homepage.png");
await expect(page.getByTestId("chart")).toHaveScreenshot("chart.png");
```

### Soft Assertions

```typescript
test("multiple checks with soft assertions", async ({ page }) => {
  await page.goto("/profile");

  // Soft assertions don't stop the test on failure
  await expect.soft(page.getByText("Name: John")).toBeVisible();
  await expect.soft(page.getByText("Email: john@test.com")).toBeVisible();
  await expect.soft(page.getByText("Role: Admin")).toBeVisible();

  // All failures reported at the end
});
```

### Polling Assertions

```typescript
test("wait for condition", async ({ page }) => {
  await page.goto("/processing");

  // Poll until condition is met
  await expect(async () => {
    const status = await page.getByTestId("status").textContent();
    expect(status).toBe("Complete");
  }).toPass({ timeout: 30000 });
});
```

---

## Debugging

### Debug Commands

```bash
# UI mode (interactive)
npx playwright test --ui

# Debug with Inspector
PWDEBUG=1 npx playwright test

# Run specific test
npx playwright test -g "login flow"

# Headed mode
npx playwright test --headed

# Verbose API logs
DEBUG=pw:api npx playwright test

# View report
npx playwright show-report

# Codegen (record tests)
npx playwright codegen http://localhost:3000
```

### In-Test Debugging

```typescript
test("debug example", async ({ page }) => {
  await page.goto("/");

  // Pause test for manual inspection
  await page.pause();

  // Log to terminal
  console.log("Current URL:", page.url());

  // Screenshot for debugging
  await page.screenshot({ path: "debug.png", fullPage: true });

  // Evaluate in browser console
  const result = await page.evaluate(() => {
    return document.querySelector("h1")?.textContent;
  });
  console.log("H1 text:", result);
});
```

---

## Utilities

### Retry Flaky Operations

```typescript
import { test, expect } from "@playwright/test";

test("retry flaky button click", async ({ page }) => {
  await page.goto("/");

  // Retry until success or timeout
  await expect(async () => {
    await page.getByRole("button", { name: "Submit" }).click();
    await expect(page.getByText("Success")).toBeVisible();
  }).toPass({
    timeout: 10000,
    intervals: [500, 1000, 2000],
  });
});
```

### Wait for Network Idle

```typescript
test("wait for all API calls", async ({ page }) => {
  await page.goto("/dashboard", { waitUntil: "networkidle" });

  // Or wait manually
  await page.waitForLoadState("networkidle");
});
```

### Screenshot with Mask

```typescript
test("screenshot without dynamic elements", async ({ page }) => {
  await page.goto("/");

  await expect(page).toHaveScreenshot("homepage.png", {
    mask: [page.getByTestId("timestamp"), page.getByTestId("random-ad")],
    maxDiffPixels: 100,
  });
});
```

### Trace Viewer

```typescript
// Enable trace in config
// use: { trace: 'on-first-retry' }

// Or manually in test
test("with trace", async ({ page, context }) => {
  await context.tracing.start({ screenshots: true, snapshots: true });

  await page.goto("/");
  await page.getByRole("button", { name: "Submit" }).click();

  await context.tracing.stop({ path: "trace.zip" });
});
```
