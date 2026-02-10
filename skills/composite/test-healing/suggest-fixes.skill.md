---
name: 'suggest-fixes'
description: 'Suggest specific code fixes for common test failures, providing actionable solutions that combine wait strategies, safe interactions, and form handling patterns'
version: '1.0.0'
type: 'composite'
category: 'test-healing'

composed-of:
  - 'atomic/interactions/click-safe'
  - 'atomic/interactions/fill-form'
  - 'atomic/waits/wait-for-visible'
  - 'atomic/locators/find-by-role'
  - 'atomic/locators/find-by-testid'
  - 'atomic/assertions/assert-visible'

activation: 'explicit'
aliases: ['fix-suggestions', 'test-healing', 'auto-fix', 'remediation']

requires:
  skills: ['diagnose-failure']
  knowledge: ['anti-patterns', 'best practices', 'timing issues', 'locator strategies']
  tools: ['@playwright/test', 'selenium', 'webdriverio']

output:
  format: 'code'
  template: 'templates/fix-suggestion.md'

success-criteria:
  - Fix addresses the identified root cause
  - Solution follows testing best practices
  - Code is copy-paste ready
  - Multiple fix options provided (quick, robust, ideal)
  - Explanation of why fix works is included
---

## Purpose

Provide specific, actionable code fixes for common test failures. This composite skill combines interaction, wait, and locator patterns to suggest solutions that are both effective and maintainable.

## When to Use

- After diagnosing a test failure
- When refactoring flaky tests
- During code review to improve test quality
- When documenting common failure solutions
- For creating test healing/auto-fix rules

## Required Atomic Skills

This composite skill orchestrates the following atomic skills:

- [click-safe](../../atomic/interactions/click-safe.skill.md) - Safe element interaction patterns
- [fill-form](../../atomic/interactions/fill-form.skill.md) - Form handling solutions
- [wait-for-visible](../../atomic/waits/wait-for-visible.skill.md) - Timing and synchronization
- [find-by-role](../../atomic/locators/find-by-role.skill.md) - Robust locator strategies
- [find-by-testid](../../atomic/locators/find-by-testid.skill.md) - Fallback locator options
- [assert-visible](../../atomic/assertions/assert-visible.skill.md) - State verification

## Common Fixes by Category

### 1. Timing Fixes

#### Fix 1.1: Add Explicit Wait
**Problem**: Element not found/visible when test runs
**Solution**: Use wait-for-visible before interaction

```typescript
// BEFORE - Flaky
await page.getByRole('button', { name: 'Submit' }).click();

// AFTER - Fixed
await page.getByRole('button', { name: 'Submit' })
  .waitFor({ state: 'visible', timeout: 5000 });
await page.getByRole('button', { name: 'Submit' }).click();

// BETTER - Combined wait and verify
await expect(page.getByRole('button', { name: 'Submit' }))
  .toBeVisible({ timeout: 5000 });
await page.getByRole('button', { name: 'Submit' }).click();
```

#### Fix 1.2: Wait for Loading State
**Problem**: Test fails during data loading
**Solution**: Wait for loading indicator to disappear

```typescript
// BEFORE - Race condition
await page.goto('/dashboard');
await expect(page.getByTestId('chart')).toBeVisible();

// AFTER - Fixed
await page.goto('/dashboard');
await page.getByTestId('loading').waitFor({ state: 'hidden' });
await expect(page.getByTestId('chart')).toBeVisible();

// ALTERNATIVE - Wait for specific condition
await page.goto('/dashboard');
await page.waitForFunction(() =>
  document.querySelector('[data-testid="chart"]')?.offsetParent !== null
);
```

#### Fix 1.3: Increase Timeout
**Problem**: Operation takes longer than default timeout
**Solution**: Set appropriate timeout for the specific action

```typescript
// BEFORE - Default timeout too short
await page.getByRole('button', { name: 'Export Report' }).click();
await expect(page.getByTestId('download-link')).toBeVisible();

// AFTER - Fixed with longer timeout
await page.getByRole('button', { name: 'Export Report' }).click();
await expect(page.getByTestId('download-link'))
  .toBeVisible({ timeout: 15000 }); // Allow for report generation
```

