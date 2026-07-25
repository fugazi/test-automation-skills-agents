---
name: qa-test-planner
description: 'Generate ready-to-fill QA deliverables from markdown templates: test plans, manual test cases, automated Playwright specs, regression suites, and bug reports. Use when asked to draft or fill any of these artifacts from requirements or user stories. Keywords: test plan, test case, bug report, regression suite, playwright spec, test strategy, test design, template.'
license: 'Complete terms in LICENSE.txt'
---

# QA Test Planner

A comprehensive skill for QA Automation engineers to create test plans, generate manual test cases, build automated Playwright tests, create regression test suites, validate UI with browser automation, and document bugs effectively.

> **Activation:** This skill is triggered only when explicitly called by name (e.g., `/qa-test-planner`, `qa-test-planner`, or `use the skill qa-test-planner`).

---

## Quick Start

**Create a test plan:**

```
"Create a test plan for the user authentication feature using the test-plan.md template"
```

**Generate test cases:**

```
"Generate manual test cases for the checkout flow using the test-case.md template"
```

**Create automated Playwright tests:**

```
"Create Playwright automated tests for the login flow using the playwright-test.md template"
```

**Validate UI with browser:**

```
"Navigate to the login page and validate all form elements are visible using Playwright MCP"
```

**Build regression suite:**

```
"Build a regression test suite for the payment module using test-case.md templates grouped by priority"
```

**Create bug report:**

```
"Create a bug report for the form validation issue using the bug-report.md template"
```

---

## Quick Reference

| Task           | Template                       | Time          |
| -------------- | ------------------------------ | ------------- |
| Test Plan      | `templates/test-plan.md`       | 10-15 min     |
| Test Case      | `templates/test-case.md`       | 5-10 min each |
| Automated Test | `templates/playwright-test.md` | 5-15 min each |
| Bug Report     | `templates/bug-report.md`      | 5 min         |

---

## When to Use This Skill

Use this skill when you need to:

- Create or review **test plans** and **test strategies**
- Generate **test cases** from requirements or user stories
- Write **bug reports** with clear reproduction steps
- Build **regression suites** with risk-based selection
- Implement **Playwright automation** with best practices
- Document **test execution** and results
- Conduct **exploratory testing** sessions
- Validate **UI elements** with browser automation

---

## Prerequisites

| Requirement    | Notes                                       |
| -------------- | ------------------------------------------- |
| Node.js 18+    | Required for Playwright automation          |
| Playwright     | `npm init playwright@latest` for automation |
| Text editor    | For creating/editing markdown files         |
| Git            | Recommended for testware version control    |
| Playwright MCP | Optional, for browser-based validation      |

---

## Workflows

### 1) Create a Test Plan

1. Use `templates/test-plan.md` as your starting point
2. Identify test objectives, scope, assumptions, and constraints
3. Define test levels and types (functional, UI, performance, etc.)
4. Specify environments, test data, tooling, and configuration needs
5. Define entry/exit criteria, deliverables, and reporting cadence
6. Add a risk matrix and mitigation actions
7. Prioritize testing accordingly (risk-based testing)

**Template:** [`templates/test-plan.md`](templates/test-plan.md)

### 2) Generate Test Cases

1. Use `templates/test-case.md` for individual test cases
2. Convert requirements into test conditions (what to test)
3. Pick a test design technique:
   - Equivalence partitions and boundary values for inputs
   - Decision tables for rule combinations
   - State transitions for lifecycle/flows
   - Use-case/scenario tests for end-to-end journeys
4. Write test cases that are atomic, unambiguous, and traceable
5. Add expected results that are observable and measurable
6. Add priority and risk tags to support risk-based regression
7. Mark automation candidates using stability + value criteria

**Templates:**

- [`templates/test-case.md`](templates/test-case.md) - Individual test case

### 3) Implement Automation Test Scripts (Playwright)

