---
description: 'Page Object Model (POM) pattern for test automation. Covers principles, implementation in Playwright and Selenium, anti-patterns, and examples.'
version: '1.0.0'
category: 'patterns'
applies-to:
  agents: ['test-writer', 'qa-automation', 'selenium-tester', 'playwright-tester']
  skills: ['ui-testing', 'test-design', 'page-object-model']
  frameworks: ['playwright', 'selenium', 'webdriver', 'webdriverio', 'cypress']
priority: 'recommended'
compliance:
  must-follow: ['Separate page logic from test logic', 'Each page should have its own class', 'Never use raw selectors in tests', 'Methods should return page objects for chaining', 'Page objects should not contain assertions']
  should-follow: ['Use meaningful method names that reflect business actions', 'Encapsulate waits and synchronization', 'Initialize elements lazily when possible', 'Keep page objects focused on single responsibility']
  can-ignore: ['Simple one-off scripts', 'Proof of concept tests']
---

# Page Object Model Pattern

## Purpose

The Page Object Model (POM) is a design pattern that creates an object repository for web UI elements. It reduces code duplication, improves test maintenance, and separates test logic from page interaction logic. By modeling pages as objects and their actions as methods, tests become more readable, reusable, and resilient to UI changes.

## POM Principles

### Core Principles

1. **Separation of Concerns**
   - Page objects handle UI interactions
   - Tests handle validation and assertions
   - Test code should never directly access page elements

2. **Single Responsibility**
   - Each page object represents one page or component
   - Methods represent user actions on that page
   - Page objects should not contain assertions

3. **Encapsulation**
   - Hide implementation details (selectors, waits)
   - Expose only high-level business methods
   - Abstract away complex interaction patterns

4. **Reusability**
   - Page objects can be used across multiple tests
   - Common components should have their own objects
   - Share utility methods across page objects

5. **Return Self for Chaining**
   - Actions that navigate should return the new page object
   - Actions that stay on page should return the same page object
   - Enables fluent test writing

### Architecture

```
Tests (Assertion Layer)
    ↓
Page Objects (Interaction Layer)
    ↓
Element Locators (Selector Layer)
    ↓
Web Application (AUT)
```

## Playwright Implementation

### Base Page Object

```typescript
// pages/base-page.ts
import { Page, Locator } from '@playwright/test';

export abstract class BasePage {
    readonly page: Page;

    constructor(page: Page) {
        this.page = page;
    }

    // Common utility methods
    async navigate(url: string): Promise<this> {
        await this.page.goto(url);
        return this;
    }

    async waitForPageLoad(): Promise<void> {
        await this.page.waitForLoadState('networkidle');
    }

    async clickElement(locator: Locator): Promise<void> {
        await locator.waitFor({ state: 'visible' });
        await locator.click();
    }

    async fillInput(locator: Locator, value: string): Promise<void> {
        await locator.waitFor({ state: 'visible' });
        await locator.clear();
        await locator.fill(value);
    }

    async getText(locator: Locator): Promise<string> {
        await locator.waitFor({ state: 'visible' });
        return await locator.textContent() || '';
    }

    async isVisible(locator: Locator): Promise<boolean> {
        return await locator.isVisible().catch(() => false);
    }

    // Screenshot utility
    async screenshot(options?: { path: string }): Promise<Buffer> {
        return await this.page.screenshot(options);
    }
}
```

### Page Object Example

