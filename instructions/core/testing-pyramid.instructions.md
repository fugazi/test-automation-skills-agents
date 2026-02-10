---
description: 'Testing pyramid strategy balancing unit, integration, and E2E tests for optimal test coverage and feedback speed'
version: '1.0.0'
category: 'core'
applies-to:
  agents: ['*']
  skills: ['*']
priority: 'mandatory'
compliance:
  must-follow: [
    'Prioritize unit tests over integration and E2E tests',
    'Maintain test pyramid proportions (70-80% unit, 10-20% integration, 2-5% E2E)',
    'Design tests to run quickly and provide fast feedback',
    'Avoid duplicating test coverage across pyramid levels'
  ]
  should-follow: [
    'Write unit tests alongside production code',
    'Use integration tests for critical workflows only',
    'Reserve E2E tests for happy paths and critical user journeys',
    'Regularly review and prune tests to maintain pyramid balance',
    'Mock external dependencies to keep tests fast and reliable'
  ]
  can-ignore: [
    'Pyramid proportions during legacy system modernization (gradual improvement acceptable)',
    'Additional E2E coverage for compliance or regulatory requirements',
    'Higher integration test ratio for distributed systems with complex interactions'
  ]
---

# Testing Pyramid

## Purpose and Scope

The Testing Pyramid is a fundamental strategy for structuring automated tests to optimize for speed, reliability, and maintainability. This document provides guidance on implementing the testing pyramid to ensure effective test coverage while minimizing feedback time and maintenance burden.

## Test Pyramid Visualization

```
                    /\
                   /  \
                  / E2E\
                 / (2-5%)\        Slow, Expensive, Brittle
                /----------\
               /            \
              / Integration \
             /   (10-20%)    \     Medium Speed, Medium Cost
            /------------------\
           /                    \
          /      Unit Tests      \
         /      (70-80%)          \  Fast, Cheap, Reliable
        /------------------------------

Key Characteristics by Level:

┌─────────────┬──────────────┬──────────┬──────────┬─────────────┐
│   Level     │   Quantity   │ Speed    │ Cost     │ Reliability │
├─────────────┼──────────────┼──────────┼──────────┼─────────────┤
│ Unit        │ 70-80%       │ <1 sec   │ Low      │ High        │
│ Integration │ 10-20%       │ 1-10 sec │ Medium   │ Medium      │
│ E2E         │ 2-5%         │ 10-60 sec│ High     │ Low         │
└─────────────┴──────────────┴──────────┴──────────┴─────────────┘
```

### Why the Pyramid Shape?

**Base (Unit Tests):**
- Provides foundation of confidence
- Fast feedback enables rapid development
- Cheap to write and maintain
- Pinpoints exact failure location

**Middle (Integration Tests):**
- Validates component interactions
- Covers what unit tests cannot
- More expensive but still manageable

**Top (E2E Tests):**
- Validates complete user workflows
- Expensive and slow
- Necessary but kept minimal

**Ice Cream Cone Anti-Pattern:**

```
      /\
     /  \    ← Inverted: Too many slow E2E tests
    /E2E \      = Slow feedback
   / (50%)\     = High maintenance
  /--------\    = Flaky test suite
 /          \
 /Integration\  ← Underutilized
/   (20%)    \
/--------------\
/   Unit       \ ← Neglected
/   (30%)       \ = Missed defect isolation
/----------------\ = Poor test coverage
```

## Unit Tests (70-80%)

### Characteristics

Unit tests verify the smallest testable parts of an application in isolation.

**Definition:**
```yaml
Unit Test:
  scope: Single function, method, or class
  dependencies: Mocked or stubbed
  execution_time: < 1 second each
  test_suite_time: < 5 minutes (full suite)
  environment: Same as development (no special setup)
```

**Key Attributes:**
- **Isolated**: Tests one thing at a time
- **Fast**: Run in milliseconds
- **Deterministic**: Same result every time
- **Independent**: No dependencies on other tests
- **Readable**: Clear what is being tested and why

### When to Use Unit Tests

