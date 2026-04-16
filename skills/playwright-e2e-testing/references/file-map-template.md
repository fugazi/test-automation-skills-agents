# File Map Template (Playwright TypeScript)

When agents generate test code for a target project, they must follow this structure. Copy this section into the target project's CLAUDE.md or test configuration.

## Recommended Project Structure

```
tests/
├── pages/                      # Page Object Models
│   └── {feature}/
│       └── {name}.page.ts      # One POM per page/component
├── fixtures/
│   ├── test-base.ts            # Custom test with merged fixtures
│   └── {scope}.fixture.ts      # Auth, cart, API fixtures
├── data/
│   ├── users.data.ts           # User credentials and roles
│   ├── {entity}.data.ts        # Feature-specific test data
│   └── factories/              # Optional: data factories
├── helpers/
│   └── {name}.helper.ts        # Reusable test utilities
└── e2e/
    └── {feature}/
        └── {name}.spec.ts      # Test specs by feature
```

## Naming Conventions

| Type        | Pattern              | Example                              |
| ----------- | -------------------- | ------------------------------------ |
| Page Object | `{name}.page.ts`     | `login.page.ts`, `cart.page.ts`      |
| Spec        | `{name}.spec.ts`     | `login.spec.ts`, `checkout.spec.ts`  |
| Fixture     | `{scope}.fixture.ts` | `auth.fixture.ts`, `cart.fixture.ts` |
| Data        | `{entity}.data.ts`   | `users.data.ts`, `products.data.ts`  |
| Helper      | `{name}.helper.ts`   | `api.helper.ts`, `date.helper.ts`    |

## Fixture System (DI)

All tests import from the custom fixture base — never from `@playwright/test` directly in specs.

```typescript
// tests/fixtures/test-base.ts
import { mergeTests } from "@playwright/test";
import { pagesTest } from "./pages.fixture";
import { authTest } from "./auth.fixture";

export const test = mergeTests(pagesTest, authTest);
export { expect };
```

```typescript
// tests/fixtures/pages.fixture.ts
import { test as base } from "@playwright/test";
import { LoginPage } from "../pages/auth/login.page";
import { HomePage } from "../pages/home/home.page";

type Pages = {
  loginPage: LoginPage;
  homePage: HomePage;
};

export const pagesTest = base.extend<Pages>({
  loginPage: async ({ page }, use) => await use(new LoginPage(page)),
  homePage: async ({ page }, use) => await use(new HomePage(page)),
});
```

## Spec Template

```typescript
// tests/e2e/{feature}/{name}.spec.ts
import { test, expect } from "../fixtures/test-base";
import { USERS } from "../data/users.data";

test.describe("Feature Name", () => {
  test("should do something", async ({ homePage, loginPage }) => {
    await test.step("Navigate to feature", async () => {
      await homePage.goto();
    });

    await test.step("Perform action", async () => {
      await loginPage.login(USERS.customer);
    });

    await test.step("Verify result", async () => {
      await expect(homePage.dashboard).toBeVisible();
    });
  });
});
```

## POM Template

```typescript
// tests/pages/{feature}/{name}.page.ts
import { expect, Locator, Page } from "@playwright/test";

export class ExamplePage {
  readonly heading: Locator;
  readonly actionButton: Locator;

  constructor(private readonly page: Page) {
    this.heading = page.getByRole("heading", { name: "Example" });
    this.actionButton = page.getByRole("button", { name: "Action" });
  }

  async goto(): Promise<void> {
    await this.page.goto("/example");
  }

  async performAction(): Promise<void> {
    await this.actionButton.click();
  }
}
```

## Usage

Copy the "Recommended Project Structure" section into the target project's CLAUDE.md under a `## File Map` heading. Agents will use this to place files in the correct directories.
