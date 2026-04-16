# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

The repository content is intended to be **tool-agnostic** (Copilot, Claude, Cursor, OpenCode, Windsurf, etc.). This file is simply the Claude-specific entrypoint for the same agents/instructions/skills concepts.

## Repository Purpose

This is an **AI Agents & Skills repository** for test automation.

The content is **tool-agnostic** (Copilot, Claude, Cursor, OpenCode, Windsurf, etc.), while the file formats and folder conventions in this repo are primarily optimized for **GitHub Copilot customizations**.

It contains custom agent definitions and skill instructions for:

- **Playwright** (TypeScript) - End-to-end browser automation
- **Selenium WebDriver** (Java 21+) - UI testing with JUnit 5 and AssertJ
- **API Testing** - REST/GraphQL testing with Playwright request fixture and REST Assured
- **Accessibility Testing** - WCAG 2.1 AA compliance testing
- **Manual QA** - ISTQB-based testing practices
- **Test Planning** - Test strategy and documentation
- **CI/CD Pipelines** - GitHub Actions test automation workflows

**Important:** This repository has **no build system**. Files are Markdown with YAML frontmatter. No build, lint, or test commands are required.

## Repository Architecture

```
agents/           # Custom AI agent definitions (*.agent.md)
skills/           # Specialized testing skills (*/SKILL.md with resources)
instructions/     # Guidelines for creating agents/skills (*.instructions.md)
docs/             # Setup guides and documentation
references/       # Shared reference material (anti-patterns, patterns)
AGENTS.md         # Style guide and standards for this repository
```

### Key Architectural Concepts

**1. Progressive Loading (Skills)**
Skills use three-level loading for efficiency:

- Level 1: Discovery (`name` and `description` only)
- Level 2: Instructions (full SKILL.md body when request matches)
- Level 3: Resources (scripts, examples, docs only when referenced)

**2. Agent Orchestration**
Agents can invoke sub-agents using the `agent` tool. The orchestrator must include all tools that sub-agents need. See `instructions/agents.instructions.md` for orchestration patterns.

**3. Handoffs (VS Code only)**
Agents can define `handoffs` in frontmatter for guided sequential workflows. Each handoff requires: `label`, `agent` (target), `prompt`, and optional `send: true` for auto-submission.

**4. Resource Bundling (Skills)**

- `scripts/` - Executable automation (run when invoked)
- `references/` - Documentation loaded into AI context when referenced
- `assets/` - Static files used AS-IS in output
- `templates/` - Starter code that AI modifies and builds upon

**5. Test Orchestration Workflow**
The TOP defines an 8-step workflow: Initialize → Explore → Plan → Generate → Implement → Review → Refactor → Run Tests. See `instructions/orchestration-workflow.instructions.md`.

## File Naming Conventions

| Type          | Pattern                                  | Example                                  |
| ------------- | ---------------------------------------- | ---------------------------------------- |
| Agents        | `lowercase-with-hyphens.agent.md`        | `playwright-test-generator.agent.md`     |
| Instructions  | `lowercase-with-hyphens.instructions.md` | `playwright-typescript.instructions.md`  |
| Skills        | `SKILL.md` (inside skill folder)         | `skills/playwright-e2e-testing/SKILL.md` |
| Skill folders | `lowercase-with-hyphens`                 | `playwright-e2e-testing/`                |

## Frontmatter Requirements

### Agents (\*.agent.md)

Required fields:

```yaml
---
description: "Clear description of purpose (50-150 chars)"
---
```

Optional fields:

```yaml
---
name: "Display Name" # Defaults to filename
tools: ["read", "edit", "search"] # Omit for all tools
model: "Claude Sonnet 4.5" # Recommended for VS Code
target: "vscode" # 'vscode' or 'github-copilot'
infer: true # Auto-selection (default: true)
handoffs: # VS Code 1.106+ only
  - label: Next Step
    agent: target-agent
    prompt: "Continue with..."
    send: false
---
```

### Skills (SKILL.md)

Required fields:

```yaml
---
name: skill-name # Lowercase, hyphens, ≤64 chars
description: "WHAT it does, WHEN to use it, KEYWORDS for matching"
---
```

The `description` field is CRITICAL for automatic skill discovery. It must clearly state:

- **WHAT** the skill does (capabilities)
- **WHEN** to use it (specific triggers, scenarios, file types)
- **KEYWORDS** that users might mention

Optional field:

```yaml
---
license: "Complete terms in LICENSE.txt" # Or SPDX identifier
---
```

## Code Style Guidelines

### Markdown & YAML

- Line length: Under 120 characters where practical
- Indentation: 2 spaces for YAML and Markdown lists
- Quotes: Single quotes for YAML string values
- Frontmatter markers: Triple-dash `---` at start and end

### Content Structure (Agents)

```markdown
# Agent Identity

Clear statement of who the agent is and its primary role.

## Core Responsibilities

- List specific tasks the agent performs
- Be explicit about scope boundaries

## Approach and Methodology

- How the agent works
- Step-by-step workflow patterns

## Guidelines and Constraints

- What to do/avoid
- Quality standards

## Output Expectations

- Expected format and quality
```

