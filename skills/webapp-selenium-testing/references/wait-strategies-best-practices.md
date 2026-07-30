# Wait Strategies Best Practices

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original wait-strategies.md. See the other related files in this folder.

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
// [no] Thread.sleep - NEVER!
Thread.sleep(5000);

// [no] Catching Exception to hide timing issues
try {
    element.click();
} catch (Exception e) {
    Thread.sleep(1000);
    element.click();
}

// [no] Using findElement without wait for dynamic content
WebElement element = driver.findElement(By.id("dynamic"));

// [no] Very long implicit wait
driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(60));

// [no] Polling in a loop manually
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
