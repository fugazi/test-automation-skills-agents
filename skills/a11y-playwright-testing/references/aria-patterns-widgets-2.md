# ARIA Patterns: Widgets Part 2 (Accordion, Combobox, Live Regions, Tooltip)

> Part of the `a11y-playwright-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original aria-patterns.md. See the other related files in this folder.

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
