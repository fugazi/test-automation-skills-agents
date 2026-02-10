---
description: 'Guidelines for diagnosing, preventing, and resolving flaky tests that cause intermittent failures and undermine confidence in the test suite'
version: '1.0.0'
category: 'best-practices'
applies-to:
  agents: ['*']
  skills: ['*']
priority: 'recommended'
compliance:
  must-follow: ['Never ignore flaky tests - fix or quarantine them', 'Investigate flaky tests within 1 business day of identification', 'Use proper synchronization primitives instead of hard waits']
  should-follow: ['Design tests to be independent and isolated', 'Use retries only as a last resort with investigation', 'Document root causes and fixes for future reference']
  can-ignore: ['Known flaky tests that are quarantined with @skip tags', 'Third-party service issues documented with tickets']
---

# Flaky Test Resolution Guide

## Purpose

This document provides a systematic approach to identifying, diagnosing, preventing, and resolving flaky tests. Flaky tests are tests that produce inconsistent results (pass/fail) without any code changes, undermining trust in the test suite and wasting development time.

## What Are Flaky Tests?

A flaky test is one that:

```yaml
Definition:
  - Passes sometimes and fails other times
  - Shows different results across multiple runs
  - Fails intermittently without code changes
  - Succeeds on retry without any changes

Impact:
  - Lost developer time investigating false failures
  - Reduced confidence in test results
  - Blocked deployments due to false failures
  - "Boy who cried wolf" effect - real failures ignored
```

## Common Causes of Flaky Tests

### 1. Timing Issues

```yaml
Symptoms:
  - Test fails on slow machines but passes on fast ones
  - CI failures but local passes (or vice versa)
  - Inconsistent network conditions affect results
  - Race conditions in parallel test execution

Root Causes:
  - Hardcoded sleep times (waitForTimeout)
  - Missing explicit waits for conditions
  - No waiting for async operations
  - Animation and transition interference
```

### 2. State Leakage

```yaml
Symptoms:
  - Tests pass when run individually but fail in suite
  - Tests fail only when run after specific other tests
  - Inconsistent order-dependent failures
  - Database pollution between tests

Root Causes:
  - Shared state not properly reset
  - Database transactions not rolled back
  - Browser storage not cleared
  - Global variables not reset
  - Background processes not terminated
```

### 3. External Dependencies

```yaml
Symptoms:
  - Tests fail when external services are slow
  - Time-dependent tests fail at certain times/dates
  - Tests fail when third-party APIs have issues
  - Random test data generation causes occasional failures

Root Causes:
  - No mocking of external services
  - Tests depend on real-time clocks
  - Unreliable third-party APIs
  - Insufficient test data variety
```

### 4. Resource Constraints

```yaml
Symptoms:
  - Tests fail under high CPU/memory load
  - Tests fail when many tests run in parallel
  - File/socket descriptor exhaustion
  - Port conflicts in parallel execution

Root Causes:
  - Unreleased resources (file handles, connections)
  - No limits on parallel execution
  - Memory leaks in test code
  - Insufficient CI resources
```

### 5. Selectors and Locators

```yaml
Symptoms:
  - Tests fail when UI renders slightly differently
  - Tests fail due to dynamic element ordering
  - Auto-generated IDs cause failures
  - Multiple elements match selector

Root Causes:
  - Use of dynamic selectors (auto-generated IDs)
  - Selectors matching multiple elements
  - Using structural CSS classes
  - Time-dependent element visibility
```

## Diagnosis Strategies

### Step 1: Reproduce the Flakiness

```bash
# Run test multiple times sequentially
for i in {1..10}; do npm test -- specific.test; done

# Run test suite multiple times
npm test -- --repeats=10

# Run with increased logging
DEBUG=test:* npm test

# Run in isolation vs in suite
npm test -- specific.test  # Individual
npm test  # Full suite
```

### Step 2: Gather Information

```yaml
Collect:
  - Console logs from browser/application
  - Network requests and timing
  - Screenshots/video on failure
  - Test execution order
  - System resources during run
  - Timestamps of key operations

Tools:
  - Test framework's retry mechanism
  - CI logs and artifacts
  - Browser DevTools recordings
  - Performance profiling
```

### Step 3: Isolate the Cause

```typescript
// Add diagnostic logging
test('potentially flaky test', async () => {
  console.log('TEST START:', new Date().toISOString());

  try {
    await someAsyncOperation();
    console.log('ASYNC COMPLETE:', new Date().toISOString());

    await verifyResult();
    console.log('VERIFY COMPLETE:', new Date().toISOString());
  } catch (error) {
    console.log('ERROR:', {
      message: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString()
    });
    throw error;
  }
});
```

