---
name: qa-manual-istqb
description: ISTQB Foundation Level (CTFL) aligned QA toolkit for manual and automated testing. Use when asked to create test plans, test strategies, test conditions, test cases, bug reports, defect logs, regression suites, traceability matrices, or exploratory charters. Supports risk-based testing, test design techniques (equivalence partitioning, boundary value analysis, decision tables, state transitions), test estimation, static testing reviews, and test process management. Includes Playwright automation guidance for test implementation.
---

# ISTQB Manual & Automation QA Toolkit

Complete ISTQB Foundation Level (CTFL) aligned workflow for QA test engineers covering:
**Test Planning → Test Analysis → Test Design → Test Implementation → Test Execution → Test Completion**

## When to Use This Skill

- Creating or reviewing **test plans** and **test strategies**
- Generating **test conditions** and **test cases** from requirements
- Applying **test design techniques** (EP, BVA, decision tables, state transitions, use cases)
- Writing **bug reports** and managing **defect lifecycle**
- Building **regression suites** with risk-based selection
- Creating **traceability matrices** (requirements ↔ tests ↔ defects)
- Conducting **exploratory testing** sessions with charters
- Estimating test effort using ISTQB techniques
- Reviewing testware through **static testing** practices
- Implementing automation with **Playwright** (TypeScript)

## Prerequisites

| Requirement | Notes                                           |
| ----------- | ----------------------------------------------- |
| Node.js 18+ | Required for CLI script and Playwright          |
| Playwright  | `npm init playwright@latest` for automation     |
| Text editor | For creating/editing markdown and CSV artifacts |
| Git         | Recommended for testware version control        |

## Quick Start (choose one)

- Create a test plan: use `templates/test-plan.md` as a starting point.
- Create a test summary report: use `templates/test-summary-report.md`.
- Generate test cases: use `templates/test-cases.csv` and fill it from the test basis (requirements, user stories, acceptance criteria).
- Create a bug report: use `templates/bug-report.md`.
- Create a bug log: use `templates/bug-log.csv`.
- Create traceability: use `templates/traceability-matrix.csv`.
- Build a regression suite definition: use `templates/regression-suite.md`.
- Scaffold Playwright tests: use `templates/playwright-spec.ts` and adapt to the system under test.
- Run exploratory testing: use `templates/exploratory-charter.md` to timebox and capture outcomes.

If running locally, generate artifacts with the bundled CLI:

```bash
node scripts/qa_artifacts.mjs list
node scripts/qa_artifacts.mjs create test-plan --out specs --project "My App" --release "R1"
node scripts/qa_artifacts.mjs create test-cases --out specs --feature "Checkout"
node scripts/qa_artifacts.mjs create bug-report --out specs/bugs --title "Search returns 500"
```

## Inputs to collect (ask if missing)

- **Test basis**: requirements, user stories, acceptance criteria, designs, risk register, defect history.
- **Scope**: in-scope/out-of-scope features, target platforms/browsers/devices, locales, accessibility, integrations.
- **Quality risks**: what can fail, impact, likelihood, regulatory/compliance, critical user journeys.
- **Constraints**: deadlines, environments, data availability, tooling, access/roles, CI/CD expectations.
- **Definitions**: severity vs priority scale, test levels and test types to cover, entry/exit criteria.

## Workflows

### 1) Create a test plan (and/or test strategy)

1. Identify test objectives, scope, assumptions, and constraints from the test basis.
2. Define test levels and types (functional + change-related + key non-functional, as applicable).
3. Choose test design techniques per area (see `references/test-design-techniques.md`).
4. Specify environments, test data, tooling, and configuration management needs.
5. Define entry/exit criteria, deliverables, and reporting cadence/metrics.
6. Add a risk matrix and mitigation actions; prioritize testing accordingly (risk-based testing).

Use: `templates/test-plan.md` (detailed sections + checklists).

### 2) Generate test conditions and test cases

1. Convert the test basis into **test conditions** (what to test) before writing step-by-step cases.
2. For each condition, pick a technique:
   - Equivalence partitions and boundary values for inputs/validation.
   - Decision tables for rule combinations.
   - State transitions for lifecycle/flows.
   - Use-case/scenario tests for end-to-end journeys.
   - Exploratory testing sessions to learn quickly (see `templates/exploratory-charter.md`).
