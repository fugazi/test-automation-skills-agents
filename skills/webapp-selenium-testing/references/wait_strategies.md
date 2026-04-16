````markdown
# Wait Strategies Guide for Selenium WebDriver (Java)

Comprehensive guide for implementing proper synchronization in Selenium tests using explicit waits.

---

## The Golden Rule

> **NEVER use `Thread.sleep()`** - Always use explicit waits with `WebDriverWait` and `ExpectedConditions`.

### Why Thread.sleep() is Bad

| Problem            | Impact                                   |
| ------------------ | ---------------------------------------- |
| Fixed delay        | Wastes time when element is ready sooner |
| Flaky tests        | Still fails if element takes longer      |
| No condition check | Just waits blindly                       |
| Unpredictable      | Different machines have different speeds |
| Hard to maintain   | Magic numbers everywhere                 |

```java
// ❌ NEVER DO THIS
Thread.sleep(3000);
element.click();

// ✅ ALWAYS DO THIS
wait.until(ExpectedConditions.elementToBeClickable(element)).click();
```

---

## WebDriverWait Setup

### Basic Configuration

```java
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;
import java.time.Duration;

// Standard wait with 15 second timeout
WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));

// With custom polling interval (default is 500ms)
WebDriverWait wait = new WebDriverWait(
    driver,
    Duration.ofSeconds(15),      // timeout
    Duration.ofMillis(250)       // polling interval
);
```

### In BasePage Class

```java
public abstract class BasePage {
    protected final WebDriver driver;
    protected final WebDriverWait wait;
    protected final WebDriverWait shortWait;
    protected final WebDriverWait longWait;

    private static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(15);
    private static final Duration SHORT_TIMEOUT = Duration.ofSeconds(5);
    private static final Duration LONG_TIMEOUT = Duration.ofSeconds(30);

    protected BasePage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, DEFAULT_TIMEOUT);
        this.shortWait = new WebDriverWait(driver, SHORT_TIMEOUT);
        this.longWait = new WebDriverWait(driver, LONG_TIMEOUT);
    }
}
```

---

## ExpectedConditions Reference

### Element Visibility

```java
// Wait for element to be visible (present + displayed)
WebElement element = wait.until(
    ExpectedConditions.visibilityOfElementLocated(By.id("username"))
);

// Wait for specific element to be visible
wait.until(ExpectedConditions.visibilityOf(existingElement));

// Wait for all elements to be visible
List<WebElement> elements = wait.until(
    ExpectedConditions.visibilityOfAllElementsLocatedBy(By.cssSelector(".item"))
);
```

### Element Invisibility

```java
// Wait for element to disappear (loading spinner, modal)
wait.until(
    ExpectedConditions.invisibilityOfElementLocated(By.id("loading"))
);

// Wait for specific element to become invisible
wait.until(ExpectedConditions.invisibilityOf(loadingSpinner));

// Wait for element with specific text to disappear
wait.until(
    ExpectedConditions.invisibilityOfElementWithText(By.id("status"), "Loading...")
);
```

### Element Presence

```java
// Wait for element in DOM (may not be visible)
WebElement element = wait.until(
    ExpectedConditions.presenceOfElementLocated(By.id("hidden-input"))
);

// Wait for all elements in DOM
List<WebElement> elements = wait.until(
    ExpectedConditions.presenceOfAllElementsLocatedBy(By.cssSelector(".row"))
);
```

### Element Clickability

```java
// Wait for element to be clickable (visible + enabled)
WebElement button = wait.until(
    ExpectedConditions.elementToBeClickable(By.id("submit"))
);
button.click();

// One-liner pattern
wait.until(ExpectedConditions.elementToBeClickable(By.id("submit"))).click();
```

### Text Conditions

```java
// Wait for specific text to be present
wait.until(
    ExpectedConditions.textToBePresentInElementLocated(
        By.id("status"),
        "Success"
    )
);

// Wait for element text to match exactly
wait.until(
    ExpectedConditions.textToBe(By.id("header"), "Welcome")
);

// Wait for element text to match pattern
wait.until(
    ExpectedConditions.textMatches(
        By.id("message"),
        Pattern.compile("Order #\\d+ confirmed")
    )
);

// Wait for specific value in input
wait.until(
    ExpectedConditions.textToBePresentInElementValue(
        By.id("email"),
        "@"
    )
);
```

### URL Conditions

```java
// Wait for URL to contain substring
wait.until(ExpectedConditions.urlContains("/dashboard"));

// Wait for exact URL
wait.until(ExpectedConditions.urlToBe("https://app.example.com/home"));

// Wait for URL to match pattern
wait.until(
    ExpectedConditions.urlMatches(".*\\/orders\\/\\d+$")
);
```

### Page Title Conditions

```java
// Wait for title to contain text
wait.until(ExpectedConditions.titleContains("Dashboard"));

// Wait for exact title
wait.until(ExpectedConditions.titleIs("My Application - Dashboard"));
```

### Element State Conditions