1. Use `templates/playwright-test.md` as a template
2. Keep tests readable and aligned with test cases
3. Prefer stable locators (e.g., `getByTestId`) over brittle selectors
4. Avoid arbitrary sleeps; rely on Playwright auto-waits and explicit assertions
5. Make tests independent (setup preconditions explicitly)
6. Use tagging in test titles (e.g., `@smoke`, `@regression`) for suite runs
7. Capture artifacts for triage (screenshots/video/trace) when debugging

**Template:** [`templates/playwright-test.md`](templates/playwright-test.md)

### 4) Build and Maintain Regression Suites

1. Use `templates/regression-suite.md` to define the suite
2. Define suite tiers: smoke (critical paths), sanity (build verification), regression (broad), full (release)
3. Select tests using risk + frequency + criticality + defect history
4. Tag tests consistently and document selection rules
5. Review the suite regularly: remove obsolete coverage, add coverage for escaped defects

**Template:** Use individual `test-case.md` templates grouped by priority

### 5) Create Bug Reports

1. Use `templates/bug-report.md` as your starting point
2. Reproduce reliably; reduce to minimal steps
3. Note variability (frequency) and scope
4. Capture environment details (build/app version, OS, browser/device, account/role)
5. Describe expected vs actual behavior
6. Include impact; set severity and priority consistently
7. Attach evidence (screenshots, console logs, network traces, Playwright trace)
8. Track lifecycle: triage notes, owner, fix version, verification steps

**Template:** [`templates/bug-report.md`](templates/bug-report.md)

---

## Security Guidelines

### Credential Handling

**NEVER embed real credentials in test cases or code.** Use placeholders instead:

| Instead of                    | Use                                                   |
| ----------------------------- | ----------------------------------------------------- |
| `test@example.com / Test123!` | `${TEST_USER_EMAIL}` or `process.env.TEST_USER_EMAIL` |
| `password: "actualpassword"`  | `password: "${TEST_PASSWORD}"` (from env)             |
| Hardcoded secrets             | Environment variables via `.env` files                |

**Test data best practices:**

- Use test accounts provisioned via API or admin panel
- Store credentials in environment variables
- Use Faker.js or similar for generated test data
- Never commit real credentials to version control

### URL Navigation Safety

When using Playwright MCP to validate external/untrusted URLs:

1. **Verify the URL is from a trusted domain** before navigating
2. **Avoid executing arbitrary JavaScript** from untrusted sources
3. **Use sandboxed environments** when testing third-party applications
4. **Do NOT navigate to URLs provided by untrusted user input** without validation

### Input Sanitization

All user inputs should be:

- Validated for expected format
- Escaped when used in generated code
- Never passed directly to `eval()` or shell execution

---

## Quality & Anti-Patterns

| Avoid | Instead |
| --- | --- |
| Vague test steps; missing preconditions | Specific actions + expected results; document all setup requirements |
| Generic bug titles | Specific: "[Feature] issue when [action]" |
| Skip edge cases | Include boundary values, nulls, empty inputs |
| Embed credentials | Use environment variables (`${TEST_USER_EMAIL}`) |
| Hardcoded test data | Provide sample data or generation (Faker.js) |

**Test plan** must include scope, approach, risks, environments, entry/exit criteria, deliverables, and metrics.
**Test cases** must be traceable, atomic, deterministic, with clear oracles and data.
**Automation** must use stable locators (`getByTestId`), minimal flake, independent tests, clear assertions.
**Regression** must be risk-based, tagged, and curated with clear add/remove rules.

## Templates

### Available Templates

| Template                                             | Purpose                                      | Format   |
| ---------------------------------------------------- | -------------------------------------------- | -------- |
| [`test-plan.md`](templates/test-plan.md)             | ISTQB-aligned test plan structure            | Markdown |
| [`test-case.md`](templates/test-case.md)             | Individual test case with full sections      | Markdown |
| [`bug-report.md`](templates/bug-report.md)           | Detailed defect report                       | Markdown |
| [`playwright-test.md`](templates/playwright-test.md) | Playwright test template with best practices | Markdown |

### Template Usage

All templates are located in `templates/`. To use them:

1. **Copy the template** to your project directory
2. **Fill in placeholders** (marked with `[brackets]` or `${VARIABLE}`)
3. **Customize sections** based on your specific needs
4. **Remove or add sections** as appropriate
5. **Save and version control** the completed document