```typescript
// pages/login-page.ts
import { Page } from '@playwright/test';
import { BasePage } from './base-page';
import { DashboardPage } from './dashboard-page';

export class LoginPage extends BasePage {
    // Selectors
    private readonly usernameInput = this.page.locator('[data-testid="username-input"]');
    private readonly passwordInput = this.page.locator('[data-testid="password-input"]');
    private readonly loginButton = this.page.locator('[data-testid="login-button"]');
    private readonly errorMessage = this.page.locator('[data-testid="error-message"]');
    private readonly forgotPasswordLink = this.page.locator('a[href="/forgot-password"]');

    // URL
    static readonly url = '/login';

    constructor(page: Page) {
        super(page);
    }

    // Business Actions
    async enterUsername(username: string): Promise<this> {
        await this.fillInput(this.usernameInput, username);
        return this;
    }

    async enterPassword(password: string): Promise<this> {
        await this.fillInput(this.passwordInput, password);
        return this;
    }

    async clickLogin(): Promise<DashboardPage> {
        await this.clickElement(this.loginButton);
        await this.page.waitForURL('**/dashboard');
        return new DashboardPage(this.page);
    }

    // Combined action
    async login(username: string, password: string): Promise<DashboardPage> {
        await this.enterUsername(username);
        await this.enterPassword(password);
        return await this.clickLogin();
    }

    // State verification
    async getErrorMessage(): Promise<string> {
        return await this.getText(this.errorMessage);
    }

    async isErrorMessageVisible(): Promise<boolean> {
        return await this.isVisible(this.errorMessage);
    }

    async isLoginButtonEnabled(): Promise<boolean> {
        return await this.loginButton.isEnabled();
    }
}
```

### Navigation Page Object

```typescript
// pages/dashboard-page.ts
import { Page } from '@playwright/test';
import { BasePage } from './base-page';

export class DashboardPage extends BasePage {
    private readonly welcomeMessage = this.page.locator('[data-testid="welcome-message"]');
    private readonly logoutButton = this.page.locator('[data-testid="logout-button"]');
    private readonly navigationMenu = this.page.locator('[data-testid="nav-menu"]');

    static readonly url = '/dashboard';

    constructor(page: Page) {
        super(page);
    }

    async isLoaded(): Promise<boolean> {
        await this.welcomeMessage.waitFor({ state: 'visible' });
        return await this.isVisible(this.welcomeMessage);
    }

    async getWelcomeText(): Promise<string> {
        return await this.getText(this.welcomeMessage);
    }

    async logout(): Promise<LoginPage> {
        await this.clickElement(this.logoutButton);
        await this.page.waitForURL('**/login');
        return new LoginPage(this.page);
    }
}
```

### Component Page Object

```typescript
// components/navigation-menu.ts
import { Page, Locator } from '@playwright/test';

export class NavigationMenu {
    private readonly menu = this.page.locator('[data-testid="nav-menu"]');
    private readonly menuItems = this.menu.locator('.nav-item');
    private readonly userMenu = this.page.locator('[data-testid="user-menu"]');
    private readonly userDropdown = this.page.locator('[data-testid="user-dropdown"]');

    constructor(private readonly page: Page) {}

    async clickMenuItem(itemName: string): Promise<void> {
        const item = this.menuItems.filter({ hasText: itemName });
        await item.click();
    }

    async openUserMenu(): Promise<void> {
        await this.userMenu.click();
        await this.userDropdown.waitFor({ state: 'visible' });
    }

    async isMenuItemVisible(itemName: string): Promise<boolean> {
        const item = this.menuItems.filter({ hasText: itemName });
        return await item.isVisible().catch(() => false);
    }
}
```

### Test Using Page Objects

```typescript
// tests/login.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/login-page';
import { DashboardPage } from '../pages/dashboard-page';

test.describe('Login Flow', () => {
    let loginPage: LoginPage;

    test.beforeEach(async ({ page }) => {
        loginPage = new LoginPage(page);
        await loginPage.navigate(`https://example.com${LoginPage.url}`);
    });

    test('should login successfully with valid credentials', async ({ page }) => {
        // Arrange & Act
        const dashboardPage = await loginPage.login('user@example.com', 'password123');

        // Assert
        await expect(dashboardPage.isLoaded()).resolves.toBe(true);
        const welcomeText = await dashboardPage.getWelcomeText();
        expect(welcomeText).toContain('Welcome');
    });

    test('should show error with invalid credentials', async ({ page }) => {
        // Act
        await loginPage.login('invalid@example.com', 'wrongpassword');

        // Assert
        const isErrorMessageVisible = await loginPage.isErrorMessageVisible();
        expect(isErrorMessageVisible).toBe(true);

        const errorMessage = await loginPage.getErrorMessage();
        expect(errorMessage).toContain('Invalid credentials');
    });

    test('should disable login button when form is invalid', async ({ page }) => {
        // Act
        await loginPage.enterUsername('test@example.com');

        // Assert
        const isEnabled = await loginPage.isLoginButtonEnabled();
        expect(isEnabled).toBe(false);
    });
});
```

### Page Object Factory

```typescript
// pages/page-factory.ts
import { Page } from '@playwright/test';
import { LoginPage } from './login-page';
import { DashboardPage } from './dashboard-page';
import { HomePage } from './home-page';

