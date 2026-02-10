---
name: 'fill-form'
description: 'Safely fill multiple form fields with proper interaction patterns, handling various input types and clearing existing values'
version: '1.0.0'
type: 'atomic'
category: 'interactions'

activation: 'implicit'
aliases: ['fill-inputs', 'complete-form', 'form-filling', 'populate-form', 'enter-form-data']

requires:
  knowledge: ['form input types', 'value clearing strategies', 'input events', 'form validation']
  tools: ['@playwright/test', 'selenium', 'webdriverio']

output:
  format: 'code'

success-criteria:
  - All form fields are populated with correct values
  - Existing values are properly cleared
  - Form validation passes (if applicable)
  - Values are visible in the inputs after filling
---

## Purpose

Efficiently and reliably fill form fields with test data, ensuring proper interaction with various input types while avoiding common pitfalls like incomplete clearing or triggering premature validation.

## When to Use

- Populating user registration/login forms
- Filling out search/filter forms
- Testing form validation with various inputs
- Data entry scenarios
- Multi-field form completion

## Playwright Examples

### Basic form filling
```typescript
await page.getByRole('textbox', { name: 'Email' })
  .fill('user@example.com');
await page.getByRole('textbox', { name: 'Password' })
  .fill('securePassword123');
await page.getByRole('button', { name: 'Sign In' })
  .click();
```

### Multiple fields sequentially
```typescript
await page.getByLabel('First Name').fill('John');
await page.getByLabel('Last Name').fill('Doe');
await page.getByLabel('Email').fill('john.doe@example.com');
await page.getByLabel('Phone').fill('555-123-4567');
```

### Fill with clear option
```typescript
// fill() automatically clears existing values
await page.getByRole('textbox', { name: 'Username' })
  .fill('newuser');
```

### Fill and verify
```typescript
await page.getByRole('textbox', { name: 'Email' })
  .fill('user@example.com');
await expect(page.getByRole('textbox', { name: 'Email' }))
  .toHaveValue('user@example.com');
```

### Select dropdowns
```typescript
// Using select option
await page.getByRole('combobox', { name: 'Country' })
  .selectOption('United States');

// Using label
await page.getByRole('combobox', { name: 'Country' })
  .selectOption({ label: 'United States' });

// Using value
await page.getByRole('combobox', { name: 'Country' })
  .selectOption({ value: 'us' });
```

### Checkboxes and radio buttons
```typescript
// Checkbox
await page.getByRole('checkbox', { name: 'Agree to terms' })
  .check();

// Uncheck
await page.getByRole('checkbox', { name: 'Subscribe' })
  .uncheck();

// Radio button
await page.getByRole('radio', { name: 'Credit Card' })
  .check();
```

### File uploads
```typescript
await page.getByLabel('Resume')
  .setInputFiles('/path/to/resume.pdf');
```

### Complete form example
```typescript
async function fillRegistrationForm(page, userData) {
  await page.getByRole('textbox', { name: 'Email' })
    .fill(userData.email);
  await page.getByRole('textbox', { name: 'Password' })
    .fill(userData.password);
  await page.getByRole('textbox', { name: 'Confirm Password' })
    .fill(userData.password);
  await page.getByRole('checkbox', { name: 'Agree to terms' })
    .check();
  await page.getByRole('button', { name: 'Create Account' })
    .click();
}
```

## Selenium Examples

### Basic form filling
```java
// Text inputs
driver.findElement(By.id("email")).sendKeys("user@example.com");
driver.findElement(By.id("password")).sendKeys("password123");

// Clear before filling
WebElement emailInput = driver.findElement(By.id("email"));
emailInput.clear();
emailInput.sendKeys("newemail@example.com");
```

### Using Actions class for precise control
```java
Actions actions = new Actions(driver);
WebElement emailField = driver.findElement(By.id("email"));

actions.click(emailField)
       .keyDown(Keys.CONTROL)
       .sendKeys("a")
       .keyUp(Keys.CONTROL)
       .sendKeys("newemail@example.com")
       .perform();
```

### Select dropdowns
```java
// Using Select class
Select countryDropdown = new Select(
    driver.findElement(By.id("country"))
);
countryDropdown.selectByVisibleText("United States");
countryDropdown.selectByValue("us");
countryDropdown.selectByIndex(0);
```

### Checkboxes and radio buttons
```java
// Check checkbox (if not already checked)
WebElement checkbox = driver.findElement(By.id("terms"));
if (!checkbox.isSelected()) {
    checkbox.click();
}

// Radio button
WebElement creditCardOption = driver.findElement(
    By.cssSelector("input[type='radio'][value='credit-card']")
);
creditCardOption.click();
```

### File uploads
```java
WebElement fileInput = driver.findElement(By.id("resume"));
fileInput.sendKeys("/absolute/path/to/resume.pdf");
```

### Form filling helper
```java
public void fillForm(Map<String, String> formData) {
    for (Map.Entry<String, String> entry : formData.entrySet()) {
        String fieldId = entry.getKey();
        String value = entry.getValue();

        WebElement field = driver.findElement(By.id(fieldId));
        field.clear();
        field.sendKeys(value);
    }
}

// Usage
Map<String, String> userData = new HashMap<>();
userData.put("firstName", "John");
userData.put("lastName", "Doe");
userData.put("email", "john@example.com");
fillForm(userData);
```