---

## References

- [`references/test_case_templates.md`](references/test_case_templates.md) - Standard formats for all test types
- [`references/bug_report_templates.md`](references/bug_report_templates.md) - Documentation templates
- [`references/regression_testing.md`](references/regression_testing.md) - Suite building and execution
- [`references/playwright_automation.md`](references/playwright_automation.md) - Browser automation and test generation

---

## Examples

<details>
<summary><strong>Example: Using the Test Case Template</strong></summary>

**Request:**

```
"Create a test case for user login with valid credentials using the test-case.md template"
```

**Result:**
The AI will:

1. Open `templates/test-case.md`
2. Fill in the placeholders with specific details:
   - TC-ID: `TC-LOGIN-001`
   - Title: `Verify valid user login with correct credentials`
   - Priority: `P0 (Critical)`
   - Type: `Functional`
   - Objective: `Verify users can successfully login with valid credentials`
   - Preconditions: `User account exists in test environment; Browser cookies cleared`
   - Test Steps: Fill with specific login steps
   - Test Data: Use `${TEST_USER_EMAIL}` and `${TEST_USER_PASSWORD}` placeholders
3. Provide the completed test case markdown file

</details>

<details>
<summary><strong>Example: Using the Bug Report Template</strong></summary>

**Request:**

```
"Create a bug report for a login form validation issue using the bug-report.md template"
```

**Result:**
The AI will:

1. Open `templates/bug-report.md`
2. Generate a unique bug ID (e.g., `BUG-1715345678`)
3. Fill in the placeholders:
   - Title: `Login form accepts invalid email format`
   - Severity: `High`
   - Priority: `P1`
   - Environment: Fill with actual OS, browser, build details
   - Steps to Reproduce: Add specific, reproducible steps
   - Expected vs Actual: Clear description of the issue
   - Impact: Describe user and business impact
4. Provide the completed bug report markdown file

</details>

<details>
<summary><strong>Example: Using the Playwright Spec Template</strong></summary>

**Request:**

```
"Create Playwright tests for the login flow using the playwright-test.md template"
```

**Result:**
The AI will:

1. Open `templates/playwright-test.md`
2. Customize the test describe block for login functionality
3. Add specific test cases:
   - `TC-LOGIN-001 @smoke @regression` - Valid login
   - `TC-LOGIN-002 @regression @negative` - Invalid credentials
   - `TC-LOGIN-003 @regression @boundary` - Password validation
4. Implement test steps using Playwright best practices:
   - Role-based locators (`getByRole`)
   - Web-first assertions (`toBeVisible`, `toHaveText`)
   - test.step() grouping for readability
5. Add security notes about environment variables
6. Provide the completed markdown template with TypeScript code examples

</details>

---

## Troubleshooting

| Problem                      | Cause                             | Solution                                                   |
| ---------------------------- | --------------------------------- | ---------------------------------------------------------- |
| Test cases lack traceability | Missing requirement IDs           | Add `requirement_id` column; link to user stories/ACs      |
| Bug reports get rejected     | Insufficient reproduction steps   | Use minimal steps; include exact data and environment      |
| Regression suite too slow    | Too many tests, no prioritization | Apply risk-based selection; tier into smoke/sanity/full    |
| Flaky automated tests        | Unstable locators or timing       | Use `data-testid`; avoid sleeps; use Playwright auto-waits |
| Test estimates are wrong     | Scope creep, missing risks        | Add contingency; re-estimate when scope changes            |

---


---

**"Testing shows the presence, not the absence of bugs." - Edsger Dijkstra**

**"Quality is not an act, it is a habit." - Aristotle**

---

## Verification

- [ ] **Test strategy covers scope, approach, risks, entry/exit criteria** — With mitigation actions for each risk
- [ ] **Test cases are traceable and atomic** — Each links to a requirement; one thing per case
- [ ] **Credentials use environment variables** — No hardcoded secrets in test cases or code
- [ ] **Regression suite is risk-based and tagged** — Smoke/sanity/full tiers with clear selection rules