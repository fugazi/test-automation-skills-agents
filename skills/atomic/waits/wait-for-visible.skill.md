---
name: 'wait-for-visible'
description: 'Pause test execution until an element becomes visible in the viewport, handling dynamic content loading and conditional rendering'
version: '1.0.0'
type: 'atomic'
category: 'waits'

activation: 'implicit'
aliases: ['await-visible', 'wait-for-element', 'wait-for-displayed', 'waitForVisible']

requires:
  knowledge: ['dynamic content loading', 'AJAX/rendering delays', 'race conditions']
  tools: ['@playwright/test', 'selenium', 'webdriverio']

output:
  format: 'code'

success-criteria:
  - Element exists in DOM
  - Element is visible (not hidden by CSS)
  - Wait completes within specified timeout
  - No flaky failures due to timing issues
---

## Purpose

Synchronize test execution with dynamic UI state by waiting for elements to become visible. This prevents race conditions when content loads asynchronously or appears after user interactions.

## When to Use

- After triggering dynamic content loading (API calls, navigation)
- When elements appear with animation or transition delays
- Before interacting with conditionally rendered elements
- After actions that change visibility (clicking expand/collapse)
- When working with lazy-loaded content

## Playwright Examples

### Basic wait for visible
```typescript
await page.waitForSelector('[data-testid="modal"]', {
  state: 'visible'
});
```

### Wait with timeout
```typescript
await page.waitForSelector('#success-message', {
  state: 'visible',
  timeout: 10000
});
```

### Wait with locator
```typescript
await page.getByRole('dialog').waitFor({ state: 'visible' });
```

### Combined with assertion
```typescript
// Wait then assert
await page.getByTestId('loading').waitFor({ state: 'hidden' });
await expect(page.getByTestId('content')).toBeVisible();
```

### Wait for multiple elements
```typescript
// Wait for ANY matching element
await page.waitForSelector('[data-testid="item"]', {
  state: 'visible'
});

// Wait for all elements (custom logic)
await page.waitForFunction(() =>
  document.querySelectorAll('[data-testid="item"]').length > 0
);
```

### Wait with custom condition
```typescript
await page.waitForFunction(
  () => {
    const el = document.querySelector('[data-testid="chart"]');
    return el && el.getBoundingClientRect().width > 0;
  },
  null,
  { timeout: 5000 }
);
```

## Selenium Examples

### Explicit wait for visibility
```java
WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
WebElement modal = wait.until(
    ExpectedConditions.visibilityOfElementLocated(
        By.id("modal-dialog")
    )
);
```

### Wait for element to be present AND visible
```java
WebElement element = wait.until(
    ExpectedConditions.and(
        ExpectedConditions.presenceOfElementLocated(By.id("element")),
        ExpectedConditions.visibilityOfElementLocated(By.id("element"))
    )
);
```

### Wait for custom condition
```java
WebElement element = wait.until(new ExpectedCondition<WebElement>() {
    @Override
    public WebElement apply(WebDriver driver) {
        WebElement el = driver.findElement(By.id("chart"));
        return el.isDisplayed() ? el : null;
    }
});
```

### Wait for invisibility
```java
wait.until(
    ExpectedConditions.invisibilityOfElementLocated(
        By.id("loading-spinner")
    )
);
```

### Fluent wait with custom polling
```java
Wait<WebDriver> fluentWait = new FluentWait<>(driver)
    .withTimeout(Duration.ofSeconds(10))
    .pollingEvery(Duration.ofMillis(500))
    .ignoring(NoSuchElementException.class);

WebElement element = fluentWait.until(driver ->
    driver.findElement(By.id("dynamic-content"))
);
```

## WebdriverIO Examples

