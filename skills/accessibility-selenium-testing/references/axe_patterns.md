# Axe-Core Patterns for Selenium Java

This reference provides reusable patterns and helper classes for implementing accessibility testing with axe-core in Selenium WebDriver projects.

---

## Maven Dependencies

```xml
<dependencies>
    <!-- Axe-core Selenium integration -->
    <dependency>
        <groupId>com.deque.html.axe-core</groupId>
        <artifactId>selenium</artifactId>
        <version>4.10.0</version>
    </dependency>

    <!-- JSON processing for reports -->
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
        <version>2.18.1</version>
    </dependency>
</dependencies>
```

---

## AccessibilityHelper Utility Class

A comprehensive helper class for accessibility testing:

```java
package com.example.utils;

import com.deque.html.axecore.results.CheckedNode;
import com.deque.html.axecore.results.Results;
import com.deque.html.axecore.results.Rule;
import com.deque.html.axecore.selenium.AxeBuilder;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.qameta.allure.Allure;
import io.qameta.allure.Step;
import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.WebDriver;

import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@Slf4j
public class AccessibilityHelper {

    // WCAG 2.1 AA tags (recommended default)
    private static final List<String> WCAG_21_AA_TAGS = List.of(
        "wcag2a", "wcag2aa", "wcag21a", "wcag21aa"
    );

    // Add best-practice for additional coverage
    private static final List<String> WCAG_WITH_BEST_PRACTICE = List.of(
        "wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "best-practice"
    );

    // Critical and Serious impacts that should fail CI
    private static final List<String> BLOCKING_IMPACTS = List.of("critical", "serious");

    private static final ObjectMapper objectMapper = new ObjectMapper();

    // =====================================================
    // Full Page Scans
    // =====================================================

    /**
     * Scan entire page for WCAG 2.1 AA violations.
     * Fails if ANY violations are found.
     */
    @Step("Verify page accessibility - WCAG 2.1 AA (strict)")
    public static void verifyPageAccessibility(WebDriver driver) {
        Results results = new AxeBuilder()
            .withTags(WCAG_21_AA_TAGS)
            .analyze(driver);

        logViolations(results.getViolations());
        attachResultsToAllure(results);

        assertThat(results.violationFree())
            .as("Accessibility violations found on: %s", driver.getCurrentUrl())
            .isTrue();
    }

    /**
     * Scan page with best-practice rules included.
     * More comprehensive but may have more false positives.
     */
    @Step("Verify page accessibility - WCAG 2.1 AA + Best Practice")
    public static void verifyPageAccessibilityWithBestPractice(WebDriver driver) {
        Results results = new AxeBuilder()
            .withTags(WCAG_WITH_BEST_PRACTICE)
            .analyze(driver);

        logViolations(results.getViolations());
        attachResultsToAllure(results);

        assertThat(results.violationFree())
            .as("Accessibility violations found on: %s", driver.getCurrentUrl())
            .isTrue();
    }

    /**
     * Scan page but only fail on Critical and Serious violations.
     * Logs Moderate and Minor for awareness.
     */
    @Step("Verify page accessibility - Critical/Serious only")
    public static void verifyCriticalAccessibility(WebDriver driver) {
        Results results = new AxeBuilder()
            .withTags(WCAG_21_AA_TAGS)
            .analyze(driver);

        List<Rule> criticalViolations = filterByImpact(results.getViolations(), BLOCKING_IMPACTS);
        List<Rule> otherViolations = filterExcludingImpact(results.getViolations(), BLOCKING_IMPACTS);

        // Log all violations
        if (!criticalViolations.isEmpty()) {
            log.error("BLOCKING VIOLATIONS:");
            logViolations(criticalViolations);
        }
        if (!otherViolations.isEmpty()) {
            log.warn("NON-BLOCKING VIOLATIONS (review recommended):");
            logViolations(otherViolations);
        }

        attachResultsToAllure(results);

        // Only fail on critical/serious
        assertThat(criticalViolations)
            .as("Critical/Serious accessibility violations found on: %s", driver.getCurrentUrl())
            .isEmpty();
    }

    // =====================================================
    // Component Scans
    // =====================================================

    /**
     * Scan specific component(s) by CSS selector.
     * Use for modals, forms, or isolated widgets.
     */
    @Step("Verify component accessibility: {selectors}")
    public static void verifyComponentAccessibility(WebDriver driver, String... selectors) {
        AxeBuilder builder = new AxeBuilder()
            .withTags(WCAG_21_AA_TAGS);

        for (String selector : selectors) {
            builder.include(selector);
        }

        Results results = builder.analyze(driver);
        logViolations(results.getViolations());
        attachResultsToAllure(results);

        assertThat(results.violationFree())
            .as("Component accessibility violations found for: %s", String.join(", ", selectors))
            .isTrue();
    }

    /**
     * Scan page excluding specific selectors.
     * Use for third-party widgets or known exceptions.
     * Always document the reason for exclusions.
     */
    @Step("Verify accessibility with exclusions")
    public static void verifyWithExclusions(WebDriver driver, List<String> exclusions) {
        AxeBuilder builder = new AxeBuilder()
            .withTags(WCAG_21_AA_TAGS);

        for (String exclusion : exclusions) {
            builder.exclude(exclusion);
            log.warn("EXCLUDING from a11y scan: {} (ensure this is documented)", exclusion);
        }

        Results results = builder.analyze(driver);
        logViolations(results.getViolations());
        attachResultsToAllure(results);

        assertThat(results.violationFree())
            .as("Accessibility violations found on: %s", driver.getCurrentUrl())
            .isTrue();
    }

    // =====================================================
    // Rule-Specific Scans
    // =====================================================

    /**
     * Run only specific rules.
     * Use when testing a specific aspect (e.g., color contrast only).
     */
    @Step("Verify specific rules: {rules}")
    public static void verifySpecificRules(WebDriver driver, List<String> rules) {
        Results results = new AxeBuilder()
            .withRules(rules)
            .analyze(driver);

        logViolations(results.getViolations());
        attachResultsToAllure(results);

        assertThat(results.violationFree())
            .as("Rule violations found: %s", String.join(", ", rules))
            .isTrue();
    }

    /**
     * Scan but disable specific rules.
     * Use carefully - document reason for each disabled rule.
     */
    @Step("Verify accessibility (rules disabled: {disabledRules})")
    public static void verifyWithDisabledRules(WebDriver driver, List<String> disabledRules) {
        for (String rule : disabledRules) {
            log.warn("DISABLING rule: {} (ensure this is documented)", rule);
        }

        Results results = new AxeBuilder()
            .withTags(WCAG_21_AA_TAGS)
            .disableRules(disabledRules)
            .analyze(driver);

        logViolations(results.getViolations());
        attachResultsToAllure(results);

        assertThat(results.violationFree())
            .as("Accessibility violations found on: %s", driver.getCurrentUrl())
            .isTrue();
    }

    // =====================================================
    // Results Processing
    // =====================================================

    /**
     * Get scan results without assertion.
     * Use when you need to process results manually.
     */
    public static Results getAccessibilityResults(WebDriver driver) {
        return new AxeBuilder()
            .withTags(WCAG_21_AA_TAGS)
            .analyze(driver);
    }

    /**
     * Get only violations (not all results).
     */
    public static List<Rule> getViolations(WebDriver driver) {
        return getAccessibilityResults(driver).getViolations();
    }

    /**
     * Get incomplete/needs-review items.
     */
    public static List<Rule> getIncomplete(WebDriver driver) {
        return getAccessibilityResults(driver).getIncomplete();
    }

    // =====================================================
    // Filtering Helpers
    // =====================================================

    /**
     * Filter violations by impact levels.
     */
    public static List<Rule> filterByImpact(List<Rule> violations, List<String> impacts) {
        return violations.stream()
            .filter(v -> impacts.contains(v.getImpact()))
            .toList();
    }

    /**
     * Filter violations excluding specified impact levels.
     */
    public static List<Rule> filterExcludingImpact(List<Rule> violations, List<String> impacts) {
        return violations.stream()
            .filter(v -> !impacts.contains(v.getImpact()))
            .toList();
    }

    /**
     * Filter violations by rule IDs.
     */
    public static List<Rule> filterByRuleId(List<Rule> violations, List<String> ruleIds) {
        return violations.stream()
            .filter(v -> ruleIds.contains(v.getId()))
            .toList();
    }

    /**
     * Get count of violations by impact.
     */
    public static long countByImpact(List<Rule> violations, String impact) {
        return violations.stream()
            .filter(v -> impact.equals(v.getImpact()))
            .count();
    }

    // =====================================================
    // Logging
    // =====================================================

    /**
     * Log violations in a human-readable format.
     * Includes Help URL for developer reference.
     */
    public static void logViolations(List<Rule> violations) {
        if (violations.isEmpty()) {
            log.info("✓ No accessibility violations found");
            return;
        }

        log.error("✗ Found {} accessibility violation(s):", violations.size());
        log.error("═══════════════════════════════════════════════════════════");

        for (Rule violation : violations) {
            log.error("");
            log.error("  [{} / {}]", violation.getImpact().toUpperCase(), violation.getId());
            log.error("  Description: {}", violation.getDescription());
            log.error("  Help: {}", violation.getHelpUrl());
            log.error("  WCAG Tags: {}", String.join(", ", violation.getTags()));

            for (CheckedNode node : violation.getNodes()) {
                log.error("    ├── Target: {}", String.join(" > ", node.getTarget()));
                log.error("    ├── HTML: {}", truncate(node.getHtml(), 120));
                if (node.getFailureSummary() != null) {
                    log.error("    └── Fix: {}", truncate(node.getFailureSummary(), 200));
                }
            }
        }
        log.error("═══════════════════════════════════════════════════════════");
    }

    /**
     * Generate summary statistics.
     */
    public static void logSummary(List<Rule> violations) {
        if (violations.isEmpty()) {
            log.info("Summary: 0 violations");
            return;
        }

        long critical = countByImpact(violations, "critical");
        long serious = countByImpact(violations, "serious");
        long moderate = countByImpact(violations, "moderate");
        long minor = countByImpact(violations, "minor");

        log.info("Summary: {} total violations", violations.size());
        log.info("  Critical: {}", critical);
        log.info("  Serious:  {}", serious);
        log.info("  Moderate: {}", moderate);
        log.info("  Minor:    {}", minor);
    }

    // =====================================================
    // Reporting
    // =====================================================

    /**
     * Attach axe results to Allure report as JSON.
     */
    public static void attachResultsToAllure(Results results) {
        try {
            String json = objectMapper.writerWithDefaultPrettyPrinter()
                .writeValueAsString(results);

            Allure.addAttachment(
                "Axe Results",
                "application/json",
                new ByteArrayInputStream(json.getBytes(StandardCharsets.UTF_8)),
                "json"
            );
        } catch (Exception e) {
            log.warn("Failed to attach axe results to Allure", e);
        }
    }

    /**
     * Save results to JSON file.
     * Useful for external reporting tools.
     */
    public static void saveResultsToFile(Results results, Path outputPath) {
        try {
            Files.createDirectories(outputPath.getParent());
            String json = objectMapper.writerWithDefaultPrettyPrinter()
                .writeValueAsString(results);
            Files.writeString(outputPath, json);
            log.info("Axe results saved to: {}", outputPath);
        } catch (Exception e) {
            log.error("Failed to save axe results to file", e);
        }
    }

    /**
     * Generate HTML report from results.
     */
    public static void saveHtmlReport(Results results, Path outputPath) {
        try {
            StringBuilder html = new StringBuilder();
            html.append("<!DOCTYPE html>\n<html lang=\"en\"><head>\n");
            html.append("<meta charset=\"UTF-8\">\n");
            html.append("<title>Accessibility Report</title>\n");
            html.append("<style>\n");
            html.append("body { font-family: system-ui, sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; }\n");
            html.append(".critical { border-left: 4px solid #d32f2f; background: #ffebee; }\n");
            html.append(".serious { border-left: 4px solid #f57c00; background: #fff3e0; }\n");
            html.append(".moderate { border-left: 4px solid #fbc02d; background: #fffde7; }\n");
            html.append(".minor { border-left: 4px solid #1976d2; background: #e3f2fd; }\n");
            html.append(".violation { margin: 16px 0; padding: 16px; border-radius: 4px; }\n");
            html.append("code { background: #f5f5f5; padding: 2px 6px; border-radius: 3px; }\n");
            html.append("</style>\n</head><body>\n");
            html.append("<h1>Accessibility Report</h1>\n");
            html.append("<p>URL: ").append(results.getUrl()).append("</p>\n");
            html.append("<p>Violations: ").append(results.getViolations().size()).append("</p>\n");

            for (Rule violation : results.getViolations()) {
                html.append("<div class=\"violation ").append(violation.getImpact()).append("\">\n");
                html.append("<h3>").append(violation.getId()).append(" (").append(violation.getImpact()).append(")</h3>\n");
                html.append("<p>").append(violation.getDescription()).append("</p>\n");
                html.append("<p><a href=\"").append(violation.getHelpUrl()).append("\" target=\"_blank\">How to fix</a></p>\n");

                for (CheckedNode node : violation.getNodes()) {
                    html.append("<p>Target: <code>").append(String.join(" > ", node.getTarget())).append("</code></p>\n");
                }
                html.append("</div>\n");
            }

            html.append("</body></html>");

            Files.createDirectories(outputPath.getParent());
            Files.writeString(outputPath, html.toString());
            log.info("HTML report saved to: {}", outputPath);
        } catch (Exception e) {
            log.error("Failed to save HTML report", e);
        }
    }

    // =====================================================
    // Utilities
    // =====================================================

    private static String truncate(String text, int maxLength) {
        if (text == null) return "";
        text = text.replaceAll("\\s+", " ").trim();
        if (text.length() <= maxLength) return text;
        return text.substring(0, maxLength - 3) + "...";
    }
}
```

