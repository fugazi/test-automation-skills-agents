# Locator Strategies Guide

Comprehensive guide for choosing and implementing robust locators in Playwright tests.

---

## Locator Priority Hierarchy

Always prefer locators higher in this list for maximum resilience:

| Priority | Locator Type           | Example                                   | Why                                |
| -------- | ---------------------- | ----------------------------------------- | ---------------------------------- |
| 1        | Role + accessible name | `getByRole('button', { name: 'Submit' })` | Accessible, user-facing, resilient |
| 2        | Label                  | `getByLabel('Email')`                     | Tied to accessibility              |
| 3        | Placeholder            | `getByPlaceholder('Enter email')`         | User-visible text                  |
| 4        | Text                   | `getByText('Welcome')`                    | Content-based                      |
| 5        | Alt text               | `getByAltText('Company logo')`            | Images, accessible                 |
| 6        | Title                  | `getByTitle('Close dialog')`              | Tooltips                           |
| 7        | Test ID                | `getByTestId('submit-btn')`               | Stable, explicit                   |
| 8        | CSS                    | `locator('.btn-primary')`                 | Brittle, avoid                     |
| 9        | XPath                  | `locator('//button')`                     | Extremely brittle, never use       |

---

## Role-Based Locators

### Common ARIA Roles

```typescript
// Buttons
page.getByRole("button", { name: "Submit" });
page.getByRole("button", { name: /submit/i }); // case-insensitive

// Links
page.getByRole("link", { name: "Home" });
page.getByRole("link", { name: "Read more" });

// Form controls
page.getByRole("textbox", { name: "Email" });
page.getByRole("textbox", { name: "Password" });
page.getByRole("checkbox", { name: "Remember me" });
page.getByRole("radio", { name: "Credit card" });
page.getByRole("combobox", { name: "Country" });
page.getByRole("spinbutton", { name: "Quantity" });
page.getByRole("slider", { name: "Volume" });

// Dropdowns
page.getByRole("listbox");
page.getByRole("option", { name: "United States" });

// Navigation
page.getByRole("navigation");
page.getByRole("menu");
page.getByRole("menuitem", { name: "Settings" });
page.getByRole("menubar");
page.getByRole("tab", { name: "Details" });
page.getByRole("tabpanel");

// Headings (semantic structure)
page.getByRole("heading", { name: "Welcome" });
page.getByRole("heading", { level: 1 });
page.getByRole("heading", { level: 2, name: "Features" });

// Page structure
page.getByRole("main");
page.getByRole("banner"); // <header>
page.getByRole("contentinfo"); // <footer>
page.getByRole("complementary"); // <aside>
page.getByRole("region", { name: "Sidebar" });

// Tables
page.getByRole("table");
page.getByRole("row");
page.getByRole("cell", { name: "Total" });
page.getByRole("columnheader", { name: "Price" });
page.getByRole("rowheader");

// Dialogs
page.getByRole("dialog");
page.getByRole("alertdialog");
page.getByRole("alert");

// Lists
page.getByRole("list");
page.getByRole("listitem");

// Media
page.getByRole("img", { name: "Product photo" });
page.getByRole("figure");

// Search
page.getByRole("searchbox");
page.getByRole("search");
```

### Role Modifiers

```typescript
// Exact match (default is substring)
page.getByRole("button", { name: "Submit", exact: true });

// State modifiers
page.getByRole("button", { pressed: true }); // Toggle buttons
page.getByRole("button", { expanded: true }); // Accordions, dropdowns
page.getByRole("checkbox", { checked: true }); // Checkboxes
page.getByRole("option", { selected: true }); // Select options
page.getByRole("button", { disabled: true }); // Disabled state
page.getByRole("tab", { selected: true }); // Active tab

// Include hidden elements (default: false)
page.getByRole("button", { includeHidden: true });
```

---

## Label-Based Locators

Best for form fields with proper `<label>` elements:

