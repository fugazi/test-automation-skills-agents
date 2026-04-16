# Accessibility Testing Snippets (Playwright + axe-core)

Ready-to-use patterns for accessibility testing. Adapt to your project's conventions.

---

## Setup

### Install Dependencies

```bash
npm install -D @axe-core/playwright axe-core
```

### Project Structure

```
tests/
├── a11y/
│   ├── a11y-helper.ts      # Reusable axe helper
│   ├── pages.spec.ts       # Page-level scans
│   ├── components.spec.ts  # Component scans
│   └── keyboard.spec.ts    # Keyboard/focus tests
```

---

## Axe-Core Helper

### Reusable A11y Check with Report Attachment

```typescript
// tests/a11y/a11y-helper.ts
import AxeBuilder from "@axe-core/playwright";
import { expect, type Page, type TestInfo } from "@playwright/test";

const WCAG21AA_TAGS = ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"] as const;

export interface A11yOptions {
  tags?: string[];
  include?: string | string[];
  exclude?: string | string[];
  disableRules?: string[];
}

export async function runA11yCheck(
  page: Page,
  testInfo: TestInfo,
  options?: A11yOptions,
): Promise<void> {
  const tags = options?.tags ?? [...WCAG21AA_TAGS];
  const include = toArray(options?.include);
  const exclude = toArray(options?.exclude);
  const disableRules = options?.disableRules ?? [];

  let builder = new AxeBuilder({ page }).withTags(tags);

  for (const selector of include) {
    builder = builder.include(selector);
  }
  for (const selector of exclude) {
    builder = builder.exclude(selector);
  }
  if (disableRules.length) {
    builder = builder.disableRules(disableRules);
  }

  const results = await builder.analyze();

  // Attach results to test report
  await testInfo.attach("axe-results.json", {
    body: JSON.stringify(results, null, 2),
    contentType: "application/json",
  });

  // Format violations for clear error message
  const message = formatViolations(results.violations);
  expect(results.violations, message).toEqual([]);
}

function toArray(value?: string | string[]): string[] {
  if (!value) return [];
  return Array.isArray(value) ? value : [value];
}

function formatViolations(
  violations: Array<{
    id: string;
    impact?: string;
    helpUrl?: string;
    description?: string;
    nodes: Array<{ target?: string[]; failureSummary?: string }>;
  }>,
): string {
  if (!violations.length) return "";

  return violations
    .map((v) => {
      const targets = v.nodes
        .map((n) => `  - ${(n.target ?? []).join(" > ")}`)
        .join("\n");
      return `\n[${v.impact?.toUpperCase()}] ${v.id}\n${v.description}\n${v.helpUrl}\nAffected elements:\n${targets}`;
    })
    .join("\n");
}
```

### Usage in Tests

```typescript
// tests/a11y/pages.spec.ts
import { test } from "@playwright/test";
import { runA11yCheck } from "./a11y-helper";

test.describe("Page Accessibility", () => {
  test("homepage has no violations", async ({ page }, testInfo) => {
    await page.goto("/");
    await runA11yCheck(page, testInfo);
  });

  test("login page has no violations", async ({ page }, testInfo) => {
    await page.goto("/login");
    await runA11yCheck(page, testInfo);
  });

  test("dashboard (authenticated) has no violations", async ({
    page,
  }, testInfo) => {
    // Assuming authenticated state
    await page.goto("/dashboard");
    await runA11yCheck(page, testInfo);
  });
});
```

---

## Scanning Patterns

### Full Page Scan

```typescript
import AxeBuilder from "@axe-core/playwright";
import { test, expect } from "@playwright/test";

test("page is accessible", async ({ page }) => {
  await page.goto("/");

  const results = await new AxeBuilder({ page })
    .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
    .analyze();

  expect(results.violations).toEqual([]);
});
```

### Component-Scoped Scan

```typescript
test("form component is accessible", async ({ page }) => {
  await page.goto("/contact");

  const results = await new AxeBuilder({ page })
    .include("#contact-form")
    .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
    .analyze();

  expect(results.violations).toEqual([]);
});
```

### Exclude Third-Party Widgets

```typescript
test("page accessible (excluding third-party)", async ({ page }) => {
  await page.goto("/");

  const results = await new AxeBuilder({ page })
    .exclude("#chat-widget") // Third-party chat
    .exclude("[data-ad-slot]") // Ad containers
    .exclude(".social-embed") // Social media embeds
    .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
    .analyze();

  expect(results.violations).toEqual([]);
});
```

### Dynamic Content Scan

```typescript
test("error state is accessible", async ({ page }, testInfo) => {
  await page.goto("/checkout");

  // Trigger error state
  await page.getByRole("button", { name: "Pay now" }).click();

  // Wait for error to render
  await page.getByRole("alert").waitFor();

  // Scan after state change
  await runA11yCheck(page, testInfo);
});
```

### Multiple States Scan

```typescript
test("form states are accessible", async ({ page }, testInfo) => {
  await page.goto("/contact");

  // Initial state
  await runA11yCheck(page, testInfo, { include: "#contact-form" });

  // Submit with errors
  await page.getByRole("button", { name: "Send" }).click();
  await page.getByText("Please fill required fields").waitFor();
  await runA11yCheck(page, testInfo, { include: "#contact-form" });

  // Fill and submit success
  await page.getByLabel("Name").fill("Test User");
  await page.getByLabel("Email").fill("test@example.com");
  await page.getByRole("button", { name: "Send" }).click();
  await page.getByText("Message sent").waitFor();
  await runA11yCheck(page, testInfo);
});
```

---

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
