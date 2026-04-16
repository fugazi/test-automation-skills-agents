````skill
---
name: accessibility-selenium-testing
description: Accessibility testing toolkit using Selenium WebDriver 4+ with Java 21+ and axe-core engine. Use when asked to validate WCAG 2.1/2.2 compliance, scan pages or components for a11y violations, test keyboard navigation, audit color contrast, check ARIA semantics, generate accessibility reports, filter axe rules, debug screen reader issues, or implement POUR principles (perceivable, operable, understandable, robust).
---

# Accessibility Testing with Selenium WebDriver & Axe Core

This skill enables automated accessibility analysis within the Selenium WebDriver framework using the **axe-core** engine to detect WCAG violations and best practice issues directly in the browser.

> **Activation:** This skill is triggered when you need to validate WCAG compliance, scan for accessibility violations, test keyboard navigation, audit ARIA semantics, or generate a11y reports.

## First Questions to Ask

- What app URL(s) or user flows are in scope (and what is explicitly out of scope)?
- Is there an existing Selenium setup and how is CI run?
- Which standard is the target (WCAG 2.1 AA by default), and are there org-specific policies?
- Which pages/components are highest risk (auth, checkout, forms, modals, navigation)?
- Are there known constraints (legacy markup, third-party widgets) that require exceptions?

## Prerequisites

| Component | Version | Purpose |
|-----------|---------|---------|
| Java JDK | 21+ | Runtime with modern features |
| Maven | 3.9+ | Dependency management |
| Selenium WebDriver | 4.x | Browser automation |
| axe-core-selenium | 4.10+ | Deque axe-core integration |
| JUnit 5 | 5.10+ | Test framework |
| AssertJ | 3.x | Fluent assertions for readable failures |
| Allure | 2.x | Reporting with a11y violation attachments |

> **Note:** Use `com.deque.html.axe-core:selenium` Maven dependency for axe integration.

---

## WCAG Compliance Levels

| Level | Requirement | Legal Status | Axe Tags |
|-------|-------------|--------------|----------|
| **Level A** | Basic accessibility (must have) | Minimum legal requirement | `wcag2a`, `wcag21a` |
| **Level AA** | Intermediate (should have) | Legal requirement in most jurisdictions | `wcag2aa`, `wcag21aa` |
| **Level AAA** | Advanced (nice to have) | Not typically required | `wcag2aaa`, `wcag21aaa` |
| **Best Practice** | Industry recommendations | Not WCAG but improves UX | `best-practice` |

---

## Axe-Core Tools Reference

### AxeBuilder Configuration

| Method | Purpose | Example |
|--------|---------|---------|
| `new AxeBuilder()` | Create scanner instance | Entry point |
| `.withTags(List<String>)` | Filter by WCAG tags | `wcag2aa`, `wcag21aa` |
| `.include(String)` | Scan specific selector | `#main-content` |
| `.exclude(String)` | Skip selector from scan | `.third-party-widget` |
| `.disableRules(List<String>)` | Disable specific rules | `color-contrast` |
| `.withRules(List<String>)` | Run only specific rules | `label`, `button-name` |
| `.analyze(WebDriver)` | Execute the scan | Returns `Results` |

### Results Object

| Method | Returns | Purpose |
|--------|---------|---------|
| `getViolations()` | `List<Rule>` | Rules that failed |
| `getPasses()` | `List<Rule>` | Rules that passed |
| `getIncomplete()` | `List<Rule>` | Rules needing manual review |
| `getInapplicable()` | `List<Rule>` | Rules not applicable to page |
| `violationFree()` | `boolean` | True if no violations |

### Violation Impact Levels

| Impact | Severity | CI Action |
|--------|----------|-----------|
| **Critical** | Blocks users completely | Always fail build |
| **Serious** | Significant barrier | Always fail build |
| **Moderate** | Some difficulty | Warn or fail |
| **Minor** | Inconvenience | Log for review |

---

## Core Capabilities

### 1. Axe Builder Analysis
- **Full Page Scan**: `new AxeBuilder().analyze(driver)`
- **Component Scan**: `new AxeBuilder().include("#my-component").analyze(driver)`
- **Rule Configuration**: `.withTags(List.of("wcag2a", "wcag2aa"))`
- **Exclusions**: `.exclude(".legacy-footer")` (use carefully, document reason)

