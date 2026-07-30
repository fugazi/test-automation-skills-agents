# Axe Patterns: Keyboard Navigation Testing and CI/CD Integration

> Part of the `accessibility-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original axe-patterns.md. See the other related files in this folder.

## Keyboard Navigation Testing

```java
/**
 * Test keyboard accessibility for interactive elements.
 */
public class KeyboardAccessibilityHelper {

    /**
     * Verify an element is reachable via Tab key.
     */
    @Step("Verify element is keyboard accessible: {targetSelector}")
    public static void verifyKeyboardReachable(WebDriver driver, String targetSelector, int maxTabs) {
        WebElement body = driver.findElement(By.tagName("body"));
        WebElement target = driver.findElement(By.cssSelector(targetSelector));

        // Start from body
        body.click();

        for (int i = 0; i < maxTabs; i++) {
            body.sendKeys(Keys.TAB);
            WebElement focused = driver.switchTo().activeElement();

            if (focused.equals(target)) {
                log.info("Element {} reached after {} tab(s)", targetSelector, i + 1);
                return;
            }
        }

        throw new AssertionError("Element " + targetSelector + " not reachable via Tab within " + maxTabs + " presses");
    }

    /**
     * Verify focus trap in modal.
     */
    @Step("Verify focus trap in: {modalSelector}")
    public static void verifyFocusTrap(WebDriver driver, String modalSelector, int maxTabs) {
        WebElement modal = driver.findElement(By.cssSelector(modalSelector));
        List<WebElement> focusableElements = modal.findElements(
            By.cssSelector("button, [href], input, select, textarea, [tabindex]:not([tabindex='-1'])")
        );

        assertThat(focusableElements).as("Modal should have focusable elements").isNotEmpty();

        // Tab through all elements to verify focus stays in modal
        WebElement firstElement = focusableElements.getFirst();
        firstElement.click();

        for (int i = 0; i < maxTabs; i++) {
            driver.switchTo().activeElement().sendKeys(Keys.TAB);
            WebElement focused = driver.switchTo().activeElement();

            assertThat(isDescendantOf(focused, modal))
                .as("Focus should stay within modal after Tab #%d", i + 1)
                .isTrue();
        }
    }

    /**
     * Verify Escape key closes modal.
     */
    @Step("Verify Escape closes: {modalSelector}")
    public static void verifyEscapeCloses(WebDriver driver, String modalSelector) {
        WebElement modal = driver.findElement(By.cssSelector(modalSelector));
        assertThat(modal.isDisplayed()).as("Modal should be visible initially").isTrue();

        modal.sendKeys(Keys.ESCAPE);

        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(2));
        wait.until(ExpectedConditions.invisibilityOf(modal));
    }

    private static boolean isDescendantOf(WebElement element, WebElement container) {
        try {
            return container.findElements(By.xpath(".//*")).contains(element) ||
                   container.equals(element);
        } catch (Exception e) {
            return false;
        }
    }
}
```

---

## CI/CD Integration Example

### GitHub Actions

```yaml
name: Accessibility Tests

on: [push, pull_request]

jobs:
  a11y:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: "21"
          distribution: "temurin"

      - name: Run Accessibility Tests
        run: |
          mvn test -Dgroups=a11y -Dheadless=true

      - name: Upload A11y Report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: a11y-results
          path: |
            target/a11y-results/
            target/allure-results/
```

### JUnit Platform Properties

```properties
# src/test/resources/junit-platform.properties

# Run a11y tests in parallel (different pages)
junit.jupiter.execution.parallel.enabled=true
junit.jupiter.execution.parallel.mode.default=same_thread
junit.jupiter.execution.parallel.mode.classes.default=concurrent
junit.jupiter.execution.parallel.config.strategy=dynamic
```
