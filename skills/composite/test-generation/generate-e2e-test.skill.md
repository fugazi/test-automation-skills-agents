---
name: 'generate-e2e-test'
description: 'Generate complete end-to-end tests with Page Object Model structure, combining locators, assertions, interactions, and waits into comprehensive test scenarios'
version: '1.0.0'
type: 'composite'
category: 'test-generation'

composed-of:
  - 'atomic/locators/find-by-role'
  - 'atomic/locators/find-by-testid'
  - 'atomic/assertions/assert-visible'
  - 'atomic/assertions/assert-text'
  - 'atomic/interactions/click-safe'
  - 'atomic/interactions/fill-form'
  - 'atomic/waits/wait-for-visible'

activation: 'explicit'
aliases: ['e2e-test-generation', 'full-flow-test', 'user-journey-test', 'scenario-test']

requires:
  skills: ['page-object-model', 'test-structure']
  knowledge: ['E2E testing patterns', 'user flows', 'test organization', 'Page Object Model']
  tools: ['@playwright/test', 'selenium', 'webdriverio']

output:
  format: 'code'
  template: 'templates/e2e-test-template.md'

success-criteria:
  - Generated test follows Page Object Model structure
  - Test covers complete user journey from start to finish
  - Includes proper waits and assertions at each step
  - Uses semantic locators (role-first, testid as fallback)
  - Handles dynamic content and loading states
  - Includes setup, execution, and teardown phases
---

## Purpose

Generate comprehensive end-to-end tests that validate complete user journeys through the application. This composite skill combines atomic locator, assertion, interaction, and wait skills to create robust, maintainable tests following the Page Object Model pattern.

## When to Use

- Creating new E2E tests for user workflows
- Generating test suites for feature acceptance criteria
- Building regression tests for critical user paths
- Documenting user behavior through executable tests
- Validating multi-step scenarios spanning multiple pages

## Required Atomic Skills

This composite skill orchestrates the following atomic skills:

- [find-by-role](../../atomic/locators/find-by-role.skill.md) - Primary element location strategy using ARIA roles
- [find-by-testid](../../atomic/locators/find-by-testid.skill.md) - Fallback locator for elements without semantic markup
- [assert-visible](../../atomic/assertions/assert-visible.skill.md) - Verify UI state changes
- [assert-text](../../atomic/assertions/assert-text.skill.md) - Validate content and messages
- [click-safe](../../atomic/interactions/click-safe.skill.md) - Reliable element interactions
- [fill-form](../../atomic/interactions/fill-form.skill.md) - Form data entry
- [wait-for-visible](../../atomic/waits/wait-for-visible.skill.md) - Handle dynamic content

## Workflow

### 1. Analyze User Journey
Break down the user flow into discrete steps:
- Entry point (URL or action)
- Sequential user actions
- Expected state changes
- Exit criteria/verification

### 2. Design Page Objects
Create page object classes for each page/section:
- Locators using role-first strategy
- Action methods for user interactions
- Verification methods for assertions

### 3. Generate Test Structure
Follow the standard E2E test pattern:
```
Setup -> Navigate -> Act -> Assert -> Cleanup
```

### 4. Add Waits and Assertions
Insert waits for dynamic content
Add assertions at each verification point

### 5. Handle Edge Cases
Account for loading states, errors, and alternative paths

## Examples

### Example 1: Login Flow with POM

```typescript
// Page Object: LoginPage
class LoginPage {
  constructor(private page: Page) {}

  // Locators using find-by-role
  readonly emailInput = this.page.getByRole('textbox', { name: /email|username/i });
  readonly passwordInput = this.page.getByRole('textbox', { name: /password/i });
  readonly loginButton = this.page.getByRole('button', { name: /sign in|log in/i });
  readonly errorMessage = this.page.getByTestId('login-error');

  // Action methods using fill-form and click-safe
  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }

  // Verification using assert-visible
  async assertError(message: string) {
    await expect(this.errorMessage).toBeVisible();
    await expect(this.errorMessage).toHaveText(message);
  }
}

// Generated E2E Test
test('user can login with valid credentials', async ({ page }) => {
  const loginPage = new LoginPage(page);

  // Navigate
  await page.goto('/login');

  // Wait for page to load using wait-for-visible
  await loginPage.loginButton.waitFor({ state: 'visible' });

  // Act - using fill-form composite
  await loginPage.login('user@example.com', 'password123');

  // Assert - using assert-visible
  await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
});
```

### Example 2: Multi-Step Checkout Flow

