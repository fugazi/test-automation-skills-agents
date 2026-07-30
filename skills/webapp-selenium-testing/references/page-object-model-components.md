# Page Object Model Components And Base Test

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original page-object-model.md. See the other related files in this folder.

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

    // [!] Security: Only call this inside tests that navigate to your own application.
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
