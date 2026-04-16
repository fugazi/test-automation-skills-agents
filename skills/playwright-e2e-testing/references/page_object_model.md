# Page Object Model (POM) Guide

Design patterns and best practices for implementing maintainable Page Objects in Playwright with TypeScript.

---

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

## Page Object Implementation

### Login Page

```typescript
// pages/LoginPage.ts
import { Page, Locator, expect } from "@playwright/test";
import { BasePage } from "./BasePage";
import { DashboardPage } from "./DashboardPage";

export class LoginPage extends BasePage {
  // Locators (defined in constructor)
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly loginButton: Locator;
  readonly errorMessage: Locator;
  readonly forgotPasswordLink: Locator;
  readonly signUpLink: Locator;
  readonly rememberMeCheckbox: Locator;

  constructor(page: Page) {
    super(page);
    this.emailInput = page.getByLabel("Email");
    this.passwordInput = page.getByLabel("Password");
    this.loginButton = page.getByRole("button", { name: "Sign in" });
    this.errorMessage = page.getByRole("alert");
    this.forgotPasswordLink = page.getByRole("link", {
      name: "Forgot password?",
    });
    this.signUpLink = page.getByRole("link", { name: "Sign up" });
    this.rememberMeCheckbox = page.getByRole("checkbox", {
      name: "Remember me",
    });
  }

  // Navigation
  async goto(): Promise<this> {
    await this.page.goto("/login");
    return this;
  }

  // Actions - return 'this' for fluent chaining
  async fillEmail(email: string): Promise<this> {
    await this.emailInput.fill(email);
    return this;
  }

  async fillPassword(password: string): Promise<this> {
    await this.passwordInput.fill(password);
    return this;
  }

  async checkRememberMe(): Promise<this> {
    await this.rememberMeCheckbox.check();
    return this;
  }

  async clickLogin(): Promise<void> {
    await this.loginButton.click();
  }

  // Combined action - returns next page
  async login(email: string, password: string): Promise<DashboardPage> {
    await this.fillEmail(email);
    await this.fillPassword(password);
    await this.clickLogin();
    await this.page.waitForURL(/.*dashboard/);
    return new DashboardPage(this.page);
  }

  // Attempt invalid login (stays on same page)
  async attemptInvalidLogin(email: string, password: string): Promise<this> {
    await this.fillEmail(email);
    await this.fillPassword(password);
    await this.clickLogin();
    return this;
  }

  // Validation methods
  async expectErrorMessage(message: string): Promise<void> {
    await expect(this.errorMessage).toContainText(message);
  }

  async expectLoginButtonEnabled(): Promise<void> {
    await expect(this.loginButton).toBeEnabled();
  }

  async expectLoginButtonDisabled(): Promise<void> {
    await expect(this.loginButton).toBeDisabled();
  }

  async expectEmailFieldError(): Promise<void> {
    await expect(this.emailInput).toHaveAttribute("aria-invalid", "true");
  }
}
```

### Dashboard Page

```typescript
// pages/DashboardPage.ts
import { Page, Locator, expect } from "@playwright/test";
import { BasePage } from "./BasePage";
import { HeaderComponent } from "./components/HeaderComponent";

export class DashboardPage extends BasePage {
  readonly header: HeaderComponent;
  readonly welcomeHeading: Locator;
  readonly statsCards: Locator;
  readonly recentActivityList: Locator;
  readonly quickActionsMenu: Locator;

  constructor(page: Page) {
    super(page);
    this.header = new HeaderComponent(page);
    this.welcomeHeading = page.getByRole("heading", { level: 1 });
    this.statsCards = page.getByTestId("stats-card");
    this.recentActivityList = page.getByRole("list", {
      name: "Recent Activity",
    });
    this.quickActionsMenu = page.getByRole("menu", { name: "Quick Actions" });
  }

  async goto(): Promise<this> {
    await this.page.goto("/dashboard");
    return this;
  }

  async getWelcomeMessage(): Promise<string> {
    return (await this.welcomeHeading.textContent()) ?? "";
  }

  async getStatsCount(): Promise<number> {
    return this.statsCards.count();
  }

  async clickQuickAction(actionName: string): Promise<void> {
    await this.quickActionsMenu
      .getByRole("menuitem", { name: actionName })
      .click();
  }

  async expectWelcomeMessage(name: string): Promise<void> {
    await expect(this.welcomeHeading).toContainText(`Welcome, ${name}`);
  }

  async expectMinimumStats(count: number): Promise<void> {
    await expect(this.statsCards).toHaveCount(count);
  }
}
```

---

## Component Objects

For reusable UI components (header, footer, modals):

### Header Component

