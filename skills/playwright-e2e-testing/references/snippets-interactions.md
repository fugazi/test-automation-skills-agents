# Snippets: Form Interactions, API & Network

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `snippets.md`. See the other `snippets-*.md` files in this folder for related sections.

## Form Interactions

### Form Submit with Navigation

```typescript
test("login navigates to dashboard", async ({ page }) => {
  await page.goto("/login");

  await page.getByLabel("Email").fill("user@example.com");
  await page.getByLabel("Password").fill("password123");

  // Click and wait for navigation (auto-waiting)
  await page.getByRole("button", { name: "Sign in" }).click();
  await expect(page).toHaveURL(/.*dashboard/);

  await expect(page.getByRole("heading", { name: "Dashboard" })).toBeVisible();
});
```

### Form Submit with API Response Validation

```typescript
test("save profile updates API", async ({ page }) => {
  await page.goto("/settings");

  await page.getByLabel("Display Name").fill("John Doe");

  // Set up response promise before triggering action
  const responsePromise = page.waitForResponse(
    (r) => r.url().includes("/api/profile") && r.request().method() === "PUT",
  );
  await page.getByRole("button", { name: "Save" }).click();
  const response = await responsePromise;

  expect(response.ok()).toBeTruthy();
  const data = await response.json();
  expect(data).toMatchObject({ success: true, name: "John Doe" });
});
```

### Form Validation Errors

```typescript
test("shows validation errors", async ({ page }) => {
  await page.goto("/register");

  // Submit empty form
  await page.getByRole("button", { name: "Register" }).click();

  // Check for validation messages
  await expect(page.getByText("Email is required")).toBeVisible();
  await expect(
    page.getByText("Password must be at least 8 characters"),
  ).toBeVisible();

  // Fix errors and resubmit
  await page.getByLabel("Email").fill("valid@email.com");
  await page.getByLabel("Password").fill("securepassword");
  await page.getByRole("button", { name: "Register" }).click();

  await expect(page.getByText("Email is required")).toBeHidden();
});
```

### Complex Form with Multiple Steps

```typescript
test("multi-step checkout form", async ({ page }) => {
  await page.goto("/checkout");

  await test.step("Step 1: Shipping Info", async () => {
    await page.getByLabel("Full Name").fill("John Doe");
    await page.getByLabel("Address").fill("123 Main St");
    await page.getByLabel("City").fill("Seattle");
    await page.getByRole("combobox", { name: "State" }).selectOption("WA");
    await page.getByLabel("ZIP").fill("98101");
    await page.getByRole("button", { name: "Continue" }).click();
  });

  await test.step("Step 2: Payment", async () => {
    await page.getByLabel("Card Number").fill("4111111111111111");
    await page.getByLabel("Expiry").fill("12/25");
    await page.getByLabel("CVV").fill("123");
    await page.getByRole("button", { name: "Place Order" }).click();
  });

  await test.step("Step 3: Confirmation", async () => {
    await expect(
      page.getByRole("heading", { name: "Order Confirmed" }),
    ).toBeVisible();
    await expect(page.getByText(/Order #\d+/)).toBeVisible();
  });
});
```

---

## API Testing

### API-only Test (No Browser)

```typescript
import { test, expect } from "@playwright/test";

test.describe("API Tests", () => {
  test("GET /api/health returns ok", async ({ request }) => {
    const response = await request.get("/api/health");

    expect(response.ok()).toBeTruthy();
    expect(response.status()).toBe(200);

    const json = await response.json();
    expect(json).toMatchObject({ status: "ok" });
  });

  test("POST /api/users creates user", async ({ request }) => {
    const response = await request.post("/api/users", {
      data: {
        name: "Test User",
        email: "test@example.com",
      },
    });

    expect(response.status()).toBe(201);

    const user = await response.json();
    expect(user).toMatchObject({
      id: expect.any(String),
      name: "Test User",
      email: "test@example.com",
    });
  });

  test("authenticated API request", async ({ request }) => {
    // First, get auth token
    const authResponse = await request.post("/api/auth/login", {
      data: { email: "user@test.com", password: "password" },
    });
    const { token } = await authResponse.json();

    // Use token for authenticated request
    const response = await request.get("/api/profile", {
      headers: { Authorization: `Bearer ${token}` },
    });

    expect(response.ok()).toBeTruthy();
  });
});
```

### UI-Driven API Verification

```typescript
test("verify request body and response", async ({ page }) => {
  await page.goto("/settings");

  await page.getByRole("checkbox", { name: "Marketing emails" }).check();

  // Set up listeners before action
  const requestPromise = page.waitForRequest((r) =>
    r.url().includes("/api/preferences"),
  );
  const responsePromise = page.waitForResponse((r) =>
    r.url().includes("/api/preferences"),
  );

  await page.getByRole("button", { name: "Save" }).click();

  const request = await requestPromise;
  const response = await responsePromise;

  // Verify request
  expect(request.method()).toBe("POST");
  expect(request.postDataJSON()).toMatchObject({ marketingEmails: true });

  // Verify response
  expect(response.ok()).toBeTruthy();
  expect(await response.json()).toMatchObject({ success: true });
});
```

---

## Network Interception

### Mock API Response

```typescript
test("displays mocked data", async ({ page }) => {
  await page.route("**/api/products", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        products: [{ id: "1", name: "Mock Product", price: 99.99 }],
      }),
    });
  });

  await page.goto("/products");

  await expect(page.getByText("Mock Product")).toBeVisible();
  await expect(page.getByText("$99.99")).toBeVisible();
});
```

### Mock Error Response

```typescript
test("handles API error gracefully", async ({ page }) => {
  await page.route("**/api/data", async (route) => {
    await route.fulfill({
      status: 500,
      contentType: "application/json",
      body: JSON.stringify({ error: "Internal Server Error" }),
    });
  });

  await page.goto("/dashboard");

  await expect(page.getByRole("alert")).toContainText("Something went wrong");
  await expect(page.getByRole("button", { name: "Retry" })).toBeVisible();
});
```

### Mock Network Failure

```typescript
test("handles network failure", async ({ page }) => {
  await page.route("**/api/data", async (route) => {
    await route.abort("failed");
  });

  await page.goto("/dashboard");

  await expect(page.getByText("Network error")).toBeVisible();
});
```

### Modify Response (Pass-through with Changes)

```typescript
test("modify API response", async ({ page }) => {
  await page.route("**/api/products", async (route) => {
    const response = await route.fetch();
    const json = await response.json();

    // Apply discount to all products
    json.products = json.products.map((p: any) => ({
      ...p,
      price: p.price * 0.9,
    }));

    await route.fulfill({ response, json });
  });

  await page.goto("/products");
});
```

### Delay Response

```typescript
test("shows loading state", async ({ page }) => {
  await page.route("**/api/data", async (route) => {
    await new Promise((resolve) => setTimeout(resolve, 2000));
    await route.continue();
  });

  await page.goto("/dashboard");

  // Loading state should appear
  await expect(page.getByRole("progressbar")).toBeVisible();

  // Then content loads
  await expect(page.getByRole("progressbar")).toBeHidden();
});
```

---
