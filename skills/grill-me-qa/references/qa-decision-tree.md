# QA Decision Tree — Full Question Bank

This reference contains the complete interrogation tree for all five dimensions. During a grilling session, work through each dimension in order. Within each dimension, resolve dependencies top-to-bottom unless the user redirects.

**Selection rule:** Select the core questions based on the Phase 1 profile (SDET / QA Lead / Individual) and the codebase explored. A deep-dive is allowed only when its dimension is using fewer than 3 core questions, or another dimension was cut to 2 — the 15-question session ceiling is hard.

**Adaptive answers:** Every recommended answer is tailored by profile. Treat these as defaults — adjust to the project's specifics, but keep the per-profile emphasis.

| Profile | Emphasis |
|---------|----------|
| **SDET (individual)** | Pragmatic, fast to implement, off-the-shelf tooling over bespoke frameworks |
| **QA Lead** | Strategic, enterprise-grade governance, metrics, team scalability |
| **QA Engineer (individual)** | Practical, team-oriented, balances shipping speed with maintainability |

---

## Dimension 1: Test Strategy & Coverage

### 1.1 What testing pyramid shape fits this project?

- What is the current ratio of unit / integration / E2E tests?
- Does a testing trophy (more integration) fit better than the traditional pyramid?

**Recommended answer:** Start with the testing trophy (Kent C. Dodds) for web applications — emphasize integration tests over E2E. Reserve E2E for critical user journeys only (5-15% of total). Adjust based on app architecture (microservices may need more contract/integration tests).

- **SDET:** Trophy. Ship integration tests fast; keep E2E to a handful of smoke journeys.
- **QA Lead:** Trophy + coverage targets per layer as a governance metric (e.g., unit ≥70%, E2E ≤15%).
- **Individual:** Pragmatic trophy — whatever the current test runner makes cheapest to write.

### 1.2 What is the risk-based coverage priority?

- Which features have the highest business risk if they break?
- Which areas have the most production incidents historically?

**Recommended answer:** Map every test to a risk score (impact × likelihood). Prioritize coverage so that P0 critical paths have 100% automated coverage, P1 paths have 80%+, and P2 paths are covered by exploratory testing. Use production incident history as input.

- **SDET:** Focus on P0 paths only; defer P1/P2 until the suite stabilizes.
- **QA Lead:** Full P0/P1/P2 matrix tracked in a dashboard; review quarterly.
- **Individual:** P0 + P1 automated; P2 via scheduled exploratory sessions.

### 1.3 What non-functional testing is required?

- Performance: what are the SLAs and load profiles?
- Accessibility: what standard must be met (WCAG 2.1 AA is typical)?
- Security: what compliance requirements apply (OWASP, PCI, HIPAA)?

**Recommended answer:** Non-functional requirements should be defined by business needs, not assumed. At minimum: WCAG 2.1 AA for accessibility, baseline performance budgets (Lighthouse CI), and OWASP Top 10 scanning. Add load testing for high-traffic endpoints.

- **SDET:** Lighthouse CI in the pipeline; defer load/security to dedicated tooling.
- **QA Lead:** Full NFR policy (a11y, perf, security) with ownership and SLAs.
- **Individual:** axe-core scans on PRs + Lighthouse CI; raise load/security as backlog items.

---

## Dimension 2: Framework & Tooling

### 2.1 Why this framework over alternatives?

- What frameworks were evaluated, and against what criteria?
- Is the framework suited to the team's expertise, or will it require training?

**Recommended answer:** Document a comparison matrix with weighted criteria. For modern web apps with TypeScript: Playwright is the leading choice (speed, auto-waiting, multi-browser, MCP integration). For Java teams: Selenium + JUnit 5 + AssertJ remains solid. For API testing: Playwright API fixtures or REST Assured. Avoid mixing frameworks unless justified by a clear boundary.

- **SDET:** Pick what ships fastest — Playwright for TS/JS, Selenium + JUnit for Java. One framework, no mix.
- **QA Lead:** Weighted matrix + migration path; standardize across teams.
- **Individual:** Match the team's primary language; optimize for onboarding speed.

### 2.2 What design pattern?

- Page Object Model (POM)?
- Screenplay Pattern?
- Fluent API / Builder?

**Recommended answer:** POM for small-to-medium suites (under 500 tests) — it is well-understood and widely supported. Screenplay for large, complex suites with many actors and workflows — it scales better for composition and reuse. Avoid anemic POMs (just locators, no behavior).