**Ideal For:**
- Business logic validation
- Algorithm verification
- Data transformation validation
- Edge case and boundary testing
- Error handling verification
- Private/internal method behavior

**Not Ideal For:**
- Database interactions
- External API calls
- UI rendering
- Complex multi-component workflows

### Unit Test Example

```typescript
// System under test
class PriceCalculator {
  calculateSubtotal(items: CartItem[]): number {
    return items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  }

  calculateDiscount(subtotal: number, discountPercent: number): number {
    if (discountPercent < 0 || discountPercent > 100) {
      throw new Error("Invalid discount percentage");
    }
    return subtotal * (discountPercent / 100);
  }

  calculateTax(subtotal: number, taxRate: number): number {
    return subtotal * (taxRate / 100);
  }

  calculateTotal(subtotal: number, discount: number, tax: number): number {
    return subtotal - discount + tax;
  }
}

// Unit tests
describe("PriceCalculator", () => {
  let calculator: PriceCalculator;

  beforeEach(() => {
    calculator = new PriceCalculator();
  });

  describe("calculateSubtotal", () => {
    it("should calculate subtotal for multiple items", () => {
      const items = [
        { price: 10, quantity: 2 },
        { price: 5, quantity: 3 }
      ];
      expect(calculator.calculateSubtotal(items)).toBe(35);
    });

    it("should return zero for empty cart", () => {
      expect(calculator.calculateSubtotal([])).toBe(0);
    });

    it("should handle zero quantity items", () => {
      const items = [
        { price: 10, quantity: 0 },
        { price: 5, quantity: 1 }
      ];
      expect(calculator.calculateSubtotal(items)).toBe(5);
    });
  });

  describe("calculateDiscount", () => {
    it("should calculate discount correctly", () => {
      expect(calculator.calculateDiscount(100, 20)).toBe(20);
    });

    it("should throw error for negative discount", () => {
      expect(() => calculator.calculateDiscount(100, -5))
        .toThrow("Invalid discount percentage");
    });

    it("should throw error for discount over 100%", () => {
      expect(() => calculator.calculateDiscount(100, 150))
        .toThrow("Invalid discount percentage");
    });

    it("should handle zero discount", () => {
      expect(calculator.calculateDiscount(100, 0)).toBe(0);
    });
  });

  describe("calculateTotal", () => {
    it("should calculate total with discount and tax", () => {
      const subtotal = 100;
      const discount = 10;
      const tax = 8;
      expect(calculator.calculateTotal(subtotal, discount, tax)).toBe(98);
    });
  });
});
```

### Unit Test Anti-Patterns

```typescript
// ANTI-PATTERN: Testing multiple things
describe("Bad example", () => {
  it("tests everything at once", () => {
    // Creates user, logs in, makes purchase, sends email
    // This is NOT a unit test!
  });
});

// ANTI-PATTERN: Testing implementation details
describe("Bad example", () => {
  it("uses private variable directly", () => {
    expect((calculator as any).internalCache).toEqual([]);
  });
});

// ANTI-PATTERN: Brittle test coupling
describe("Bad example", () => {
  it("depends on exact array ordering", () => {
    expect(result.items[0].name).toBe("First");
    expect(result.items[1].name).toBe("Second");
    // Breaks if order changes
  });
});
```

## Integration Tests (10-20%)

### Characteristics

Integration tests verify that different components or services work together correctly.

**Definition:**
```yaml
Integration Test:
  scope: Multiple components or services
  dependencies: Real or in-memory substitutes
  execution_time: 1-10 seconds each
  test_suite_time: 5-30 minutes
  environment: Dedicated test environment
```

**Key Attributes:**
- **Real Dependencies**: Uses actual database, message queue, or external services
- **Focused Scope**: Tests specific integration points, not entire system
- **Environment Isolation**: Runs in controlled test environment
- **Data Management**: Sets up and tears down test data

### When to Use Integration Tests

**Ideal For:**
- Database interaction validation
- API contract verification
- Message queue integration
- Cache layer behavior
- Service-to-service communication
- Data persistence and retrieval
- Third-party integrations