export class PageFactory {
    constructor(private readonly page: Page) {}

    getLoginPage(): LoginPage {
        return new LoginPage(this.page);
    }

    getDashboardPage(): DashboardPage {
        return new DashboardPage(this.page);
    }

    getHomePage(): HomePage {
        return new HomePage(this.page);
    }
}
```

## Selenium Implementation

### Base Page Object

```java
// pages/BasePage.java
package pages;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.*;

public abstract class BasePage {
    protected final WebDriver driver;
    protected final WebDriverWait wait;

    // Timeout constants
    protected static final int DEFAULT_TIMEOUT = 10;
    protected static final int SHORT_TIMEOUT = 5;
    protected static final int LONG_TIMEOUT = 30;

    public BasePage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, DEFAULT_TIMEOUT);
    }

    // Navigation
    public void navigateTo(String url) {
        driver.get(url);
    }

    // Element interaction methods
    protected void click(By locator) {
        waitForElementClickable(locator);
        driver.findElement(locator).click();
    }

    protected void type(By locator, String text) {
        waitForElementVisible(locator);
        WebElement element = driver.findElement(locator);
        element.clear();
        element.sendKeys(text);
    }

    protected String getText(By locator) {
        waitForElementVisible(locator);
        return driver.findElement(locator).getText();
    }

    protected boolean isDisplayed(By locator) {
        try {
            return driver.findElement(locator).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    protected boolean isEnabled(By locator) {
        waitForElementVisible(locator);
        return driver.findElement(locator).isEnabled();
    }

    // Wait methods
    protected void waitForElementVisible(By locator) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    protected void waitForElementClickable(By locator) {
        wait.until(ExpectedConditions.elementToBeClickable(locator));
    }

    protected void waitForPageLoad() {
        wait.until(webDriver ->
            ((JavascriptExecutor) webDriver)
                .executeScript("return document.readyState").equals("complete")
        );
    }

    // JavaScript execution
    protected void scrollToElement(By locator) {
        WebElement element = driver.findElement(locator);
        ((JavascriptExecutor) driver).executeScript(
            "arguments[0].scrollIntoView(true);", element
        );
    }
}
```

### Page Object Example

```java
// pages/LoginPage.java
package pages;

import org.openqa.selenium.*;

public class LoginPage extends BasePage {
    // Selectors
    private static final By USERNAME_INPUT = By.id("username");
    private static final By PASSWORD_INPUT = By.id("password");
    private static final By LOGIN_BUTTON = By.cssSelector("[data-testid='login-button']");
    private static final By ERROR_MESSAGE = By.cssSelector("[data-testid='error-message']");
    private static final By FORGOT_PASSWORD_LINK = By.linkText("Forgot Password?");

    // URL
    private static final String URL = "/login";

    public LoginPage(WebDriver driver) {
        super(driver);
    }

    public static LoginPage open(WebDriver driver) {
        LoginPage loginPage = new LoginPage(driver);
        loginPage.navigateTo(URL);
        return loginPage;
    }

    // Business actions
    public LoginPage enterUsername(String username) {
        type(USERNAME_INPUT, username);
        return this;
    }

    public LoginPage enterPassword(String password) {
        type(PASSWORD_INPUT, password);
        return this;
    }

    public DashboardPage clickLogin() {
        click(LOGIN_BUTTON);
        return new DashboardPage(driver);
    }

    public DashboardPage login(String username, String password) {
        return enterUsername(username)
                .enterPassword(password)
                .clickLogin();
    }

    // State verification
    public String getErrorMessage() {
        waitForElementVisible(ERROR_MESSAGE);
        return getText(ERROR_MESSAGE);
    }

    public boolean isErrorMessageDisplayed() {
        return isDisplayed(ERROR_MESSAGE);
    }

    public boolean isLoginButtonEnabled() {
        return isEnabled(LOGIN_BUTTON);
    }
}
```

### Dashboard Page Object

```java
// pages/DashboardPage.java
package pages;

import org.openqa.selenium.*;

public class DashboardPage extends BasePage {
    private static final By WELCOME_MESSAGE = By.cssSelector("[data-testid='welcome-message']");
    private static final By LOGOUT_BUTTON = By.cssSelector("[data-testid='logout-button']");
    private static final By USER_MENU = By.cssSelector("[data-testid='user-menu']");

    public DashboardPage(WebDriver driver) {
        super(driver);
        waitForPageLoad();
    }

    public boolean isLoaded() {
        return isDisplayed(WELCOME_MESSAGE);
    }

    public String getWelcomeText() {
        return getText(WELCOME_MESSAGE);
    }

    public LoginPage logout() {
        click(LOGOUT_BUTTON);
        waitForElementVisible(USERNAME_INPUT); // Wait for login page
        return new LoginPage(driver);
    }
}
```

### Test Using Page Objects

```java
// tests/LoginTest.java
package tests;

import org.junit.jupiter.api.*;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import pages.LoginPage;
import pages.DashboardPage;

import static org.junit.jupiter.api.Assertions.*;

@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class LoginTest {

    private WebDriver driver;
    private LoginPage loginPage;

    @BeforeAll
    void setUpDriver() {
        driver = new ChromeDriver();
    }

    @BeforeEach
    void setUp() {
        loginPage = LoginPage.open(driver);
    }

    @Test
    void testSuccessfulLogin() {
        // Act
        DashboardPage dashboardPage = loginPage.login("user@example.com", "password123");

        // Assert
        assertTrue(dashboardPage.isLoaded());
        assertTrue(dashboardPage.getWelcomeText().contains("Welcome"));
    }

    @Test
    void testInvalidCredentials() {
        // Act
        loginPage.login("invalid@example.com", "wrongpassword");

        // Assert
        assertTrue(loginPage.isErrorMessageDisplayed());
        assertTrue(loginPage.getErrorMessage().contains("Invalid credentials"));
    }

    @Test
    void testLoginButtonDisabledWhenFormInvalid() {
        // Act
        loginPage.enterUsername("test@example.com");

        // Assert
        assertFalse(loginPage.isLoginButtonEnabled());
    }

    @AfterAll
    void tearDown() {
        if (driver != null) {
            driver.quit();
        }
    }
}
```

## Anti-Patterns

### 1. Assertions in Page Objects

**Anti-Pattern:**
```typescript
async login(username: string, password: string): Promise<void> {
    await this.usernameInput.fill(username);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
    // DON'T: Assertions belong in tests
    expect(await this.page.title()).toBe('Dashboard');
}
```

**Correct Pattern:**
```typescript
async login(username: string, password: string): Promise<DashboardPage> {
    await this.enterUsername(username);
    await this.enterPassword(password);
    await this.clickLogin();
    return new DashboardPage(this.page);
}
```

### 2. Exposing Internal Locators

**Anti-Pattern:**
```typescript
class LoginPage {
    // DON'T: Expose internal locators directly
    getUsernameInput(): Locator {
        return this.usernameInput;
    }
}

// Test code
await loginPage.getUsernameInput().fill('user');
```

**Correct Pattern:**
```typescript
class LoginPage {
    // DO: Provide business methods
    async enterUsername(username: string): Promise<this> {
        await this.fillInput(this.usernameInput, username);
        return this;
    }
}

// Test code
await loginPage.enterUsername('user');
```

### 3. God Object (Too Large)

**Anti-Pattern:**
```typescript
// DON'T: One page object for everything
class ApplicationPage {
    // All pages and all actions...
    async login() { }
    async buyProduct() { }
    async viewProfile() { }
    async changeSettings() { }
    // ... 1000 lines of code
}
```

**Correct Pattern:**
```typescript
// DO: Separate page objects for each page
class LoginPage { /* login only */ }
class ProductsPage { /* products only */ }
class ProfilePage { /* profile only */ }
class SettingsPage { /* settings only */ }
```

### 4. Raw Selectors in Tests

**Anti-Pattern:**
```typescript
// DON'T: Raw selectors in test
test('login', async ({ page }) => {
    await page.goto('/login');
    await page.fill('#username', 'user');
    await page.fill('#password', 'pass');
    await page.click('button[type="submit"]');
});
```

**Correct Pattern:**
```typescript
// DO: Use page objects
test('login', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.navigate('/login');
    await loginPage.login('user', 'pass');
});
```

### 5. Methods Returning Nothing When They Should

**Anti-Pattern:**
```typescript
async clickLogin(): Promise<void> {
    await this.loginButton.click();
}
```

**Correct Pattern:**
```typescript
async clickLogin(): Promise<DashboardPage> {
    await this.loginButton.click();
    await this.page.waitForURL('**/dashboard');
    return new DashboardPage(this.page);
}
```

### 6. Not Waiting for Page Load

**Anti-Pattern:**
```typescript
constructor(page: Page) {
    this.page = page;
}
```

**Correct Pattern:**
```typescript
constructor(page: Page) {
    this.page = page;
    this.waitForLoad();
}

