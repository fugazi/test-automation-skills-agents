# QA Decision Tree — Full Question Bank

This reference contains the complete interrogation tree for all seven dimensions. During a grilling session, work through each dimension in order. Within each dimension, resolve dependencies top-to-bottom unless the user redirects.

---

## Dimension 1: Test Strategy & Coverage

### 1.1 What testing pyramid shape fits this project?

- What is the current ratio of unit / integration / E2E tests?
- Is the traditional pyramid (lots of unit, few E2E) right here, or does a testing trophy (more integration) fit better?
- What proportion of testing budget goes to E2E vs API vs unit?

**Recommended answer:** Start with the testing trophy (Kent C. Dodds) for web applications — emphasize integration tests over E2E. Reserve E2E for critical user journeys only (5-15% of total). Adjust based on app architecture (microservices may need more contract/integration tests).

### 1.2 What is the risk-based coverage priority?

- Which features have the highest business risk if they break?
- Which areas change most frequently?
- Which areas have the most production incidents historically?
- What is the current coverage of critical paths vs nice-to-have paths?

**Recommended answer:** Map every test to a risk score (impact × likelihood). Prioritize coverage so that P0 critical paths have 100% automated coverage, P1 paths have 80%+, and P2 paths are covered by exploratory testing. Use production incident history as input.

### 1.3 What is the boundary between automated and exploratory testing?

- What is automated vs explored manually?
- Who does exploratory testing, and how often?
- How are exploratory findings fed back into automation?

**Recommended answer:** Automate regression-critical, repetitive, and deterministic paths. Reserve exploratory testing for new features, edge cases, and usability. Schedule structured exploratory sessions (session-based testing) at least weekly. Convert high-value exploratory findings into automated tests.

### 1.4 What non-functional testing is required?

- Performance: What are the SLAs and load profiles?
- Security: What compliance requirements apply (OWASP, PCI, HIPAA)?
- Accessibility: What standard must be met (WCAG 2.1 AA is typical)?
- Is there a need for chaos/resilience testing?

**Recommended answer:** Non-functional requirements should be defined by business needs, not assumed. At minimum: WCAG 2.1 AA for accessibility, baseline performance budgets (Lighthouse CI), and OWASP Top 10 scanning. Add load testing for high-traffic endpoints.

---

## Dimension 2: Framework & Tooling

### 2.1 Why this framework over alternatives?

- What frameworks were evaluated?
- What are the selection criteria? (speed, ecosystem, language, team skills, AI compatibility)
- Is the framework suited for the team's expertise or will it require training?

**Recommended answer:** Document a comparison matrix with weighted criteria. For modern web apps with TypeScript: Playwright is the leading choice (speed, auto-waiting, multi-browser, MCP integration). For Java teams: Selenium + JUnit 5 + AssertJ remains solid. For API testing: Playwright API fixtures or REST Assured. Avoid mixing frameworks unless justified by a clear boundary.

### 2.2 What language and why?

- Does the team have existing expertise?
- Does the language integrate well with the application stack?
- Are there type safety requirements?

**Recommended answer:** Match the test language to the team's primary language. TypeScript for JS/TS teams, Java for Java teams. Type safety is non-negotiable for maintainable test suites — use TypeScript or Java, avoid plain JavaScript or Python for large suites unless the team is Python-native.

### 2.3 What design pattern?

- Page Object Model (POM)?
- Screenplay Pattern?
- Fluent API / Builder?
- Hybrid?

**Recommended answer:** POM for small-to-medium suites (under 500 tests) — it is well-understood and widely supported. Screenplay for large, complex suites with many actors and workflows — it scales better for composition and reuse. Avoid anemic POMs (just locators, no behavior).

### 2.4 What reporting and observability tools?

- HTML reports? (Allure, Playwright HTML, ReportPortal)
- CI integration? (JUnit XML, GitHub Annotations)
- Test observability? (traces, videos, screenshots on failure)
- Real-time dashboard?

**Recommended answer:** Allure or ReportPortal for rich reporting. Playwright's built-in trace viewer for debugging. Always enable video + screenshot on failure in CI. Export JUnit XML for CI integration. Consider ReportPortal if multiple teams need a shared dashboard.

---

## Dimension 3: Test Architecture

