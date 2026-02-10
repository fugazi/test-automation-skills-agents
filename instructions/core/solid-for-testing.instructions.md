---
description: 'SOLID principles applied specifically to test automation code, ensuring maintainable, scalable, and robust test suites'
version: '1.0.0'
category: 'core'
applies-to:
  agents: ['*']
  skills: ['*']
priority: 'mandatory'
compliance:
  must-follow: [
    'Each test should verify one specific behavior or assertion',
    'Page objects and test utilities should be extensible without modification',
    'Test data factories should follow consistent interfaces',
    'Test utilities should have focused, single-purpose interfaces',
    'Tests should depend on abstractions, not concrete implementations'
  ]
  should-follow: [
    'Use composition over inheritance in test helpers',
    'Create focused page object methods that do one thing well',
    'Implement test data builders for complex object creation',
    'Separate test logic from test data management',
    'Apply dependency injection for external service dependencies'
  ]
  can-ignore: [
    'Simple smoke tests that combine multiple verifications for speed',
    'Legacy test suites during gradual refactoring efforts',
    'One-off scripts or temporary validation tests'
  ]
---

# SOLID for Testing

## Purpose and Scope

SOLID principles, originally designed for production code, are equally valuable in test automation. This document adapts each principle to the testing context, providing practical guidance for creating maintainable, scalable, and robust test suites.

## Overview

```yaml
SOLID Principles for Testing:

  S - Single Responsibility Principle
      "Each test should have one reason to fail"

  O - Open/Closed Principle
      "Test code should be open for extension, closed for modification"

  L - Liskov Substitution Principle
      "Test data and fixtures should be substitutable without breaking tests"

  I - Interface Segregation Principle
      "Test utilities should not depend on methods they don't use"

  D - Dependency Inversion Principle
      "Tests should depend on abstractions, not concrete implementations"
```

## Single Responsibility Principle (SRP)

### Definition for Testing

**A test method should verify only one specific behavior.**

In test automation, SRP means:
- Each test validates one thing
- Each test class/fixture focuses on one feature
- Each test helper performs one specific action
- Failure reasons are clear and unambiguous

### Why It Matters for Tests

```yaml
Benefits:
  - Clear failure diagnosis: Know exactly what broke
  - Faster debugging: Isolated failures
  - Better test reports: Precise failure descriptions
  - Easier maintenance: Changes affect fewer tests
  - Reliable flaky test detection: Can identify patterns

Violation Consequences:
  - Cascading failures: One break causes multiple test failures
  - Confusing reports: "Test failed but why?"
  - Longer debugging: Which assertion caused the failure?
  - Brittle tests: Changes break many tests
```

### Good Example: Single Responsibility

```typescript
// GOOD: Each test verifies one specific behavior
describe("User Registration", () => {
  describe("Email Validation", () => {
    it("should accept valid email format", () => {
      const result = validateEmail("user@example.com");
      expect(result.isValid).toBe(true);
    });

    it("should reject email without domain", () => {
      const result = validateEmail("user@");
      expect(result.isValid).toBe(false);
      expect(result.error).toBe("Invalid domain");
    });

    it("should reject email without @ symbol", () => {
      const result = validateEmail("userexample.com");
      expect(result.isValid).toBe(false);
    });
  });

  describe("Password Strength", () => {
    it("should accept strong password", () => {
      const result = validatePassword("Str0ng!Pass");
      expect(result.isValid).toBe(true);
      expect(result.strength).toBe("strong");
    });

    it("should reject weak password", () => {
      const result = validatePassword("weak");
      expect(result.isValid).toBe(false);
      expect(result.error).toContain("at least 8 characters");
    });
  });

  describe("Duplicate Email Check", () => {
    it("should check if email already exists", async () => {
      await createUser({ email: "existing@example.com" });
      const exists = await emailExists("existing@example.com");
      expect(exists).toBe(true);
    });
  });
});
```

### Bad Example: Violating SRP