**Not Ideal For:**
- Simple business logic (use unit tests)
- Complete user journeys (use E2E tests)
- UI validation (use component/E2E tests)

### Integration Test Example

```typescript
// Integration test for user repository with real database
describe("UserRepository Integration", () => {
  let repository: UserRepository;
  let testDatabase: TestDatabase;

  beforeAll(async () => {
    testDatabase = await TestDatabase.create();
    repository = new UserRepository(testDatabase.connection);
  });

  afterAll(async () => {
    await testDatabase.cleanup();
  });

  beforeEach(async () => {
    await testDatabase.migrate();
    await testDatabase.seed("test-users");
  });

  afterEach(async () => {
    await testDatabase.truncateAll();
  });

  describe("createUser", () => {
    it("should create user with hashed password", async () => {
      const userData = {
        email: "test@example.com",
        password: "plain-text-password",
        name: "Test User"
      };

      const user = await repository.create(userData);

      expect(user.id).toBeDefined();
      expect(user.email).toBe(userData.email);
      expect(user.password).not.toBe(userData.password); // Hashed
      expect(user.createdAt).toBeInstanceOf(Date);
    });

    it("should enforce unique email constraint", async () => {
      const userData = {
        email: "test@example.com",
        password: "password123",
        name: "Test User"
      };

      await repository.create(userData);

      await expect(repository.create(userData))
        .rejects.toThrow("Duplicate email");
    });
  });

  describe("findByEmail", () => {
    it("should return user by email", async () => {
      await repository.create({
        email: "test@example.com",
        password: "hashed",
        name: "Test User"
      });

      const user = await repository.findByEmail("test@example.com");

      expect(user).toBeDefined();
      expect(user?.email).toBe("test@example.com");
    });

    it("should return null for non-existent email", async () => {
      const user = await repository.findByEmail("nonexistent@example.com");
      expect(user).toBeNull();
    });
  });

  describe("updatePassword", () => {
    it("should update password with new hash", async () => {
      const user = await repository.create({
        email: "test@example.com",
        password: "old-password",
        name: "Test User"
      });

      await repository.updatePassword(user.id, "new-password");

      const updated = await repository.findById(user.id);
      expect(updated?.password).not.toBe("new-password"); // Hashed
      expect(updated?.password).not.toBe(user.password); // Changed
    });
  });
});
```

### Integration Test Anti-Patterns

```typescript
// ANTI-PATTERN: Testing too many integrations at once
describe("Bad integration test", () => {
  it("tests database, cache, message queue, and external API together", () => {
    // Where did the failure occur? Impossible to tell!
  });
});

// ANTI-PATTERN: Using production resources
describe("Bad integration test", () => {
  it("connects to production database", () => {
    // NEVER DO THIS - could corrupt production data!
  });
});

// ANTI-PATTERN: Shared state between tests
describe("Bad integration test", () => {
  it("depends on data from previous test", () => {
    // Tests should be independent
  });
});
```

## E2E Tests (2-5%)

### Characteristics

End-to-End tests validate complete user workflows through the entire application stack.

**Definition:**
```yaml
E2E Test:
  scope: Complete user workflows
  dependencies: Full system running
  execution_time: 10-60 seconds each
  test_suite_time: 30-120 minutes
  environment: Staging or production-like environment
```

**Key Attributes:**
- **User Perspective**: Simulates real user behavior
- **Full Stack**: Tests UI, API, database, and external services
- **Critical Paths**: Focuses on important business workflows
- **High Maintenance**: Most expensive to maintain

### When to Use E2E Tests

**Ideal For:**
- Critical business workflows (checkout, login, sign-up)
- Happy path user journeys
- Cross-system integration validation
- Production smoke tests
- Regression prevention for high-risk areas

**Not Ideal For:**
- Edge cases and error conditions (use lower-level tests)
- Every possible user scenario
- Business logic validation (use unit tests)
- UI component variations (use component tests)

### E2E Test Example

