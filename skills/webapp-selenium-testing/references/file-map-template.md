# File Map Template (Selenium Java)

When agents generate test code for a target project, they must follow this structure. Copy this section into the target project's CLAUDE.md or test configuration.

## Recommended Project Structure

```
src/
├── main/java/com/project/
│   ├── base/                   # BasePage with common waits and actions
│   ├── pages/{feature}/        # Page Object Model classes (*Page.java)
│   ├── components/             # Reusable UI components (Header, Modal)
│   ├── factories/              # WebDriverFactory, PageFactory
│   ├── models/                 # DTOs with Lombok (@Builder, @Getter)
│   └── utils/                  # WaitUtils, ConfigReader, FakerProvider
├── main/resources/
│   └── config.properties       # Environment configuration
└── test/java/com/project/
    ├── fixtures/               # BaseTest with setup/teardown
    ├── tests/{feature}/        # Test classes (*Test.java)
    └── utils/                  # Test-specific utilities
src/test/resources/
├── testdata/                   # JSON/CSV test data files
└── configs/                    # Environment-specific configs
```

## Naming Conventions

| Type        | Pattern                | Example                               |
| ----------- | ---------------------- | ------------------------------------- |
| Page Object | `{Feature}Page.java`   | `LoginPage.java`, `CartPage.java`     |
| Test Class  | `{Feature}Test.java`   | `LoginTest.java`, `CheckoutTest.java` |
| Base Class  | `Base{Type}.java`      | `BasePage.java`, `BaseTest.java`      |
| Helper      | `{Feature}Helper.java` | `ApiHelper.java`, `DateHelper.java`   |
| Data File   | `{entity}.json`        | `users.json`, `products.json`         |

## BaseTest Template

```java
package com.project.fixtures;

import com.project.factories.WebDriverFactory;
import io.qameta.allure.Allure;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.*;
import org.openqa.selenium.*;
import java.io.ByteArrayInputStream;

@Slf4j
public abstract class BaseTest {
    protected WebDriver driver;

    @RegisterExtension
    TestWatcher screenshotWatcher = new TestWatcher() {
        @Override
        public void testFailed(ExtensionContext context, Throwable cause) {
            if (driver != null) {
                byte[] screenshot = ((TakesScreenshot) driver).getScreenshotAs(OutputType.BYTES);
                Allure.addAttachment("Screenshot on failure", "image/png",
                    new ByteArrayInputStream(screenshot), ".png");
            }
        }
    };

    @BeforeEach
    void setUp(TestInfo testInfo) {
        log.info("Starting test: {}", testInfo.getDisplayName());
        driver = WebDriverFactory.createDriver();
        driver.manage().window().maximize();
    }

    @AfterEach
    void tearDown(TestInfo testInfo) {
        if (driver != null) {
            driver.quit();
            log.info("Completed test: {}", testInfo.getDisplayName());
        }
    }
}
```

## POM Template

```java
package com.project.pages.feature;

import com.project.base.BasePage;
import io.qameta.allure.Step;
import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.ExpectedConditions;

@Slf4j
public class LoginPage extends BasePage {
    private final By usernameInput = By.id("username");
    private final By passwordInput = By.id("password");
    private final By loginButton = By.cssSelector("[data-testid='login-btn']");

    public LoginPage(WebDriver driver) {
        super(driver);
    }

    @Step("Login with username: {username}")
    public HomePage login(String username, String password) {
        type(usernameInput, username);
        type(passwordInput, password);
        click(loginButton);
        return new HomePage(driver);
    }
}
```

## Test Class Template

```java
package com.project.tests.feature;

import com.project.fixtures.BaseTest;
import com.project.pages.feature.LoginPage;
import io.qameta.allure.*;
import org.assertj.core.api.SoftAssertions;
import org.junit.jupiter.api.*;

@Epic("Feature Epic")
@Feature("Feature Name")
class LoginTest extends BaseTest {

    private LoginPage loginPage;

    @BeforeEach
    void initPages() {
        loginPage = new LoginPage(driver);
    }

    @Test
    @Tag("smoke")
    @Severity(SeverityLevel.BLOCKER)
    @DisplayName("Should login successfully with valid credentials")
    void shouldLoginSuccessfullyWithValidCredentials() {
        var homePage = loginPage.login("standard_user", "secret_sauce");

        SoftAssertions.assertSoftly(softly -> {
            softly.assertThat(homePage.isDisplayed())
                .as("Home page should be visible after login")
                .isTrue();
        });
    }
}
```

## Usage

Copy the "Recommended Project Structure" section into the target project's CLAUDE.md under a `## File Map` heading. Agents will use this to place files in the correct directories.
