# Test Conditions - {{feature}}

> Test conditions are testable aspects derived from the test basis. Each condition answers "what to test" before defining detailed test cases (how to test).

## Document Control

- Feature: {{feature}}
- Release: {{release}}
- Date: {{date}}
- Author: {{owner}}
- Test Basis: [Link to requirements/stories]

## Test Conditions

### Functional Conditions

| ID | Test Condition | Source | Priority | Risk | Technique | Test Cases |
|----|---------------|--------|:--------:|:----:|-----------|------------|
| COND-001 | Verify [feature] accepts valid [input] | REQ-001 | High | High | EP, BVA | TC-001, TC-002 |
| COND-002 | Verify [feature] rejects invalid [input] | REQ-001 | High | Medium | EP | TC-003 |
| COND-003 | Verify [feature] handles [boundary case] | REQ-001 | Medium | High | BVA | TC-004 |
| COND-004 | Verify [workflow state] transitions correctly | REQ-002 | High | High | State transition | TC-005, TC-006 |
| COND-005 | Verify [business rule] applies when [conditions] | REQ-003 | High | Medium | Decision table | TC-007 |
| COND-006 | Verify [user journey] completes successfully | US-001 | High | High | Use case | TC-008, TC-009 |

### Non-Functional Conditions

| ID | Test Condition | Quality Attribute | Source | Priority | Test Cases |
|----|---------------|-------------------|--------|:--------:|------------|
| COND-NF-001 | Verify page loads within [X] seconds | Performance | NFR-001 | High | TC-NF-001 |
| COND-NF-002 | Verify system handles [N] concurrent users | Scalability | NFR-002 | Medium | TC-NF-002 |
| COND-NF-003 | Verify [feature] is accessible via keyboard | Accessibility | NFR-003 | High | TC-NF-003 |
| COND-NF-004 | Verify [data] is encrypted in transit | Security | NFR-004 | High | TC-NF-004 |

### Negative/Error Conditions

| ID | Test Condition | Expected Behavior | Source | Priority | Test Cases |
|----|---------------|-------------------|--------|:--------:|------------|
| COND-NEG-001 | Verify [feature] handles [error scenario] | Show error message | REQ-001 | Medium | TC-NEG-001 |
| COND-NEG-002 | Verify [timeout scenario] is handled gracefully | Retry/fallback | REQ-002 | High | TC-NEG-002 |
| COND-NEG-003 | Verify [invalid input] is rejected with feedback | Validation error | REQ-003 | High | TC-NEG-003 |

## Coverage Matrix

| Requirement | Test Conditions | Test Cases | Status |
|-------------|:---------------:|:----------:|--------|
| REQ-001 | 3 | 5 | Designed |
| REQ-002 | 2 | 3 | Designed |
| REQ-003 | 1 | 2 | Pending |
| US-001 | 1 | 2 | Designed |
| NFR-001 | 1 | 1 | Designed |

## Notes

- **Derivation technique**: [EP/BVA/Decision table/State transition/Use case]
- **Gaps identified**: [Any requirements without conditions]
- **Assumptions**: [Any assumptions made during analysis]
- **Follow-ups**: [Questions for stakeholders, missing information]

## Revision History

| Version | Date | Author | Changes |
|:-------:|------|--------|---------|
| 0.1 | {{date}} | {{owner}} | Initial draft |
