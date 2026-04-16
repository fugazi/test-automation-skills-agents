# Test Levels and Test Types (ISTQB Foundation Level)

Understanding test levels and test types is fundamental to ISTQB. They define **when** and **what** we test.

## Test Levels

Test levels are groups of test activities organized by the development stage. Each level has specific objectives, test basis, and typically different testers.

### 1. Component Testing (Unit Testing)

| Aspect                | Description                                                          |
| --------------------- | -------------------------------------------------------------------- |
| **Focus**             | Individual units (functions, classes, modules) in isolation          |
| **Test basis**        | Code, detailed design, data model                                    |
| **Typically done by** | Developers                                                           |
| **Environment**       | Development environment with mocks/stubs                             |
| **Objectives**        | Verify each unit works correctly; reduce risk of defects propagating |

**What to test:**

- Function/method behavior with various inputs
- Edge cases and boundary conditions
- Error handling and exceptions
- Data structures and algorithms

### 2. Integration Testing

| Aspect                | Description                                                 |
| --------------------- | ----------------------------------------------------------- |
| **Focus**             | Interactions between integrated components or systems       |
| **Test basis**        | Architecture, workflows, use cases, API contracts           |
| **Typically done by** | Developers or testers                                       |
| **Environment**       | Integration environment with real or simulated dependencies |
| **Objectives**        | Find defects in interfaces and interactions                 |

**Integration approaches:**

| Approach        | Description                                | When to Use                    |
| --------------- | ------------------------------------------ | ------------------------------ |
| **Big-bang**    | All components integrated at once          | Small systems, tight deadlines |
| **Top-down**    | Start from top-level, stub lower levels    | UI-first development           |
| **Bottom-up**   | Start from lowest level, driver for higher | Foundation-first development   |
| **Incremental** | Integrate one component at a time          | Most common, lower risk        |

**What to test:**

- Data flow between components
- API contracts and protocols
- Error propagation and handling
- Timing and sequencing issues

### 3. System Testing

| Aspect                | Description                                         |
| --------------------- | --------------------------------------------------- |
| **Focus**             | Complete, integrated system as a whole              |
| **Test basis**        | Requirements, use cases, risk analysis, regulations |
| **Typically done by** | Independent test team                               |
| **Environment**       | Production-like environment                         |
| **Objectives**        | Validate system meets specified requirements        |

**What to test:**

- End-to-end functional flows
- Non-functional characteristics (performance, security, usability)
- Data handling and integrity
- Recovery and failover scenarios
- Installation and configuration

### 4. Acceptance Testing

| Aspect                | Description                                               |
| --------------------- | --------------------------------------------------------- |
| **Focus**             | System readiness for deployment and use                   |
| **Test basis**        | Business requirements, user needs, contracts, regulations |
| **Typically done by** | Users, customers, or their representatives                |
| **Environment**       | Production or production-equivalent                       |
| **Objectives**        | Build confidence that system is fit for purpose           |

**Types of acceptance testing:**

| Type                                     | Purpose                                  | Who                                 |
| ---------------------------------------- | ---------------------------------------- | ----------------------------------- |
| **User Acceptance Testing (UAT)**        | Validate system meets user needs         | End users, business representatives |
| **Operational Acceptance Testing (OAT)** | Verify operations can support the system | Operations/IT staff                 |
| **Contractual Acceptance**               | Verify contract requirements are met     | Customer per contract               |
| **Regulatory Acceptance**                | Verify compliance with regulations       | Regulatory bodies or auditors       |
| **Alpha Testing**                        | Internal testing before external release | Internal users                      |
| **Beta Testing**                         | External testing before general release  | Selected external users             |

## Test Types

Test types focus on **what quality characteristic** is being tested, regardless of test level.

### 1. Functional Testing

**Focus:** What the system does (behavior, features, functions)