### Step 4: Test Hypotheses

```yaml
Hypothesis Testing:
  1. Add explicit waits → Did it stabilize?
  2. Run in isolation → Is it state leakage?
  3. Mock external services → Is it external dependency?
  4. Reduce parallelization → Is it resource contention?
  5. Use fixed test data → Is it random data issue?
```

## Prevention Techniques

### 1. Proper Synchronization

```typescript
// WRONG: Hardcoded wait
await page.waitForTimeout(5000);
await expect(page.locator('.result')).toBeVisible();

// RIGHT: Wait for specific condition
await page.waitForSelector('[data-testid="result"]', { state: 'visible' });
await expect(page.locator('[data-testid="result"]')).toBeVisible();

// RIGHT: Wait for network response
await page.waitForResponse(resp =>
  resp.url().includes('/api/data') && resp.status() === 200
);

// RIGHT: Wait for element to be actionable
await page.waitForSelector('[data-testid="submit"]', { state: 'attached' });
await page.waitForSelector('[data-testid="submit"]', { state: 'visible' });
await page.waitForSelector('[data-testid="submit"]', { state: 'stable' });
```

### 2. Test Isolation

```typescript
// WRONG: Shared state across tests
let userId: string;

test('create user', async () => {
  userId = await createUser({ name: 'Test' });
});

test('update user', async () => {
  // Depends on previous test running!
  await updateUser(userId, { name: 'Updated' });
});

// RIGHT: Each test is independent
test('create user', async () => {
  const user = await createUser({ name: 'Test' });
  await expect(user).toHaveProperty('id');
});

test('update user', async () => {
  const user = await createUser({ name: 'Test' });
  const updated = await updateUser(user.id, { name: 'Updated' });
  await expect(updated.name).toBe('Updated');
});
```

### 3. Proper Cleanup

```typescript
// RIGHT: Always clean up, even on failure
test('creates and deletes user', async () => {
  let userId: string;

  try {
    const user = await createUser({ name: 'Test' });
    userId = user.id;

    // Test assertions here
    await expect(user.name).toBe('Test');
  } finally {
    // Cleanup always runs
    if (userId) {
      await deleteUser(userId);
    }
  }
});

// BETTER: Use test framework hooks
let userId: string;

beforeEach(async () => {
  userId = await createUser({ name: 'Test' });
});

afterEach(async () => {
  if (userId) {
    await deleteUser(userId);
  }
});

test('user operations work', async () => {
  const user = await getUser(userId);
  await expect(user.name).toBe('Test');
});
```

### 4. Stable Selectors

```typescript
// WRONG: Dynamic selector
await page.click('.item:nth-child(3)');
await page.click('#element-abc123'); // Auto-generated ID
await page.click('div > div > span.button'); // Structural

// RIGHT: Semantic, stable selectors
await page.click('[data-testid="submit-button"]');
await page.click('button[type="submit"]');
await page.click('[aria-label="Submit form"]');
await page.getByName('submitButton').click();
```

### 5. Mock External Dependencies

```typescript
// WRONG: Depends on real external API
test('fetches user data', async () => {
  await page.goto('/profile');
  await expect(page.locator('.username')).toHaveText('John Doe');
  // Fails if API is down/slow
});

// RIGHT: Mock the API response
test('displays user data', async () => {
  await page.route('**/api/user', route => {
    route.fulfill({
      status: 200,
      body: JSON.stringify({ name: 'John Doe', email: 'john@example.com' })
    });
  });

  await page.goto('/profile');
  await expect(page.locator('.username')).toHaveText('John Doe');
});
```

### 6. Deterministic Test Data

```typescript
// WRONG: Random data can cause occasional failures
test('email validation', async () => {
  const email = generateRandomEmail();
  const valid = await validateEmail(email);
  // Random email might accidentally be invalid
  await expect(valid).toBe(true);
});

// RIGHT: Deterministic test data
test('accepts valid email format', async () => {
  const validEmails = [
    'test@example.com',
    'user.name@domain.co.uk',
    'first+last@test.com'
  ];

  for (const email of validEmails) {
    await expect(validateEmail(email)).resolves.toBe(true);
  }
});
```

## Retry Strategy

When to Use Retries

```yaml
Acceptable Use Cases:
  - Known network flakiness (document the root cause)
  - Third-party service limitations (with ticket to fix)
  - Interim solution while proper fix is developed

Never Use For:
  - Masking poor synchronization
  - Hiding state leakage issues
  - Ignoring actual test failures
  - Convenience over proper fixes
```

