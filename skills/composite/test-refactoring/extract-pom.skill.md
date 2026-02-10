---
name: 'extract-pom'
description: 'Extract Page Object Model classes from existing test code, separating page logic from test logic using role-based and test ID locators'
version: '1.0.0'
type: 'composite'
category: 'test-refactoring'

composed-of:
  - 'atomic/locators/find-by-role'
  - 'atomic/locators/find-by-testid'

activation: 'explicit'
aliases: ['create-page-object', 'pom-extraction', 'refactor-to-pom', 'page-object-model']

requires:
  skills: ['generate-e2e-test']
  knowledge: ['Page Object Model pattern', 'class design', 'encapsulation', 'test organization']
  tools: ['@playwright/test', 'selenium', 'typescript', 'java']

output:
  format: 'code'
  template: 'templates/page-object-template.md'

success-criteria:
  - Page objects are created for each distinct page/component
  - All selectors moved from tests to page objects
  - Action methods encapsulate user interactions
  - Tests use semantic, readable method names
  - Locators use role-first strategy
  - Test code is simplified and more maintainable
---

## Purpose

Refactor existing tests to use the Page Object Model pattern, separating test logic from page interaction logic. This creates more maintainable, reusable, and readable test suites by encapsulating page-specific behavior in dedicated classes.

## When to Use

- Converting legacy tests to POM architecture
- Extracting reusable components from duplicated test code
- Improving test maintainability
- Reducing test code duplication
- Creating a structured test framework

## Required Atomic Skills

This composite skill primarily uses:

- [find-by-role](../../atomic/locators/find-by-role.skill.md) - Create semantic, resilient locators
- [find-by-testid](../../atomic/locators/find-by-testid.skill.md) - Fallback locators when roles aren't available

## Workflow

### 1. Analyze Existing Tests
Identify:
- Pages/components being tested
- Common selectors used across tests
- Repeated interaction patterns
- Assertions that can be encapsulated

### 2. Design Page Object Structure
Create classes for:
- Each unique page
- Reusable components (headers, modals, forms)
- Base page class with common utilities

### 3. Extract Locators
Move selectors from tests to page objects:
- Prefer role-based locators
- Group related selectors
- Use descriptive names

### 4. Create Action Methods
Encapsulate interactions:
- User-facing method names
- Return page objects for flow
- Include assertions where appropriate

### 5. Refactor Tests
Replace direct interactions with page object methods

## Examples

### Example 1: Basic Login Test Refactoring

```typescript
// BEFORE - Test with inline selectors
test('user can login', async ({ page }) => {
  await page.goto('/login');

  // Direct selectors scattered in test
  await page.locator('#email').fill('user@example.com');
  await page.locator('#password').fill('password123');
  await page.locator('button[type="submit"]').click();

  // Direct assertion
  await expect(page.locator('.welcome-message')).toBeVisible();
});

// AFTER - Extracted to POM

// Page Object: LoginPage
class LoginPage {
  constructor(private page: Page) {}

  // Locators extracted using find-by-role
  readonly emailInput = this.page.getByRole('textbox', { name: /email|username/i });
  readonly passwordInput = this.page.getByRole('textbox', { name: /password/i });
  readonly loginButton = this.page.getByRole('button', { name: /sign in|log in|login/i });
  readonly errorMessage = this.page.getByRole('alert');

  // Action method using fill-form pattern
  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }

  // Method returning next page for flow
  async loginAs(email: string, password: string): Promise<DashboardPage> {
    await this.login(email, password);
    return new DashboardPage(this.page);
  }
}

// Page Object: DashboardPage
class DashboardPage {
  constructor(private page: Page) {}

  readonly welcomeMessage = this.page.getByRole('heading', { name: /welcome/i });
  readonly logoutButton = this.page.getByRole('button', { name: /logout|sign out/i });

  async assertWelcome() {
    await expect(this.welcomeMessage).toBeVisible();
  }
}

// Refactored Test - Clean and readable
test('user can login', async ({ page }) => {
  const loginPage = new LoginPage(page);

  await loginPage.goto();
  const dashboard = await loginPage.loginAs('user@example.com', 'password123');
  await dashboard.assertWelcome();
});
```

### Example 2: Form Page with Multiple Actions

