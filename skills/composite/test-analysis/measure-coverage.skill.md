---
name: 'measure-coverage'
description: 'Analyze test coverage across user flows, features, and edge cases to identify gaps in the test suite and suggest additional test scenarios'
version: '1.0.0'
type: 'composite'
category: 'test-analysis'

activation: 'explicit'
aliases: ['coverage-analysis', 'test-gap-analysis', 'coverage-report', 'identify-missing-tests']

requires:
  skills: ['generate-e2e-test']
  knowledge: ['coverage metrics', 'user flow mapping', 'edge case identification', 'risk-based testing']
  tools: ['coverage tools', 'test runners', 'code analysis']

output:
  format: 'report'
  template: 'templates/coverage-report.md'

success-criteria:
  - All critical user flows are identified
  - Coverage gaps are documented with risk levels
  - Missing test scenarios are suggested
  - Priority recommendations are provided
  - Coverage metrics are calculated
---

## Purpose

Analyze the test suite to measure coverage across features, user flows, and scenarios. Identify gaps where tests are missing and prioritize areas that need additional test coverage based on risk and business impact.

## When to Use

- Before release to ensure adequate test coverage
- When planning test suite expansion
- During test triage to identify under-tested areas
- For quality metrics and reporting
- When conducting risk assessments

## Analysis Dimensions

### 1. User Flow Coverage
Measures how many complete user journeys are tested end-to-end.

| Flow Type | Tested | Missing | Coverage |
|-----------|--------|---------|----------|
| Authentication | | | |
| Registration | | | |
| Checkout | | | |
| Search | | | |

### 2. Feature Coverage
Measures which features have dedicated tests.

| Feature | Happy Path | Edge Cases | Error Paths | Total |
|---------|-----------|------------|-------------|-------|
| User Profile | Y | N | N | 33% |
| Shopping Cart | Y | Y | N | 66% |
| Payments | Y | N | Y | 66% |

### 3. Scenario Coverage
Measures test coverage for different scenarios.

| Scenario | Covered | Gap |
|----------|---------|-----|
| Successful operations | 90% | 10% |
| Error handling | 40% | 60% |
| Edge cases | 25% | 75% |
| Boundary conditions | 30% | 70% |
| Performance/Load | 10% | 90% |

### 4. Browser/Device Coverage
Measures cross-platform testing coverage.

| Platform | Desktop | Mobile | Tablet |
|----------|---------|--------|--------|
| Chrome | Y | Y | N |
| Firefox | Y | N | N |
| Safari | Y | Y | N |
| Edge | N | N | N |

## Workflow

### 1. Map Application Features
Identify all features and user-facing functionality:
- User authentication and authorization
- Core business flows
- Data management operations
- Integrations and external dependencies
- Administrative functions

### 2. Inventory Existing Tests
Catalog current test coverage:
- List all test files and their purposes
- Map tests to features they cover
- Identify duplicate tests
- Note test types (E2E, integration, unit)

### 3. Identify Gaps
Compare feature map against test inventory:
- Untested features
- Partially tested features
- Missing edge cases
- Uncovered error paths

### 4. Prioritize by Risk
Rank gaps by impact and likelihood:
- Critical: High impact, high likelihood
- High: High impact, medium likelihood
- Medium: Medium impact, any likelihood
- Low: Low impact, any likelihood

### 5. Generate Recommendations
Suggest specific tests to add:
- Test names and descriptions
- Expected outcomes
- Priority levels

## Coverage Report Template

