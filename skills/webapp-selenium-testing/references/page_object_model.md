````markdown
# Page Object Model (POM) Best Practices for Selenium WebDriver (Java)

Comprehensive guide for implementing the Page Object Model pattern in Selenium tests with Java.

---

## What is Page Object Model?

Page Object Model (POM) is a design pattern that creates an abstraction layer between test code and page implementation. Each page (or component) in your application gets its own class that encapsulates:

- **Locators** for elements on the page
- **Methods** for interactions and actions
- **Fluent interface** for method chaining

### Benefits

| Benefit         | Description                             |
| --------------- | --------------------------------------- |
| Maintainability | Change locator once, not in every test  |
| Readability     | Tests read like user stories            |
| Reusability     | Share page logic across tests           |
| Separation      | Test logic separate from implementation |
| Scalability     | Easy to add new pages/components        |

---

## Directory Structure (Maven)

```
src/
├── main/java/com/project/
│   ├── base/
│   │   ├── BasePage.java           # Common page functionality
│   │   └── BaseComponent.java      # Reusable UI components
│   ├── pages/
│   │   ├── LoginPage.java
│   │   ├── DashboardPage.java
│   │   └── ProductPage.java
│   ├── components/
│   │   ├── HeaderComponent.java
│   │   ├── FooterComponent.java
│   │   └── ModalComponent.java
│   ├── factories/
│   │   └── WebDriverFactory.java
│   ├── models/
│   │   └── User.java               # Data models with Lombok
│   └── utils/
│       ├── ConfigReader.java
│       └── WaitUtils.java
├── main/resources/
│   └── config.properties
└── test/java/com/project/
    ├── base/
    │   └── BaseTest.java           # Test setup/teardown
    └── tests/
        ├── LoginTest.java
        └── DashboardTest.java
```

---

## Base Page Pattern

Create a base class with common functionality:

```java
package com.project.base;

import io.qameta.allure.Step;
import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.*;
import java.time.Duration;
import java.util.List;

@Slf4j
public abstract class BasePage {
    protected final WebDriver driver;
    protected final WebDriverWait wait;
    private static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(15);
    private static final Duration POLL_INTERVAL = Duration.ofMillis(500);

    protected BasePage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, DEFAULT_TIMEOUT, POLL_INTERVAL);
    }

    // ============ WAIT METHODS ============

    protected WebElement waitForVisible(By locator) {
        log.debug("Waiting for element visible: {}", locator);
        return wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    protected WebElement waitForClickable(By locator) {
        log.debug("Waiting for element clickable: {}", locator);
        return wait.until(ExpectedConditions.elementToBeClickable(locator));
    }

    protected void waitForInvisible(By locator) {
        log.debug("Waiting for element invisible: {}", locator);
        wait.until(ExpectedConditions.invisibilityOfElementLocated(locator));
    }

    protected void waitForUrlContains(String urlPart) {
        log.debug("Waiting for URL to contain: {}", urlPart);
        wait.until(ExpectedConditions.urlContains(urlPart));
    }

    protected void waitForTextPresent(By locator, String text) {
        wait.until(ExpectedConditions.textToBePresentInElementLocated(locator, text));
    }

    // ============ ACTION METHODS ============

    @Step("Click on element: {locator}")
    protected void click(By locator) {
        log.info("Clicking: {}", locator);
        waitForClickable(locator).click();
    }

    @Step("Enter text '{text}' in field: {locator}")
    protected void type(By locator, String text) {
        log.info("Typing '{}' into: {}", text, locator);
        var element = waitForVisible(locator);
        element.clear();
        element.sendKeys(text);
    }

    @Step("Clear and type '{text}' in field: {locator}")
    protected void clearAndType(By locator, String text) {
        var element = waitForVisible(locator);
        element.sendKeys(Keys.chord(Keys.CONTROL, "a"), text);
    }

    @Step("Select option '{visibleText}' from dropdown: {locator}")
    protected void selectByVisibleText(By locator, String visibleText) {
        log.info("Selecting '{}' from: {}", visibleText, locator);
        var select = new Select(waitForVisible(locator));
        select.selectByVisibleText(visibleText);
    }

    @Step("Select option by value '{value}' from dropdown: {locator}")
    protected void selectByValue(By locator, String value) {
        var select = new Select(waitForVisible(locator));
        select.selectByValue(value);
    }

    // ============ GETTER METHODS ============

    protected String getText(By locator) {
        return waitForVisible(locator).getText();
    }

    protected String getAttribute(By locator, String attribute) {
        return waitForVisible(locator).getAttribute(attribute);
    }

    protected String getValue(By locator) {
        return getAttribute(locator, "value");
    }

    protected List<WebElement> findAll(By locator) {
        return driver.findElements(locator);
    }

    protected List<String> getAllTexts(By locator) {
        return findAll(locator).stream()
            .map(WebElement::getText)
            .toList();
    }

    // ============ STATE METHODS ============

    protected boolean isDisplayed(By locator) {
        try {
            return driver.findElement(locator).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    protected boolean isEnabled(By locator) {
        return waitForVisible(locator).isEnabled();
    }

    protected boolean isSelected(By locator) {
        return waitForVisible(locator).isSelected();
    }

    protected int countElements(By locator) {
        return driver.findElements(locator).size();
    }

    // ============ UTILITY METHODS ============

    @Step("Take screenshot: {name}")
    protected byte[] takeScreenshot(String name) {
        log.info("Taking screenshot: {}", name);
        return ((TakesScreenshot) driver).getScreenshotAs(OutputType.BYTES);
    }

    protected void scrollToElement(By locator) {
        var element = waitForVisible(locator);
        ((JavascriptExecutor) driver).executeScript(
            "arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});",
            element
        );
    }

    protected void jsClick(By locator) {
        var element = waitForVisible(locator);
        ((JavascriptExecutor) driver).executeScript("arguments[0].click();", element);
    }
}
```

