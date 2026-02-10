---
name: 'analyze-flakiness'
description: 'Identify potential sources of test flakiness by examining wait strategies, visibility assertions, and timing patterns in test code'
version: '1.0.0'
type: 'composite'
category: 'test-analysis'

composed-of:
  - 'atomic/waits/wait-for-visible'
  - 'atomic/assertions/assert-visible'
  - 'atomic/interactions/click-safe'
  - 'atomic/locators/find-by-role'

activation: 'explicit'
aliases: ['flaky-test-analysis', 'test-stability-analysis', 'identify-flakiness', 'flakiness-detector']

requires:
  skills: ['generate-e2e-test', 'diagnose-failure']
  knowledge: ['race conditions', 'timing issues', 'async operations', 'flaky test patterns']
  tools: ['@playwright/test', 'selenium', 'test runners']

output:
  format: 'report'
  template: 'templates/flakiness-report.md'

success-criteria:
  - Identify all potential timing-related issues
  - Flag inadequate wait strategies
  - Detect race conditions
  - Suggest specific fixes for each flaky pattern found
  - Prioritize issues by likelihood of causing flakes
---

## Purpose

Analyze test code to identify patterns that commonly cause flaky test behavior. This composite skill examines wait strategies, assertions, and interactions to pinpoint timing-related vulnerabilities that lead to intermittent failures.

## When to Use

- During test code review to catch potential flakiness
- When investigating intermittent test failures
- Before merging new test code
- As part of test suite health assessment
- When establishing test quality standards

## Required Atomic Skills

This composite skill orchestrates the following atomic skills:

- [wait-for-visible](../../atomic/waits/wait-for-visible.skill.md) - Identify timing/wait issues
- [assert-visible](../../atomic/assertions/assert-visible.skill.md) - Find assertion timing problems
- [click-safe](../../atomic/interactions/click-safe.skill.md) - Detect interaction timing issues
- [find-by-role](../../atomic/locators/find-by-role.skill.md) - Check for fragile locators

## Flakiness Patterns

### Pattern 1: Missing Waits

**Risk Level**: HIGH
**Description**: Interacting with elements before they're ready

```typescript
// FLAKY - No wait for dynamic content
test('flaky example', async ({ page }) => {
  await page.goto('/dashboard');
  // Chart data loads asynchronously - no wait!
  await page.getByTestId('chart').click();
});

// ANALYSIS: Using wait-for-visible
// PROBLEM: Element may not be ready when click is attempted
// FIX: Add explicit wait
test('fixed example', async ({ page }) => {
  await page.goto('/dashboard');
  await page.getByTestId('chart').waitFor({ state: 'visible' });
  await page.getByTestId('chart').click();
});
```

### Pattern 2: Hard-coded Timeouts

**Risk Level**: MEDIUM
**Description**: Using arbitrary sleep durations instead of conditional waits

```typescript
// FLAKY - Arbitrary wait
test('flaky example', async ({ page }) => {
  await page.click('#submit');
  await page.waitForTimeout(3000); // Hope 3 seconds is enough!
  await expect(page.getByText('Success')).toBeVisible();
});

// ANALYSIS: Using wait-for-visible
// PROBLEM: Too short on slow machines, wasteful on fast ones
// FIX: Wait for specific condition
test('fixed example', async ({ page }) => {
  await page.click('#submit');
  await page.getByText('Success').waitFor({ state: 'visible' });
  await expect(page.getByText('Success')).toBeVisible();
});
```

### Pattern 3: No Post-Action Verification

**Risk Level**: HIGH
**Description**: Assuming actions complete successfully

