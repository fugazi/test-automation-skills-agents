# Axe-Core API Reference

> Part of the `accessibility-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

## AxeBuilder Configuration

| Method | Purpose | Example |
|--------|---------|---------|
| `new AxeBuilder()` | Create scanner instance | Entry point |
| `.withTags(List<String>)` | Filter by WCAG tags | `wcag2aa`, `wcag21aa` |
| `.include(String)` | Scan specific selector | `#main-content` |
| `.exclude(String)` | Skip selector from scan | `.third-party-widget` |
| `.disableRules(List<String>)` | Disable specific rules | `color-contrast` |
| `.withRules(List<String>)` | Run only specific rules | `label`, `button-name` |
| `.analyze(WebDriver)` | Execute the scan | Returns `Results` |

## Results Object

| Method | Returns | Purpose |
|--------|---------|---------|
| `getViolations()` | `List<Rule>` | Rules that failed |
| `getPasses()` | `List<Rule>` | Rules that passed |
| `getIncomplete()` | `List<Rule>` | Rules needing manual review |
| `getInapplicable()` | `List<Rule>` | Rules not applicable to page |
| `violationFree()` | `boolean` | True if no violations |

## Violation Impact Levels

| Impact | Severity | CI Action |
|--------|----------|-----------|
| **Critical** | Blocks users completely | Always fail build |
| **Serious** | Significant barrier | Always fail build |
| **Moderate** | Some difficulty | Warn or fail |
| **Minor** | Inconvenience | Log for review |
