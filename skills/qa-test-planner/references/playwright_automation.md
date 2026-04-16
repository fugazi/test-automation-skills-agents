# Playwright Automation Guide

Comprehensive guide for browser automation, test generation, and UI validation using Playwright MCP.

---

## Prerequisites

**Required:**

- Node.js installed (v18+)
- Playwright MCP server configured
- Application running locally or accessible URL

**Setup:**

```bash
# Install Playwright
npm init playwright@latest

# Verify installation
npx playwright --version
```

---

## Playwright MCP Tools Reference

### Navigation & Interaction

| Tool                    | Purpose             | Example Use            |
| ----------------------- | ------------------- | ---------------------- |
| `browser_navigate`      | Go to a URL         | Navigate to login page |
| `browser_click`         | Click elements      | Click submit button    |
| `browser_fill_form`     | Fill input fields   | Enter form data        |
| `browser_hover`         | Hover over elements | Show dropdown menu     |
| `browser_press_key`     | Keyboard input      | Press Enter, Escape    |
| `browser_select_option` | Select dropdown     | Choose from list       |

### Validation & Capture

| Tool                       | Purpose                | Example Use           |
| -------------------------- | ---------------------- | --------------------- |
| `browser_snapshot`         | Get accessibility tree | Verify page structure |
| `browser_take_screenshot`  | Capture visual state   | Document bugs         |
| `browser_console_messages` | View browser logs      | Debug JS errors       |
| `browser_network_requests` | Monitor API calls      | Verify integrations   |

### Browser Management

| Tool             | Purpose         | Example Use            |
| ---------------- | --------------- | ---------------------- |
| `browser_resize` | Change viewport | Test responsive design |
| `browser_tabs`   | Manage tabs     | Multi-page workflows   |
| `browser_close`  | Close browser   | Cleanup                |

---

## Validation Workflow

### Step 1: Navigate and Snapshot

**Navigate to the page:**

```
"Navigate to BASE_URL/login"
```

**Capture accessibility snapshot:**

```
"Get the accessibility snapshot of the current page"

Response includes:
- Page structure (headings, landmarks)
- Interactive elements (buttons, links, inputs)
- Form fields with labels
- ARIA attributes and roles
```

### Step 2: Validate UI Elements

**Check element presence:**

```
Look in the snapshot for:
- form with role="form"
- textbox with name="Email"
- textbox with name="Password"
- button with name="Login"
```

**Verify element states:**

```
- Button enabled/disabled
- Input required attributes
- Error message visibility
- Focus indicators
```

### Step 3: Test Interactions

**Fill and submit form:**

```
"Fill the email field with test email placeholder"
"Fill the password field with test password placeholder"
"Click the Login button"
```

**Security Note:** Always use environment variables for credentials in generated code:

```typescript
const { TEST_USER_EMAIL, TEST_USER_PASSWORD } = process.env;
await page.getByRole("textbox", { name: "Email" }).fill(TEST_USER_EMAIL);
await page.getByRole("textbox", { name: "Password" }).fill(TEST_USER_PASSWORD);
```

**Verify results:**

**Verify results:**

```
"Take a screenshot of the result"
"Check console messages for errors"
"Get the new page snapshot"
```

### Step 4: Generate Automated Tests

Based on validation, create .spec.ts files following Playwright best practices.

---

## Test Generation Guidelines

### Locator Strategy (Priority Order)

```typescript
// ✅ BEST: Role-based (accessible, resilient)
page.getByRole("button", { name: "Submit" });
page.getByRole("textbox", { name: "Email" });
page.getByRole("link", { name: "Sign up" });

// ✅ GOOD: User-facing text
page.getByLabel("Email address");
page.getByPlaceholder("Enter your email");
page.getByText("Welcome back");

// ✅ GOOD: Test IDs (stable, explicit)
page.getByTestId("submit-button");

// ⚠️ AVOID: CSS selectors (brittle)
page.locator(".btn-primary");

// ❌ NEVER: XPath (extremely brittle)
page.locator('//div[@class="container"]/button[1]');
```

### Test Structure Template

```typescript
import { test, expect } from "@playwright/test";

test.describe("Feature Name", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("BASE_URL/page");
  });

  test("descriptive test name", async ({ page }) => {
    await test.step("Step 1 description", async () => {
      // Actions
      await page.getByRole("button", { name: "Action" }).click();
    });

    await test.step("Step 2 validation", async () => {
      // Assertions
      await expect(page.getByRole("heading")).toHaveText("Expected");
    });
  });
});
```

### Assertion Best Practices

```typescript
// ✅ Web-first assertions (auto-retrying)
await expect(page.getByRole("button")).toBeVisible();
await expect(page.getByRole("heading")).toHaveText("Welcome");
await expect(page).toHaveURL(/.*dashboard/);
await expect(page.getByRole("list")).toHaveCount(5);

// ✅ Accessibility tree assertions
await expect(page.getByRole("main")).toMatchAriaSnapshot(`
  - main:
    - heading "Dashboard" [level=1]
    - list:
      - listitem: "Item 1"
      - listitem: "Item 2"
`);

// ⚠️ Avoid non-retrying assertions for dynamic content
const text = await page.textContent(".status"); // Gets current value only
```

---

## Common Validation Patterns

### Form Validation

**MCP Validation:**

```
"Navigate to the registration form"
"Get the accessibility snapshot"
"Fill invalid email 'not-an-email'"
"Click submit"
"Take screenshot of error state"
"Verify error message in snapshot"
```

**Generated Test:**

