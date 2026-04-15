# Playwright Automated Test: [Feature/Module Name]

**Test File:** [tests/feature/test.spec.ts]
**Category:** [Functional | UI/Visual | Form Validation | Navigation | API Integration | Accessibility]
**Feature:** [Feature name]
**Created:** [YYYY-MM-DD]
**Author:** [Your Name]

---

## Test Description

[Brief description of what this test suite covers]

---

## Naming Convention

- Include test case ID for traceability: `"TC-XXX [description]"`
- Add suite tags for `--grep` runs: `"@smoke"`, `"@regression"`, `"@critical"`

---

## Test Suite Structure

```typescript
import { test, expect } from '@playwright/test';

test.describe('[Feature/Module Name]', () => {
  // Common setup for all tests in this suite
  test.beforeEach(async ({ page }) => {
    // Navigate to base URL
    await page.goto(process.env.BASE_URL || 'BASE_URL_HERE');

    // Additional setup if needed
    // - Login with test credentials
    // - Set required cookies/localStorage
    // - Navigate to specific page
  });

  // Example test - replace with your actual tests
  test('TC-XXX @smoke @regression [Test Description]', async ({ page }) => {
    await test.step('Verify initial state', async () => {
      // Use role-based locators for accessibility
      await expect(page.getByRole('heading', { name: 'Page Title' })).toBeVisible();
    });

    await test.step('Perform user action', async () => {
      // Prefer stable locators (data-testid) when available
      // await page.getByTestId('submit-button').click();

      // Or use role-based locators
      await page.getByRole('button', { name: 'Submit' }).click();
    });

    await test.step('Verify expected outcome', async () => {
      // Use web-first assertions
      await expect(page).toHaveURL(/.*success/);
      await expect(page.getByRole('alert')).toContainText('Success');
    });
  });

  // Add more tests as needed
  // test('TC-XXX @regression [Test Description]', async ({ page }) => {
  //   // Test implementation
  // });

  // test('TC-XXX @critical [Test Description]', async ({ page }) => {
  //   // Test implementation
  // });
});
```

---

## Security

- Load credentials from environment variables
- Never hardcode secrets or test data
- Use test accounts provisioned for testing

**Example:**
```typescript
const { TEST_USER_EMAIL, TEST_USER_PASSWORD } = process.env;
```

---

## Best Practices

### 1. Locator Strategies

**Prefer:**
- `getByRole()` - Most accessible and stable
- `getByTestId()` - Most stable when available
- `getByLabel()` - Good for form fields

**Avoid:**
- CSS selectors - Brittle to style changes
- XPath - Brittle and hard to maintain

**Examples:**
```typescript
// Good - Role-based
await page.getByRole('button', { name: 'Submit' }).click();

// Good - Test ID
await page.getByTestId('submit-button').click();

// Good - Label
await page.getByLabel('Email').fill('test@example.com');

// Avoid - CSS selector
await page.locator('.btn.submit').click();
```

### 2. Assertions

**Use web-first assertions:**
```typescript
// Good
await expect(page.getByRole('heading')).toBeVisible();
await expect(page.getByRole('alert')).toHaveText('Success');
await expect(page).toHaveURL(/.*dashboard/);

// Avoid - Manual waits
await page.waitForSelector('.alert');
```

### 3. Test Organization

**Group related steps with test.step():**
```typescript
test('example test', async ({ page }) => {
  await test.step('Setup', async () => {
    // Setup code
  });

  await test.step('Execute', async () => {
    // Main test code
  });

  await test.step('Verify', async () => {
    // Verification code
  });
});
```

**Keep tests independent:**
```typescript
test.beforeEach(async ({ page }) => {
  // Setup preconditions explicitly
  await page.goto('/login');
});

// Each test is independent and can run alone
test('test 1', async ({ page }) => { /* ... */ });
test('test 2', async ({ page }) => { /* ... */ });
```

### 4. Error Handling

**Playwright auto-waits for elements:**
```typescript
// No need for explicit waits
await page.getByRole('button', { name: 'Submit' }).click();
await expect(page.getByRole('alert')).toBeVisible();

// Screenshots captured automatically on failure
```

### 5. Test Data

**Load from environment variables:**
```typescript
// .env file (never commit this)
TEST_USER_EMAIL=test@example.com
TEST_USER_PASSWORD=TestPassword123!
BASE_URL=http://localhost:3000

// In test file
const { TEST_USER_EMAIL, TEST_USER_PASSWORD, BASE_URL } = process.env;
```

**Use test data generators:**
```typescript
// Example with Faker.js
import { faker } from '@faker-js/faker';

const testEmail = faker.internet.email();
const testName = faker.person.fullName();
```

---

## Running Tests

### Run All Tests
```bash
npx playwright test
```

### Run by Tag
```bash
npx playwright test --grep "@smoke"
npx playwright test --grep "@regression"
npx playwright test --grep "@critical"
```

### Run Specific File
```bash
npx playwright test tests/feature/test.spec.ts
```

### Run with UI
```bash
npx playwright test --ui
```

### Run in Debug Mode
```bash
npx playwright test --debug
```

### Run on Specific Browsers
```bash
npx playwright test --project=chromium
npx playwright test --project=firefox
npx playwright test --project=webkit
```

---

## Test Cases

| Test ID | Description | Tags | Status |
|----------|-------------|-------|--------|
| TC-XXX | [Description] | @smoke @regression | Not Run |
| TC-XXX | [Description] | @regression @negative | Not Run |
| TC-XXX | [Description] | @regression @boundary | Not Run |

---

## Notes

- [Additional context]
- [Known issues]
- [Dependencies on other features]
- [Automation-specific considerations]

---

## Related Test Cases

- [TC-XXX: Related test case]
- [TC-XXX: Related test case]

---

## Attachments

- [ ] Screenshots
- [ ] Screen recordings
- [ ] Console logs
- [ ] Network traces
- [ ] Playwright trace files

---

## References

- [Playwright Documentation](https://playwright.dev/docs/intro)
- [Best Practices Guide](https://playwright.dev/docs/best-practices)
- [Locator Strategies](https://playwright.dev/docs/locators)
- [Assertions](https://playwright.dev/docs/test-assertions)
