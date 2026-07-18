# AGENTS.md

This is an AI Agents & Skills repository for test automation.

The content is **tool-agnostic** (usable with GitHub Copilot, Claude, Cursor, OpenCode, Windsurf, etc.), while the file formats and folder conventions are primarily optimized for **GitHub Copilot customizations**.

## Repository Structure

```
agents/           # Custom AI agent definitions (*.agent.md)
skills/           # Specialized testing skills (*/SKILL.md)
instructions/     # Guidelines for creating agents/skills (*.instructions.md)
docs/             # Setup guides and documentation
references/       # Shared reference material
```

## Build/Lint/Test Commands

This repository has **no build system** — it is a documentation/knowledge base. Files are Markdown with YAML frontmatter, consumed by AI coding tools.

## File Naming Conventions

| File Type     | Pattern                                  | Example                                 |
| ------------- | ---------------------------------------- | --------------------------------------- |
| Agents        | `lowercase-with-hyphens.agent.md`        | `playwright-test-generator.agent.md`    |
| Instructions  | `lowercase-with-hyphens.instructions.md` | `playwright-typescript.instructions.md` |
| Skills        | `SKILL.md` (inside skill folder)         | `skills/my-skill/SKILL.md`              |
| Skill folders | `lowercase-with-hyphens`                 | `playwright-e2e-testing/`               |

## Frontmatter Requirements

All `.agent.md` and `SKILL.md` files **must** include YAML frontmatter.

### Agents (*.agent.md)

Required fields:

```yaml
---
description: 'Clear description of purpose (50-150 chars)'
---
```

Optional fields:

```yaml
---
name: 'Display Name' # Defaults to filename
tools: ['read', 'edit', 'search'] # Omit for all tools
target: 'vscode' # 'vscode' or 'github-copilot'
infer: true # Auto-selection (default: true)
handoffs: # VS Code 1.106+ only
  - label: 'Next Step'
    agent: 'target-agent'
    prompt: 'Continue with...'
    send: false
---
```

> **Note:** Do not pin a specific model in tool-agnostic files. Let consumers choose based on their ecosystem.

### Skills (SKILL.md)

Required fields:

```yaml
---
name: 'skill-name' # Lowercase, hyphens, ≤64 chars
description: 'WHAT it does, WHEN to use it, KEYWORDS for matching'
---
```

The `description` field is **critical** for automatic skill discovery. It must clearly state what the skill does, when to use it, and keywords users might mention.

Optional field:

```yaml
---
license: 'Complete terms in LICENSE.txt' # Or SPDX identifier
---
```

## Formatting Standards

- **Line length**: Under 120 characters where practical
- **Indentation**: 2 spaces for YAML and Markdown lists
- **Quotes**: Use **single quotes** for YAML string values
- **Frontmatter markers**: Triple-dash `---` at start and end
- **Markdown headers**: `#` for title, `##` for sections, `###` for subsections
- **Bullet lists**: `-` (hyphen) with space after
- **Numbered lists**: `1.` with space after

## Content Structure

### Agents

```markdown
# Agent Identity

Clear statement of who the agent is and its primary role.

## Constitution (from TOP)

### MUST DO

- [5-6 rules that are NON-NEGOTIABLE for this agent]

### WON'T DO

- [4-5 rules that this agent must NEVER violate]

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

Agents that generate or modify test code should include a `## Constitution (from TOP)` section. The Constitution follows the Test Orchestration Pattern (TOP), defined centrally in `agents/qa-orchestrator.agent.md`. Individual agents copy the relevant MUST DO / WON'T DO rules so they are visible at the agent level.

### Skills

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

| Issue   | Solution |
| ------- | -------- |
| Problem | Fix      |

## References

- [API Reference](./references/api_reference.md)
```

## Directory Organization

**Skills subdirectories:**

```
skills/<skill-name>/
├── SKILL.md              # Required: Main instructions
├── LICENSE.txt           # Recommended: License terms
├── scripts/              # Optional: Executable automation
├── references/           # Optional: Documentation (loaded into context)
├── assets/               # Optional: Static files (used as-is)
└── templates/            # Optional: Starter code (AI modifies)
```

### Resource Types

- `scripts/` — Executable automation (run when invoked)
- `references/` — Documentation loaded into AI context when referenced
- `assets/` — Static files used AS-IS in output
- `templates/` — Starter code that AI modifies and builds upon

## Conventions

### Tool References

Use lowercase aliases in `tools:` frontmatter: `read`, `edit`, `search`, `execute`, `agent`, `web`. For MCP servers: `playwright/*`, `github/*`, `server-name/tool-name`.

### Variable Usage

Use `${variableName}` syntax for dynamic values in prompts.

## Quality Checklist

When creating new agents or skills:

- [ ] Valid YAML frontmatter with required fields
- [ ] `description` clearly states WHAT, WHEN, and KEYWORDS (skills)
- [ ] File naming follows lowercase-with-hyphens convention
- [ ] Relative paths used for resource references
- [ ] No hardcoded credentials or secrets
- [ ] Agent content under 30,000 characters
- [ ] Skill body under 500 lines (split large content into `references/`)
- [ ] Orchestrator tool permissions cover all sub-agent needs

## Common Mistakes to Avoid

- Missing or unquoted `description` field in frontmatter
- Vague descriptions that won't trigger skill activation
- Invalid YAML syntax (check indentation)
- Absolute paths in resource references
- Hardcoded credentials or secrets
- Excessive tool access without justification
- Forgetting that orchestrator tool permissions limit sub-agents

## Reference Documentation

- [Getting Started](./docs/getting-started.md) — Overview and quick start for all AI tools
- [Skill Anatomy Standard](./docs/skill-anatomy.md) — How skills are structured and authored
- [Creating Custom Agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents)
- [Agent Skills Specification](https://agentskills.io/)
- [VS Code Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
