---
name: 'find-by-testid'
description: 'Locate web elements using dedicated test ID attributes, providing implementation-specific selectors when accessibility-based locators are insufficient'
version: '1.0.0'
type: 'atomic'
category: 'locators'

activation: 'implicit'
aliases: ['get-by-testid', 'locate-by-data-testid', 'data-test-selector', 'qa-id']

requires:
  knowledge: ['test ID attributes', 'data-testid convention', 'testing hooks']
  tools: ['@playwright/test', 'selenium']

output:
  format: 'code'

success-criteria:
  - Element is uniquely and reliably identified
  - Test IDs are intentionally added for testing purposes
  - Selector remains stable across styling and structural changes
---

## Purpose

Locate elements using dedicated testing attributes (typically `data-testid` or `data-test-id`) when accessibility-based selectors cannot be used. This serves as a fallback strategy for elements that lack proper semantic markup.

## When to Use

- **Fallback** when role-based locators are not feasible
- For elements with no clear user-visible text or ARIA attributes
- When working with legacy code lacking accessibility attributes
- For purely decorative elements that still need test interaction
- When team convention requires test IDs for all interactable elements

## Playwright Examples

### Basic test ID locator
```typescript
await page.getByTestId('submit-button').click();
```

### Chaining with filters
```typescript
const menuItem = page.getByTestId('menu-item')
  .filter({ hasText: 'Settings' });
```

### Within a container
```typescript
const container = page.getByTestId('user-profile');
const name = container.getByTestId('user-name');
```

### Form with multiple test IDs
```typescript
await page.getByTestId('email-input').fill('user@example.com');
await page.getByTestId('password-input').fill('secret123');
await page.getByTestId('login-button').click();
```

### Custom test ID attribute
```typescript
// Configure custom attribute
const testIdAttribute = 'data-qa';

await page.locator(`[data-qa="submit-btn"]`).click();
```

## Selenium Examples

### Basic data-testid selector
```java
WebElement button = driver.findElement(
    By.cssSelector("[data-testid='submit-button']")
);
button.click();
```

### Using XPath
```java
WebElement element = driver.findElement(
    By.xpath("//*[@data-testid='user-email']")
);
```

### Chaining with parent context
```java
WebElement form = driver.findElement(By.cssSelector("[data-testid='login-form']"));
WebElement input = form.findElement(By.cssSelector("[data-testid='username']"));
input.sendKeys("testuser");
```

### Waiting for test ID element
```java
WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
WebElement button = wait.until(
    ExpectedConditions.presenceOfElementLocated(
        By.cssSelector("[data-testid='confirm-button']")
    )
);
```

## Test ID Conventions

### Recommended prefixes by element type
| Element Type | Example Test ID |
|--------------|-----------------|
| Buttons | `submit-button`, `cancel-btn` |
| Inputs | `email-input`, `username-field` |
| Links | `home-link`, `profile-nav` |
| Containers | `login-form`, `user-card` |
| Text elements | `error-message`, `welcome-text` |

### Naming best practices
```html
<!-- Good: Descriptive and specific -->
<button data-testid="login-submit-button">Submit</button>
<input data-testid="checkout-email-input" />

<!-- Avoid: Generic or unclear -->
<button data-testid="button1">Submit</button>
<input data-testid="input" />
```

## Anti-Patterns

❌ **Don't** use test IDs as first choice:
```typescript
// Avoid if role is available
await page.getByTestId('submit').click();
// Prefer
await page.getByRole('button', { name: 'Submit' }).click();
```

❌ **Don't** use auto-generated or non-semantic IDs:
```html
<!-- Avoid -->
<button data-testid="btn-847238">Submit</button>
<button data-testid="Component_Button_1">Submit</button>
```

❌ **Don't** couple test IDs to CSS:
```html
<!-- Avoid -->
<button data-testid="btn-primary" class="btn-primary">Submit</button>
```

❌ **Don't** use test IDs for user-facing text validation:
```typescript
// Avoid
await expect(page.getByTestId('title'))
  .toHaveText('Welcome');
// Prefer role for text assertions
await expect(page.getByRole('heading', { level: 1 }))
  .toHaveText('Welcome');
```

## Best Practices

1. **Establish team conventions** - Define consistent naming patterns
2. **Document the attribute name** - Agree on `data-testid` vs `data-test-id` vs `data-qa`
3. **Scope to necessary elements** - Don't add test IDs to every element
4. **Keep IDs stable** - Don't change test IDs during refactors unless necessary
5. **Consider automation** - Generate test IDs via build tools for large projects

## Implementation Guidance

### Adding test IDs to components
```typescript
// React component example
function SubmitButton({ testId = 'submit-button' }) {
  return (
    <button data-testid={testId} type="submit">
      Submit
    </button>
  );
}

// Usage with override
<SubmitButton testId="login-submit" />
```

### Custom Playwright configuration
```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    testIdAttribute: 'data-qa', // Custom attribute
  },
});
```

## Related Skills

- [find-by-role](./find-by-role.skill.md) - Preferred accessibility-first locator
- [assert-visible](../assertions/assert-visible.skill.md) - Verify located elements
- [click-safe](../interactions/click-safe.skill.md) - Safe interaction patterns
- [fill-form](../interactions/fill-form.skill.md) - Form interaction patterns
