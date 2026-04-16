# ISTQB Glossary (Foundation Level - Key Terms)

Essential terminology from the ISTQB Foundation Level syllabus, organized by topic.

## Testing Fundamentals

| Term                       | Definition                                                                  |
| -------------------------- | --------------------------------------------------------------------------- |
| **Testing**                | Process of evaluating a software product to find defects and assess quality |
| **Quality**                | Degree to which a component/system meets requirements and user expectations |
| **Quality Assurance (QA)** | Process-focused activities to ensure quality is built in                    |
| **Quality Control (QC)**   | Product-focused activities to verify quality (including testing)            |
| **Defect (Bug/Fault)**     | A flaw in the software that may cause incorrect behavior                    |
| **Failure**                | Incorrect output or behavior observed during execution                      |
| **Error (Mistake)**        | Human action that produces an incorrect result                              |
| **Root Cause**             | Fundamental reason for the occurrence of a defect                           |

### Error → Defect → Failure Chain

```
Developer makes ERROR → ERROR causes DEFECT in code → DEFECT triggers FAILURE when executed
```

## Test Process

| Term               | Definition                                                               |
| ------------------ | ------------------------------------------------------------------------ |
| **Test basis**     | Source of information for test analysis (requirements, stories, designs) |
| **Test condition** | Testable aspect derived from the test basis (what to test)               |
| **Test case**      | Set of preconditions, inputs, actions, and expected results              |
| **Test procedure** | Sequence of actions for executing a test (how to execute)                |
| **Test script**    | Automated test procedure                                                 |
| **Test suite**     | Set of test cases to be executed together                                |
| **Test run**       | Execution of a test suite on a specific build/environment                |
| **Testware**       | All artifacts produced during testing (plans, cases, data, scripts)      |

## Test Oracles

| Term                | Definition                                         |
| ------------------- | -------------------------------------------------- |
| **Test oracle**     | Source to determine expected results               |
| **Expected result** | Predicted behavior/output defined before execution |
| **Actual result**   | Observed behavior/output after execution           |

**Oracle sources:** Requirements, specifications, comparable systems, user expectations, heuristics

## Test Levels

| Term                                 | Definition                                          |
| ------------------------------------ | --------------------------------------------------- |
| **Component testing (Unit testing)** | Testing individual units in isolation               |
| **Integration testing**              | Testing interactions between integrated components  |
| **System testing**                   | Testing the complete integrated system              |
| **Acceptance testing**               | Testing to determine if system meets business needs |

## Test Types

| Term                                  | Definition                                                     |
| ------------------------------------- | -------------------------------------------------------------- |
| **Functional testing**                | Testing what the system does (behavior)                        |
| **Non-functional testing**            | Testing how well the system performs (quality characteristics) |
| **White-box testing**                 | Testing based on internal structure (code)                     |
| **Black-box testing**                 | Testing based on specifications (inputs/outputs)               |
| **Confirmation testing (Re-testing)** | Testing to verify a specific defect was fixed                  |
| **Regression testing**                | Testing to detect unintended side effects of changes           |

## Test Design Techniques

| Term                         | Definition                                                     |
| ---------------------------- | -------------------------------------------------------------- |
| **Equivalence partitioning** | Dividing inputs into groups expected to behave the same        |
| **Boundary value analysis**  | Testing at the edges of equivalence partitions                 |
| **Decision table testing**   | Testing combinations of conditions and their resulting actions |
| **State transition testing** | Testing based on states and transitions between them           |
| **Use case testing**         | Testing based on user scenarios and flows                      |
| **Error guessing**           | Using experience to predict where defects might occur          |
| **Exploratory testing**      | Simultaneous test design, execution, and learning              |

## Coverage

| Term                      | Definition                                              |
| ------------------------- | ------------------------------------------------------- |
| **Test coverage**         | Degree to which test basis items are exercised by tests |
| **Requirements coverage** | % of requirements with associated tests                 |
| **Code coverage**         | % of code executed by tests                             |
| **Statement coverage**    | % of executable statements exercised                    |
| **Branch coverage**       | % of branches (decisions) exercised                     |

