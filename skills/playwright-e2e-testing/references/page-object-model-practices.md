# Page Object Model: Best Practices & Examples

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `page-object-model.md`. See the other `page-object-model-*.md` files in this folder for related sections.

## Best Practices

### DO

```typescript
// [ok] Use role-based locators
this.submitButton = page.getByRole('button', { name: 'Submit' });

// [ok] Define locators in constructor
constructor(page: Page) {
  this.emailInput = page.getByRole('textbox', { name: 'Email' });
}

// [ok] Return this for fluent chaining
async fillEmail(email: string): Promise<this> {
  await this.emailInput.fill(email);
  return this;
}

// [ok] Return next page on navigation
async submit(): Promise<ConfirmationPage> {
  await this.submitButton.click();
  await this.page.waitForURL(/.*confirmation/);
  return new ConfirmationPage(this.page);
}

// [ok] Meaningful validation methods
async expectSubmitEnabled(): Promise<void> {
  await expect(this.submitButton).toBeEnabled();
}

// [ok] Use test.step for complex operations
async completeCheckout(data: CheckoutData): Promise<void> {
  await test.step('Fill shipping', async () => { /* ... */ });
  await test.step('Fill payment', async () => { /* ... */ });
  await test.step('Confirm order', async () => { /* ... */ });
}
```

### DON'T

```typescript
// [no] Don't use CSS/XPath selectors
this.submitButton = page.locator('.btn-submit');

// [no] Don't create locators in methods (create once in constructor)
async fillEmail(email: string): Promise<void> {
  await this.page.getByLabel('Email').fill(email);
}

// [no] Don't mix assertions with actions
async clickSubmit(): Promise<void> {
  await this.submitButton.click();
  await expect(this.page).toHaveURL(/success/);  // Move to test
}

// [no] Don't expose page directly
get pageInstance() { return this.page; }  // Breaks encapsulation
```

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
