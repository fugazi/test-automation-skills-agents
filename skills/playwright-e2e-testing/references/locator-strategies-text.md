# Locator Strategies: Label, Text, Placeholder & Test ID

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `locator-strategies.md`. See the other `locator-strategies-*.md` files in this folder for related sections.

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