---

## Common Axe Tags Reference

### WCAG Tags

| Tag             | Standard | Level     |
| --------------- | -------- | --------- |
| `wcag2a`        | WCAG 2.0 | Level A   |
| `wcag2aa`       | WCAG 2.0 | Level AA  |
| `wcag2aaa`      | WCAG 2.0 | Level AAA |
| `wcag21a`       | WCAG 2.1 | Level A   |
| `wcag21aa`      | WCAG 2.1 | Level AA  |
| `wcag21aaa`     | WCAG 2.1 | Level AAA |
| `wcag22aa`      | WCAG 2.2 | Level AA  |
| `best-practice` | Deque    | Industry  |

### Common Rule IDs

| Rule ID             | What it checks               |
| ------------------- | ---------------------------- |
| `color-contrast`    | Text contrast ratio          |
| `image-alt`         | Images have alt text         |
| `label`             | Form inputs have labels      |
| `button-name`       | Buttons have accessible name |
| `link-name`         | Links have accessible name   |
| `heading-order`     | Heading hierarchy            |
| `landmark-one-main` | Single main landmark         |
| `region`            | Content in landmarks         |
| `aria-valid-attr`   | Valid ARIA attributes        |
| `aria-roles`        | Valid ARIA roles             |

---

## Test Patterns