```javascript
// Basic wait for displayed
await $('#modal').waitForDisplayed({ timeout: 5000 });

// Wait for visible
await $('#modal').waitFor({ timeout: 5000, visible: true });

// Wait for hidden
await $('#loading').waitForDisplayed({ reverse: true });

// Wait for existence (not necessarily visible)
await $('#element').waitForExist();

// Custom wait condition
await browser.waitUntil(
    async () => (await $('#chart').isDisplayed()) === true,
    { timeout: 5000, timeoutMsg: 'Chart never became visible' }
);
```

## Wait States Reference

| State | Description |
|-------|-------------|
| `attached` | Element in DOM (may be hidden) |
| `detached` | Element removed from DOM |
| `visible` | Element visible in viewport |
| `hidden` | Element not visible (exists but hidden) |

## Anti-Patterns

❌ **Don't** use hard-coded sleeps:
```typescript
// Avoid - arbitrary delays
await page.waitForTimeout(3000);

// Prefer - conditional waits
await page.getByTestId('modal').waitFor({ state: 'visible' });
```

❌ **Don't** wait longer than necessary:
```typescript
// Avoid - excessive timeout
await page.waitForSelector('#element', { timeout: 60000 });

// Prefer - reasonable timeout with clear error
await page.waitForSelector('#element', {
  timeout: 10000,
  state: 'visible'
});
```

❌ **Don't** wait without assertion:
```typescript
// Avoid - wait but don't verify
await page.waitForSelector('#content');
await page.locator('#content').click();

// Prefer - wait and verify
await page.waitForSelector('#content', { state: 'visible' });
await expect(page.locator('#content')).toBeVisible();
await page.locator('#content').click();
```

❌ **Don't** ignore timeout errors:
```typescript
// Avoid - silent failure
try {
  await page.waitForSelector('#element', { timeout: 1000 });
} catch (e) {
  // Do nothing
}
```

## Best Practices

1. **Set appropriate timeouts** - Balance reliability and test speed
2. **Wait for specific conditions** - Use `state` parameter explicitly
3. **Chain with actions** - Combine wait with subsequent interactions
4. **Handle timeouts gracefully** - Provide meaningful error messages
5. **Prefer auto-waiting** - Let framework handle implicit waits when possible

## Common Scenarios

### Modal appears after click
```typescript
await page.getByRole('button', { name: 'Open Settings' }).click();
await page.getByRole('dialog', { name: 'Settings' })
  .waitFor({ state: 'visible' });
```

### Content loads after navigation
```typescript
await page.goto('/dashboard');
await page.getByTestId('dashboard-content')
  .waitFor({ state: 'visible' });
```

### Loading spinner disappears
```typescript
await page.getByRole('button', { name: 'Submit' }).click();
await page.getByTestId('loading')
  .waitFor({ state: 'hidden' });
await page.getByTestId('success-message')
  .waitFor({ state: 'visible' });
```

### Animated element becomes interactive
```typescript
await page.getByRole('button', { name: 'Show Details' }).click();
// Wait for animation to complete
await page.getByTestId('details-panel')
  .waitFor({ state: 'visible' });
await page.waitForTimeout(300); // For animation completion if needed
```

### Table data loads asynchronously
```typescript
await page.goto('/reports');
await page.getByTestId('table-row')
  .first()
  .waitFor({ state: 'visible' });
```

## Timeout Strategies

### Progressive timeouts
```typescript
// Quick fail for expected elements
await page.getByTestId('fast-element')
  .waitFor({ state: 'visible', timeout: 2000 });

// Longer timeout for slow operations
await page.getByTestId('api-data')
  .waitFor({ state: 'visible', timeout: 15000 });
```

### Framework-level defaults
```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    actionTimeout: 10000,     // Default for actions
    navigationTimeout: 30000, // Default for navigation
  },
});
```

## Related Skills

- [assert-visible](../assertions/assert-visible.skill.md) - Verify visibility after waiting
- [find-by-role](../locators/find-by-role.skill.md) - Locate elements to wait for
- [click-safe](../interactions/click-safe.skill.md) - Safe interaction after waiting
