# Snippets (Playwright + TypeScript)

Ready-to-use code patterns for Playwright tests. Adapt to your project's conventions.

---

## Table of Contents

- [Configuration](#configuration)
- [Custom Fixtures](#custom-fixtures)
- [Form Interactions](#form-interactions)
- [API Testing](#api-testing)
- [Network Interception](#network-interception)
- [Responsive Testing](#responsive-testing)
- [Authentication](#authentication)
- [Assertions](#assertions)
- [Debugging](#debugging)
- [Utilities](#utilities)

---

## Configuration

### Basic `playwright.config.ts`

```typescript
import { defineConfig, devices } from "@playwright/test";

const PORT = process.env.PORT ? Number(process.env.PORT) : 3000;
const baseURL = process.env.BASE_URL ?? `http://127.0.0.1:${PORT}`;

export default defineConfig({
  testDir: "./tests",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ["html", { open: "never" }],
    ["junit", { outputFile: "test-results/junit.xml" }],
  ],
  use: {
    baseURL,
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },
  webServer: process.env.CI
    ? undefined
    : {
        command: "npm run dev",
        url: baseURL,
        reuseExistingServer: true,
        timeout: 120_000,
      },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    { name: "firefox", use: { ...devices["Desktop Firefox"] } },
    { name: "webkit", use: { ...devices["Desktop Safari"] } },
    { name: "mobile-chrome", use: { ...devices["Pixel 5"] } },
    { name: "mobile-safari", use: { ...devices["iPhone 13"] } },
  ],
});
```

### Config with Authentication Setup

```typescript
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./tests",
  projects: [
    // Setup project for authentication
    { name: "setup", testMatch: /.*\.setup\.ts/ },

    // Tests that need authentication
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        storageState: "playwright/.auth/user.json",
      },
      dependencies: ["setup"],
    },

    // Tests that don't need authentication
    {
      name: "chromium-no-auth",
      use: { ...devices["Desktop Chrome"] },
      testMatch: /.*\.public\.spec\.ts/,
    },
  ],
});
```

---

## Custom Fixtures

### Fixture with Console/Network Logging

```typescript
// tests/fixtures.ts
import { test as base, expect, Page, TestInfo } from "@playwright/test";

interface CaptureArtifacts {
  captureLogs: () => Promise<void>;
}

export const test = base.extend<CaptureArtifacts>({
  captureLogs: async ({ page }, use, testInfo) => {
    const consoleMessages: string[] = [];
    const networkErrors: string[] = [];

    // Capture console messages
    page.on("console", (msg) => {
      consoleMessages.push(`[${msg.type()}] ${msg.text()}`);
    });

    // Capture page errors
    page.on("pageerror", (err) => {
      consoleMessages.push(`[error] ${err.message}`);
    });

    // Capture failed network requests
    page.on("requestfailed", (req) => {
      networkErrors.push(
        `${req.method()} ${req.url()} - ${req.failure()?.errorText ?? "unknown"}`,
      );
    });

    // Capture slow API responses (>1s)
    page.on("response", async (resp) => {
      if (!resp.url().includes("/api/")) return;
      const timing = resp.request().timing();
      if (timing.responseEnd - timing.startTime > 1000) {
        consoleMessages.push(
          `[slow-api] ${resp.url()} took ${timing.responseEnd - timing.startTime}ms`,
        );
      }
    });

    await use(async () => {
      // Attach logs on failure
      if (testInfo.status !== testInfo.expectedStatus) {
        if (consoleMessages.length) {
          await testInfo.attach("console-logs.txt", {
            body: consoleMessages.join("\n"),
            contentType: "text/plain",
          });
        }
        if (networkErrors.length) {
          await testInfo.attach("network-errors.txt", {
            body: networkErrors.join("\n"),
            contentType: "text/plain",
          });
        }
      }
    });
  },
});

export { expect };
```

### Fixture with Auto-Screenshot on Failure

```typescript
// tests/fixtures.ts
import { test as base } from "@playwright/test";

export const test = base.extend({
  page: async ({ page }, use, testInfo) => {
    await use(page);

    // Auto-screenshot on failure
    if (testInfo.status !== testInfo.expectedStatus) {
      await page.screenshot({
        path: `test-results/failures/${testInfo.title.replace(/\s+/g, "-")}.png`,
        fullPage: true,
      });
    }
  },
});
```

---

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

## Responsive Testing

### Multiple Viewports Loop

```typescript
const viewports = [
  { width: 375, height: 667, name: "mobile" },
  { width: 768, height: 1024, name: "tablet" },
  { width: 1280, height: 720, name: "desktop" },
];

for (const vp of viewports) {
  test.describe(`${vp.name} viewport`, () => {
    test.use({ viewport: { width: vp.width, height: vp.height } });

    test("navigation is accessible", async ({ page }) => {
      await page.goto("/");

      if (vp.width < 768) {
        // Mobile: hamburger menu
        const menuButton = page.getByRole("button", { name: /menu/i });
        await expect(menuButton).toBeVisible();
        await menuButton.click();
      }

      await page.getByRole("link", { name: "About" }).click();
      await expect(page).toHaveURL(/about/);
    });
  });
}
```

### Project-based Responsive Testing

```typescript
// In playwright.config.ts projects:
// projects: [
//   { name: 'desktop', use: { viewport: { width: 1280, height: 720 } } },
//   { name: 'mobile', use: { viewport: { width: 375, height: 667 } } },
// ]

// Test file (runs on all projects)
test("layout adapts to viewport", async ({ page }) => {
  await page.goto("/");

  const viewport = page.viewportSize();
  const isMobile = viewport && viewport.width < 768;

  if (isMobile) {
    await expect(page.getByTestId("mobile-nav")).toBeVisible();
    await expect(page.getByTestId("desktop-nav")).toBeHidden();
  } else {
    await expect(page.getByTestId("desktop-nav")).toBeVisible();
    await expect(page.getByTestId("mobile-nav")).toBeHidden();
  }
});
```

---

## Authentication

### Storage State Setup

```typescript
// auth.setup.ts
import { test as setup, expect } from "@playwright/test";

const authFile = "playwright/.auth/user.json";

setup("authenticate", async ({ page }) => {
  await page.goto("/login");
  await page.getByLabel("Email").fill("user@example.com");
  await page.getByLabel("Password").fill("password123");
  await page.getByRole("button", { name: "Sign in" }).click();

  // Wait for auth to complete
  await page.waitForURL("**/dashboard");

  // Save storage state
  await page.context().storageState({ path: authFile });
});
```

### Use Storage State in Tests

```typescript
// tests/authenticated.spec.ts
import { test, expect } from "@playwright/test";

test.use({ storageState: "playwright/.auth/user.json" });

test("access protected page", async ({ page }) => {
  await page.goto("/settings");
  // Already logged in via storage state
  await expect(page.getByRole("heading", { name: "Settings" })).toBeVisible();
});
```

### API Token Authentication

```typescript
// Fixture for API token
import { test as base } from "@playwright/test";

export const test = base.extend<{ apiToken: string }>({
  apiToken: async ({ request }, use) => {
    const response = await request.post("/api/auth/login", {
      data: { email: "api@test.com", password: "password" },
    });
    const { token } = await response.json();
    await use(token);
  },
});

// Use in test
test("authenticated API call", async ({ request, apiToken }) => {
  const response = await request.get("/api/protected", {
    headers: { Authorization: `Bearer ${apiToken}` },
  });
  expect(response.ok()).toBeTruthy();
});
```

---

## Assertions

### Common Web-First Assertions

```typescript
// Visibility
await expect(page.getByRole("button")).toBeVisible();
await expect(page.getByRole("dialog")).toBeHidden();

// Text content
await expect(page.getByRole("heading")).toHaveText("Welcome");
await expect(page.getByRole("heading")).toContainText("Welcome");

// URL
await expect(page).toHaveURL(/.*dashboard/);
await expect(page).toHaveURL("https://example.com/dashboard");

// Input values
await expect(page.getByLabel("Name")).toHaveValue("John");
await expect(page.getByLabel("Name")).toBeEmpty();

// Checkbox/radio state
await expect(page.getByRole("checkbox")).toBeChecked();
await expect(page.getByRole("checkbox")).not.toBeChecked();

// Enabled/disabled
await expect(page.getByRole("button")).toBeEnabled();
await expect(page.getByRole("button")).toBeDisabled();

// Focus
await expect(page.getByLabel("Email")).toBeFocused();

// Count
await expect(page.getByRole("listitem")).toHaveCount(5);

// Attributes
await expect(page.getByRole("link")).toHaveAttribute("href", "/about");

// CSS class
await expect(page.getByRole("button")).toHaveClass(/active/);

// Screenshot comparison
await expect(page).toHaveScreenshot("homepage.png");
await expect(page.getByTestId("chart")).toHaveScreenshot("chart.png");
```

### Soft Assertions

```typescript
test("multiple checks with soft assertions", async ({ page }) => {
  await page.goto("/profile");

  // Soft assertions don't stop the test on failure
  await expect.soft(page.getByText("Name: John")).toBeVisible();
  await expect.soft(page.getByText("Email: john@test.com")).toBeVisible();
  await expect.soft(page.getByText("Role: Admin")).toBeVisible();

  // All failures reported at the end
});
```

### Polling Assertions

```typescript
test("wait for condition", async ({ page }) => {
  await page.goto("/processing");

  // Poll until condition is met
  await expect(async () => {
    const status = await page.getByTestId("status").textContent();
    expect(status).toBe("Complete");
  }).toPass({ timeout: 30000 });
});
```

---

## Debugging

### Debug Commands

```bash
# UI mode (interactive)
npx playwright test --ui

# Debug with Inspector
PWDEBUG=1 npx playwright test

# Run specific test
npx playwright test -g "login flow"

# Headed mode
npx playwright test --headed

# Verbose API logs
DEBUG=pw:api npx playwright test

# View report
npx playwright show-report

# Codegen (record tests)
npx playwright codegen http://localhost:3000
```

### In-Test Debugging

```typescript
test("debug example", async ({ page }) => {
  await page.goto("/");

  // Pause test for manual inspection
  await page.pause();

  // Log to terminal
  console.log("Current URL:", page.url());

  // Screenshot for debugging
  await page.screenshot({ path: "debug.png", fullPage: true });

  // Evaluate in browser console
  const result = await page.evaluate(() => {
    return document.querySelector("h1")?.textContent;
  });
  console.log("H1 text:", result);
});
```

---

## Utilities

### Retry Flaky Operations

```typescript
import { test, expect } from "@playwright/test";

test("retry flaky button click", async ({ page }) => {
  await page.goto("/");

  // Retry until success or timeout
  await expect(async () => {
    await page.getByRole("button", { name: "Submit" }).click();
    await expect(page.getByText("Success")).toBeVisible();
  }).toPass({
    timeout: 10000,
    intervals: [500, 1000, 2000],
  });
});
```

### Wait for Network Idle

```typescript
test("wait for all API calls", async ({ page }) => {
  await page.goto("/dashboard", { waitUntil: "networkidle" });

  // Or wait manually
  await page.waitForLoadState("networkidle");
});
```

### Screenshot with Mask

```typescript
test("screenshot without dynamic elements", async ({ page }) => {
  await page.goto("/");

  await expect(page).toHaveScreenshot("homepage.png", {
    mask: [page.getByTestId("timestamp"), page.getByTestId("random-ad")],
    maxDiffPixels: 100,
  });
});
```

### Trace Viewer

```typescript
// Enable trace in config
// use: { trace: 'on-first-retry' }

// Or manually in test
test("with trace", async ({ page, context }) => {
  await context.tracing.start({ screenshots: true, snapshots: true });

  await page.goto("/");
  await page.getByRole("button", { name: "Submit" }).click();

  await context.tracing.stop({ path: "trace.zip" });
});
```