### Page-Level Test

```java
@Test
@Tag("a11y")
@Severity(SeverityLevel.CRITICAL)
@DisplayName("Homepage should be WCAG 2.1 AA compliant")
void homePage_shouldBeAccessible() {
    driver.get(baseUrl);
    waitForPageReady();

    AccessibilityHelper.verifyPageAccessibility(driver);
}
```

### Modal/Component Test

```java
@Test
@Tag("a11y")
@DisplayName("Login modal should be accessible")
void loginModal_shouldBeAccessible() {
    driver.get(baseUrl);

    // Open modal
    driver.findElement(By.id("login-btn")).click();
    wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("login-modal")));

    // Scan only the modal
    AccessibilityHelper.verifyComponentAccessibility(driver, "#login-modal");
}
```

### Multiple Pages Test

```java
@ParameterizedTest
@ValueSource(strings = {"/", "/about", "/contact", "/products"})
@Tag("a11y")
@DisplayName("All pages should be accessible")
void allPages_shouldBeAccessible(String path) {
    driver.get(baseUrl + path);
    waitForPageReady();

    AccessibilityHelper.verifyPageAccessibility(driver);
}
```

### Form States Test

```java
@Test
@Tag("a11y")
@DisplayName("Form error state should be accessible")
void formErrors_shouldBeAccessible() {
    driver.get(baseUrl + "/register");

    // Submit empty form to trigger errors
    driver.findElement(By.cssSelector("button[type='submit']")).click();
    wait.until(ExpectedConditions.visibilityOfElementLocated(By.className("error-message")));

    // Verify error state accessibility
    AccessibilityHelper.verifyPageAccessibility(driver);
}
```

