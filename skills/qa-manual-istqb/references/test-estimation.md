# Test Estimation (ISTQB Foundation Level)

Test estimation predicts the effort, duration, and resources needed for testing activities. Accurate estimates are crucial for planning, budgeting, and managing stakeholder expectations.

## Why Estimation Is Difficult

- Requirements evolve during the project
- Defect counts are unpredictable
- Test environments may not be available
- Team experience varies
- External dependencies introduce uncertainty

## Estimation Factors

Consider these factors when estimating test effort:

| Factor Category | Specific Factors                                              |
| --------------- | ------------------------------------------------------------- |
| **Product**     | Size, complexity, criticality, domain, quality requirements   |
| **Process**     | Test levels, test types, coverage criteria, automation degree |
| **People**      | Team size, experience, skills, training needs                 |
| **Project**     | Schedule, budget, parallel activities, dependencies           |
| **Environment** | Tool availability, test data, infrastructure readiness        |
| **Risk**        | Technical risks, requirement stability, defect likelihood     |

## Estimation Techniques

### 1. Expert Judgment / Wideband Delphi

**How it works:**

1. Present the scope to multiple experts
2. Each expert estimates independently
3. Compare estimates and discuss differences
4. Repeat until consensus is reached

**Best for:** Early estimates, unique projects, when historical data is lacking

**Tips:**

- Use 3-5 experts with diverse perspectives
- Document assumptions behind estimates
- Track actual vs. estimated for future calibration

### 2. Historical Data / Analogous Estimation

**How it works:**

1. Find similar past projects
2. Adjust for differences (size, complexity, team)
3. Use actual effort from past as baseline

**Best for:** Projects similar to past work, organizations with good metrics

**Example:**

```
Past project: 500 test cases, 200 hours execution
New project: 750 test cases (1.5x)
Estimate: 200 × 1.5 = 300 hours
Adjust for: new technology (+20%), experienced team (-10%)
Final: 300 × 1.1 = 330 hours
```

### 3. Ratio-Based Estimation

**How it works:**

- Use industry or organizational ratios
- Apply to project parameters (LOC, function points, story points)

**Common ratios (vary by context):**

| Ratio                      | Typical Range        | Notes                           |
| -------------------------- | -------------------- | ------------------------------- |
| Test effort / Dev effort   | 20-50%               | Varies greatly by quality needs |
| Test cases / Requirements  | 3-10 per requirement | Depends on complexity           |
| Execution time / Test case | 10-30 min manual     | Highly variable                 |
| Defects found / Test hour  | 0.5-2                | Depends on quality              |

### 4. Work Breakdown Structure (WBS)

**How it works:**

1. Decompose testing into granular tasks
2. Estimate each task individually
3. Sum up all task estimates
4. Add buffer for coordination, dependencies, risks

**Test activity breakdown:**

| Activity                | Sub-activities                                                     |
| ----------------------- | ------------------------------------------------------------------ |
| **Test Planning**       | Review requirements, identify risks, write test plan, define scope |
| **Test Analysis**       | Analyze test basis, identify test conditions, review coverage      |
| **Test Design**         | Write test cases, identify test data, create traceability          |
| **Test Implementation** | Set up environment, prepare data, automate tests                   |
| **Test Execution**      | Execute tests, log results, report defects, retest fixes           |
| **Test Completion**     | Evaluate exit criteria, write summary, archive testware            |

**Example WBS estimate:**

| Task                             | Effort (hours) |
| -------------------------------- | -------------: |
| Test planning                    |             16 |
| Test analysis                    |             24 |
| Test case design (50 cases × 1h) |             50 |
| Test data preparation            |             16 |
| Environment setup                |              8 |
| Test execution (50 cases × 0.5h) |             25 |
| Defect reporting and retesting   |             20 |
| Test summary and closure         |              8 |
| **Subtotal**                     |        **167** |
| Contingency (20%)                |             33 |
| **Total**                        |        **200** |

### 5. Three-Point Estimation (PERT)

**How it works:**

1. Estimate optimistic (O), most likely (M), pessimistic (P) for each task
2. Calculate expected value: E = (O + 4M + P) / 6
3. Calculate standard deviation: σ = (P - O) / 6

**Example:**

| Task            | Optimistic | Most Likely | Pessimistic | Expected |
| --------------- | :--------: | :---------: | :---------: | :------: |
| Test design     |    30h     |     40h     |     80h     |   45h    |
| Test execution  |    15h     |     20h     |     40h     |  22.5h   |
| Defect handling |    10h     |     20h     |     50h     |  23.3h   |

### 6. Test Point Analysis (TPA)

**How it works:**

1. Identify test points from requirements (similar to function points)
2. Adjust for complexity, risk, and test type
3. Apply productivity factor (hours per test point)

**Simplified formula:**

```
Test Effort = Σ(Test Points × Complexity Factor) × Productivity
```

## Estimation Worksheet Template

```markdown
## Test Estimation - [Project/Feature Name]

### Scope

- Features in scope: [list]
- Test levels: [component, integration, system, acceptance]
- Test types: [functional, performance, security, etc.]

### Assumptions

- [ ] Requirements are stable (80%+ complete)
- [ ] Test environment available by [date]
- [ ] Team of [N] testers available
- [ ] [Other assumptions]

### Effort Breakdown

| Activity              | Hours | Notes |
| --------------------- | ----: | ----- |
| Test planning         |       |       |
| Test analysis         |       |       |
| Test design           |       |       |
| Test implementation   |       |       |
| Test execution        |       |       |
| Defect management     |       |       |
| Test closure          |       |       |
| **Subtotal**          |       |       |
| Contingency (\_\_\_%) |       |       |
| **Total**             |       |       |

### Duration

- Start date:
- End date:
- Calendar days:
- Working days:
- Parallel with development: [yes/no]

### Risks to Estimate

| Risk | Impact on Estimate | Mitigation |
| ---- | ------------------ | ---------- |
|      |                    |            |
```

## Contingency Guidelines

| Project Characteristic            | Suggested Contingency |
| --------------------------------- | --------------------- |
| Well-defined, stable requirements | 10-15%                |
| Moderately defined requirements   | 15-25%                |
| Unclear or evolving requirements  | 25-40%                |
| New technology or domain          | 30-50%                |
| Critical/regulated systems        | 20-30% additional     |

## Tracking and Refining Estimates

1. **Track actuals**: Record actual effort for each activity
2. **Compare regularly**: Earned Value, Burn-down charts
3. **Re-estimate**: Update estimates as scope clarifies
4. **Post-mortem**: Analyze variance and improve future estimates

**Tracking metrics:**

| Metric            | Formula                                       | Target                |
| ----------------- | --------------------------------------------- | --------------------- |
| Estimate accuracy | (Actual - Estimated) / Estimated × 100%       | ±10-15%               |
| Schedule variance | (Planned End - Actual End) / Planned Duration | Minimal               |
| Scope creep       | Added scope / Original scope                  | Tracked and accounted |

## Common Estimation Mistakes

| Mistake                         | Impact                 | Prevention                         |
| ------------------------------- | ---------------------- | ---------------------------------- |
| Underestimating defect handling | 20-40% effort missed   | Add explicit defect buffer         |
| Ignoring environment issues     | Delays and rework      | Estimate setup and troubleshooting |
| Assuming ideal productivity     | Overruns               | Use realistic productivity factors |
| Not accounting for meetings     | Lost time              | Add 10-15% for coordination        |
| Forgetting regression testing   | Late surprises         | Include in every iteration         |
| Skipping contingency            | No buffer for unknowns | Always add contingency             |
