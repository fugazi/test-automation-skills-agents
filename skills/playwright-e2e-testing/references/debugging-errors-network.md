# Debugging: Console Errors & Network

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `debugging.md`. See the other `debugging-*.md` files in this folder for related sections.

## Console & Page Errors

### Capture Console Messages

```typescript
test("monitor console", async ({ page }) => {
  const consoleLogs: string[] = [];

  page.on("console", (msg) => {
    consoleLogs.push(`[${msg.type()}] ${msg.text()}`);
  });

  page.on("pageerror", (error) => {
    consoleLogs.push(`[ERROR] ${error.message}`);
  });

  await page.goto("/");

  // Check for errors
  const errors = consoleLogs.filter((log) => log.includes("[error]"));
  expect(errors).toHaveLength(0);
});
```

### Fixture for Auto-Capture

```typescript
// fixtures/debug.fixture.ts
import { test as base, TestInfo } from "@playwright/test";

export const test = base.extend({
  page: async ({ page }, use, testInfo) => {
    const logs: string[] = [];

    page.on("console", (msg) => logs.push(`[${msg.type()}] ${msg.text()}`));
    page.on("pageerror", (err) => logs.push(`[ERROR] ${err.message}`));

    await use(page);

    // Attach logs on failure
    if (testInfo.status !== testInfo.expectedStatus && logs.length) {
      await testInfo.attach("console-logs.txt", {
        body: logs.join("\n"),
        contentType: "text/plain",
      });
    }
  },
});
```

---

## Network Debugging

### Monitor Requests

```typescript
test("debug network", async ({ page }) => {
  const requests: string[] = [];
  const failures: string[] = [];

  page.on("request", (req) => {
    requests.push(`${req.method()} ${req.url()}`);
  });

  page.on("requestfailed", (req) => {
    failures.push(`${req.method()} ${req.url()} - ${req.failure()?.errorText}`);
  });

  page.on("response", (res) => {
    if (!res.ok()) {
      console.log(`HTTP ${res.status()} ${res.url()}`);
    }
  });

  await page.goto("/");

  console.log("Total requests:", requests.length);
  console.log("Failed requests:", failures);
});
```

### Wait for Specific Request

```typescript
test("debug API call", async ({ page }) => {
  // Set up listener before action
  const responsePromise = page.waitForResponse(
    (res) => res.url().includes("/api/data") && res.status() === 200,
  );

  await page.goto("/dashboard");

  const response = await responsePromise;

  // Inspect response
  console.log("Status:", response.status());
  console.log("Headers:", response.headers());
  console.log("Body:", await response.json());
});
```

---