Implementing Retries

```typescript
// Playwright example: Configure retries globally
module.exports = {
  retries: process.env.CI ? 2 : 0, // Only retry in CI
};

// Per-test override
test.skip('flaky test being investigated', async () => {
  // ...
});

test('test with documented retry reason', async ({
  // This test retries due to known API rate limiting
  // Ticket: TEST-123
}, testInfo) => {
  testInfo.retry = true;
  // ...
});
```

## Examples: Flaky Tests and Fixes

### Example 1: Race Condition

```typescript
// FLAKY: Element not yet clickable
test('submits form', async () => {
  await page.click('[data-testid="submit"]');
  // Sometimes fails: Element not visible or not clickable
});

// FIXED: Wait for actionable state
test('submits form', async () => {
  const button = page.locator('[data-testid="submit"]');
  await button.waitFor({ state: 'visible' });
  await button.waitFor({ state: 'attached' });
  await button.click();
});

// BETTER: Use built-in actionability checks
test('submits form', async () => {
  await page.click('[data-testid="submit"]', {
    force: false, // Let Playwright check actionability
    timeout: 5000 // Explicit but reasonable timeout
  });
});
```

### Example 2: State Leakage

```typescript
// FLAKY: Depends on test execution order
test('adds item to cart', async () => {
  await cart.addItem('item-1');
  const count = await cart.getItemCount();
  await expect(count).toBe(1); // Fails if previous test left items
});

// FIXED: Ensure clean state
test('adds item to cart', async () => {
  await cart.clear(); // Clear first
  await cart.addItem('item-1');
  const count = await cart.getItemCount();
  await expect(count).toBe(1);
});

// BETTER: Use beforeEach for setup
beforeEach(async () => {
  await cart.clear();
});

test('adds item to cart', async () => {
  await cart.addItem('item-1');
  await expect(await cart.getItemCount()).toBe(1);
});
```

### Example 3: Network Dependency

```typescript
// FLAKY: Depends on external API availability
test('displays weather data', async () => {
  await page.goto('/weather');
  await expect(page.locator('.temperature')).toBeVisible();
  // Fails when weather API is slow/down
});

// FIXED: Mock the external service
test('displays weather data', async () => {
  await page.route('**/api/weather', route => {
    route.fulfill({
      status: 200,
      body: JSON.stringify({ temp: 72, condition: 'Sunny' })
    });
  });

  await page.goto('/weather');
  await expect(page.locator('.temperature')).toContainText('72');
});
```

### Example 4: Animation Interference

```typescript
// FLAKY: Animations cause element position changes
test('clicks menu item', async () => {
  await page.hover('[data-testid="menu"]');
  await page.click('[data-testid="menu-item"]');
  // Sometimes misses due to menu animation
});

// FIXED: Disable animations or wait for completion
test('clicks menu item', async () => {
  // Disable animations
  await page.addInitStyle(`
    *, *::before, *::after {
      animation-duration: 0ms !important;
      transition-duration: 0ms !important;
    }
  `);

  await page.goto('/page');
  await page.hover('[data-testid="menu"]');
  await page.click('[data-testid="menu-item"]');
});
```

### Example 5: Dynamic Selector

```typescript
// FLAKY: Selector uses dynamic ID
test('opens modal', async () => {
  await page.click('#modal-btn-12345'); // ID changes
});

// FIXED: Use stable selector
test('opens modal', async () => {
  await page.click('[data-testid="open-modal-button"]');
});
```

## Quarantine Process

When a flaky test cannot be immediately fixed:

```typescript
/**
 * @flaky
 * Issue: TEST-456
 * Reason: Race condition with payment processing
 * Discovered: 2024-01-15
 * Target Fix: 2024-01-30
 */
test.skip('payment processes correctly', async () => {
  // Temporarily skipped
});
```

## Monitoring Flaky Tests

```yaml
Track:
  - Flaky test frequency (how often)
  - Flaky test patterns (which tests)
  - Time to resolution
  - Root cause categories

Tools:
  - Test flakiness dashboards
  - Automated flakiness detection
  - Regular flakiness reports
  - Test history tracking
```

## Prevention Checklist

Before marking a test as complete:

- [ ] Test passes when run individually 10 times
- [ ] Test passes when run in full suite
- [ ] Test passes in CI environment
- [ ] No hardcoded sleeps or arbitrary waits
- [ ] Proper cleanup in afterEach/afterAll
- [ ] Stable selectors (data-testid preferred)
- [ ] External dependencies mocked or documented
- [ ] Test data is deterministic
- [ ] No shared state with other tests
- [ ] Clear error messages for failures