```typescript
// Standard label association
// HTML: <label for="email">Email Address</label><input id="email">
page.getByLabel("Email Address");

// Wrapped label
// HTML: <label>Email <input type="text"></label>
page.getByLabel("Email");

// aria-label
// HTML: <input aria-label="Search">
page.getByLabel("Search");

// aria-labelledby
// HTML: <span id="label1">Phone</span><input aria-labelledby="label1">
page.getByLabel("Phone");

// Options
page.getByLabel("Email", { exact: true });
page.getByLabel(/email/i); // Regex, case-insensitive
```

---

## Text-Based Locators

For static content and visible text:

```typescript
// Contains text (substring match)
page.getByText("Welcome back");

// Exact match
page.getByText("Welcome back!", { exact: true });

// Regex
page.getByText(/total:\s*\$[\d.]+/i);
page.getByText(/^Welcome/); // Starts with
page.getByText(/back!$/); // Ends with
```

---

## Placeholder & Alt Locators

```typescript
// Placeholder text
page.getByPlaceholder("Enter your email");
page.getByPlaceholder("Search...", { exact: true });

// Alt text for images
page.getByAltText("Company logo");
page.getByAltText(/product image/i);

// Title attribute (tooltips)
page.getByTitle("Close dialog");
page.getByTitle(/remove/i);
```

---

## Test ID Locators

For elements without semantic meaning or when other locators aren't stable:

```typescript
// HTML: <div data-testid="user-avatar">...</div>
page.getByTestId("user-avatar");

// Custom attribute (configure in playwright.config.ts)
// playwright.config.ts:
// use: { testIdAttribute: 'data-qa' }
// HTML: <button data-qa="submit-btn">...</button>
page.getByTestId("submit-btn");
```

**When to use Test IDs:**

- Dynamic content without stable text
- Generic elements (divs, spans)
- Third-party components where roles aren't exposed
- Last resort when semantic locators aren't available

---

## Filtering and Chaining

### Filter by Text

```typescript
// Button containing specific text
page.getByRole("button").filter({ hasText: "Delete" });

// Row containing specific content
page.getByRole("row").filter({ hasText: "john@example.com" });

// Not containing text
page.getByRole("listitem").filter({ hasNotText: "Draft" });
```

### Filter by Child Element

```typescript
// List item containing a specific link
page.getByRole("listitem").filter({
  has: page.getByRole("link", { name: "Edit" }),
});

// Form containing specific input
page.getByRole("form").filter({
  has: page.getByLabel("Email"),
});

// Without specific child
page.getByRole("listitem").filter({
  hasNot: page.getByRole("button", { name: "Delete" }),
});
```

### Chaining Locators

```typescript
// Find within a container
page.getByRole("dialog").getByRole("button", { name: "Cancel" });

// Form within main content
page.getByRole("main").getByRole("form");

// Multiple levels
page
  .getByRole("table")
  .getByRole("row")
  .filter({ hasText: "Product A" })
  .getByRole("button", { name: "Edit" });

// Navigation within header
page.getByRole("banner").getByRole("navigation");
```

### Index-Based Selection

```typescript
// Nth element (0-indexed)
page.getByRole("button").nth(1); // Second button

// First and last
page.getByRole("listitem").first();
page.getByRole("listitem").last();

// All matching elements
const items = page.getByRole("listitem");
const count = await items.count();
for (let i = 0; i < count; i++) {
  await items.nth(i).click();
}
```

---

## Complex Patterns

### Data Table Row Actions

```typescript
// Find row and interact
const userRow = page.getByRole("row").filter({ hasText: "john@example.com" });
await userRow.getByRole("button", { name: "Edit" }).click();

// Or with chained locators
await page
  .getByRole("row", { name: /john@example.com/ })
  .getByRole("button", { name: "Delete" })
  .click();
```

### Modal Dialog Interactions

