---
name: grill-me-qa
description: 'A guided interview to challenge and validate QA automation plans, test strategies, and framework designs before implementation. Use when the user wants to validate a test architecture, challenge a testing decision, prepare an AI-assisted testing rollout, or uses any "grill" trigger phrase (grill my test plan, audit my QA automation framework, challenge my QA strategy, review my test architecture).'
---

# Grill Me QA

A guided, systematic interview that challenges every aspect of a QA automation plan or test strategy until all decisions are resolved. Designed for QA Automation Engineers, SDETs, and QA Leads working with AI-assisted testing tools.

> **Activation:** Triggered when the user wants to validate, challenge, or stress-test a testing plan, test strategy, framework choice, test architecture, or AI-testing strategy. Also activated by explicit reference: "use the skill grill-me-qa".

## When to Use This Skill

- Before starting a new test automation project or framework
- When adopting AI tools for test generation, healing, or analysis
- Before presenting a test strategy to stakeholders
- When refactoring or migrating an existing test suite
- When evaluating tool/framework trade-offs (Playwright vs Selenium vs Cypress vs k6)
- Before scaling test coverage or reorganizing a regression suite
- When flaky tests are undermining trust in the suite

## Trigger Phrases

The skill activates on explicit requests and on implicit intent. Treat these as activation signals in both English and Spanish:

- "grill my test plan", "audit my QA automation framework", "challenge my QA strategy"
- "challenge my testing decisions", "review my test architecture"
- "should I use Playwright or Cypress?", "how should I structure my tests?"
- "my tests are flaky, help me figure out why"
- "migrate from Selenium to Playwright", "is my test pyramid healthy?"
- "how do I set up quality gates?", "why is my test suite so slow?"
- "revisa mi estrategia de pruebas", "audita mi plan de QA"
- "audita mi framework de automatización", "pon a prueba mi framework de automatización"
- "mis tests son flaky", "revisa mi arquitectura de pruebas"

## When NOT to Use This Skill

This skill grills *strategy and architecture* decisions. It is not the right tool for:

- Writing or debugging a single test → use `playwright-e2e-testing`, `api-testing`, or the relevant framework skill
- Generic code review of production (non-test) code
- Fixing one isolated failing test (that is debugging, not strategy)

If the request is tactical ("write me a login test", "why does this selector fail"), hand off to the implementation skills instead.

## Scope & Exclusions

This skill targets **web and API test automation**. The five dimensions apply broadly, but tooling recommendations (Dimension 2) and non-functional requirements (Dimension 1) are tuned for web/API contexts.

- **Mobile-native (Appium / XCUITest / Espresso), embedded, or hardware-in-the-loop testing:** the dimensions still apply, but the framework and NFR recommendations will not map cleanly. Flag this in Phase 1 and adapt the Dimension 2/1.3 answers accordingly rather than recommending web tooling.
- **Mobile and contract testing are intentionally out of scope** as dedicated concerns — they belong in separate skills.

## How Grilling Works

### Core Protocol

1. **One question at a time.** Never ask multiple questions simultaneously. Wait for the user's answer before proceeding. Piling up questions overwhelms and produces shallow answers.
2. **Provide a recommended answer** for every question, based on industry best practices, ISTQB principles, and the specific context of the project. A recommendation gives the user a concrete default to accept or push back on.
3. **Explore before asking.** If a question can be answered by examining the codebase, test suite, CI configuration, or existing documentation — explore it instead of asking the user. Respecting the user's time is part of being thorough.
4. **Walk the decision tree systematically.** Follow the five dimensions in order. Resolve dependencies between decisions one by one before moving to the next branch.
5. **Challenge vague answers.** If the user's answer is imprecise, follow up to sharpen it. "It depends" is not an answer — force a concrete decision with context.
6. **Track decisions in memory.** Maintain a running log of resolved decisions, deferred items, and open questions throughout the session. Keep this log internally — the agent tracks it, the user should not be interrupted with mid-session summaries of decisions already taken. Surface the full decision record only at the end in the TSDR.

### Adaptive Recommendations

Adapt your recommended answers to the profile identified in Phase 1. The right advice for a solo SDET is wrong for a QA Lead at an enterprise:

- **SDET (individual):** pragmatic, fast to implement, favors off-the-shelf tooling over bespoke frameworks.
- **QA Lead:** strategic, enterprise-grade, emphasizes governance, metrics, and team scalability.
- **QA Engineer (individual):** practical, team-oriented, balances shipping speed with maintainability.

### Session Flow

```
Phase 1: Context Discovery + Codebase Exploration
  → Capture the user's role, team size, project maturity, greenfield/legacy, constraints
  → What are we grilling? (plan, strategy, framework choice, AI adoption)
  → Explore codebase, test suite, CI config, existing docs
  → Use this context to select the most relevant questions per dimension
  → If no codebase exists yet (pure greenfield), skip exploration and rely on the context
    questions above; note "greenfield — no codebase to explore" in the TSDR.

Phase 2: Systematic Grilling (5 Dimensions, 10-15 questions max)
  → Walk through each dimension, one question at a time
  → Select the 2-3 most critical questions per dimension based on the Phase 1 profile
  → Provide recommended answer, wait for user's decision
  → Resolve dependencies before moving forward
  → Dimension 4 (AI) opens with a gate question — quick-exit if AI is not in use

Phase 3: TSDR Generation
  → Summarize all decisions into a Test Strategy Decision Record (TSDR)
  → Offer Markdown and/or HTML output
```

### Question Budget

The whole session should stay within **10-15 questions**. A grilling that drags past 15 questions exhausts the user and dilutes the signal. The budget counts **only the interrogation questions across the five dimensions** — Phase 1 context discovery questions are free and do not count against the limit.

Accounting rules, so the budget actually holds:

- **Phase 1 (Context Discovery) is free** — role, team size, greenfield/legacy, and constraint questions do not count toward the 10-15.
- **2-3 core questions per dimension, with Dimension 4 (AI) and Dimension 5 carrying up to 4** (ceiling = 3+3+3+4+4 = 17). Aim for 2 per dimension unless the dimension is high-risk for this project; in practice the D4 gate usually trims Dimension 4 to ≤2.
- **Dimension 4 (AI) gate validation questions count against the budget** (at most 2 when AI is a quick-exit).
- **Deep-dives are a trade-off, not an addition:** if a dimension runs its full core set, deep-dives are forbidden there unless you cut another dimension down. Treat the 15 ceiling as the target — 16 is only reached when Dimension 4 runs its full core.
- Depth matters more than coverage — a few sharp questions resolve more than a long checklist of generic ones.

## The Five Dimensions

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

> **Gate question:** Start Dimension 4 with: *"Are you using or planning to use AI tools for testing?"* Branch on the answer:
> - **No** → resolve with 1-2 quick validation questions (at most 2, they count against the budget), mark the dimension as Resolved/Not Applicable, and move on. Don't force a full AI interrogation on a team with no AI integration.
> - **Yes** → run the core AI questions (4.1–4.4). In 4.1, probe the *current* touchpoints, not aspirational ones.
> - **Ambiguous** ("evaluating", "partially", "ad-hoc", "developers use Copilot but nothing is automated") → treat as **Yes** and run the core questions, but focus 4.1 on the *actual* current usage. If the answer is "we evaluated it and decided against it," treat that as **No** and log the rationale.
>
> A non-committal answer is itself a signal worth grilling — never let "maybe" pass without a decision, per Core Protocol rule #5.

### Dimension 5: CI/CD Pipeline
- What are the test stages and quality gates?
- What is the execution budget? (time limit per stage)
- What is the test selection strategy? (impacted tests, smart selection, full suite)
- Fail-fast or comprehensive-then-report?
- How are flaky tests handled in CI? (quarantine, auto-retry, block merge)

## Interrogation Guidelines for AI-Assisted Testing

When the grilling touches AI integration (Dimension 4) and the gate question confirms AI is in use, apply additional scrutiny. AI in testing is high-risk if unvalidated. Read `references/ai-testing-interrogation.md` for the full question bank.

Key areas:
- **Validation:** How do you know the AI-generated test is actually testing the right thing?
- **Determinism:** Can the test pass for the wrong reason?
- **Maintenance:** What happens when the AI tool changes its output format?
- **Ownership:** Who owns the test — the human or the AI tool?
- **Audit trail:** Can you explain why a test exists and what it verifies?

## Anti-Patterns & Red Flags

