---
name: a11y-playwright-testing
description: 'Accessibility testing for web applications using Playwright (@playwright/test), TypeScript, and axe-core. Use to write, run, or debug WCAG 2.2 AA checks, keyboard and focus tests, ARIA/semantic validation, accessible names, form labels, color contrast, or screen-reader test patterns. Keywords: accessibility, WCAG, axe-core, keyboard navigation, focus management, ARIA.'
license: 'Complete terms in LICENSE.txt'
---

# Playwright Accessibility Testing (TypeScript)

Comprehensive toolkit for automated accessibility testing using Playwright with TypeScript and axe-core. Enables WCAG 2.2 Level AA compliance verification (superset of 2.1), keyboard operability testing, semantic validation, and accessibility regression prevention.

> **Activation:** This skill is triggered when working with accessibility testing, WCAG compliance, axe-core scans, keyboard navigation tests, focus management, ARIA validation, or screen reader compatibility.

## When to Use This Skill

- **Automated a11y scans** with axe-core for WCAG 2.2 AA compliance
- **Keyboard navigation tests** for Tab/Enter/Space/Escape/Arrow key operability
- **Focus management** validation for dialogs, menus, and dynamic content
- **Semantic structure** assertions for landmarks, headings, and ARIA
- **Form accessibility** testing for labels, errors, and instructions
- **Color contrast** and visual accessibility verification
- **Screen reader** compatibility testing patterns

### Do NOT Use For

- Selenium/Java accessibility testing (use `accessibility-selenium-testing`).
- Authoring Playwright functional/UI E2E specs (use `playwright-e2e-testing`).
- Full conformance sign-off — automated axe scans catch ~30-40% of issues; manual audit + assistive-tech testing is still required.

## Prerequisites

| Requirement | Details                        |
| ----------- | ------------------------------ |
| Node.js     | v18+ recommended               |
| Playwright  | `@playwright/test` installed   |
| axe-core    | `@axe-core/playwright` package |
| TypeScript  | Configured in project          |

### Quick Setup

```bash
# Add axe-core to existing Playwright project
npm install -D @axe-core/playwright axe-core
```

## First Questions to Ask

Before writing accessibility tests, clarify:

1. **Scope**: Which pages/flows are in scope? What's explicitly excluded?
2. **Standard**: WCAG 2.2 AA (default) or specific organizational policy?
3. **Priority**: Which components are highest risk (forms, modals, navigation, checkout)?
4. **Exceptions**: Known constraints (legacy markup, third-party widgets)?
5. **Assistive Tech**: Which screen readers/browsers need manual testing?

---

## Core Principles

### 1. Automation Limitations

> [!] **Critical**: Automated tooling can detect ~30-40% of accessibility issues. Use automation to prevent regressions and catch common failures; **manual audits are required** for full WCAG conformance.

### 2. Semantic HTML First

Prefer native HTML semantics over ARIA. Use ARIA only when native elements cannot achieve the required semantics.

```typescript
// [ok] Semantic HTML - inherently accessible
await page.getByRole("button", { name: "Submit" }).click();

// [no] ARIA override - requires manual keyboard/focus handling
await page.locator('[role="button"]').click(); // Often a <div>
```

### 3. Locator Strategy as A11y Signal

If you **cannot locate an element by role or label**, it's often an accessibility defect.

| Locator Success                              | Accessibility Signal       |
| -------------------------------------------- | -------------------------- |
| `getByRole('button', { name: 'Submit' })` [ok] | Button has accessible name |
| `getByLabel('Email')` [ok]                     | Input properly labeled     |
| `getByRole('navigation')` [ok]                 | Landmark exists            |
| `locator('.submit-btn')` [!]                  | May lack accessible name   |

---

## Key Workflows

### Automated Axe Scan (WCAG 2.2 AA)