| Technique           | Description                                        |
| ------------------- | -------------------------------------------------- |
| Specification-based | Derive tests from requirements, stories, use cases |
| Black-box           | Test without knowledge of internal structure       |
| Covers              | Business rules, data processing, user interactions |

**What to test:**

- Feature functionality per requirements
- User workflows and scenarios
- Data validation and processing
- Error handling and messages
- Integration with external systems

### 2. Non-Functional Testing

**Focus:** How well the system performs its functions (quality characteristics)

| Quality Characteristic | Description                            | Example Tests                               |
| ---------------------- | -------------------------------------- | ------------------------------------------- |
| **Performance**        | Speed, throughput, resource usage      | Load tests, stress tests, endurance tests   |
| **Security**           | Protection against threats             | Penetration testing, vulnerability scanning |
| **Usability**          | Ease of use, user experience           | User testing, heuristic evaluation          |
| **Reliability**        | Consistency, fault tolerance           | Failover tests, recovery tests              |
| **Portability**        | Adaptability across environments       | Cross-browser, cross-platform tests         |
| **Maintainability**    | Ease of modification                   | Code reviews, static analysis               |
| **Compatibility**      | Coexistence with other systems         | Integration tests, data migration           |
| **Accessibility**      | Usability for people with disabilities | WCAG compliance testing                     |

**ISO 25010 Quality Model:**

```
                    Quality Characteristics
                            |
    +-----------------------+------------------------+
    |           |           |           |            |
Functional  Performance  Compatibility  Usability  Reliability
 Suitability  Efficiency
    |           |           |           |            |
Security   Maintainability  Portability
```

### 3. White-Box Testing (Structure-Based)

**Focus:** Internal structure of the system (code, architecture)

| Technique          | Description                            |
| ------------------ | -------------------------------------- |
| Statement coverage | Every statement executed at least once |
| Branch coverage    | Every branch (true/false) executed     |
| Path coverage      | Every possible path through code       |
| Data flow testing  | Follow data through the code           |

**Typically applied at:**

- Component testing (code coverage)
- Integration testing (API/component interaction)

### 4. Change-Related Testing

**Focus:** Verify changes haven't broken existing functionality

| Type                                  | Purpose                        | Scope                             |
| ------------------------------------- | ------------------------------ | --------------------------------- |
| **Confirmation testing (re-testing)** | Verify defect fix works        | Specific to the fix               |
| **Regression testing**                | Detect unintended side effects | Broader area potentially affected |

**Regression testing strategies:**

- Run all tests (if fast enough)
- Run risk-based subset
- Run tests related to changed code (impact analysis)
- Run smoke/sanity before full regression

## Mapping Test Levels to Test Types

| Test Type      | Component | Integration | System | Acceptance |
| -------------- | :-------: | :---------: | :----: | :--------: |
| Functional     |     ✓     |      ✓      |   ✓    |     ✓      |
| Non-functional | Sometimes |  Sometimes  |   ✓    |     ✓      |
| White-box      |     ✓     |      ✓      | Rarely |     —      |
| Change-related |     ✓     |      ✓      |   ✓    |     ✓      |

## Selecting Test Levels and Types

Consider these factors:

1. **Risk**: Higher risk → more levels and types
2. **Regulations**: Compliance may mandate specific testing
3. **Time/budget**: Constraints may limit coverage
4. **Architecture**: Complex integrations need more integration testing
5. **User expectations**: User-facing apps need more acceptance/usability testing

## Entry and Exit Criteria by Level

| Level       | Example Entry Criteria                     | Example Exit Criteria                       |
| ----------- | ------------------------------------------ | ------------------------------------------- |
| Component   | Code compiles, unit test framework ready   | X% statement coverage, all tests pass       |
| Integration | Components deployed, interfaces documented | Integration tests pass, no critical defects |
| System      | System deployed, test data ready           | Functional tests pass, NFR targets met      |
| Acceptance  | UAT environment ready, users trained       | UAT sign-off, go-live decision made         |