### Content Structure (Skills)

```markdown
# Skill Title

Brief overview of capabilities.

## When to Use This Skill

- List of scenarios and triggers

## Prerequisites

Required tools, dependencies, environment setup.

## Step-by-Step Workflows

Numbered steps for common tasks.

## Troubleshooting

| Issue | Solution |
| ----- | -------- |

## References

- [Resource Name](./path/to/resource.md)
```

## Tool References

When referencing tools in `tools:` frontmatter:

- Use lowercase aliases: `read`, `edit`, `search`, `execute`, `agent`, `web`
- For MCP servers: `playwright/*`, `github/*`, `server-name/tool-name`

## Variable Usage

Use `${variableName}` syntax for dynamic values in prompts:

```markdown
## Dynamic Parameters

- **projectName**: ${projectName}
- **basePath**: ${basePath}
```

## Agent Sub-Agent Orchestration Pattern

When creating orchestrator agents that delegate to sub-agents:

1. Include `agent` in tools list: `tools: ['read', 'edit', 'search', 'agent']`
2. Orchestrator's tool permissions act as a ceiling for all sub-agents
3. Use prompt-based orchestration with clear wrapper:
   ```
   This phase must be performed as the agent "<AGENT_NAME>" defined in "<AGENT_SPEC_PATH>".
   - Read and apply the entire .agent.md spec
   - Work on "<WORK_UNIT_NAME>" with base path: "<BASE_PATH>"
   ```
4. Pass paths and identifiers, not entire file contents
5. Launch sub-agents sequentially (faster than batching prompts)

## Domain-Specific Guidelines

### Playwright (TypeScript)

- Use `@playwright/test` with TypeScript
- Locator priority: role-based → label → placeholder → text → test ID → CSS
- Web-first assertions: `await expect(locator).toBeVisible()` (auto-retry)
- Page Object Model required
- See `instructions/playwright-typescript.instructions.md`

### Selenium WebDriver (Java 21+)

- Stack: Selenium 4.x, JUnit 5, AssertJ Soft Assertions, Allure reporting
- Locator priority: ID → test ID → semantic CSS → class → XPath
- Explicit waits with `WebDriverWait` and `ExpectedConditions`
- Never use `Thread.sleep()`
- Modern Java: Records, Streams, Optional, Pattern Matching
- See `instructions/selenium-webdriver-java.instructions.md`

### API Testing

- Playwright request fixture and REST Assured (Java 21+)
- Schema validation (Zod for TS, JSON Schema Validator for Java)
- Contract testing, idempotency, authentication flows
- See `skills/api-testing/`

### CI/CD Test Pipelines

- Tiered test system: smoke → sanity → selective → full regression
- GitHub Actions workflows with sharding and parallel execution
- Deployment gates, flaky test handling, failure notifications
- See `instructions/cicd-testing.instructions.md`

### Accessibility Testing

- WCAG 2.1 AA compliance
- Use axe-core or Playwright's built-in accessibility tree
- Test with screen readers and keyboard navigation
- See `instructions/a11y.instructions.md` and respective skill folders

## Quality Checklist

When creating new agents or skills:

- [ ] Valid YAML frontmatter with required fields
- [ ] `description` clearly states WHAT, WHEN, and KEYWORDS (skills)
- [ ] File naming follows lowercase-with-hyphens convention
- [ ] Relative paths used for resource references
- [ ] No hardcoded credentials or secrets
- [ ] Agent content under 30,000 characters
- [ ] Skill body under 500 lines (split large content into `references/`)

## Common Mistakes to Avoid

- Missing or unquoted `description` field in frontmatter
- Vague descriptions that won't trigger skill activation
- Absolute paths in resource references
- Excessive tool access without justification
- Hardcoded credentials or secrets
- Forgetting that orchestrator tool permissions limit sub-agents

## Reference Documentation

- [AGENTS.md](./AGENTS.md) - Complete style guide and file standards
- [instructions/agents.instructions.md](./instructions/agents.instructions.md) - Agent creation guidelines
- [instructions/agent-skills.instructions.md](./instructions/agent-skills.instructions.md) - Skill creation guidelines
- [Official: Creating Custom Agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents)
- [Official: Agent Skills Specification](https://agentskills.io/)
- [Orchestration Workflow](./instructions/orchestration-workflow.instructions.md) — TOP 8-step workflow for AI-driven test automation
- [File Map Template (Playwright)](./skills/playwright-e2e-testing/references/file-map-template.md) — Recommended project structure for Playwright TypeScript
- [File Map Template (Selenium)](./skills/webapp-selenium-testing/references/file-map-template.md) — Recommended project structure for Selenium Java
- [CI/CD Test Pipelines](./instructions/cicd-testing.instructions.md) — GitHub Actions workflows, test tiers, parallel execution
- [Getting Started](./docs/getting-started.md) — Overview and quick start for all AI tools
- [Skill Anatomy Standard](./docs/skill-anatomy.md) — How skills are structured and authored
- [Testing Anti-Patterns](./references/testing-anti-patterns.md) — 14 common mistakes with Bad/Good examples
