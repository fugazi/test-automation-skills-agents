import { test, expect } from '@playwright/test';

/**
 * Naming convention:
 * - Include test case ID (traceability): "TC-123 ..."
 * - Use the `tag` annotation for `--grep` runs: `{ tag: '@smoke' }` (one tag per test)
 */

test('TC-001 example test', { tag: '@smoke' }, async ({ page }) => {
  await page.goto('/');

  // Prefer stable locators (data-testid) when available.
  await expect(page.getByTestId('header')).toBeVisible();

  // TODO: Implement remaining steps + assertions from the test case.
});

