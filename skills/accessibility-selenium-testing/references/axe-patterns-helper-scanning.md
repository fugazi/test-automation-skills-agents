# Axe Patterns: Maven Setup and AccessibilityHelper Scanning Methods

> Part of the `accessibility-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original axe-patterns.md. See the other related files in this folder.

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

```