```typescript
import AxeBuilder from "@axe-core/playwright";
import { test, expect } from "@playwright/test";

test("page has no WCAG 2.2 AA violations", async ({ page }) => {
  await page.goto("/");

  const results = await new AxeBuilder({ page })
    .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22a", "wcag22aa"])
    .analyze();

  expect(results.violations).toEqual([]);
});
```

### Scoped Axe Scan (Component-Level)

```typescript
test("form component is accessible", async ({ page }) => {
  await page.goto("/contact");

  const results = await new AxeBuilder({ page })
    .include("#contact-form") // Scope to specific component
    .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22a", "wcag22aa"])
    .analyze();

  expect(results.violations).toEqual([]);
});
```

### Keyboard Navigation Test

```typescript
test("form is keyboard navigable", async ({ page }) => {
  await page.goto("/login");

  // Tab to first field
  await page.keyboard.press("Tab");
  await expect(page.getByLabel("Email")).toBeFocused();

  // Tab to password
  await page.keyboard.press("Tab");
  await expect(page.getByLabel("Password")).toBeFocused();

  // Tab to submit button
  await page.keyboard.press("Tab");
  await expect(page.getByRole("button", { name: "Sign in" })).toBeFocused();

  // Submit with Enter
  await page.keyboard.press("Enter");
  await expect(page).toHaveURL(/dashboard/);
});
```

### Dialog Focus Management

```typescript
test("dialog traps and returns focus", async ({ page }) => {
  await page.goto("/settings");
  const trigger = page.getByRole("button", { name: "Delete account" });

  // Open dialog
  await trigger.click();
  const dialog = page.getByRole("dialog");
  await expect(dialog).toBeVisible();

  // Focus should be inside dialog
  await expect(dialog.getByRole("button", { name: "Cancel" })).toBeFocused();

  // Tab should stay trapped in dialog
  await page.keyboard.press("Tab");
  await expect(dialog.getByRole("button", { name: "Confirm" })).toBeFocused();
  await page.keyboard.press("Tab");
  await expect(dialog.getByRole("button", { name: "Cancel" })).toBeFocused();

  // Escape closes and returns focus to trigger
  await page.keyboard.press("Escape");
  await expect(dialog).toBeHidden();
  await expect(trigger).toBeFocused();
});
```

### Skip Link Validation

```typescript
test("skip link moves focus to main content", async ({ page }) => {
  await page.goto("/");

  // First Tab should focus skip link
  await page.keyboard.press("Tab");
  const skipLink = page.getByRole("link", { name: /skip to (main|content)/i });
  await expect(skipLink).toBeFocused();

  // Activating skip link moves focus to main
  await page.keyboard.press("Enter");
  await expect(page.locator('#main, [role="main"]').first()).toBeFocused();
});
```

---

## POUR Principles Reference

| Principle          | Focus Areas                               | Example Tests                                     |
| ------------------ | ----------------------------------------- | ------------------------------------------------- |
| **Perceivable**    | Alt text, captions, contrast, structure   | Image alternatives, color contrast ratio          |
| **Operable**       | Keyboard, focus, timing, navigation       | Tab order, focus visibility, skip links           |
| **Understandable** | Labels, instructions, errors, consistency | Form labels, error messages, predictable behavior |
| **Robust**         | Valid HTML, ARIA, name/role/value         | Semantic structure, accessible names              |

---

## Axe-Core Tags

Default: `wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa`, `wcag22a`, `wcag22aa` (WCAG 2.2 AA). Use `best-practice` for additional checks. See [`references/axe-tags-reference.md`](references/axe-tags-reference.md) for full tag list.

---

## Exception Handling

When exceptions are unavoidable:

1. **Scope narrowly** - specific component/route only
2. **Document impact** - which WCAG criterion, user impact
3. **Set expiration** - owner + remediation date
4. **Track ticket** - link to remediation issue

```typescript
// [no] Avoid: Global rule disable
new AxeBuilder({ page }).disableRules(["color-contrast"]);

// [ok] Better: Scoped exclusion with documentation
new AxeBuilder({ page })
  .exclude("#third-party-widget") // Known issue: JIRA-1234, fix by Q2
  .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22a", "wcag22aa"])
  .analyze();
```

