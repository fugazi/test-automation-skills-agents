# Debugging Guide

Comprehensive techniques for debugging Playwright tests, investigating failures, and fixing flaky tests.

---

## Debugging Tools Overview

| Tool         | Use Case                           | Command                            |
| ------------ | ---------------------------------- | ---------------------------------- |
| UI Mode      | Interactive debugging, time-travel | `npx playwright test --ui`         |
| Inspector    | Step-by-step debugging             | `PWDEBUG=1 npx playwright test`    |
| Headed Mode  | See browser during test            | `npx playwright test --headed`     |
| Trace Viewer | Post-mortem analysis               | `npx playwright show-report`       |
| Codegen      | Generate locators                  | `npx playwright codegen <url>`     |
| Verbose Logs | API-level debugging                | `DEBUG=pw:api npx playwright test` |

---

## UI Mode (Recommended)

The most powerful debugging tool for Playwright:

```bash
npx playwright test --ui
```

### Features

- **Time-travel debugging**: Step through each action
- **DOM snapshots**: See page state at each step
- **Network tab**: Inspect requests/responses
- **Console tab**: View browser logs
- **Locator picker**: Interactively find locators
- **Watch mode**: Auto-rerun on file changes
- **Filter tests**: Run specific tests

### Tips

```bash
# Open UI mode for specific test file
npx playwright test login.spec.ts --ui

# Open with specific project
npx playwright test --ui --project=chromium
```

---

## Playwright Inspector

Step-by-step debugging with breakpoints:

```bash
# Windows PowerShell
$env:PWDEBUG=1; npx playwright test

# Windows CMD
set PWDEBUG=1 && npx playwright test

# Unix/macOS
PWDEBUG=1 npx playwright test
```

### Inspector Features

- **Step over**: Execute one action at a time
- **Locator explorer**: Highlight and test locators
- **Console**: Execute Playwright commands live
- **Network**: Monitor requests

### In-Code Breakpoint

```typescript
test("debug this test", async ({ page }) => {
  await page.goto("/");

  // Pause execution here
  await page.pause();

  await page.getByRole("button", { name: "Submit" }).click();
});
```

---

## Trace Viewer

Post-mortem debugging with recorded traces:

### Enable Traces

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    trace: "on-first-retry", // Record on retry
    // trace: 'on',                  // Always record
    // trace: 'retain-on-failure',   // Keep only on failure
  },
});
```

### View Traces

```bash
# From HTML report
npx playwright show-report

# Directly open trace file
npx playwright show-trace trace.zip

# View remote trace
npx playwright show-trace https://example.com/trace.zip
```

### Manual Trace Recording

```typescript
test("with trace", async ({ page, context }) => {
  // Start recording
  await context.tracing.start({
    screenshots: true,
    snapshots: true,
    sources: true,
  });

  await page.goto("/");
  await page.getByRole("button").click();

  // Stop and save
  await context.tracing.stop({ path: "traces/my-trace.zip" });
});
```

---

## Headed Mode

Run tests with visible browser:

```bash
# Run all tests headed
npx playwright test --headed

# Slow down execution (ms per action)
npx playwright test --headed --slowmo=500

# Keep browser open after test
PWDEBUG=1 npx playwright test --headed
```

### Configuration

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    headless: false, // Always headed
    launchOptions: {
      slowMo: 500, // Slow down
    },
  },
});
```

---

## Verbose Logging

Enable Playwright debug logs:

```bash
# All Playwright logs
DEBUG=pw:api npx playwright test

# Specific channels
DEBUG=pw:browser npx playwright test
DEBUG=pw:protocol npx playwright test

# Multiple channels
DEBUG=pw:api,pw:browser npx playwright test

# Windows PowerShell
$env:DEBUG="pw:api"; npx playwright test
```

### Log Channels

| Channel        | Description            |
| -------------- | ---------------------- |
| `pw:api`       | Playwright API calls   |
| `pw:browser`   | Browser logs           |
| `pw:protocol`  | CDP/WebSocket messages |
| `pw:webserver` | Web server logs        |

---

## Screenshots & Videos

