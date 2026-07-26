# Section Details Guide

Detailed guidance for each SKILL.md section type.


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

1. No `Thread.sleep()` or `waitForTimeout()` — use auto-waits or explicit assertions
2. Locators follow priority order (role > label > testId > CSS)
3. No hardcoded credentials — all from environment variables
```

---



## Cross-Skill References

Reference other skills by name using inline code format:

```markdown
Follow the `playwright-e2e-testing` skill for writing Playwright tests.
For Selenium patterns, use the `webapp-selenium-testing` skill.
If the build breaks, use the `playwright-regression-testing` skill for diagnosis.
For test planning and QA deliverables, activate the `qa-manual-istqb` skill.
```

### Cross-Reference Rules

1. **Never duplicate content between skills.** If two skills need the same information, put it in one skill's `references/` and link from the other.
2. **Reference by skill name, not file path.** Use `` `skill-name` `` not `skills/skill-name/SKILL.md`.
3. **Keep references directional.** Avoid circular references (Skill A references Skill B which references Skill A).
4. **Document cross-references in SKILLS-INDEX.md.** If a skill references another skill, add it to the dependency map.

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