```typescript
// Page Object: CheckoutPage
class CheckoutPage {
  constructor(private page: Page) {}

  readonly cartButton = this.page.getByRole('button', { name: 'Cart' });
  readonly checkoutButton = this.page.getByRole('button', { name: 'Checkout' });
  readonly shippingForm = {
    name: this.page.getByRole('textbox', { name: 'Full Name' }),
    address: this.page.getByRole('textbox', { name: 'Address' }),
    city: this.page.getByRole('textbox', { name: 'City' }),
    country: this.page.getByRole('combobox', { name: 'Country' })
  };
  readonly continueButton = this.page.getByRole('button', { name: 'Continue' });
  readonly paymentForm = {
    cardNumber: this.page.getByTestId('card-number'),
    expiry: this.page.getByTestId('card-expiry'),
    cvv: this.page.getByTestId('card-cvv')
  };
  readonly completeOrderButton = this.page.getByRole('button', { name: 'Complete Order' });
  readonly orderConfirmation = this.page.getByRole('heading', { name: /order confirmed/i });

  async fillShipping(details: ShippingDetails) {
    // Using fill-form skill
    await this.shippingForm.name.fill(details.name);
    await this.shippingForm.address.fill(details.address);
    await this.shippingForm.city.fill(details.city);
    await this.shippingForm.country.selectOption(details.country);
  }

  async fillPayment(details: PaymentDetails) {
    // Using find-by-testid for sensitive fields without labels
    await this.paymentForm.cardNumber.fill(details.cardNumber);
    await this.paymentForm.expiry.fill(details.expiry);
    await this.paymentForm.cvv.fill(details.cvv);
  }

  async completeOrder() {
    // Using click-safe skill
    await this.completeOrderButton.click();
  }
}

// Generated E2E Test
test('complete checkout flow', async ({ page }) => {
  const checkout = new CheckoutPage(page);

  await page.goto('/cart');
  await checkout.checkoutButton.click();

  // Wait for form using wait-for-visible
  await checkout.shippingForm.name.waitFor({ state: 'visible' });

  // Fill shipping using fill-form
  await checkout.fillShipping({
    name: 'John Doe',
    address: '123 Main St',
    city: 'New York',
    country: 'United States'
  });

  await checkout.continueButton.click();

  // Wait for payment form
  await checkout.paymentForm.cardNumber.waitFor({ state: 'visible' });

  // Fill payment
  await checkout.fillPayment({
    cardNumber: '4111111111111111',
    expiry: '12/25',
    cvv: '123'
  });

  await checkout.completeOrder();

  // Assert completion using assert-visible
  await expect(checkout.orderConfirmation).toBeVisible();
});
```

### Example 3: User Registration with Validation

```typescript
// Generated E2E Test with error handling
test('user registration with validation', async ({ page }) => {
  await page.goto('/register');

  // Test invalid email using assert-text
  await page.getByRole('textbox', { name: 'Email' }).fill('invalid-email');
  await page.getByRole('button', { name: 'Create Account' }).click();
  await expect(page.getByTestId('email-error'))
    .toHaveText(/please enter a valid email/i);

  // Test password mismatch
  await page.getByRole('textbox', { name: 'Email' }).fill('user@example.com');
  await page.getByRole('textbox', { name: 'Password' }).fill('password123');
  await page.getByRole('textbox', { name: 'Confirm Password' }).fill('different');
  await page.getByRole('button', { name: 'Create Account' }).click();
  await expect(page.getByTestId('password-error'))
    .toHaveText(/passwords do not match/i);

  // Successful registration
  await page.getByRole('textbox', { name: 'Confirm Password' }).fill('password123');
  await page.getByRole('checkbox', { name: 'I agree to terms' }).check();
  await page.getByRole('button', { name: 'Create Account' }).click();

  // Wait for redirect using wait-for-visible
  await page.getByRole('heading', { name: 'Welcome' }).waitFor({ state: 'visible' });
});
```

## Output Format

Generated tests follow this structure:

```
tests/
├── e2e/
│   ├── auth/
│   │   ├── login.spec.ts
│   │   ├── register.spec.ts
│   │   └── password-reset.spec.ts
│   ├── checkout/
│   │   └── checkout-flow.spec.ts
│   └── ...
├── page-objects/
│   ├── LoginPage.ts
│   ├── CheckoutPage.ts
│   └── BasePage.ts
└── fixtures/
    └── test-data.ts
```

## Best Practices

1. **Page Object First** - Always create/maintain page objects
2. **Role-Based Locators** - Use `getByRole()` as primary strategy
3. **Explicit Waits** - Use `waitFor()` for dynamic content
4. **Single Responsibility** - One test per user journey
5. **Descriptive Names** - Test names should describe the user behavior
6. **Setup/Teardown** - Use `beforeEach`/`afterEach` for common setup

## Test Template

```typescript
import { test, expect } from '@playwright/test';
import { PageName } from '../page-objects/PageName';

test.describe('Feature Name', () => {
  let pageObject: PageName;

  test.beforeEach(async ({ page }) => {
    pageObject = new PageName(page);
    await page.goto('/starting-path');
  });

  test('descriptive test name', async ({ page }) => {
    // Arrange
    const testData = { /* test data */ };

    // Act
    await pageObject.performAction(testData);

    // Assert - using assert-visible
    await expect(pageObject.successElement).toBeVisible();
    await expect(pageObject.successElement).toHaveText('Expected text');
  });

  test('error scenario', async ({ page }) => {
    // Test negative case
    await pageObject.performInvalidAction();

    // Assert error - using assert-visible
    await expect(pageObject.errorElement).toBeVisible();
  });
});
```

## Related Skills

- [diagnose-failure](../test-healing/diagnose-failure.skill.md) - Analyze test failures
- [extract-pom](../test-refactoring/extract-pom.skill.md) - Refactor tests into POM
- [analyze-flakiness](../test-analysis/analyze-flakiness.skill.md) - Identify timing issues
