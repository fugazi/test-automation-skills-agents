# CLAUDE.md

Claude Code entry point for this repository. Shared standards (naming, frontmatter, formatting, content structure) are in [AGENTS.md](./AGENTS.md) — refer there first.

## Repository Purpose

AI Agents & Skills repository for test automation, covering:

- **Playwright** (TypeScript) — End-to-end browser automation
- **Selenium WebDriver** (Java 21+) — UI testing with JUnit 5 and AssertJ
- **API Testing** — REST/GraphQL with Playwright request fixture and REST Assured
- **Accessibility Testing** — WCAG 2.1 AA compliance
- **Manual QA** — ISTQB-based testing practices
- **Test Planning** — Test strategy and documentation
- **CI/CD Pipelines** — GitHub Actions test automation workflows

## Key Architectural Concepts

**1. Progressive Loading (Skills)**
Skills use three-level loading: Discovery (`name` + `description`) → Instructions (full SKILL.md) → Resources (scripts, examples, docs when referenced).

**2. Agent Orchestration**
Agents can invoke sub-agents using the `agent` tool. The orchestrator must include all tools that sub-agents need. See `instructions/agents.instructions.md`.

**3. Handoffs (VS Code only)**
Agents can define `handoffs` in frontmatter for guided sequential workflows. Each handoff requires: `label`, `agent`, `prompt`, and optional `send: true`.

**4. Test Orchestration Workflow (TOP)**
8-step workflow: Initialize → Explore → Plan → Generate → Implement → Review → Refactor → Run Tests. See `instructions/orchestration-workflow.instructions.md`.

## Sub-Agent Orchestration Pattern

1. Include `agent` in orchestrator tools list
2. Orchestrator's tool permissions act as a ceiling for all sub-agents
3. Use prompt-based orchestration with clear wrapper:

```
This phase must be performed as the agent "<AGENT_NAME>" defined in "<AGENT_SPEC_PATH>".
- Read and apply the entire .agent.md spec
- Work on "<WORK_UNIT_NAME>" with base path: "<BASE_PATH>"
```

4. Pass paths and identifiers, not entire file contents
5. Launch sub-agents sequentially

## Domain-Specific Guidelines

### Playwright (TypeScript)

- Locator priority: role-based → label → placeholder → text → test ID → CSS
- Web-first assertions with auto-retry (`await expect(locator).toBeVisible()`)
- Page Object Model required
- See `instructions/playwright-typescript.instructions.md`

### Selenium WebDriver (Java 21+)

- Stack: Selenium 4.x, JUnit 5, AssertJ Soft Assertions, Allure reporting
- Locator priority: ID → test ID → semantic CSS → class → XPath
- Explicit waits with `WebDriverWait` — never `Thread.sleep()`
- Modern Java: Records, Streams, Optional, Pattern Matching
- See `instructions/selenium-webdriver-java.instructions.md`

### API Testing

- Playwright request fixture (TS) and REST Assured (Java 21+)
- Schema validation: Zod (TS) / JSON Schema Validator (Java)
- Contract testing, idempotency, authentication flows
- See `skills/api-testing/`

### CI/CD Test Pipelines

- Tiered: smoke → sanity → selective → full regression
- GitHub Actions with sharding and parallel execution
- See `instructions/cicd-testing.instructions.md`

### Accessibility Testing

- WCAG 2.1 AA compliance with axe-core or Playwright accessibility tree
- See `instructions/a11y.instructions.md`

## Reference Documentation

- [AGENTS.md](./AGENTS.md) — Style guide and file standards
- [Agent Creation Guidelines](./instructions/agents.instructions.md)
- [Skill Creation Guidelines](./instructions/agent-skills.instructions.md)
- [Orchestration Workflow (TOP)](./instructions/orchestration-workflow.instructions.md)
- [Playwright File Map](./skills/playwright-e2e-testing/references/file-map-template.md)
- [Selenium File Map](./skills/webapp-selenium-testing/references/file-map-template.md)
- [Testing Anti-Patterns](./references/testing-anti-patterns.md) — 14 common mistakes with Bad/Good examples