---

## Troubleshooting

| Problem                                           | Cause                          | Solution                                |
| ------------------------------------------------- | ------------------------------ | --------------------------------------- |
| Axe finds 0 violations but app fails manual audit | Automation covers ~30-40%      | Add manual testing checklist            |
| False positive on dynamic content                 | Content not fully rendered     | Wait for stable state before scan       |
| Color contrast fails incorrectly                  | Background image/gradient      | Use `exclude` for known false positives |
| Cannot find element by role                       | Missing semantic HTML          | Fix markup - this is a real bug         |
| Focus not visible                                 | Missing `:focus` styles        | Add visible focus indicator CSS         |
| Dialog focus not trapped                          | Missing focus trap logic       | Implement focus trap (see snippets)     |
| Skip link doesn't work                            | Target missing `tabindex="-1"` | Add tabindex to main content            |

---

## CLI Quick Reference

| Command                             | Description                            |
| ----------------------------------- | -------------------------------------- |
| `npx playwright test --grep "a11y"` | Run accessibility tests only           |
| `npx playwright test --headed`      | Run with visible browser for debugging |
| `npx playwright test --debug`       | Step through with Inspector            |
| `PWDEBUG=1 npx playwright test`     | Debug mode with pause                  |

---

## Red Flags

- Treating a clean axe scan as full WCAG conformance — automation covers only ~30-40% of criteria.
- Globally disabling rules (e.g., `color-contrast`) instead of scoped `.exclude()` with a documented ticket.
- Scanning before the page reaches a stable state — async content yields false "0 violations".
- Skipping keyboard/focus tests because axe passed — focus order and traps need explicit tests.

---

## References

| Document                                                                         | Content                                          |
| -------------------------------------------------------------------------------- | ------------------------------------------------ |
| [Snippets: Setup & Scanning](./references/snippets-setup-and-scanning.md)        | axe-core setup, helper, and scanning patterns    |
| [Snippets: Keyboard, Focus, Semantic](./references/snippets-keyboard-focus-semantic.md) | Keyboard navigation, focus management, semantic structure |
| [Snippets: Visual, Names, Checklist](./references/snippets-visual-names-checklist.md) | Visual accessibility, accessible names, critical pages |
| [WCAG 2.2 AA Checklist](./references/wcag21aa-checklist.md)                      | Manual audit checklist by POUR principle         |
| [ARIA Patterns: Widgets Part 1](./references/aria-patterns-widgets-1.md)         | Fundamentals, dialog, tabs, menu widgets         |
| [ARIA Patterns: Widgets Part 2](./references/aria-patterns-widgets-2.md)         | Accordion, combobox, live regions, tooltip       |
| [ARIA Patterns: Mistakes & Reference](./references/aria-patterns-mistakes.md)    | Common ARIA mistakes and roles quick reference   |

## External Resources

| Resource                     | URL                                     |
| ---------------------------- | --------------------------------------- |
| WCAG 2.2 Specification       | https://www.w3.org/TR/WCAG22/           |
| WCAG Quick Reference         | https://www.w3.org/WAI/WCAG22/quickref/ |
| WAI-ARIA Authoring Practices | https://www.w3.org/WAI/ARIA/apg/        |
| axe-core Rules               | https://dequeuniversity.com/rules/axe/  |

---

## Verification

- [ ] **axe-core audit passes** — `AxeBuilder.analyze()` returns zero critical violations
- [ ] **Keyboard navigation tested** — All interactive elements reachable via Tab; focus order is logical
- [ ] **Color contrast sufficient** — WCAG 2.2 AA minimum contrast ratios met (4.5:1 normal text, 3:1 large text)
- [ ] **WCAG 2.2 AA conformance** — Tags `wcag22a`/`wcag22aa` included in scans (focus-not-obscured, dragging movements, target-size minimums)