```typescript
// Wait for and interact with dialog
const dialog = page.getByRole("dialog");
await expect(dialog).toBeVisible();

await dialog.getByLabel("Name").fill("New Name");
await dialog.getByRole("button", { name: "Save" }).click();

await expect(dialog).toBeHidden();
```

### Dynamic Lists

```typescript
// Find item in dynamically loaded list
await expect(async () => {
  await page.getByRole("listitem").filter({ hasText: "New Item" }).click();
}).toPass({ timeout: 5000 });
```

### Repeated Components

```typescript
// Multiple cards with same structure
const productCards = page.getByTestId("product-card");
const firstCard = productCards.first();

await firstCard.getByRole("button", { name: "Add to Cart" }).click();
await firstCard.getByText("Added!").waitFor();
```

---

## Anti-Patterns to Avoid

### ❌ CSS Selectors (Brittle)

```typescript
// Bad - class names change frequently
page.locator(".btn-primary.submit-form");
page.locator("#submit-button");
page.locator('[class*="Button"]');
```

### ❌ Complex XPath

```typescript
// Bad - extremely brittle
page.locator(
  '//div[@class="container"]//form//button[contains(text(), "Submit")]',
);
page.locator("//table/tbody/tr[3]/td[2]/a");
```

### ❌ Index Without Context

```typescript
// Bad - which button? Why index 3?
page.locator("button").nth(3);
```

### ✅ Correct Alternatives

```typescript
// Good - use role-based
page.getByRole("button", { name: "Submit" });

// Good - filter then index
page
  .getByRole("row")
  .filter({ hasText: "Product A" })
  .getByRole("button")
  .first();

// Good - chain from container
page.getByRole("dialog").getByRole("button", { name: "Submit" });
```

---

## CSS Locator (Last Resort)

When semantic locators aren't available:

```typescript
// By class (less brittle with data attributes)
page.locator('[data-state="active"]');
page.locator('[aria-expanded="true"]');

// By attribute
page.locator('input[type="file"]');
page.locator('a[href*="download"]');

// Child/descendant
page.locator("nav >> a"); // descendant
page.locator("ul > li"); // direct child

// Combining with text
page.locator('button:has-text("Submit")');
page.locator('div:text-is("Exact match")');

// Pseudo-selectors
page.locator("input:visible");
page.locator("button:enabled");
```

---

## Debugging Locators

### Playwright Inspector

```bash
# Launch with Inspector
PWDEBUG=1 npx playwright test

# Or in UI mode
npx playwright test --ui
```

### Codegen

```bash
# Record interactions and see locators
npx playwright codegen http://localhost:3000
```

### Browser DevTools

```javascript
// In browser console
document.querySelector('[data-testid="submit"]');
document.querySelectorAll('[role="button"]');

// Test accessibility tree
$0; // Select element, then inspect in Accessibility panel
```

### In-Test Debugging

```typescript
// Highlight element before interacting
await page.getByRole("button", { name: "Submit" }).highlight();

// Log matched elements count
const count = await page.getByRole("listitem").count();
console.log(`Found ${count} list items`);

// Pause for inspection
await page.pause();
```

---

## Quick Reference

| Need           | Locator                                        |
| -------------- | ---------------------------------------------- |
| Button by text | `getByRole('button', { name: 'Click' })`       |
| Input by label | `getByLabel('Email')`                          |
| Link by text   | `getByRole('link', { name: 'Home' })`          |
| Heading        | `getByRole('heading', { name: 'Title' })`      |
| Checkbox       | `getByRole('checkbox', { name: 'Agree' })`     |
| First in list  | `getByRole('listitem').first()`                |
| In container   | `getByRole('dialog').getByRole('button')`      |
| Table row      | `getByRole('row').filter({ hasText: 'John' })` |
| By test ID     | `getByTestId('custom-element')`                |
| Placeholder    | `getByPlaceholder('Search...')`                |
| Image alt      | `getByAltText('Logo')`                         |