```typescript
// pages/components/HeaderComponent.ts
import { Page, Locator, expect } from "@playwright/test";

export class HeaderComponent {
  readonly page: Page;
  readonly container: Locator;
  readonly logo: Locator;
  readonly searchBox: Locator;
  readonly cartIcon: Locator;
  readonly cartCount: Locator;
  readonly userMenu: Locator;
  readonly logoutButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.container = page.getByRole("banner");
    this.logo = this.container.getByRole("link", { name: "Home" });
    this.searchBox = page.getByRole("searchbox");
    this.cartIcon = this.container.getByRole("link", { name: /cart/i });
    this.cartCount = page.getByTestId("cart-count");
    this.userMenu = this.container.getByRole("button", { name: /account/i });
    this.logoutButton = page.getByRole("menuitem", { name: "Logout" });
  }

  async search(query: string): Promise<void> {
    await this.searchBox.fill(query);
    await this.searchBox.press("Enter");
  }

  async getCartItemCount(): Promise<number> {
    const text = await this.cartCount.textContent();
    return parseInt(text ?? "0", 10);
  }

  async goToCart(): Promise<void> {
    await this.cartIcon.click();
  }

  async openUserMenu(): Promise<void> {
    await this.userMenu.click();
  }

  async logout(): Promise<void> {
    await this.openUserMenu();
    await this.logoutButton.click();
  }

  async expectLoggedIn(username?: string): Promise<void> {
    if (username) {
      await expect(this.userMenu).toContainText(username);
    }
    await expect(this.userMenu).toBeVisible();
  }
}
```

### Modal Component

```typescript
// pages/components/ModalComponent.ts
import { Page, Locator, expect } from "@playwright/test";

export class ModalComponent {
  readonly page: Page;
  readonly container: Locator;
  readonly title: Locator;
  readonly closeButton: Locator;
  readonly confirmButton: Locator;
  readonly cancelButton: Locator;

  constructor(page: Page, name?: string) {
    this.page = page;
    this.container = name
      ? page.getByRole("dialog", { name })
      : page.getByRole("dialog");
    this.title = this.container.getByRole("heading");
    this.closeButton = this.container.getByRole("button", { name: "Close" });
    this.confirmButton = this.container.getByRole("button", {
      name: /confirm|save|submit/i,
    });
    this.cancelButton = this.container.getByRole("button", { name: /cancel/i });
  }

  async waitForOpen(): Promise<void> {
    await expect(this.container).toBeVisible();
  }

  async waitForClose(): Promise<void> {
    await expect(this.container).toBeHidden();
  }

  async close(): Promise<void> {
    await this.closeButton.click();
    await this.waitForClose();
  }

  async confirm(): Promise<void> {
    await this.confirmButton.click();
  }

  async cancel(): Promise<void> {
    await this.cancelButton.click();
    await this.waitForClose();
  }

  async expectTitle(title: string): Promise<void> {
    await expect(this.title).toHaveText(title);
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

## Best Practices

### DO

```typescript
// ✅ Use role-based locators
this.submitButton = page.getByRole('button', { name: 'Submit' });

// ✅ Define locators in constructor
constructor(page: Page) {
  this.emailInput = page.getByRole('textbox', { name: 'Email' });
}

// ✅ Return this for fluent chaining
async fillEmail(email: string): Promise<this> {
  await this.emailInput.fill(email);
  return this;
}

// ✅ Return next page on navigation
async submit(): Promise<ConfirmationPage> {
  await this.submitButton.click();
  await this.page.waitForURL(/.*confirmation/);
  return new ConfirmationPage(this.page);
}

// ✅ Meaningful validation methods
async expectSubmitEnabled(): Promise<void> {
  await expect(this.submitButton).toBeEnabled();
}

// ✅ Use test.step for complex operations
async completeCheckout(data: CheckoutData): Promise<void> {
  await test.step('Fill shipping', async () => { /* ... */ });
  await test.step('Fill payment', async () => { /* ... */ });
  await test.step('Confirm order', async () => { /* ... */ });
}
```

### DON'T

```typescript
// ❌ Don't use CSS/XPath selectors
this.submitButton = page.locator('.btn-submit');

// ❌ Don't create locators in methods (create once in constructor)
async fillEmail(email: string): Promise<void> {
  await this.page.getByLabel('Email').fill(email);
}

// ❌ Don't mix assertions with actions
async clickSubmit(): Promise<void> {
  await this.submitButton.click();
  await expect(this.page).toHaveURL(/success/);  // Move to test
}

// ❌ Don't expose page directly
get pageInstance() { return this.page; }  // Breaks encapsulation
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

## Complete Example

```typescript
// Full flow using page objects
import { test, expect } from "../fixtures/pages.fixture";

test.describe("E-commerce Purchase", () => {
  test("complete purchase flow", async ({ page }) => {
    // Start from login
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    // Login → Dashboard
    const dashboard = await loginPage.login("user@test.com", "password");
    await dashboard.expectWelcomeMessage("Test User");

    // Search for product
    await dashboard.header.search("laptop");

    // Navigate to product
    const productPage = new ProductPage(page);
    await productPage.goto("/products/laptop-pro");

    // Add to cart (fluent)
    await productPage.selectVariant("16GB RAM").setQuantity(2);
    await productPage.addToCart();

    // Verify cart via header
    expect(await dashboard.header.getCartItemCount()).toBe(2);

    // Checkout
    await dashboard.header.goToCart();
    const cartPage = new CartPage(page);

    const checkoutPage = await cartPage.proceedToCheckout();

    const confirmationPage = await checkoutPage
      .fillShippingAddress({
        name: "John Doe",
        address: "123 Main St",
        city: "Seattle",
        zip: "98101",
      })
      .selectShipping("Express")
      .placeOrder();

    // Verify
    await confirmationPage.expectOrderConfirmed();
  });
});
```
