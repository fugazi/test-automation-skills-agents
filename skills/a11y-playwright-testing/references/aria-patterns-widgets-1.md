# ARIA Patterns: Widgets Part 1 (Fundamentals, Dialog, Tabs, Menu)

> Part of the `a11y-playwright-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original aria-patterns.md. See the other related files in this folder.

Common ARIA widget patterns and how to test them for accessibility compliance using Playwright.

---

## ARIA Fundamentals

### When to Use ARIA

> **First Rule of ARIA**: Don't use ARIA if you can use native HTML.

| Scenario      | Recommendation                                 |
| ------------- | ---------------------------------------------- |
| Button        | Use `<button>`, not `<div role="button">`      |
| Link          | Use `<a href="...">`, not `<span role="link">` |
| Checkbox      | Use `<input type="checkbox">`, not custom ARIA |
| Custom widget | ARIA required (tabs, combobox, tree)           |

### ARIA Roles Categories

| Category        | Examples                                      | Description           |
| --------------- | --------------------------------------------- | --------------------- |
| **Landmark**    | `banner`, `navigation`, `main`, `contentinfo` | Page structure        |
| **Widget**      | `button`, `checkbox`, `tab`, `menu`           | Interactive elements  |
| **Composite**   | `tablist`, `menu`, `listbox`, `tree`          | Container widgets     |
| **Live Region** | `alert`, `status`, `log`                      | Dynamic announcements |

---

## Dialog (Modal)

### Required ARIA

```html
<div role="dialog" aria-modal="true" aria-labelledby="dialog-title">
  <h2 id="dialog-title">Confirm Action</h2>
  <!-- content -->
</div>
```

### Test Pattern

```typescript
import { test, expect } from "@playwright/test";

test("dialog has correct ARIA", async ({ page }) => {
  await page.goto("/settings");
  await page.getByRole("button", { name: "Delete" }).click();

  const dialog = page.getByRole("dialog");

  // Dialog visible with correct role
  await expect(dialog).toBeVisible();
  await expect(dialog).toHaveAttribute("aria-modal", "true");

  // Has accessible name
  const labelledBy = await dialog.getAttribute("aria-labelledby");
  expect(labelledBy).toBeTruthy();

  // Title exists
  const title = page.locator(`#${labelledBy}`);
  await expect(title).toBeVisible();

  // Focus management
  await expect(dialog.locator(":focus")).toBeVisible();

  // Escape closes
  await page.keyboard.press("Escape");
  await expect(dialog).toBeHidden();
});
```

### Focus Trap Test

```typescript
test("dialog traps focus", async ({ page }) => {
  await page.goto("/settings");
  await page.getByRole("button", { name: "Delete" }).click();

  const dialog = page.getByRole("dialog");
  const focusableElements = dialog.locator(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])',
  );
  const count = await focusableElements.count();

  // Tab through all focusable elements
  for (let i = 0; i < count + 1; i++) {
    await page.keyboard.press("Tab");
  }

  // Focus should wrap back to first element
  const firstFocusable = focusableElements.first();
  await expect(firstFocusable).toBeFocused();
});
```

---

## Tabs

### Required ARIA

```html
<div role="tablist" aria-label="Settings sections">
  <button role="tab" aria-selected="true" aria-controls="panel-1" id="tab-1">
    General
  </button>
  <button role="tab" aria-selected="false" aria-controls="panel-2" id="tab-2">
    Security
  </button>
</div>
<div role="tabpanel" id="panel-1" aria-labelledby="tab-1">
  <!-- General content -->
</div>
<div role="tabpanel" id="panel-2" aria-labelledby="tab-2" hidden>
  <!-- Security content -->
</div>
```

### Test Pattern

```typescript
test("tabs have correct ARIA structure", async ({ page }) => {
  await page.goto("/settings");

  // Tablist exists
  const tablist = page.getByRole("tablist");
  await expect(tablist).toBeVisible();

  // Tabs exist within tablist
  const tabs = page.getByRole("tab");
  const tabCount = await tabs.count();
  expect(tabCount).toBeGreaterThan(1);

  // First tab is selected
  const firstTab = tabs.first();
  await expect(firstTab).toHaveAttribute("aria-selected", "true");

  // Tab controls a panel
  const controlsId = await firstTab.getAttribute("aria-controls");
  expect(controlsId).toBeTruthy();

  // Panel exists and is visible
  const panel = page.getByRole("tabpanel");
  await expect(panel).toBeVisible();
  await expect(panel).toHaveAttribute("aria-labelledby");
});

test("tabs keyboard navigation", async ({ page }) => {
  await page.goto("/settings");

  const tabs = page.getByRole("tab");

  // Focus first tab
  await tabs.first().focus();
  await expect(tabs.first()).toBeFocused();

  // Arrow right moves to next tab
  await page.keyboard.press("ArrowRight");
  await expect(tabs.nth(1)).toBeFocused();
  await expect(tabs.nth(1)).toHaveAttribute("aria-selected", "true");

  // Arrow left moves back
  await page.keyboard.press("ArrowLeft");
  await expect(tabs.first()).toBeFocused();

  // Home moves to first
  await page.keyboard.press("End");
  await expect(tabs.last()).toBeFocused();

  await page.keyboard.press("Home");
  await expect(tabs.first()).toBeFocused();
});
```

---

## Menu (Dropdown)

### Required ARIA

```html
<button aria-haspopup="menu" aria-expanded="false" aria-controls="menu-1">
  Options
</button>
<ul role="menu" id="menu-1" hidden>
  <li role="menuitem">Edit</li>
  <li role="menuitem">Delete</li>
  <li role="separator"></li>
  <li role="menuitem">Settings</li>
</ul>
```

### Test Pattern

```typescript
test("menu has correct ARIA", async ({ page }) => {
  await page.goto("/dashboard");

  const trigger = page.getByRole("button", { name: "Options" });

  // Trigger has required attributes
  await expect(trigger).toHaveAttribute("aria-haspopup", "menu");
  await expect(trigger).toHaveAttribute("aria-expanded", "false");

  // Open menu
  await trigger.click();
  await expect(trigger).toHaveAttribute("aria-expanded", "true");

  // Menu visible with correct role
  const menu = page.getByRole("menu");
  await expect(menu).toBeVisible();

  // Menu items exist
  const items = page.getByRole("menuitem");
  expect(await items.count()).toBeGreaterThan(0);
});

test("menu keyboard navigation", async ({ page }) => {
  await page.goto("/dashboard");

  const trigger = page.getByRole("button", { name: "Options" });
  await trigger.focus();

  // Enter opens menu
  await page.keyboard.press("Enter");
  const menu = page.getByRole("menu");
  await expect(menu).toBeVisible();

  // First item focused
  const items = page.getByRole("menuitem");
  await expect(items.first()).toBeFocused();

  // Arrow down moves through items
  await page.keyboard.press("ArrowDown");
  await expect(items.nth(1)).toBeFocused();

  // Arrow up moves back
  await page.keyboard.press("ArrowUp");
  await expect(items.first()).toBeFocused();

  // Escape closes menu
  await page.keyboard.press("Escape");
  await expect(menu).toBeHidden();
  await expect(trigger).toBeFocused();
});
```

---
