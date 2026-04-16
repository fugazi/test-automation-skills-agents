````markdown
# Locator Strategies Guide for Selenium WebDriver (Java)

Comprehensive guide for choosing and implementing the right locator strategy in Selenium tests.

---

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
// ✅ BEST: Direct ID
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
// ✅ GOOD: Test IDs (stable, explicit)
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

## CSS Selectors (Flexible)

Use semantic CSS selectors when IDs aren't available:

```java
// ✅ GOOD: Semantic CSS selectors
By.cssSelector("form#login input[type='email']")
By.cssSelector("button[aria-label='Close dialog']")
By.cssSelector("input[placeholder='Search...']")
By.cssSelector("table#users tbody tr")

// Attribute-based
By.cssSelector("[name='email']")
By.cssSelector("[type='submit']")
By.cssSelector("[role='button']")
By.cssSelector("[aria-expanded='true']")

// Combinators
By.cssSelector("div.container > form")          // Direct child
By.cssSelector("nav a")                          // Descendant
By.cssSelector("input + button")                 // Adjacent sibling
By.cssSelector("h1 ~ p")                         // General sibling

// Pseudo-selectors
By.cssSelector("li:first-child")
By.cssSelector("tr:nth-child(2)")
By.cssSelector("button:not([disabled])")
```

---

## Name and Class Locators

```java
// Name attribute (good for form fields)
By.name("username")
By.name("password")
By.name("remember-me")

// Class name (single class only)
By.className("btn-primary")
By.className("error-message")

// Multiple classes with CSS
By.cssSelector(".btn.btn-primary.large")
```

---

## Link Text Locators

For anchor (`<a>`) elements:

```java
// Exact text match
By.linkText("Sign up")
By.linkText("Forgot password?")

// Partial text match
By.partialLinkText("Sign")
By.partialLinkText("Learn more")
```

---

## XPath Locators (Use Sparingly)

Use XPath only when CSS selectors can't achieve the goal:

```java
// ⚠️ USE WITH CAUTION: XPath for complex scenarios

// Text-based (CSS can't do this)
By.xpath("//button[text()='Submit']")
By.xpath("//button[normalize-space()='Submit']")
By.xpath("//button[contains(text(),'Submit')]")

// Parent traversal (CSS can't do this)
By.xpath("//input[@id='email']/..")
By.xpath("//input[@id='email']/ancestor::form")

// Sibling navigation
By.xpath("//label[text()='Email']/following-sibling::input")
By.xpath("//td[text()='John']/preceding-sibling::td")

// Position-based (when needed)
By.xpath("(//button[@class='action'])[1]")
By.xpath("//table//tr[last()]")

// Attribute contains
By.xpath("//input[contains(@class,'error')]")
By.xpath("//div[starts-with(@id,'product-')]")

// ❌ NEVER: Absolute XPath
By.xpath("/html/body/div[1]/div[2]/form/button[3]")  // Extremely brittle!
```

---

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

## Avoiding Common Mistakes

### ❌ Wrong: Brittle CSS Selectors

```java
// Brittle - relies on styling classes
By.cssSelector("div.MuiBox-root > div.MuiContainer-root button.MuiButton-containedPrimary")
By.cssSelector(".styles__button___2K8Hx")  // CSS modules hash
```

### ✅ Right: Stable Selectors

```java
By.cssSelector("[data-testid='submit-button']")
By.cssSelector("button[type='submit']")
By.id("submit-button")
```

---

### ❌ Wrong: Absolute XPath

```java
By.xpath("/html/body/div[1]/div/div[2]/form/div[3]/button")
```

### ✅ Right: Relative XPath

```java
By.xpath("//form[@id='login']//button[@type='submit']")
```

---

### ❌ Wrong: Index Without Context

```java
By.xpath("(//button)[5]")  // Which button? Why 5?
```

### ✅ Right: Meaningful Context

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

## Quick Reference

| Need            | Locator                                         |
| --------------- | ----------------------------------------------- |
| Button by ID    | `By.id("submit-btn")`                           |
| Input by name   | `By.name("email")`                              |
| By test ID      | `By.cssSelector("[data-testid='name']")`        |
| By aria-label   | `By.cssSelector("[aria-label='Close']")`        |
| By type         | `By.cssSelector("input[type='password']")`      |
| Link by text    | `By.linkText("Sign up")`                        |
| Row in table    | `By.cssSelector("table tbody tr:nth-child(2)")` |
| By text (XPath) | `By.xpath("//button[text()='Submit']")`         |
| Parent element  | `By.xpath("//input[@id='x']/parent::div")`      |

---

## Locator Checklist

Before implementing a locator, verify:

- [ ] Is there a unique ID? → Use `By.id()`
- [ ] Is there a `data-testid`? → Use `By.cssSelector("[data-testid='x']")`
- [ ] Is there a unique `name`? → Use `By.name()`
- [ ] Can I use semantic CSS? → Use `By.cssSelector()`
- [ ] Do I need text matching? → Consider XPath
- [ ] Is it an anchor tag? → Consider `By.linkText()`
- [ ] Am I using absolute XPath? → **Refactor immediately!**
````