```typescript
// BAD: One test doing too many things
describe("User Registration", () => {
  it("should validate email, password, and check duplicates", async () => {
    // This test verifies THREE different things
    const emailResult = validateEmail("user@example.com");
    expect(emailResult.isValid).toBe(true);

    const passwordResult = validatePassword("weak");
    expect(passwordResult.isValid).toBe(false);

    await createUser({ email: "test@example.com" });
    const exists = await emailExists("test@example.com");
    expect(exists).toBe(true);
  });

  // Problems:
  // - If email validation breaks, password test doesn't run
  // - Failure message doesn't indicate which assertion failed
  // - Can't run password validation independently
  // - Test name doesn't reflect all assertions
});
```

### SRP for Test Helpers

```typescript
// GOOD: Focused, single-purpose helpers
class LoginPage {
  navigateToLogin(): void {
    cy.visit("/login");
  }

  enterEmail(email: string): void {
    cy.get("[data-testid=email-input]").type(email);
  }

  enterPassword(password: string): void {
    cy.get("[data-testid=password-input]").type(password);
  }

  clickLoginButton(): void {
    cy.get("[data-testid=login-button]").click();
  }
}

// Each method does one thing, tests can compose them
const loginPage = new LoginPage();
loginPage.navigateToLogin();
loginPage.enterEmail("user@example.com");
loginPage.enterPassword("password");
loginPage.clickLoginButton();

// BAD: One method doing everything
class LoginPage {
  login(email: string, password: string): void {
    cy.visit("/login");
    cy.get("[data-testid=email-input]").type(email);
    cy.get("[data-testid=password-input]").type(password);
    cy.get("[data-testid=login-button]").click();
  }
}

// Problems:
// - Can't reuse individual steps
// - Can't test navigation separately
// - Forces all tests to follow exact same flow
// - Hard to add variations (e.g., remember me)
```

## Open/Closed Principle (OCP)

### Definition for Testing

**Test code should be open for extension but closed for modification.**

In test automation, OCP means:
- Add new test cases without modifying existing test code
- Extend page objects and helpers without changing them
- Create new test data scenarios without editing factories
- Support new environments/configurations through extension

### Why It Matters for Tests

```yaml
Benefits:
  - Safer additions: New tests don't risk breaking existing tests
  - Faster onboarding: New testers add tests without understanding all internals
  - Parallel development: Multiple teams extend test suite independently
  - Stable foundation: Core test infrastructure changes less frequently

Violation Consequences:
  - Fragile tests: Adding tests breaks existing tests
  - Merge conflicts: Frequent changes to shared test code
  - Regression in tests: New features break old tests
```

### Good Example: Extensible Page Object

```typescript
// GOOD: Base page object that can be extended
class BasePage {
  constructor(protected page: Page) {}

  async clickElement(selector: string): Promise<void> {
    await this.page.click(selector);
  }

  async fillInput(selector: string, value: string): Promise<void> {
    await this.page.fill(selector, value);
  }

  async waitForSelector(selector: string): Promise<void> {
    await this.page.waitForSelector(selector);
  }

  async getText(selector: string): Promise<string> {
    return await this.page.textContent(selector) || "";
  }
}

// Extended without modifying base
class LoginPage extends BasePage {
  private readonly selectors = {
    email: "[data-testid=email-input]",
    password: "[data-testid=password-input]",
    submit: "[data-testid=login-button]",
    error: "[data-testid=error-message]"
  };

  async enterEmail(email: string): Promise<void> {
    await this.fillInput(this.selectors.email, email);
  }

  async enterPassword(password: string): Promise<void> {
    await this.fillInput(this.selectors.password, password);
  }

  async submit(): Promise<void> {
    await this.clickElement(this.selectors.submit);
  }

  async getErrorMessage(): Promise<string> {
    return await this.getText(this.selectors.error);
  }

  // Additional methods for this specific page
  async loginWithRememberMe(email: string, password: string): Promise<void> {
    await this.enterEmail(email);
    await this.enterPassword(password);
    await this.clickElement("[data-testid=remember-me]");
    await this.submit();
  }
}

// Another page extending BasePage independently
class CheckoutPage extends BasePage {
  // Adds its own functionality
  // No changes needed to BasePage or LoginPage
}
```