private async waitForLoad(): Promise<void> {
    await this.mainContent.waitFor({ state: 'visible' });
}
```

### 7. Hard-coded Wait Times

**Anti-Pattern:**
```typescript
async clickLogin(): Promise<DashboardPage> {
    await this.loginButton.click();
    await this.page.waitForTimeout(3000); // DON'T: Hard-coded wait
    return new DashboardPage(this.page);
}
```

**Correct Pattern:**
```typescript
async clickLogin(): Promise<DashboardPage> {
    await this.loginButton.click();
    await this.page.waitForURL('**/dashboard'); // DO: Wait for specific condition
    return new DashboardPage(this.page);
}
```

### 8. Not Handling Dynamic Content

**Anti-Pattern:**
```typescript
private readonly productItem = this.page.locator('.product-item:first-child');
```

**Correct Pattern:**
```typescript
getProductItemByName(name: string): Locator {
    return this.page.locator('.product-item').filter({ hasText: name });
}

// Usage
await this.getProductItemByName('iPhone').click();
```

### 9. Using General WebElement Instead of Specific Types

**Anti-Pattern (Selenium):**
```java
public void clickLogin() {
    // Not waiting for element
    driver.findElement(loginButton).click();
}
```

**Correct Pattern:**
```java
public DashboardPage clickLogin() {
    waitForElementClickable(LOGIN_BUTTON);
    click(LOGIN_BUTTON);
    return new DashboardPage(driver);
}
```

### 10. Not Reusing Common Elements

**Anti-Pattern:**
```typescript
class LoginPage {
    private readonly usernameInput = this.page.locator('[data-testid="username"]');
}

