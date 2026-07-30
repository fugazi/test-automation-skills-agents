## Examples

### Minimal Skill Structure

```
skills/playwright-visual-testing/
├── SKILL.md
├── LICENSE.txt
├── references/
│   ├── masking-strategies.md
│   └── threshold-configuration.md
└── templates/
    └── visual-test-template.ts
```

### Minimal SKILL.md

````markdown
---
name: playwright-visual-testing
description: 'Visual regression testing with screenshot comparison. Use when asked to implement, update, or debug visual regression tests with Playwrights toHaveScreenshot(), configure thresholds, mask dynamic content, or manage baseline images. Covers snapshot comparison, CI baselines, and diff analysis.'
---

# Playwright Visual Regression Testing

## Overview

Toolkit for implementing visual regression testing using Playwright's built-in screenshot comparison. Ensures UI consistency across changes with configurable thresholds and masking.

## When to Use

- Implement visual regression tests with `toHaveScreenshot()`
- Configure comparison thresholds and maxDiffPixelRatio
- Mask dynamic content (timestamps, ads, avatars) in screenshots
- Debug screenshot diff failures
- Manage baseline images across CI environments

**NOT for:**

- Pixel-perfect design QA (use dedicated design review tools)
- Accessibility testing (use the `a11y-playwright-testing` skill)

## Core Process

1. **Identify visual regression scope**
   - List pages/components that need visual testing
   - Identify dynamic content that must be masked
   - Determine threshold sensitivity per component

2. **Create baseline screenshots**

   ```typescript
   await expect(page).toHaveScreenshot("homepage.png");
   ```

3. **Configure comparison options**

   ```typescript
   await expect(page).toHaveScreenshot("homepage.png", {
     maxDiffPixelRatio: 0.01,
     mask: [page.locator(".dynamic-content")],
   });
   ```

4. **Run and review**

   ```bash
   npx playwright test --update-snapshots  # First run (create baselines)
   npx playwright test                      # Subsequent runs (compare)
   ```

5. **Handle failures**
   - Review diff images in HTML report
   - If intentional change: update baseline with `--update-snapshots`
   - If regression: fix the UI change and re-run

## Affirmative Principles

> Do NOT use a `## Common Rationalizations` table. Express recurring-step discipline as 1-line affirmative principles instead.

- Always review the diff image before accepting a baseline update.
- Use per-component thresholds; a single global threshold is too loose for complex pages.
- Mask dynamic content (timestamps, ads, avatars) before capturing baselines.

## Red Flags

- Baseline images updated without reviewing diff output
- No masking for dynamic content (dates, ads, user-specific data)
- Visual tests disabled in CI pipeline
- Using full-page screenshots for components (use `.toHaveScreenshot()` on specific locators)
- Threshold set to 0 (any pixel change fails — too brittle for CI)

## Verification

- [ ] Baseline and threshold configured for all pages/components under test
- [ ] Dynamic content is masked with `mask` option
- [ ] Visual tests run in CI alongside functional tests
- [ ] Diff images reviewed before baseline updates
- [ ] Test report includes comparison images for all failures

## References

- [Masking Strategies](./references/masking-strategies.md)
- [Threshold Configuration](./references/threshold-configuration.md)
- [Visual Test Template](./templates/visual-test-template.ts)
````

