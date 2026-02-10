---
name: 'find-by-role'
description: 'Locate web elements using their ARIA role and accessible name, following accessibility-first testing principles'
version: '1.0.0'
type: 'atomic'
category: 'locators'

activation: 'implicit'
aliases: ['get-by-role', 'locate-by-aria', 'aria-locator', 'accessible-locator']

requires:
  knowledge: ['ARIA roles', 'accessibility tree', 'accessible names']
  tools: ['@playwright/test', 'selenium']

output:
  format: 'code'

success-criteria:
  - Element is uniquely identified using role and name
  - Locator reflects how users interact with the element
  - Selector remains stable across UI changes
---

## Purpose

Locate elements by their semantic role and accessible name, promoting tests that align with how users perceive and interact with the application. This approach yields more resilient and accessible tests.

## When to Use

- **Primary choice** for all interactive elements (buttons, links, form inputs)
- When elements have proper ARIA roles or semantic HTML
- When testing user-facing interactions rather than implementation details
- When you want tests that survive CSS class and structure changes

## Playwright Examples

### Basic button click
```typescript
await page.getByRole('button', { name: 'Submit' }).click();
```

### Locate by exact name
```typescript
await page.getByRole('button', { name: 'Save', exact: true }).click();
```

### Locate heading
```typescript
const heading = page.getByRole('heading', { name: 'Welcome' });
await expect(heading).toBeVisible();
```

### Form controls
```typescript
await page.getByRole('textbox', { name: 'Email' }).fill('user@example.com');
await page.getByRole('checkbox', { name: 'Agree to terms' }).check();
```

### Filtered by level (headings)
```typescript
const mainHeading = page.getByRole('heading', { level: 1, name: 'Dashboard' });
```

### Combined with filters
```typescript
const deleteButton = page.getByRole('button', { name: /delete/i })
  .filter({ hasText: 'Confirm' });
```

## Selenium Examples

### Basic role-based locator (requires custom helper)
```java
// Selenium doesn't have built-in role locators; use with accessibility helper
WebElement button = driver.findElement(By.cssSelector("[role='button'][aria-label='Submit']"));
```

### Recommended Selenium approach with XPath
```java
// Button by accessible name
WebElement button = driver.findElement(
    By.xpath("//button[contains(text(), 'Submit')]")
);

// Using ARIA attributes
WebElement dialog = driver.findElement(
    By.xpath("//div[@role='dialog' and @aria-labelledby='modal-title']")
);
```

## ARIA Roles Reference

Common roles to use:
| Role | Usage |
|------|-------|
| `button` | Buttons, submit inputs |
| `link` | Anchor tags |
| `textbox` | Input[type=text], textarea |
| `checkbox` | Input[type=checkbox] |
| `radio` | Input[type=radio] |
| `combobox` | Select dropdowns |
| `listbox` | Select with multiple |
| `menuitem` | Menu items |
| `tab` | Tab buttons |
| `heading` | h1-h6 elements |
| `alert` | Alert/toast notifications |
| `dialog` | Modal dialogs |

## Anti-Patterns

❌ **Don't** use role selectors when semantic HTML exists:
```typescript
// Avoid
await page.locator('[role="button"]').click();
// Prefer
await page.getByRole('button').click();
```

❌ **Don't** over-specify when name is sufficient:
```typescript
// Avoid
await page.getByRole('button', { name: 'Submit', exact: true }).click();
// Use exact only when needed for partial match conflicts
```

❌ **Don't** use role for non-interactive elements:
```typescript
// Avoid
await page.getByRole('div').click(); // div is not a valid role
```

❌ **Don't** combine with fragile selectors:
```typescript
// Avoid
await page.getByRole('button', { name: 'Submit' })
  .locator('.btn-primary')
  .click();
```

## Best Practices

1. **Role first, name second** - Use role as primary identifier, name for disambiguation
2. **Prefer user-visible text** - Use labels, placeholders, or visible text over aria-label when possible
3. **Be specific with roles** - Use `radio` instead of `input`, `textbox` instead of generic `input`
4. **Leverage hierarchy** - Use `level` for headings, `checked` for checkboxes

## Related Skills

- [find-by-testid](./find-by-testid.skill.md) - When elements lack proper roles
- [assert-visible](../assertions/assert-visible.skill.md) - Verify located elements
- [click-safe](../interactions/click-safe.skill.md) - Safe interaction patterns
- [wait-for-visible](../waits/wait-for-visible.skill.md) - Ensure element readiness