```typescript
// BEFORE - Repeated form code across tests
test('register new user', async ({ page }) => {
  await page.goto('/register');
  await page.locator('#name').fill('John Doe');
  await page.locator('#email').fill('john@example.com');
  await page.locator('#password').fill('pass123');
  await page.locator('#confirm-password').fill('pass123');
  await page.locator('#terms').check();
  await page.locator('button[type="submit"]').click();
});

test('register with invalid email shows error', async ({ page }) => {
  await page.goto('/register');
  await page.locator('#name').fill('John Doe');
  await page.locator('#email').fill('invalid-email');
  await page.locator('#password').fill('pass123');
  await page.locator('#confirm-password').fill('pass123');
  await page.locator('#terms').check();
  await page.locator('button[type="submit"]').click();
  await expect(page.locator('.email-error')).toBeVisible();
});

// AFTER - Extracted POM

class RegistrationPage {
  constructor(private page: Page) {}

  // Locators grouped logically
  readonly nameInput = this.page.getByRole('textbox', { name: 'Full Name' });
  readonly emailInput = this.page.getByRole('textbox', { name: 'Email' });
  readonly passwordInput = this.page.getByRole('textbox', { name: 'Password' });
  readonly confirmPasswordInput = this.page.getByRole('textbox', { name: 'Confirm Password' });
  readonly termsCheckbox = this.page.getByRole('checkbox', { name: /agree|terms/i });
  readonly submitButton = this.page.getByRole('button', { name: /create account|register|sign up/i });
  readonly emailError = this.page.getByTestId('email-error');

  async goto() {
    await this.page.goto('/register');
  }

  // Fill form using fill-form pattern
  async fillForm(details: { name: string; email: string; password: string }) {
    await this.nameInput.fill(details.name);
    await this.emailInput.fill(details.email);
    await this.passwordInput.fill(details.password);
    await this.confirmPasswordInput.fill(details.password);
  }

  async acceptTerms() {
    await this.termsCheckbox.check();
  }

  async submit() {
    await this.submitButton.click();
  }

  // High-level action combining multiple steps
  async register(details: { name: string; email: string; password: string }) {
    await this.fillForm(details);
    await this.acceptTerms();
    await this.submit();
  }

  async assertEmailError() {
    await expect(this.emailError).toBeVisible();
  }
}

// Refactored tests
test('register new user', async ({ page }) => {
  const registerPage = new RegistrationPage(page);
  await registerPage.goto();
  await registerPage.register({
    name: 'John Doe',
    email: 'john@example.com',
    password: 'pass123'
  });
});

test('register with invalid email shows error', async ({ page }) => {
  const registerPage = new RegistrationPage(page);
  await registerPage.goto();
  await registerPage.fillForm({
    name: 'John Doe',
    email: 'invalid-email',
    password: 'pass123'
  });
  await registerPage.acceptTerms();
  await registerPage.submit();
  await registerPage.assertEmailError();
});
```

### Example 3: Component POM (Reusable Header)

```typescript
// BEFORE - Header code duplicated in every test
test('navigate to profile', async ({ page }) => {
  await page.goto('/');
  await page.locator('.header .user-menu').click();
  await page.locator('.header .profile-link').click();
  await expect(page).toHaveURL('/profile');
});

test('navigate to settings', async ({ page }) => {
  await page.goto('/');
  await page.locator('.header .user-menu').click();
  await page.locator('.header .settings-link').click();
  await expect(page).toHaveURL('/settings');
});

// AFTER - Extracted component POM

class HeaderComponent {
  constructor(private page: Page) {}

  private get userMenuButton() {
    return this.page.getByRole('button', { name: /user menu|account/i });
  }

  private get profileLink() {
    return this.page.getByRole('menuitem', { name: 'Profile' });
  }

  private get settingsLink() {
    return this.page.getByRole('menuitem', { name: 'Settings' });
  }

  private get logoutLink() {
    return this.page.getByRole('menuitem', { name: /logout|sign out/i });
  }

  async openUserMenu() {
    await this.userMenuButton.click();
  }

  async goToProfile() {
    await this.openUserMenu();
    await this.profileLink.click();
    await this.page.waitForURL(/\/profile/);
  }

  async goToSettings() {
    await this.openUserMenu();
    await this.settingsLink.click();
    await this.page.waitForURL(/\/settings/);
  }

  async logout() {
    await this.openUserMenu();
    await this.logoutLink.click();
  }
}

// Base page class that includes common components
class BasePage {
  constructor(public page: Page) {
    this.header = new HeaderComponent(page);
  }

  readonly header: HeaderComponent;

  async goto(url: string) {
    await this.page.goto(url);
  }
}

// Usage in tests
test('navigate to profile', async ({ page }) => {
  const homePage = new BasePage(page);
  await homePage.goto('/');
  await homePage.header.goToProfile();
  await expect(page).toHaveURL('/profile');
});
```

