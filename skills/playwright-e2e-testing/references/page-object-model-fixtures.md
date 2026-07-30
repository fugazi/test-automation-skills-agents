# Page Object Model: Custom & Authenticated Fixtures

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `page-object-model.md`. See the other `page-object-model-*.md` files in this folder for related sections.

## Custom Fixtures

Inject page objects into tests via fixtures:

```typescript
// fixtures/pages.fixture.ts
import { test as base } from "@playwright/test";
import { LoginPage } from "../pages/LoginPage";
import { DashboardPage } from "../pages/DashboardPage";
import { ProductPage } from "../pages/ProductPage";

type Pages = {
  loginPage: LoginPage;
  dashboardPage: DashboardPage;
  productPage: ProductPage;
};

export const test = base.extend<Pages>({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },
  dashboardPage: async ({ page }, use) => {
    await use(new DashboardPage(page));
  },
  productPage: async ({ page }, use) => {
    await use(new ProductPage(page));
  },
});

export { expect } from "@playwright/test";
```

### Using in Tests

```typescript
// specs/login.spec.ts
import { test, expect } from "../fixtures/pages.fixture";

test.describe("Login", () => {
  test("successful login", async ({ loginPage }) => {
    await loginPage.goto();
    const dashboard = await loginPage.login("user@test.com", "password123");
    await dashboard.expectWelcomeMessage("Test User");
  });

  test("invalid credentials", async ({ loginPage }) => {
    await loginPage.goto();
    await loginPage.attemptInvalidLogin("wrong@test.com", "wrong");
    await loginPage.expectErrorMessage("Invalid credentials");
  });

  test("empty form validation", async ({ loginPage }) => {
    await loginPage.goto();
    await loginPage.clickLogin();
    await loginPage.expectEmailFieldError();
  });
});
```

---

## Authenticated Fixture

Pre-authenticate for tests requiring login:

```typescript
// fixtures/auth.fixture.ts
import { test as base } from "@playwright/test";
import { DashboardPage } from "../pages/DashboardPage";
import { LoginPage } from "../pages/LoginPage";

type AuthFixtures = {
  authenticatedDashboard: DashboardPage;
};

export const test = base.extend<AuthFixtures>({
  authenticatedDashboard: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    const dashboard = await loginPage.login(
      process.env.TEST_USER_EMAIL!,
      process.env.TEST_USER_PASSWORD!,
    );
    await use(dashboard);
  },
});

export { expect } from "@playwright/test";
```

### Or Use Storage State

```typescript
// auth.setup.ts
import { test as setup } from "@playwright/test";
import { LoginPage } from "../pages/LoginPage";

setup("authenticate", async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login("user@test.com", "password123");

  await page.context().storageState({ path: "playwright/.auth/user.json" });
});

// In specs:
test.use({ storageState: "playwright/.auth/user.json" });
```

---
