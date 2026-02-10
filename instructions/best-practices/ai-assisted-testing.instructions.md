---
description: 'Best practices for using AI assistance in QA Automation testing activities, including when to leverage AI, validation requirements, and privacy considerations'
version: '1.0.0'
category: 'best-practices'
applies-to:
  agents: ['*']
  skills: ['*']
priority: 'recommended'
compliance:
  must-follow: ['Always review AI-generated code before committing', 'Never include PII or sensitive credentials in AI prompts', 'Security and critical path tests require manual validation']
  should-follow: ['Use AI for boilerplate and repetitive tasks', 'Maintain human oversight for test logic', 'Document AI-assisted changes']
  can-ignore: ['Simple, non-critical utility functions', 'Proof-of-concept or experimental code']
---

# AI-Assisted Testing Best Practices

## Purpose

This document provides guidelines for effectively using AI assistance in QA Automation while maintaining code quality, security, and human oversight. AI can significantly accelerate test development but requires careful validation and appropriate use cases.

## When to Use AI

### Excellent Use Cases

| Use Case | Description | Example |
|----------|-------------|---------|
| **Boilerplate Generation** | Create repetitive test scaffolding | Page object classes, test templates, configuration files |
| **Test Data Generation** | Create varied test datasets | JSON fixtures, CSV test data, edge case values |
| **Refactoring Ideas** | Get suggestions for code improvement | Identifying duplication, suggesting design patterns |
| **Documentation** | Generate or improve documentation | Test descriptions, README files, inline comments |
| **Selector Strategies** | Suggest stable CSS/XPath selectors | Data-testid strategies, ARIA label approaches |
| **Test Structure Ideas** | Explore organizational patterns | Test pyramid implementations, folder structures |

### Moderate Use Cases (Review Required)

| Use Case | Caution | Example |
|----------|---------|---------|
| **Test Logic** | May miss edge cases | Happy path tests, straightforward assertions |
| **Error Messages** | May be generic | Custom error descriptions, failure messages |
| **Mock/Stub Creation** | May not match real behavior | API response mocks, fixture data |

## When NOT to Use AI

### High-Risk Areas (Avoid AI)

| Area | Reason | Alternative |
|------|--------|-------------|
| **Security Tests** | AI may miss vulnerabilities | Manual security review, specialized tools |
| **Critical Path Tests** | Failure impact is severe | Human-written, thoroughly reviewed tests |
| **Compliance Tests** | Legal/regulatory implications | SME-validated test scenarios |
| **Performance Tests** | AI can't validate performance characteristics | Specialized performance tools, human analysis |
| **Complex Business Logic** | AI may misunderstand domain rules | QA + Business Owner collaboration |

### Red Flags for AI Usage

- Tests for payment processing or financial transactions
- Authentication/authorization flows
- Personal data handling (GDPR, CCPA)
- Multi-threading or race condition scenarios
- Tests requiring specific domain expertise

## Validation Requirements

### Mandatory Validation Checklist

Before committing AI-generated test code:

- [ ] **Code Review**: Another human has reviewed the code
- [ ] **Manual Execution**: Test has been run successfully at least once
- [ ] **Assertion Verification**: All assertions are correct and meaningful
- [ ] **Selector Stability**: Locators are resilient to UI changes
- [ ] **Error Handling**: Proper failure messages and cleanup
- [ ] **No Hardcoded Values**: Environment-specific data is externalized

### Validation Levels

```yaml
Critical: # Requires senior QA review
  - Authentication tests
  - Payment flows
  - Data deletion/alteration
  - Security-related scenarios

High: # Requires peer review
  - Core business logic
  - Integration tests
  - API contract tests

Moderate: # Self-review acceptable
  - UI smoke tests
  - Page object updates
  - Test data generation

Low: # Minimal validation
  - Documentation updates
  - Comment additions
  - Formatting changes
```

## Examples: Good vs Bad AI Usage

### Good: AI for Boilerplate

```typescript
// AI-generated page object template (GOOD)
// Human then adds specific selectors and methods
export class BasePage {
  constructor(protected page: Page) {}

  async navigate(url: string): Promise<void> {
    await this.page.goto(url);
  }

  async waitForSelector(selector: string): Promise<void> {
    await this.page.waitForSelector(selector);
  }
}
```

