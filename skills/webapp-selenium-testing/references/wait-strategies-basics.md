# Wait Strategies Basics

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original wait-strategies.md. See the other related files in this folder.

Comprehensive guide for implementing proper synchronization in Selenium tests using explicit waits.

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
// [no] NEVER DO THIS
Thread.sleep(3000);
element.click();

// [ok] ALWAYS DO THIS
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