## WebdriverIO Examples

```javascript
// Basic fill
await $('#email').setValue('user@example.com');
await $('#password').setValue('password123');

// Clear and fill
await $('#email').clearValue();
await $('#email').setValue('newemail@example.com');

// Add value (append)
await $('#comments').addValue('Additional text');

// Select dropdown
await $('#country').selectByVisibleText('United States');
await $('#country').selectByAttribute('value', 'us');

// Checkbox
await $('#terms').click();
await expect($('#terms')).toBeChecked();

// Multiple fields
await $('input[name="firstName"]').setValue('John');
await $('input[name="lastName"]').setValue('Doe');
await $('input[name="email"]').setValue('john@example.com');
```

## Input Type Handling

| Input Type | Recommended Approach |
|------------|---------------------|
| `text` | `fill()` / `sendKeys()` |
| `email` | `fill()` / `sendKeys()` |
| `password` | `fill()` / `sendKeys()` |
| `number` | `fill()` / `sendKeys()` |
| `tel` | `fill()` / `sendKeys()` |
| `textarea` | `fill()` / `sendKeys()` |
| `select` | `selectOption()` |
| `checkbox` | `check()` / `uncheck()` |
| `radio` | `check()` |
| `file` | `setInputFiles()` |
| `date` | `fill()` with ISO format |
| `datetime-local` | `fill()` with ISO format |

## Anti-Patterns

❌ **Don't** type character-by-character unnecessarily:
```typescript
// Avoid - slower and potentially triggers validation
await page.locator('#email').type('u', { delay: 50 });
await page.locator('#email').type('s', { delay: 50 });
// ... etc

// Prefer
await page.getByRole('textbox', { name: 'Email' })
  .fill('user@example.com');
```

❌ **Don't** forget to clear existing values:
```java
// Avoid - appends to existing value
emailField.sendKeys("newvalue@example.com");

// Prefer
emailField.clear();
emailField.sendKeys("newvalue@example.com");
```

❌ **Don't** click before filling (unless necessary):
```typescript
// Avoid - unnecessary
await page.getByRole('textbox', { name: 'Email' }).click();
await page.getByRole('textbox', { name: 'Email' }).fill('user@example.com');

// Prefer
await page.getByRole('textbox', { name: 'Email' })
  .fill('user@example.com');
```

❌ **Don't** fill disabled/readonly fields:
```typescript
// Avoid - will fail
await page.getByRole('textbox', { name: 'Disabled' })
  .fill('value');

// Prefer - verify enabled state first
await expect(page.getByRole('textbox', { name: 'Email' }))
  .toBeEnabled();
await page.getByRole('textbox', { name: 'Email' }).fill('user@example.com');
```

## Best Practices

1. **Clear before fill** - Ensure no residual values remain
2. **Use semantic locators** - Fill by label/role, not CSS
3. **Verify after fill** - Assert values are correct
4. **Handle validation** - Account for real-time validation feedback
5. **Group related actions** - Keep form fields together logically

## Common Scenarios

### Login form
```typescript
await page.getByRole('textbox', { name: /email|username/i })
  .fill('user@example.com');
await page.getByRole('textbox', { name: 'password' })
  .fill('password123');
await page.getByRole('button', { name: /sign in|log in/i })
  .click();
```

### Registration with validation
```typescript
await page.getByLabel('Email').fill('invalid-email');
await page.getByRole('button', { name: 'Submit' }).click();
await expect(page.getByTestId('email-error'))
  .toHaveText(/valid email/i);

await page.getByLabel('Email').fill('user@example.com');
await page.getByRole('button', { name: 'Submit' }).click();
```

### Search/filter form
```typescript
await page.getByRole('textbox', { name: 'Search' })
  .fill('laptop');
await page.getByRole('combobox', { name: 'Category' })
  .selectOption('Electronics');
await page.getByRole('spinbutton', { name: 'Min Price' })
  .fill('100');
await page.getByRole('spinbutton', { name: 'Max Price' })
  .fill('1000');
await page.getByRole('button', { name: 'Apply Filters' })
  .click();
```

### Dynamic form fields
```typescript
// Fill variable number of fields
const tags = ['javascript', 'testing', 'automation'];
for (const tag of tags) {
  await page.getByRole('textbox', { name: 'Add Tag' })
    .fill(tag);
  await page.getByRole('button', { name: 'Add' })
    .click();
}
```

### Date inputs
```typescript
// ISO 8601 format for date inputs
await page.getByRole('textbox', { name: 'Start Date' })
  .fill('2024-01-15');

// DateTime local
await page.getByRole('textbox', { name: 'Appointment' })
  .fill('2024-01-15T14:30');
```

## Related Skills

- [find-by-role](../locators/find-by-role.skill.md) - Locate form fields by role
- [find-by-testid](../locators/find-by-testid.skill.md) - Alternative form field locator
- [click-safe](./click-safe.skill.md) - Submit form safely
- [assert-text](../assertions/assert-text.skill.md) - Verify input values