## Test Management

| Term                | Definition                                                   |
| ------------------- | ------------------------------------------------------------ |
| **Test plan**       | Document describing scope, approach, resources, and schedule |
| **Test strategy**   | High-level description of test levels and approach           |
| **Entry criteria**  | Conditions required to start a test activity                 |
| **Exit criteria**   | Conditions required to stop a test activity                  |
| **Test monitoring** | Tracking test progress against the plan                      |
| **Test control**    | Taking corrective actions based on monitoring                |

## Defect Management

| Term                           | Definition                                                       |
| ------------------------------ | ---------------------------------------------------------------- |
| **Defect report (Bug report)** | Document describing a defect with reproduction steps             |
| **Severity**                   | Impact of the defect on the system/user                          |
| **Priority**                   | Urgency of fixing the defect                                     |
| **Defect lifecycle**           | States a defect passes through (New → Fixed → Verified → Closed) |
| **Triage**                     | Process of evaluating and prioritizing defects                   |

### Severity vs Priority

| Aspect  | Severity                    | Priority                          |
| ------- | --------------------------- | --------------------------------- |
| Focus   | Technical impact            | Business urgency                  |
| Set by  | Tester                      | Product owner/manager             |
| Example | "Crash" = Critical severity | "Fix before launch" = P0 priority |

**Example combinations:**

- High severity, high priority: System crashes on login
- High severity, low priority: Crash on rarely-used admin page
- Low severity, high priority: Typo in company name on homepage
- Low severity, low priority: Minor UI alignment issue

## Risk

| Term                   | Definition                                  |
| ---------------------- | ------------------------------------------- |
| **Risk**               | Possibility of a negative outcome           |
| **Product risk**       | Risk affecting software quality             |
| **Project risk**       | Risk affecting the testing project          |
| **Risk level**         | Likelihood x Impact                         |
| **Risk-based testing** | Prioritizing testing based on risk          |
| **Mitigation**         | Actions to reduce risk likelihood or impact |

## Static Testing

| Term                | Definition                                                |
| ------------------- | --------------------------------------------------------- |
| **Static testing**  | Testing without executing code (reviews, static analysis) |
| **Dynamic testing** | Testing by executing code                                 |
| **Review**          | Manual examination of a work product                      |
| **Inspection**      | Formal, systematic review with defined roles              |
| **Walkthrough**     | Author-led presentation and discussion                    |
| **Static analysis** | Tool-based examination of code without execution          |

## Test Automation

| Term                       | Definition                                          |
| -------------------------- | --------------------------------------------------- |
| **Test automation**        | Using tools to control test execution               |
| **Test framework**         | Architecture/library for writing automated tests    |
| **Test harness**           | Software/tools to execute tests and capture results |
| **Keyword-driven testing** | Tests written using keywords mapped to actions      |
| **Data-driven testing**    | Tests that iterate over data sets                   |

## Independence

| Term                       | Definition                                                            |
| -------------------------- | --------------------------------------------------------------------- |
| **Independent testing**    | Testing by people not involved in development                         |
| **Levels of independence** | Same developer < Different developer < Different team < External team |

## Psychological Aspects

| Term                  | Definition                                                    |
| --------------------- | ------------------------------------------------------------- |
| **Confirmation bias** | Tendency to interpret information to confirm existing beliefs |
| **Author bias**       | Difficulty finding defects in one's own work                  |

## Common Abbreviations

| Abbreviation | Full Term                                           |
| ------------ | --------------------------------------------------- |
| ISTQB        | International Software Testing Qualifications Board |
| CTFL         | Certified Tester Foundation Level                   |
| UAT          | User Acceptance Testing                             |
| SUT          | System Under Test                                   |
| TC           | Test Case                                           |
| EP           | Equivalence Partitioning                            |
| BVA          | Boundary Value Analysis                             |
| MTTR         | Mean Time To Repair                                 |
| CI/CD        | Continuous Integration / Continuous Delivery        |
