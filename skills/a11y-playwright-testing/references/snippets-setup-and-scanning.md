# A11y Snippets: Setup, Axe-Core Helper, and Scanning Patterns

> Part of the `a11y-playwright-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original snippets.md. See the other related files in this folder.

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