```java
// Wait for element to be selected (checkbox, radio)
wait.until(
    ExpectedConditions.elementToBeSelected(By.id("agree-checkbox"))
);

// Wait for element selection state
wait.until(
    ExpectedConditions.elementSelectionStateToBe(
        By.id("remember-me"),
        true  // should be selected
    )
);

// Wait for element to be enabled
wait.until(d -> d.findElement(By.id("submit")).isEnabled());

// Wait for attribute value
wait.until(
    ExpectedConditions.attributeToBe(
        By.id("button"),
        "class",
        "btn-success"
    )
);

// Wait for attribute to contain value
wait.until(
    ExpectedConditions.attributeContains(
        By.id("status"),
        "class",
        "active"
    )
);
```

### Frame and Window Conditions

```java
// Wait and switch to frame
wait.until(
    ExpectedConditions.frameToBeAvailableAndSwitchToIt(By.id("iframe"))
);

// Wait and switch to frame by name
wait.until(
    ExpectedConditions.frameToBeAvailableAndSwitchToIt("frameName")
);

// Wait for new window/tab
String originalWindow = driver.getWindowHandle();
wait.until(ExpectedConditions.numberOfWindowsToBe(2));

// Switch to new window
for (String handle : driver.getWindowHandles()) {
    if (!handle.equals(originalWindow)) {
        driver.switchTo().window(handle);
        break;
    }
}
```

### Alert Conditions

```java
// Wait for alert and switch
Alert alert = wait.until(ExpectedConditions.alertIsPresent());
alert.accept();  // or alert.dismiss()

// Get alert text
String alertText = wait.until(ExpectedConditions.alertIsPresent()).getText();
```

### Staleness Condition

```java
// Wait for element to become stale (removed from DOM)
WebElement element = driver.findElement(By.id("dynamic-content"));
// ... trigger action that refreshes the element ...
wait.until(ExpectedConditions.stalenessOf(element));
// Now find the fresh element
element = driver.findElement(By.id("dynamic-content"));
```

---

## Combining Conditions

### AND Conditions

```java
// Both conditions must be true
wait.until(ExpectedConditions.and(
    ExpectedConditions.visibilityOfElementLocated(By.id("form")),
    ExpectedConditions.elementToBeClickable(By.id("submit"))
));
```

### OR Conditions

```java
// Either condition can be true
wait.until(ExpectedConditions.or(
    ExpectedConditions.visibilityOfElementLocated(By.id("success")),
    ExpectedConditions.visibilityOfElementLocated(By.id("error"))
));
```

### NOT Conditions

```java
// Negate a condition
wait.until(ExpectedConditions.not(
    ExpectedConditions.visibilityOfElementLocated(By.id("loading"))
));
```

---

## Custom Wait Conditions

### Using Lambda Expressions

```java
// Wait for specific number of elements
wait.until(driver ->
    driver.findElements(By.cssSelector(".item")).size() >= 5
);

// Wait for element attribute to change
wait.until(driver -> {
    String value = driver.findElement(By.id("status")).getAttribute("data-state");
    return "complete".equals(value);
});

// Wait for JavaScript variable
wait.until(driver ->
    ((JavascriptExecutor) driver).executeScript("return window.appReady === true")
);

// Wait for AJAX to complete (jQuery)
wait.until(driver ->
    (Boolean) ((JavascriptExecutor) driver).executeScript(
        "return jQuery.active === 0"
    )
);
```

### Creating Reusable Custom Conditions

```java
public class CustomExpectedConditions {

    /**
     * Wait for element's text to change from initial value
     */
    public static ExpectedCondition<Boolean> textToChange(By locator, String initialText) {
        return driver -> {
            try {
                String currentText = driver.findElement(locator).getText();
                return !currentText.equals(initialText);
            } catch (StaleElementReferenceException e) {
                return true;  // Element changed
            }
        };
    }

    /**
     * Wait for element count to be at least N
     */
    public static ExpectedCondition<Boolean> elementCountAtLeast(By locator, int count) {
        return driver -> driver.findElements(locator).size() >= count;
    }

    /**
     * Wait for element to have non-empty text
     */
    public static ExpectedCondition<WebElement> elementHasText(By locator) {
        return driver -> {
            WebElement element = driver.findElement(locator);
            String text = element.getText();
            return (text != null && !text.trim().isEmpty()) ? element : null;
        };
    }

    /**
     * Wait for page to finish loading (document.readyState)
     */
    public static ExpectedCondition<Boolean> pageLoadComplete() {
        return driver -> {
            String state = ((JavascriptExecutor) driver)
                .executeScript("return document.readyState")
                .toString();
            return "complete".equals(state);
        };
    }

    /**
     * Wait for element to stop moving (animations)
     */
    public static ExpectedCondition<Boolean> elementStoppedMoving(WebElement element) {
        return new ExpectedCondition<>() {
            private Point lastLocation;

            @Override
            public Boolean apply(WebDriver driver) {
                Point currentLocation = element.getLocation();
                boolean stopped = currentLocation.equals(lastLocation);
                lastLocation = currentLocation;
                return stopped;
            }
        };
    }
}

// Usage
wait.until(CustomExpectedConditions.textToChange(By.id("status"), "Loading"));
wait.until(CustomExpectedConditions.elementCountAtLeast(By.cssSelector(".row"), 10));
```

