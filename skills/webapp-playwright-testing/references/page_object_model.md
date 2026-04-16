# Page Object Model (POM) Best Practices

Comprehensive guide for implementing the Page Object Model pattern in Playwright tests.

---

## What is Page Object Model?

Page Object Model (POM) is a design pattern that creates an abstraction layer between test code and page implementation. Each page (or component) in your application gets its own class that encapsulates:

- **Locators** for elements on the page
- **Methods** for interactions and actions
- **Assertions** for validating state

### Benefits

| Benefit         | Description                             |
| --------------- | --------------------------------------- |
| Maintainability | Change locator once, not in every test  |
| Readability     | Tests read like user stories            |
| Reusability     | Share page logic across tests           |
| Separation      | Test logic separate from implementation |
| Scalability     | Easy to add new pages/components        |

---

## Directory Structure

```
tests/
├── pages/                    # Page Objects
│   ├── BasePage.ts          # Common functionality
│   ├── LoginPage.ts
│   ├── DashboardPage.ts
│   ├── ProductPage.ts
│   └── components/          # Reusable components
│       ├── HeaderComponent.ts
│       ├── FooterComponent.ts
│       └── ModalComponent.ts
├── fixtures/
│   └── test-fixtures.ts     # Custom fixtures with pages
├── login.spec.ts
├── dashboard.spec.ts
└── products.spec.ts
```

---

## Base Page Pattern

Create a base class with common functionality:

```typescript
// pages/BasePage.ts
import { Page, Locator, expect } from "@playwright/test";

export class BasePage {
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

  async waitForPageLoad(): Promise<void> {
    await this.loadingSpinner.waitFor({ state: "hidden" });
  }

  async getPageTitle(): Promise<string> {
    return await this.page.title();
  }

  async takeScreenshot(name: string): Promise<void> {
    await this.page.screenshot({
      path: `screenshots/${name}-${Date.now()}.png`,
      fullPage: true,
    });
  }

  async expectNoConsoleErrors(): Promise<void> {
    const errors: string[] = [];
    this.page.on("console", (msg) => {
      if (msg.type() === "error") {
        errors.push(msg.text());
      }
    });
    expect(errors).toHaveLength(0);
  }
}
```

---

## Page Object Implementation

### Login Page Example

```typescript
// pages/LoginPage.ts
import { Page, Locator, expect } from "@playwright/test";
import { BasePage } from "./BasePage";
import { DashboardPage } from "./DashboardPage";

export class LoginPage extends BasePage {
  // Locators
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly loginButton: Locator;
  readonly errorMessage: Locator;
  readonly forgotPasswordLink: Locator;
  readonly signUpLink: Locator;

  constructor(page: Page) {
    super(page);
    this.emailInput = page.getByRole("textbox", { name: "Email" });
    this.passwordInput = page.getByRole("textbox", { name: "Password" });
    this.loginButton = page.getByRole("button", { name: "Login" });
    this.errorMessage = page.getByRole("alert");
    this.forgotPasswordLink = page.getByRole("link", {
      name: "Forgot password?",
    });
    this.signUpLink = page.getByRole("link", { name: "Sign up" });
  }

  // Navigation
  async goto(): Promise<this> {
    await this.page.goto("/login");
    return this;
  }

  // Actions - return 'this' for chaining
  async fillEmail(email: string): Promise<this> {
    await this.emailInput.fill(email);
    return this;
  }

  async fillPassword(password: string): Promise<this> {
    await this.passwordInput.fill(password);
    return this;
  }

  async clickLogin(): Promise<void> {
    await this.loginButton.click();
  }

  // Combined action - return next page
  async login(email: string, password: string): Promise<DashboardPage> {
    await this.fillEmail(email);
    await this.fillPassword(password);
    await this.clickLogin();
    await this.page.waitForURL(/.*dashboard/);
    return new DashboardPage(this.page);
  }

  // Validation methods
  async expectError(message: string): Promise<void> {
    await expect(this.errorMessage).toContainText(message);
  }

  async expectLoginButtonEnabled(): Promise<void> {
    await expect(this.loginButton).toBeEnabled();
  }

  async expectLoginButtonDisabled(): Promise<void> {
    await expect(this.loginButton).toBeDisabled();
  }
}
```

### Dashboard Page Example