### Bad Example: Modification Required

```typescript
// BAD: Page object that requires modification
class LoginPage {
  async login(email: string, password: string): Promise<void> {
    await this.page.fill("[data-testid=email-input]", email);
    await this.page.fill("[data-testid=password-input]", password);
    await this.page.click("[data-testid=login-button]");
  }

  // Every new login variation requires editing this class
  async loginWithRememberMe(email: string, password: string): Promise<void> {
    await this.page.fill("[data-testid=email-input]", email);
    await this.page.fill("[data-testid=password-input]", password);
    await this.page.click("[data-testid=remember-me]");
    await this.page.click("[data-testid=login-button]");
  }

  async loginWithSocial(provider: string): Promise<void> {
    // Now we're modifying this class again
    await this.page.click(`[data-testid=${provider}-login]`);
  }

  // Problems:
  // - Class grows indefinitely
  // - Each change risks breaking existing methods
  // - Hard to maintain
  // - Violates SRP too
}
```

### Extensible Test Data

```typescript
// GOOD: Extensible test data builder
class UserTestData {
  private data: UserData = {
    email: "test@example.com",
    password: "Test123!",
    firstName: "Test",
    lastName: "User",
    country: "US"
  };

  withEmail(email: string): this {
    this.data.email = email;
    return this;
  }

  withPassword(password: string): this {
    this.data.password = password;
    return this;
  }

  withCountry(country: string): this {
    this.data.country = country;
    return this;
  }

  build(): UserData {
    return { ...this.data };
  }
}

// Extend for specific scenarios
class AdminUserBuilder extends UserTestData {
  constructor() {
    super();
    this.withEmail("admin@example.com")
        .withPassword("Admin123!");
  }

  withPermissions(permissions: string[]): this {
    (this.data as any).permissions = permissions;
    return this;
  }
}

// Usage
const standardUser = new UserTestData().build();
const germanUser = new UserTestData().withCountry("DE").build();
const adminUser = new AdminUserBuilder()
  .withPermissions(["read", "write", "delete"])
  .build();
```

## Liskov Substitution Principle (LSP)

### Definition for Testing

**Test data and fixtures should be substitutable without breaking tests.**

In test automation, LSP means:
- Any test data object can be replaced with a subtype
- Mock implementations can replace real implementations
- Different test environments are interchangeable
- Test doubles honor their contracts

### Why It Matters for Tests

```yaml
Benefits:
  - Flexible test data: Use various data sources interchangeably
  - Environment portability: Tests run anywhere
  - Reliable mocking: Mocks behave like real dependencies
  - Test inheritance: Base tests work with derived fixtures

Violation Consequences:
  - Tests pass with mocks but fail with real implementations
  - Test data works locally but fails in CI
  - Inconsistent behavior across environments
```

### Good Example: Substitutable Test Data

```typescript
// GOOD: Base user data that can be substituted
interface IUserData {
  getEmail(): string;
  getPassword(): string;
  isValid(): boolean;
}

class StandardUser implements IUserData {
  constructor(
    private email: string,
    private password: string
  ) {}

  getEmail(): string {
    return this.email;
  }

  getPassword(): string {
    return this.password;
  }

  isValid(): boolean {
    return this.email.includes("@") && this.password.length >= 8;
  }
}

class AdminUser extends StandardUser {
  constructor(email: string, password: string, private role: string = "admin") {
    super(email, password);
  }

  isValid(): boolean {
    return super.isValid() && this.role === "admin";
  }
}

class GuestUser implements IUserData {
  getEmail(): string {
    return "guest@example.com";
  }

  getPassword(): string {
    return "guest123";
  }

  isValid(): boolean {
    return true;
  }
}

// Tests work with any user type
describe("User Login", () => {
  const testLogin = async (user: IUserData) => {
    const loginPage = new LoginPage(page);
    await loginPage.login(user.getEmail(), user.getPassword());
    expect(await loginPage.isLoggedIn()).toBe(true);
  };

  it("should login as standard user", async () => {
    await testLogin(new StandardUser("user@example.com", "password123"));
  });

  it("should login as admin user", async () => {
    await testLogin(new AdminUser("admin@example.com", "admin123"));
  });

  it("should login as guest user", async () => {
    await testLogin(new GuestUser());
  });
});
```

