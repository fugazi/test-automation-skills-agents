# Debugging: Trace Viewer, Verbose Logging & Screenshots

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `debugging.md`. See the other `debugging-*.md` files in this folder for related sections.

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
