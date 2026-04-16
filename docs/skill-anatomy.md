# Skill Anatomy

This document defines the standard structure, format, and quality criteria for all skills in the `test-automation-skills-agents` repository. Use this as the authoritative reference when creating, reviewing, or modifying skills.

---

## Table of Contents

1. [File Location & Directory Structure](#file-location--directory-structure)
2. [Frontmatter Specification](#frontmatter-specification)
3. [Required Sections](#required-sections)
4. [Section Details](#section-details)
5. [Dual-Stack Patterns](#dual-stack-patterns-playwright--selenium)
6. [Instructions Layer](#instructions-layer)
7. [Supporting Files & Resource Types](#supporting-files--resource-types)
8. [Naming Conventions](#naming-conventions)
9. [Progressive Disclosure Rules](#progressive-disclosure-rules)
10. [Reference File Rules](#reference-file-rules)
11. [Template Rules](#template-rules)
12. [Anti-Rationalization Patterns](#anti-rationalization-patterns)
13. [Cross-Skill References](#cross-skill-references)
14. [Writing Principles](#writing-principles)
15. [Verification Checklist](#verification-checklist)
16. [Examples](#examples)

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
description: 'WHAT the skill does. Use when [specific trigger conditions]. KEYWORDS for matching.'
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

## Required Sections

Every `SKILL.md` MUST include these sections in order:

```
# Skill Title

## Overview
## When to Use
## [Core Process / Workflow / Steps]
## Common Rationalizations
## Red Flags
## Verification
```

### Optional Sections (include when relevant)

- `## Prerequisites` — Required tools, dependencies, environment setup
- `## Configuration` — Configuration patterns and examples
- `## Troubleshooting` — Table of common problems and solutions
- `## CLI Quick Reference` — Command table for common operations
- `## References` — Links to supporting files
- `## Security Considerations` — When skill handles credentials, URLs, or sensitive data
- `## Anti-Patterns` — Table of things to avoid with explanations
- `## Examples` — Collapsible examples (use `<details>` to save tokens)

---

## Section Details

### Overview

**Purpose:** The elevator pitch. What does this skill do, and why should an agent follow it?

**Rules:**

- 1-2 sentences maximum
- Must answer: "What does this skill do?" and "Why is it important?"
- NO process steps in the overview — those belong in the Core Process section

**Example:**

```markdown
## Overview

Comprehensive toolkit for end-to-end testing of web applications using Playwright with TypeScript. Enables robust UI testing, API validation, and responsive design verification following industry best practices.
```

### When to Use

**Purpose:** Help agents and humans decide if this skill applies to the current task.

**Rules:**

- Bullet list of positive triggers ("Use when X")
- MUST include negative exclusions ("NOT for Y")
- Be specific about file types, tool names, and scenarios

**Example:**

```markdown
## When to Use

- Write E2E tests for user flows, forms, navigation, and authentication
- API testing via Playwright's `request` fixture or network interception
- Responsive testing across mobile, tablet, and desktop viewports
- Debug flaky tests using traces, screenshots, videos, and Inspector

**NOT for:**

- Unit testing (use your framework's built-in test runner)
- Performance/load testing (use the `performance-testing-k6` skill)
- Visual regression with pixel-level comparison (use the `visual-regression-testing` skill)
```

### Core Process / Workflow / Steps

**Purpose:** The heart of the skill. The step-by-step workflow the agent follows.

**Rules:**

- Must be specific and actionable — not vague advice
- Use numbered steps for sequential workflows
- Use `test.step()` notation where it helps clarity
- Include code examples where they help (but keep them short)
- Use ASCII flowcharts where decision points exist
- Maximum 200 lines for the SKILL.md body (split larger content into `references/`)

**Good:** "Run `npx playwright test --reporter=html` and verify the exit code is 0"
**Bad:** "Make sure the tests pass"

**Good:** "Use `getByRole('button', { name: 'Submit' })` — priority 1 locator"
**Bad:** "Find the submit button"

### Common Rationalizations

**Purpose:** The most distinctive feature of well-crafted skills. These are excuses agents use to skip important steps, paired with factual rebuttals.

**Rules:**

- MUST be a markdown table with two columns: `Rationalization` and `Reality`
- Include at least 3 entries
- Every skip-worthy step in the Core Process needs a corresponding entry
- Be specific — generic entries like "I'll skip testing" are less useful

**Example:**

```markdown
## Common Rationalizations

| Rationalization                                                | Reality                                                                                                                                |
| -------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| "The login test is simple, I don't need the POM pattern"       | Simple tests grow complex. Without POM, a locator change breaks every test that touches login.                                         |
| "I'll add error handling after the tests pass"                 | Without error handling, test failures produce unhelpful stack traces. Add `test.step()` and proper assertions from the start.          |
| "This selector worked locally, it's fine for CI"               | CI environments have different timing and rendering. Always use stable locators (`getByRole`, `getByTestId`) and web-first assertions. |
| "Thread.sleep() is easier than explicit waits"                 | `Thread.sleep()` creates flaky tests that fail intermittently. Use `WebDriverWait` with `ExpectedConditions` for deterministic waits.  |
| "I'll skip the accessibility assertions, they're not critical" | WCAG compliance is a legal requirement in many jurisdictions. Use axe-core assertions from the start.                                  |
```

### Red Flags

**Purpose:** Observable signs that the skill is being violated. Useful during code review and self-monitoring.

**Rules:**

- Bullet list of behavioral patterns
- Must be detectable by reading code or reviewing test output
- Include at least 3 entries

**Example:**

```markdown
## Red Flags

- Using `Thread.sleep()` or `page.waitForTimeout()` instead of explicit waits / web-first assertions
- Importing Page Object classes directly in test files (should use fixtures/DI)
- Using CSS selectors (`locator('.btn')`) when role-based locators are available
- Tests that depend on execution order or shared mutable state
- Missing `@DisplayName` or test.step() descriptions in test output
- Hardcoded URLs, credentials, or environment-specific values
- No screenshot/trace capture configured for failing tests
```

### Verification

**Purpose:** Exit criteria. A checklist the agent uses to confirm the skill's process is complete.

**Rules:**

- MUST be a checklist using `- [ ]` syntax
- Every checkbox must be verifiable with evidence (test output, build result, file existence, etc.)
- Include at least 5 items
- Group by category when the checklist is long

**Example:**

```markdown
## Verification

After completing this skill's process, confirm:

- [ ] All tests pass: `npx playwright test` exits with code 0
- [ ] No `Thread.sleep()` or `waitForTimeout()` in any test file
- [ ] All locators follow priority order (role > label > placeholder > text > testId > CSS)
- [ ] Page Object Model used for any page with 3+ interactions
- [ ] test.step() used for multi-step test flows
- [ ] Screenshots/traces configured for failure capture
- [ ] No hardcoded credentials — all loaded from environment variables
- [ ] Test data uses placeholders or generated data (no real user data)
```

---

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

This repository includes an `instructions/` layer that is unique to our structure. Instructions define **how to create and use agents and skills** — they are meta-guidelines, not executable skills.

### Instructions vs. Skills

| Aspect        | Skill                                                        | Instruction                                         |
| ------------- | ------------------------------------------------------------ | --------------------------------------------------- |
| Purpose       | Executable workflow for a specific task                      | Guideline for creating/using skills or agents       |
| Location      | `skills/<name>/SKILL.md`                                     | `instructions/<name>.instructions.md`               |
| Frontmatter   | `name` + `description`                                       | `description` only                                  |
| Activation    | Automatic (description matching) or explicit (`/skill-name`) | Loaded by agents or referenced in agent frontmatter |
| Size limit    | ≤500 lines body                                              | ≤300 lines body                                     |
| Code examples | Yes, with runnable snippets                                  | Yes, but structural/pattern-focused                 |
| References    | Supported (`references/`, `templates/`)                      | Not supported (inline only)                         |

### Instructions Naming Conventions

| Pattern                                  | Example                                 | Purpose                             |
| ---------------------------------------- | --------------------------------------- | ----------------------------------- |
| `<framework>-<language>.instructions.md` | `playwright-typescript.instructions.md` | Framework-specific coding standards |
| `<domain>.instructions.md`               | `a11y.instructions.md`                  | Domain-specific guidelines          |
| `<concept>.instructions.md`              | `agents.instructions.md`                | Meta-guidelines for repo concepts   |

### Instructions Content Structure

```markdown
# Instruction Title

## Purpose

Why this instruction exists and what it governs.

## Scope

What is and is not covered by this instruction.

## Standards

Specific rules, patterns, and conventions.

## Examples

Code snippets demonstrating correct patterns.

## Anti-Patterns

What to avoid and why.

## Cross-References

Links to related instructions, skills, or agents.
```

### Key Instructions in This Repository

| Instruction                               | Governs                                  |
| ----------------------------------------- | ---------------------------------------- |
| `agents.instructions.md`                  | Agent creation, orchestration, handoffs  |
| `agent-skills.instructions.md`            | Skill creation standards                 |
| `playwright-typescript.instructions.md`   | Playwright/TypeScript coding conventions |
| `selenium-webdriver-java.instructions.md` | Selenium/Java coding conventions         |
| `a11y.instructions.md`                    | Accessibility testing standards          |

---

## Supporting Files & Resource Types

### Resource Type Matrix

| Directory     | Purpose                                       | AI Interaction                 | Examples                                             |
| ------------- | --------------------------------------------- | ------------------------------ | ---------------------------------------------------- |
| `references/` | Documentation loaded into AI context          | Read and understood            | API guides, strategy docs, deep-dive explanations    |
| `templates/`  | Starter code that AI modifies and builds upon | Copied, filled, and customized | Test case templates, POM templates, config templates |
| `scripts/`    | Executable automation                         | Run when invoked               | Setup scripts, scaffolding, codegen helpers          |
| `assets/`     | Static files used AS-IS in output             | Read and included verbatim     | Sample data, example screenshots, reference images   |

### When to Create Supporting Files

Create supporting files ONLY when:

- Reference material exceeds 100 lines (keep the main SKILL.md focused on process)
- Code tools or scripts are needed for setup or scaffolding
- Checklists or templates are long enough to justify separate files
- The content would be reused across multiple skills

Keep patterns and principles **inline** when under 50 lines.

### Supporting File Frontmatter

Supporting files do NOT need frontmatter. They should start with:

```markdown
# File Title

> Part of the `[skill-name]` skill. See [SKILL.md](../SKILL.md) for context.
```

---

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

| Anti-Pattern                                          | Problem                                    | Fix                                    |
| ----------------------------------------------------- | ------------------------------------------ | -------------------------------------- |
| Including full API docs in SKILL.md                   | Burns tokens, makes skill hard to scan     | Move to `references/` and link         |
| Loading all references upfront                        | Defeats the purpose of progressive loading | Reference only when needed in workflow |
| No description keywords                               | Agent can't discover the skill at Level 1  | Add trigger keywords to description    |
| Duplicating content between SKILL.md and references   | Maintenance burden, token waste            | Link, don't duplicate                  |

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

## Anti-Rationalization Patterns

The `Common Rationalizations` section is the signature feature of well-crafted skills. This section documents the excuses agents make to skip important steps, paired with factual rebuttals.

### Why This Matters

AI agents are prone to:

1. **Shortcut-seeking:** "This is simple enough to skip the full process"
2. **Over-optimism:** "I'll add tests later"
3. **Pattern-matching to simplicity:** "I've seen similar code, I know what to do"
4. **Avoiding tedious steps:** "The manual verification isn't necessary"

The rationalizations table pre-empts these behaviors by providing the agent with built-in counter-arguments.

### Pattern for Writing Rationalizations

For each skip-worthy step in your Core Process, ask:

1. **What excuse would an agent use to skip this step?** → That's the `Rationalization`
2. **What factually goes wrong when this step is skipped?** → That's the `Reality`

### QA-Specific Rationalizations

Include these QA-specific entries where applicable:

| Rationalization                                                | Reality                                                                                                                     |
| -------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| "I'll test just the happy path, edge cases can wait"           | Edge cases are where 60% of production bugs originate. Test boundary values, empty inputs, and error states from the start. |
| "The test passes locally, CI must be flaky"                    | CI failures often reveal real environmental issues (timing, rendering, dependencies). Investigate before dismissing.        |
| "This selector is stable enough"                               | Selectors based on CSS classes or XPath break on the next UI redesign. Use role-based locators or `data-testid` attributes. |
| "I don't need to test this in multiple browsers"               | Cross-browser differences account for 15-20% of UI bugs. At minimum, test Chromium + Firefox.                               |
| "Manual testing covered this, no need to automate"             | Manual testing doesn't scale and isn't repeatable. Automate regression-critical paths.                                      |
| "The API response looks right, no need to validate the schema" | Without schema validation, implicit breaking changes pass silently. Validate response structure, not just values.           |
| "I'll skip the wait strategy, the element loads fast enough"   | "Fast enough" is not a synchronization strategy. Use explicit waits / web-first assertions for deterministic behavior.      |
| "Page Object Model is overkill for this test"                  | Tests without POM become unmaintainable after 20+ test cases. Even simple pages benefit from encapsulated locators.         |

---

## Cross-Skill References

Reference other skills by name using inline code format:

```markdown
Follow the `playwright-e2e-testing` skill for writing Playwright tests.
For Selenium patterns, use the `webapp-selenium-testing` skill.
If the build breaks, use the `playwright-regression-testing` skill for diagnosis.
For test planning, activate the `qa-test-planner` skill.
```

### Cross-Reference Rules

1. **Never duplicate content between skills.** If two skills need the same information, put it in one skill's `references/` and link from the other.
2. **Reference by skill name, not file path.** Use `` `skill-name` `` not `skills/skill-name/SKILL.md`.
3. **Keep references directional.** Avoid circular references (Skill A references Skill B which references Skill A).
4. **Document cross-references in SKILLS-INDEX.md.** If a skill references another skill, add it to the dependency map.

---

## Writing Principles

1. **Process over knowledge.** Skills are workflows, not reference docs. Steps, not facts. An agent reading the skill should know exactly what to DO.

2. **Specific over general.** "Run `npx playwright test --reporter=html`" beats "verify the tests pass". "Use `getByRole('button', { name: 'Submit' })`" beats "find the submit button".

3. **Evidence over assumption.** Every verification checkbox requires proof. "All tests pass" must be backed by "exit code is 0" or "HTML report shows 0 failures".

4. **Anti-rationalization.** Every skip-worthy step needs a counter-argument in the Common Rationalizations table. If agents routinely skip a step, document why they shouldn't.

5. **Progressive disclosure.** Main SKILL.md is the entry point. Supporting files are loaded only when the workflow reaches a step that references them.

6. **Token-conscious.** Every section must justify its inclusion. If removing it wouldn't change agent behavior, remove it.

7. **Dual-stack aware.** When writing a skill that could apply to both Playwright and Selenium, clearly separate the content. Never mix TypeScript and Java in the same code block.

8. **QA-domain specific.** This repository is for QA Automation Engineers. Write for that audience — assume familiarity with testing concepts (POM, assertions, fixtures, test data management).

---

## Verification Checklist

Use this checklist when reviewing a new or modified skill:

### Frontmatter

- [ ] `name` is lowercase, hyphen-separated, matches directory name, ≤64 chars
- [ ] `description` states WHAT, WHEN, and KEYWORDS
- [ ] `description` is single-quoted and ≤1024 characters
- [ ] No process steps in description

### Required Sections

- [ ] Overview: 1-2 sentences, no process steps
- [ ] When to Use: includes positive triggers AND negative exclusions
- [ ] Core Process: specific, actionable steps with code examples
- [ ] Common Rationalizations: table with ≥3 entries
- [ ] Red Flags: bullet list with ≥3 entries
- [ ] Verification: checklist with ≥5 verifiable items

### Structure

- [ ] Sections in required order
- [ ] SKILL.md body ≤500 lines (split to references/ if larger)
- [ ] No duplicate content across skills
- [ ] Cross-references use skill name, not file path

### Supporting Files

- [ ] `references/` exists only if referenced from SKILL.md
- [ ] `templates/` uses clear placeholders
- [ ] `scripts/` are executable and documented
- [ ] `assets/` for static files only (no templates here)
- [ ] Each reference file ≤300 lines and covers one topic

### Dual-Stack Compliance (when applicable)

- [ ] Framework-specific code clearly separated
- [ ] No mixed TypeScript/Java code blocks
- [ ] Locator priority tables included per framework
- [ ] Scope classification matches naming convention

### Quality

- [ ] No hardcoded credentials or secrets
- [ ] Relative paths for all resource references
- [ ] No absolute paths
- [ ] All links resolve correctly
- [ ] Markdown is valid (headers, tables, code blocks)

---

## Examples

### Minimal Skill Structure

```
skills/playwright-visual-testing/
├── SKILL.md
├── LICENSE.txt
├── references/
│   ├── masking-strategies.md
│   └── threshold-configuration.md
└── templates/
    └── visual-test-template.ts
```

### Minimal SKILL.md

````markdown
---
name: playwright-visual-testing
description: 'Visual regression testing with screenshot comparison. Use when asked to implement, update, or debug visual regression tests with Playwright\'s toHaveScreenshot(), configure thresholds, mask dynamic content, or manage baseline images. Covers snapshot comparison, CI baselines, and diff analysis.'
---

# Playwright Visual Regression Testing

## Overview

Toolkit for implementing visual regression testing using Playwright's built-in screenshot comparison. Ensures UI consistency across changes with configurable thresholds and masking.

## When to Use

- Implement visual regression tests with `toHaveScreenshot()`
- Configure comparison thresholds and maxDiffPixelRatio
- Mask dynamic content (timestamps, ads, avatars) in screenshots
- Debug screenshot diff failures
- Manage baseline images across CI environments

**NOT for:**

- Pixel-perfect design QA (use dedicated design review tools)
- Accessibility testing (use the `a11y-playwright-testing` skill)

## Core Process

1. **Identify visual regression scope**
   - List pages/components that need visual testing
   - Identify dynamic content that must be masked
   - Determine threshold sensitivity per component

2. **Create baseline screenshots**
   ```typescript
   await expect(page).toHaveScreenshot("homepage.png");
   ```

3. **Configure comparison options**
   ```typescript
   await expect(page).toHaveScreenshot("homepage.png", {
     maxDiffPixelRatio: 0.01,
     mask: [page.locator(".dynamic-content")],
   });
   ```

4. **Run and review**
   ```bash
   npx playwright test --update-snapshots  # First run (create baselines)
   npx playwright test                      # Subsequent runs (compare)
   ```

5. **Handle failures**
   - Review diff images in HTML report
   - If intentional change: update baseline with `--update-snapshots`
   - If regression: fix the UI change and re-run

## Common Rationalizations

| Rationalization                                       | Reality                                                                                                                                                         |
| ----------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| "Visual tests are too flaky to be useful"             | Flakiness comes from unmasked dynamic content and missing thresholds. Configure properly and visual tests become one of the most reliable regression detectors. |
| "I'll update the baseline without reviewing the diff" | Blind baseline updates defeat the purpose of visual testing. Always review the diff image before accepting changes.                                             |
| "One global threshold is enough for all pages"        | Different pages have different complexity. A 1% threshold may be fine for a static landing page but too loose for a data dashboard.                             |

## Red Flags

- Baseline images updated without reviewing diff output
- No masking for dynamic content (dates, ads, user-specific data)
- Visual tests disabled in CI pipeline
- Using full-page screenshots for components (use `.toHaveScreenshot()` on specific locators)
- Threshold set to 0 (any pixel change fails — too brittle for CI)

## Verification

- [ ] Baseline screenshots exist for all pages/components under test
- [ ] Dynamic content is masked with `mask` option
- [ ] Threshold configured appropriately per component complexity
- [ ] Visual tests run in CI alongside functional tests
- [ ] Diff images reviewed before baseline updates
- [ ] Test report includes comparison images for all failures

## References

- [Masking Strategies](./references/masking-strategies.md)
- [Threshold Configuration](./references/threshold-configuration.md)
- [Visual Test Template](./templates/visual-test-template.ts)
````

---

_This document is the authoritative standard for skill creation in the test-automation-skills-agents repository. When in doubt, refer to this document first._