- **SDET:** POM with behavior-rich page objects; get moving fast.
- **QA Lead:** Screenplay at scale; POM for smaller products; enforce via linting/review.
- **Individual:** POM; follow the existing team convention if one exists.

### 2.3 What reporting and observability tools?

- HTML reports? (Allure, Playwright HTML, ReportPortal)
- Test observability? (traces, videos, screenshots on failure)

**Recommended answer:** Allure or ReportPortal for rich reporting. Playwright's built-in trace viewer for debugging. Always enable video + screenshot on failure in CI. Export JUnit XML for CI integration. Consider ReportPortal if multiple teams need a shared dashboard.

- **SDET:** Playwright HTML report + traces; Allure if cheap to add.
- **QA Lead:** ReportPortal or Allure as a shared cross-team dashboard with metrics.
- **Individual:** Built-in HTML report + failure artifacts; Allure when stakeholders ask.

---

## Dimension 3: Test Architecture

### 3.1 How are tests isolated from each other?

- Does each test create its own data, or is there shared state?
- Are tests order-dependent? What happens in parallel?

**Recommended answer:** Zero shared state. Each test creates and cleans up its own data. Use `beforeEach`/`afterEach` for setup and teardown. Tests must pass in any order and in parallel. Use database transactions or API-based cleanup for data isolation.

- **SDET:** API-based create/cleanup per test; parallelize from day one.
- **QA Lead:** Isolation as a review gate; no shared-state PRs merged.
- **Individual:** `beforeEach`/`afterEach` discipline; quarantine anything that can't parallelize.

### 3.2 What is the test data strategy?

- Factories / builders? API-generated data? Hardcoded?
- What is the cleanup strategy?

**Recommended answer:** API-based test data creation (fast, reliable, no UI dependency). Use factory functions for complex objects. Never hardcode data that can change (IDs, timestamps, dynamic content). Cleanup via API calls or database resets, not UI interactions.

- **SDET:** API factories + API cleanup; one helper module, reused everywhere.
- **QA Lead:** Centralized data factory with ownership and versioning.
- **Individual:** Factories for the common entities; hardcode only truly static reference data.

### 3.3 What is the retry and flakiness policy?

- How many retries are acceptable? How are flaky tests detected and resolved?
- Is there a quarantine process?

**Recommended answer:** Zero retries in local development (expose flakiness immediately). In CI, allow 1-2 retries on non-critical paths, 0 on critical paths. Auto-detect flaky tests (tests that pass on retry). Flaky tests get a 48-hour fix window, then are quarantined with a tracking issue. Never silently suppress flakiness.

- **SDET:** Zero retries locally, one in CI; flaky test = P1 issue, same day.
- **QA Lead:** Flakiness rate as a tracked metric; block new tests if rate >2%.
- **Individual:** 1 retry in CI; 48-hour quarantine window with a tracking issue.

---

## Dimension 4: AI Integration

> See `references/ai-testing-interrogation.md` for the expanded question bank on this dimension.

> **Gate question:** Start this dimension with: *"Are you using or planning to use AI tools for testing?"*
> - **No** → resolve with 1-2 validation questions (at most 2, they count against the budget), mark as Resolved/Not Applicable, move on.
> - **Yes** → run core questions 4.1–4.4. In 4.1, probe current (not aspirational) touchpoints.
> - **Ambiguous** ("evaluating", "partially", "ad-hoc") → treat as Yes and run 4.1–4.4 focused on actual usage. "Evaluated and decided against" → treat as No, log the rationale.
>
> The core set for this dimension is 4.1–4.4 (mirrors `references/ai-testing-interrogation.md`). If the question budget is tight, 4.1 and 4.2 are the two most critical.

### 4.1 Where does AI enter the testing workflow?

- Test generation? Test healing? Visual regression? Triage? Test selection?

**Recommended answer:** Start with the lowest-risk AI integration first: triage and analysis. Then move to test generation with mandatory human review. Test healing should be opt-in and logged. Visual AI diffing is mature enough for production use. Never deploy AI-based test selection without a fallback to full suite execution.

- **SDET:** Triage first (low risk, high value); then generation with review gating.
- **QA Lead:** Tiered rollout plan; AI autonomy tiers defined per workflow.
- **Individual:** One AI touchpoint to start (usually generation with mandatory review).

