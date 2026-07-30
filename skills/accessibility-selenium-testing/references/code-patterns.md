# code-patterns 

> Part of the `accessibility-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.
## Code Patterns

### Basic Full-Page Scan

```java
@Step("Verify page accessibility - WCAG 2.1 AA")
public void verifyPageAccessibility(WebDriver driver) {
    Results results = new AxeBuilder()
        .withTags(List.of("wcag2a", "wcag2aa", "wcag21a", "wcag21aa"))
        .analyze(driver);

    logViolations(results.getViolations());

    assertThat(results.violationFree())
        .as("Accessibility violations found on: %s", driver.getCurrentUrl())
        .isTrue();
}
```

### Component-Specific Scan

```java
@Step("Verify component accessibility: {selectors}")
public void verifyComponentAccessibility(WebDriver driver, String... selectors) {
    AxeBuilder builder = new AxeBuilder()
        .withTags(List.of("wcag2a", "wcag2aa"));

    for (String selector : selectors) {
        builder.include(selector);
    }

    Results results = builder.analyze(driver);
    logViolations(results.getViolations());

    assertThat(results.violationFree())
        .as("Component accessibility check failed")
        .isTrue();
}
```

### Filter by Impact Level

```java
@Step("Verify no critical accessibility violations")
public void verifyCriticalViolations(WebDriver driver) {
    Results results = new AxeBuilder()
        .withTags(List.of("wcag2a", "wcag2aa"))
        .analyze(driver);

    List<Rule> criticalViolations = results.getViolations().stream()
        .filter(v -> List.of("critical", "serious").contains(v.getImpact()))
        .toList();

    if (!criticalViolations.isEmpty()) {
        logViolations(criticalViolations);
    }

    assertThat(criticalViolations)
        .as("Critical/Serious accessibility violations found")
        .isEmpty();
}
```

### With Documented Exclusions

```java
/**
 * Scan with exclusions for known issues.
 * Exclusions must be documented with ticket reference.
 */
@Step("Verify accessibility with documented exclusions")
public void verifyWithExclusions(WebDriver driver) {
    Results results = new AxeBuilder()
        .withTags(List.of("wcag2a", "wcag2aa"))
        .exclude(".third-party-chat-widget")  // JIRA-1234: Vendor limitation
        .exclude("#legacy-footer")            // JIRA-5678: Scheduled for Q2 fix
        .analyze(driver);

    assertThat(results.violationFree()).isTrue();
}
```

### Violation Logger

```java
private void logViolations(List<Rule> violations) {
    if (violations.isEmpty()) {
        log.info("✓ No accessibility violations found");
        return;
    }

    log.error("✗ Found {} accessibility violations:", violations.size());
    for (Rule violation : violations) {
        log.error("  [{}/{}] {}",
            violation.getImpact().toUpperCase(),
            violation.getId(),
            violation.getDescription());
        log.error("    Help: {}", violation.getHelpUrl());

        for (CheckedNode node : violation.getNodes()) {
            log.error("    Target: {}", String.join(", ", node.getTarget()));
            log.error("    HTML: {}", truncate(node.getHtml(), 100));
        }
    }
}
```

### JUnit 5 Test Class

```java
@Epic("Accessibility")
@Feature("WCAG 2.1 AA Compliance")
class AccessibilityTest extends BaseTest {

    @Test
    @Tag("a11y")
    @Severity(SeverityLevel.CRITICAL)
    @DisplayName("Homepage should meet WCAG 2.1 AA standards")
    void homePage_shouldBeAccessible() {
        driver.get(ConfigReader.get("base.url"));
        waitForPageReady();

        Results results = new AxeBuilder()
            .withTags(List.of("wcag2a", "wcag2aa", "wcag21a", "wcag21aa"))
            .analyze(driver);

        attachResultsToAllure(results);

        SoftAssertions.assertSoftly(softly -> {
            softly.assertThat(results.violationFree())
                .as("Page should have no accessibility violations")
                .isTrue();
        });
    }

    @Test
    @Tag("a11y")
    @DisplayName("Login modal should be keyboard accessible")
    void loginModal_shouldBeKeyboardAccessible() {
        driver.get(ConfigReader.get("base.url"));

        // Open modal
        driver.findElement(By.id("login-btn")).click();
        waitForVisible(By.id("login-modal"));

        // Scan modal only
        Results results = new AxeBuilder()
            .withTags(List.of("wcag2a", "wcag2aa"))
            .include("#login-modal")
            .analyze(driver);

        assertThat(results.violationFree()).isTrue();

        // Test keyboard navigation
        WebElement modal = driver.findElement(By.id("login-modal"));
        WebElement firstInput = modal.findElement(By.cssSelector("input:first-of-type"));

        assertThat(driver.switchTo().activeElement())
            .as("Focus should be inside modal")
            .isEqualTo(firstInput);

        // Test Escape closes modal
        modal.sendKeys(Keys.ESCAPE);
        assertThat(isDisplayed(By.id("login-modal"))).isFalse();
    }
}
```

---

