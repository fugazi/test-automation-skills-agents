---
description: "The 8-step Test Orchestration Pattern workflow for AI-driven test automation. Defines Initialize, Explore, Plan, Generate, Implement, Review, Refactor, and Run Tests phases."
applyTo: "**/*.agent.md"
---

# Test Orchestration Pattern — 8-Step Workflow

This instruction defines the standard 8-step workflow that AI-driven test automation agents follow, adapted from the Test Orchestration Pattern (TOP).

Every agent that generates, modifies, or verifies test code should follow this workflow in order. Steps may be skipped only when their conditions are already met.

## Step 1: Initialize

**What:** Read project configuration and establish context.

**Why:** Every test task needs to understand the project's framework, conventions, and structure before writing any code. Starting without context leads to inconsistent or broken tests.

**How:**

1. Read the project's `CLAUDE.md` (if exists) or test configuration file
2. Identify the test framework (Playwright, Selenium, other)
3. Identify the project structure: test directory, pages directory, fixtures directory
4. Set up context variables: `${projectPath}`, `${featureName}`, `${testFramework}`

**Agent/Skill:** Orchestrator or any agent starting a new workflow.

## Step 2: Explore

**What:** Navigate to the live application and map its structure.

**Why:** "The AI must navigate to the live app before writing code. No guessing." Locators written without seeing the actual DOM are unreliable and brittle.

**How:**

1. Navigate to the live application using browser tools or HTTP calls
2. Identify all interactive elements, forms, navigation paths, and functionality
3. Map the page and component structure
4. Record the accessibility tree for locator discovery

**Agent/Skill:** `playwright-test-planner`, skill `webapp-playwright-testing`

## Step 3: Plan

**What:** Design test scenarios covering happy path, edge cases, and error handling.

**Why:** A structured plan prevents gaps in coverage and ensures tests are purposeful rather than ad-hoc. The plan becomes the contract between planning and generation.

**How:**

1. Design test scenarios: happy path, edge cases, error handling
2. Identify which test data is needed (types, ranges, invalid inputs)
3. Create a structured test plan document with scenario descriptions
4. Map scenarios to pages and components

**Agent/Skill:** `playwright-test-planner`, skill `qa-test-planner`

## Step 4: Generate

**What:** Write test code following the Constitution rules.

**Why:** Generated code must follow the project's quality standards from the start. Fixing violations later is more expensive than preventing them during generation.

**How:**

1. Write test code following Constitution MUST DO / WON'T DO rules
2. Use the project's fixture system for dependency injection
3. Follow POM pattern with selector priority
4. Externalize all test data to files or factories
5. Wrap logical groupings in `test.step()` or `@Step`

**Agent/Skill:** `playwright-test-generator`, `selenium-test-specialist`

## Step 5: Implement

**What:** Create any missing infrastructure the generated tests depend on.

**Why:** Tests cannot run without supporting infrastructure — Page Object classes, fixtures, data files, and configuration. This step ensures everything is wired together.

**How:**

1. Create missing POM classes referenced by generated tests
2. Create or update custom fixtures for dependency injection
3. Create test data files or factory functions
4. Follow the File Map conventions from the project's `CLAUDE.md`

**Agent/Skill:** `playwright-test-generator`, `selenium-test-specialist`

## Step 6: Review

**What:** Check generated code against the Constitution (MUST DO / WON'T DO).

**Why:** Even well-intentioned generation can introduce violations. A review step catches issues before they propagate to the test suite.

**How:**

1. Verify no hardcoded data (strings, IDs, URLs, credentials)
2. Verify no XPath selectors (Playwright) or fragile XPath (Selenium)
3. Verify no hard waits (`waitForTimeout`, `Thread.sleep`, `networkidle`)
4. Verify all `test.step()` or `@Step` usage for logical grouping
5. Verify selector priority is followed

**Agent/Skill:** `test-refactor-specialist`

## Step 7: Refactor

**What:** Extract duplication, parameterize, and improve code quality.

**Why:** Fresh-generated code often has duplication across tests. Refactoring consolidates patterns and reduces maintenance burden before tests enter the suite.

**How:**

1. Extract duplicated setup or interaction patterns into reusable methods
2. Parameterize data-driven tests where applicable
3. Improve selector quality where violations were found in Step 6
4. Ensure POM methods follow fluent interface pattern

**Agent/Skill:** `test-refactor-specialist`

## Step 8: Run Tests

**What:** Execute the test suite, analyze failures, and fix iteratively until all tests pass.

**Why:** "The AI does not just hand over code. It runs tests, analyzes failures, and fixes them. It must prove its own work passes." Unverified code is unfinished work.

**How:**

1. Execute the test suite using the project's test runner
2. Analyze any failures — distinguish between code issues and test issues
3. Fix issues iteratively (return to Step 4 if generation is wrong, Step 5 if infrastructure is missing)
4. Repeat until all generated tests pass consistently

**Agent/Skill:** `playwright-test-healer`, `selenium-test-executor`

## Step States

Each step in the workflow tracks its state:

| State   | Meaning                          | Action                      |
| ------- | -------------------------------- | --------------------------- |
| PENDING | Not started                      | Wait for trigger            |
| RUNNING | Executing                        | Monitor progress            |
| SUCCESS | Completed without errors         | Proceed to next step        |
| SKIPPED | Condition not met (already done) | Proceed to next step        |
| FAILED  | Error occurred                   | Stop and diagnose, or retry |

## Context Passing Between Steps

When transitioning between steps (especially across agents), pass context using this template:

```markdown
This phase must be performed as the agent "<AGENT_NAME>" defined in "<AGENT_SPEC_PATH>".

IMPORTANT:

- Read and apply the entire .agent.md spec (tools, constraints, quality standards).
- Read and apply the Test Constitution (MUST DO / WON'T DO).
- Project: "${projectName}"
- Base path: "${projectPath}"
- Feature: "${featureName}"
- Previous output: "${previousOutputPath}" (if applicable)

Task: [what to do]
Return: Summary with status, files created/modified, issues found.
```

## Constitution Reference

All steps are governed by the Test Constitution defined in `agents/qa-orchestrator.agent.md`:

### MUST DO

1. DI via custom fixtures — never `new PageObject(page)` in specs
2. Selector priority: getByRole > getByLabel > getByPlaceholder > getByText > getByTestId > CSS
3. External test data — never hardcoded
4. `test.step()` / `@Step` for all logical groupings
5. Explore live app before writing locators
6. Web-first assertions (auto-retry)

### WON'T DO

1. No XPath selectors
2. No hard waits (`waitForTimeout`, `Thread.sleep`, `networkidle`)
3. No hardcoded strings, IDs, URLs, or credentials
4. No `any` type
5. No skipping verification