### 3.1 How are tests isolated from each other?

- Does each test create its own data, or is there shared state?
- Are tests order-dependent?
- What happens if tests run in parallel?

**Recommended answer:** Zero shared state. Each test creates and cleans up its own data. Use `beforeEach`/`afterEach` for setup and teardown. Tests must pass in any order and in parallel. Use database transactions or API-based cleanup for data isolation.

### 3.2 What is the test data strategy?

- Hardcoded data?
- Factories / builders?
- Seeded databases?
- API-generated data?
- What is the cleanup strategy?

**Recommended answer:** API-based test data creation (fast, reliable, no UI dependency). Use factory functions for complex objects. Never hardcode data that can change (IDs, timestamps, dynamic content). Cleanup via API calls or database resets, not UI interactions.

### 3.3 How are environments managed?

- Local, staging, production — which environments are tested?
- How are environment-specific configs handled?
- Is there a stable staging environment, or does it change unpredictably?

**Recommended answer:** Use environment-specific config files (not environment variables scattered in code). Test primarily against a stable staging environment that mirrors production. Run smoke tests against production after deployment (synthetic monitoring). Never run destructive tests against shared environments.

### 3.4 What is the parallelization strategy?

- Can tests run in parallel?
- Are there shared resources that prevent parallelization?
- What is the sharding strategy for CI?

**Recommended answer:** Maximize parallelization from day one. Design tests to be independent (see 3.1). Use Playwright's default parallel workers. For CI, shard tests across multiple runners (GitHub Actions matrix). Identify and quarantine tests that cannot be parallelized.

### 3.5 What is the retry and flakiness policy?

- How many retries are acceptable?
- How are flaky tests detected, reported, and resolved?
- Is there a quarantine process?

**Recommended answer:** Zero retries in local development (expose flakiness immediately). In CI, allow 1-2 retries on non-critical paths, 0 on critical paths. Auto-detect flaky tests (tests that pass on retry). Flaky tests get a 48-hour fix window, then are quarantined with a tracking issue. Never silently suppress flakiness.

---

## Dimension 4: AI Integration

> See `references/ai-testing-interrogation.md` for the expanded question bank on this dimension.

### 4.1 Where does AI enter the testing workflow?

- Test generation? (code from specs, Gherkin, or descriptions)
- Test healing? (auto-fixing broken selectors or assertions)
- Visual regression? (AI-assisted diffing)
- Triage? (analyzing failures, grouping, root cause)
- Test selection? (impacted tests based on changes)

**Recommended answer:** Start with the lowest-risk AI integration first: triage and analysis. Then move to test generation with mandatory human review. Test healing should be opt-in and logged. Visual AI diffing is mature enough for production use. Never deploy AI-based test selection without a fallback to full suite execution.

### 4.2 How are AI-generated tests validated?

### 4.3 What is the human-in-the-loop boundary?

### 4.4 What is the cost/token budget?

**Recommended answer for all:** See `references/ai-testing-interrogation.md`.

---

## Dimension 5: CI/CD Pipeline

### 5.1 What are the test stages and quality gates?

- What runs on PR vs on merge vs on schedule?
- What gates block a merge?

**Recommended answer:** Three tiers: (1) **PR gate** — unit + integration + smoke E2E (under 5 min), blocks merge. (2) **Merge pipeline** — full regression suite + accessibility + performance baseline, runs post-merge. (3) **Nightly** — full E2E + visual regression + load tests. Gates: PR gate must pass 100%. Merge pipeline failures create issues but don't block (post-merge). Nightly failures alert the team.

### 5.2 What is the execution budget?

- How long is acceptable for each stage?
- What happens when the suite exceeds the budget?

**Recommended answer:** PR gate: 5 minutes max. Merge pipeline: 15 minutes. Nightly: 60 minutes. If the suite exceeds budget, split into shards or prioritize test selection. Never let the suite grow unchecked — budget enforcement forces prioritization.

### 5.3 What is the test selection strategy?

- Full suite every time?
- Impacted-area selection?
- AI-based selection?

**Recommended answer:** Use impact-based test selection for PRs (run only tests affected by the code change). Run full suite nightly. If using AI-based selection, maintain a 95%+ confidence threshold and always run a random 10% of non-selected tests as a safety net.

