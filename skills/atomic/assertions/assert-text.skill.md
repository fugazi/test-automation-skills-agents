---
name: 'assert-text'
description: 'Verify that an element contains expected text content, supporting exact match, partial match, and regex patterns'
version: '1.0.0'
type: 'atomic'
category: 'assertions'

activation: 'implicit'
aliases: ['assert-text-content', 'verify-text', 'check-text', 'has-text', 'contains-text']

requires:
  knowledge: ['text content vs innerText', 'regex patterns', 'text normalization']
  tools: ['@playwright/test', 'selenium', 'webdriverio']

output:
  format: 'code'

success-criteria:
  - Element contains the expected text
  - Text comparison mode matches requirements (exact, partial, regex)
  - Assertion fails appropriately when text is missing or incorrect
---

## Purpose

Assert that an element's text content matches expected values. This is fundamental for verifying that applications display correct information to users.

## When to Use

- Verifying user-facing messages and labels
- Confirming form input values
- Checking dynamic content (prices, dates, user names)
- Validating error and success messages
- Testing internationalized content

## Text Matching Modes

| Mode | Use Case |
|------|----------|
| Exact | Complete text must match precisely |
| Partial | Text contains the specified substring |
| Regex | Pattern matching for dynamic values |
| Ignore case | Case-insensitive text comparison |

## Playwright Examples

### Exact text match
```typescript
await expect(page.getByRole('heading'))
  .toHaveText('Welcome to Dashboard');
```

### Partial text match
```typescript
await expect(page.getByTestId('status'))
  .toContainText('completed');
```

### Regular expression
```typescript
// Match pattern
await expect(page.getByTestId('order-total'))
  .toHaveText(/\$\d+\.\d{2}/);

// Match with word boundaries
await expect(page.getByTestId('email'))
  .toHaveText(/[\w.]+@[\w.]+\.\w+/);
```

### Multiple elements
```typescript
// All list items contain text
await expect(page.getByTestId('item-name'))
  .toHaveText(['Apple', 'Banana', 'Orange']);
```

### Using filter with text
```typescript
const button = page.getByRole('button')
  .filter({ hasText: 'Submit' });
await expect(button).toBeVisible();
```

### Text content vs innerText
```typescript
// TextContent includes hidden text
await expect(page.locator('.element'))
  .toHaveText('Hidden and visible');

// InnerText only includes visible text
const visibleText = await page.locator('.element')
  .evaluate(el => el.innerText);
```

## Selenium Examples

### Exact text match
```java
WebElement heading = driver.findElement(By.tagName("h1"));
assertEquals("Welcome to Dashboard", heading.getText());
```

### Partial text match
```java
String statusText = driver.findElement(By.id("status")).getText();
assertTrue(statusText.contains("completed"));
```

### Regular expression
```java
String orderTotal = driver.findElement(By.id("order-total")).getText();
assertTrue(orderTotal.matches("\\$\\d+\\.\\d{2}"));
```

### Using contains in XPath
```java
// Find element containing text
WebElement button = driver.findElement(
    By.xpath("//button[contains(text(), 'Submit')]")
);

// Exact text match in XPath
WebElement heading = driver.findElement(
    By.xpath("//h1[text()='Welcome to Dashboard']")
);
```

### Normalize whitespace
```java
String text = element.getText().trim().replaceAll("\\s+", " ");
assertEquals("Expected text", text);
```

## WebdriverIO Examples

```javascript
// Exact match
await expect($('#heading')).toHaveText('Welcome');

// Partial match
await expect($('#status')).toHaveTextContaining('completed');

// Regex
await expect($('#price')).toHaveText(/\$\d+\.\d{2}/);

// Case insensitive
await expect($('#message')).toHaveText(expect.stringMatching(/success/i));
```

## Anti-Patterns

❌ **Don't** test dynamic content with exact matches:
```typescript
// Avoid - time-sensitive
await expect(page.getByTestId('timestamp'))
  .toHaveText('2024-01-15 10:30:45');

// Prefer - pattern match
await expect(page.getByTestId('timestamp'))
  .toHaveText(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/);
```

❌ **Don't** include unnecessary whitespace:
```typescript
// Avoid - fragile to formatting changes
await expect(page.getByRole('heading'))
  .toHaveText(`
    Welcome
    to
    Dashboard
  `);

// Prefer - normalized text
await expect(page.getByRole('heading'))
  .toHaveText('Welcome to Dashboard');
```

❌ **Don't** test CSS content via text assertions:
```typescript
// Avoid - tests implementation details
await expect(page.locator('.icon'))
  .toHaveText('×'); // CSS pseudo-element

// Prefer - test visible behavior
await expect(page.getByRole('button', { name: 'Close' }))
  .toBeVisible();
```

❌ **Don't** assert on entire page text:
```typescript
// Avoid - too broad and fragile
await expect(page.locator('body'))
  .toContainText('some text');
```

## Best Practices

1. **Prefer specific elements** - Target elements with expected text
2. **Use regex for patterns** - Match dynamic values (dates, IDs, prices)
3. **Consider i18n** - Account for translations if applicable
4. **Normalize when needed** - Handle whitespace variations
5. **Combine with role** - Use role locators with text filters

## Common Scenarios

### Form validation messages
```typescript
await page.getByTestId('email-input').fill('invalid-email');
await page.getByRole('button', { name: 'Submit' }).click();
await expect(page.getByTestId('email-error'))
  .toHaveText('Please enter a valid email address');
```

### Dynamic data (user-specific)
```typescript
// Using regex for user name pattern
await expect(page.getByTestId('welcome-message'))
  .toHaveText(/Welcome, \w+/);
```

### Status updates
```typescript
await page.getByRole('button', { name: 'Process' }).click();
await expect(page.getByTestId('status'))
  .toHaveText('Processing...');

await expect(page.getByTestId('status'))
  .not.toHaveText('Processing...');
await expect(page.getByTestId('status'))
  .toHaveText(/completed|failed/);
```

### Currency formatting
```typescript
await expect(page.getByTestId('total-price'))
  .toHaveText(/\$\d{1,3}(,\d{3})*(\.\d{2})?/);
```

## Text Comparison Considerations

### Hidden elements
- `textContent`: Includes text from hidden descendants
- `innerText`: Only visible text (respecting CSS)
- Framework defaults vary - check documentation

### Whitespace handling
```typescript
// Playwright normalizes whitespace by default
await expect(element).toHaveText('normalized text');

// For exact whitespace preservation
await expect(element).toHaveText('exact  whitespace  ', { exact: true });
```

### HTML entities
```typescript
// Frameworks decode entities automatically
await expect(page.getByRole('heading'))
  .toHaveText('Copyright & Trademark'); // Matches &copy; &trade;
```

## Related Skills

- [find-by-role](../locators/find-by-role.skill.md) - Locate elements by role and text
- [assert-visible](./assert-visible.skill.md) - Verify element visibility before text check
- [wait-for-visible](../waits/wait-for-visible.skill.md) - Ensure element is ready
