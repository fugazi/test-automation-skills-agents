# Setup: GitHub Copilot

Integration guide for using test-automation-skills-agents with [GitHub Copilot](https://docs.github.com/en/copilot) in VS Code and on GitHub.

## Installation

### Option A: Copy to .github/ (Recommended)

This is the canonical approach for GitHub Copilot customizations.

```bash
# Clone the repo
git clone https://github.com/fugazi/test-automation-skills-agents.git

# Copy agents
cp -r test-automation-skills-agents/agents/ .github/agents/

# Copy instructions
cp -r test-automation-skills-agents/instructions/ .github/instructions/

# Copy skills
cp -r test-automation-skills-agents/skills/ .github/skills/
```

### Option B: Copilot Instructions File

Create `.github/copilot-instructions.md` with the repo's conventions:

```bash
mkdir -p .github
cat test-automation-skills-agents/CLAUDE.md > .github/copilot-instructions.md
```

### Option C: Git Submodule

```bash
git submodule add https://github.com/fugazi/test-automation-skills-agents.git .github/test-automation-skills-agents
```

Then add a sync step in your workflow to copy assets into `.github/agents/`, `.github/instructions/`, and `.github/skills/`.

### Option D: Install Skills via skills.sh

Install individual skills directly:

```bash
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill playwright-e2e-testing
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill api-testing
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill webapp-selenium-testing
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill a11y-playwright-testing
```

Browse all available skills: `https://skills.sh/?q=fugazi/test-automation-skills-agents`

## How Copilot Discovers Customizations

GitHub Copilot looks for customizations in these canonical locations:

| Type                 | Path                                     | Format                         |
| -------------------- | ---------------------------------------- | ------------------------------ |
| Agents               | `.github/agents/*.agent.md`              | Markdown with YAML frontmatter |
| Instructions         | `.github/instructions/*.instructions.md` | Markdown with YAML frontmatter |
| Skills               | `.github/skills/<name>/SKILL.md`         | Folder-based with frontmatter  |
| Copilot Instructions | `.github/copilot-instructions.md`        | Plain markdown                 |

## Activating Skills

Copilot uses the `description` field in SKILL.md frontmatter to decide when to load a skill. Skills load progressively:

- **Level 1**: Copilot reads `name` + `description` to determine relevance
- **Level 2**: Copilot loads the full SKILL.md body when relevant
- **Level 3**: Copilot loads references/scripts/templates only when linked

If a skill doesn't activate automatically, reference it explicitly:

```
@workspace Following the playwright-e2e-testing skill, write tests for the login page.
Use the conventions from instructions/playwright-typescript.instructions.md.
```

### qa-test-planner Exception

The `qa-test-planner` skill is intentionally strict — it activates only when called by name:

```
@workspace Use the skill qa-test-planner to create a test plan for the payments module.
```

## Using Agents

Agents appear in the Copilot Chat agent selector when placed in `.github/agents/`.

### In VS Code Copilot Chat

1. Open Copilot Chat.
2. Select the agent from the agent dropdown (Custom Agents).
3. Give a task prompt.

Example prompts:

```
"Use Flaky Test Hunter: investigate why checkout.spec.ts fails intermittently in CI"
"As API Tester Specialist: create negative tests for /v1/orders covering auth failures and schema validation"
"As Selenium Test Specialist: generate POM + JUnit 5 tests for login + forgot password"
```

### In GitHub Copilot Coding Agent

If using Copilot on GitHub (agent workflows), agents under `.github/agents/` are discovered automatically.

Recommended pattern:

1. Use a planning agent to produce an execution plan
2. Hand off to a specialist agent (Playwright generator/healer, flaky hunter, etc.)

## Customization

### Project-Level Copilot Instructions

Add to `.github/copilot-instructions.md`:

```markdown
## QA Automation Conventions

- Use Playwright for TypeScript E2E testing
- Use Selenium + REST Assured for Java testing
- Follow the Test Orchestration Pattern (TOP)
- Use custom fixtures for Page Object injection
- Prefer getByRole() > getByTestId() > CSS selectors (Playwright)
- Prefer ID > testId > semantic CSS > class > XPath (Selenium)
- Never use Thread.sleep() or waitForTimeout()
- Test happy path AND error states
- Validate all API responses against schemas
```

### Skill-Specific Instructions

Copy specific instructions alongside skills:

```bash
# Playwright conventions
cp test-automation-skills-agents/instructions/playwright-typescript.instructions.md .github/instructions/

# Selenium conventions
cp test-automation-skills-agents/instructions/selenium-webdriver-java.instructions.md .github/instructions/

# Accessibility standards
cp test-automation-skills-agents/instructions/a11y.instructions.md .github/instructions/

# CI/CD pipeline setup
cp test-automation-skills-agents/instructions/cicd-testing.instructions.md .github/instructions/
```

## Verifying Setup

1. Confirm files exist at the expected paths:
   - `.github/agents/*.agent.md`
   - `.github/instructions/*.instructions.md`
   - `.github/skills/<skill-name>/SKILL.md`

2. In VS Code, reload the window (Developer: Reload Window) to refresh Copilot customizations.

3. Open Copilot Chat:
   - Check that agents appear in the agent selector dropdown.
   - If a skill doesn't trigger, mention it by name in your prompt.

## Tips

- **Reload after changes.** Copilot reads customizations at load time. After adding or modifying files, reload the VS Code window.
- **Description quality matters.** The `description` field in SKILL.md frontmatter is what Copilot uses for auto-discovery. Include WHAT, WHEN, and KEYWORDS.
- **Use `@workspace` for context.** When referencing skills or instructions, use `@workspace` to ensure Copilot includes project files in its context.
- **Split by domain.** Keep Playwright, Selenium, and API instructions as separate files for clarity and to avoid context overflow.
