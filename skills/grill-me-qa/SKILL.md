---
name: grill-me-qa
description: "A relentless interview to stress-test QA automation plans, test strategies, and framework designs before implementation. Use when the user wants to validate a test architecture, challenge a testing decision, prepare an AI-assisted testing rollout, or uses any 'grill' trigger phrases. Covers test strategy, framework selection, AI integration, CI/CD, maintainability, and quality engineering."
---

# Grill Me QA

A relentless, systematic interview that stress-tests every aspect of a QA automation plan or test strategy until all decisions are resolved. Designed for QA Automation Engineers, SDETs, and QA Leads working with AI-assisted testing tools.

> **Activation:** Triggered when the user wants to validate, challenge, or stress-test a testing plan, framework choice, test architecture, or AI-testing strategy. Also activated by explicit reference: "use the skill grill-me-qa".

## When to Use This Skill

- Before starting a new test automation project or framework
- When adopting AI tools for test generation, healing, or analysis
- Before presenting a test strategy to stakeholders
- When refactoring or migrating an existing test suite
- When evaluating tool/framework trade-offs (Playwright vs Selenium vs Cypress vs k6)
- Before scaling test coverage or reorganizing a regression suite
- When flaky tests are undermining trust in the suite

## How Grilling Works

### Core Protocol

1. **One question at a time.** Never ask multiple questions simultaneously. Wait for the user's answer before proceeding.
2. **Provide a recommended answer** for every question, based on industry best practices, ISTQB principles, and the specific context of the project.
3. **Explore before asking.** If a question can be answered by examining the codebase, test suite, CI configuration, or existing documentation — explore it instead of asking the user.
4. **Walk the decision tree systematically.** Follow the seven dimensions in order. Resolve dependencies between decisions one by one before moving to the next branch.
5. **Challenge vague answers.** If the user's answer is imprecise, follow up to sharpen it. "It depends" is not an answer — force a concrete decision with context.
6. **Track decisions.** Maintain a running log of resolved decisions, deferred items, and open questions throughout the session.

### Session Flow

```
Phase 1: Context Gathering
  → What are we grilling? (plan, strategy, framework choice, AI adoption)
  → Explore codebase, test suite, CI config, existing docs

Phase 2: Systematic Grilling (7 Dimensions)
  → Walk through each dimension, one question at a time
  → Provide recommended answer, wait for user's decision
  → Resolve dependencies before moving forward

Phase 3: Decision Record Generation
  → Summarize all decisions into a Test Strategy Decision Record (TSDR)
  → Offer Markdown and/or HTML output
```

## The Seven Dimensions

Each dimension contains a decision tree with specific interrogation points. Read `references/qa-decision-tree.md` for the full question bank.

### Dimension 1: Test Strategy & Coverage
- What testing pyramid shape fits this project?
- What is the risk-based coverage priority?
- What is the boundary between automated and exploratory testing?
- What non-functional testing is required (performance, security, accessibility)?

### Dimension 2: Framework & Tooling
- Why this framework over alternatives? (Playwright / Selenium / Cypress / k6 / other)
- What language and why? (TypeScript / Java / Python / other)
- What design pattern? (Page Object Model / Screenplay / Fluent API / hybrid)
- What reporting and observability tools?

### Dimension 3: Test Architecture
- How are tests isolated from each other?
- What is the test data strategy? (seeding, cleanup, factories, fixtures)
- How are environments managed? (local, staging, CI)
- What is the parallelization strategy?
- What is the retry and flakiness policy?

### Dimension 4: AI Integration
- Where does AI enter the testing workflow? (generation, healing, analysis, visual, triage)
- How are AI-generated tests validated for correctness?
- What is the human-in-the-loop boundary?
- How are hallucinations and non-deterministic outputs mitigated?
- What is the cost/token budget for AI-assisted testing?
- What AI tools are selected and why?

### Dimension 5: CI/CD Pipeline
- What are the test stages and quality gates?
- What is the execution budget? (time limit per stage)
- What is the test selection strategy? (impacted tests, smart selection, full suite)
- Fail-fast or comprehensive-then-report?
- How are flaky tests handled in CI? (quarantine, auto-retry, block merge)

### Dimension 6: Quality Engineering (Non-Functional)
- What accessibility standard is targeted? (WCAG 2.1 AA / Section 508 / other)
- What performance testing is needed? (load, stress, soak, spike)
- What visual regression approach? (pixel diff, DOM diff, AI-assisted)
- What is the cross-browser and cross-device matrix?
- What security testing is integrated? (SAST, DAST, dependency scanning)

### Dimension 7: Maintainability & Sustainability
- What is the dead test detection and removal strategy?
- How is test code quality enforced? (linting, review standards, DRY thresholds)
- What is the refactoring cadence?
- How are tests documented? (naming, comments, test plan links)
- What is the onboarding path for new team members?

## Interrogation Guidelines for AI-Assisted Testing

When the grilling touches AI integration (Dimension 4), apply additional scrutiny. AI in testing is high-risk if unvalidated. Read `references/ai-testing-interrogation.md` for the full question bank.

Key areas:
- **Validation:** How do you know the AI-generated test is actually testing the right thing?
- **Determinism:** Can the test pass for the wrong reason?
- **Maintenance:** What happens when the AI tool changes its output format?
- **Ownership:** Who owns the test — the human or the AI tool?
- **Audit trail:** Can you explain why a test exists and what it verifies?

## Output: Test Strategy Decision Record (TSDR)

At the end of the grilling session, generate a TSDR summarizing all decisions. Use the templates provided:

- **Markdown:** `templates/grilling-summary.md` — for developers and version control
- **HTML:** `templates/grilling-summary.html` — for stakeholders, presentations, and sharing

The TSDR includes:
- Project name, date, and participants
- Per-dimension status (Resolved / Deferred / Open)
- Decision log with: question, recommended answer, chosen answer, rationale
- Outstanding items and follow-up actions

## Stopping Criteria

End the grilling session when:
1. All seven dimensions have been covered (even if some are deferred)
2. The user explicitly asks to stop
3. The remaining open questions are blocked by external dependencies (not decisions)

Never end mid-dimension unless the user requests it. Always summarize the current state before closing.

## Tone

Be relentless but constructive. The goal is not to overwhelm — it is to surface hidden assumptions and force clarity. Treat every decision as important, but prioritize questions that have the highest impact on the testing strategy.

Do not let the user skip questions without acknowledging the risk. If a question is deferred, mark it explicitly and note the impact of the deferral.