```typescript
// pages/DashboardPage.ts
import { Page, Locator, expect } from "@playwright/test";
import { BasePage } from "./BasePage";

export class DashboardPage extends BasePage {
  readonly welcomeHeading: Locator;
  readonly userMenu: Locator;
  readonly logoutButton: Locator;
  readonly statsCards: Locator;
  readonly recentActivityList: Locator;

  constructor(page: Page) {
    super(page);
    this.welcomeHeading = page.getByRole("heading", { level: 1 });
    this.userMenu = page.getByRole("button", { name: /user menu/i });
    this.logoutButton = page.getByRole("menuitem", { name: "Logout" });
    this.statsCards = page.getByTestId("stats-card");
    this.recentActivityList = page.getByRole("list", {
      name: "Recent Activity",
    });
  }

  async goto(): Promise<this> {
    await this.page.goto("/dashboard");
    return this;
  }

  async logout(): Promise<void> {
    await this.userMenu.click();
    await this.logoutButton.click();
  }

  async getWelcomeMessage(): Promise<string> {
    return (await this.welcomeHeading.textContent()) ?? "";
  }

  async expectWelcomeMessage(name: string): Promise<void> {
    await expect(this.welcomeHeading).toContainText(`Welcome, ${name}`);
  }

  async getStatsCount(): Promise<number> {
    return await this.statsCards.count();
  }
}
```

---

## Fluent Interface Pattern

Design methods to return `this` or the next page object for method chaining:

```typescript
// Fluent chaining within same page
await loginPage.fillEmail("user@test.com").fillPassword("password123");

// Fluent navigation to next page
const dashboard = await loginPage.login("user@test.com", "password");
await dashboard.expectWelcomeMessage("John");
```

### Implementation Pattern

```typescript
export class CheckoutPage extends BasePage {
  // Actions that stay on same page return 'this'
  async selectShipping(method: string): Promise<this> {
    await this.page.getByRole("radio", { name: method }).check();
    return this;
  }

  async enterPromoCode(code: string): Promise<this> {
    await this.promoInput.fill(code);
    await this.applyPromoButton.click();
    return this;
  }

  // Actions that navigate return next page
  async proceedToPayment(): Promise<PaymentPage> {
    await this.proceedButton.click();
    await this.page.waitForURL(/.*payment/);
    return new PaymentPage(this.page);
  }
}

// Usage
const payment = await checkoutPage
  .selectShipping("Express")
  .enterPromoCode("SAVE10")
  .proceedToPayment();
```

---

## Component Objects

For reusable UI components (header, footer, modals):

```typescript
// pages/components/HeaderComponent.ts
import { Page, Locator } from "@playwright/test";

export class HeaderComponent {
  readonly page: Page;
  readonly logo: Locator;
  readonly searchBox: Locator;
  readonly cartIcon: Locator;
  readonly cartCount: Locator;
  readonly userMenu: Locator;

  constructor(page: Page) {
    this.page = page;
    this.logo = page.getByRole("banner").getByRole("link", { name: "Home" });
    this.searchBox = page.getByRole("searchbox");
    this.cartIcon = page.getByRole("link", { name: /cart/i });
    this.cartCount = page.getByTestId("cart-count");
    this.userMenu = page.getByRole("button", { name: /account/i });
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
}
```

### Using Components in Pages

```typescript
// pages/ProductPage.ts
import { Page, Locator } from "@playwright/test";
import { BasePage } from "./BasePage";
import { HeaderComponent } from "./components/HeaderComponent";

export class ProductPage extends BasePage {
  readonly header: HeaderComponent;
  readonly productTitle: Locator;
  readonly addToCartButton: Locator;
  readonly quantityInput: Locator;

  constructor(page: Page) {
    super(page);
    this.header = new HeaderComponent(page);
    this.productTitle = page.getByRole("heading", { level: 1 });
    this.addToCartButton = page.getByRole("button", { name: "Add to Cart" });
    this.quantityInput = page.getByRole("spinbutton", { name: "Quantity" });
  }

  async addToCart(quantity: number = 1): Promise<this> {
    await this.quantityInput.fill(quantity.toString());
    await this.addToCartButton.click();
    return this;
  }
}
```

---

## Custom Fixtures

Create fixtures to inject page objects into tests:

```typescript
// fixtures/test-fixtures.ts
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

### Using Custom Fixtures

```typescript
// login.spec.ts
import { test, expect } from "./fixtures/test-fixtures";

test.describe("Login", () => {
  test("successful login", async ({ loginPage }) => {
    await loginPage.goto();
    const dashboard = await loginPage.login("user@test.com", "password123");
    await dashboard.expectWelcomeMessage("Test User");
  });

  test("invalid credentials", async ({ loginPage }) => {
    await loginPage.goto();
    await loginPage.fillEmail("wrong@test.com");
    await loginPage.fillPassword("wrongpassword");
    await loginPage.clickLogin();
    await loginPage.expectError("Invalid credentials");
  });
});
```

---

## Authenticated Fixture

Pre-authenticate for tests that require login:

```typescript
// fixtures/test-fixtures.ts
import { test as base } from "@playwright/test";
import { DashboardPage } from "../pages/DashboardPage";
import { LoginPage } from "../pages/LoginPage";

type AuthPages = {
  authenticatedPage: DashboardPage;
};

