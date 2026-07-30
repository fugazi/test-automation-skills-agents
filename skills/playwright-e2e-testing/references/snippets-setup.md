# Snippets: Configuration & Fixtures

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `snippets.md`. See the other `snippets-*.md` files in this folder for related sections.

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
