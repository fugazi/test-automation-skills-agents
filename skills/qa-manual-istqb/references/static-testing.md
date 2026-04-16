# Static Testing (ISTQB Foundation Level)

Static testing examines work products (requirements, designs, code, test cases) **without executing** software. It finds defects early, reducing cost and rework.

## Static vs Dynamic Testing

| Aspect    | Static Testing                         | Dynamic Testing                             |
| --------- | -------------------------------------- | ------------------------------------------- |
| Execution | No code execution                      | Code is executed                            |
| Timing    | Early (shift-left)                     | After implementation                        |
| Finds     | Defects in documents, code structure   | Failures in running software                |
| Examples  | Reviews, walkthroughs, static analysis | Unit tests, integration tests, system tests |

## Benefits of Static Testing

- **Early defect detection**: Find issues before they become code defects
- **Lower cost**: Fixing defects in requirements is 10-100x cheaper than in production
- **Improved quality**: Better requirements lead to better implementations
- **Knowledge sharing**: Reviews spread understanding across the team
- **Compliance**: Required for safety-critical and regulated industries

## Review Types (ISTQB)

### 1. Informal Review

- No formal process; ad-hoc feedback
- Quick turnaround; limited documentation
- Good for early drafts and learning

### 2. Walkthrough

- Author presents the work product
- Attendees ask questions and provide feedback
- Moderately formal; some documentation
- Good for knowledge transfer and consensus

### 3. Technical Review

- Led by a moderator (not the author)
- Focus on technical correctness and standards
- Participants are technical peers
- Documented findings and decisions

### 4. Inspection (Fagan Inspection)

- Most formal and rigorous
- Defined roles: moderator, author, reviewers, recorder
- Checklists and entry/exit criteria
- Metrics collected for process improvement
- Highest defect detection rate

## Review Process (Generic)

1. **Planning**: Define scope, objectives, participants, entry criteria
2. **Initiation**: Distribute materials; explain objectives
3. **Individual review**: Each reviewer examines the work product
4. **Issue communication**: Discuss findings (meeting or async)
5. **Fixing and reporting**: Author addresses issues; document outcomes
6. **Follow-up**: Verify fixes; close the review

## Review Roles

| Role      | Responsibility                                      |
| --------- | --------------------------------------------------- |
| Author    | Creates the work product; addresses findings        |
| Moderator | Facilitates the review; ensures process is followed |
| Reviewer  | Examines work product; identifies issues            |
| Recorder  | Documents findings and decisions                    |
| Manager   | Allocates time and resources for reviews            |

## Review Checklists

### Requirements Review Checklist

- [ ] Requirements are unambiguous and testable
- [ ] Requirements are complete (no TBD, missing scenarios)
- [ ] Requirements are consistent (no contradictions)
- [ ] Requirements are traceable to business goals
- [ ] Acceptance criteria are defined
- [ ] Non-functional requirements are specified (performance, security, usability)
- [ ] Edge cases and error handling are addressed
- [ ] Dependencies and interfaces are identified

### Test Plan Review Checklist

- [ ] Scope and objectives are clear
- [ ] Test levels and types are appropriate
- [ ] Entry and exit criteria are defined and measurable
- [ ] Risks are identified with mitigation strategies
- [ ] Resources, schedule, and dependencies are realistic
- [ ] Test environments and data are planned
- [ ] Deliverables and reporting are specified

### Test Case Review Checklist

- [ ] Test case has a unique ID and clear title
- [ ] Preconditions are specified
- [ ] Steps are atomic and unambiguous
- [ ] Expected results are verifiable (clear oracle)
- [ ] Test case is traceable to requirement/story
- [ ] Test data is specified or referenced
- [ ] Priority and risk tags are assigned

### Code Review Checklist (for test automation)

- [ ] Code follows team coding standards
- [ ] Test is independent (no order dependencies)
- [ ] Locators are stable (prefer test IDs)
- [ ] No hardcoded waits; uses explicit waits/assertions
- [ ] Error handling is appropriate
- [ ] Test is readable and maintainable
- [ ] Comments explain non-obvious logic

## Static Analysis Tools

Static analysis automates code inspection without execution:

| Tool Type            | Purpose                   | Examples                   |
| -------------------- | ------------------------- | -------------------------- |
| Linters              | Code style and formatting | ESLint, Pylint, Checkstyle |
| Type checkers        | Type safety               | TypeScript, mypy           |
| Security scanners    | Vulnerability detection   | SonarQube, Snyk, CodeQL    |
| Complexity analyzers | Code maintainability      | SonarQube, Code Climate    |

## When to Use Static Testing

- **Requirements phase**: Review user stories, acceptance criteria
- **Design phase**: Review architecture, API contracts, UI mockups
- **Implementation phase**: Code reviews, static analysis
- **Test planning phase**: Review test plans, test cases
- **Before major milestones**: Gate reviews for quality assurance

## Metrics from Reviews

- **Defects found per hour** of review time
- **Defect density** in reviewed work products
- **Review coverage**: % of work products reviewed
- **Defect escape rate**: defects found later that could have been found in review