3. Write test cases that are atomic, unambiguous, and traceable to requirement/user story IDs.
4. Add expected results that are observable and measurable (define the test oracle).
5. Add priority and risk tags to support risk-based regression selection.
6. Mark automation candidates using stability + value criteria (see `references/automation-playwright-best-practices.md`).

Use: `templates/test-cases.csv`.

### 3) Implement automation test scripts (Playwright-first)

1. Keep tests readable and aligned with test cases (include test case IDs in titles).
2. Prefer stable locators (e.g., `getByTestId`) over brittle selectors.
3. Avoid arbitrary sleeps; rely on Playwright auto-waits and explicit assertions.
4. Make tests independent (setup preconditions explicitly; avoid order dependencies).
5. Use tagging in test titles (e.g., `@smoke`, `@regression`) so suites are runnable via `--grep`.
6. Capture artifacts for triage (screenshots/video/trace) when debugging failures.

Use: `templates/playwright-spec.ts` and `references/automation-playwright-best-practices.md`.

### 4) Build and maintain regression suites

1. Define suite tiers (example): smoke (critical paths), sanity (build verification), regression (broad), full (release).
2. Select tests using risk + frequency + criticality + defect history (not only coverage).
3. Tag tests consistently and document selection rules and ownership.
4. Review the suite regularly: remove obsolete coverage, add coverage for escaped defects and high-risk changes.

Use: `templates/regression-suite.md` and `references/regression-suite-strategy.md`.

### 5) Create bug reports and document bugs effectively

1. Reproduce reliably; reduce to minimal steps; note variability (frequency) and scope.
2. Capture environment details (build/app version, OS, browser/device, account/role, data conditions).
3. Describe expected vs actual behavior; include impact; set severity and priority consistently.
4. Attach evidence (screenshots, console logs, network traces, Playwright trace) and link related tests/requirements.
5. Track lifecycle: triage notes, owner, fix version, verification steps and results, closure criteria.

Use: `templates/bug-report.md` and `references/bug-report-quality.md`.

### 6) Conduct static testing (reviews)

1. Schedule reviews early (shift-left): requirements, designs, test plans, test cases.
2. Use checklists for consistency (see `references/static-testing.md`).
3. Document findings with severity and actionability.
4. Track defects found in static testing separately (prevention vs detection).

Use: `references/static-testing.md` for review checklists and techniques.

### 7) Estimate test effort

1. Identify factors: scope, complexity, risk, team experience, tool maturity.
2. Apply estimation techniques (see `references/test-estimation.md`):
   - Expert judgment / historical data
   - Test point analysis
   - Work breakdown structure
3. Add contingency for risks and unknowns.
4. Review and refine estimates as the project progresses.

Use: `references/test-estimation.md` for techniques and formulas.

### 8) Monitor test progress and metrics

1. Track execution metrics: planned vs executed vs passed vs failed vs blocked.
2. Monitor defect metrics: found vs fixed vs open, by severity/priority.
3. Calculate test coverage: requirements covered, risk areas tested.
4. Report status regularly and escalate blockers early.

Use: `references/test-monitoring-metrics.md` for metrics definitions and dashboards.

## Quality Gates (self-check)

- **Test plan** includes scope, approach, risks, environments, entry/exit criteria, deliverables, and metrics.
- **Test cases** are traceable, atomic, deterministic, and include clear oracles and data.
- **Automation** is maintainable (stable locators, minimal flake, independent tests, clear assertions).
- **Regression** is risk-based, tagged, and curated with clear add/remove rules.
- **Bug reports** are reproducible, actionable, and contain evidence + environment + impact.
- **Static testing** reviews are documented with findings tracked to resolution.
- **Estimates** include contingency and are refined as scope clarifies.

## Troubleshooting

| Problem                      | Cause                             | Solution                                                      |
| ---------------------------- | --------------------------------- | ------------------------------------------------------------- |
| Test cases lack traceability | Missing requirement IDs           | Add `requirement_id` column; link to user stories/ACs         |
| Bug reports get rejected     | Insufficient reproduction steps   | Use minimal steps; include exact data and environment         |
| Regression suite too slow    | Too many tests, no prioritization | Apply risk-based selection; tier into smoke/sanity/full       |
| Flaky automated tests        | Unstable locators or timing       | Use `data-testid`; avoid sleeps; use Playwright auto-waits    |
| Test estimates are wrong     | Scope creep, missing risks        | Add contingency; re-estimate when scope changes               |
| Reviews find no defects      | Superficial review                | Use checklists; allocate sufficient time; rotate reviewers    |
| Unclear test oracles         | Missing expected results          | Define oracles from requirements, rules, or reference systems |

