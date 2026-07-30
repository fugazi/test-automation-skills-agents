# ARIA Patterns: Common Mistakes and Quick Reference

> Part of the `a11y-playwright-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original aria-patterns.md. See the other related files in this folder.

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
