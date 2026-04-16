---
description: 'Selenium WebDriver 4+ with Java 21+ test generation instructions. Standards for UI automation using Page Object Model, JUnit 5, AssertJ Soft Assertions, Allure reporting, and modern Java features (Records, Streams, Pattern Matching).'
applyTo: 'src/test/java/**/*.java, src/main/java/**/pages/**/*.java, src/main/java/**/base/**/*.java, src/main/java/**/factories/**/*.java, **/pom.xml'
---

# Selenium WebDriver + Java Test Automation Guidelines

## Prerequisites & Technology Stack

| Component          | Version | Purpose                                                       |
| ------------------ | ------- | ------------------------------------------------------------- |
| Java               | 21+     | Language runtime (Records, Pattern Matching, Virtual Threads) |
| Selenium WebDriver | 4.x     | Browser automation                                            |
| JUnit 5            | 5.10+   | Test framework                                                |
| AssertJ            | 3.x     | Fluent assertions with Soft Assertions                        |
| Allure             | 2.x     | Test reporting and documentation                              |
| Lombok             | 1.18+   | Boilerplate reduction (@Slf4j, @Builder)                      |
| JavaFaker          | 2.x     | Dynamic test data generation                                  |
| Jackson            | 2.x     | JSON serialization for API/DTOs                               |
| HttpClient         | 5.x     | API interactions for test setup                               |

---

## Locator Strategy (Priority Order)

Use locators that maximize stability and maintainability:

```java
// ✅ BEST: ID-based (fastest, most stable)
By.id("login-button")
By.name("username")

// ✅ GOOD: Test IDs (stable, explicit)
By.cssSelector("[data-testid='submit-button']")
By.cssSelector("[data-qa='user-avatar']")

// ✅ GOOD: Semantic CSS selectors
By.cssSelector("form#login input[type='email']")
By.cssSelector("button[aria-label='Close dialog']")

// ⚠️ USE WITH CAUTION: Class-based (can change with styling)
By.className("btn-primary")
By.cssSelector(".card-header .title")

// ⚠️ USE WITH CAUTION: XPath (only for complex DOM traversal)
By.xpath("//table[@id='users']//tr[contains(@class,'active')]")
By.xpath("//button[normalize-space()='Submit']")

// ❌ NEVER: Fragile absolute XPath
By.xpath("/html/body/div[1]/div[2]/button[3]")
```

### Locator Declaration Pattern

```java
// Declare as private final with descriptive names
private final By usernameInput = By.id("username");
private final By passwordInput = By.id("password");
private final By loginButton = By.cssSelector("[data-testid='login-btn']");
private final By errorMessage = By.cssSelector(".alert-danger");
```

---

## Code Quality Standards

### Page Object Model (POM)

- Every test **must** interact with UI through Page Object classes
- Encapsulate element locators and interaction logic within Page Objects
- Page Objects should **never** contain assertions (except visibility checks)
- Design methods with **Fluent Interface**: return `this` or the next `Page` object

### Explicit Waits

- **Never** use `Thread.sleep()` under any circumstances
- Use `WebDriverWait` with `ExpectedConditions` for all dynamic elements
- Standardize timeout using `Duration.ofSeconds()` (Selenium 4 compliance)

### Clean Code Principles

- Follow **SOLID** principles throughout
- Tests focus on **business logic**, Page Objects on **implementation details**
- Use meaningful variable names for `WebElement` instances

---

## Modern Java Standards (21+)

| Feature                   | Usage                                                               |
| ------------------------- | ------------------------------------------------------------------- |
| **Records**               | Immutable data carriers for test data, configuration, API responses |
| **Streams API**           | Collection processing with lambda expressions                       |
| **Optional**              | Handle nullable values, avoid `NullPointerException`                |
| **Pattern Matching**      | Type checks with `instanceof` patterns                              |
| **Sequenced Collections** | Use `.getFirst()`, `.getLast()` instead of index access             |
| **Text Blocks**           | Multi-line strings for JSON payloads, SQL queries                   |
| **Virtual Threads**       | Parallel test execution (Project Loom)                              |

```java
// Record for test data
public record UserCredentials(String username, String password) {}

// Sequenced Collections
var firstItem = items.getFirst();
var lastItem = items.getLast();

// Pattern Matching
if (element instanceof WebElement we && we.isDisplayed()) {
    we.click();
}

// Streams with toList()
var names = elements.stream()
    .map(WebElement::getText)
    .filter(text -> !text.isBlank())
    .toList();
```