### 2. Locator Fixes

#### Fix 2.1: Replace CSS with Role
**Problem**: CSS selector breaks after styling changes
**Solution**: Use find-by-role for resilient locators

```typescript
// BEFORE - Fragile CSS selector
await page.locator('.btn-primary.submit-btn').click();
await page.locator('#email-input').fill('user@example.com');

// AFTER - Robust role-based locators
await page.getByRole('button', { name: 'Submit' }).click();
await page.getByRole('textbox', { name: 'Email' }).fill('user@example.com');

// FALLBACK - If role not available
await page.getByTestId('submit-button').click();
await page.getByTestId('email-input').fill('user@example.com');
```

#### Fix 2.2: Handle Dynamic Content
**Problem**: Element attributes change dynamically
**Solution**: Use stable identifiers or relative locators

```typescript
// BEFORE - Dynamic ID
await page.locator('#item-847238').click();

// AFTER - Stable approach
await page.getByTestId('menu-item').filter({ hasText: 'Settings' }).click();
// OR
await page.getByRole('menuitem', { name: 'Settings' }).click();
```

#### Fix 2.3: Disambiguate Multiple Elements
**Problem**: Selector matches multiple elements
**Solution**: Use filters or relative locators

```typescript
// BEFORE - Ambiguous
await page.getByRole('button', { name: 'Delete' }).click();

// AFTER - Disambiguated
await page.getByRole('listitem', { name: 'Item 1' })
  .getByRole('button', { name: 'Delete' })
  .click();
// OR
await page.getByRole('button', { name: 'Delete' }).first().click();
```

### 3. Interaction Fixes

#### Fix 3.1: Handle Click Interception
**Problem**: Element click intercepted by overlay
**Solution**: Dismiss overlay before clicking

```typescript
// BEFORE - Click intercepted
await page.getByRole('button', { name: 'Submit' }).click();

// AFTER - Handle overlay
const cookieBanner = page.getByRole('dialog', { name: 'Cookie Consent' });
if (await cookieBanner.isVisible()) {
  await page.getByRole('button', { name: 'Accept All' }).click();
}
await page.getByRole('button', { name: 'Submit' }).click();

// ALTERNATIVE - Wait for overlay to disappear
await page.getByRole('dialog', { name: 'Cookie Consent' })
  .waitFor({ state: 'hidden', timeout: 5000 })
  .catch(() => {}); // Ignore if already gone
await page.getByRole('button', { name: 'Submit' }).click();
```

#### Fix 3.2: Scroll Into View
**Problem**: Element exists but not in viewport
**Solution**: Scroll before interaction

```typescript
// BEFORE - Element off-screen
await page.getByTestId('save-button').click();

// AFTER - Scroll into view
await page.getByTestId('save-button').scrollIntoViewIfNeeded();
await page.getByTestId('save-button').click();

// AUTOMATIC - Playwright auto-scrolls, but explicit for other tools
await page.evaluate(selector => {
  document.querySelector(selector)?.scrollIntoView({ behavior: 'smooth' });
}, '[data-testid="save-button"]');
```

#### Fix 3.3: Force Click (Last Resort)
**Problem**: Legitimately covered element (rare)
**Solution**: Use force with documented reason

```typescript
// BEFORE - Attempted normal click
await page.getByTestId('tooltip-close').click();

// AFTER - Force click with justification
// Element is covered by a transparent overlay for event capture
// Force click is acceptable here as the element is designed to be clickable
await page.getByTestId('tooltip-close').click({ force: true });
```

### 4. Form Handling Fixes

#### Fix 4.1: Clear Before Fill
**Problem**: Existing values interfere
**Solution**: Explicitly clear or use fill (auto-clears)

```typescript
// BEFORE - Selenium doesn't auto-clear
emailField.sendKeys("new@example.com");

// AFTER - Clear first
emailField.clear();
emailField.sendKeys("new@example.com");

// PLAYWRIGHT - Auto-clears with fill()
await page.getByRole('textbox', { name: 'Email' }).fill('new@example.com');
```