### 2. Validation & Assertion
- Analyze `Results.getViolations()` - should be empty
- Filter by impact level (Critical, Serious, Moderate, Minor)
- Use AssertJ Soft Assertions to report all violations before failing

### 3. Reporting
- Log: Rule ID + Help URL + Selector for each violation
- Serialize `Results` to JSON for dashboards
- Attach to Allure reports

---

## Your Role

As an Accessibility Automation Specialist:

1. **Integration**: Configure axe-core with Selenium WebDriver
2. **Configuration**: Set up `AxeBuilder` with appropriate WCAG tags
3. **Analysis**: Parse results to identify violations by impact
4. **Assertion**: Fail on Critical/Serious, warn on Moderate/Minor
5. **Reporting**: Log Help URLs and selectors for remediation

---

## Step-by-Step Workflows

### Workflow 1: Add A11y Scan to Existing Test

1. **Add dependency to pom.xml**
   ```xml
   <dependency>
       <groupId>com.deque.html.axe-core</groupId>
       <artifactId>selenium</artifactId>
       <version>4.10.0</version>
   </dependency>
   ```

2. **Create AccessibilityHelper utility**
   - See [Axe Patterns Guide](references/axe_patterns.md)

3. **Add scan after page loads**
   ```java
   driver.get("https://example.com");
   waitForPageReady();
   AccessibilityHelper.verifyPageAccessibility(driver);
   ```

4. **Run and review violations**
   ```bash
   mvn test -Dtest=A11yTest
   ```

### Workflow 2: Test Specific Component

1. **Navigate to page with component visible**
2. **Trigger component state** (open modal, show dropdown)
3. **Scan only the component**
   ```java
   Results results = new AxeBuilder()
       .withTags(List.of("wcag2a", "wcag2aa"))
       .include("#login-modal")
       .analyze(driver);
   ```

4. **Assert and log**

### Workflow 3: Keyboard Navigation Audit

1. **Identify all interactive elements**
2. **Tab through the page programmatically**
   ```java
   element.sendKeys(Keys.TAB);
   WebElement focused = driver.switchTo().activeElement();
   ```
3. **Verify focus order is logical**
4. **Test Escape closes modals**
5. **Verify no keyboard traps**

### Workflow 4: CI Integration

1. **Configure headless browser**
   ```bash
   mvn test -Dheadless=true -Dgroups=a11y
   ```

2. **Set zero-tolerance for Critical/Serious**
   ```java
   long criticalCount = violations.stream()
       .filter(v -> List.of("critical", "serious").contains(v.getImpact()))
       .count();
   assertThat(criticalCount).isZero();
   ```

3. **Generate JSON report for tracking**

---

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

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Axe returns empty results | Page not fully loaded | Add explicit wait for page ready state |
| False positives on contrast | Dynamic themes | Test both light and dark modes |
| Violations in third-party widgets | Cannot modify vendor code | Use `.exclude()` with documented ticket |
| Incomplete rules | Requires manual review | Log for manual audit, don't auto-fail |
| Different results between runs | Async content loading | Ensure deterministic page state before scan |
| CI fails but local passes | Different viewport/browser | Use same headless config as CI |

---

## Best Practices Checklist

✅ **Wait for page ready** - Ensure DOM is stable before axe analysis
✅ **Scan unique states** - Test modal open, form error, empty state separately
✅ **Zero tolerance for Critical/Serious** - Always fail CI on these
✅ **Use specific tags** - Define `wcag2aa` vs `best-practice` to reduce noise
✅ **Log Help URLs** - Developers need the link to fix issues
✅ **Document exclusions** - Every `.exclude()` needs a JIRA ticket
✅ **Test keyboard navigation** - Tab order, focus traps, Escape key
✅ **Attach JSON reports** - Enable tracking violations over time
✅ **Combine with manual audit** - Axe catches ~30-50% of issues

---

## Guardrails (Important Limitations)

