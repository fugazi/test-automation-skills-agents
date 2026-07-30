# Axe Patterns: Common Tags Reference and Test Patterns

> Part of the `accessibility-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original axe-patterns.md. See the other related files in this folder.

## Common Axe Tags Reference

### WCAG Tags

| Tag             | Standard | Level     |
| --------------- | -------- | --------- |
| `wcag2a`        | WCAG 2.0 | Level A   |
| `wcag2aa`       | WCAG 2.0 | Level AA  |
| `wcag2aaa`      | WCAG 2.0 | Level AAA |
| `wcag21a`       | WCAG 2.1 | Level A   |
| `wcag21aa`      | WCAG 2.1 | Level AA  |
| `wcag21aaa`     | WCAG 2.1 | Level AAA |
| `wcag22aa`      | WCAG 2.2 | Level AA  |
| `best-practice` | Deque    | Industry  |

### Common Rule IDs

| Rule ID             | What it checks               |
| ------------------- | ---------------------------- |
| `color-contrast`    | Text contrast ratio          |
| `image-alt`         | Images have alt text         |
| `label`             | Form inputs have labels      |
| `button-name`       | Buttons have accessible name |
| `link-name`         | Links have accessible name   |
| `heading-order`     | Heading hierarchy            |
| `landmark-one-main` | Single main landmark         |
| `region`            | Content in landmarks         |
| `aria-valid-attr`   | Valid ARIA attributes        |
| `aria-roles`        | Valid ARIA roles             |

---

## Test Patterns

### Page-Level Test

```java
@Test
@Tag("a11y")
@Severity(SeverityLevel.CRITICAL)
@DisplayName("Homepage should be WCAG 2.1 AA compliant")
void homePage_shouldBeAccessible() {
    driver.get(baseUrl);
    waitForPageReady();

    AccessibilityHelper.verifyPageAccessibility(driver);
}
```

### Modal/Component Test

```java
@Test
@Tag("a11y")
@DisplayName("Login modal should be accessible")
void loginModal_shouldBeAccessible() {
    driver.get(baseUrl);

    // Open modal
    driver.findElement(By.id("login-btn")).click();
    wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("login-modal")));

    // Scan only the modal
    AccessibilityHelper.verifyComponentAccessibility(driver, "#login-modal");
}
```

### Multiple Pages Test

```java
@ParameterizedTest
@ValueSource(strings = {"/", "/about", "/contact", "/products"})
@Tag("a11y")
@DisplayName("All pages should be accessible")
void allPages_shouldBeAccessible(String path) {
    driver.get(baseUrl + path);
    waitForPageReady();

    AccessibilityHelper.verifyPageAccessibility(driver);
}
```

### Form States Test

```java
@Test
@Tag("a11y")
@DisplayName("Form error state should be accessible")
void formErrors_shouldBeAccessible() {
    driver.get(baseUrl + "/register");

    // Submit empty form to trigger errors
    driver.findElement(By.cssSelector("button[type='submit']")).click();
    wait.until(ExpectedConditions.visibilityOfElementLocated(By.className("error-message")));

    // Verify error state accessibility
    AccessibilityHelper.verifyPageAccessibility(driver);
}
```

### CI Threshold Test

```java
@Test
@Tag("a11y")
@Tag("ci")
@DisplayName("No critical accessibility violations allowed")
void page_shouldHaveNoCriticalViolations() {
    driver.get(baseUrl);
    waitForPageReady();

    // Only fail on critical/serious - warn on others
    AccessibilityHelper.verifyCriticalAccessibility(driver);
}
```

---
