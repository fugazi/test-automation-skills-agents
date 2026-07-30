# Page Object Model: Basics & Fluent Interface

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `page-object-model.md`. See the other `page-object-model-*.md` files in this folder for related sections.

## What is Page Object Model?

Page Object Model (POM) creates an abstraction layer between test logic and page implementation. Each page/component gets its own class encapsulating:

- **Locators** for elements on the page
- **Actions** for user interactions
- **Assertions** for state validation

### Benefits

| Benefit         | Description                            |
| --------------- | -------------------------------------- |
| Maintainability | Change locator once, not in every test |
| Readability     | Tests read like user stories           |
| Reusability     | Share page logic across tests          |
| Separation      | Test logic separate from page details  |
| Scalability     | Easy to add new pages/components       |
| Type Safety     | TypeScript ensures correct usage       |

---

## Directory Structure

```
tests/
├── pages/
│   ├── BasePage.ts           # Common functionality
│   ├── LoginPage.ts
│   ├── DashboardPage.ts
│   ├── ProductPage.ts
│   └── components/
│       ├── HeaderComponent.ts
│       ├── FooterComponent.ts
│       └── ModalComponent.ts
├── fixtures/
│   └── pages.fixture.ts      # Page Object fixtures
├── specs/
│   ├── login.spec.ts
│   ├── dashboard.spec.ts
│   └── products.spec.ts
└── playwright.config.ts
```

---

## Base Page Pattern

Create a base class with common functionality:

```typescript
// pages/BasePage.ts
import { Page, Locator, expect } from "@playwright/test";

export abstract class BasePage {
  readonly page: Page;
  readonly header: Locator;
  readonly footer: Locator;
  readonly loadingSpinner: Locator;

  constructor(page: Page) {
    this.page = page;
    this.header = page.getByRole("banner");
    this.footer = page.getByRole("contentinfo");
    this.loadingSpinner = page.getByRole("progressbar");
  }

  /**
   * Navigate to the page
   */
  abstract goto(): Promise<this>;

  /**
   * Wait for page to fully load
   */
  async waitForPageLoad(): Promise<void> {
    await this.loadingSpinner.waitFor({ state: "hidden", timeout: 30000 });
  }

  /**
   * Get the page title
   */
  async getTitle(): Promise<string> {
    return this.page.title();
  }

  /**
   * Get the current URL
   */
  getUrl(): string {
    return this.page.url();
  }

  /**
   * Take a screenshot
   */
  async screenshot(name: string): Promise<void> {
    await this.page.screenshot({
      path: `screenshots/${name}-${Date.now()}.png`,
      fullPage: true,
    });
  }

  /**
   * Wait for URL to match pattern
   */
  async waitForUrl(pattern: RegExp | string): Promise<void> {
    await this.page.waitForURL(pattern);
  }
}
```

---

## Fluent Interface Pattern

Design methods to return `this` for chaining:

```typescript
// Actions on same page return 'this'
await loginPage
  .fillEmail("user@test.com")
  .fillPassword("password123")
  .checkRememberMe();

// Navigation returns next page
const dashboard = await loginPage.login("user@test.com", "password123");
await dashboard.expectWelcomeMessage("John");
```

### Implementation Rules

```typescript
export class CheckoutPage extends BasePage {
  // Actions staying on same page → return 'this'
  async selectShipping(method: string): Promise<this> {
    await this.page.getByRole("radio", { name: method }).check();
    return this;
  }

  async enterPromoCode(code: string): Promise<this> {
    await this.promoInput.fill(code);
    await this.applyPromoButton.click();
    return this;
  }

  // Actions navigating to new page → return new Page Object
  async proceedToPayment(): Promise<PaymentPage> {
    await this.proceedButton.click();
    await this.page.waitForURL(/.*payment/);
    return new PaymentPage(this.page);
  }

  // Validation methods → return void (assertions throw on failure)
  async expectTotalPrice(price: string): Promise<void> {
    await expect(this.totalPrice).toHaveText(price);
  }
}
```

---

## Anti-Patterns

| Anti-Pattern          | Problem                    | Solution                     |
| --------------------- | -------------------------- | ---------------------------- |
| God Page Object       | One class for entire app   | One class per page/component |
| Fat Page Object       | Too many methods           | Split into components        |
| Locators in tests     | Duplicated, hard to update | Keep in page objects         |
| Assertions in actions | Mixes concerns             | Separate expect methods      |
| Hardcoded waits       | Flaky                      | Use auto-waiting locators    |
| Direct page access    | Bypasses abstraction       | Use page object methods      |

---