---

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

## Component Objects

For reusable UI components (header, footer, modals):

```java
package com.project.components;

import com.project.base.BasePage;
import io.qameta.allure.Step;
import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

@Slf4j
public class HeaderComponent extends BasePage {

    private final By logo = By.cssSelector("header a[aria-label='Home']");
    private final By searchBox = By.cssSelector("input[type='search']");
    private final By userMenu = By.cssSelector("[data-testid='user-menu']");
    private final By logoutButton = By.cssSelector("[data-testid='logout']");
    private final By cartIcon = By.cssSelector("[data-testid='cart-icon']");
    private final By cartCount = By.cssSelector("[data-testid='cart-count']");
    private final By notificationBell = By.cssSelector("[data-testid='notifications']");

    public HeaderComponent(WebDriver driver) {
        super(driver);
    }

    @Step("Search for: {query}")
    public HeaderComponent search(String query) {
        type(searchBox, query);
        searchBox.sendKeys(org.openqa.selenium.Keys.ENTER);
        return this;
    }

    @Step("Click user menu")
    public HeaderComponent openUserMenu() {
        click(userMenu);
        return this;
    }

    @Step("Logout")
    public void logout() {
        openUserMenu();
        click(logoutButton);
    }

    @Step("Go to cart")
    public CartPage goToCart() {
        click(cartIcon);
        return new CartPage(driver);
    }

    public int getCartItemCount() {
        String text = getText(cartCount);
        return text.isEmpty() ? 0 : Integer.parseInt(text);
    }

    public boolean isLoggedIn() {
        return isDisplayed(userMenu);
    }
}
```

### Modal Component

```java
package com.project.components;

import com.project.base.BasePage;
import io.qameta.allure.Step;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public class ModalComponent extends BasePage {

    private final By modal = By.cssSelector("[role='dialog']");
    private final By modalTitle = By.cssSelector("[role='dialog'] h2");
    private final By closeButton = By.cssSelector("[role='dialog'] button[aria-label='Close']");
    private final By confirmButton = By.cssSelector("[role='dialog'] [data-testid='confirm']");
    private final By cancelButton = By.cssSelector("[role='dialog'] [data-testid='cancel']");

    public ModalComponent(WebDriver driver) {
        super(driver);
    }

    @Step("Wait for modal to appear")
    public ModalComponent waitForModal() {
        waitForVisible(modal);
        return this;
    }

    @Step("Get modal title")
    public String getTitle() {
        return getText(modalTitle);
    }

    @Step("Click confirm button")
    public void confirm() {
        click(confirmButton);
        waitForInvisible(modal);
    }

    @Step("Click cancel button")
    public void cancel() {
        click(cancelButton);
        waitForInvisible(modal);
    }

    @Step("Close modal")
    public void close() {
        click(closeButton);
        waitForInvisible(modal);
    }

    public boolean isDisplayed() {
        return isDisplayed(modal);
    }
}
```

---

## Base Test Class