---

## Common Wait Patterns

### Wait for Page Load After Click

```java
@Step("Click and wait for navigation")
protected void clickAndWaitForUrl(By locator, String expectedUrlPart) {
    click(locator);
    wait.until(ExpectedConditions.urlContains(expectedUrlPart));
}

// Usage
clickAndWaitForUrl(loginButton, "/dashboard");
```

### Wait for Loading Spinner

```java
@Step("Wait for loading to complete")
protected void waitForLoading() {
    // Wait for spinner to appear (if it will)
    try {
        shortWait.until(ExpectedConditions.visibilityOfElementLocated(loadingSpinner));
    } catch (TimeoutException e) {
        // Spinner may already be gone or loading was instant
        return;
    }
    // Wait for spinner to disappear
    wait.until(ExpectedConditions.invisibilityOfElementLocated(loadingSpinner));
}
```

### Wait for Modal

```java
private final By modal = By.cssSelector("[role='dialog']");
private final By modalBackdrop = By.cssSelector(".modal-backdrop");

@Step("Wait for modal to open")
protected void waitForModalOpen() {
    wait.until(ExpectedConditions.visibilityOfElementLocated(modal));
}

@Step("Wait for modal to close")
protected void waitForModalClose() {
    wait.until(ExpectedConditions.invisibilityOfElementLocated(modal));
    wait.until(ExpectedConditions.invisibilityOfElementLocated(modalBackdrop));
}
```

### Wait for Table Data

```java
@Step("Wait for table to have data")
protected void waitForTableData(By tableRows, int minRows) {
    wait.until(driver ->
        driver.findElements(tableRows).size() >= minRows
    );
}

// Usage
waitForTableData(By.cssSelector("table tbody tr"), 5);
```

### Wait with Retry on Stale Element

```java
@Step("Click with stale element retry")
protected void clickWithRetry(By locator) {
    wait.until(driver -> {
        try {
            driver.findElement(locator).click();
            return true;
        } catch (StaleElementReferenceException e) {
            return false;  // Retry
        }
    });
}
```

### Wait for File Download

```java
@Step("Wait for file download")
protected void waitForFileDownload(Path downloadDir, String fileNamePattern, Duration timeout) {
    WebDriverWait downloadWait = new WebDriverWait(driver, timeout);
    downloadWait.until(driver -> {
        try {
            return Files.list(downloadDir)
                .anyMatch(file -> file.getFileName().toString().matches(fileNamePattern));
        } catch (IOException e) {
            return false;
        }
    });
}
```

---

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
| Recommended | ❌ Avoid                 | ✅ Prefer                  |

### Why Avoid Implicit Waits

```java
// ❌ Don't mix implicit and explicit waits
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

## Quick Reference

| Need                  | ExpectedCondition                           |
| --------------------- | ------------------------------------------- |
| Element visible       | `visibilityOfElementLocated(By)`            |
| Element clickable     | `elementToBeClickable(By)`                  |
| Element invisible     | `invisibilityOfElementLocated(By)`          |
| Element exists in DOM | `presenceOfElementLocated(By)`              |
| Text present          | `textToBePresentInElementLocated(By, text)` |
| URL contains          | `urlContains(urlPart)`                      |
| Title contains        | `titleContains(text)`                       |
| Alert present         | `alertIsPresent()`                          |
| Frame available       | `frameToBeAvailableAndSwitchToIt(By)`       |
| Element stale         | `stalenessOf(element)`                      |
| Multiple windows      | `numberOfWindowsToBe(count)`                |
| Attribute value       | `attributeToBe(By, attr, value)`            |

---

## Anti-Patterns to Avoid

```java
// ❌ Thread.sleep - NEVER!
Thread.sleep(5000);

// ❌ Catching Exception to hide timing issues
try {
    element.click();
} catch (Exception e) {
    Thread.sleep(1000);
    element.click();
}

// ❌ Using findElement without wait for dynamic content
WebElement element = driver.findElement(By.id("dynamic"));

// ❌ Very long implicit wait
driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(60));

// ❌ Polling in a loop manually
for (int i = 0; i < 10; i++) {
    if (element.isDisplayed()) break;
    Thread.sleep(500);
}
```

---

## Best Practices Checklist

- [ ] **Never** use `Thread.sleep()`
- [ ] Use `WebDriverWait` with `ExpectedConditions`
- [ ] Set reasonable timeouts (10-15 seconds default)
- [ ] Use shorter waits for quick checks (3-5 seconds)
- [ ] Use longer waits for file uploads/downloads (30+ seconds)
- [ ] Create reusable wait methods in BasePage
- [ ] Handle `TimeoutException` gracefully when appropriate
- [ ] Use custom conditions for complex scenarios
- [ ] Avoid mixing implicit and explicit waits
- [ ] Wait before interacting, not after
````
