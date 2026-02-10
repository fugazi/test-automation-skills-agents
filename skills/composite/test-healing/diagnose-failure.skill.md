---
name: 'diagnose-failure'
description: 'Analyze test failures to identify root causes, combining visibility checks, wait strategies, and locator analysis to pinpoint why tests fail'
version: '1.0.0'
type: 'composite'
category: 'test-healing'

composed-of:
  - 'atomic/locators/find-by-role'
  - 'atomic/locators/find-by-testid'
  - 'atomic/assertions/assert-visible'
  - 'atomic/assertions/assert-text'
  - 'atomic/waits/wait-for-visible'

activation: 'explicit'
aliases: ['failure-analysis', 'test-diagnosis', 'debug-test', 'root-cause-analysis']

requires:
  skills: ['generate-e2e-test']
  knowledge: ['test failure patterns', 'timing issues', 'locator fragility', 'DOM state changes']
  tools: ['@playwright/test', 'selenium', 'debugger', 'browser DevTools']

output:
  format: 'report'
  template: 'templates/failure-diagnosis-report.md'

success-criteria:
  - Root cause of failure is identified
  - Specific failing line/element is pinpointed
  - Category of failure (timing, locator, state, etc.) is determined
  - Actionable fix recommendations are provided
  - Similar potential failures are flagged
---

## Purpose

Systematically analyze test failures to determine their root cause. This composite skill combines locator knowledge, visibility assertions, and wait strategies to diagnose why tests fail and provide actionable remediation steps.

## When to Use

- When a test fails and you need to understand why
- During test triage to categorize failure types
- Before implementing fixes to ensure the correct solution
- For flaky test analysis to identify intermittent issues
- When onboarding new developers to the test suite

## Required Atomic Skills

This composite skill orchestrates the following atomic skills:

- [find-by-role](../../atomic/locators/find-by-role.skill.md) - Verify semantic locators exist
- [find-by-testid](../../atomic/locators/find-by-testid.skill.md) - Check for fallback locator options
- [assert-visible](../../atomic/assertions/assert-visible.skill.md) - Validate element visibility state
- [assert-text](../../atomic/assertions/assert-text.skill.md) - Check content matching
- [wait-for-visible](../../atomic/waits/wait-for-visible.skill.md) - Identify timing-related issues

## Workflow

### 1. Gather Failure Context
Collect information about the failure:
- Error message and stack trace
- Screenshot/video at failure point
- DOM snapshot at failure
- Network requests timing
- Console errors/warnings

### 2. Categorize Failure Type
Identify which category the failure falls into:
- **Locator failures**: Element not found
- **Visibility failures**: Element exists but not visible
- **Timing failures**: Element appears late
- **State failures**: Element in wrong state
- **Text/content failures**: Expected content mismatch

### 3. Apply Diagnostic Skills
Use atomic skills to investigate:
- Check element exists with current locator
- Verify element visibility state
- Test alternative locators
- Measure actual wait times needed
- Check for overlapping elements

### 4. Generate Diagnosis Report
Document findings and recommendations

## Examples

### Example 1: Locator Failure Diagnosis

```typescript
// FAILED TEST CODE
await page.locator('.submit-btn').click();
// Error: Selector .submit-btn did not match any elements

// DIAGNOSIS PROCESS
// 1. Check if element exists with different locator
const roleLocator = page.getByRole('button', { name: 'Submit' });
const testIdLocator = page.getByTestId('submit-button');

// 2. Verify which locator works
const existsByRole = await roleLocator.count() > 0;  // true
const existsByClass = await page.locator('.submit-btn').count() > 0;  // false

// DIAGNOSIS REPORT
// Failure Category: LOCATOR_FAILURE
// Root Cause: CSS class changed from 'submit-btn' to 'btn-primary'
// Element Status: EXISTS - can be found by role
// Recommendation: Replace CSS selector with role-based locator
// Suggested Fix:
//   await page.getByRole('button', { name: 'Submit' }).click();
```

### Example 2: Timing Failure Diagnosis

```typescript
// FAILED TEST CODE
await page.goto('/dashboard');
await expect(page.getByTestId('chart')).toBeVisible();
// Error: Timed out after 5000ms waiting for element to be visible

// DIAGNOSIS PROCESS
// 1. Check if element exists in DOM
const exists = await page.getByTestId('chart').count();  // true
const isVisible = await page.getByTestId('chart').isVisible();  // false

// 2. Check for loading indicators
const loadingSpinner = page.getByTestId('loading');
const isStillLoading = await loadingSpinner.isVisible();  // true

// 3. Measure actual load time
const start = Date.now();
await page.getByTestId('chart').waitFor({ state: 'visible' });
const actualWaitTime = Date.now() - start;  // ~6500ms

// DIAGNOSIS REPORT
// Failure Category: TIMING_FAILURE
// Root Cause: API call takes longer than test timeout (5000ms)
// Element Status: INVISIBLE - waiting for data
// Loading Indicator: ACTIVE
// Actual Wait Time Needed: ~6500ms
// Recommendations:
//   1. Increase timeout for this assertion
//   2. Wait for loading spinner to disappear first
// Suggested Fix:
//   await page.getByTestId('loading').waitFor({ state: 'hidden' });
//   await expect(page.getByTestId('chart')).toBeVisible({ timeout: 10000 });
```

### Example 3: Visibility vs Presence Confusion

