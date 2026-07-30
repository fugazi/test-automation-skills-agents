# Page Object Implementation

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original page-object-model.md. See the other related files in this folder.

## Page Object Implementation

### Login Page Example

```java
package com.project.pages;

import com.project.base.BasePage;
import io.qameta.allure.Step;
import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

@Slf4j
public class LoginPage extends BasePage {

    // ============ LOCATORS ============
    private final By usernameInput = By.id("username");
    private final By passwordInput = By.id("password");
    private final By loginButton = By.id("login-button");
    private final By errorMessage = By.cssSelector("[data-testid='error']");
    private final By forgotPasswordLink = By.linkText("Forgot password?");
    private final By rememberMeCheckbox = By.id("remember-me");

    public LoginPage(WebDriver driver) {
        super(driver);
    }

    // ============ NAVIGATION ============

    @Step("Navigate to login page")
    public LoginPage open() {
        driver.get(ConfigReader.get("base.url") + "/login");
        return this;
    }

    // ============ ACTIONS (Fluent Interface) ============

    @Step("Enter username: {username}")
    public LoginPage enterUsername(String username) {
        type(usernameInput, username);
        return this;
    }

    @Step("Enter password")
    public LoginPage enterPassword(String password) {
        type(passwordInput, password);
        return this;
    }

    @Step("Check 'Remember me'")
    public LoginPage checkRememberMe() {
        if (!isSelected(rememberMeCheckbox)) {
            click(rememberMeCheckbox);
        }
        return this;
    }

    @Step("Click login button")
    public void clickLogin() {
        click(loginButton);
    }

    // ============ COMBINED ACTIONS ============

    @Step("Login with username: {username}")
    public DashboardPage loginAs(String username, String password) {
        log.info("Logging in as: {}", username);
        enterUsername(username);
        enterPassword(password);
        clickLogin();
        waitForUrlContains("/dashboard");
        return new DashboardPage(driver);
    }

    @Step("Attempt login with invalid credentials")
    public LoginPage loginExpectingError(String username, String password) {
        enterUsername(username);
        enterPassword(password);
        clickLogin();
        waitForVisible(errorMessage);
        return this;
    }

    // ============ GETTERS ============

    @Step("Get error message text")
    public String getErrorMessage() {
        return getText(errorMessage);
    }

    // ============ STATE CHECKS ============

    public boolean isErrorDisplayed() {
        return isDisplayed(errorMessage);
    }

    public boolean isLoginButtonEnabled() {
        return isEnabled(loginButton);
    }
}
```

### Dashboard Page Example

```java
package com.project.pages;

import com.project.base.BasePage;
import com.project.components.HeaderComponent;
import io.qameta.allure.Step;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

@Slf4j
public class DashboardPage extends BasePage {

    // ============ COMPONENTS ============
    @Getter
    private final HeaderComponent header;

    // ============ LOCATORS ============
    private final By welcomeHeading = By.cssSelector("h1[data-testid='welcome']");
    private final By statsCards = By.cssSelector("[data-testid='stats-card']");
    private final By recentActivityList = By.cssSelector("[data-testid='activity-list'] li");
    private final By loadingSpinner = By.cssSelector("[data-testid='loading']");

    public DashboardPage(WebDriver driver) {
        super(driver);
        this.header = new HeaderComponent(driver);
    }

    // ============ NAVIGATION ============

    @Step("Navigate to dashboard")
    public DashboardPage open() {
        driver.get(ConfigReader.get("base.url") + "/dashboard");
        waitForInvisible(loadingSpinner);
        return this;
    }

    // ============ GETTERS ============

    @Step("Get welcome message")
    public String getWelcomeMessage() {
        return getText(welcomeHeading);
    }

    @Step("Get stats card count")
    public int getStatsCardCount() {
        return countElements(statsCards);
    }

    @Step("Get recent activity items")
    public java.util.List<String> getRecentActivityItems() {
        return getAllTexts(recentActivityList);
    }

    // ============ STATE CHECKS ============

    public boolean isLoaded() {
        return isDisplayed(welcomeHeading);
    }
}
```

---