## Bundled Resources

### Templates (`templates/`)

| Template                        | Purpose                                        |
| ------------------------------- | ---------------------------------------------- |
| `test-plan.md`                  | ISTQB-aligned test plan structure              |
| `test-summary-report.md`        | End-of-cycle summary and sign-off              |
| `test-cases.csv`                | Test case repository with traceability         |
| `test-conditions.md`            | Test conditions derived from test basis        |
| `traceability-matrix.csv`       | Requirements ↔ tests ↔ defects mapping         |
| `bug-report.md`                 | Detailed defect report                         |
| `bug-log.csv`                   | Defect tracking log                            |
| `regression-suite.md`           | Suite definition and selection rules           |
| `exploratory-charter.md`        | Session-based exploratory testing              |
| `playwright-spec.ts`            | Playwright test scaffold                       |
| `test-environment-checklist.md` | Environment readiness verification             |
| `risk-assessment-matrix.md`     | Quality risk identification and prioritization |

### References (`references/`)

| Reference                                 | Content                                                           |
| ----------------------------------------- | ----------------------------------------------------------------- |
| `test-design-techniques.md`               | EP, BVA, decision tables, state transitions, use cases            |
| `experience-based-techniques.md`          | Error guessing, checklist-based, exploratory                      |
| `static-testing.md`                       | Reviews, walkthroughs, inspections                                |
| `test-levels-types.md`                    | Unit, integration, system, acceptance; functional, non-functional |
| `test-estimation.md`                      | Estimation techniques and factors                                 |
| `test-monitoring-metrics.md`              | Progress tracking and quality metrics                             |
| `risk-based-testing.md`                   | Risk identification, analysis, mitigation                         |
| `istqb-glossary.md`                       | Key ISTQB terminology                                             |
| `test-process-and-deliverables.md`        | Test process phases and outputs                                   |
| `automation-playwright-best-practices.md` | Playwright implementation guidance                                |
| `regression-suite-strategy.md`            | Suite management and optimization                                 |
| `bug-report-quality.md`                   | Effective defect reporting                                        |
| `defect-lifecycle.md`                     | Defect states and workflow                                        |

### Scripts (`scripts/`)

| Script             | Purpose                                          |
| ------------------ | ------------------------------------------------ |
| `qa_artifacts.mjs` | CLI tool to generate QA artifacts from templates |

---

## Common Rationalizations

> Common shortcuts and "good enough" excuses that erode test quality — and the reality behind each.

| Rationalization                                   | Reality                                                                                                           |
| ------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| "ISTQB theory doesn't apply in practice"          | Equivalence partitioning and boundary value analysis directly reduce test count while maintaining coverage.       |
| "We don't need test plans for small projects"     | Even small projects benefit from structured testing. A lightweight test plan prevents scope creep.                |
| "Exploratory testing isn't real testing"          | Exploratory testing finds bugs that scripted tests never will. It's a disciplined technique, not ad-hoc clicking. |
| "Risk-based testing means testing less"           | It means testing smarter — focusing effort where failure impact is highest, not testing everything equally.       |
| "Traceability matrices are bureaucratic overhead" | They prove coverage, support audit readiness, and reveal gaps between requirements and tests.                     |
| "Manual testing is obsolete"                      | Manual testing catches usability, visual, and accessibility issues that automation misses entirely.               |

---

## Verification

After completing this skill's workflow, confirm:

- [ ] **Test cases follow ISTQB structure** — Each case has: ID, description, preconditions, steps, expected result, actual result
- [ ] **Coverage matrix maintained** — Requirements mapped to test cases; no uncovered requirements
- [ ] **Priority levels assigned** — Each test case has a priority (Critical, High, Medium, Low)
- [ ] **Positive and negative scenarios** — Both valid and invalid inputs tested
- [ ] **Edge cases documented** — Boundary values, empty inputs, and extreme values covered
- [ ] **Test data documented** — Specific test data values listed, not just "valid data"
- [ ] **Traceability maintained** — Each test case links to a requirement or user story