#### Fix 4.2: Handle Dropdown Selection
**Problem**: Select by wrong property
**Solution**: Use correct selection method

```typescript
// BEFORE - Wrong approach
await page.locator('#country').click();
await page.locator('option[value="US"]').click();

// AFTER - Correct select handling
await page.getByRole('combobox', { name: 'Country' })
  .selectOption({ label: 'United States' });
// OR
await page.getByRole('combobox', { name: 'Country' })
  .selectOption('US');
```

#### Fix 4.3: Handle File Uploads
**Problem**: File upload input hidden/styled
**Solution**: Use setInputFiles directly

```typescript
// BEFORE - Trying to click styled button
await page.getByRole('button', { name: 'Upload' }).click();

// AFTER - Direct file input
await page.getByLabel('Resume').setInputFiles('/path/to/resume.pdf');

// HIDDEN INPUT - Find the actual input
const fileInput = page.locator('input[type="file"]');
await fileInput.setInputFiles('/path/to/file.pdf');
```

### 5. Assertion Fixes

#### Fix 5.1: Assert After Action
**Problem**: No verification of action result
**Solution**: Add assert-visible after interactions

```typescript
// BEFORE - No verification
await page.getByRole('button', { name: 'Save' }).click();

// AFTER - Verify result
await page.getByRole('button', { name: 'Save' }).click();
await expect(page.getByRole('alert', { name: 'Saved successfully' }))
  .toBeVisible();
```

#### Fix 5.2: Use Specific Assertions
**Problem**: Generic assertions miss edge cases
**Solution**: Use precise assertion types

```typescript
// BEFORE - Too generic
await expect(page.locator('.status')).toBeVisible();

// AFTER - Specific assertion
await expect(page.getByRole('status'))
  .toHaveAttribute('aria-live', 'polite');
await expect(page.getByRole('status'))
  .toHaveText(/saved|completed/);
```

#### Fix 5.3: Handle Multiple States
**Problem**: Element may be in different states
**Solution**: Assert appropriate state for context

```typescript
// BEFORE - Assumes always visible
await expect(page.getByTestId('dropdown-menu')).toBeVisible();

// AFTER - Conditional assertion
const isOpen = await page.getByRole('button', { name: 'Menu' })
  .getAttribute('aria-expanded');
if (isOpen === 'true') {
  await expect(page.getByTestId('dropdown-menu')).toBeVisible();
} else {
  await expect(page.getByTestId('dropdown-menu')).not.toBeVisible();
}
```

## Fix Suggestion Format

Each fix suggestion includes:

```markdown
### Fix: [Descriptive Name]

**Problem**: [What's failing and why]

**Solution**: [What the fix does]

**Code**:
```typescript
// Before
[problematic code]

// After
[fixed code]
```

**Why This Works**: [Explanation]

**Alternatives**: [Other approaches if applicable]
```

## Quick Reference

| Error Type | Quick Fix | Robust Fix |
|------------|-----------|------------|
| Element not found | Add testid | Use role-based locator |
| Element not visible | Add waitFor | Wait for loading state |
| Click intercepted | Dismiss overlay | Wait for overlay hidden |
| Timeout | Increase timeout | Wait for specific condition |
| Stale element | Re-locate | Use page.evaluate |
| Multiple matches | Use first() | Filter by context |

## Best Practices for Fixes

1. **Preventive over Reactive** - Add waits before interactions, not after failures
2. **Semantic over Specific** - Role-based locators over CSS/XPath
3. **Explicit over Implicit** - Clear intent with specific assertions
4. **Document Trade-offs** - Explain why a particular fix was chosen
5. **Consider Maintainability** - Fix should work through UI changes

## Related Skills

- [diagnose-failure](./diagnose-failure.skill.md) - Identify the problem first
- [analyze-flakiness](../test-analysis/analyze-flakiness.skill.md) - Find timing issues
- [extract-pom](../test-refactoring/extract-pom.skill.md) - Refactor after fixing