class RegisterPage {
    private readonly usernameInput = this.page.locator('[data-testid="username"]');
}
```

**Correct Pattern:**
```typescript
// Shared component
class UsernameInputComponent {
    constructor(private readonly page: Page, private readonly root: Locator) {}

    async fill(value: string): Promise<void> {
        await this.root.locator('[data-testid="username"]').fill(value);
    }
}

// Or shared selectors file
export const Selectors = {
    auth: {
        username: '[data-testid="username"]',
        password: '[data-testid="password"]',
    }
};
```

## Best Practices Summary

1. **One Page Object Per Page/Component**: Each page or major component gets its own class
2. **No Assertions in Page Objects**: Page objects perform actions, tests validate results
3. **Return Page Objects for Chaining**: Methods that navigate should return the new page object
4. **Use Meaningful Method Names**: Methods should describe business actions, not technical interactions
5. **Encapsulate Waits**: Page objects handle synchronization internally
6. **Hide Implementation Details**: Tests should not know about selectors or waits
7. **Use Page Factory/Manager**: Centralize page object creation and navigation
8. **Make Page Objects Immutable**: Avoid storing state that changes between tests
9. **Use Composition for Components**: Build complex pages from smaller component objects
10. **Keep Page Objects Focused**: Each page object should have a single, clear responsibility