---

## Test Structure (JUnit 5)

### Annotations

| Annotation                 | Purpose                                 |
| -------------------------- | --------------------------------------- |
| `@Test`                    | Mark test methods                       |
| `@BeforeEach`              | Setup before each test                  |
| `@AfterEach`               | Teardown after each test                |
| `@BeforeAll` / `@AfterAll` | Suite-level setup/teardown              |
| `@DisplayName`             | Human-readable test description         |
| `@Tag`                     | Test categorization (smoke, regression) |
| `@ParameterizedTest`       | Data-driven tests                       |
| `@Disabled`                | Skip test with reason                   |

### Naming Conventions

- **Class**: `FeatureNameTest.java` (e.g., `LoginTest.java`)
- **Method**: `should[ExpectedResult]When[Action]()` (e.g., `shouldShowErrorWhenInvalidCredentials()`)

### Allure Reporting Annotations

| Annotation     | Purpose                                                   |
| -------------- | --------------------------------------------------------- |
| `@Epic`        | High-level business capability                            |
| `@Feature`     | Feature under test                                        |
| `@Story`       | User story reference                                      |
| `@Severity`    | Test priority (BLOCKER, CRITICAL, NORMAL, MINOR, TRIVIAL) |
| `@Description` | Detailed test description                                 |
| `@Step`        | Action step in Page Object methods                        |

---

## Assertion Best Practices (AssertJ Soft Assertions)

**Mandatory**: Use Soft Assertions for multiple validations in a single test.

```java
// ✅ CORRECT: Soft Assertions with descriptive messages
SoftAssertions.assertSoftly(softly -> {
    softly.assertThat(page.getHeaderText())
        .as("Page header should display 'Products'")
        .isEqualToIgnoringCase("Products");

    softly.assertThat(page.getItemCount())
        .as("Inventory should have items")
        .isGreaterThan(0);

    softly.assertThat(page.isCartEmpty())
        .as("Cart should be empty initially")
        .isTrue();
});

// ✅ Collection Assertions
softly.assertThat(productNames)
    .as("Product list")
    .hasSize(6)
    .contains("Backpack", "Bike Light")
    .doesNotContainNull();
```

**Always** use `.as("description")` before assertions for clear failure messages.

---

## File Organization (Maven Standard)

```
src/
├── main/java/com/project/
│   ├── base/           # BasePage, BaseComponent
│   ├── pages/          # Page Objects with @Step annotations
│   ├── components/     # Reusable UI components (Header, Modal, Table)
│   ├── factories/      # WebDriverFactory, PageFactory
│   ├── models/         # DTOs with Lombok (@Builder, @Getter)
│   ├── enums/          # Application enumerations
│   └── utils/          # WaitUtils, ConfigReader, FakerProvider
├── main/resources/
│   └── config.properties   # Environment configuration
└── test/java/com/project/
    └── tests/          # Test classes with Soft Assertions
```

---

## Base Classes

### BasePage

```java
package com.project.base;

import io.qameta.allure.Step;
import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.*;
import java.time.Duration;

@Slf4j
public abstract class BasePage {
    protected final WebDriver driver;
    protected final WebDriverWait wait;
    private static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(15);

    protected BasePage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, DEFAULT_TIMEOUT);
    }

    protected WebElement waitForVisible(By locator) {
        log.debug("Waiting for element visible: {}", locator);
        return wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    protected WebElement waitForClickable(By locator) {
        log.debug("Waiting for element clickable: {}", locator);
        return wait.until(ExpectedConditions.elementToBeClickable(locator));
    }

    @Step("Click on element: {locator}")
    protected void click(By locator) {
        waitForClickable(locator).click();
    }

    @Step("Enter text '{text}' in field: {locator}")
    protected void type(By locator, String text) {
        var element = waitForVisible(locator);
        element.clear();
        element.sendKeys(text);
    }

    protected String getText(By locator) {
        return waitForVisible(locator).getText();
    }

    protected boolean isDisplayed(By locator) {
        try {
            return driver.findElement(locator).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    protected void waitForUrlContains(String urlPart) {
        wait.until(ExpectedConditions.urlContains(urlPart));
    }
}
```