### Bad Example: Breaking Substitution

```typescript
// BAD: AdminUser breaks the contract
class AdminUser extends StandardUser {
  login(): Promise<void> {
    // Different signature - breaks substitution
    // Now tests can't use AdminUser interchangeably
  }

  isValid(): boolean {
    // Throws exception instead of returning boolean
    throw new Error("Admin validation requires special handling");
  }
}

// Problems:
// - Tests using StandardUser break with AdminUser
// - Can't use polymorphism
// - Requires special handling for different types
```

### LSP for Test Environments

```typescript
// GOOD: Interchangeable environment configurations
interface ITestEnvironment {
  getBaseUrl(): string;
  getDatabaseUrl(): string;
  setup(): Promise<void>;
  teardown(): Promise<void>;
}

class LocalEnvironment implements ITestEnvironment {
  getBaseUrl(): string {
    return "http://localhost:3000";
  }

  getDatabaseUrl(): string {
    return "postgresql://localhost:5432/test_db";
  }

  async setup(): Promise<void> {
    await startLocalServices();
  }

  async teardown(): Promise<void> {
    await cleanupLocalServices();
  }
}

class CIEnvironment implements ITestEnvironment {
  getBaseUrl(): string {
    return process.env.TEST_BASE_URL || "http://test-app:8080";
  }

  getDatabaseUrl(): string {
    return process.env.TEST_DATABASE_URL || "";
  }

  async setup(): Promise<void> {
    await deployTestApp();
    await migrateDatabase();
  }

  async teardown(): Promise<void> {
    await undeployTestApp();
  }
}

// Tests work with any environment
class TestRunner {
  constructor(private env: ITestEnvironment) {}

  async runTests(): Promise<void> {
    await this.env.setup();
    try {
      // Tests use this.env.getBaseUrl()
      await executeTests(this.env.getBaseUrl());
    } finally {
      await this.env.teardown();
    }
  }
}

// Can easily swap environments
const localRunner = new TestRunner(new LocalEnvironment());
const ciRunner = new TestRunner(new CIEnvironment());
```

## Interface Segregation Principle (ISP)

### Definition for Testing

**Test utilities should not depend on methods they don't use.**

In test automation, ISP means:
- Create focused, specific interfaces for test helpers
- Avoid large, monolithic page object interfaces
- Split test utilities by use case
- Tests only need to know about methods they actually use

### Why It Matters for Tests

```yaml
Benefits:
  - Clearer APIs: Smaller interfaces are easier to understand
  - Loose coupling: Changes affect fewer tests
  - Better discoverability: Easier to find relevant methods
  - Easier mocking: Smaller interfaces are simpler to mock

Violation Consequences:
  - Confusing APIs: Too many methods to sort through
  - Unnecessary dependencies: Tests depend on unused functionality
  - Brittle tests: Changes to unused methods still affect tests
```

### Good Example: Segregated Interfaces

