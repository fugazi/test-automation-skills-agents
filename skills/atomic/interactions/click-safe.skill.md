---
name: 'click-safe'
description: 'Perform safe element clicks with proper waiting, visibility checks, and error handling to prevent flaky test failures'
version: '1.0.0'
type: 'atomic'
category: 'interactions'

activation: 'implicit'
aliases: ['safe-click', 'reliable-click', 'click-element', 'perform-click']

requires:
  knowledge: ['element interactivity', 'click interception', 'viewport visibility', 'overlay handling']
  tools: ['@playwright/test', 'selenium', 'webdriverio']

output:
  format: 'code'

success-criteria:
  - Element is visible and enabled before click
  - Click action completes successfully
  - Expected post-click state is verified
  - No timeout or element-click-intercepted errors
---

## Purpose

Execute reliable click actions on interactive elements by ensuring the element is ready, visible, and not obscured. This prevents common flaky test issues caused by timing problems and UI overlays.

## When to Use

- Clicking buttons, links, and other interactive elements
- Triggering actions that change application state
- Interacting with dynamically rendered elements
- Navigating between pages or views
- Opening/closing modals and dropdowns

## Pre-Click Checklist

Before clicking, ensure:
- [ ] Element is visible in viewport
- [ ] Element is enabled (not disabled)
- [ ] Element is not obscured by overlays
- [ ] Element is stable (not animating)
- [ ] Page is not actively loading

## Playwright Examples

### Basic safe click
```typescript
// Playwright auto-waits for element to be actionable
await page.getByRole('button', { name: 'Submit' }).click();
```

### Click with force override
```typescript
// Use sparingly - only when element is legitimately covered
await page.getByTestId('close-button').click({ force: true });
```

### Click with specific timeout
```typescript
await page.getByRole('link', { name: 'Details' }).click({
  timeout: 10000
});
```

### Double click
```typescript
await page.getByTestId('editable').dblclick();
```

### Click with modifier keys
```typescript
// Ctrl+Click to open in new tab
await page.getByRole('link', { name: 'Documentation' }).click({
  modifiers: ['Control']
});

// Shift+Click
await page.getByRole('button', { name: 'Select Range' }).click({
  modifiers: ['Shift']
});
```

### Click with position (for specific elements)
```typescript
await page.getByTestId('canvas').click({
  position: { x: 100, y: 50 }
});
```

### Safe click with verification
```typescript
async function safeClick(page, locator) {
  await locator.waitFor({ state: 'visible' });
  await expect(locator).toBeEnabled();
  await locator.click();
  // Verify expected outcome
}

await safeClick(page, page.getByRole('button', { name: 'Delete' }));
await expect(page.getByRole('dialog')).toBeVisible();
```

## Selenium Examples

### Basic click with explicit wait
```java
WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
WebElement button = wait.until(
    ExpectedConditions.elementToBeClickable(
        By.id("submit-button")
    )
);
button.click();
```

### Safe click wrapper
```java
public void safeClick(By locator) {
    WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
    WebElement element = wait.until(
        ExpectedConditions.and(
            ExpectedConditions.presenceOfElementLocated(locator),
            ExpectedConditions.visibilityOfElementLocated(locator),
            ExpectedConditions.elementToBeClickable(locator)
        )
    );
    element.click();
}

// Usage
safeClick(By.cssSelector("[data-testid='submit-btn']"));
```

### JavaScript click as fallback
```java
// Use only when normal click fails due to legitimate overlay
WebElement element = driver.findElement(By.id("button"));
JavascriptExecutor js = (JavascriptExecutor) driver;
js.executeScript("arguments[0].click();", element);
```

### Handling overlays before click
```java
// Dismiss cookie banner or overlay first
if (driver.findElements(By.id("cookie-banner")).size() > 0) {
    driver.findElement(By.id("accept-cookies")).click();
}

// Then proceed with intended click
driver.findElement(By.id("main-button")).click();
```

## WebdriverIO Examples

