# Page Object Model: Pages & Components

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `page-object-model.md`. See the other `page-object-model-*.md` files in this folder for related sections.

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