```typescript
test("shows validation error for invalid email", async ({ page }) => {
  await test.step("Submit invalid email", async () => {
    await page.getByRole("textbox", { name: "Email" }).fill("not-an-email");
    await page.getByRole("button", { name: "Submit" }).click();
  });

  await test.step("Verify error message", async () => {
    await expect(page.getByRole("alert")).toContainText("valid email");
  });
});
```

### Navigation Flow

**MCP Validation:**

```
"Navigate to homepage"
"Click the 'Products' link"
"Verify URL contains '/products'"
"Take screenshot of products page"
```

**Generated Test:**

```typescript
test("navigates to products page", async ({ page }) => {
  await page.goto("/");
  await page.getByRole("link", { name: "Products" }).click();
  await expect(page).toHaveURL(/.*products/);
  await expect(page.getByRole("heading", { level: 1 })).toHaveText("Products");
});
```

### Responsive Design

**MCP Validation:**

```
"Set viewport to 375x667 (mobile)"
"Navigate to the page"
"Take screenshot"
"Verify hamburger menu is visible"
"Set viewport to 1920x1080 (desktop)"
"Verify navigation links are visible"
```

**Generated Test:**

```typescript
test.describe("responsive navigation", () => {
  test("shows hamburger on mobile", async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto("/");
    await expect(page.getByRole("button", { name: /menu/i })).toBeVisible();
  });

  test("shows full nav on desktop", async ({ page }) => {
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.goto("/");
    await expect(page.getByRole("navigation")).toBeVisible();
    await expect(page.getByRole("button", { name: /menu/i })).toBeHidden();
  });
});
```

---

## Page Object Model

### Structure

```
tests/
  pages/
    BasePage.ts
    LoginPage.ts
    DashboardPage.ts
  fixtures/
    test-fixtures.ts
  login.spec.ts
  dashboard.spec.ts
```

### Example Page Object

```typescript
// pages/LoginPage.ts
import { Page, Locator, expect } from "@playwright/test";

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly loginButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByRole("textbox", { name: "Email" });
    this.passwordInput = page.getByRole("textbox", { name: "Password" });
    this.loginButton = page.getByRole("button", { name: "Login" });
    this.errorMessage = page.getByRole("alert");
  }

  async goto(): Promise<this> {
    await this.page.goto("/login");
    return this;
  }

  async login(email: string, password: string): Promise<this> {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
    return this;
  }

  async expectError(message: string): Promise<void> {
    await expect(this.errorMessage).toContainText(message);
  }
}
```

### Using Page Objects in Tests

```typescript
import { test, expect } from "@playwright/test";
import { LoginPage } from "./pages/LoginPage";

test.describe("Login", () => {
  test("shows error for invalid credentials", async ({ page }) => {
    const loginPage = new LoginPage(page);

    await loginPage.goto();
    await loginPage.login("invalid@test.com", "wrongpassword");
    await loginPage.expectError("Invalid credentials");
  });
});
```

---

## Bug Documentation with Screenshots

### Capturing Evidence

**Using Playwright MCP:**

```
"Navigate to the page with the bug"
"Reproduce the issue (click button, fill form, etc.)"
"Take a screenshot"
"Get console messages for any errors"
"Get the accessibility snapshot"
```

### Bug Report Template

```markdown
# BUG-XXX: [Clear, specific title]

**Severity:** High
**Type:** Functional

## Environment

- Browser: Chrome 120
- Viewport: 1920x1080
- Build: v2.5.0

## Steps to Reproduce

1. Navigate to /checkout
2. Fill cart with items
3. Click "Proceed to Payment"
4. Observe error

## Expected Behavior

Payment form should display

## Actual Behavior

Page shows blank white screen with console error

## Evidence

- Screenshot: [attached from browser_take_screenshot]
- Console Error: "TypeError: Cannot read property 'amount' of undefined"
- Network: POST /api/payment returned 500

## Accessibility Impact

- Users cannot complete checkout
- Screen readers announce no content
```

---

## Test Execution

### Running Tests

```bash
# Run all tests
npx playwright test

# Run specific file
npx playwright test login.spec.ts

# Run in headed mode (see browser)
npx playwright test --headed

# Run with specific browser
npx playwright test --project=chromium

# Debug mode
npx playwright test --debug

# Generate report
npx playwright show-report
```

### CI/CD Integration

```yaml
# .github/workflows/tests.yml
name: Playwright Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 18
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
```

---

## Checklist for Automated Tests

Per test file:

- [ ] Uses role-based locators
- [ ] Implements web-first assertions
- [ ] Groups steps with test.step()
- [ ] Handles setup in beforeEach
- [ ] Follows Page Object Model (for complex pages)
- [ ] Captures screenshots on failure
- [ ] Tests both happy path and error cases
- [ ] Validates accessibility with aria snapshots

Per test suite:

- [ ] Organized by feature
- [ ] Independent tests (no order dependency)
- [ ] Appropriate test coverage
- [ ] Runs in all target browsers
- [ ] Integrated with CI/CD

---

## Quick Reference

| Task          | MCP Query                        | Generated Code                       |
| ------------- | -------------------------------- | ------------------------------------ |
| Check element | "Get accessibility snapshot"     | `expect(locator).toBeVisible()`      |
| Fill form     | "Fill {field} with {value}"      | `page.getByRole().fill()`            |
| Click button  | "Click the {name} button"        | `page.getByRole('button').click()`   |
| Verify text   | "Get snapshot and look for text" | `expect(locator).toHaveText()`       |
| Screenshot    | "Take a screenshot"              | `page.screenshot({ path: 'x.png' })` |
| Check errors  | "Get console messages"           | `page.on('console', ...)`            |

---

**"Test automation is not about replacing testers, it's about empowering them."**

**"Automate what you repeat. Test what matters."**
