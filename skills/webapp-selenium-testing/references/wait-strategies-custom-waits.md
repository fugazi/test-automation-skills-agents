# Wait Strategies Custom Conditions And Patterns

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original wait-strategies.md. See the other related files in this folder.

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
