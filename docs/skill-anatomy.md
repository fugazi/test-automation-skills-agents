# Skill Anatomy

This document defines the standard structure, format, and quality criteria for all skills in the `test-automation-skills-agents` repository. Use this as the authoritative reference when creating, reviewing, or modifying skills.

---

## Table of Contents

1. [File Location & Directory Structure](#file-location--directory-structure)
2. [Frontmatter Specification](#frontmatter-specification)
3. [Core CE Principle](#core-ce-principle)
4. [Required Sections](#required-sections)
5. [Section Details](#section-details)
6. [Dual-Stack Patterns](#dual-stack-patterns-playwright--selenium)
7. [Instructions Layer](#instructions-layer)
8. [Supporting Files & Resource Types](#supporting-files--resource-types)
9. [Naming Conventions](#naming-conventions)
10. [Progressive Disclosure Rules](#progressive-disclosure-rules)
11. [Reference File Rules](#reference-file-rules)
12. [Template Rules](#template-rules)
13. [Verification Checklist](#verification-checklist)
14. [Examples](#examples)

---

## File Location & Directory Structure

Every skill lives in its own directory under `skills/`:

```
skills/
  skill-name/
    SKILL.md          # Required: The skill definition
    LICENSE.txt       # Recommended: License terms
    references/       # Optional: Documentation loaded into AI context
      example-reference.md
    templates/        # Optional: Starter code that AI modifies
      example-template.md
    scripts/          # Optional: Executable automation
      example-script.sh
    assets/           # Optional: Static files used AS-IS in output
      example-asset.md
```

**Rules:**

- Every skill directory MUST contain exactly one `SKILL.md`
- The directory name MUST match the `name` field in frontmatter
- Empty directories are not allowed — remove or populate
- At most ONE of each subdirectory (`references/`, `templates/`, `scripts/`, `assets/`)

---

## Frontmatter Specification

### Required Fields

```yaml
---
name: skill-name-with-hyphens
description: "WHAT the skill does. Use when [specific trigger conditions]. KEYWORDS for matching."
---
```

### Field Rules

| Field         | Required | Rules                                                                                                                                                                         |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`        | **Yes**  | Lowercase, hyphen-separated. Must match directory name. Maximum 64 characters.                                                                                                |
| `description` | **Yes**  | Single-quoted string. Must state WHAT the skill does (third person) followed by WHEN to use it (trigger conditions). Include KEYWORDS for discovery. Maximum 1024 characters. |
| `license`     | No       | SPDX identifier or reference to `LICENSE.txt`                                                                                                                                 |

### Description Anatomy

The `description` field is the **most critical field** for skill discovery. Agents discover skills by reading descriptions injected into their system prompt. A well-written description:

1. **Starts with capabilities** (third person, present tense): "End-to-end testing toolkit for..."
2. **Follows with triggers** (when to activate): "Use when asked to write, run, debug, or maintain..."
3. **Ends with keywords** (discovery terms): "...Covers browser automation, network interception, Page Object Model, fixtures, and parallel execution."

**Good:**

```yaml
description: "End-to-end testing toolkit using Playwright with TypeScript. Use when asked to write, run, debug, or maintain Playwright (@playwright/test) TypeScript tests for UI behavior, form submissions, user flows, API validation, or visual regression. Covers browser automation, Page Object Model, fixtures, and parallel execution."
```

**Bad:**

```yaml
description: "Playwright testing skill"
```

**Why it matters:** If the description is vague, the agent won't know when to activate the skill. If it contains process steps, the agent may follow the summary instead of reading the full SKILL.md.

---

## Core CE Principle

The model's judgment replaces structural compliance. Before adding a section, ask: *"Would removing it change what the model does?"* If not, remove it.

## Required Sections

Every `SKILL.md` MUST include these sections:

1. **`## When to Use`** — Critical for skill discovery and activation
2. **`## Core Process`** (or Workflow/Steps) — The heart of the skill
3. **`## References`** — Links to supporting files (progressive disclosure)

### Optional Sections (include only if they change agent behavior)

- `## Overview` — 1-2 sentence summary (often redundant with description)
- `## Prerequisites` — Required tools, dependencies, environment setup
- `## Security Considerations` — When skill handles credentials, URLs, or sensitive data
- `## Anti-Patterns` / `## Red Flags` — Only with genuine non-inferable content
- `## Verification` — Compact checklist (3-5 non-inferable items max)
- `## Troubleshooting` — Common problems specific to this skill's domain
- `## CLI Quick Reference` — Command table for common operations
- `## Configuration` — Configuration patterns and examples

### Sections NOT Recommended

- `## Common Rationalizations` — **Removed.** This pattern anticipates model excuses (micro-management). Anthropic eliminated it from Claude Code with no eval loss. If documenting a *real observed* model failure, use a 1-line affirmative principle instead.
- `<details>` tags — **Cosmetic only.** Content inside `<details>` still consumes tokens. Use for human readability, not token savings. To reduce tokens, move content to `references/`.

---

## Section Details

Each section type (Overview, When to Use, Core Process, Prerequisites, etc.) has detailed formatting guidance in [`references/section-details-guide.md`](references/section-details-guide.md). Key principles: be specific over general, process over knowledge, token-conscious.

## Dual-Stack Patterns (Playwright + Selenium)

This repository is unique in supporting **two testing frameworks** side by side. Skills must account for this dual-stack nature.

### Skill Scope Classification

| Scope              | Convention                                                   | Example                                                                 |
| ------------------ | ------------------------------------------------------------ | ----------------------------------------------------------------------- |
| Playwright-only    | Prefix with `playwright-` or include "Playwright" in name    | `playwright-e2e-testing`                                                |
| Selenium-only      | Prefix with `webapp-selenium-` or include "Selenium" in name | `webapp-selenium-testing`                                               |
| Framework-agnostic | No framework prefix                                          | `qa-test-planner`, `qa-manual-istqb`                                    |
| Both frameworks    | Cover both in a single skill with clear sections             | `a11y-playwright-testing` + `accessibility-selenium-testing` (separate) |

### When to Use Separate Skills vs. Combined

**Use separate skills when:**

- The code examples are fundamentally different (TypeScript vs Java)
- The tooling and CLI commands are different
- The workflows diverge significantly

**Use a combined skill when:**

- The concepts are the same (test planning, ISTQB practices)
- The workflow is tool-agnostic
- The dual-stack nature is a small part of the content

### Dual-Stack Section Template

When a skill covers both frameworks, use this pattern:

```markdown
## Playwright (TypeScript)

<!-- Playwright-specific steps, code examples, and patterns -->

## Selenium (Java)

<!-- Selenium-specific steps, code examples, and patterns -->
```

Never mix Playwright and Selenium code in the same code block.

### Locator Strategy Tables

Each framework skill MUST include a locator priority table:

**Playwright:**

| Priority | Locator                | Example                                   |
| -------- | ---------------------- | ----------------------------------------- |
| 1        | Role + accessible name | `getByRole('button', { name: 'Submit' })` |
| 2        | Label                  | `getByLabel('Email')`                     |
| 3        | Placeholder            | `getByPlaceholder('Enter email')`         |
| 4        | Text                   | `getByText('Welcome')`                    |
| 5        | Test ID                | `getByTestId('submit-btn')`               |
| 6        | CSS (avoid)            | `locator('.btn-primary')`                 |

**Selenium:**

| Priority | Locator             | Example                                  |
| -------- | ------------------- | ---------------------------------------- |
| 1        | ID                  | `By.id("elementId")`                     |
| 2        | Test ID (CSS)       | `By.cssSelector("[data-testid='name']")` |
| 3        | Semantic CSS        | `By.cssSelector("nav > a.active")`       |
| 4        | Class               | `By.className("btn-primary")`            |
| 5        | XPath (last resort) | `By.xpath("//button[text()='Submit']")`  |

---

## Instructions Layer

Optional `.instructions.md` files for editor-specific guidance (VS Code, Cursor). See [`references/section-details-guide.md`](references/section-details-guide.md).

## Supporting Files & Resource Types

`references/` (docs), `templates/` (starter code), `scripts/` (automation), `assets/` (static files). See [`references/section-details-guide.md`](references/section-details-guide.md) for detailed rules.

## Naming Conventions

### Skills

| Element              | Convention                        | Example                          |
| -------------------- | --------------------------------- | -------------------------------- |
| Directory            | `lowercase-hyphen-separated`      | `playwright-e2e-testing/`        |
| Main file            | `SKILL.md` (always uppercase)     | `SKILL.md`                       |
| Playwright skills    | Prefix with `playwright-`         | `playwright-regression-testing/` |
| Selenium skills      | Include `selenium` in name        | `webapp-selenium-testing/`       |
| QA skills (agnostic) | Prefix with `qa-`                 | `qa-test-planner/`               |
| A11y skills          | Include `a11y` or `accessibility` | `a11y-playwright-testing/`       |

### Supporting Files

| Element         | Convention                         | Example                 |
| --------------- | ---------------------------------- | ----------------------- |
| Reference files | `lowercase-hyphen-separated.md`    | `locator_strategies.md` |
| Template files  | `lowercase-hyphen-separated.md`    | `test-case.md`          |
| Script files    | `lowercase-hyphen-separated.<ext>` | `setup-project.sh`      |
| Asset files     | `lowercase-hyphen-separated.<ext>` | `sample-report.html`    |

### Instructions

| Element   | Convention                                   | Example                                 |
| --------- | -------------------------------------------- | --------------------------------------- |
| File name | `lowercase-hyphen-separated.instructions.md` | `playwright-typescript.instructions.md` |

### Agents

| Element   | Convention                            | Example                              |
| --------- | ------------------------------------- | ------------------------------------ |
| File name | `lowercase-hyphen-separated.agent.md` | `playwright-test-generator.agent.md` |

---

## Progressive Disclosure Rules

Skills use a three-level loading model for efficiency:

```
Level 1: Discovery
  └─ Agent reads `name` + `description` from frontmatter
  └─ Decides whether to activate the skill

Level 2: Instructions
  └─ Agent reads full SKILL.md body
  └─ Follows the process/workflow

Level 3: Resources
  └─ Agent loads references/, templates/, scripts/ ONLY when needed
  └─ Triggered by explicit reference in the workflow
```

### Rules

1. **Level 1 must be self-contained.** The `description` field alone must tell the agent whether this skill applies. No external references.

2. **Level 2 must be actionable.** The SKILL.md body must contain enough information to execute the core workflow without loading any supporting files.

3. **Level 3 is demand-loaded.** References are loaded only when the agent reaches a step that says "See [Reference Name](./references/xxx.md) for detailed patterns." Never front-load all references.

4. **Keep SKILL.md under 500 lines.** If the body exceeds 500 lines, split content into `references/` files and link to them from the appropriate workflow step.

5. **Use collapsible sections** (`<details>`) for examples, extended code blocks, and supplementary content. This keeps the main content scannable while preserving detail.

### Progressive Disclosure Anti-Patterns

| Anti-Pattern                                        | Problem                                    | Fix                                    |
| --------------------------------------------------- | ------------------------------------------ | -------------------------------------- |
| Including full API docs in SKILL.md                 | Burns tokens, makes skill hard to scan     | Move to `references/` and link         |
| Loading all references upfront                      | Defeats the purpose of progressive loading | Reference only when needed in workflow |
| No description keywords                             | Agent can't discover the skill at Level 1  | Add trigger keywords to description    |
| Duplicating content between SKILL.md and references | Maintenance burden, token waste            | Link, don't duplicate                  |

---

## Reference File Rules

### Location

References are stored in `skills/<skill-name>/references/`, NOT at the project root.

### Content Rules

1. **One topic per file.** A reference file covers one subject (e.g., `locator_strategies.md`, NOT `playwright-guide.md` that covers everything).
2. **Maximum 300 lines per reference file.** If a topic exceeds 300 lines, split into multiple focused files.
3. **Must be linkable.** Every reference file must be referenced from at least one step in SKILL.md. Orphan references are dead weight.
4. **Use relative paths.** Always reference as `./references/file-name.md` or `./scripts/file-name.sh`. Never use absolute paths.
5. **Include a header.** Every reference file starts with a title and a back-link to SKILL.md.

### Reference File Template

```markdown
# Reference Title

> Part of the `[skill-name]` skill. See [SKILL.md](../SKILL.md) for full context.

## Overview

Brief description of what this reference covers.

## Content

<!-- Detailed content here -->

## See Also

- [Other Reference](./other-reference.md) — Related topic
```

---

## Template Rules

### Location

Templates are stored in `skills/<skill-name>/templates/`.

### Content Rules

1. **Templates are NOT documentation.** They are starter code/markup that AI agents copy, fill in, and customize.
2. **Use clear placeholders.** Mark placeholders with `[BRACKETS]` or `${VARIABLE}` syntax.
3. **Include instructions as comments.** Templates should have inline comments explaining what to fill in.
4. **Keep templates focused.** One template per deliverable type.
5. **Never put templates in `assets/`.** `assets/` is for static files used AS-IS. `templates/` is for files that AI modifies.

### Template vs. Asset Decision Tree

```
Does the file need to be modified/filled by the AI?
├─ YES → templates/
└─ NO → assets/
```

### Template File Template

```markdown
<!--
Template: [Template Name]
Part of the [skill-name] skill.

Instructions: Copy this template, replace [PLACEHOLDERS] with actual values,
and remove the <!-- --> comments before finalizing.

-->

# [DOCUMENT TITLE]

## [Section Name]

[PLACEHOLDER: Describe what goes here]
```

---

## Verification Checklist

Use this checklist when reviewing a skill:

- [ ] `name` is lowercase-hyphenated, matches directory, ≤64 chars
- [ ] `description` follows WHAT+WHEN+KEYWORDS (≤450 chars ideal)
- [ ] SKILL.md ≤ 500 lines (this standard included)
- [ ] References ≤ 300 lines each, one topic per file
- [ ] No duplicated sections (one concept = one source)
- [ ] No "Common Rationalizations" (use affirmative principles instead)
- [ ] Code examples ≤ 15 lines inline (longer → `references/`)
- [ ] Skills are self-contained (no cross-skill runtime dependencies)
- [ ] File naming: lowercase-hyphens (not snake_case)
- [ ] Progressive disclosure: 3 levels (discovery → instructions → resources)
- [ ] No persona framing or motivational filler
- [ ] Security rules are explicit and non-inferable
- [ ] `<details>` noted as cosmetic (tokens still consumed)
- [ ] References have back-links for files >100 lines
- [ ] Templates clearly marked as starter code

---

## Examples

See [`references/example-skill-template.md`](references/example-skill-template.md) for a complete minimal skill structure and full SKILL.md example.

---

_This document is the authoritative standard for skill creation in the test-automation-skills-agents repository. When in doubt, refer to this document first._
