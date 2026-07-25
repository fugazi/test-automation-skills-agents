# Workflow Examples

## Example: Using the Test Case Template

**Request:**

```
"Create a test case for user login with valid credentials using the test-case.md template"
```

**Result:**
The AI will:

1. Open `templates/test-case.md`
2. Fill in the placeholders with specific details:
   - TC-ID: `TC-LOGIN-001`
   - Title: `Verify valid user login with correct credentials`
   - Priority: `P0 (Critical)`
   - Type: `Functional`
   - Objective: `Verify users can successfully login with valid credentials`
   - Preconditions: `User account exists in test environment; Browser cookies cleared`
   - Test Steps: Fill with specific login steps
   - Test Data: Use `${TEST_USER_EMAIL}` and `${TEST_USER_PASSWORD}` placeholders
3. Provide the completed test case markdown file

## Example: Using the Bug Report Template

**Request:**

```
"Create a bug report for a login form validation issue using the bug-report.md template"
```

**Result:**
The AI will:

1. Open `templates/bug-report.md`
2. Generate a unique bug ID (e.g., `BUG-1715345678`)
3. Fill in the placeholders:
   - Title: `Login form accepts invalid email format`
   - Severity: `High`
   - Priority: `P1`
   - Environment: Fill with actual OS, browser, build details
   - Steps to Reproduce: Add specific, reproducible steps
   - Expected vs Actual: Clear description of the issue
   - Impact: Describe user and business impact
4. Provide the completed bug report markdown file

## Example: Using the Playwright Spec Template

**Request:**

```
"Create Playwright tests for the login flow using the playwright-test.md template"
```

**Result:**
The AI will:

1. Open `templates/playwright-test.md`
2. Customize the test describe block for login functionality
3. Add specific test cases:
   - `TC-LOGIN-001 @smoke @regression` - Valid login
   - `TC-LOGIN-002 @regression @negative` - Invalid credentials
   - `TC-LOGIN-003 @regression @boundary` - Password validation
4. Implement test steps using Playwright best practices:
   - Role-based locators (`getByRole`)
   - Web-first assertions (`toBeVisible`, `toHaveText`)
   - test.step() grouping for readability
5. Add security notes about environment variables
6. Provide the completed markdown template with TypeScript code examples
