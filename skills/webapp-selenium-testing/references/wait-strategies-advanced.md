# Wait Strategies Advanced Control

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original wait-strategies.md. See the other related files in this folder.

## FluentWait for Advanced Control

```java
import org.openqa.selenium.support.ui.FluentWait;

// FluentWait with custom configuration
Wait<WebDriver> fluentWait = new FluentWait<>(driver)
    .withTimeout(Duration.ofSeconds(30))
    .pollingEvery(Duration.ofMillis(500))
    .ignoring(NoSuchElementException.class)
    .ignoring(StaleElementReferenceException.class)
    .withMessage("Element not found within timeout");

WebElement element = fluentWait.until(
    ExpectedConditions.elementToBeClickable(By.id("dynamic-button"))
);
```

### Ignoring Multiple Exceptions

```java
Wait<WebDriver> robustWait = new FluentWait<>(driver)
    .withTimeout(Duration.ofSeconds(30))
    .pollingEvery(Duration.ofMillis(250))
    .ignoring(NoSuchElementException.class)
    .ignoring(StaleElementReferenceException.class)
    .ignoring(ElementNotInteractableException.class)
    .ignoring(ElementClickInterceptedException.class);
```

---

## Implicit vs Explicit Waits

### Comparison

| Aspect      | Implicit Wait            | Explicit Wait              |
| ----------- | ------------------------ | -------------------------- |
| Scope       | Global (all findElement) | Specific element/condition |
| Flexibility | One size fits all        | Customizable per situation |
| Conditions  | Only presence            | Any condition              |
| Recommended | [no] Avoid                 | [ok] Prefer                  |

### Why Avoid Implicit Waits

```java
// [no] Don't mix implicit and explicit waits
driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(10));

// This can cause unexpected behavior:
// - Explicit wait timeout + implicit wait timeout = unpredictable delays
// - Can mask real issues with slow loading
```

### If You Must Use Implicit Wait

```java
// Set a short implicit wait for basic element finding
driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(2));

// Use explicit waits for specific conditions
WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
wait.until(ExpectedConditions.elementToBeClickable(By.id("submit")));
```

---

## Handling Timeout Exceptions

```java
@Step("Click element if present")
protected boolean clickIfPresent(By locator, Duration timeout) {
    try {
        WebDriverWait wait = new WebDriverWait(driver, timeout);
        wait.until(ExpectedConditions.elementToBeClickable(locator)).click();
        return true;
    } catch (TimeoutException e) {
        log.warn("Element not clickable within timeout: {}", locator);
        return false;
    }
}

@Step("Get text or default")
protected String getTextOrDefault(By locator, String defaultValue) {
    try {
        return shortWait.until(ExpectedConditions.visibilityOfElementLocated(locator)).getText();
    } catch (TimeoutException e) {
        return defaultValue;
    }
}
```

---
