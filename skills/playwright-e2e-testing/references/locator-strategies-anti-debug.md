# Locator Strategies: Anti-Patterns, CSS Last-Resort & Debugging

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `locator-strategies.md`. See the other `locator-strategies-*.md` files in this folder for related sections.

## Anti-Patterns to Avoid

### [no] CSS Selectors (Brittle)

```typescript
// Bad - class names change frequently
page.locator(".btn-primary.submit-form");
page.locator("#submit-button");
page.locator('[class*="Button"]');
```

### [no] Complex XPath

```typescript
// Bad - extremely brittle
page.locator(
  '//div[@class="container"]//form//button[contains(text(), "Submit")]',
);
page.locator("//table/tbody/tr[3]/td[2]/a");
```

### [no] Index Without Context

```typescript
// Bad - which button? Why index 3?
page.locator("button").nth(3);
```

### [ok] Correct Alternatives

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
