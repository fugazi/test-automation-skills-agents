# Locator Strategies Declaration Patterns

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original locator-strategies.md. See the other related files in this folder.

## Locator Declaration Patterns

### Page Object Locators

```java
public class LoginPage extends BasePage {
    // Declare locators as private final fields
    private final By usernameInput = By.id("username");
    private final By passwordInput = By.id("password");
    private final By loginButton = By.id("login-button");
    private final By errorMessage = By.cssSelector("[data-testid='error-alert']");
    private final By forgotPasswordLink = By.linkText("Forgot password?");

    public LoginPage(WebDriver driver) {
        super(driver);
    }

    // Use locators in action methods
    @Step("Enter username: {username}")
    public LoginPage enterUsername(String username) {
        type(usernameInput, username);
        return this;
    }
}
```

### Dynamic Locators

```java
public class ProductPage extends BasePage {

    // Dynamic locator with parameter
    private By productCard(String productId) {
        return By.cssSelector("[data-testid='product-card'][data-id='" + productId + "']");
    }

    // Dynamic locator with String.format
    private By rowByEmail(String email) {
        return By.xpath(String.format("//tr[contains(.,'%s')]", email));
    }

    // Dynamic locator for table cell
    private By cellInRow(int row, int col) {
        return By.cssSelector(String.format("table tbody tr:nth-child(%d) td:nth-child(%d)", row, col));
    }

    @Step("Click product: {productId}")
    public ProductDetailPage selectProduct(String productId) {
        click(productCard(productId));
        return new ProductDetailPage(driver);
    }
}
```

---

## Common Patterns

### Login Form

```java
private final By usernameInput = By.id("username");
private final By passwordInput = By.id("password");
private final By loginButton = By.id("login-button");
private final By errorAlert = By.cssSelector("[role='alert']");

@Step("Login with username: {username}")
public HomePage login(String username, String password) {
    type(usernameInput, username);
    type(passwordInput, password);
    click(loginButton);
    return new HomePage(driver);
}
```

### Data Table Row

```java
// Find row containing specific text
private By rowContaining(String text) {
    return By.xpath(String.format("//table//tr[contains(.,'%s')]", text));
}

// Find action button in specific row
private By editButtonInRow(String rowText) {
    return By.xpath(String.format("//tr[contains(.,'%s')]//button[contains(@class,'edit')]", rowText));
}

@Step("Edit user: {email}")
public EditUserPage editUser(String email) {
    click(editButtonInRow(email));
    return new EditUserPage(driver);
}
```

### Modal Dialog

```java
private final By modal = By.cssSelector("[role='dialog']");
private final By modalTitle = By.cssSelector("[role='dialog'] h2");
private final By modalCloseButton = By.cssSelector("[role='dialog'] button[aria-label='Close']");
private final By modalConfirmButton = By.cssSelector("[role='dialog'] button[data-testid='confirm']");

@Step("Confirm action in modal")
public void confirmModal() {
    waitForVisible(modal);
    click(modalConfirmButton);
    waitForInvisible(modal);
}
```

### Navigation Menu

```java
private final By navMenu = By.cssSelector("nav[role='navigation']");
private final By hamburgerButton = By.cssSelector("button[aria-label='Menu']");

private By navLink(String text) {
    return By.cssSelector(String.format("nav a[href*='%s']", text.toLowerCase()));
}

@Step("Navigate to: {section}")
public void navigateTo(String section) {
    click(navLink(section));
}
```

---