### Configuration

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    screenshot: "only-on-failure", // 'on' | 'off' | 'only-on-failure'
    video: "retain-on-failure", // 'on' | 'off' | 'retain-on-failure'
  },
});
```

### Manual Screenshots

```typescript
test("capture state", async ({ page }) => {
  await page.goto("/");

  // Full page screenshot
  await page.screenshot({ path: "screenshots/full.png", fullPage: true });

  // Element screenshot
  await page.getByTestId("chart").screenshot({ path: "screenshots/chart.png" });

  // With mask for dynamic content
  await page.screenshot({
    path: "screenshots/masked.png",
    mask: [page.getByTestId("timestamp")],
  });
});
```

### Attach to Report

```typescript
test("with attachments", async ({ page }, testInfo) => {
  await page.goto("/");

  // Attach screenshot on failure
  if (testInfo.status !== testInfo.expectedStatus) {
    const screenshot = await page.screenshot();
    await testInfo.attach("failure-screenshot", {
      body: screenshot,
      contentType: "image/png",
    });
  }
});
```

---

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

## Debugging Flaky Tests

### Common Causes & Solutions

| Symptom                        | Likely Cause       | Solution                                |
| ------------------------------ | ------------------ | --------------------------------------- |
| Element not found randomly     | Race condition     | Use `waitFor()` or web-first assertions |
| Clicks sometimes fail          | Element covered    | Scroll into view, wait for overlays     |
| Assertions fail intermittently | Animations         | Disable animations, use proper waits    |
| Different results in CI        | Environment timing | Increase timeouts, use `networkidle`    |
| Data inconsistency             | Shared test state  | Isolate test data, cleanup              |

### Identify Flaky Tests

```bash
# Run multiple times
npx playwright test --repeat-each=10

# Run with retries
npx playwright test --retries=3

# Fail fast
npx playwright test --max-failures=1
```

### Fix Strategies

```typescript
// ❌ Bad: Arbitrary wait
await page.waitForTimeout(2000);

// ✅ Good: Wait for specific condition
await page.getByRole("button").waitFor({ state: "visible" });
await expect(page.getByText("Loaded")).toBeVisible();
await page.waitForLoadState("networkidle");

// ✅ Good: Retry assertion
await expect(async () => {
  await page.getByRole("button").click();
  await expect(page.getByText("Success")).toBeVisible();
}).toPass({ timeout: 10000 });

// ✅ Good: Disable animations
export default defineConfig({
  use: {
    // Disable CSS animations
    contextOptions: {
      reducedMotion: "reduce",
    },
  },
});
```

### Isolate Test Data

```typescript
test.beforeEach(async ({ request }) => {
  // Create unique test data
  const uniqueEmail = `test-${Date.now()}@example.com`;
  await request.post("/api/users", {
    data: { email: uniqueEmail, name: "Test User" },
  });
});

test.afterEach(async ({ request }) => {
  // Cleanup
  await request.delete("/api/test-data/cleanup");
});
```

---

## Locator Debugging

### Codegen

```bash
# Generate locators interactively
npx playwright codegen http://localhost:3000
```

### Test Locators in Console

```typescript
test("debug locators", async ({ page }) => {
  await page.goto("/");

  // Count matches
  const count = await page.getByRole("button").count();
  console.log(`Found ${count} buttons`);

  // Highlight element
  await page.getByRole("button", { name: "Submit" }).highlight();

  // Evaluate in browser
  const text = await page.evaluate(() => {
    return document.querySelector("h1")?.textContent;
  });
  console.log("H1 text:", text);

  // Pause to inspect
  await page.pause();
});
```

### Strict Mode Issues

```typescript
// Error: Strict mode violation - getByRole('button') resolved to 3 elements

// Solutions:
// 1. Be more specific
page.getByRole("button", { name: "Submit" });

// 2. Use filter
page.getByRole("button").filter({ hasText: "Submit" });

// 3. Use nth (with caution)
page.getByRole("button").first();

// 4. Scope to container
page.getByRole("dialog").getByRole("button", { name: "OK" });
```

---

## Quick Debug Commands

```bash
# Interactive UI mode
npx playwright test --ui

# Debug specific test
npx playwright test -g "login" --debug

# Headed with slow motion
npx playwright test --headed --slowmo=1000

# Stop at first failure
npx playwright test --max-failures=1

# Retry flaky tests
npx playwright test --retries=3

# Generate report
npx playwright test --reporter=html

# Verbose output
npx playwright test --reporter=line

# Update snapshots
npx playwright test --update-snapshots
```

---

## Debugging Checklist

When a test fails:

1. **Run in UI mode**: `npx playwright test --ui`
2. **Check trace**: Look at DOM snapshots, network, console
3. **Verify locator**: Use Codegen or Inspector
4. **Check timing**: Add explicit waits if needed
5. **Inspect network**: Look for failed requests
6. **Check console**: Look for JavaScript errors
7. **Run headed**: `--headed --slowmo=500`
8. **Isolate test**: Run single test, check for state pollution
9. **Check environment**: Compare local vs CI settings
10. **Add logging**: `console.log()` strategic points
