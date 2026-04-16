# Setup: Gemini CLI

Integration guide for using test-automation-skills-agents with [Gemini CLI](https://github.com/google-gemini/gemini-cli).

## Installation

### Option A: GEMINI.md Configuration (Recommended)

Add to your project's `GEMINI.md`:

```markdown
## QA Automation Skills & Agents

This project uses test-automation-skills-agents for QA automation guidance.

### Key Conventions

- Playwright (TypeScript) for E2E and API testing
- Selenium + REST Assured (Java 21+) for Java-based testing
- Custom fixtures for dependency injection (Playwright)
- Explicit waits with WebDriverWait (Selenium) — never Thread.sleep()
- Follow Test Orchestration Pattern for AI-driven test workflows

### Skills Location

Skills are in: /path/to/test-automation-skills-agents/skills/
Agents are in: /path/to/test-automation-skills-agents/agents/
Instructions are in: /path/to/test-automation-skills-agents/instructions/
```

### Option B: Clone and Reference

```bash
git clone https://github.com/fugazi/test-automation-skills-agents.git
```

Then reference specific files in your Gemini CLI sessions:

```
"Read /path/to/test-automation-skills-agents/skills/playwright-e2e-testing/SKILL.md and follow its workflow to write tests for the login page"
```

### Option C: Copy into Project

Copy the skills and instructions you need directly into your project:

```bash
# Copy all skills
cp -r test-automation-skills-agents/skills/ ./qa-skills/

# Copy instructions
cp -r test-automation-skills-agents/instructions/ ./qa-instructions/

# Copy agents
cp -r test-automation-skills-agents/agents/ ./qa-agents/
```

Reference these directories in your `GEMINI.md`.

## How Skills Work with Gemini CLI

Gemini CLI discovers skills through configuration. The SKILL.md frontmatter `description` field tells Gemini when to activate each skill.

To enable skill auto-discovery, list your skills in `GEMINI.md`:

```markdown
### Available Skills

| Skill                          | When to Use                                |
| ------------------------------ | ------------------------------------------ |
| playwright-e2e-testing         | Writing Playwright E2E tests               |
| api-testing                    | Creating REST/GraphQL API tests            |
| webapp-selenium-testing        | Writing Selenium Java tests                |
| a11y-playwright-testing        | Accessibility testing with Playwright      |
| accessibility-selenium-testing | Accessibility testing with Selenium        |
| playwright-regression-testing  | Regression suite strategy and optimization |
| qa-manual-istqb                | ISTQB-aligned test artifacts               |
| qa-test-planner                | Test plans, test cases, bug reports        |
| playwright-cli                 | Browser automation via CLI                 |
| webapp-playwright-testing      | Live browser testing and debugging         |
```

## Activating Skills

Reference skills explicitly in your Gemini CLI prompts:

```
"Follow the playwright-e2e-testing skill to create tests for the checkout flow"
"Use the api-testing skill to design REST Assured tests for the /orders endpoint"
"Apply the a11y-playwright-testing skill to audit the login page for WCAG compliance"
```

## Using Agents

Reference agent files in your Gemini session:

```
"Read agents/playwright-test-planner.agent.md and use that persona to create a test plan for the user registration flow"
```

Or paste agent content directly:

```
"Act as the Flaky Test Hunter agent defined in agents/flaky-test-hunter.agent.md. Investigate why this test fails intermittently:

[Test code or error output]"
```

### Agent Quick Reference

| Agent                     | Invocation                                                                    |
| ------------------------- | ----------------------------------------------------------------------------- |
| Playwright Test Planner   | "Use the playwright-test-planner agent to create a test plan for..."          |
| Playwright Test Generator | "Use the playwright-test-generator agent to generate tests from this plan..." |
| Playwright Test Healer    | "Use the playwright-test-healer agent to fix this failing test..."            |
| API Tester Specialist     | "Use the api-tester-specialist agent to design API tests for..."              |
| Selenium Test Specialist  | "Use the selenium-test-specialist agent to create Java tests for..."          |
| Flaky Test Hunter         | "Use the flaky-test-hunter agent to investigate this flaky test..."           |
| Test Refactor Specialist  | "Use the test-refactor-specialist agent to refactor this test suite..."       |

## Customization

### Project-Specific GEMINI.md

Tailor the configuration to your project:

```markdown
## QA Automation Configuration

### Tech Stack

- Framework: Playwright 1.40+
- Language: TypeScript 5.x
- Runner: @playwright/test
- Base URL: http://localhost:3000

### Conventions

- Page Objects in: src/pages/
- Tests in: tests/
- Fixtures in: tests/fixtures/
- Test data via: environment variables

### Agent Preferences

- Default agent: playwright-test-generator
- For flaky tests: flaky-test-hunter
- For API work: api-tester-specialist
```

### Skill Selection

Only reference the skills relevant to your project:

- **Playwright + TypeScript project**: `playwright-e2e-testing`, `api-testing`, `a11y-playwright-testing`, `playwright-regression-testing`
- **Selenium + Java project**: `webapp-selenium-testing`, `accessibility-selenium-testing`, `api-testing`
- **Mixed stack**: Include all relevant skills

## Tips

- **GEMINI.md is your entry point.** Keep it concise but specific. Include tech stack, conventions, and skill/agent locations.
- **Reference files, don't paste them.** Use file paths in prompts rather than pasting entire SKILL.md contents — Gemini CLI can read files directly.
- **Use the agent pattern.** Start with "Read agents/[name].agent.md and use that persona" for consistent specialist behavior.
- **Combine skill + instruction.** "Follow the playwright-e2e-testing skill AND the playwright-typescript instructions" gives Gemini the most context for high-quality output.