### 5.4 How are flaky tests handled in CI?

**Recommended answer:** See Dimension 3.5. In CI specifically: auto-retry once, log the retry, track flakiness rate as a metric. If flakiness rate exceeds 2%, block new test additions until the rate is brought down.

---

## Dimension 6: Quality Engineering (Non-Functional)

### 6.1 Accessibility

- What standard? (WCAG 2.1 AA, AAA, Section 508)
- Automated scanning? (axe-core, Lighthouse, Pa11y)
- Manual testing? (keyboard navigation, screen readers)
- When in the pipeline?

**Recommended answer:** WCAG 2.1 AA as the baseline. Automated axe-core scans on every PR (in Playwright or Selenium tests). Manual keyboard navigation and screen reader testing for critical flows, at least once per release. Accessibility issues are P1 bugs, not nice-to-haves.

### 6.2 Performance

- What performance budgets exist?
- Is there load testing? Stress testing?
- What tools? (k6, JMeter, Gatling, Lighthouse CI)

**Recommended answer:** Define performance budgets for key pages (LCP < 2.5s, CLS < 0.1, FID < 100ms). Run Lighthouse CI on every PR against critical pages. Load test with k6 for API endpoints — run weekly or before major releases. Alert on budget violations.

### 6.3 Visual Regression

- Pixel diff? (Percy, Chromatic, Playwright snapshots)
- DOM diff?
- AI-assisted? (Applitools, Reflect)
- What is the review workflow?

**Recommended answer:** Playwright visual comparisons for cost-effective baseline. Percy or Chromatic for managed visual regression with review workflows. AI-assisted (Applitools) for apps with dynamic content where pixel diff produces too many false positives. Review visual diffs in the PR, not after merge.

### 6.4 Cross-Browser & Device Matrix

- Which browsers? (Chrome, Firefox, Safari, Edge)
- Which devices? (Desktop, mobile, tablet)
- Real devices or emulators?

**Recommended answer:** Chrome + Firefox + Safari (desktop) and Chrome (mobile emulation) in CI. Test on real iOS Safari and Android Chrome via cloud providers (BrowserStack, Sauce Labs) for critical paths, weekly. Do not try to test every combination on every PR — use risk-based selection.

---

## Dimension 7: Maintainability & Sustainability

### 7.1 What is the dead test detection and removal strategy?

- How do you identify tests that never fail?
- How do you identify tests that test deprecated functionality?
- What is the removal process?

**Recommended answer:** Track test effectiveness metrics: tests that haven't caught a bug in 6 months are candidates for removal. Use code coverage to detect tests for removed features. Quarterly test suite audit to identify and remove dead tests. Make test removal a first-class PR, not a side task.

### 7.2 How is test code quality enforced?

- Linting rules? (ESLint, Checkstyle, SpotBugs)
- Code review standards?
- DRY thresholds?

**Recommended answer:** Apply the same linting and review standards to test code as production code. Custom ESLint/Checkstyle rules to catch common test anti-patterns (Thread.sleep, hardcoded waits, magic numbers). Require at least one review on test PRs. DRY is important but readability trumps DRY in tests — a slightly verbose test that reads clearly is better than an over-abstracted one.

### 7.3 What is the refactoring cadence?

- When do tests get refactored?
- Is there dedicated time for test maintenance?

**Recommended answer:** Refactor tests as part of feature work (boy scout rule: leave tests better than you found them). Schedule a dedicated test maintenance sprint quarterly. Track test code health metrics (duplication, complexity, flakiness) and trend them over time.

### 7.4 How are tests documented?

- Naming conventions?
- Test plan links?
- Comment standards?

**Recommended answer:** Test names should describe behavior, not implementation ("should display error when email is invalid" not "testLogin1"). Link tests to requirements/test plans via annotations or tags. Comments only for non-obvious setup or to explain why a test exists, not what it does. The test body should be self-documenting.

### 7.5 What is the onboarding path for new team members?

- How long does it take to write their first test?
- Is there documentation for the test framework setup?

**Recommended answer:** New team members should be able to write and run their first test within 30 minutes. Maintain a `TESTING.md` with setup, conventions, and examples. Pair program on the first few tests. Include test framework overview in onboarding documentation.