```java
package com.project.base;

import com.project.factories.WebDriverFactory;
import com.project.pages.*;
import io.qameta.allure.Allure;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.*;
import org.openqa.selenium.*;
import java.io.ByteArrayInputStream;

@Slf4j
public abstract class BaseTest {
    protected WebDriver driver;
    protected LoginPage loginPage;
    protected DashboardPage dashboardPage;

    @BeforeEach
    void setUp(TestInfo testInfo) {
        log.info("========== Starting: {} ==========", testInfo.getDisplayName());
        driver = WebDriverFactory.createDriver();
        driver.manage().window().maximize();
        initializePages();
    }

    @AfterEach
    void tearDown(TestInfo testInfo) {
        if (driver != null) {
            log.info("========== Finished: {} ==========", testInfo.getDisplayName());
            driver.quit();
        }
    }

    private void initializePages() {
        loginPage = new LoginPage(driver);
        dashboardPage = new DashboardPage(driver);
    }

    // ============ HELPER METHODS ============

    protected void attachScreenshot(String name) {
        try {
            byte[] screenshot = ((TakesScreenshot) driver).getScreenshotAs(OutputType.BYTES);
            Allure.addAttachment(name, "image/png", new ByteArrayInputStream(screenshot), "png");
        } catch (Exception e) {
            log.warn("Failed to capture screenshot: {}", e.getMessage());
        }
    }

    // ⚠️ Security: Only call this inside tests that navigate to your own application.
    // Attaching raw page source from third-party sites can expose AI-assisted sessions
    // to indirect prompt injection embedded in web content (W011).
    // The 50 KB limit prevents excessive untrusted content from entering the AI context.
    protected void attachPageSource(String name) {
        String pageSource = driver.getPageSource();
        final int MAX_CHARS = 50_000;
        if (pageSource.length() > MAX_CHARS) {
            pageSource = pageSource.substring(0, MAX_CHARS) + "\n<!-- [page source truncated for safety] -->";
        }
        Allure.addAttachment(name, "text/html", pageSource, "html");
    }

    protected DashboardPage loginAsStandardUser() {
        return loginPage
            .open()
            .loginAs("standard_user", "secret_sauce");
    }
}
```

---

## Fluent Interface Pattern

Design methods to return `this` or the next page object for method chaining:

```java
// ✅ Fluent chaining within same page
loginPage
    .enterUsername("user@test.com")
    .enterPassword("password123")
    .checkRememberMe()
    .clickLogin();

// ✅ Fluent navigation to next page
DashboardPage dashboard = loginPage
    .open()
    .loginAs("user@test.com", "password");

// ✅ Chain with component
dashboard.getHeader()
    .search("product")
    .goToResults();
```

### Implementation Rules

```java
// Actions that stay on same page return 'this'
public LoginPage enterUsername(String username) {
    type(usernameInput, username);
    return this;  // ← Same page
}

// Actions that navigate return next page
public DashboardPage loginAs(String username, String password) {
    // ... login logic ...
    return new DashboardPage(driver);  // ← Next page
}

// Void return for terminal actions
public void clickLogin() {
    click(loginButton);
    // No return - end of chain, outcome determined by test
}
```

---

## Test Class Example

```java
package com.project.tests;

import com.project.base.BaseTest;
import io.qameta.allure.*;
import org.assertj.core.api.SoftAssertions;
import org.junit.jupiter.api.*;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

@Epic("Authentication")
@Feature("Login")
class LoginTest extends BaseTest {

    @Test
    @Tag("smoke")
    @Severity(SeverityLevel.BLOCKER)
    @DisplayName("Should login successfully with valid credentials")
    void shouldLoginSuccessfully() {
        // Act
        var dashboard = loginPage
            .open()
            .loginAs("standard_user", "secret_sauce");

        // Assert
        SoftAssertions.assertSoftly(softly -> {
            softly.assertThat(dashboard.isLoaded())
                .as("Dashboard should be loaded")
                .isTrue();
            softly.assertThat(dashboard.getWelcomeMessage())
                .as("Welcome message")
                .containsIgnoringCase("Welcome");
            softly.assertThat(dashboard.getHeader().isLoggedIn())
                .as("User should be logged in")
                .isTrue();
        });
    }

    @ParameterizedTest(name = "Login fails with {0}")
    @Tag("regression")
    @Severity(SeverityLevel.CRITICAL)
    @CsvSource({
        "locked_user, secret_sauce, locked out",
        "invalid, wrong, do not match"
    })
    @DisplayName("Should show error for invalid credentials")
    void shouldShowErrorForInvalidCredentials(String user, String pass, String expectedError) {
        // Act
        loginPage
            .open()
            .loginExpectingError(user, pass);

        // Assert
        SoftAssertions.assertSoftly(softly -> {
            softly.assertThat(loginPage.isErrorDisplayed())
                .as("Error message visibility")
                .isTrue();
            softly.assertThat(loginPage.getErrorMessage())
                .as("Error message content")
                .containsIgnoringCase(expectedError);
        });

        attachScreenshot("login-error");
    }
}
```

---

## Best Practices Summary

### DO ✅

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

### DON'T ❌

```java
// Don't put assertions in Page Objects
public void clickLogin() {
    click(loginButton);
    assertThat(driver.getCurrentUrl()).contains("/dashboard");  // ❌ Wrong!
}

// Don't create locators in methods
public void enterEmail(String email) {
    driver.findElement(By.id("email")).sendKeys(email);  // ❌ Wrong!
}

// Don't expose WebDriver publicly
public WebDriver getDriver() { return driver; }  // ❌ Wrong!

// Don't use Thread.sleep
public void waitForPage() {
    Thread.sleep(2000);  // ❌ Never!
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