⚠️ **Automated tooling cannot prove full WCAG conformance** - only the presence of certain issues
⚠️ **Use automation to prevent regressions** - use manual audits for complete coverage
⚠️ **Prefer native HTML semantics** - use ARIA only when required
⚠️ **Never disable rules globally** - scope exceptions narrowly with documentation

---

## Triage by POUR Principles

| Principle | Focus Areas | Common Violations |
|-----------|-------------|-------------------|
| **Perceivable** | Text alternatives, captions, contrast, structure | Missing alt text, low contrast, missing labels |
| **Operable** | Keyboard access, focus order, bypass blocks | Keyboard traps, no skip link, focus not visible |
| **Understandable** | Labels, predictable behavior, error handling | Unclear instructions, unexpected changes |
| **Robust** | Valid HTML, ARIA, name/role/value | Invalid ARIA, duplicate IDs, missing roles |

---

## Running Tests

### Maven Commands

| Command | Purpose |
|---------|---------|
| `mvn test -Dgroups=a11y` | Run all accessibility tests |
| `mvn test -Dtest=A11yTest` | Run specific test class |
| `mvn test -Dheadless=true` | Run headless (CI mode) |
| `mvn allure:serve` | View Allure report with violations |

### CI/CD Integration

```yaml
- name: Run Accessibility Tests
  run: mvn test -Dgroups=a11y -Dheadless=true

- name: Upload A11y Report
  uses: actions/upload-artifact@v3
  with:
    name: a11y-report
    path: target/a11y-results/
```

---

## Common Rationalizations

> Common shortcuts and "good enough" excuses that erode test quality — and the reality behind each.

| Rationalization | Reality |
| --------------- | ------- |
| "Selenium isn't good for a11y testing" | axe-core + Selenium is battle-tested, CI-ready, and covers WCAG violations programmatically. |
| "We can just run a scan at the end" | Shift-left: catch violations as code is written. Late scans mean expensive fixes. |
| "The framework handles accessibility" | No framework auto-generates proper ARIA roles, labels, or keyboard interactions. |
| "We only need to test the homepage" | Every page a user visits must be accessible. Start with high-risk pages, expand coverage. |
| "Skip the contrast checks, designers fix that" | Automated contrast checks take seconds and prevent lawsuits. They are tests, not design reviews. |
| "Our users don't have disabilities" | ~15% of the global population has some form of disability. Accessibility is for everyone. |

---

## References

- [Axe Patterns Guide](references/axe_patterns.md) - AxeBuilder patterns and helpers
- [WCAG 2.1 AA Checklist](references/wcag21aa-checklist.md) - Manual audit checklist
- [Deque Axe Rules](https://dequeuniversity.com/rules/axe/4.10) - Rule descriptions
- [W3C WCAG 2.1](https://www.w3.org/TR/WCAG21/) - Official specification
- [WAI-ARIA Practices](https://www.w3.org/WAI/ARIA/apg/) - Widget patterns

---

## Quick Reference

| Task | Code Pattern |
|------|--------------|
| Full page scan | `new AxeBuilder().withTags(List.of("wcag2aa")).analyze(driver)` |
| Component scan | `new AxeBuilder().include("#selector").analyze(driver)` |
| Exclude element | `new AxeBuilder().exclude(".ignore").analyze(driver)` |
| Check violations | `results.getViolations().isEmpty()` |
| Filter critical | `.filter(v -> v.getImpact().equals("critical"))` |
| Get help URL | `violation.getHelpUrl()` |
| Tab navigation | `element.sendKeys(Keys.TAB)` |
| Get focused element | `driver.switchTo().activeElement()` |

---

## Verification

After completing this skill's workflow, confirm:

- [ ] **Axe WebDriver audit passes** — `AxeBuilder.analyze(driver)` returns zero violations
- [ ] **WCAG 2.1 AA compliance** — All rules for AA level pass
- [ ] **ARIA labels present** — All interactive elements have accessible names
- [ ] **Keyboard accessibility verified** — Tab navigation reaches all interactive elements
- [ ] **Violation report saved** — Accessibility results written to JSON/HTML file
- [ ] **Tests pass with Java 21+** — `mvn test -Dtest=*Accessibility*` passes

````
