# Experience-Based Test Techniques (ISTQB Foundation Level)

Experience-based techniques leverage the tester's knowledge, intuition, and skills to design and execute tests. They complement specification-based techniques and are particularly valuable when documentation is incomplete or time is limited.

## Overview of Experience-Based Techniques

| Technique           | Best For                                 | Key Benefit                                   |
| ------------------- | ---------------------------------------- | --------------------------------------------- |
| Error Guessing      | Finding defects based on experience      | Quick identification of likely failure points |
| Checklist-Based     | Consistent coverage of known areas       | Structured approach with flexibility          |
| Exploratory Testing | Learning while testing; incomplete specs | Adaptive, creative defect discovery           |

## 1. Error Guessing

### What It Is

Error guessing uses the tester's experience to anticipate where defects are likely to occur. Testers "guess" potential errors based on:

- Past defects in similar systems
- Common programming mistakes
- Known problematic areas
- Intuition from domain knowledge

### Common Error Categories to Guess

| Category                | Examples                                                            |
| ----------------------- | ------------------------------------------------------------------- |
| **Input handling**      | Empty inputs, special characters, SQL injection, XSS                |
| **Boundary conditions** | Off-by-one errors, max length exceeded, zero values                 |
| **State management**    | Invalid state transitions, race conditions, session expiry          |
| **Integration points**  | API failures, timeout handling, data format mismatches              |
| **Error handling**      | Missing error messages, incorrect error codes, unhandled exceptions |
| **Concurrency**         | Simultaneous updates, deadlocks, data corruption                    |
| **Configuration**       | Default values, environment differences, feature flags              |
| **Edge cases**          | First/last item, empty collections, null values                     |

### Error Guessing Checklist

- [ ] What happens with empty/null input?
- [ ] What happens with very long input?
- [ ] What happens with special characters?
- [ ] What happens at boundary values?
- [ ] What happens with invalid data types?
- [ ] What happens during network failure?
- [ ] What happens with concurrent users?
- [ ] What happens after session timeout?
- [ ] What happens on browser back/refresh?
- [ ] What happens with different user roles?

### Building an Error Catalog

Maintain a catalog of common errors organized by:

1. **Application area** (login, checkout, search)
2. **Error type** (validation, integration, performance)
3. **Historical defects** (escaped bugs, production incidents)

## 2. Checklist-Based Testing

### What It Is

Checklist-based testing uses predefined lists of conditions or quality attributes to guide test design and execution. Unlike scripted test cases, checklists provide guidance while allowing tester judgment.

### Types of Checklists

| Checklist Type             | Purpose                   | Example Items                    |
| -------------------------- | ------------------------- | -------------------------------- |
| **Functional**             | Feature-specific coverage | Login flows, CRUD operations     |
| **Quality characteristic** | Non-functional aspects    | Performance, security, usability |
| **Platform/device**        | Cross-platform coverage   | Browsers, OS versions, devices   |
| **Regulatory**             | Compliance requirements   | WCAG, GDPR, HIPAA                |
| **User journey**           | End-to-end flows          | Purchase, onboarding, support    |

### Sample Functional Checklist: User Authentication

- [ ] Successful login with valid credentials
- [ ] Failed login with invalid password
- [ ] Failed login with invalid username
- [ ] Account lockout after failed attempts
- [ ] Password reset flow
- [ ] Remember me functionality
- [ ] Session timeout behavior
- [ ] Logout clears session
- [ ] Login from multiple devices
- [ ] OAuth/SSO integration (if applicable)

### Sample Quality Checklist: Usability

- [ ] Clear and informative error messages
- [ ] Consistent navigation and layout
- [ ] Keyboard accessibility
- [ ] Form field labels and placeholders
- [ ] Loading indicators for async operations
- [ ] Confirmation for destructive actions
- [ ] Responsive design on mobile
- [ ] Help text and tooltips where needed

