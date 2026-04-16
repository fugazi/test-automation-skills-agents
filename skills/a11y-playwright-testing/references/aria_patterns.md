# ARIA Patterns and Testing

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

## Accordion

### Required ARIA

```html
<div class="accordion">
  <h3>
    <button aria-expanded="false" aria-controls="section1">Section 1</button>
  </h3>
  <div id="section1" role="region" aria-labelledby="section1-trigger" hidden>
    <!-- Content -->
  </div>
</div>
```

### Test Pattern

```typescript
test("accordion has correct ARIA", async ({ page }) => {
  await page.goto("/faq");

  const trigger = page.getByRole("button", { name: "Section 1" });

  // Initially collapsed
  await expect(trigger).toHaveAttribute("aria-expanded", "false");

  // Controls a region
  const controlsId = await trigger.getAttribute("aria-controls");
  expect(controlsId).toBeTruthy();

  // Expand section
  await trigger.click();
  await expect(trigger).toHaveAttribute("aria-expanded", "true");

  // Region visible
  const region = page.locator(`#${controlsId}`);
  await expect(region).toBeVisible();
});

test("accordion keyboard interaction", async ({ page }) => {
  await page.goto("/faq");

  const triggers = page.locator(".accordion button");

  // Focus first trigger
  await triggers.first().focus();

  // Space toggles
  await page.keyboard.press("Space");
  await expect(triggers.first()).toHaveAttribute("aria-expanded", "true");

  await page.keyboard.press("Space");
  await expect(triggers.first()).toHaveAttribute("aria-expanded", "false");

  // Enter also toggles
  await page.keyboard.press("Enter");
  await expect(triggers.first()).toHaveAttribute("aria-expanded", "true");
});
```

---

## Combobox (Autocomplete)

### Required ARIA

```html
<label for="city-input">City</label>
<input
  type="text"
  id="city-input"
  role="combobox"
  aria-autocomplete="list"
  aria-expanded="false"
  aria-controls="city-listbox"
  aria-activedescendant=""
/>
<ul role="listbox" id="city-listbox" hidden>
  <li role="option" id="opt-1">New York</li>
  <li role="option" id="opt-2">Los Angeles</li>
</ul>
```

### Test Pattern

```typescript
test("combobox has correct ARIA", async ({ page }) => {
  await page.goto("/search");

  const combobox = page.getByRole("combobox", { name: "City" });

  // Initial state
  await expect(combobox).toHaveAttribute("aria-expanded", "false");
  await expect(combobox).toHaveAttribute("aria-autocomplete", "list");

  // Type to show options
  await combobox.fill("New");
  await expect(combobox).toHaveAttribute("aria-expanded", "true");

  // Listbox visible
  const listbox = page.getByRole("listbox");
  await expect(listbox).toBeVisible();

  // Options exist
  const options = page.getByRole("option");
  expect(await options.count()).toBeGreaterThan(0);
});

test("combobox keyboard navigation", async ({ page }) => {
  await page.goto("/search");

  const combobox = page.getByRole("combobox", { name: "City" });
  await combobox.fill("New");

  // Arrow down selects first option
  await page.keyboard.press("ArrowDown");

  // Active descendant updated
  const activeId = await combobox.getAttribute("aria-activedescendant");
  expect(activeId).toBeTruthy();

  // Continue navigating
  await page.keyboard.press("ArrowDown");
  const newActiveId = await combobox.getAttribute("aria-activedescendant");
  expect(newActiveId).not.toBe(activeId);

  // Enter selects option
  await page.keyboard.press("Enter");
  await expect(combobox).toHaveValue(/./); // Has a value
  await expect(page.getByRole("listbox")).toBeHidden();
});
```

---

## Live Regions

### Types

| Role     | Use Case                  | Politeness             |
| -------- | ------------------------- | ---------------------- |
| `alert`  | Errors, warnings          | Assertive (interrupts) |
| `status` | Success messages, updates | Polite (waits)         |
| `log`    | Chat, activity feed       | Polite                 |
| `timer`  | Countdown, elapsed time   | Off (manual)           |

### Required ARIA

```html
<!-- Alert (interrupts screen reader) -->
<div role="alert">Error: Invalid email address</div>

<!-- Status (announced at next pause) -->
<div role="status">Settings saved successfully</div>

<!-- Custom live region -->
<div aria-live="polite" aria-atomic="true">3 items in cart</div>
```

### Test Pattern

```typescript
test("alert announced on error", async ({ page }) => {
  await page.goto("/login");

  // Submit invalid form
  await page.getByRole("button", { name: "Sign in" }).click();

  // Alert appears with correct role
  const alert = page.getByRole("alert");
  await expect(alert).toBeVisible();
  await expect(alert).toContainText(/error|invalid/i);
});