### Example 4: Handling Dynamic Content with testid

```typescript
// BEFORE - Complex selectors for data table
test('sort table by name', async ({ page }) => {
  await page.goto('/users');
  await page.locator('.users-table th[data-sort="name"]').click();
  const firstRow = page.locator('.users-table tbody tr:first-child td:first-child');
  await expect(firstRow).toHaveText('Alice');
});

// AFTER - POM with component for table

class UsersTableComponent {
  constructor(private page: Page) {
    this.table = this.page.getByTestId('users-table');
  }

  private readonly table;

  private get headers() {
    return this.table.getByRole('columnheader');
  }

  private get rows() {
    return this.table.getByRole('row');
  }

  async sortBy(columnName: string) {
    await this.headers.filter({ hasText: columnName }).click();
  }

  async getCellText(rowIndex: number, columnName: string): Promise<string> {
    const row = this.rows.nth(rowIndex);
    return row.getByRole('cell', { name: columnName }).textContent();
  }

  async assertRowCount(count: number) {
    await expect(this.rows).toHaveCount(count + 1); // +1 for header
  }
}

class UsersPage extends BasePage {
  constructor(page: Page) {
    super(page);
    this.usersTable = new UsersTableComponent(page);
  }

  readonly usersTable: UsersTableComponent;

  async goto() {
    await this.page.goto('/users');
  }
}

// Refactored test
test('sort table by name', async ({ page }) => {
  const usersPage = new UsersPage(page);
  await usersPage.goto();
  await usersPage.usersTable.sortBy('Name');
  const firstName = await usersPage.usersTable.getCellText(0, 'Name');
  expect(firstName).toBe('Alice');
});
```

## Page Object Structure Template

```typescript
// Base page with common utilities
export abstract class BasePage {
  constructor(public readonly page: Page) {}

  async goto(path: string) {
    await this.page.goto(path);
  }

  async waitForURL(pattern: RegExp | string) {
    await this.page.waitForURL(pattern);
  }

  async reload() {
    await this.page.reload();
  }
}

// Specific page example
export class ExamplePage extends BasePage {
  constructor(page: Page) {
    super(page);
  }

  // ===== LOCATORS =====
  // Group related locators together
  private readonly form = {
    name: this.page.getByRole('textbox', { name: 'Name' }),
    email: this.page.getByRole('textbox', { name: 'Email' }),
    submit: this.page.getByRole('button', { name: 'Submit' })
  };

  private readonly navigation = {
    home: this.page.getByRole('link', { name: 'Home' }),
    about: this.page.getByRole('link', { name: 'About' })
  };

  // ===== ACTIONS =====
  // User-facing actions return void or next page
  async goto() {
    await super.goto('/example');
  }

  async fillForm(data: { name: string; email: string }) {
    await this.form.name.fill(data.name);
    await this.form.email.fill(data.email);
  }

  async submitForm(): Promise<SuccessPage> {
    await this.form.submit.click();
    await this.page.waitForURL(/\/success/);
    return new SuccessPage(this.page);
  }

  // ===== ASSERTIONS =====
  async assertOnPage() {
    await expect(this.page.getByRole('heading', { name: 'Example' }))
      .toBeVisible();
  }
}
```

## Extraction Checklist

- [ ] Identify all pages/components in the test
- [ ] Create base page class if not exists
- [ ] Extract locators using role-first strategy
- [ ] Group related locators logically
- [ ] Create action methods for user interactions
- [ ] Return page objects for navigation flow
- [ ] Add assertion methods for page-specific verifications
- [ ] Update tests to use page objects
- [ ] Remove duplicate code
- [ ] Verify all tests still pass

## Best Practices

1. **One Class Per Page** - Each page gets its own class
2. **Semantic Method Names** - Methods should read like user actions
3. **Return Page Objects** - Enable fluent test chaining
4. **Private Locators** - Hide implementation details
5. **Composition Over Inheritance** - Use component POMs for shared elements
6. **Role-Based Locators** - Prefer getByRole() over CSS selectors

## Related Skills

- [generate-e2e-test](../test-generation/generate-e2e-test.skill.md) - Create new tests with POM
- [suggest-fixes](../test-healing/suggest-fixes.skill.md) - Fix issues during refactoring
- [find-by-role](../../atomic/locators/find-by-role.skill.md) - Best locator for POM
