# Wait Strategies Expected Conditions

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original wait-strategies.md. See the other related files in this folder.

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
