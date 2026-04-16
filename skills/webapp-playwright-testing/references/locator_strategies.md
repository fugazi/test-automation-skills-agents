# Locator Strategies Guide

Comprehensive guide for choosing and implementing the right locator strategy in Playwright tests.

---

## Locator Priority Hierarchy

Always prefer locators higher in this list:

| Priority | Locator Type | Example                                   | Why                                |
| -------- | ------------ | ----------------------------------------- | ---------------------------------- |
| 1        | Role-based   | `getByRole('button', { name: 'Submit' })` | Accessible, resilient, user-facing |
| 2        | Label        | `getByLabel('Email')`                     | Tied to accessibility              |
| 3        | Placeholder  | `getByPlaceholder('Enter email')`         | User-visible text                  |
| 4        | Text         | `getByText('Welcome')`                    | Content-based                      |
| 5        | Test ID      | `getByTestId('submit-btn')`               | Stable, explicit                   |
| 6        | CSS          | `locator('.btn-primary')`                 | Brittle, avoid                     |
| 7        | XPath        | `locator('//button')`                     | Extremely brittle, never use       |

---

## Role-Based Locators

### Common Roles

```typescript
// Buttons
page.getByRole("button", { name: "Submit" });
page.getByRole("button", { name: /submit/i }); // regex, case-insensitive

// Links
page.getByRole("link", { name: "Sign up" });

// Text inputs
page.getByRole("textbox", { name: "Email" });
page.getByRole("textbox", { name: "Password" });

// Checkboxes and radios
page.getByRole("checkbox", { name: "Remember me" });
page.getByRole("radio", { name: "Credit card" });

// Dropdowns
page.getByRole("combobox", { name: "Country" });
page.getByRole("listbox");
page.getByRole("option", { name: "United States" });

// Navigation
page.getByRole("navigation");
page.getByRole("menu");
page.getByRole("menuitem", { name: "Settings" });

// Headings
page.getByRole("heading", { name: "Welcome" });
page.getByRole("heading", { level: 1 });

// Structure
page.getByRole("main");
page.getByRole("banner"); // header
page.getByRole("contentinfo"); // footer
page.getByRole("complementary"); // aside

// Tables
page.getByRole("table");
page.getByRole("row");
page.getByRole("cell", { name: "Total" });

// Dialogs
page.getByRole("dialog");
page.getByRole("alertdialog");

// Lists
page.getByRole("list");
page.getByRole("listitem");
```

### Role Modifiers

```typescript
// Exact match (default is substring)
page.getByRole("button", { name: "Submit", exact: true });

// Pressed state (toggle buttons)
page.getByRole("button", { pressed: true });

// Expanded state (accordions, menus)
page.getByRole("button", { expanded: true });

// Selected state
page.getByRole("option", { selected: true });

// Checked state
page.getByRole("checkbox", { checked: true });

// Disabled state
page.getByRole("button", { disabled: true });
```

---

## Label-Based Locators

Best for form fields with proper labeling:

```typescript
// Input with <label for="email">Email</label>
page.getByLabel("Email");

// Textarea with aria-label
page.getByLabel("Comments");

// Case-insensitive
page.getByLabel(/email/i);

// Exact match
page.getByLabel("Email", { exact: true });
```

---

## Text-Based Locators

For static content:

```typescript
// Contains text
page.getByText("Welcome");

// Exact match
page.getByText("Welcome back!", { exact: true });

// Regex
page.getByText(/total:\s*\$[\d.]+/i);
```

---

## Test ID Locators

For elements without accessible names:

```typescript
// HTML: <div data-testid="user-avatar">...</div>
page.getByTestId("user-avatar");

// Custom attribute (configure in playwright.config.ts)
// testIdAttribute: 'data-qa'
page.getByTestId("submit-button");
```

---

## Filtering and Chaining

### Filter by Text

```typescript
// Button containing specific text
page.getByRole("button").filter({ hasText: "Delete" });

// Row containing specific cell
page.getByRole("row").filter({ hasText: "John Doe" });
```

### Filter by Child Element

```typescript
// List item containing specific link
page.getByRole("listitem").filter({
  has: page.getByRole("link", { name: "Edit" }),
});
```

### Chaining Locators

```typescript
// Find within a specific container
page.getByRole("dialog").getByRole("button", { name: "Cancel" });

// Form within main content
page.getByRole("main").getByRole("form");
```

### Nth Element

```typescript
// Second button (0-indexed)
page.getByRole("button").nth(1);

// First item
page.getByRole("listitem").first();

// Last item
page.getByRole("listitem").last();
```

---

## Common Patterns

### Login Form

```typescript
const loginForm = page.getByRole("form", { name: /login/i });
await loginForm.getByRole("textbox", { name: "Email" }).fill("user@test.com");
await loginForm.getByRole("textbox", { name: "Password" }).fill("password");
await loginForm.getByRole("button", { name: "Login" }).click();
```

### Data Table Row

```typescript
// Find row and interact with it
const userRow = page.getByRole("row").filter({ hasText: "john@example.com" });
await userRow.getByRole("button", { name: "Edit" }).click();
```

### Modal Dialog

```typescript
// Wait for dialog and interact
const dialog = page.getByRole("dialog");
await expect(dialog).toBeVisible();
await dialog.getByRole("button", { name: "Confirm" }).click();
```

### Navigation Menu

```typescript
// Mobile: Open menu first
await page.getByRole("button", { name: /menu/i }).click();
await page
  .getByRole("navigation")
  .getByRole("link", { name: "Products" })
  .click();
```

---

## Avoiding Common Mistakes

### ❌ Wrong: CSS Selectors

```typescript
// Brittle - class names change frequently
page.locator(".btn-primary.submit-form");
page.locator("#submit-button");
```

### ✅ Right: Role-Based

```typescript
page.getByRole("button", { name: "Submit" });
```

---

### ❌ Wrong: Complex XPath

```typescript
page.locator(
  '//div[@class="container"]//form//button[contains(text(), "Submit")]',
);
```

### ✅ Right: Chained Roles

```typescript
page.getByRole("form").getByRole("button", { name: "Submit" });
```

---

### ❌ Wrong: Index Without Context

```typescript
page.locator("button").nth(3); // Which button? Why 3?
```

### ✅ Right: Filter Then Index

```typescript
page
  .getByRole("row")
  .filter({ hasText: "ProductA" })
  .getByRole("button")
  .first();
```

---

## Debugging Locators

### Use Playwright Inspector

```bash
npx playwright test --debug
```

### Use Browser DevTools

In DevTools Console:

```javascript
// Test a selector
document.querySelector('[data-testid="submit"]');

// List all buttons
document.querySelectorAll('[role="button"]');
```

### Use Accessibility Snapshot

With Playwright MCP:

```
"Get the accessibility snapshot"
```

This shows the accessibility tree with roles and names, making it easy to find the right locator.

---

## Quick Reference

| Need             | Locator                                    |
| ---------------- | ------------------------------------------ |
| Button by text   | `getByRole('button', { name: 'Click' })`   |
| Input by label   | `getByLabel('Email')`                      |
| Link by text     | `getByRole('link', { name: 'Home' })`      |
| Heading          | `getByRole('heading', { name: 'Title' })`  |
| Checkbox         | `getByRole('checkbox', { name: 'Agree' })` |
| First in list    | `getByRole('listitem').first()`            |
| Within container | `getByRole('dialog').getByRole('button')`  |
| By test ID       | `getByTestId('custom-element')`            |