### BaseTest

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
    protected HomePage homePage;

    @BeforeEach
    void setUp(TestInfo testInfo) {
        log.info("Starting test: {}", testInfo.getDisplayName());
        driver = WebDriverFactory.createDriver();
        driver.manage().window().maximize();
        initializePages();
        navigateToBaseUrl();
    }

    @AfterEach
    void tearDown(TestInfo testInfo) {
        if (driver != null) {
            captureScreenshotOnFailure(testInfo);
            driver.quit();
            log.info("Completed test: {}", testInfo.getDisplayName());
        }
    }

    private void initializePages() {
        loginPage = new LoginPage(driver);
        homePage = new HomePage(driver);
    }

    private void navigateToBaseUrl() {
        var baseUrl = ConfigReader.get("base.url");
        driver.get(baseUrl);
    }

    private void captureScreenshotOnFailure(TestInfo testInfo) {
        try {
            byte[] screenshot = ((TakesScreenshot) driver).getScreenshotAs(OutputType.BYTES);
            Allure.addAttachment("Screenshot", "image/png",
                new ByteArrayInputStream(screenshot), "png");
        } catch (Exception e) {
            log.warn("Failed to capture screenshot: {}", e.getMessage());
        }
    }
}
```

---

## WebDriver Factory

```java
package com.project.factories;

import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.*;
import org.openqa.selenium.edge.*;
import org.openqa.selenium.firefox.*;
import java.time.Duration;

@Slf4j
public class WebDriverFactory {
    private static final Duration IMPLICIT_WAIT = Duration.ofSeconds(5);

    public static WebDriver createDriver() {
        var browser = ConfigReader.get("browser", "chrome").toLowerCase();
        log.info("Creating WebDriver for browser: {}", browser);

        WebDriver driver = switch (browser) {
            case "firefox" -> createFirefoxDriver();
            case "edge" -> createEdgeDriver();
            default -> createChromeDriver();
        };

        driver.manage().timeouts().implicitlyWait(IMPLICIT_WAIT);
        return driver;
    }

    private static WebDriver createChromeDriver() {
        var options = new ChromeOptions();
        options.addArguments("--disable-notifications", "--start-maximized");
        if (isHeadless()) options.addArguments("--headless=new");
        return new ChromeDriver(options);
    }

    private static WebDriver createFirefoxDriver() {
        var options = new FirefoxOptions();
        if (isHeadless()) options.addArguments("-headless");
        return new FirefoxDriver(options);
    }

    private static WebDriver createEdgeDriver() {
        var options = new EdgeOptions();
        if (isHeadless()) options.addArguments("--headless=new");
        return new EdgeDriver(options);
    }

    private static boolean isHeadless() {
        return Boolean.parseBoolean(ConfigReader.get("headless", "false"));
    }
}
```

---

## Page Object Example

```java
package com.project.pages;

import com.project.base.BasePage;
import io.qameta.allure.Step;
import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.*;

@Slf4j
public class LoginPage extends BasePage {
    private final By usernameInput = By.id("user-name");
    private final By passwordInput = By.id("password");
    private final By loginButton = By.id("login-button");
    private final By errorMessage = By.cssSelector("[data-test='error']");

    public LoginPage(WebDriver driver) {
        super(driver);
    }

    @Step("Login with username: {username}")
    public HomePage login(String username, String password) {
        log.info("Logging in as: {}", username);
        type(usernameInput, username);
        type(passwordInput, password);
        click(loginButton);
        return new HomePage(driver);
    }

    @Step("Get error message text")
    public String getErrorMessage() {
        return getText(errorMessage);
    }

    public boolean isErrorDisplayed() {
        return isDisplayed(errorMessage);
    }
}
```

---

## Test Class Example

```java
package com.project.tests;

import com.project.base.BaseTest;
import io.qameta.allure.*;
import net.datafaker.Faker;
import org.assertj.core.api.SoftAssertions;
import org.junit.jupiter.api.*;
import org.junit.jupiter.params.*;
import org.junit.jupiter.params.provider.*;

@Epic("Authentication")
@Feature("Login")
class LoginTest extends BaseTest {
    private final Faker faker = new Faker();

    @Test
    @Tag("smoke")
    @Severity(SeverityLevel.BLOCKER)
    @DisplayName("Should login successfully with valid credentials")
    void shouldLoginSuccessfullyWithValidCredentials() {
        // Act
        var homePage = loginPage.login("standard_user", "secret_sauce");

        // Assert
        SoftAssertions.assertSoftly(softly -> {
            softly.assertThat(homePage.isDisplayed())
                .as("Home page should be visible after login")
                .isTrue();
            softly.assertThat(homePage.getTitle())
                .as("Page title")
                .containsIgnoringCase("Products");
        });
    }

