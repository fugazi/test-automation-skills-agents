# Testing Anti-Patterns Reference

Quick reference for common testing anti-patterns in QA Automation. Use this when reviewing test code, auditing test suites, or generating new tests.

## Table of Contents

- [1. Over-Mocking](#1-over-mocking)
- [2. Testing Implementation Details](#2-testing-implementation-details)
- [3. Shared Mutable State](#3-shared-mutable-state)
- [4. Brittle Selectors](#4-brittle-selectors)
- [5. Hard-Coded Waits](#5-hard-coded-waits)
- [6. Snapshot Abuse](#6-snapshot-abuse)
- [7. Testing Framework Code](#7-testing-framework-code)
- [8. Happy Path Only](#8-happy-path-only)
- [9. POM Without Dependency Injection](#9-pom-without-dependency-injection)
- [10. Mixed Responsibilities in Page Objects](#10-mixed-responsibilities-in-page-objects)
- [11. Test Interdependence](#11-test-interdependence)
- [12. Ignoring CI Environment Differences](#12-ignoring-ci-environment-differences)
- [13. Missing Schema Validation](#13-missing-schema-validation)
- [14. Over-Reliance on Visual Testing](#14-over-reliance-on-visual-testing)

---

## 1. Over-Mocking

**Problem:** Mocking everything creates tests that pass while production breaks. Mocks verify that code calls specific methods, not that the code actually works.

### Bad (TypeScript)

```typescript
// Mocking internal business logic — this tests the mock, not the code
const mockUserService = {
  getUser: jest.fn().mockReturnValue({ id: "1", name: "Test" }),
  validateAccess: jest.fn().mockReturnValue(true),
};

test("user has access", () => {
  expect(mockUserService.validateAccess()).toBe(true); // Always true — meaningless
});
```

### Good (TypeScript)

```typescript
// Test against real API with test database
test("user has access to protected resource", async ({ request }) => {
  // Create real user in test DB
  await request.post("/api/users", { data: { name: "Test", role: "viewer" } });

  // Test real behavior
  const response = await request.get("/api/admin/dashboard");
  expect(response.status()).toBe(403); // viewer can't access admin
});
```

### Bad (Java)

```java
// Over-mocked — tests the mock, not the system
@Mock private UserRepository repo;
@Mock private EmailService email;
@InjectMocks private UserService service;

@Test void createUser() {
    when(repo.save(any())).thenReturn(new User("1", "Test"));
    User result = service.create(new UserDTO("Test"));
    assertEquals("Test", result.getName()); // Always passes — meaningless
}
```

### Good (Java)

```java
// Integration test with real test database
@Test void createUserPersistsToDatabase() {
    UserDTO input = new UserDTO("Test User", "test@example.com");
    User result = userService.create(input);

    // Verify in database
    User saved = userRepository.findById(result.getId());
    assertThat(saved.getName()).isEqualTo("Test User");
    assertThat(saved.getEmail()).isEqualTo("test@example.com");
}
```

**Rule:** Mock only at system boundaries (external APIs, email, payment gateways). Use real implementations for everything else.

---

## 2. Testing Implementation Details

**Problem:** Tests that verify HOW code works internally break when you refactor, even if behavior is unchanged.

### Bad (TypeScript)

```typescript
// Tests internal method calls — breaks on refactor
test("search calls repository with correct query", () => {
  searchService.search("test");
  expect(mockRepo.query).toHaveBeenCalledWith(
    'SELECT * FROM items WHERE name LIKE "%test%"',
  );
});
```

### Good (TypeScript)

```typescript
// Tests the outcome — survives refactors
test("search returns matching items", async () => {
  await itemFactory.create({ name: "Test Item" });
  await itemFactory.create({ name: "Other Item" });

  const results = await searchService.search("Test");
  expect(results).toHaveLength(1);
  expect(results[0].name).toBe("Test Item");
});
```

**Rule:** Assert on inputs and outputs (state), not on method calls (interactions).

---

## 3. Shared Mutable State

**Problem:** Tests that share state pass individually but fail when run together (or vice versa). Order-dependent tests mask real bugs.

### Bad (TypeScript)

```typescript
// Shared state modified by tests
let sharedUser: User;

test("create user", async () => {
  sharedUser = await createUser({ name: "Test" });
});

test("update user", async () => {
  // Depends on previous test creating the user
  await updateUser(sharedUser.id, { name: "Updated" });
});
```

### Good (TypeScript)

```typescript
// Each test sets up its own state
test("update user changes name", async ({ request }) => {
  // Create user within this test
  const create = await request.post("/api/users", {
    data: { name: "Test" },
  });
  const { id } = await create.json();

  const update = await request.put(`/api/users/${id}`, {
    data: { name: "Updated" },
  });
  expect((await update.json()).name).toBe("Updated");
});
```

**Rule:** Each test sets up AND tears down its own state. No test depends on another test's side effects.

---

## 4. Brittle Selectors

**Problem:** CSS selectors and XPath break when developers change styling, class names, or DOM structure.

### Bad (TypeScript)

```typescript
// Breaks when CSS classes change
await page.click("div.sidebar > ul.menu > li:nth-child(3) > a.link");
await page.fill("#login-form > div.input-group:nth-child(2) > input");
```

### Good (TypeScript)

```typescript
// Stable across redesigns
await page.getByRole("link", { name: "Products" }).click();
await page.getByLabel("Email address").fill("test@example.com");
await page.getByTestId("submit-button").click();
```

### Bad (Java)

```java
// Brittle CSS
driver.findElement(By.cssSelector("div.card:nth-child(2) button.primary")).click();
```

### Good (Java)

```java
// Stable locator strategies
driver.findElement(By.id("submit-order")).click();
driver.findElement(By.cssSelector("[data-testid='submit-order']")).click();
```

**Rule:** Prefer `getByRole()` > `getByTestId()` > `getByLabel()` > `getByText()` > CSS selectors. Never use XPath for click/type actions.

---

## 5. Hard-Coded Waits

**Problem:** `Thread.sleep()`, `page.waitForTimeout()`, and fixed waits make tests slow and flaky. They either wait too long (wasting time) or too short (causing failures).

### Bad (TypeScript)

```typescript
await page.waitForTimeout(5000); // Hope the page loads in 5 seconds
await page.click("#submit");
await page.waitForTimeout(2000); // Hope the form submits in 2 seconds
```

### Good (TypeScript)

```typescript
await page.getByRole("button", { name: "Submit" }).click();
await expect(page.getByText("Order confirmed")).toBeVisible(); // Auto-waits
await page.waitForURL("**/orders/**");
```

### Bad (Java)

```java
driver.findElement(By.id("submit")).click();
Thread.sleep(5000); // Hope for the best
String text = driver.findElement(By.id("result")).getText();
```

### Good (Java)

```java
driver.findElement(By.id("submit")).click();
WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("result")));
String text = driver.findElement(By.id("result")).getText();
```

**Rule:** Use auto-waiting (Playwright) or explicit waits (Selenium `WebDriverWait`). Never use fixed-time waits.

---

## 6. Snapshot Abuse

**Problem:** Large snapshots nobody reviews. Any change breaks the snapshot, and developers blindly update without checking.

### Bad (TypeScript)

```typescript
// 200-line snapshot that nobody reads
expect(responseBody).toMatchSnapshot();
```

### Good (TypeScript)

```typescript
// Targeted assertions on specific fields
expect(responseBody.data).toHaveLength(3);
expect(responseBody.data[0]).toMatchObject({
  id: expect.any(String),
  name: "Test Product",
  price: 29.99,
});
```

**Rule:** Use snapshots only for complex, stable structures (API contracts). Assert specific values for everything else. Review EVERY snapshot change.

---

## 7. Testing Framework Code

**Problem:** Writing tests that verify Playwright or Selenium works correctly. This wastes time — framework authors already tested their code.

### Bad (TypeScript)

```typescript
// Testing that Playwright's click works
test("page.click clicks a button", async ({ page }) => {
  await page.setContent('<button id="btn">Click me</button>');
  await page.click("#btn");
  // This tests Playwright, not your application
});
```

### Good (TypeScript)

```typescript
// Testing YOUR application's behavior
test('clicking "Add to Cart" adds item to cart', async ({ page }) => {
  await page.goto("/products/1");
  await page.getByRole("button", { name: "Add to Cart" }).click();
  await expect(page.getByTestId("cart-badge")).toHaveText("1");
});
```

**Rule:** Only test YOUR code and YOUR business logic. Never test framework behavior.

---

## 8. Happy Path Only

**Problem:** Tests only verify the success case. Error states, empty states, loading states, and edge cases go untested.

### Bad (TypeScript)

```typescript
test("login works", async ({ page }) => {
  await page.fill('[name="email"]', "user@test.com");
  await page.fill('[name="password"]', "password123");
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL("/dashboard");
});
// That's the only test — no error cases, no edge cases
```

### Good (TypeScript)

```typescript
test.describe("Login", () => {
  test("successful login redirects to dashboard", async ({ page }) => {
    await page.goto("/login");
    await page.getByLabel("Email").fill("user@test.com");
    await page.getByLabel("Password").fill("password123");
    await page.getByRole("button", { name: "Sign in" }).click();
    await expect(page).toHaveURL("/dashboard");
  });

  test("empty fields show validation errors", async ({ page }) => {
    await page.goto("/login");
    await page.getByRole("button", { name: "Sign in" }).click();
    await expect(page.getByText("Email is required")).toBeVisible();
    await expect(page.getByText("Password is required")).toBeVisible();
  });

  test("wrong credentials show error message", async ({ page }) => {
    await page.goto("/login");
    await page.getByLabel("Email").fill("user@test.com");
    await page.getByLabel("Password").fill("wrongpassword");
    await page.getByRole("button", { name: "Sign in" }).click();
    await expect(page.getByText("Invalid credentials")).toBeVisible();
  });

  test("locked account shows appropriate message", async ({ page }) => {
    await page.goto("/login");
    await page.getByLabel("Email").fill("locked@test.com");
    await page.getByLabel("Password").fill("password123");
    await page.getByRole("button", { name: "Sign in" }).click();
    await expect(page.getByText("Account locked")).toBeVisible();
  });
});
```

**Rule:** For every feature, test: happy path, empty input, invalid input, error responses, and boundary conditions.

---

## 9. POM Without Dependency Injection

**Problem:** Page Objects instantiated with `new` in test files create tight coupling and make tests harder to maintain.

### Bad (TypeScript)

```typescript
// Manual instantiation — tight coupling
test("user can login", async ({ page }) => {
  const loginPage = new LoginPage(page); // Manual new
  const dashboardPage = new DashboardPage(page); // Another manual new
  await loginPage.navigate();
  await loginPage.login("user@test.com", "password");
  await dashboardPage.waitForLoad();
});
```

### Good (TypeScript)

```typescript
// Fixture injection — loose coupling
import { test } from "./fixtures";

test("user can login", async ({ loginPage, dashboardPage }) => {
  await loginPage.navigate();
  await loginPage.login("user@test.com", "password");
  await dashboardPage.waitForLoad();
});
```

### Bad (Java)

```java
// Manual instantiation in test method
@Test void userCanLogin() {
    WebDriver driver = new ChromeDriver(); // Manual setup
    LoginPage loginPage = new LoginPage(driver); // Manual new
    loginPage.login("user@test.com", "password");
}
```

### Good (Java)

```java
// Dependency injection via constructor or test framework
@ExtendWith(SeleniumExtension.class)
@Test void userCanLogin(LoginPage loginPage, DashboardPage dashboardPage) {
    loginPage.login("user@test.com", "password");
    dashboardPage.waitForLoad();
}
```

**Rule:** Never use `new PageObject()` in test files. Use custom fixtures (Playwright) or DI framework (Java) for all Page Object instantiation.

---

## 10. Mixed Responsibilities in Page Objects

**Problem:** Page Objects that handle navigation, interaction, assertion, AND API calls violate Single Responsibility Principle.

### Bad (TypeScript)

```typescript
// God Page Object — does everything
class OrderPage {
  constructor(private page: Page) {}

  async navigateToOrders() {
    /* ... */
  }
  async createOrder(data: OrderData) {
    /* ... */
  }
  async assertOrderVisible(name: string) {
    /* ... */
  }
  async getOrderViaAPI(id: string) {
    /* ... */
  } // API call in a POM?!
  async deleteOrder(id: string) {
    /* ... */
  }
  async getOrderCount() {
    /* ... */
  }
}
```

### Good (TypeScript)

```typescript
// Focused Page Object — only UI interactions
class OrderPage {
  constructor(private page: Page) {}

  // Navigation
  async goto() {
    await this.page.goto("/orders");
  }

  // Interactions only
  async createOrder(data: OrderData) {
    /* ... */
  }
  async deleteOrder(id: string) {
    /* ... */
  }

  // State queries (return data, don't assert)
  async getOrderNames(): Promise<string[]> {
    /* ... */
  }
  async getOrderCount(): Promise<number> {
    /* ... */
  }
}

// Assertions stay in the test or a separate assertion helper
test("order appears after creation", async ({ orderPage }) => {
  await orderPage.createOrder({ item: "Widget", quantity: 2 });
  const names = await orderPage.getOrderNames();
  expect(names).toContain("Widget");
});
```

**Rule:** Page Objects handle interactions and state queries. Assertions belong in tests. API calls belong in API helpers, not UI Page Objects.

---

## 11. Test Interdependence

**Problem:** Tests that must run in a specific order. Test B depends on Test A's side effects.

### Bad

```typescript
// Test 1 creates data that Test 2 uses
let productId: string;

test("1. create product", async ({ request }) => {
  const response = await request.post("/api/products", {
    data: { name: "Widget" },
  });
  productId = (await response.json()).id; // Leaked state
});

test("2. add product to cart", async ({ request }) => {
  // Depends on test 1 — fails if run alone
  const response = await request.post(`/api/cart/add/${productId}`);
});
```

### Good

```typescript
test("add product to cart", async ({ request }) => {
  // Create product within this test
  const product = await request.post("/api/products", {
    data: { name: `Widget-${Date.now()}` },
  });
  const productId = (await product.json()).id;

  const response = await request.post(`/api/cart/add/${productId}`);
  expect(response.status()).toBe(200);

  // Cleanup
  await request.delete(`/api/products/${productId}`);
});
```

**Rule:** Every test must pass when run in isolation. Use unique test data (timestamps, UUIDs) to prevent collisions.

---

## 12. Ignoring CI Environment Differences

**Problem:** Tests pass locally but fail in CI due to different fonts, rendering, timing, or resources.

### Bad

```yaml
# CI workflow with no consideration for browser differences
- run: npx playwright test
```

### Good

```yaml
# CI-optimized Playwright config
- run: npx playwright install --with-deps chromium
- run: npx playwright test --project=chromium
  env:
    CI: true
```

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    retries: process.env.CI ? 2 : 0,
    timeout: process.env.CI ? 30000 : 10000,
  },
});
```

**Common CI differences:**

| Issue       | Local           | CI                         |
| ----------- | --------------- | -------------------------- |
| Fonts       | System fonts    | Minimal fonts (use Docker) |
| Rendering   | GPU-accelerated | Software rendering         |
| Timing      | Fast            | Slower (shared resources)  |
| Screen size | Variable        | Fixed viewport             |
| Network     | Direct          | Behind proxy/NAT           |

**Rule:** Always test in CI. Use Docker for consistent environments. Set `CI=true` for appropriate config overrides.

---

## 13. Missing Schema Validation

**Problem:** API tests check status codes but don't validate response structure. API changes silently break consumers.

### Bad (TypeScript)

```typescript
test("GET /users returns 200", async ({ request }) => {
  const response = await request.get("/api/users");
  expect(response.status()).toBe(200);
  // Response could be ANYTHING — no structure validation
});
```

### Good (TypeScript)

```typescript
import { z } from "zod";

const UserSchema = z.strictObject({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
  role: z.enum(["admin", "user", "viewer"]),
});

test("GET /users returns valid user schemas", async ({ request }) => {
  const response = await request.get("/api/users");
  expect(response.status()).toBe(200);
  const body = await response.json();

  // Every user in the list matches the schema
  for (const user of body.data) {
    UserSchema.parse(user); // Throws if invalid
  }
});
```

### Bad (Java)

```java
@Test void getUsersReturns200() {
    given()
        .header("Authorization", "Bearer " + token)
    .when()
        .get("/api/users")
    .then()
        .statusCode(200); // No structure validation
}
```

### Good (Java)

```java
@Test void getUsersReturnsValidSchema() {
    given()
        .header("Authorization", "Bearer " + token)
    .when()
        .get("/api/users")
    .then()
        .statusCode(200)
        .body("data", is(instanceOf(List.class)))
        .body("data.size()", greaterThan(0))
        .body("data[0].id", matchesPattern(UUID_REGEX))
        .body("data[0].name", not(emptyString()))
        .body("data[0].email", matchesPattern(EMAIL_REGEX))
        .body("data[0].role", is(oneOf("admin", "user", "viewer")));
}
```

**Rule:** Every API response must be validated against a schema. Use Zod (TypeScript) or JSON Schema Validator (Java).

---

## 14. Over-Reliance on Visual Testing

**Problem:** Using screenshot comparison for everything, including content that should be tested with assertions.

### Bad

```typescript
// Screenshot testing what should be a text assertion
test("page shows welcome message", async ({ page }) => {
  await page.goto("/");
  await expect(page).toHaveScreenshot("welcome.png");
  // Breaks on ANY pixel change — font rendering, antialiasing, time of day
});
```

### Good

```typescript
// Use the right tool for the job
test("page shows welcome message", async ({ page }) => {
  await page.goto("/");
  // Text assertion for content
  await expect(page.getByRole("heading", { level: 1 })).toHaveText("Welcome");
});

test("hero layout matches design", async ({ page }) => {
  await page.goto("/");
  // Visual test ONLY for layout/rendering
  await expect(page.getByTestId("hero-section")).toHaveScreenshot("hero.png", {
    maxDiffPixelRatio: 0.01,
    mask: [page.getByTestId("current-date")], // Mask dynamic content
  });
});
```

**Rule:** Use text assertions for content, aria snapshots for structure, and visual testing ONLY for layout/rendering verification.