```typescript
// GOOD: Small, focused interfaces
interface ICanNavigate {
  goto(path: string): Promise<void>;
  getCurrentPath(): Promise<string>;
}

interface ICanSearch {
  search(query: string): Promise<void>;
  getSearchResults(): Promise<SearchResult[]>;
}

interface ICanAddToCart {
  addToCart(productId: string): Promise<void>;
  getCartCount(): Promise<number>;
}

interface ICanCheckout {
  beginCheckout(): Promise<void>;
  completePayment(details: PaymentDetails): Promise<void>;
}

// Page implements multiple specific interfaces
class ProductPage implements ICanNavigate, ICanSearch, ICanAddToCart {
  // Only methods from implemented interfaces
  async goto(path: string): Promise<void> { /* ... */ }
  async getCurrentPath(): Promise<string> { /* ... */ }
  async search(query: string): Promise<void> { /* ... */ }
  async getSearchResults(): Promise<SearchResult[]> { /* ... */ }
  async addToCart(productId: string): Promise<void> { /* ... */ }
  async getCartCount(): Promise<number> { /* ... */ }
}

// Tests depend only on what they need
class SearchTests {
  constructor(private page: ICanSearch) {}

  async testSearch() {
    await this.page.search("laptop");
    const results = await this.page.getSearchResults();
    expect(results.length).toBeGreaterThan(0);
  }
}

class CartTests {
  constructor(private page: ICanAddToCart) {
    // Only depends on cart methods
  }
}
```

### Bad Example: Bloated Interface

```typescript
// BAD: Large interface that forces dependencies
interface IPageObject {
  navigate(): Promise<void>;
  click(selector: string): Promise<void>;
  fill(selector: string, value: string): Promise<void>;
  search(query: string): Promise<void>;
  addToCart(id: string): Promise<void>;
  removeFromCart(id: string): Promise<void>;
  checkout(): Promise<void>;
  pay(details: PaymentDetails): Promise<void>;
  login(credentials: Credentials): Promise<void>;
  logout(): Promise<void>;
  // ... 50 more methods
}

// Tests depend on everything, even unused methods
class SearchTests {
  constructor(private page: IPageObject) {
    // Depends on checkout, payment, auth methods it never uses
  }
}
```

### ISP for Test Fixtures

```typescript
// GOOD: Segregated fixture interfaces
interface IUserFixture {
  createUser(data: UserData): Promise<User>;
  getUser(id: string): Promise<User | null>;
  deleteUser(id: string): Promise<void>;
}

interface IProductFixture {
  createProduct(data: ProductData): Promise<Product>;
  getProduct(id: string): Promise<Product | null>;
  updateStock(id: string, quantity: number): Promise<void>;
}

interface IOrderFixture {
  createOrder(data: OrderData): Promise<Order>;
  getOrder(id: string): Promise<Order | null>;
  cancelOrder(id: string): Promise<void>;
}

// Tests depend only on fixtures they use
describe("Product Management", () => {
  let products: IProductFixture;

  beforeEach(() => {
    products = new ProductFixture();
    // No need for user or order fixtures
  });
});

describe("Order Processing", () => {
  let users: IUserFixture;
  let products: IProductFixture;
  let orders: IOrderFixture;

  beforeEach(() => {
    users = new UserFixture();
    products = new ProductFixture();
    orders = new OrderFixture();
  });
});
```

## Dependency Inversion Principle (DIP)

### Definition for Testing

**Tests should depend on abstractions, not concrete implementations.**

In test automation, DIP means:
- Tests depend on interfaces, not concrete classes
- Test data comes from abstract factories
- External dependencies are injected, not hardcoded
- Page objects implement interfaces for mocking

### Why It Matters for Tests

```yaml
Benefits:
  - Easy mocking: Can inject test doubles
  - Flexible configuration: Swap implementations without test changes
  - Better testability: Tests can control all dependencies
  - Environment independence: Same tests, different implementations

Violation Consequences:
  - Hardcoded dependencies: Difficult to test in isolation
  - Tight coupling: Tests break when implementations change
  - Limited flexibility: Can't easily swap test data sources
```

### Good Example: Dependency Injection