### Sample Cross-Browser Checklist

- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest, macOS/iOS)
- [ ] Edge (latest)
- [ ] Mobile Chrome (Android)
- [ ] Mobile Safari (iOS)

### Building Effective Checklists

1. **Start from standards**: ISO 25010, WCAG, security best practices
2. **Add project-specific items**: Business rules, integrations
3. **Incorporate lessons learned**: Past defects, production issues
4. **Keep them concise**: 10-20 items per checklist
5. **Review and update regularly**: Remove obsolete items, add new ones

## 3. Exploratory Testing

### What It Is

Exploratory testing is a **simultaneous learning, test design, and test execution** approach. The tester explores the application, designs tests on the fly, and executes them immediately based on observations.

### Key Principles

- **Concurrent activities**: Learn → Design → Execute → Evaluate (in loops)
- **Tester autonomy**: Tester makes decisions about what to test next
- **Time-boxed sessions**: Focused effort with clear start/end (30-90 min)
- **Documented findings**: Notes, defects, and follow-up questions

### Session-Based Test Management (SBTM)

Structure exploratory testing with **charters** and **sessions**:

| Element           | Description                                        |
| ----------------- | -------------------------------------------------- |
| **Charter**       | Mission statement: what to explore, why, how long  |
| **Session**       | Time-boxed period of testing (typically 45-90 min) |
| **Session notes** | Observations, questions, ideas, findings           |
| **Debrief**       | Review session with stakeholders; plan next steps  |

### Writing Effective Charters

A charter should answer:

- **What** area or feature to explore?
- **Why** is this important (risk, change, unknowns)?
- **How** to approach (techniques, data, personas)?
- **What** are the expected oracles (how to judge correct behavior)?

**Charter template:**

```
Explore [target area]
With [resources: data, tools, persona]
To discover [information sought: risks, behaviors, issues]
```

**Example charters:**

- "Explore the checkout flow with edge-case payment methods to discover error handling gaps"
- "Explore the admin dashboard with slow network to discover performance and usability issues"
- "Explore user registration with special characters to discover input validation defects"

### Exploratory Testing Heuristics

Use heuristics to guide exploration:

| Heuristic           | Description                                                                                 |
| ------------------- | ------------------------------------------------------------------------------------------- |
| **SFDPOT**          | Structure, Function, Data, Platform, Operations, Time                                       |
| **HICCUPPS**        | History, Image, Comparable products, Claims, User expectations, Product, Purpose, Standards |
| **Boundaries**      | Test at limits, just inside, just outside                                                   |
| **Interruptions**   | Cancel, back, refresh, timeout mid-operation                                                |
| **Data variations** | Valid, invalid, empty, long, special characters                                             |

### Documenting Exploratory Sessions

During the session, capture:

- **Observations**: What you noticed (good and bad)
- **Questions**: Things to investigate or clarify
- **Ideas**: New test ideas spawned
- **Bugs**: Defects found (log formally)
- **Risks**: Areas needing more testing

After the session:

- **Summary**: What was explored, how long, coverage
- **Findings**: Defects, issues, concerns
- **Follow-up**: New charters, test cases to formalize, automation candidates

## Combining Techniques

| Situation               | Recommended Approach            |
| ----------------------- | ------------------------------- |
| Well-documented feature | Specification-based + checklist |
| New or changed feature  | Exploratory + error guessing    |
| High-risk area          | All techniques combined         |
| Time-constrained        | Error guessing + checklist      |
| Learning the system     | Exploratory testing             |
| Regression testing      | Checklist + automated tests     |

## Metrics for Experience-Based Testing

- **Session count**: Number of exploratory sessions conducted
- **Charter coverage**: % of planned charters completed
- **Defects per session**: Average defects found per session
- **Bug/discovery ratio**: Bugs vs. other findings (questions, ideas)
- **Time on task**: Actual testing time vs. session duration
