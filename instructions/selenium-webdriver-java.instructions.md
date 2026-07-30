---
description: 'Selenium WebDriver 4+ / Java 21+ essentials — locator priority, explicit waits, POM, AssertJ Soft Assertions, Allure, modern Java. Applied to Java test and page-object files.'
applyTo: 'src/test/java/**/*.java, src/main/java/**/pages/**/*.java, src/main/java/**/base/**/*.java, src/main/java/**/factories/**/*.java, **/pom.xml'
---

# Selenium WebDriver + Java Essentials

Stack: Selenium 4.x · Java 21+ · JUnit 5 · AssertJ (Soft Assertions) · Allure · Lombok · Maven.

## Locator Priority (always follow)

1. `By.id()` / `By.name()` — fastest, most stable
2. `[data-testid]` / `[data-qa]` CSS — stable, explicit
3. Semantic CSS (`form#login input[type='email']`, `button[aria-label]`)
4. Class-based CSS — caution (changes with styling)
5. XPath — complex traversal only; **never** absolute XPath

## Non-Negotiable Rules

- **POM required**: all UI interaction through Page Object classes; Page Objects hold no assertions (except visibility)
- **No `Thread.sleep()`**: use `WebDriverWait` + `ExpectedConditions`; `Duration.ofSeconds()` for timeouts (Selenium 4)
- **Soft Assertions**: `SoftAssertions.assertSoftly(...)` for multiple validations, each with `.as("description")`
- **Fluent Page Objects**: methods return `this` or the next `Page` object
- **Naming**: class `FeatureNameTest`, method `should[Result]When[Action]()`
- **Reporting**: `@DisplayName`, `@Tag`, and Allure annotations (`@Epic`/`@Feature`/`@Story`/`@Severity`) on tests; `@Step` on Page Object actions
- **Logging**: `@Slf4j` only — no `System.out.println`
- **Driver lifecycle**: instantiated and quit in `BaseTest`; rely on Selenium Manager (built into 4.6+) to auto-resolve drivers — do NOT add any external driver-management library (Maven-only)
- **Modern Java 21+**: Records for DTOs, Streams `.toList()`, `Optional`, Pattern Matching, Sequenced Collections (`.getFirst()`/`.getLast()`)

## References

For full patterns (BasePage/BaseTest templates, WebDriver factory, complete Page Object & test examples, parallel execution, troubleshooting): use the `webapp-selenium-testing` skill (`references/page-object-model-*`, `references/wait-strategies-*`, `references/locator-strategies-*`).