```markdown
# Test Coverage Analysis Report

**Date**: 2024-01-15
**Application**: E-Commerce Platform
**Test Suite**: 127 tests across 15 files

---

## Executive Summary

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Feature Coverage | 78% | 90% | BELOW TARGET |
| User Flow Coverage | 65% | 80% | BELOW TARGET |
| Error Path Coverage | 42% | 70% | BELOW TARGET |
| Edge Case Coverage | 28% | 60% | BELOW TARGET |

**Overall Assessment**: Test suite covers primary user flows but lacks comprehensive error handling and edge case coverage.

---

## Feature Coverage Details

### Authentication (100% Covered)
- Login: 4 tests covering success, invalid credentials, locked account
- Registration: 3 tests covering success, validation, duplicate email
- Password Reset: 2 tests covering request and completion
- Logout: 1 test

### Checkout (60% Covered)
- **Covered**:
  - Guest checkout
  - Registered user checkout
  - Multiple payment methods
- **Missing**:
  - [HIGH] Out of stock items
  - [HIGH] Payment failure scenarios
  - [MEDIUM] Cart abandonment
  - [MEDIUM] Promo code validation
  - [LOW] Multiple address support

### Product Catalog (70% Covered)
- **Covered**:
  - Search functionality
  - Category browsing
  - Product details
- **Missing**:
  - [MEDIUM] Advanced filters
  - [MEDIUM] Sorting options
  - [HIGH] Product comparison

### User Profile (50% Covered)
- **Covered**:
  - View profile
  - Edit basic info
- **Missing**:
  - [HIGH] Profile picture upload
  - [MEDIUM] Address management
  - [MEDIUM] Order history
  - [LOW] Preferences

---

## Critical Gaps (High Priority)

### 1. Payment Failure Handling
**Risk**: HIGH - Revenue impact
**Current**: Only success case tested
**Missing Tests**:
- Payment declined scenarios
- Network timeout during payment
- Invalid card details
- Payment gateway errors

**Suggested Test**:
```typescript
test('shows appropriate error when payment is declined', async ({ page }) => {
  await completeCheckoutThroughPayment(page, {
    cardNumber: '4000000000000002', // Declined card
    expiry: '12/25',
    cvv: '123'
  });

  await expect(page.getByRole('alert'))
    .toHaveText(/payment declined|card was declined/i);
  await expect(page).toHaveURL(/\/checkout/);
});
```

### 2. Concurrent Cart Operations
**Risk**: HIGH - Data integrity
**Current**: No tests for concurrent usage
**Missing Tests**:
- Adding same item from multiple tabs
- Stock depletion during checkout
- Price changes while in cart

### 3. Session Timeout Handling
**Risk**: MEDIUM - User experience
**Current**: Not tested
**Missing Tests**:
- Session expires during checkout
- Re-authentication after timeout
- Cart persistence across sessions

---

## Edge Case Gaps

### Input Validation
| Input | Valid Tested | Invalid Tested | Boundary Tested |
|-------|--------------|----------------|----------------|
| Email | Yes | Partial | No |
| Password | Yes | Yes | No |
| Phone | No | No | No |
| Postal Code | No | No | No |

### Data Scenarios
| Scenario | Tested |
|----------|---------|
| Empty lists | Partial |
| Very large lists | No |
| Special characters | Partial |
| Unicode characters | No |
| Null/undefined values | No |

---

## Recommendations

### Immediate Actions (Sprint 1)
1. Add payment failure scenarios (5 tests)
2. Test session timeout handling (3 tests)
3. Add out-of-stock checkout flow (2 tests)

### Short-term (Sprint 2-3)
1. Expand edge case coverage for forms
2. Add concurrent operation tests
3. Implement comparison feature tests
4. Add profile management tests

### Long-term (Sprint 4+)
1. Performance and load tests
2. Accessibility test coverage
3. Cross-browser compatibility matrix
4. Mobile-specific behavior tests

---

## Coverage by Risk

| Risk Level | Features Covered | Features Partial | Features Missing |
|------------|------------------|------------------|------------------|
| Critical | 5 | 2 | 1 |
| High | 8 | 4 | 2 |
| Medium | 12 | 8 | 5 |
| Low | 15 | 10 | 8 |
```

## Coverage Metrics Calculation

```typescript
// Example coverage calculation
interface CoverageMetrics {
  featureCoverage: number;
  flowCoverage: number;
  scenarioCoverage: number;
  overallCoverage: number;
}

function calculateCoverage(
  totalFeatures: number,
  testedFeatures: number,
  totalFlows: number,
  testedFlows: number,
  totalScenarios: number,
  testedScenarios: number
): CoverageMetrics {
  return {
    featureCoverage: (testedFeatures / totalFeatures) * 100,
    flowCoverage: (testedFlows / totalFlows) * 100,
    scenarioCoverage: (testedScenarios / totalScenarios) * 100,
    overallCoverage:
      ((testedFeatures + testedFlows + testedScenarios) /
       (totalFeatures + totalFlows + totalScenarios)) * 100
  };
}
```

## Common Coverage Gaps

### Most Frequently Missing Tests

1. **Error Paths** (60% of projects lack)
   - API failure responses
   - Network timeouts
   - Invalid data handling

2. **Edge Cases** (75% of projects lack)
   - Boundary values
   - Empty states
   - Maximum limits

3. **Negative Testing** (70% of projects lack)
   - Invalid inputs
   - Unauthorized access
   - Malformed data

4. **Performance** (90% of projects lack)
   - Large data sets
   - Slow networks
   - Concurrent users

## Test Coverage Checklist

Use this checklist to identify missing test areas:

### Functional Coverage
- [ ] All user workflows tested
- [ ] All CRUD operations tested
- [ ] All form validations tested
- [ ] All error states tested
- [ ] All API integrations tested

### Non-Functional Coverage
- [ ] Performance under load
- [ ] Slow network conditions
- [ ] Accessibility (WCAG)
- [ ] Cross-browser compatibility
- [ ] Mobile responsiveness

### Data Coverage
- [ ] Valid data formats
- [ ] Invalid data formats
- [ ] Boundary values
- [ ] Empty/null values
- [ ] Special characters
- [ ] Unicode/internationalization

### User Coverage
- [ ] Guest users
- [ ] Authenticated users
- [ ] Different user roles
- [ ] Different permission levels
- [ ] Disabled users (a11y)

## Best Practices

1. **Prioritize by Risk** - Focus on high-impact, high-likelihood scenarios
2. **Cover Happy Path First** - Ensure main flows work before edge cases
3. **Test Error Paths** - Don't forget negative scenarios
4. **Consider User Context** - Different users, devices, environments
5. **Maintain Test Independence** - Each test should verify one thing
6. **Review Coverage Regularly** - Apps change, coverage needs updating

## Related Skills

- [generate-e2e-test](../test-generation/generate-e2e-test.skill.md) - Create missing tests
- [analyze-flakiness](./analyze-flakiness.skill.md) - Assess test quality
- [diagnose-failure](../test-healing/diagnose-failure.skill.md) - Analyze test failures