### Bad: AI for Critical Security Test

```typescript
// AI-generated security test (BAD)
// Missing: CSRF token validation, session checks, proper authentication
test('should prevent unauthorized access', async () => {
  await page.goto('/admin');
  // AI didn't consider auth redirect, session tokens, etc.
  expect(await page.textContent()).toContain('Access Denied');
});
```

### Good: AI with Human Refinement

```typescript
// AI suggested (GOOD FOUNDATION)
const testCases = [
  { input: 'valid@email.com', expected: 'success' },
  { input: 'invalid', expected: 'error' }
];

// Human added edge cases (ESSENTIAL)
const testCases = [
  { input: 'valid@email.com', expected: 'success', description: 'standard email' },
  { input: 'invalid', expected: 'error', description: 'missing @ symbol' },
  { input: 'a@b.c', expected: 'success', description: 'minimal valid email' },
  { input: 'very.long.' + 'x'.repeat(64) + '@example.com', expected: 'error', description: 'exceeds length limit' },
  { input: '"quoted@"@example.com', expected: 'success', description: 'quoted local part' }
];
```

### Bad: Unvalidated AI Test Logic

```typescript
// AI-generated without review (BAD)
test('checkout flow', async () => {
  await page.click('[data-testid="checkout"]'); // Too generic
  await page.fill('input[name="card"]', '4111...'); // Fake data might fail validation
  await page.click('button[type="submit"]');
  // No verification of success, no cleanup, no state reset
});
```

## Privacy Considerations

### What NOT to Include in AI Prompts

```yaml
Never Include:
  - Real user credentials (usernames, passwords)
  - API keys or access tokens
  - Personal data (names, emails, addresses)
  - Production URLs or endpoints
  - Internal IP addresses
  - Database connection strings
  - Security tokens or session IDs
  - Proprietary algorithms or trade secrets

Always Sanitize:
  - Replace real emails with test@example.com
  - Use placeholder URLs like https://test-env.example.com
  - Replace real tokens with YOUR_TOKEN or similar placeholders
  - Anonymize user data before sharing
```

### Example: Safe vs Unsafe Prompts

```yaml
Unsafe: ❌
  "How do I test login for user john.doe@company.com with password Secret123?"

Safe: ✅
  "How do I write a login test using test@example.com and placeholder credentials?"
```

## AI Prompt Best Practices

### Effective Prompt Structure

```markdown
1. **Context**: Briefly describe the testing goal
2. **Tech Stack**: Specify framework, language, and tools
3. **Requirements**: List specific requirements or constraints
4. **Output Format**: Describe expected output structure
5. **Example**: Provide a similar working example if available
```

### Example Effective Prompt

```
Context: I need to create a login page object for a React application.
Tech Stack: TypeScript, Playwright, Page Object Model
Requirements:
- Methods for login, logout, and password reset
- Proper waiting for network responses
- Error handling for invalid credentials
- Use data-testid selectors
Output: TypeScript class with JSDoc comments
```

## AI-Assisted Code Review Checklist

When reviewing AI-generated code:

| Check | Question |
|-------|----------|
| **Correctness** | Does the test actually validate what it claims? |
| **Completeness** | Are all edge cases covered? |
| **Stability** | Will UI changes break this test? |
| **Maintainability** | Is the code readable and well-structured? |
| **Performance** | Is the test efficient (no unnecessary waits)? |
| **Security** | Does it handle sensitive data appropriately? |
| **Cleanup** | Does it clean up after itself? |

## Continuous Improvement

### Tracking AI Assistance Quality

```yaml
For each AI-assisted test, document:
  - Original prompt
  - AI-generated code
  - Human modifications made
  - Issues found during validation
  - Lessons learned
```

### Feedback Loop

1. **Document failures**: When AI-generated tests fail, note why
2. **Refine prompts**: Update prompt templates based on lessons learned
3. **Share patterns**: Distribute successful prompt patterns to team
4. **Update guidelines**: Revise this doc with new learnings

## Resources

- [OWASP Testing Guidelines](https://owasp.org/www-project-web-security-testing-guide/)
- [AI Prompt Engineering for Testing](https://example.com) (internal)
- Team knowledge base for approved prompt templates
