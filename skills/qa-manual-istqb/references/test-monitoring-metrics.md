# Test Monitoring and Metrics (ISTQB Foundation Level)

Test monitoring tracks progress against the test plan and provides visibility to stakeholders. Metrics quantify quality and progress to support decision-making.

## Test Monitoring vs Test Control

| Aspect         | Monitoring                        | Control                                |
| -------------- | --------------------------------- | -------------------------------------- |
| **Focus**      | Observing and measuring           | Taking corrective action               |
| **Activities** | Collecting data, reporting status | Adjusting scope, resources, priorities |
| **Output**     | Dashboards, reports, metrics      | Decisions, plan updates                |

## Key Monitoring Activities

1. **Compare progress to plan**: Executed vs. planned tests
2. **Analyze results**: Pass/fail rates, defect trends
3. **Assess coverage**: Requirements, risks, code coverage
4. **Evaluate exit criteria**: Are we ready to stop testing?
5. **Report status**: Communicate to stakeholders
6. **Identify blockers**: Escalate issues early

## Test Metrics Categories

### 1. Progress Metrics

Track how testing is advancing through the plan.

| Metric                   | Formula                   | Purpose                     |
| ------------------------ | ------------------------- | --------------------------- |
| Test case execution rate | Executed / Planned × 100% | Track completion            |
| Test case pass rate      | Passed / Executed × 100%  | Assess quality              |
| Test case failure rate   | Failed / Executed × 100%  | Identify problem areas      |
| Blocked test rate        | Blocked / Planned × 100%  | Identify impediments        |
| Test automation rate     | Automated / Total × 100%  | Track automation investment |

**Example progress table:**

| Status    |   Count | % of Total |
| --------- | ------: | ---------: |
| Passed    |     120 |        60% |
| Failed    |      30 |        15% |
| Blocked   |      10 |         5% |
| Not Run   |      40 |        20% |
| **Total** | **200** |   **100%** |

### 2. Defect Metrics

Track bugs found, fixed, and remaining.

| Metric                     | Formula                            | Purpose                          |
| -------------------------- | ---------------------------------- | -------------------------------- |
| Defects found              | Count by severity/priority         | Volume and severity distribution |
| Defects fixed              | Closed / Found × 100%              | Fix rate                         |
| Defects open               | Found - Closed                     | Outstanding issues               |
| Defect density             | Defects / Size (KLOC, FP, etc.)    | Code quality indicator           |
| Defect detection rate      | Found before release / Total found | Testing effectiveness            |
| Defect leakage             | Found in production / Total found  | Escaped defects                  |
| Mean time to repair (MTTR) | Avg time from reported to fixed    | Fix efficiency                   |

**Defect trend chart data:**

| Week | Found | Fixed | Open |
| ---- | ----: | ----: | ---: |
| 1    |    15 |     5 |   10 |
| 2    |    20 |    18 |   12 |
| 3    |    12 |    15 |    9 |
| 4    |     5 |    10 |    4 |

**Look for:** Convergence (found rate decreasing, open count decreasing)

### 3. Coverage Metrics

Measure how much of the system has been tested.

| Metric                    | Formula                                        | Purpose                |
| ------------------------- | ---------------------------------------------- | ---------------------- |
| Requirements coverage     | Requirements with tests / Total requirements   | Completeness           |
| Risk coverage             | High-risk items tested / Total high-risk items | Risk mitigation        |
| Code coverage (statement) | Statements executed / Total statements         | White-box completeness |
| Code coverage (branch)    | Branches executed / Total branches             | Decision path coverage |

### 4. Quality Metrics

Assess the quality of the software under test.

| Metric                       | Interpretation                            |
| ---------------------------- | ----------------------------------------- |
| Pass rate trend              | Improving = quality stabilizing           |
| Defect severity distribution | Many criticals = high risk                |
| Defect age                   | Old defects = potential blockers          |
| Reopen rate                  | High = poor fixes or unclear requirements |
| Regression defects           | Indicates side effects from changes       |

### 5. Test Efficiency Metrics

Measure the effectiveness of the testing effort.

| Metric                      | Formula                               | Purpose                  |
| --------------------------- | ------------------------------------- | ------------------------ |
| Defects per test hour       | Defects found / Test hours            | Testing productivity     |
| Test execution productivity | Tests executed / Tester days          | Throughput               |
| Automation ROI              | (Manual time saved - Automation cost) | Investment justification |
| Flaky test rate             | Flaky tests / Automated tests         | Automation quality       |

## Exit Criteria Evaluation

Use metrics to evaluate readiness to stop testing.

**Sample exit criteria checklist:**

| Criterion                      | Target | Actual | Status |
| ------------------------------ | ------ | ------ | ------ |
| Test cases executed            | 100%   | 95%    | ⚠️     |
| Test cases passed              | ≥95%   | 92%    | ❌     |
| Critical defects open          | 0      | 0      | ✅     |
| Major defects open             | ≤3     | 2      | ✅     |
| High-risk requirements covered | 100%   | 100%   | ✅     |
| Regression suite passed        | 100%   | 100%   | ✅     |

**Decision:** Not ready—address remaining test cases and failed tests.

## Test Reporting

### Daily/Stand-up Report

Quick status for the team:

- Tests executed yesterday
- Tests planned today
- Defects found/fixed
- Blockers

### Weekly/Iteration Report

| Section              | Content                                     |
| -------------------- | ------------------------------------------- |
| Executive summary    | Overall status (on track, at risk, blocked) |
| Progress             | Execution rates, burn-down chart            |
| Quality              | Pass rate, defect trends, coverage          |
| Risks and issues     | Blockers, escalations, mitigations          |
| Plan for next period | Priorities, focus areas                     |

### Test Summary Report (End of Cycle)

Comprehensive closure report:

- Scope tested vs. planned
- Results by test level/type
- Defect summary with severity distribution
- Exit criteria status
- Residual risks and recommendations
- Go/no-go recommendation

## Dashboard Elements

Effective test dashboards include:

| Widget                  | Type        | Purpose                     |
| ----------------------- | ----------- | --------------------------- |
| Test progress pie/bar   | Chart       | Quick status overview       |
| Test execution trend    | Line chart  | Progress over time          |
| Defect trend            | Line chart  | Found vs. fixed convergence |
| Defect by severity      | Bar chart   | Quality risk                |
| Coverage heat map       | Table/chart | Gap identification          |
| Blockers list           | List        | Action items                |
| Exit criteria checklist | Table       | Go/no-go readiness          |

## Common Monitoring Pitfalls

| Pitfall            | Problem                                 | Solution                         |
| ------------------ | --------------------------------------- | -------------------------------- |
| Vanity metrics     | Numbers that look good but don't inform | Focus on actionable metrics      |
| Measuring too much | Overhead without value                  | Select 5-10 key metrics          |
| Gaming metrics     | Behavior to hit numbers, not quality    | Balance metrics, inspect quality |
| Stale data         | Decisions on old information            | Automate data collection         |
| No baseline        | Can't tell if improving                 | Establish baselines early        |
| Ignoring trends    | Missing patterns                        | Chart data over time             |

## Metrics-Driven Actions

| Observation               | Possible Actions                                   |
| ------------------------- | -------------------------------------------------- |
| Pass rate dropping        | Investigate new defects, code quality, environment |
| Many blocked tests        | Escalate environment issues, reprioritize          |
| High critical defects     | Focus testing on affected areas, delay release     |
| Low requirements coverage | Add test cases, reassess risk                      |
| Defects not converging    | Extend testing, improve fix quality                |
| Flaky tests increasing    | Invest in test maintenance, fix locators           |
