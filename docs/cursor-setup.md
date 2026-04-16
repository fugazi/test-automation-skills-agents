# Setup: Cursor IDE

Integration guide for using test-automation-skills-agents with [Cursor](https://cursor.sh).

## Installation

### Option A: Copy Skills to Cursor Rules

Copy relevant SKILL.md files to `.cursor/rules/` in Cursor's MDC format:

```bash
mkdir -p .cursor/rules

# Copy and rename skills to MDC format
cp test-automation-skills-agents/skills/playwright-e2e-testing/SKILL.md .cursor/rules/playwright-e2e-testing.mdc
cp test-automation-skills-agents/skills/api-testing/SKILL.md .cursor/rules/api-testing.mdc
cp test-automation-skills-agents/skills/webapp-selenium-testing/SKILL.md .cursor/rules/selenium-testing.mdc
cp test-automation-skills-agents/skills/a11y-playwright-testing/SKILL.md .cursor/rules/a11y-testing.mdc
cp test-automation-skills-agents/skills/playwright-regression-testing/SKILL.md .cursor/rules/regression-testing.mdc
```

### Option B: Reference the Full Directory

In `.cursorrules` at your project root:

```markdown
Reference the QA automation skills from: /path/to/test-automation-skills-agents/skills/
Follow the conventions in: /path/to/test-automation-skills-agents/instructions/
```

### Option C: Cursor MCP Integration

If using Cursor's MCP features, add the test-automation-skills-agents directory as a workspace context source in your Cursor settings.

## Cursor Rule Format

Convert SKILL.md frontmatter to Cursor's MDC format. Replace the YAML frontmatter:

```yaml
---
description: Use when writing Playwright E2E tests for TypeScript projects
globs: ["**/*.spec.ts", "**/tests/**/*.ts", "**/e2e/**/*.ts"]
alwaysApply: false
---
```

### MDC Conversion Guide

| SKILL.md Field | MDC Equivalent |
|---------------|----------------|
| `name` | Use as filename (e.g., `playwright-e2e-testing.mdc`) |
| `description` | `description` in MDC frontmatter |
| No glob equivalent | `globs` — add file patterns relevant to the skill |
| No apply equivalent | `alwaysApply: false` for on-demand, `true` for always-on |

## Recommended Rules

Create these rule files for the best experience:

| Rule File | Source Skill | Globs |
|-----------|-------------|-------|
| `playwright-e2e.mdc` | playwright-e2e-testing | `**/*.spec.ts`, `**/e2e/**/*.ts` |
| `playwright-api.mdc` | api-testing | `**/api/**/*.spec.ts`, `**/tests/api/**` |
| `selenium-java.mdc` | webapp-selenium-testing | `**/*Test.java`, `**/selenium/**/*.java` |
| `a11y-testing.mdc` | a11y-playwright-testing | `**/*a11y*.spec.ts`, `**/*accessibility*` |
| `regression.mdc` | playwright-regression-testing | `playwright.config.*`, `**/*.spec.ts` |
| `test-planner.mdc` | qa-test-planner | Always apply: `false` |

## Activating Skills

Skills activate in Cursor when:

1. **Globs match** — You open or edit a file matching the rule's `globs` patterns
2. **Explicit reference** — You mention the skill in your Cursor chat prompt
3. **@rules reference** — You type `@rules` and select the specific rule

Example prompts:

```
"Follow the playwright-e2e-testing rules to write tests for the login page"
"@rules playwright-api Create tests for the /users endpoint"
"Using the a11y-testing rules, add accessibility checks to the checkout flow"
```

## Using Agents

Copy agent files to `.cursor/rules/agents/`:

```bash
mkdir -p .cursor/rules/agents
cp test-automation-skills-agents/agents/*.agent.md .cursor/rules/agents/
```

Then reference agents in your Cursor chat:

```
"Read .cursor/rules/agents/flaky-test-hunter.agent.md and use that persona to investigate this flaky test"
"Following .cursor/rules/agents/api-tester-specialist.agent.md, create tests for the payments API"
```

Alternatively, paste the agent content directly into your chat when you need a specialist persona.

## Customization

### Create a QA Rules File

Create `.cursor/rules/qa-conventions.mdc` with project-specific conventions:

```yaml
---
description: QA automation conventions for this project
globs: ["**/*.spec.ts", "**/*Test.java"]
alwaysApply: true
---
```

```markdown
## Project QA Conventions

- Test base URL: http://localhost:3000
- Browser: Chromium only in CI, all browsers locally
- Page Objects in: tests/pages/
- Test data via: environment variables (never hardcode credentials)
- Assertion style: web-first assertions (Playwright) or AssertJ (Java)
```

### Combine Instructions

Copy instruction files as Cursor rules:

```bash
cp test-automation-skills-agents/instructions/playwright-typescript.instructions.md .cursor/rules/playwright-conventions.mdc
cp test-automation-skills-agents/instructions/selenium-webdriver-java.instructions.md .cursor/rules/selenium-conventions.mdc
cp test-automation-skills-agents/instructions/a11y.instructions.md .cursor/rules/a11y-conventions.mdc
```

Add MDC frontmatter with appropriate globs to each file.

## Tips

- **Set `alwaysApply: false`** for most skill rules. This prevents context bloat — rules load only when you're working on matching files.
- **Use specific globs.** Narrow glob patterns mean the right rule loads at the right time. Too broad = wasted context.
- **Keep agent files separate.** Don't merge agent content into skill rules. Agents are personas; skills are procedures.
- **Test your rules.** After setup, open a `.spec.ts` file and ask Cursor to suggest a test. It should follow the Playwright conventions from the loaded rule.
