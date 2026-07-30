# Locator Strategies Debugging And Mistakes

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original locator-strategies.md. See the other related files in this folder.

## Avoiding Common Mistakes

### [no] Wrong: Brittle CSS Selectors

```java
// Brittle - relies on styling classes
By.cssSelector("div.MuiBox-root > div.MuiContainer-root button.MuiButton-containedPrimary")
By.cssSelector(".styles__button___2K8Hx")  // CSS modules hash
```

### [ok] Right: Stable Selectors

```java
By.cssSelector("[data-testid='submit-button']")
By.cssSelector("button[type='submit']")
By.id("submit-button")
```

---

### [no] Wrong: Absolute XPath

```java
By.xpath("/html/body/div[1]/div/div[2]/form/div[3]/button")
```

### [ok] Right: Relative XPath

```java
By.xpath("//form[@id='login']//button[@type='submit']")
```

---

### [no] Wrong: Index Without Context

```java
By.xpath("(//button)[5]")  // Which button? Why 5?
```

### [ok] Right: Meaningful Context

```java
By.xpath("//div[@class='user-actions']//button[text()='Delete']")
By.cssSelector(".user-actions button[data-action='delete']")
```

---

## Debugging Locators

### Using Browser DevTools

1. Open DevTools (F12)
2. In Console, test selectors:

```javascript
// CSS Selector
document.querySelector('[data-testid="submit"]');
document.querySelectorAll("table tbody tr");

// XPath
$x("//button[text()='Submit']");
$x("//input[@id='email']/ancestor::form");
```

### Using Selenium

```java
// Check if element exists
public boolean isElementPresent(By locator) {
    try {
        driver.findElement(locator);
        return true;
    } catch (NoSuchElementException e) {
        return false;
    }
}

// Count matching elements
public int countElements(By locator) {
    return driver.findElements(locator).size();
}

// Get all matching elements for debugging
public void debugLocator(By locator) {
    var elements = driver.findElements(locator);
    log.info("Found {} elements for locator: {}", elements.size(), locator);
    for (var element : elements) {
        log.info("  - Tag: {}, Text: {}", element.getTagName(), element.getText());
    }
}
```

---
