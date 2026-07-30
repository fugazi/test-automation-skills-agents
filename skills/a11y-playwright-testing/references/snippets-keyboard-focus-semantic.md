# A11y Snippets: Keyboard Navigation, Focus Management, Semantic Structure

> Part of the `a11y-playwright-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original snippets.md. See the other related files in this folder.

## Keyboard Navigation

### Tab Order Verification

```typescript
import { test, expect } from "@playwright/test";

test("tab order is logical", async ({ page }) => {
  await page.goto("/");

  const expectedOrder = [
    page.getByRole("link", { name: /skip to content/i }),
    page.getByRole("link", { name: "Home" }),
    page.getByRole("link", { name: "Products" }),
    page.getByRole("link", { name: "About" }),
    page.getByRole("link", { name: "Contact" }),
  ];

  for (const element of expectedOrder) {
    await page.keyboard.press("Tab");
    await expect(element).toBeFocused();
  }
});
```

### Form Keyboard Navigation

```typescript
test("form can be completed with keyboard only", async ({ page }) => {
  await page.goto("/login");

  // Tab to email field
  await page.keyboard.press("Tab");
  await expect(page.getByLabel("Email")).toBeFocused();
  await page.keyboard.type("user@example.com");

  // Tab to password
  await page.keyboard.press("Tab");
  await expect(page.getByLabel("Password")).toBeFocused();
  await page.keyboard.type("password123");

  // Tab to remember me checkbox
  await page.keyboard.press("Tab");
  const checkbox = page.getByRole("checkbox", { name: /remember/i });
  await expect(checkbox).toBeFocused();
  await page.keyboard.press("Space"); // Toggle checkbox
  await expect(checkbox).toBeChecked();

  // Tab to submit
  await page.keyboard.press("Tab");
  await expect(page.getByRole("button", { name: "Sign in" })).toBeFocused();

  // Submit with Enter
  await page.keyboard.press("Enter");
  await expect(page).toHaveURL(/dashboard/);
});
```

### Skip Link

```typescript
test("skip link bypasses navigation", async ({ page }) => {
  await page.goto("/");

  // First Tab focuses skip link
  await page.keyboard.press("Tab");
  const skipLink = page.getByRole("link", { name: /skip to (main|content)/i });
  await expect(skipLink).toBeFocused();
  await expect(skipLink).toBeVisible();

  // Activate skip link
  await page.keyboard.press("Enter");

  // Focus should move to main content
  const main = page.locator('#main, main, [role="main"]').first();
  await expect(main).toBeFocused();
});
```

---

## Focus Management

### Dialog Focus Trap

```typescript
test("modal dialog traps focus", async ({ page }) => {
  await page.goto("/settings");
  const trigger = page.getByRole("button", { name: "Delete account" });

  // Open modal
  await trigger.click();
  const dialog = page.getByRole("dialog");
  await expect(dialog).toBeVisible();

  // Focus should be on first focusable element inside dialog
  const firstFocusable = dialog.getByRole("button", { name: "Cancel" });
  await expect(firstFocusable).toBeFocused();

  // Tab through dialog elements
  await page.keyboard.press("Tab");
  await expect(
    dialog.getByRole("button", { name: "Confirm delete" }),
  ).toBeFocused();

  // Tab should wrap back to first element (focus trap)
  await page.keyboard.press("Tab");
  await expect(firstFocusable).toBeFocused();

  // Shift+Tab should wrap to last element
  await page.keyboard.press("Shift+Tab");
  await expect(
    dialog.getByRole("button", { name: "Confirm delete" }),
  ).toBeFocused();

  // Escape closes dialog
  await page.keyboard.press("Escape");
  await expect(dialog).toBeHidden();

  // Focus returns to trigger
  await expect(trigger).toBeFocused();
});
```

### Menu Focus Management

```typescript
test("dropdown menu has proper focus", async ({ page }) => {
  await page.goto("/");
  const menuButton = page.getByRole("button", { name: "Account menu" });

  // Open menu
  await menuButton.click();
  const menu = page.getByRole("menu");
  await expect(menu).toBeVisible();

  // First menu item should be focused or menu itself
  const firstItem = menu.getByRole("menuitem").first();
  await expect(firstItem).toBeFocused();

  // Arrow down moves to next item
  await page.keyboard.press("ArrowDown");
  await expect(menu.getByRole("menuitem").nth(1)).toBeFocused();

  // Arrow up moves to previous item
  await page.keyboard.press("ArrowUp");
  await expect(firstItem).toBeFocused();

  // Escape closes menu and returns focus
  await page.keyboard.press("Escape");
  await expect(menu).toBeHidden();
  await expect(menuButton).toBeFocused();
});
```

### Toast/Alert Focus

```typescript
test("toast notification announced without stealing focus", async ({
  page,
}) => {
  await page.goto("/settings");

  // Store current focus
  const saveButton = page.getByRole("button", { name: "Save changes" });
  await saveButton.focus();

  // Trigger action that shows toast
  await saveButton.click();

  // Toast appears
  const toast = page.getByRole("status");
  await expect(toast).toBeVisible();
  await expect(toast).toContainText("Settings saved");

  // Focus should NOT move to toast (status messages don't steal focus)
  // Focus stays on or near the action that triggered it
  await expect(saveButton).toBeFocused();
});
```

---

## Semantic Structure

### Landmarks Validation

```typescript
test("page has required landmarks", async ({ page }) => {
  await page.goto("/");

  // Main landmark
  const main = page.getByRole("main");
  await expect(main).toBeVisible();

  // Navigation landmark
  const nav = page.getByRole("navigation");
  await expect(nav).toBeVisible();

  // Banner (header)
  const banner = page.getByRole("banner");
  await expect(banner).toBeVisible();

  // Content info (footer)
  const footer = page.getByRole("contentinfo");
  await expect(footer).toBeVisible();
});
```

### Heading Hierarchy

```typescript
test("heading hierarchy is logical", async ({ page }) => {
  await page.goto("/");

  // Get all headings
  const headings = await page.locator("h1, h2, h3, h4, h5, h6").all();

  let previousLevel = 0;
  for (const heading of headings) {
    const tagName = await heading.evaluate((el) => el.tagName);
    const level = parseInt(tagName.charAt(1));

    // Heading level should not skip (e.g., h1 -> h3)
    expect(level - previousLevel).toBeLessThanOrEqual(1);
    previousLevel = level;
  }

  // Page should have exactly one h1
  const h1Count = await page.locator("h1").count();
  expect(h1Count).toBe(1);
});
```

### Form Labels

```typescript
test("all form inputs have labels", async ({ page }) => {
  await page.goto("/contact");

  const inputs = page.locator(
    'input:not([type="hidden"]):not([type="submit"]), textarea, select',
  );
  const count = await inputs.count();

  for (let i = 0; i < count; i++) {
    const input = inputs.nth(i);

    // Each input should be locatable by role and have an accessible name
    const accessibleName = await input.evaluate((el: HTMLElement) => {
      return (
        el.getAttribute("aria-label") ||
        el.getAttribute("aria-labelledby") ||
        (el as HTMLInputElement).labels?.[0]?.textContent ||
        el.getAttribute("placeholder")
      ); // Placeholder alone is insufficient
    });

    expect(accessibleName, `Input ${i} lacks accessible name`).toBeTruthy();
  }
});
```

---