```javascript
// Basic click with auto-wait
await $('#submit-button').click();

// Click with scroll into view
await $('#off-screen-button').scrollIntoView();
await $('#off-screen-button').click();

// Force click
await $('#covered-button').click({ force: true });

// Safe click wrapper
async function safeClick(selector) {
    const elem = $(selector);
    await elem.waitForDisplayed({ timeout: 5000 });
    await elem.waitForEnabled({ timeout: 5000 });
    await elem.scrollIntoView();
    await elem.click();
}

await safeClick('#submit-btn');
```

## Common Click Failures and Solutions

### Element not clickable at point
```typescript
// Error: Element is not clickable at point (x, y)
// Solutions:
// 1. Wait for overlays to disappear
await page.getByTestId('modal').waitFor({ state: 'hidden' });
await page.getByRole('button', { name: 'Submit' }).click();

// 2. Scroll element into view
await page.getByRole('button', { name: 'Submit' })
  .scrollIntoViewIfNeeded();
await page.getByRole('button', { name: 'Submit' }).click();

// 3. Use force (last resort)
await page.getByRole('button', { name: 'Submit' })
  .click({ force: true });
```

### Element click intercepted
```typescript
// Error: Element click intercepted
// Solution: Wait for loading overlay
await page.getByTestId('loading-overlay')
  .waitFor({ state: 'hidden' });
await page.getByRole('button', { name: 'Submit' }).click();
```

### Element detached from DOM
```typescript
// Error: Element is detached from DOM
// Solution: Re-locate element after state change
await page.getByRole('button', { name: 'Refresh' }).click();
// Re-locate the target element
await page.getByRole('button', { name: 'Submit' })
  .waitFor({ state: 'attached' });
await page.getByRole('button', { name: 'Submit' }).click();
```

## Anti-Patterns

❌ **Don't** click without verifying readiness:
```typescript
// Avoid
await page.locator('#button').click();

// Prefer
await page.getByRole('button', { name: 'Submit' })
  .waitFor({ state: 'visible' });
await page.getByRole('button', { name: 'Submit' }).click();
```

❌ **Don't** use force by default:
```typescript
// Avoid - force skips all safety checks
await page.locator('#button').click({ force: true });

// Prefer - let framework handle auto-wait
await page.getByRole('button', { name: 'Submit' }).click();
```

❌ **Don't** click hidden elements:
```typescript
// Avoid - clicking hidden elements
await page.locator('[style="display:none"]').click();

// Prefer - verify visibility first
await expect(page.getByRole('button')).toBeVisible();
await page.getByRole('button').click();
```

❌ **Don't** click disabled elements:
```typescript
// Avoid
await page.locator('button:disabled').click();

// Prefer - verify enabled state
await expect(page.getByRole('button')).toBeEnabled();
await page.getByRole('button').click();
```

## Best Practices

1. **Use semantic locators** - Role-based selectors improve reliability
2. **Let framework auto-wait** - Modern frameworks handle waiting automatically
3. **Verify post-click state** - Confirm expected outcome
4. **Handle overlays** - Dismiss modals/banners before clicking
5. **Avoid force clicks** - Use only as last resort with documented reason

## Click Patterns

### Navigation link
```typescript
await page.getByRole('link', { name: 'Documentation' }).click();
await page.waitForURL(/\/docs/);
```

### Submit button
```typescript
await page.getByRole('button', { name: 'Submit' }).click();
await expect(page.getByTestId('success-message'))
  .toBeVisible();
```

### Dropdown trigger
```typescript
await page.getByRole('button', { name: 'Options' }).click();
await expect(page.getByRole('menu')).toBeVisible();
```

### Tab selection
```typescript
await page.getByRole('tab', { name: 'Settings' }).click();
await expect(page.getByRole('tabpanel', { name: 'Settings' }))
  .toBeVisible();
```

## Related Skills

- [find-by-role](../locators/find-by-role.skill.md) - Locate interactive elements
- [find-by-testid](../locators/find-by-testid.skill.md) - Alternative locator strategy
- [wait-for-visible](../waits/wait-for-visible.skill.md) - Ensure element is ready
- [assert-visible](../assertions/assert-visible.skill.md) - Verify post-click state
