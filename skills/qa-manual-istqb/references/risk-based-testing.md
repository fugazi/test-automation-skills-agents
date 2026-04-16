# Risk-Based Testing (ISTQB Foundation Level)

Risk-based testing (RBT) prioritizes test effort based on the likelihood and impact of failures. It ensures the most important areas receive the most attention, optimizing limited testing resources.

## What Is Risk in Testing?

**Risk = Likelihood × Impact**

| Term           | Definition                                                     |
| -------------- | -------------------------------------------------------------- |
| **Risk**       | The possibility of a negative outcome                          |
| **Likelihood** | Probability that the failure will occur                        |
| **Impact**     | Consequence/severity if the failure occurs                     |
| **Risk level** | Combination of likelihood and impact (e.g., High, Medium, Low) |

## Types of Risk

### Product Risks (Quality Risks)

Risks related to the software product itself:

| Risk Category     | Examples                                                       |
| ----------------- | -------------------------------------------------------------- |
| **Functional**    | Incorrect calculations, missing features, wrong business logic |
| **Performance**   | Slow response, poor scalability, resource exhaustion           |
| **Security**      | Data breaches, unauthorized access, vulnerabilities            |
| **Usability**     | Confusing UI, poor accessibility, user errors                  |
| **Reliability**   | Crashes, data loss, unavailability                             |
| **Compatibility** | Browser issues, device problems, integration failures          |
| **Data**          | Corruption, migration errors, incorrect processing             |

### Project Risks

Risks affecting the testing process:

| Risk Category    | Examples                                       |
| ---------------- | ---------------------------------------------- |
| **Schedule**     | Delays, compressed timelines, late deliveries  |
| **Resources**    | Understaffing, skill gaps, turnover            |
| **Environment**  | Test environment unavailable, data not ready   |
| **Requirements** | Incomplete, changing, ambiguous specifications |
| **Tools**        | License issues, learning curves, tool failures |
| **Dependencies** | Third-party delays, integration blockers       |

## Risk-Based Testing Process

### Step 1: Risk Identification

**Sources of risk information:**

- Requirements and specifications
- Architecture and design documents
- Previous defect data
- Production incident history
- Stakeholder interviews
- Expert judgment
- Complexity analysis

**Questions to ask:**

- What could go wrong?
- What are the critical user journeys?
- What has failed before?
- What is complex or new?
- What integrates with external systems?
- What has regulatory/compliance implications?
- What would cause the most business damage?

### Step 2: Risk Assessment

Rate each risk on likelihood and impact.

**Likelihood factors:**

- Complexity of the feature
- Technology newness
- Developer experience
- Frequency of changes
- Historical defect rate
- Quality of requirements

**Impact factors:**

- Number of users affected
- Business criticality
- Revenue impact
- Safety implications
- Regulatory consequences
- Reputational damage

**Risk assessment matrix:**

|                       | Low Impact | Medium Impact | High Impact |
| --------------------- | :--------: | :-----------: | :---------: |
| **High Likelihood**   |   Medium   |     High      |  Critical   |
| **Medium Likelihood** |    Low     |    Medium     |    High     |
| **Low Likelihood**    |    Low     |      Low      |   Medium    |

### Step 3: Risk Prioritization

Order risks by risk level, then by:

- Business priority
- Dependencies
- Time sensitivity
- Stakeholder input

**Prioritized risk list template:**

| ID  | Risk Description             | Likelihood | Impact | Risk Level | Priority |
| --- | ---------------------------- | :--------: | :----: | :--------: | :------: |
| R1  | Payment processing fails     |    High    |  High  |  Critical  |    1     |
| R2  | Search returns wrong results |   Medium   |  High  |    High    |    2     |
| R3  | Login performance slow       |   Medium   | Medium |   Medium   |    3     |
| R4  | Help text has typos          |    Low     |  Low   |    Low     |    10    |

### Step 4: Risk Mitigation through Testing

Map risks to test activities:

| Risk Level   | Testing Approach                                                  |
| ------------ | ----------------------------------------------------------------- |
| **Critical** | Extensive testing, multiple techniques, early testing, automation |
| **High**     | Thorough testing, combinatorial techniques, regression coverage   |
| **Medium**   | Standard testing, risk-focused test cases                         |
| **Low**      | Basic testing, exploratory, or defer                              |

