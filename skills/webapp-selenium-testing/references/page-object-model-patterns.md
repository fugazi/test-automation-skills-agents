# Page Object Model Fluent And Test Patterns

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original page-object-model.md. See the other related files in this folder.

## Fluent Interface Pattern

Design methods to return `this` or the next page object for method chaining:

```java
// [ok] Fluent chaining within same page
loginPage
    .enterUsername("user@test.com")
    .enterPassword("password123")
    .checkRememberMe()
    .clickLogin();

// [ok] Fluent navigation to next page
DashboardPage dashboard = loginPage
    .open()
    .loginAs("user@test.com", "password");

// [ok] Chain with component
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