```typescript
// FAILED TEST CODE
await page.getByRole('button', { name: 'Delete' }).click();
// Error: Element not visible

// DIAGNOSIS PROCESS
// 1. Check element state
const deleteBtn = page.getByRole('button', { name: 'Delete' });
const count = await deleteBtn.count();  // 1
const isVisible = await deleteBtn.isVisible();  // false
const isEnabled = await deleteBtn.isEnabled();  // false

// 2. Check why element is hidden
const parentElement = deleteBtn.locator('..');
const parentClass = await parentElement.getAttribute('class');  // contains 'disabled'
const userRole = await page.evaluate(() => window.user.role);  // 'viewer'

// DIAGNOSIS REPORT
// Failure Category: STATE_FAILURE
// Root Cause: User lacks permission - delete button exists but is disabled
// Element Status: EXISTS - NOT_VISIBLE - NOT_ENABLED
// Cause: Current user is 'viewer', delete requires 'editor' role
// Recommendations:
//   1. Test with appropriate user role
//   2. Add assertion to verify button state
// Suggested Fix:
//   // Verify button exists but is disabled for viewers
//   await expect(deleteBtn).not.toBeVisible();
//   // OR test with editor role
//   await loginAs('editor');
//   await expect(deleteBtn).toBeVisible();
```

### Example 4: Element Click Intercepted

```typescript
// FAILED TEST CODE
await page.getByRole('button', { name: 'Submit' }).click();
// Error: Element click intercepted

// DIAGNOSIS PROCESS
// 1. Check for overlays
const overlays = await page.locator('[role="dialog"], .modal, .overlay').all();
const visibleOverlays = overlays.filter(async o => await o.isVisible());

// 2. Check element position
const boundingBox = await page.getByRole('button', { name: 'Submit' }).boundingBox();
const elementAtPoint = await page.evaluate(
  ({ x, y }) => document.elementFromPoint(x, y)?.tagName,
  boundingBox
);  // 'DIV' (overlay)

// DIAGNOSIS REPORT
// Failure Category: INTERACTION_FAILURE
// Root Cause: Cookie banner overlay covering the submit button
// Element Status: VISIBLE - OBSCURED
// Blocking Element: Cookie consent banner
// Recommendations:
//   1. Dismiss overlay before clicking
//   2. Wait for overlay to auto-dismiss
// Suggested Fix:
//   const acceptCookies = page.getByRole('button', { name: 'Accept' });
//   if (await acceptCookies.isVisible()) {
//     await acceptCookies.click();
//   }
//   await page.getByRole('button', { name: 'Submit' }).click();
```

## Diagnosis Categories

| Category | Description | Atomic Skills Used |
|----------|-------------|-------------------|
| **LOCATOR_FAILURE** | Selector cannot find element | find-by-role, find-by-testid |
| **TIMING_FAILURE** | Element appears too slowly | wait-for-visible |
| **VISIBILITY_FAILURE** | Element exists but hidden | assert-visible |
| **INTERACTION_FAILURE** | Element cannot be clicked/interacted | click-safe |
| **STATE_FAILURE** | Element in wrong state | assert-visible, assert-text |
| **CONTENT_FAILURE** | Text/content mismatch | assert-text |

## Diagnosis Report Template

```markdown
# Test Failure Diagnosis

## Test Information
- **Test File**: auth/login.spec.ts
- **Test Name**: user can login with valid credentials
- **Failed Line**: 42
- **Error Message**: Timed out waiting for element

## Failure Classification
**Category**: TIMING_FAILURE
**Severity**: MEDIUM
**Frequency**: FIRST_OCCURRENCE

## Root Cause Analysis
### Element Status
- **Exists in DOM**: Yes
- **Visible**: No (waiting for data)
- **Enabled**: Yes
- **Obstructed**: No

### Timing Analysis
- **Configured Timeout**: 5000ms
- **Actual Time Needed**: ~7200ms
- **Loading Indicator**: Active

## Recommended Fixes

### Option 1: Increase Timeout (Quick Fix)
```typescript
await expect(page.getByRole('heading', { name: 'Dashboard' }))
  .toBeVisible({ timeout: 10000 });
```

### Option 2: Wait for Loading State (Better)
```typescript
await page.getByTestId('loading').waitFor({ state: 'hidden' });
await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
```

### Option 3: Wait for Specific Condition (Best)
```typescript
await page.waitForURL(/\/dashboard/);
await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
```

## Similar Potential Failures
- dashboard.spec.ts:78 - Similar wait for chart data
- profile.spec.ts:23 - Same dashboard navigation

## Additional Notes
Consider adding API mocking for faster, more reliable tests.
```

## Common Failure Patterns

### Pattern 1: CSS Selector Fragility
```
Symptom: Locator worked before, now fails
Cause: CSS classes changed during refactoring
Solution: Use role-based locators
```

### Pattern 2: Race Condition
```
Symptom: Test passes sometimes, fails sometimes
Cause: No wait for async operation
Solution: Add explicit wait or use auto-waiting framework
```

### Pattern 3: Wrong Frame/Context
```
Symptom: Element not found despite being visible
Cause: Looking in wrong iframe or browser context
Solution: Switch to correct frame/context first
```

### Pattern 4: Stale Element Reference
```
Symptom: Element becomes detached after action
Cause: DOM re-rendered after initial action
Solution: Re-locate element after state change
```

## Best Practices

1. **Preserve Failure Artifacts** - Save screenshots, videos, traces
2. **Reproduce Locally** - Don't rely solely on CI logs
3. **Check Console** - Browser errors often indicate root cause
4. **Verify Environment** - Check test data, API status
5. **Document Fix** - Add comment explaining why the fix works

## Related Skills

- [suggest-fixes](./suggest-fixes.skill.md) - Get specific fix implementations
- [analyze-flakiness](../test-analysis/analyze-flakiness.skill.md) - Analyze intermittent failures
- [wait-for-visible](../../atomic/waits/wait-for-visible.skill.md) - Timing solutions
