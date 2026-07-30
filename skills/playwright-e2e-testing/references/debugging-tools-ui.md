# Debugging: Tools, UI Mode, Inspector & Headed

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `debugging.md`. See the other `debugging-*.md` files in this folder for related sections.

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
