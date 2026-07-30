# A11y Snippets: Visual Accessibility, Accessible Names, Critical Pages

> Part of the `a11y-playwright-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original snippets.md. See the other related files in this folder.

## Visual Accessibility

### Reduced Motion

```typescript
test("respects prefers-reduced-motion", async ({ page }) => {
  await page.emulateMedia({ reducedMotion: "reduce" });
  await page.goto("/");

  // Check animations are disabled
  const hero = page.getByTestId("hero-animation");
  const animationDuration = await hero.evaluate(
    (el) => getComputedStyle(el).animationDuration,
  );

  expect(animationDuration).toBe("0s");
});
```

### High Contrast Mode

```typescript
test("works in high contrast mode", async ({ page }) => {
  await page.emulateMedia({ forcedColors: "active" });
  await page.goto("/");

  // Verify key elements remain visible
  await expect(page.getByRole("navigation")).toBeVisible();
  await expect(page.getByRole("main")).toBeVisible();

  // Buttons should be identifiable
  const primaryButton = page.getByRole("button", { name: "Get started" });
  await expect(primaryButton).toBeVisible();
});
```

### Focus Visibility

```typescript
test("focus indicator is visible", async ({ page }) => {
  await page.goto("/");

  // Tab to focusable element
  await page.keyboard.press("Tab");
  const focusedElement = page.locator(":focus");

  // Check focus is visible (has outline or other indicator)
  const outline = await focusedElement.evaluate((el) => {
    const styles = getComputedStyle(el);
    return {
      outlineWidth: styles.outlineWidth,
      outlineStyle: styles.outlineStyle,
      boxShadow: styles.boxShadow,
    };
  });

  // Should have visible focus indicator
  const hasVisibleFocus =
    (outline.outlineWidth !== "0px" && outline.outlineStyle !== "none") ||
    outline.boxShadow !== "none";

  expect(hasVisibleFocus).toBe(true);
});
```

---

## Accessible Names

### Buttons Have Names

```typescript
test("all buttons have accessible names", async ({ page }) => {
  await page.goto("/");

  const buttons = page.getByRole("button");
  const count = await buttons.count();

  for (let i = 0; i < count; i++) {
    const button = buttons.nth(i);
    const name = await button.evaluate(
      (el) => el.textContent?.trim() || el.getAttribute("aria-label"),
    );
    expect(name, `Button ${i} lacks accessible name`).toBeTruthy();
  }
});
```

### Images Have Alt Text

```typescript
test("informative images have alt text", async ({ page }) => {
  await page.goto("/");

  const images = page.locator('img:not([role="presentation"]):not([alt=""])');
  const count = await images.count();

  for (let i = 0; i < count; i++) {
    const img = images.nth(i);
    const alt = await img.getAttribute("alt");
    expect(alt, `Image ${i} missing alt text`).toBeTruthy();
  }
});
```

### Links Have Purpose

```typescript
test("links convey purpose", async ({ page }) => {
  await page.goto("/");

  const links = page.getByRole("link");
  const count = await links.count();

  const genericNames = ["click here", "read more", "learn more", "here"];

  for (let i = 0; i < count; i++) {
    const link = links.nth(i);
    const name = await link.textContent();

    // Link should not have generic, non-descriptive text
    const isGeneric = genericNames.some(
      (generic) => name?.toLowerCase().trim() === generic,
    );
    expect(isGeneric, `Link "${name}" is not descriptive`).toBe(false);
  }
});
```

---

## Test Data: Critical Pages Checklist

```typescript
// tests/a11y/critical-pages.spec.ts
import { test } from "@playwright/test";
import { runA11yCheck } from "./a11y-helper";

const criticalPages = [
  { name: "Homepage", path: "/" },
  { name: "Login", path: "/login" },
  { name: "Registration", path: "/register" },
  { name: "Contact", path: "/contact" },
  { name: "Search results", path: "/search?q=test" },
  { name: "Product detail", path: "/products/1" },
  { name: "Shopping cart", path: "/cart" },
  { name: "Checkout", path: "/checkout" },
  { name: "Error 404", path: "/nonexistent-page" },
];

for (const page of criticalPages) {
  test(`${page.name} is accessible`, async ({
    page: playwrightPage,
  }, testInfo) => {
    await playwrightPage.goto(page.path);
    await runA11yCheck(playwrightPage, testInfo);
  });
}
```