```typescript
// GOOD: Tests depend on abstractions
interface IEmailService {
  sendEmail(to: string, subject: string, body: string): Promise<void>;
}

interface IUserRepository {
  create(user: UserData): Promise<User>;
  findByEmail(email: string): Promise<User | null>;
}

// System under test depends on interfaces
class UserRegistrationService {
  constructor(
    private userRepository: IUserRepository,
    private emailService: IEmailService
  ) {}

  async register(data: UserData): Promise<User> {
    const existing = await this.userRepository.findByEmail(data.email);
    if (existing) {
      throw new Error("User already exists");
    }

    const user = await this.userRepository.create(data);
    await this.emailService.sendEmail(
      user.email,
      "Welcome!",
      "Please verify your email"
    );

    return user;
  }
}

// Tests inject mock implementations
describe("UserRegistrationService", () => {
  let mockRepo: jest.Mocked<IUserRepository>;
  let mockEmail: jest.Mocked<IEmailService>;
  let service: UserRegistrationService;

  beforeEach(() => {
    mockRepo = {
      create: jest.fn(),
      findByEmail: jest.fn()
    };
    mockEmail = {
      sendEmail: jest.fn()
    };
    service = new UserRegistrationService(mockRepo, mockEmail);
  });

  it("should register new user", async () => {
    const userData = { email: "test@example.com", password: "hash" };
    mockRepo.findByEmail.mockResolvedValue(null);
    mockRepo.create.mockResolvedValue({ id: "1", ...userData } as User);

    await service.register(userData);

    expect(mockRepo.create).toHaveBeenCalledWith(userData);
    expect(mockEmail.sendEmail).toHaveBeenCalled();
  });
});
```

### Bad Example: Concrete Dependencies

```typescript
// BAD: Direct dependencies on concrete classes
class UserRegistrationService {
  private userRepository = new PostgreSQLUserRepository();
  private emailService = new SendGridEmailService();

  async register(data: UserData): Promise<User> {
    // Hard to test - real database and email service required
    const existing = await this.userRepository.findByEmail(data.email);
    if (existing) {
      throw new Error("User already exists");
    }

    const user = await this.userRepository.create(data);
    await this.emailService.sendEmail(/* ... */);

    return user;
  }
}

// Problems:
// - Tests need real database connection
// - Tests send real emails
// - Can't inject mocks
// - Slow, unreliable tests
```

### DIP for Page Objects

```typescript
// GOOD: Page objects depend on abstractions
interface IBrowser {
  goto(url: string): Promise<void>;
  fill(selector: string, value: string): Promise<void>;
  click(selector: string): Promise<void>;
  getText(selector: string): Promise<string>;
}

// Can use Playwright, Selenium, or any browser automation
class LoginPage {
  constructor(
    private browser: IBrowser,
    private config: { baseUrl: string }
  ) {}

  async visit(): Promise<void> {
    await this.browser.goto(`${this.config.baseUrl}/login`);
  }

  async login(email: string, password: string): Promise<void> {
    await this.browser.fill("[data-testid=email]", email);
    await this.browser.fill("[data-testid=password]", password);
    await this.browser.click("[data-testid=submit]");
  }
}

// Tests inject any browser implementation
describe("Login", () => {
  let mockBrowser: jest.Mocked<IBrowser>;

  beforeEach(() => {
    mockBrowser = {
      goto: jest.fn(),
      fill: jest.fn(),
      click: jest.fn(),
      getText: jest.fn()
    };
  });

  it("should submit login form", async () => {
    const page = new LoginPage(mockBrowser, { baseUrl: "http://test" });
    await page.login("user@example.com", "password");

    expect(mockBrowser.fill).toHaveBeenCalledWith("[data-testid=email]", "user@example.com");
    expect(mockBrowser.fill).toHaveBeenCalledWith("[data-testid=password]", "password");
    expect(mockBrowser.click).toHaveBeenCalledWith("[data-testid=submit]");
  });
});
```

## Cross-Principle Examples

### Example: Well-Designed Test Suite

