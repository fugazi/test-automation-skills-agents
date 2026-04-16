# Getting Started with Test Automation Skills & Agents

A tool-agnostic library of agents, instructions, and skills for QA Automation Engineers using AI coding assistants.

## What's Inside

| Component | Purpose | Count |
|-----------|---------|-------|
| **Agents** | Specialist personas for specific QA tasks | 13 |
| **Skills** | Procedural workflows for testing domains | 10 |
| **Instructions** | Rules, conventions, and standards | 7 |
| **References** | Detailed technical reference material | Multiple |
| **Templates** | Starter files for common test patterns | Multiple |

## Quick Start

### 1. Choose Your Tool

| Tool | Setup Guide |
|------|-------------|
| Claude Code | [docs/claude-code-setup.md](./claude-code-setup.md) |
| Cursor | [docs/cursor-setup.md](./cursor-setup.md) |
| GitHub Copilot | [docs/copilot-setup.md](./copilot-setup.md) |
| Gemini CLI | [docs/gemini-cli-setup.md](./gemini-cli-setup.md) |
| Windsurf | [docs/windsurf-setup.md](./windsurf-setup.md) |

### 2. How Skills Work

Skills are activated based on what you're doing:

- Writing E2E tests → activates `playwright-e2e-testing` or `webapp-selenium-testing`
- Testing APIs → activates `api-testing`
- Fixing flaky tests → activates `playwright-regression-testing`
- Planning test strategy → activates `qa-test-planner`
- Running accessibility audit → activates `a11y-playwright-testing` or `accessibility-selenium-testing`

### 3. Using Agents

Agents are specialist personas you can invoke:

| Agent | Specialty |
|-------|-----------|
| `playwright-test-planner` | Analyzes requirements and creates test plans |
| `playwright-test-generator` | Generates Playwright test code from plans |
| `playwright-test-healer` | Fixes failing or flaky tests |
| `api-tester-specialist` | Designs and generates API test suites |
| `selenium-test-specialist` | Generates Selenium/Java test code |
| `selenium-test-executor` | Runs/debugs Selenium suites |
| `flaky-test-hunter` | Identifies and fixes flaky tests |
| `test-refactor-specialist` | Refactors test code for maintainability |
| `qa-orchestrator` | Routes tasks to specialist agents |
| `architect` | Architecture and delegation-focused orchestration |
| `docs-agent` | Technical writing for test documentation |
| `principal-software-engineer` | Architecture, quality, pragmatic trade-offs |
| `implementation-plan` | Deterministic implementation plans |

### 4. Repository Structure

```
test-automation-skills-agents/
├── agents/           # 13 specialist personas (.agent.md)
├── skills/           # 10 procedural workflows (SKILL.md per directory)
│   ├── playwright-e2e-testing/
│   ├── webapp-playwright-testing/
│   ├── webapp-selenium-testing/
│   ├── a11y-playwright-testing/
│   ├── accessibility-selenium-testing/
│   ├── playwright-regression-testing/
│   ├── playwright-cli/
│   ├── qa-manual-istqb/
│   ├── qa-test-planner/
│   └── api-testing/
├── instructions/     # 7 rules and conventions (.instructions.md)
├── references/       # Detailed technical material
├── docs/             # Documentation and guides
├── AGENTS.md         # Agent registry and standards
├── CLAUDE.md         # Claude Code integration
└── README.md         # Repository overview
```

## Dual-Stack Support

This library supports both major test automation stacks:

| Stack | Tools | Languages |
|-------|-------|-----------|
| **Playwright** | @playwright/test | TypeScript |
| **Selenium** | Selenium WebDriver 4 + REST Assured | Java 21+ |

Skills that apply to both stacks provide examples in both languages.

## Suggested Workflows

### From requirements to tests (Playwright)

1. Use `qa-manual-istqb` skill to draft test conditions and test cases.
2. Use Playwright Test Planner agent to create an E2E plan.
3. Use Playwright Test Generator agent to generate tests from the plan.
4. Use `playwright-e2e-testing` skill as the best-practices reference during implementation.

### Stabilize a flaky suite

1. Use Flaky Test Hunter agent to identify patterns and root causes.
2. Apply changes (wait strategy, locators, isolation, data seeding).
3. Use Playwright Test Healer agent to validate and repair remaining failures.

### API contract validation

1. Use API Tester Specialist agent.
2. Cover auth (401/403), validation errors (400), schema/contract checks, idempotency, pagination edge cases.
3. Use `api-testing` skill for schema validation patterns (Zod, JSON Schema) and contract testing.

### Accessibility regression prevention

1. Pick the stack: Playwright + axe-core (`a11y-playwright-testing`) or Selenium + axe-core (`accessibility-selenium-testing`).
2. Add a11y checks to critical flows (auth, checkout, forms, modals).
3. Fail CI on WCAG 2.1 AA violations.

## Further Reading

- [Skill Anatomy Standard](./skill-anatomy.md) — How skills are structured and authored
- [Testing Anti-Patterns](../references/testing-anti-patterns.md) — 14 common mistakes with Bad/Good examples