### 4.2 How are AI-generated tests validated for correctness?

- Who reviews AI-generated tests before merge?
- What is the mutation testing strategy? (Can the test catch intentional bugs?)

**Recommended answer:** Every AI-generated test must pass a four-gate review: behavioral (matches spec), mutation (catches a deliberate bug), stability (no flakes over 10 runs), and readability (understandable without the author). See `references/ai-testing-interrogation.md`.

- **SDET:** Four gates enforced in CI where feasible; manual review for the rest.
- **QA Lead:** Four gates + tracking of AI test quality metrics over time.
- **Individual:** Behavioral + mutation gates as the minimum; add the rest as the suite matures.

### 4.3 What is the human-in-the-loop boundary?

- What decisions can the AI make autonomously vs. with human approval?
- Is there an audit trail (who decided what, when)?

**Recommended answer:** Define autonomy tiers (Suggest → Draft → Execute+log → Autonomous). Start everything at Tier 1-2. Advance only after 95%+ accuracy over 100+ verified executions. Maintain a complete audit log of every AI action.

- **SDET:** Everything at Tier 1-2; no autonomous AI in CI.
- **QA Lead:** Tiered policy documented; escalation criteria and audit logging enforced.
- **Individual:** Tier 1-2 with lightweight logging; escalate cautiously.

### 4.4 How are hallucinations and non-deterministic outputs mitigated?

- What temperature/decoding settings are used for test generation?
- How are AI outputs validated against the actual application?

**Recommended answer:** Use low-temperature settings (0.0-0.3) for test generation. Validate every AI selector/assertion against the live app during review. Run AI tests in a 7-day "canary" before promoting to the main suite. Track AI test quality metrics and feed them back into prompt engineering.

- **SDET:** Low temperature + canary mode; manual validation of selectors.
- **QA Lead:** Canary + feedback loop metrics; quality trends reported.
- **Individual:** Low temperature + spot-check validation; canary when CI allows.

---

## Dimension 5: CI/CD Pipeline

### 5.1 What are the test stages and quality gates?

- What runs on PR vs on merge vs on schedule?
- What gates block a merge?

**Recommended answer:** Three tiers: (1) **PR gate** — unit + integration + smoke E2E (under 5 min), blocks merge. (2) **Merge pipeline** — full regression suite + accessibility + performance baseline, runs post-merge. (3) **Nightly** — full E2E + visual regression + load tests. Gates: PR gate must pass 100%. Merge pipeline failures create issues but don't block. Nightly failures alert the team.

- **SDET:** PR gate blocks merge; nightly runs the heavy suite.
- **QA Lead:** All three tiers with quality gates as merge policy; metrics reported.
- **Individual:** PR gate + nightly; merge pipeline if CI minutes allow.

### 5.2 What is the execution budget?

- How long is acceptable for each stage?
- What happens when the suite exceeds the budget?

**Recommended answer:** PR gate: 5 minutes max. Merge pipeline: 15 minutes. Nightly: 60 minutes. If the suite exceeds budget, split into shards or prioritize test selection. Never let the suite grow unchecked — budget enforcement forces prioritization.

- **SDET:** Hard PR gate at 5 min; shard aggressively.
- **QA Lead:** Budget policy with trend tracking; alert when breached.
- **Individual:** 5-min PR gate; nightly can run longer without blocking.

### 5.3 What is the test selection strategy?

- Full suite every time? Impacted-area selection? AI-based selection?

**Recommended answer:** Use impact-based test selection for PRs (run only tests affected by the code change). Run full suite nightly. If using AI-based selection, maintain a 95%+ confidence threshold and always run a random 10% of non-selected tests as a safety net.

- **SDET:** Impact-based selection on PRs; full suite nightly.
- **QA Lead:** Impact-based + AI selection with a safety-net sample; selection coverage tracked.
- **Individual:** Impact-based selection; add AI selection only with a proven fallback.

### 5.4 How are flaky tests handled in CI?

**Recommended answer:** See Dimension 3.3 (retry and flakiness policy). In CI specifically: auto-retry once, log the retry, track flakiness rate as a metric. If flakiness rate exceeds 2%, block new test additions until the rate is brought down.

- **SDET:** One retry, logged; flaky test quarantined within 48h.
- **QA Lead:** Flakiness rate metric; >2% blocks new tests.
- **Individual:** One retry + quarantine window; report flakiness in the weekly review.