```typescript
// Demonstrates all SOLID principles together

// Interface Segregation: Small, focused interfaces
interface ILoginActions {
  enterEmail(email: string): Promise<void>;
  enterPassword(password: string): Promise<void>;
  submit(): Promise<void>;
}

interface ILoginAssertions {
  isLoggedIn(): Promise<boolean>;
  getErrorMessage(): Promise<string>;
}

// Single Responsibility: Each method does one thing
// Open/Closed: Can extend without modifying
// Liskov Substitution: Base class can be substituted
class BasePage {
  constructor(protected page: Page) {}

  protected async click(selector: string): Promise<void> {
    await this.page.click(selector);
  }

  protected async fill(selector: string, value: string): Promise<void> {
    await this.page.fill(selector, value);
  }
}

// Dependency Inversion: Depends on Page abstraction
class LoginPage extends BasePage implements ILoginActions, ILoginAssertions {
  private readonly selectors = {
    email: "[data-testid=email]",
    password: "[data-testid=password]",
    submit: "[data-testid=submit]",
    errorMessage: "[data-testid=error]"
  };

  // SRP: Each method has single responsibility
  async enterEmail(email: string): Promise<void> {
    await this.fill(this.selectors.email, email);
  }

  async enterPassword(password: string): Promise<void> {
    await this.fill(this.selectors.password, password);
  }

  async submit(): Promise<void> {
    await this.click(this.selectors.submit);
  }

  async isLoggedIn(): Promise<boolean> {
    return await this.page.isVisible("[data-testid=dashboard]");
  }

  async getErrorMessage(): Promise<string> {
    return await this.page.textContent(this.selectors.errorMessage) || "";
  }

  // OCP: New functionality via composition, not modification
  async loginWith(credentials: { email: string; password: string }): Promise<void> {
    await this.enterEmail(credentials.email);
    await this.enterPassword(credentials.password);
    await this.submit();
  }
}

// Tests use only what they need (ISP)
describe("Authentication", () => {
  let loginActions: ILoginActions;
  let loginAssertions: ILoginAssertions;

  beforeEach(() => {
    const page = new LoginPage(/* ... */);
    loginActions = page;
    loginAssertions = page;
  });

  it("should login with valid credentials", async () => {
    await loginActions.enterEmail("user@example.com");
    await loginActions.enterPassword("password");
    await loginActions.submit();

    expect(await loginAssertions.isLoggedIn()).toBe(true);
  });

  // DIP: Test data from abstraction
  it("should show error for invalid credentials", async () => {
    const credentials = TestDataProvider.invalidCredentials();
    await loginActions.loginWith(credentials);

    expect(await loginAssertions.isLoggedIn()).toBe(false);
    expect(await loginAssertions.getErrorMessage()).toContain("Invalid");
  });
});
```

### Anti-Pattern: Violating Multiple Principles

```typescript
// BAD: Violates multiple SOLID principles

class BadTestSuite {
  // DIP violation: Hardcoded concrete dependencies
  private db = new PostgreSQLDatabase();
  private api = new RealApiClient();
  private browser = new PuppeteerBrowser();

  // SRP violation: Does everything at once
  async testCompleteUserJourney(): Promise<void> {
    // Setup
    await this.db.connect();
    await this.browser.launch();

    // Multiple unrelated verifications
    await this.testLogin();
    await this.testRegistration();
    await this.testPasswordReset();
    await this.testProfileUpdate();
    await this.testLogout();

    // Cleanup
    await this.db.disconnect();
    await this.browser.close();
  }

  // ISP violation: Tests depend on methods they don't use
  // OCP violation: Adding new tests requires modifying this class
  // LSP violation: Can't substitute implementations
}
```

## Best Practices Summary

1. **One assertion per test** - Follow SRP for clear failure diagnosis
2. **Extend, don't modify** - Apply OCP to page objects and test helpers
3. **Use consistent interfaces** - Follow LSP for test data and environments
4. **Create focused interfaces** - Apply ISP to keep APIs clean and specific
5. **Inject dependencies** - Use DIP for flexible, testable code
6. **Think in layers** - Base abstractions, extended implementations, specific tests
7. **Design for change** - SOLID principles make test suites resilient to changes
8. **Refactor continuously** - Apply these principles as you write and maintain tests
9. **Review test code quality** - Test automation code deserves the same standards as production code
10. **Teach the principles** - Ensure all team members understand and apply SOLID to testing