```typescript
// E2E test using Playwright
import { test, expect } from '@playwright/test';

test.describe('Checkout Flow', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to site
    await page.goto('https://shop.example.com');
  });

  test('complete purchase as guest user', async ({ page }) => {
    // Add item to cart
    await page.click('[data-testid="product-1"]');
    await page.click('[data-testid="add-to-cart"]');
    await page.click('[data-testid="cart-icon"]');

    // Verify cart
    await expect(page.locator('[data-testid="cart-item"]')).toHaveCount(1);

    // Proceed to checkout
    await page.click('[data-testid="checkout-button"]');

    // Enter shipping information
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="firstName"]', 'Test');
    await page.fill('[name="lastName"]', 'User');
    await page.fill('[name="address"]', '123 Test St');
    await page.fill('[name="city"]', 'Test City');
    await page.fill('[name="postalCode"]', '12345');
    await page.selectOption('[name="country"]', 'US');

    // Continue to payment
    await page.click('[data-testid="continue-to-payment"]');

    // Enter payment details (test card)
    await page.fill('[name="cardNumber"]', '4242424242424242');
    await page.fill('[name="expiry"]', '12/25');
    await page.fill('[name="cvc"]', '123');

    // Place order
    await page.click('[data-testid="place-order"]');

    // Verify order confirmation
    await expect(page.locator('[data-testid="order-confirmation"]'))
      .toBeVisible();
    await expect(page.locator('[data-testid="order-number"]'))
      .toContainText(/ORD-\d+/);

    // Verify email was sent (via API check)
    const orderNumber = await page.textContent('[data-testid="order-number"]');
    await expect(orderConfirmationEmailSent(orderNumber)).toBeTruthy();
  });

  test('apply discount code during checkout', async ({ page }) => {
    // Add item and go to cart
    await page.click('[data-testid="product-1"]');
    await page.click('[data-testid="add-to-cart"]');
    await page.click('[data-testid="cart-icon"]');

    // Apply discount code
    await page.click('[data-testid="discount-code-toggle"]');
    await page.fill('[name="discountCode"]', 'SAVE20');
    await page.click('[data-testid="apply-discount"]');

    // Verify discount applied
    await expect(page.locator('[data-testid="discount-amount"]'))
      .toContainText('20%');
    await expect(page.locator('[data-testid="total-amount"]'))
      .not.toHaveText('$100.00'); // Original price
  });
});
```

### E2E Test Anti-Patterns

```typescript
// ANTI-PATTERN: Testing every permutation
test('all possible checkout combinations', async ({ page }) => {
  // Tests every product, every payment method, every shipping option
  // Results in 1000+ slow, flaky tests
});

// ANTI-PATTERN: Testing business logic
test('calculates discount correctly', async ({ page }) => {
  // This should be a unit test!
  // E2E tests should verify behavior, not calculations
});

// ANTI-PATTERN: Brittle selectors
test('uses internal classes', async ({ page }) => {
  await page.click('.css-1a2b3c'); // Will break on any CSS change
  // Use data-testid or user-facing selectors instead
});

// ANTI-PATTERN: No cleanup
test('leaves test data in system', async ({ page }) => {
  // Creates user but doesn't clean up
  // Subsequent tests may fail due to data conflicts
});
```

## How to Balance the Pyramid

### Assessment Template

Use this template to assess your current test distribution:

```yaml
Test Balance Assessment:

  Current State:
    unit_tests:
      total: 150
      execution_time: "2 minutes"
      coverage: "65%"
    integration_tests:
      total: 80
      execution_time: "15 minutes"
      coverage: "40%"
    e2e_tests:
      total: 50
      execution_time: "45 minutes"
      coverage: "N/A"

  Analysis:
    unit_percentage: "54%" # Target: 70-80%
    integration_percentage: "29%" # Target: 10-20%
    e2e_percentage: "18%" # Target: 2-5%

  Recommendations:
    - Add more unit tests for business logic
    - Reduce E2E tests to critical workflows only
    - Consolidate redundant integration tests
    - Increase unit test coverage to 80%+
```

### Balancing Strategies

**When Unit Tests Are Too Low (<70%):**
1. Identify business logic tested at higher levels
2. Extract and create unit tests
3. Remove redundant higher-level tests
4. Set coverage goals for new code