    @ParameterizedTest(name = "Login fails with {0}")
    @Tag("regression")
    @Severity(SeverityLevel.CRITICAL)
    @CsvSource({
        "locked_out_user, secret_sauce, locked out",
        "invalid_user, wrong_pass, do not match"
    })
    @DisplayName("Should show error for invalid login attempts")
    void shouldShowErrorForInvalidCredentials(String user, String pass, String expectedError) {
        // Act
        loginPage.login(user, pass);

        // Assert
        SoftAssertions.assertSoftly(softly -> {
            softly.assertThat(loginPage.isErrorDisplayed())
                .as("Error message visibility")
                .isTrue();
            softly.assertThat(loginPage.getErrorMessage())
                .as("Error message content")
                .containsIgnoringCase(expectedError);
        });
    }
}
```

---

## Advanced Patterns

### Retry Mechanism (JUnit 5)

```java
@RetryingTest(3)  // Requires junit-pioneer dependency
@DisplayName("Flaky test with retry")
void flakyTestWithRetry() {
    // Test logic
}
```

### Parallel Execution (junit-platform.properties)

```properties
junit.jupiter.execution.parallel.enabled=true
junit.jupiter.execution.parallel.mode.default=concurrent
junit.jupiter.execution.parallel.config.strategy=fixed
junit.jupiter.execution.parallel.config.fixed.parallelism=4
```

### CI/CD Integration (GitHub Actions)

```yaml
- name: Run Selenium Tests
  run: mvn clean test -Dbrowser=chrome -Dheadless=true

- name: Generate Allure Report
  run: mvn allure:report
```

---

## Test Execution Strategy

1. **Local Development**: Run with UI mode for debugging

   ```bash
   mvn test -Dtest=LoginTest -Dheadless=false
   ```

2. **CI Pipeline**: Run headless with parallel execution

   ```bash
   mvn clean test -Dheadless=true -DforkCount=4
   ```

3. **Smoke Tests**: Run critical path only

   ```bash
   mvn test -Dgroups=smoke
   ```

4. **Generate Reports**:
   ```bash
   mvn allure:serve
   ```

---

## Troubleshooting

| Problem                 | Cause                               | Solution                                      |
| ----------------------- | ----------------------------------- | --------------------------------------------- |
| Element not found       | Element not loaded yet              | Use explicit wait with `ExpectedConditions`   |
| Stale element reference | DOM changed after locating          | Re-locate element before interaction          |
| Click intercepted       | Overlay or another element blocking | Scroll into view or wait for overlay to close |
| Timeout Exception       | Element never became visible        | Verify locator, check for iframes             |
| Session not created     | Driver/browser version mismatch     | Update WebDriverManager or browser            |
| Flaky tests             | Race conditions, timing issues      | Add proper waits, use stable locators         |

---

## Quality Checklist

Before finalizing tests, ensure:

### Core Requirements

- [ ] No `Thread.sleep()` in the codebase
- [ ] All UI interactions through Page Objects
- [ ] Explicit waits for all dynamic elements
- [ ] Driver instantiated/closed in BaseTest
- [ ] `@DisplayName` and `@Tag` on all test methods

### Code Quality

- [ ] CamelCase naming conventions followed
- [ ] `@Slf4j` for all logging (no `System.out.println`)
- [ ] `@Step` in all Page Object action methods
- [ ] `Duration` for timeouts (Selenium 4)
- [ ] Page Object methods return `this` or next Page

### Assertions & Data

- [ ] AssertJ Soft Assertions with `.as()` messages
- [ ] `Faker` for dynamic test data
- [ ] `@ParameterizedTest` for data-driven tests

### Modern Java

- [ ] Records for immutable data carriers
- [ ] Streams API with `.toList()` (not `Collectors.toList()`)
- [ ] `Optional` for nullable values
- [ ] Pattern Matching where applicable
- [ ] Sequenced Collections (`.getFirst()`, `.getLast()`)

### Integration

- [ ] Lombok DTOs with `@Builder`, `@Getter` for API models
- [ ] Jackson `@JsonProperty` for API response mapping
- [ ] Allure annotations (`@Epic`, `@Feature`, `@Severity`)
