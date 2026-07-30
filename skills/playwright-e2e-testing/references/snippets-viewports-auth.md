# Snippets: Responsive Testing & Authentication

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `snippets.md`. See the other `snippets-*.md` files in this folder for related sections.

## Responsive Testing

### Multiple Viewports Loop

```typescript
const viewports = [
  { width: 375, height: 667, name: "mobile" },
  { width: 768, height: 1024, name: "tablet" },
  { width: 1280, height: 720, name: "desktop" },
];

for (const vp of viewports) {
  test.describe(`${vp.name} viewport`, () => {
    test.use({ viewport: { width: vp.width, height: vp.height } });

    test("navigation is accessible", async ({ page }) => {
      await page.goto("/");

      if (vp.width < 768) {
        // Mobile: hamburger menu
        const menuButton = page.getByRole("button", { name: /menu/i });
        await expect(menuButton).toBeVisible();
        await menuButton.click();
      }

      await page.getByRole("link", { name: "About" }).click();
      await expect(page).toHaveURL(/about/);
    });
  });
}
```

### Project-based Responsive Testing

```typescript
// In playwright.config.ts projects:
// projects: [
//   { name: 'desktop', use: { viewport: { width: 1280, height: 720 } } },
//   { name: 'mobile', use: { viewport: { width: 375, height: 667 } } },
// ]

// Test file (runs on all projects)
test("layout adapts to viewport", async ({ page }) => {
  await page.goto("/");

  const viewport = page.viewportSize();
  const isMobile = viewport && viewport.width < 768;

  if (isMobile) {
    await expect(page.getByTestId("mobile-nav")).toBeVisible();
    await expect(page.getByTestId("desktop-nav")).toBeHidden();
  } else {
    await expect(page.getByTestId("desktop-nav")).toBeVisible();
    await expect(page.getByTestId("mobile-nav")).toBeHidden();
  }
});
```

---

## Authentication

### Storage State Setup

```typescript
// auth.setup.ts
import { test as setup, expect } from "@playwright/test";

const authFile = "playwright/.auth/user.json";

setup("authenticate", async ({ page }) => {
  await page.goto("/login");
  await page.getByLabel("Email").fill("user@example.com");
  await page.getByLabel("Password").fill("password123");
  await page.getByRole("button", { name: "Sign in" }).click();

  // Wait for auth to complete
  await page.waitForURL("**/dashboard");

  // Save storage state
  await page.context().storageState({ path: authFile });
});
```

### Use Storage State in Tests

```typescript
// tests/authenticated.spec.ts
import { test, expect } from "@playwright/test";

test.use({ storageState: "playwright/.auth/user.json" });

test("access protected page", async ({ page }) => {
  await page.goto("/settings");
  // Already logged in via storage state
  await expect(page.getByRole("heading", { name: "Settings" })).toBeVisible();
});
```

### API Token Authentication

```typescript
// Fixture for API token
import { test as base } from "@playwright/test";

export const test = base.extend<{ apiToken: string }>({
  apiToken: async ({ request }, use) => {
    const response = await request.post("/api/auth/login", {
      data: { email: "api@test.com", password: "password" },
    });
    const { token } = await response.json();
    await use(token);
  },
});

// Use in test
test("authenticated API call", async ({ request, apiToken }) => {
  const response = await request.get("/api/protected", {
    headers: { Authorization: `Bearer ${apiToken}` },
  });
  expect(response.ok()).toBeTruthy();
});
```

---
