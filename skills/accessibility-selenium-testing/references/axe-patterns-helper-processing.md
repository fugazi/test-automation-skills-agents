# Axe Patterns: AccessibilityHelper Results, Filtering, Logging, and Reporting

> Part of the `accessibility-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original axe-patterns.md. See the other related files in this folder.

```java
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