test("status message for success", async ({ page }) => {
  await page.goto("/settings");

  await page.getByLabel("Name").fill("Updated Name");
  await page.getByRole("button", { name: "Save" }).click();

  // Status message appears
  const status = page.getByRole("status");
  await expect(status).toBeVisible();
  await expect(status).toContainText(/saved|success/i);
});

test("live region updates cart count", async ({ page }) => {
  await page.goto("/products");

  // Find live region for cart
  const cartCount = page
    .locator('[aria-live="polite"]')
    .filter({ hasText: /cart/i });

  // Initial state
  await expect(cartCount).toContainText("0");

  // Add item
  await page.getByRole("button", { name: "Add to cart" }).first().click();

  // Live region updated
  await expect(cartCount).toContainText("1");
});
```

---

## Tooltip

### Required ARIA

```html
<button aria-describedby="tooltip-1">Save</button>
<div role="tooltip" id="tooltip-1" hidden>Save current document (Ctrl+S)</div>
```

### Test Pattern

```typescript
test("tooltip has correct ARIA", async ({ page }) => {
  await page.goto("/editor");

  const button = page.getByRole("button", { name: "Save" });

  // Button references tooltip
  const describedBy = await button.getAttribute("aria-describedby");
  expect(describedBy).toBeTruthy();

  // Tooltip hidden initially
  const tooltip = page.getByRole("tooltip");
  await expect(tooltip).toBeHidden();

  // Hover shows tooltip
  await button.hover();
  await expect(tooltip).toBeVisible();

  // Tooltip has expected content
  await expect(tooltip).toContainText(/Ctrl\+S/);

  // Focus also shows tooltip
  await button.blur();
  await expect(tooltip).toBeHidden();

  await button.focus();
  await expect(tooltip).toBeVisible();
});
```

---

## Common ARIA Mistakes

### Test for Invalid ARIA

```typescript
test("no invalid ARIA usage", async ({ page }) => {
  await page.goto("/");

  // No role="button" on non-interactive elements (sign of missing keyboard support)
  const divButtons = page.locator('div[role="button"], span[role="button"]');
  const divButtonCount = await divButtons.count();

  for (let i = 0; i < divButtonCount; i++) {
    const el = divButtons.nth(i);

    // Must have tabindex
    const tabindex = await el.getAttribute("tabindex");
    expect(tabindex, 'Div with role="button" must be focusable').toBeTruthy();
  }

  // No empty aria-label
  const emptyLabels = page.locator('[aria-label=""]');
  expect(await emptyLabels.count()).toBe(0);

  // No broken aria-labelledby references
  const labelledBy = page.locator("[aria-labelledby]");
  const count = await labelledBy.count();

  for (let i = 0; i < count; i++) {
    const el = labelledBy.nth(i);
    const id = await el.getAttribute("aria-labelledby");
    const target = page.locator(`#${id}`);
    expect(
      await target.count(),
      `aria-labelledby references missing element #${id}`,
    ).toBe(1);
  }
});
```

### Test Roles Are Complete

```typescript
test("interactive roles have required attributes", async ({ page }) => {
  await page.goto("/");

  // Checkboxes need aria-checked
  const checkboxes = page.locator('[role="checkbox"]');
  const checkboxCount = await checkboxes.count();

  for (let i = 0; i < checkboxCount; i++) {
    const checkbox = checkboxes.nth(i);
    const checked = await checkbox.getAttribute("aria-checked");
    expect(["true", "false", "mixed"]).toContain(checked);
  }

  // Tabs need aria-selected
  const tabs = page.locator('[role="tab"]');
  const tabCount = await tabs.count();

  for (let i = 0; i < tabCount; i++) {
    const tab = tabs.nth(i);
    const selected = await tab.getAttribute("aria-selected");
    expect(["true", "false"]).toContain(selected);
  }
});
```

---

## Quick Reference: Roles and Required States

| Role       | Required States/Properties       | Keyboard              |
| ---------- | -------------------------------- | --------------------- |
| `button`   | -                                | Enter, Space          |
| `checkbox` | `aria-checked`                   | Space                 |
| `dialog`   | `aria-modal`, `aria-labelledby`  | Escape (close)        |
| `menu`     | -                                | Arrow keys, Escape    |
| `menuitem` | -                                | Enter, Space          |
| `tab`      | `aria-selected`, `aria-controls` | Arrows, Home, End     |
| `tabpanel` | `aria-labelledby`                | -                     |
| `combobox` | `aria-expanded`, `aria-controls` | Arrows, Enter, Escape |
| `listbox`  | -                                | Arrows                |
| `option`   | `aria-selected`                  | -                     |
| `alert`    | -                                | -                     |
| `status`   | -                                | -                     |