export const authenticatedTest = base.extend<AuthPages>({
  authenticatedPage: async ({ page }, use) => {
    // Perform login
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    const dashboard = await loginPage.login("test@example.com", "password123");

    // Pass authenticated dashboard to test
    await use(dashboard);
  },
});
```

### Or Use Storage State

```typescript
// fixtures/auth.setup.ts
import { test as setup } from "@playwright/test";

setup("authenticate", async ({ page }) => {
  await page.goto("/login");
  await page.getByRole("textbox", { name: "Email" }).fill("user@test.com");
  await page.getByRole("textbox", { name: "Password" }).fill("password");
  await page.getByRole("button", { name: "Login" }).click();
  await page.waitForURL(/.*dashboard/);

  // Save authentication state
  await page.context().storageState({ path: "auth.json" });
});

// In tests
test.describe("Authenticated tests", () => {
  test.use({ storageState: "auth.json" });

  test("view profile", async ({ dashboardPage }) => {
    await dashboardPage.goto();
    // Already logged in via storage state
  });
});
```

---

## Best Practices

### DO

```typescript
// ✅ Use role-based locators
this.submitButton = page.getByRole('button', { name: 'Submit' });

// ✅ Keep locators in constructor
constructor(page: Page) {
  this.emailInput = page.getByRole('textbox', { name: 'Email' });
}

// ✅ Return this for chaining
async fillEmail(email: string): Promise<this> {
  await this.emailInput.fill(email);
  return this;
}

// ✅ Return next page on navigation
async submit(): Promise<ConfirmationPage> {
  await this.submitButton.click();
  return new ConfirmationPage(this.page);
}

// ✅ Add meaningful validation methods
async expectSubmitDisabled(): Promise<void> {
  await expect(this.submitButton).toBeDisabled();
}

// ✅ Use test.step in complex methods
async completeCheckout(): Promise<void> {
  await test.step('Fill shipping', async () => { /* ... */ });
  await test.step('Fill payment', async () => { /* ... */ });
  await test.step('Confirm order', async () => { /* ... */ });
}
```

### DON'T

```typescript
// ❌ Don't use CSS selectors
this.submitButton = page.locator('.btn-submit');

// ❌ Don't put assertions in action methods
async clickSubmit(): Promise<void> {
  await this.submitButton.click();
  await expect(this.page).toHaveURL(/success/); // Move to test
}

// ❌ Don't create locators in methods
async fillEmail(email: string): Promise<void> {
  await this.page.getByRole('textbox', { name: 'Email' }).fill(email);
}

// ❌ Don't expose page directly for test manipulation
// Instead, provide needed methods in page object
```

---

## Anti-Patterns to Avoid

| Anti-Pattern       | Problem                            | Solution                                            |
| ------------------ | ---------------------------------- | --------------------------------------------------- |
| Fat Page Objects   | Too many methods, hard to maintain | Split into components                               |
| Locators in tests  | Duplicated, hard to update         | Keep all locators in page objects                   |
| Assertions in PO   | Mixes concerns                     | Keep assertions in tests or separate expect methods |
| God Page Object    | One class for entire app           | One class per page/component                        |
| Hardcoded waits    | Flaky tests                        | Use auto-waiting locators                           |
| Direct page access | Bypasses abstraction               | Always use page object methods                      |

---

## Quick Reference

| Pattern                 | When to Use                        |
| ----------------------- | ---------------------------------- |
| `return this`           | Action stays on same page          |
| `return new NextPage()` | Action navigates to new page       |
| Component Object        | Reusable UI part (header, modal)   |
| Custom Fixture          | Inject page objects into tests     |
| Storage State           | Skip login for authenticated tests |
| Base Page               | Share common functionality         |

---

## Complete Example

```typescript
// Test using all patterns
import { test, expect } from "./fixtures/test-fixtures";

test.describe("E-commerce Checkout", () => {
  test("complete purchase flow", async ({ page }) => {
    // Start from product page
    const productPage = new ProductPage(page);
    await productPage.goto("/products/laptop-pro");

    // Add to cart (fluent)
    await productPage.selectVariant("16GB RAM").setQuantity(2).addToCart();

    // Verify cart via header component
    expect(await productPage.header.getCartItemCount()).toBe(2);

    // Navigate to cart
    await productPage.header.goToCart();
    const cartPage = new CartPage(page);

    // Proceed to checkout (returns next page)
    const checkoutPage = await cartPage.proceedToCheckout();

    // Complete checkout (fluent chain)
    const confirmationPage = await checkoutPage
      .fillShippingAddress({
        name: "John Doe",
        address: "123 Main St",
        city: "Seattle",
        zip: "98101",
      })
      .selectShipping("Express")
      .enterPayment({
        card: "4111111111111111",
        expiry: "12/25",
        cvv: "123",
      })
      .placeOrder();

    // Verify confirmation
    await confirmationPage.expectOrderConfirmed();
    await confirmationPage.expectOrderNumber();
  });
});
```