### CI Threshold Test

```java
@Test
@Tag("a11y")
@Tag("ci")
@DisplayName("No critical accessibility violations allowed")
void page_shouldHaveNoCriticalViolations() {
    driver.get(baseUrl);
    waitForPageReady();

    // Only fail on critical/serious - warn on others
    AccessibilityHelper.verifyCriticalAccessibility(driver);
}
```

---

## Keyboard Navigation Testing

```java
/**
 * Test keyboard accessibility for interactive elements.
 */
public class KeyboardAccessibilityHelper {

    /**
     * Verify an element is reachable via Tab key.
     */
    @Step("Verify element is keyboard accessible: {targetSelector}")
    public static void verifyKeyboardReachable(WebDriver driver, String targetSelector, int maxTabs) {
        WebElement body = driver.findElement(By.tagName("body"));
        WebElement target = driver.findElement(By.cssSelector(targetSelector));

        // Start from body
        body.click();

        for (int i = 0; i < maxTabs; i++) {
            body.sendKeys(Keys.TAB);
            WebElement focused = driver.switchTo().activeElement();

            if (focused.equals(target)) {
                log.info("Element {} reached after {} tab(s)", targetSelector, i + 1);
                return;
            }
        }

        throw new AssertionError("Element " + targetSelector + " not reachable via Tab within " + maxTabs + " presses");
    }

    /**
     * Verify focus trap in modal.
     */
    @Step("Verify focus trap in: {modalSelector}")
    public static void verifyFocusTrap(WebDriver driver, String modalSelector, int maxTabs) {
        WebElement modal = driver.findElement(By.cssSelector(modalSelector));
        List<WebElement> focusableElements = modal.findElements(
            By.cssSelector("button, [href], input, select, textarea, [tabindex]:not([tabindex='-1'])")
        );

        assertThat(focusableElements).as("Modal should have focusable elements").isNotEmpty();

        // Tab through all elements to verify focus stays in modal
        WebElement firstElement = focusableElements.getFirst();
        firstElement.click();

        for (int i = 0; i < maxTabs; i++) {
            driver.switchTo().activeElement().sendKeys(Keys.TAB);
            WebElement focused = driver.switchTo().activeElement();

            assertThat(isDescendantOf(focused, modal))
                .as("Focus should stay within modal after Tab #%d", i + 1)
                .isTrue();
        }
    }

    /**
     * Verify Escape key closes modal.
     */
    @Step("Verify Escape closes: {modalSelector}")
    public static void verifyEscapeCloses(WebDriver driver, String modalSelector) {
        WebElement modal = driver.findElement(By.cssSelector(modalSelector));
        assertThat(modal.isDisplayed()).as("Modal should be visible initially").isTrue();

        modal.sendKeys(Keys.ESCAPE);

        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(2));
        wait.until(ExpectedConditions.invisibilityOf(modal));
    }

    private static boolean isDescendantOf(WebElement element, WebElement container) {
        try {
            return container.findElements(By.xpath(".//*")).contains(element) ||
                   container.equals(element);
        } catch (Exception e) {
            return false;
        }
    }
}
```

---

## CI/CD Integration Example

### GitHub Actions

```yaml
name: Accessibility Tests

on: [push, pull_request]

jobs:
  a11y:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: "21"
          distribution: "temurin"

      - name: Run Accessibility Tests
        run: |
          mvn test -Dgroups=a11y -Dheadless=true

      - name: Upload A11y Report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: a11y-results
          path: |
            target/a11y-results/
            target/allure-results/
```

### JUnit Platform Properties

```properties
# src/test/resources/junit-platform.properties

# Run a11y tests in parallel (different pages)
junit.jupiter.execution.parallel.enabled=true
junit.jupiter.execution.parallel.mode.default=same_thread
junit.jupiter.execution.parallel.mode.classes.default=concurrent
junit.jupiter.execution.parallel.config.strategy=dynamic
```
