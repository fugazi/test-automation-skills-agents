# Locator Strategies: Filtering, Chaining & Complex Patterns

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `locator-strategies.md`. See the other `locator-strategies-*.md` files in this folder for related sections.

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
