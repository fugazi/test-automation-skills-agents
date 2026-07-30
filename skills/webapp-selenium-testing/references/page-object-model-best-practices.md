# Page Object Model Best Practices

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original page-object-model.md. See the other related files in this folder.

## Best Practices Summary

### DO [ok]

```java
// Keep locators in constructor as private final
private final By submitButton = By.id("submit");

// Return 'this' for chaining
public LoginPage enterEmail(String email) {
    type(emailInput, email);
    return this;
}

// Return next page on navigation
public DashboardPage login() {
    click(loginButton);
    return new DashboardPage(driver);
}

// Add @Step annotations for Allure
@Step("Enter email: {email}")
public LoginPage enterEmail(String email) { ... }

// Use descriptive method names
public LoginPage checkRememberMe() { ... }
```

### DON'T [no]

```java
// Don't put assertions in Page Objects
public void clickLogin() {
    click(loginButton);
    assertThat(driver.getCurrentUrl()).contains("/dashboard");  // [no] Wrong!
}

// Don't create locators in methods
public void enterEmail(String email) {
    driver.findElement(By.id("email")).sendKeys(email);  // [no] Wrong!
}

// Don't expose WebDriver publicly
public WebDriver getDriver() { return driver; }  // [no] Wrong!

// Don't use Thread.sleep
public void waitForPage() {
    Thread.sleep(2000);  // [no] Never!
}
```

---

## Quick Reference

| Pattern                       | When to Use                        |
| ----------------------------- | ---------------------------------- |
| `return this`                 | Action stays on same page          |
| `return new NextPage(driver)` | Action navigates to new page       |
| Component Object              | Reusable UI part (header, modal)   |
| `@Step`                       | Document actions in Allure reports |
| `SoftAssertions`              | Multiple assertions in one test    |
| `waitForVisible()`            | Before interacting with element    |
| `waitForInvisible()`          | After dismissing modal/loader      |
````
