# Debugging: Flaky Tests, Locators & Quick Commands

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `debugging.md`. See the other `debugging-*.md` files in this folder for related sections.

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
// [no] Bad: Arbitrary wait
await page.waitForTimeout(2000);

// [ok] Good: Wait for specific condition
await page.getByRole("button").waitFor({ state: "visible" });
await expect(page.getByText("Loaded")).toBeVisible();
await page.waitForLoadState("networkidle");

// [ok] Good: Retry assertion
await expect(async () => {
  await page.getByRole("button").click();
  await expect(page.getByText("Success")).toBeVisible();
}).toPass({ timeout: 10000 });

// [ok] Good: Disable animations
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