```typescript
// FLAKY - No verification
test('flaky example', async ({ page }) => {
  await page.goto('/form');
  await page.fill('#email', 'test@example.com');
  await page.click('#submit');
  // Test continues immediately - did form submit?
  await expect(page.getByText('Welcome')).toBeVisible();
});

// ANALYSIS: Using assert-visible
// PROBLEM: Click may have failed or form may still be submitting
// FIX: Verify intermediate state
test('fixed example', async ({ page }) => {
  await page.goto('/form');
  await page.fill('#email', 'test@example.com');
  await page.click('#submit');
  // Verify form started submission
  await expect(page.getByTestId('submitting')).toBeVisible();
  // Wait for completion
  await expect(page.getByText('Welcome')).toBeVisible();
});
```

### Pattern 4: Fragile Locators

**Risk Level**: MEDIUM
**Description**: Using selectors that break with UI changes

```typescript
// FLAKY - CSS selector
test('flaky example', async ({ page }) => {
  // CSS class can change during refactoring
  await page.locator('.btn-primary.large').click();
});

// ANALYSIS: Using find-by-role
// PROBLEM: Selector depends on implementation details
// FIX: Use semantic locators
test('fixed example', async ({ page }) => {
  await page.getByRole('button', { name: 'Submit' }).click();
});
```

### Pattern 5: Race Conditions in API Calls

**Risk Level**: HIGH
**Description**: Not waiting for API responses before continuing

```typescript
// FLAKY - Race condition
test('flaky example', async ({ page }) => {
  await page.goto('/users');
  // Data loads via API - no wait!
  const count = await page.locator('.user-item').count();
  expect(count).toBeGreaterThan(0);
});

// ANALYSIS: Using wait-for-visible
// PROBLEM: Count may be 0 if API hasn't responded
// FIX: Wait for data to load
test('fixed example', async ({ page }) => {
  await page.goto('/users');
  await page.getByRole('listitem').first().waitFor({ state: 'visible' });
  const count = await page.locator('.user-item').count();
  expect(count).toBeGreaterThan(0);
});
```

### Pattern 6: Animation/Transition Not Considered

**Risk Level**: MEDIUM
**Description**: Interacting during animations

```typescript
// FLAKY - Animation interference
test('flaky example', async ({ page }) => {
  await page.click('#expand');
  // Element is animating - may not be clickable yet!
  await page.click('#expanded-content button');
});

// ANALYSIS: Using wait-for-visible and click-safe
// PROBLEM: Click may fail during animation
// FIX: Wait for animation to complete
test('fixed example', async ({ page }) => {
  await page.click('#expand');
  await page.getByTestId('expanded-content').waitFor({ state: 'visible' });
  await page.waitForTimeout(300); // Allow animation to finish
  await page.click('#expanded-content button');
});
```

### Pattern 7: Multiple Element Ambiguity

**Risk Level**: MEDIUM
**Description**: Selector matches multiple elements

```typescript
// FLAKY - Multiple matches
test('flaky example', async ({ page }) => {
  // Multiple delete buttons - which one gets clicked?
  await page.getByRole('button', { name: 'Delete' }).click();
});

// ANALYSIS: Using find-by-role
// PROBLEM: Selector is not specific enough
// FIX: Disambiguate by context
test('fixed example', async ({ page }) => {
  await page.getByRole('listitem', { name: 'Item 1' })
    .getByRole('button', { name: 'Delete' })
    .click();
});
```

## Analysis Workflow

### 1. Scan for Anti-Patterns

Look for these red flags:
- `waitForTimeout()` calls
- CSS selectors like `.class`, `#id` instead of role
- Actions without following assertions
- No waits after navigation
- Interactions immediately after page loads

### 2. Check Async Operations

Identify:
- API calls triggered by actions
- Dynamic content rendering
- Route transitions
- Modal/dialog appearances
- Loading states

### 3. Validate Locators

Check for:
- Role-based locators preferred
- Test IDs used appropriately
- No brittle CSS/XPath
- Unique element identification

### 4. Review Timing Dependencies

Look for:
- Dependencies on implicit waits
- Assumptions about load times
- Multi-step flows without checkpoints
- Parallel operations without coordination

## Flakiness Report Template

