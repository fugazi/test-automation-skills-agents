# Locator Strategies Priority Hierarchy

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original locator-strategies.md. See the other related files in this folder.

Comprehensive guide for choosing and implementing the right locator strategy in Selenium tests.

## Locator Priority Hierarchy

Always prefer locators higher in this list:

| Priority | Locator Type | Example                                            | Why                     |
| -------- | ------------ | -------------------------------------------------- | ----------------------- |
| 1        | ID           | `By.id("login-button")`                            | Fastest, most stable    |
| 2        | Name         | `By.name("username")`                              | Stable, semantic        |
| 3        | Test ID      | `By.cssSelector("[data-testid='submit']")`         | Explicit, stable        |
| 4        | CSS Selector | `By.cssSelector("form#login input[type='email']")` | Flexible, fast          |
| 5        | Link Text    | `By.linkText("Sign up")`                           | For anchor elements     |
| 6        | Class Name   | `By.className("btn-primary")`                      | Can change with styling |
| 7        | XPath        | `By.xpath("//button[@aria-label='Close']")`        | Use only when necessary |

---

## ID-Based Locators (Best)

The fastest and most reliable locator strategy:

```java
// [ok] BEST: Direct ID
By.id("login-button")
By.id("username")
By.id("password")
By.id("submit-form")

// Locator declaration pattern
private final By usernameInput = By.id("username");
private final By passwordInput = By.id("password");
private final By loginButton = By.id("login-button");
```

---

## Test ID Locators (Recommended)

For elements without natural IDs, use test IDs:

```java
// [ok] GOOD: Test IDs (stable, explicit)
By.cssSelector("[data-testid='user-avatar']")
By.cssSelector("[data-testid='cart-icon']")
By.cssSelector("[data-testid='product-card']")

// Alternative attributes
By.cssSelector("[data-qa='submit-button']")
By.cssSelector("[data-test='login-form']")

// With additional filtering
By.cssSelector("[data-testid='product-card'][data-product-id='123']")
```

---
