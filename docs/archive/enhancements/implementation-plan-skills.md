# Implementation Plan — Skills Consolidation v3

## Purpose

Version 3 consolidates the catalog from 11 to 9 skills to remove discovery overlap while preserving the Context Engineering improvements completed in v2. The design follows [Anthropic's guidance](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models) to use clear interfaces, progressive disclosure, and only the constraints that affect behavior.

## Decisions

| Former or current intent | Canonical skill | Boundary |
| --- | --- | --- |
| Test plans, cases, bugs, traceability, charters | `qa-manual-istqb` | Creates QA artifacts and applies ISTQB test design. |
| Versioned Playwright UI specs | `playwright-e2e-testing` | Authors and maintains `@playwright/test` browser-flow specs. |
| Live browser exploration and evidence | `playwright-cli` | Drives an interactive browser session through the CLI. |
| REST or GraphQL endpoint contracts | `api-testing` | Tests schemas, auth, errors, pagination, idempotency, and rate limits. |
| Regression-suite governance | `playwright-regression-testing` | Selects, tiers, runs, and optimizes many Playwright tests. |
| WCAG automation | Framework-specific a11y skill | Uses the Playwright or Selenium implementation required by the project. |
| QA architecture decisions | `grill-me-qa` | Challenges a proposal; it does not generate its delivery artifacts. |

## Breaking Changes and Migration

This is a major release: `.claude-plugin/plugin.json` is version `3.0.0`. No compatibility shims or deprecated skill folders are retained.

| Removed skill | Replacement | Prompt migration |
| --- | --- | --- |
| `qa-test-planner` | `qa-manual-istqb` | Replace “Use `qa-test-planner` to create a test plan” with “Use `qa-manual-istqb` to create a test plan, cases, and traceability.” |
| `webapp-playwright-testing` | `playwright-cli` | Replace “Open the browser and test” with “Use `playwright-cli` to inspect the page, interact with it, and capture evidence.” |

`qa-manual-istqb` keeps its existing templates, references, and `qa_artifacts.mjs` generator as the canonical QA-artifact resources. The removed planner resources were not migrated because they duplicate those deliverables, add unnecessary context, and include obsolete MCP-oriented guidance.

## Implementation Record

1. Merge QA artifact discovery into `qa-manual-istqb`; delete `skills/qa-test-planner/`.
2. Retire the MCP browser skill and its resources; direct live exploration to `playwright-cli`.
3. Tighten skill descriptions around distinct user intents: UI spec, endpoint contract, live CLI session, suite governance, QA artifact, accessibility, and strategic review.
4. Update catalog counts, installation instructions, routing tables, orchestration references, and setup guides.
5. Preserve `implementation-plan-v2.md` as a dated historical baseline and link this v3 document from it.

## Validation Matrix

| Prompt | Expected skill |
| --- | --- |
| “Create a checkout spec with Page Objects.” | `playwright-e2e-testing` |
| “Inspect login, capture a screenshot, and check console errors.” | `playwright-cli` |
| “Test the `POST /orders` schema and 401 response.” | `api-testing` |
| “Create a payment test plan, cases, and bug template.” | `qa-manual-istqb` |
| “Optimize smoke selection and sharding.” | `playwright-regression-testing` |
| “Add WCAG keyboard checks to the login page.” | `a11y-playwright-testing` or `accessibility-selenium-testing` |
| “Challenge our QA automation architecture.” | `grill-me-qa` |

## Acceptance Criteria

- Exactly nine `skills/*/SKILL.md` files remain, each with valid YAML frontmatter and a matching directory name.
- Active documentation has no references to the removed names; this migration document and the archived v2 baseline are the only allowed historical mentions.
- All internal Markdown links resolve and all catalog counts state nine skills.
- The version is `3.0.0` and the routing matrix above is reflected in skill descriptions and user-facing documentation.
