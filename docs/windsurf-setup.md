# Setup: Windsurf

Integration guide for using test-automation-skills-agents with [Windsurf](https://codeium.com/windsurf).

## Installation

### Option A: Windsurf Rules File (Recommended)

Add skill and convention content to `.windsurfrules` at your project root:

```bash
# Start with the core conventions
cat test-automation-skills-agents/CLAUDE.md >> .windsurfrules
```

### Option B: Per-Skill Rules

Create separate rule files in Windsurf's rules directory:

```bash
mkdir -p .windsurf/rules

# Copy skills as individual rules
cp test-automation-skills-agents/skills/playwright-e2e-testing/SKILL.md .windsurf/rules/playwright-e2e-testing.md
cp test-automation-skills-agents/skills/api-testing/SKILL.md .windsurf/rules/api-testing.md
cp test-automation-skills-agents/skills/webapp-selenium-testing/SKILL.md .windsurf/rules/selenium-testing.md
cp test-automation-skills-agents/skills/a11y-playwright-testing/SKILL.md .windsurf/rules/a11y-testing.md
cp test-automation-skills-agents/skills/playwright-regression-testing/SKILL.md .windsurf/rules/regression-testing.md

# Copy instructions as conventions
cp test-automation-skills-agents/instructions/playwright-typescript.instructions.md .windsurf/rules/playwright-conventions.md
cp test-automation-skills-agents/instructions/selenium-webdriver-java.instructions.md .windsurf/rules/selenium-conventions.md
```

### Option C: Clone and Reference

```bash
git clone https://github.com/fugazi/test-automation-skills-agents.git
```

Reference the directory in your `.windsurfrules`:

```markdown
## QA Automation Skills

Reference the skills and instructions from: /path/to/test-automation-skills-agents/

### Key Conventions
- Playwright (TypeScript) for E2E and API testing
- Selenium + REST Assured (Java 21+) for Java-based testing
- Custom fixtures for dependency injection
- Follow Test Orchestration Pattern
```

## Activating Skills

Skills activate when Windsurf detects you're working on testing tasks. For best results, reference them explicitly:

```
"Follow the api-testing skill to create REST Assured tests for the /orders endpoint"
"Using the playwright-e2e-testing skill, write tests for the checkout flow"
"Apply the a11y-playwright-testing skill to audit the registration page"
```

### Skill-to-Prompt Mapping

| Skill | Prompt Trigger |
|-------|---------------|
| playwright-e2e-testing | "Write Playwright E2E tests for..." |
| api-testing | "Create API tests for..." or "Test the REST endpoint..." |
| webapp-selenium-testing | "Write Selenium Java tests for..." |
| a11y-playwright-testing | "Check accessibility of..." or "Run a11y audit on..." |
| accessibility-selenium-testing | "Scan for WCAG issues using Selenium..." |
| playwright-regression-testing | "Organize regression suite..." or "Set up test tiers..." |
| qa-test-planner | "Use the qa-test-planner skill to create a test plan for..." |
| qa-manual-istqb | "Create ISTQB-aligned test cases for..." |
| playwright-cli | "Use playwright-cli to navigate to..." |
| webapp-playwright-testing | "Open the browser and test..." |

## Using Agents

Paste agent content into your Windsurf chat or reference the files directly:

```
"Read agents/flaky-test-hunter.agent.md and follow its approach to investigate this flaky test"
```

```
"Act as the API Tester Specialist defined in agents/api-tester-specialist.agent.md. Design tests for the payments API."
```

```
"Following agents/selenium-test-specialist.agent.md, create Java test code for the user profile page"
```

### Copy Agents for Easy Access

```bash
mkdir -p .windsurf/agents
cp test-automation-skills-agents/agents/*.agent.md .windsurf/agents/
```

Then reference them with shorter paths:

```
"Read .windsurf/agents/playwright-test-generator.agent.md and generate tests for the shopping cart"
```

## Customization

### Project-Specific Windsurf Rules

Create `.windsurfrules` with project-level QA conventions:

```markdown
## QA Automation Conventions

### Tech Stack
- Framework: Playwright 1.40+
- Language: TypeScript 5.x
- Base URL: http://localhost:3000

### Testing Standards
- Locator priority: getByRole() > getByTestId() > getByLabel() > CSS selectors
- Use web-first assertions: await expect(locator).toBeVisible()
- Page Object Model required for all test files
- Custom fixtures for dependency injection — never use new PageObject()
- Test happy path AND error states for every feature

### File Organization
- Tests: tests/
- Page Objects: tests/pages/
- Fixtures: tests/fixtures/
- Test data: environment variables only (never hardcode credentials)
```

### Per-Domain Rule Files

Split large rule files by domain for better context management:

```bash
.windsurf/rules/
├── playwright-e2e.md          # E2E testing conventions
├── api-testing.md             # API testing patterns
├── selenium-testing.md        # Selenium/Java patterns
├── a11y-testing.md            # Accessibility standards
├── regression-testing.md      # Regression strategy
├── playwright-conventions.md  # TypeScript/Playwright coding rules
└── selenium-conventions.md    # Java/Selenium coding rules
```

## Tips

- **`.windsurfrules` is always loaded.** Put your core QA conventions there. Domain-specific skills go in `.windsurf/rules/`.
- **Reference files, don't inline.** Use file paths in prompts so Windsurf can read the full content when needed.
- **Use the agent pattern consistently.** "Read agents/[name].agent.md and follow its approach" ensures repeatable specialist behavior.
- **Start with one skill.** Don't copy all 10 skills at once. Start with the ones you use daily, then add more as needed.
- **Keep rules focused.** Each rule file should cover one domain. Merged files create context noise and reduce output quality.