```markdown
# Test Flakiness Analysis Report

## Test: [Test Name]
**File**: path/to/test.spec.ts
**Lines**: X-Y

### Risk Score: HIGH/MEDIUM/LOW

---

### Identified Issues

#### 1. Missing Wait for Dynamic Content
**Severity**: HIGH
**Line**: 42
**Pattern**: Pattern 1 - Missing Waits

```typescript
// Current code
await page.goto('/dashboard');
await page.getByTestId('chart').click();
```

**Why It's Flaky**: Chart data loads asynchronously via API. Click may execute before data loads.

**Recommended Fix**:
```typescript
await page.goto('/dashboard');
await page.getByTestId('chart').waitFor({ state: 'visible' });
await page.getByTestId('chart').click();
```

---

#### 2. Hard-coded Timeout
**Severity**: MEDIUM
**Line**: 55
**Pattern**: Pattern 2 - Hard-coded Timeouts

```typescript
// Current code
await page.waitForTimeout(3000);
```

**Why It's Flaky**: Arbitrary duration may be insufficient on slow machines.

**Recommended Fix**:
```typescript
await page.getByTestId('loading').waitFor({ state: 'hidden' });
```

---

### Summary

| Issue | Severity | Pattern | Affected Lines |
|-------|----------|---------|----------------|
| Missing wait | HIGH | Pattern 1 | 42, 47, 51 |
| Hard-coded timeout | MEDIUM | Pattern 2 | 55 |
| No verification | HIGH | Pattern 3 | 63 |

### Priority Recommendations

1. [HIGH] Add explicit wait for chart data load
2. [HIGH] Verify form submission completion
3. [MEDIUM] Replace hard-coded timeouts with conditional waits

---

### Estimated Fix Time
**Quick Fixes**: 15 minutes
**Complete Refactoring**: 1 hour
```

## Common Flaky Scenarios

| Scenario | Flaky Pattern | Quick Fix |
|----------|---------------|-----------|
| Modal appears after click | Pattern 1 | Wait for dialog to be visible |
| Form submits to API | Pattern 3 | Verify loading, then success |
| Table data loads async | Pattern 5 | Wait for first row to appear |
| Dropdown menu opens | Pattern 6 | Wait for menuitem to be visible |
| Multiple similar buttons | Pattern 7 | Filter by parent context |
| Page navigation | Pattern 1 | Wait for URL change |
| File upload progress | Pattern 3 | Wait for completion indicator |

## Detection Heuristics

Use these rules to flag potential flakiness:

```typescript
// Flags for flaky patterns
const flakyPatterns = {
  hardCodedWait: /waitForTimeout/,
  cssSelector: /locator\(['"`].*[\.\#][\w-]+['"`]\)/,
  noWaitAfterNav: /goto\([^)]+\)\s*[^w]/, // goto not followed by wait
  clickWithoutVerify: /\.click\(\)\s*[^a]/, // click not followed by assertion
  firstOrLast: /\.first\(\)|\.last\(\)/, // May indicate ambiguous selectors
  indexBased: /\.nth\(\d+\)/, // Index-based selection
  waitForSelector: /waitForSelector\(['"`][^'"()]*['"`]\)/, // Generic wait
};
```

## Best Practices to Prevent Flakiness

1. **Always wait for specific conditions** - Use waitFor() with meaningful conditions
2. **Assert after actions** - Verify expected state changes
3. **Use semantic locators** - Role-based selectors are more stable
4. **Avoid arbitrary timeouts** - Let conditions drive test flow
5. **Handle loading states** - Wait for spinners/progress to complete
6. **Consider animations** - Account for transition times
7. **Be specific with selectors** - Avoid first/last when possible

## Related Skills

- [diagnose-failure](../test-healing/diagnose-failure.skill.md) - Analyze specific failures
- [suggest-fixes](../test-healing/suggest-fixes.skill.md) - Get specific fixes
- [wait-for-visible](../../atomic/waits/wait-for-visible.skill.md) - Proper wait patterns