**When Integration Tests Are Too High (>20%):**
1. Identify integration tests that don't need real dependencies
2. Convert to unit tests with mocks
3. Combine related integration tests
4. Use in-memory alternatives where possible

**When E2E Tests Are Too High (>5%):**
1. Identify E2E tests not covering critical workflows
2. Convert to component or integration tests
3. Remove duplicate test coverage
4. Focus on happy paths only

### Migration Path

```yaml
Phase 1: Assessment (1 week)
  - Catalog all existing tests
  - Categorize by type
  - Calculate current distribution
  - Identify improvement opportunities

Phase 2: Foundation (2-4 weeks)
  - Establish unit test standards
  - Create page objects/component abstractions
  - Set up test data management
  - Configure CI/CD pipelines

Phase 3: Building Out (4-8 weeks)
  - Write unit tests for new features (80%+ target)
  - Create integration tests for critical paths
  - Implement minimal E2E test suite
  - Incrementally convert existing tests

Phase 4: Optimization (ongoing)
  - Regularly review test distribution
  - Remove redundant tests
  - Optimize slow tests
  - Maintain pyramid balance
```

## Examples and Anti-Patterns

### Example: Well-Balanced Test Suite

```yaml
E-commerce Application:

  Unit Tests (75%):
    - Price calculation logic
    - Discount validation
    - Tax computation
    - Cart item management
    - Validation functions
    - Data transformers
    - 150 tests, 3 minutes execution

  Integration Tests (18%):
    - Database operations (User, Product, Order repositories)
    - Payment gateway integration
    - Email service integration
    - Cart persistence
    - Order creation flow
    - 35 tests, 12 minutes execution

  E2E Tests (7%):
    - Guest checkout (happy path)
    - Registered user checkout
    - Login/logout flow
    - Product search and add to cart
    - Password reset flow
    - Production smoke tests
    - 14 tests, 25 minutes execution

  Total: 199 tests, ~40 minutes full suite
  Fast feedback: Unit tests in 3 minutes
```

### Anti-Pattern: Unbalanced Test Suite

```yaml
E-commerce Application - Bad Example:

  Unit Tests (20%):
    - Minimal coverage
    - 40 tests, 1 minute

  Integration Tests (30%):
    - Testing everything together
    - Many could be unit tests
    - 60 tests, 25 minutes

  E2E Tests (50%):
    - Testing every combination
    - Testing business logic
    - Testing edge cases
    - 100 tests, 180 minutes

  Total: 200 tests, ~206 minutes full suite
  Problems:
    - Slow feedback loop
    - High maintenance burden
    - Flaky test suite
    - Expensive to run
```

### Decision Matrix

| Test Scenario | Unit | Integration | E2E |
|---------------|------|-------------|-----|
| Business logic calculation | ✅ | ❌ | ❌ |
| Database query validation | ❌ | ✅ | ❌ |
| API contract verification | ❌ | ✅ | ❌ |
| Component interaction | ❌ | ✅ | Maybe |
| Critical user workflow | ❌ | Maybe | ✅ |
| UI validation | ❌ | ✅ (component) | Maybe |
| Performance testing | ❌ | ✅ | ✅ |
| Security testing | ❌ | ✅ | Maybe |

## Best Practices Summary

1. **Start at the base** - Write unit tests first, then add higher-level tests only when needed
2. **Test at the lowest level possible** - If a unit test can verify it, don't use integration/E2E
3. **Keep tests fast** - Faster tests mean faster feedback and more frequent execution
4. **Minimize duplication** - Don't test the same behavior at multiple levels
5. **Focus E2E on happy paths** - Save edge cases for lower-level tests
6. **Mock external dependencies** - Keep tests isolated and reliable
7. **Review and prune** - Regularly remove redundant or unnecessary tests
8. **Measure and monitor** - Track test distribution and execution times
9. **Balance for your context** - Adjust proportions based on system complexity
10. **Maintain the pyramid** - Treat the pyramid as a living guideline, not a rigid rule