**Risk-to-test traceability:**

| Risk ID | Risk              | Test Cases       | Test Type               | Automation |
| ------- | ----------------- | ---------------- | ----------------------- | ---------- |
| R1      | Payment fails     | TC-101 to TC-115 | Functional, Integration | Yes        |
| R2      | Search results    | TC-201 to TC-210 | Functional              | Yes        |
| R3      | Login performance | TC-301 to TC-305 | Performance             | Yes        |

### Step 5: Risk Monitoring

Continuously update risk assessment:

- New risks identified → add to register
- Defects found → indicates likelihood was correct
- Risk mitigated → reduce priority
- Scope changes → reassess risks

## Risk Assessment Template

```markdown
# Risk Assessment - [Project/Feature]

## Risk Register

| ID  | Risk Description | Category | Likelihood (1-5) | Impact (1-5) | Risk Score | Priority | Mitigation |
| --- | ---------------- | -------- | :--------------: | :----------: | :--------: | :------: | ---------- |
| R1  |                  |          |                  |              |            |          |            |
| R2  |                  |          |                  |              |            |          |            |

## Risk Scoring Guide

### Likelihood

- 1: Very unlikely (rare, <10%)
- 2: Unlikely (occasional, 10-25%)
- 3: Possible (moderate, 25-50%)
- 4: Likely (frequent, 50-75%)
- 5: Very likely (almost certain, >75%)

### Impact

- 1: Trivial (cosmetic, workaround exists)
- 2: Minor (limited users, easy workaround)
- 3: Moderate (many users affected, workaround difficult)
- 4: Major (critical flow blocked, significant revenue impact)
- 5: Critical (system down, data loss, safety/legal implications)

### Risk Score

- Risk Score = Likelihood × Impact
- 1-5: Low | 6-12: Medium | 13-19: High | 20-25: Critical
```

## Applying RBT to Test Planning

### Test Case Prioritization

Order test execution by risk:

1. Critical risk areas first
2. High risk areas second
3. Medium risk areas third
4. Low risk areas last (or skip under time pressure)

### Test Suite Tiers

| Tier       | Risk Coverage            | When to Run    |
| ---------- | ------------------------ | -------------- |
| Smoke      | Critical only            | Every build    |
| Sanity     | Critical + High          | After changes  |
| Regression | Critical + High + Medium | Before release |
| Full       | All risks                | Major releases |

### Time-Constrained Testing

When time is limited:

1. Run all critical risk tests
2. Run high risk tests
3. Sample medium risk tests
4. Skip or defer low risk tests
5. Document what was not tested and residual risk

## Risk-Based Test Reporting

Include in test summary:

| Risk Level | Risks Identified | Tests Planned | Tests Executed | Tests Passed | Defects Found |
| ---------- | :--------------: | :-----------: | :------------: | :----------: | :-----------: |
| Critical   |        3         |      45       |       45       |      43      |       5       |
| High       |        8         |      80       |       78       |      72      |       8       |
| Medium     |        15        |      60       |       55       |      52      |       4       |
| Low        |        10        |      20       |       10       |      10      |       0       |

**Residual risk statement:**

- Untested areas: [list]
- Known open defects: [list with impact]
- Risks accepted: [list with justification]
- Recommendations: [actions for remaining risk]

## Benefits of Risk-Based Testing

| Benefit          | Description                         |
| ---------------- | ----------------------------------- |
| Focus            | Test the right things first         |
| Efficiency       | Optimize limited resources          |
| Communication    | Clear rationale for stakeholders    |
| Decision support | Informed go/no-go decisions         |
| Quality          | Higher confidence in critical areas |
| Adaptability     | Adjust as risks change              |

## Common Pitfalls

| Pitfall                              | Impact                       | Prevention                     |
| ------------------------------------ | ---------------------------- | ------------------------------ |
| Testing everything equally           | Critical areas under-tested  | Prioritize by risk             |
| Ignoring low-probability/high-impact | Catastrophic failures missed | Don't skip high impact         |
| Static risk assessment               | Outdated priorities          | Review risks regularly         |
| Not documenting risks                | Lost rationale               | Maintain risk register         |
| Risk assessment once                 | Missing new risks            | Continuous risk identification |
