---
name: 'assert-visible'
description: 'Verify that an element is visible to the user in the viewport, distinguishing between presence in DOM and actual visibility'
version: '1.0.0'
type: 'atomic'
category: 'assertions'

activation: 'implicit'
aliases: ['assert-element-visible', 'verify-visible', 'check-visibility', 'is-displayed']

requires:
  knowledge: ['DOM visibility', 'CSS display/visibility properties', 'viewport detection']
  tools: ['@playwright/test', 'selenium', 'webdriverio']

output:
  format: 'code'

success-criteria:
  - Element exists in the DOM
  - Element has non-zero dimensions
  - Element is not hidden by CSS (display, visibility, opacity)
  - Element is not obscured by other elements (optional, framework-dependent)
---

## Purpose

Assert that an element is actually visible to users, not merely present in the DOM. This distinguishes between elements that exist in the page structure and those that users can actually see and interact with.

## When to Use

- Verifying elements appear after actions (clicks, form submissions, navigation)
- Checking modal/dialog visibility
- Validating conditional rendering (show/hide states)
- Confirming loading states have completed
- Testing responsive behavior (elements visible on certain breakpoints)

## Visibility Criteria

An element is considered visible when:
1. It exists in the DOM
2. Has computed `display` value other than `none`
3. Has computed `visibility` value other than `hidden`
4. Has `opacity` greater than 0 (framework-dependent)
5. Has non-zero width and height
6. Is not cropped by overflow (framework-dependent)

## Playwright Examples

### Basic visibility assertion
```typescript
await expect(page.getByRole('button', { name: 'Submit' }))
  .toBeVisible();
```

### With timeout
```typescript
await expect(page.getByTestId('modal'))
  .toBeVisible({ timeout: 5000 });
```

### Negation - not visible
```typescript
await expect(page.getByTestId('loading-spinner'))
  .not.toBeVisible();
```

### Wait then assert
```typescript
// Combined wait and assertion
await page.waitForSelector('[data-testid="success-message"]', {
  state: 'visible'
});
```

### Multiple elements visible
```typescript
const items = page.getByTestId('menu-item');
await expect(items.first()).toBeVisible();
await expect(items.nth(2)).toBeVisible();
await expect(items).toHaveCount(5); // All 5 exist and are visible
```

### Attached vs visible distinction
```typescript
// Element exists but may be hidden
await expect(page.getByTestId('tooltip'))
  .toBeAttached(); // In DOM
await expect(page.getByTestId('tooltip'))
  .toBeVisible(); // Actually visible
```

## Selenium Examples

### Basic visibility check
```java
WebElement button = driver.findElement(By.id("submit-button"));
assertThat(button.isDisplayed(), is(true));
```

### With explicit wait
```java
WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
WebElement modal = wait.until(
    ExpectedConditions.visibilityOfElementLocated(
        By.id("modal-dialog")
    )
);
```

### Check invisibility
```java
WebElement spinner = driver.findElement(By.id("loading"));
assertFalse(spinner.isDisplayed(), "Spinner should be hidden");
```

### Wait for invisibility
```java
wait.until(
    ExpectedConditions.invisibilityOfElementLocated(
        By.cssSelector("[data-testid='spinner']")
    )
);
```

### Distinguish presence from visibility
```java
WebElement element = driver.findElement(By.id("tooltip"));

assertTrue(element.isDisplayed());    // Visible to user
assertTrue(element.isEnabled());      // Interactive
assertFalse(element.getAttribute("hidden") == null); // Not hidden
```

## WebdriverIO Examples

```javascript
// Basic assertion
const button = $('#submit-button');
await expect(button).toBeDisplayed();

// With custom message
await expect(button).toHaveDisplayed({
    message: 'Submit button should be visible'
});

// Negation
await expect($('#loading')).not.toBeDisplayed();

// Wait for visible
await $('#modal').waitForDisplayed({ timeout: 5000 });
```

## Anti-Patterns

❌ **Don't** assume presence equals visibility:
```typescript
// Avoid
await expect(page.locator('#modal'))
  .toBeAttached(); // Only checks DOM presence
// Use
await expect(page.locator('#modal'))
  .toBeVisible(); // Checks actual visibility
```

❌ **Don't** use visibility for existence checks:
```typescript
// Avoid when element should exist but may be hidden
await expect(page.getByTestId('dropdown-menu'))
  .toBeVisible(); // Fails if legitimately hidden
// Use
await expect(page.getByTestId('dropdown-menu'))
  .toBeAttached(); // Correct for "exists in DOM"
```

❌ **Don't** combine with unnecessary waits:
```typescript
// Avoid
await page.waitForSelector('#button', { state: 'visible' });
await expect(page.locator('#button')).toBeVisible();
// Use
await expect(page.locator('#button')).toBeVisible();
// Or set longer timeout
await expect(page.locator('#button'))
  .toBeVisible({ timeout: 10000 });
```

## Best Practices

1. **Assert visibility after actions** - Verify expected UI state changes
2. **Use appropriate timeouts** - Set reasonable limits for dynamic content
3. **Consider viewport** - Elements may exist but be off-screen
4. **Distinguish states** - Know when to check `attached` vs `visible`
5. **Negate carefully** - Use `not.toBeVisible()` to confirm hidden state

## Common Scenarios

### Modal appears
```typescript
await page.getByRole('button', { name: 'Open' }).click();
await expect(page.getByRole('dialog')).toBeVisible();
```

### Loading completes
```typescript
await page.getByRole('button', { name: 'Submit' }).click();
await expect(page.getByTestId('loading')).not.toBeVisible();
await expect(page.getByTestId('success')).toBeVisible();
```

### Conditional content
```typescript
const isAdmin = await page.evaluate(() => window.user.isAdmin);
if (isAdmin) {
  await expect(page.getByRole('button', { name: 'Delete' }))
    .toBeVisible();
} else {
  await expect(page.getByRole('button', { name: 'Delete' }))
    .not.toBeVisible();
}
```

## Related Skills

- [find-by-role](../locators/find-by-role.skill.md) - Locate elements for assertion
- [find-by-testid](../locators/find-by-testid.skill.md) - Alternative locator
- [wait-for-visible](../waits/wait-for-visible.skill.md) - Wait before asserting
- [assert-text](./assert-text.skill.md) - Verify element content
