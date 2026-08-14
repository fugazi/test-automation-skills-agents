---
description: 'Playwright TypeScript essentials — locator priority, web-first assertions, no hard waits. Applied to all .spec.ts files.'
---

# Playwright TypeScript Essentials

## Locator Priority (always follow)

1. `getByRole()` + accessible name
2. `getByLabel()`
3. `getByPlaceholder()`
4. `getByText()`
5. `getByTestId()`
6. CSS (last resort)

## Non-Negotiable Rules

- **Web-first assertions only**: `await expect(locator).toBeVisible()` — never throw-based
- **No hard waits**: `waitForTimeout()` and `waitForLoadState('networkidle')` are banned
- **No XPath**: use role-based locators instead
- **No `any` type**: always typed interfaces
- **test.step()**: wrap all logical groupings for traceability
- **External test data**: environment variables, data files, or factories — never hardcoded
- **POM required**: all UI interaction through Page Object classes, injected via custom fixtures
- **Single-tag taxonomy**: exactly one tag per test — `@smoke`, `@sanity`, `@regression`,
  `@e2e`, `@api`, or `@destructive` via `{ tag: '@smoke' }`; never on `test.describe()`,
  never combined. `@destructive` mutates shared/global state (locale, permissions, roles,
  feature flags, global settings) — exclude from parallel runs
  (`--grep-invert @destructive`) and run it separately with `--workers=1`.

## References

For full patterns (POM, fixtures, mocking, debugging, visual regression): use the `playwright-e2e-testing` skill.