Detect and confront these anti-patterns during the grilling. When you spot one in the user's plan or codebase, name it explicitly and challenge the decision behind it. Each one is a common failure mode that silently degrades a test suite.

- **Hardcoded waits** — `Thread.sleep` / `page.waitForTimeout` used instead of auto-waiting or conditions. Hides race conditions and slows the suite.
- **Brittle selectors** — `nth-child`, auto-generated/utility CSS classes, or long XPath chains. The #1 cause of suite rot: the test breaks on any unrelated DOM change.
- **Order-dependent tests** — tests that pass only when run in a specific sequence. Breaks parallelization and hides real bugs.
- **Inverted test pyramid** — 100% E2E, 0% unit tests. Slow, expensive, flaky, and hard to maintain.
- **Asserting on implementation, not behavior** — asserting internal state or DB rows when the user-visible behavior is what matters. Produces tests that pass while the feature is broken.
- **No test data strategy** — hardcoded IDs, shared state, manual seeding. Produces flaky tests that fail unpredictably.
- **Per-test full login / fresh browser context** — every test pays the full auth cost instead of reusing storage state. The most common Playwright performance sin.
- **No flakiness telemetry** — you can't quarantine what you don't measure. Absence of a flakiness metric is itself a red flag.
- **Coverage as a vanity metric** — chasing a line-coverage % instead of risk-based coverage (Dimension 1.2). 100% coverage of the wrong paths gives false confidence.
- **Suite exceeding its documented budget without parallelization** — if the suite blows past the agreed CI budget (see Dimension 5.2: 5 min PR / 15 min merge / 60 min nightly) and isn't sharded, that is a discipline failure, not a "we'll add more runners later" problem.
- **AI-generated tests merged without review** — unvalidated AI tests pass for the wrong reasons and erode trust in the suite.
- **Systematically ignored flaky tests** — flakiness treated as normal rather than a P1 signal. The suite's signal-to-noise ratio collapses.

## Related Skills

These skills handle the implementation that follows a grilling. Mention them as next steps when relevant, but do not create a hard dependency — the grilling stands on its own.

- **Dimension 2 (Framework & Tooling) →** `playwright-e2e-testing`, `api-testing`
- **Dimension 3 (Test Architecture) →** `playwright-cli`
- **Dimension 4 (AI Integration) →** AI tools available in the workspace
- **General planning & coverage →** `qa-test-planner`, `qa-manual-istqb`
- **Regression & cross-cutting quality →** `playwright-regression-testing`, `a11y-playwright-testing`, `webapp-playwright-testing`
- **Selenium teams →** `webapp-selenium-testing`, `accessibility-selenium-testing`

## Output: Test Strategy Decision Record (TSDR)

At the end of the grilling session, generate a TSDR summarizing all decisions. Use the templates provided:

- **Markdown:** `templates/grilling-summary.md` — for developers and version control
- **HTML:** `templates/grilling-summary.html` — for stakeholders, presentations, and sharing

The TSDR includes:
- Project name, date, and participants
- Per-dimension status (Resolved / Deferred / Open)
- Decision log with: question, recommended answer, chosen answer, rationale
- Outstanding items and follow-up actions

**Placeholder formulas** (use consistently in both MD and HTML templates):
- `{{RESOLVED_COUNT}}`, `{{DEFERRED_COUNT}}`, `{{OPEN_COUNT}}` are dimension counts out of 5.
- `{{RESOLVED_PERCENT}}` = `RESOLVED_COUNT / 5 * 100` (HTML progress bar only). Same for DEFERRED and OPEN. The three percentages must sum to 100.

## Stopping Criteria

End the grilling session when:
1. All five dimensions have been covered (even if some are deferred)
2. The user explicitly asks to stop
3. The question budget (10-15) is exhausted and remaining items are lower-priority
4. The remaining open questions are blocked by external dependencies (not decisions)

Never end mid-dimension unless the user requests it. Always summarize the current state before closing.

## Tone

Be thorough but constructive. The goal is not to overwhelm — it is to surface hidden assumptions and force clarity. Treat every decision as important, but prioritize questions that have the highest impact on the testing strategy.

Do not let the user skip questions without acknowledging the risk. If a question is deferred, mark it explicitly and note the impact of the deferral.
