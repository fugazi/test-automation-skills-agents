---
name: accessibility-selenium-testing
description: 'Accessibility testing toolkit using Selenium WebDriver 4+ with Java 21+ and axe-core engine. Use when asked to validate WCAG 2.1/2.2 compliance, scan pages or components for a11y violations, test keyboard navigation, audit color contrast, check ARIA semantics, generate accessibility reports, filter axe rules, debug screen reader issues, or implement POUR principles (perceivable, operable, understandable, robust).'
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

> **Target:** WCAG 2.1 AA (`wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa`). See [WCAG 2.1 spec](https://www.w3.org/TR/WCAG21/).

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

See [`references/code-patterns.md`](references/code-patterns.md) for full AxeBuilder scan patterns, violation logging, JUnit 5 integration, and CI/CD YAML.

Key snippet:

```java
Results results = new AxeBuilder()
    .withTags(List.of("wcag2a", "wcag2aa", "wcag21a", "wcag21aa"))
    .analyze(driver);
assertThat(results.violationFree()).as("A11y violations").isTrue();
```

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

## References

- [Axe Patterns Guide](references/axe_patterns.md) - AxeBuilder patterns and helpers
- [Axe-Core API Reference](references/axe-api-reference.md) - Full AxeBuilder config, Results object, and impact levels
- [WCAG 2.1 AA Checklist](references/wcag21aa-checklist.md) - Manual audit checklist
- [Deque Axe Rules](https://dequeuniversity.com/rules/axe/4.10) - Rule descriptions
- [W3C WCAG 2.1](https://www.w3.org/TR/WCAG21/) - Official specification
- [WAI-ARIA Practices](https://www.w3.org/WAI/ARIA/apg/) - Widget patterns

---

## Verification

- [ ] **Axe WebDriver audit passes** — `AxeBuilder.analyze(driver)` returns zero critical violations
- [ ] **Keyboard accessibility verified** — Tab navigation reaches all interactive elements
- [ ] **WCAG 2.1 AA compliance** — All rules for AA level pass
