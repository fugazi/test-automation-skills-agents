import { test, expect } from '@playwright/test';

/**
 * Naming convention:
 * - Include test case ID (traceability): "TC-123 ..."
 * - Add suite tags for `--grep` runs: "@smoke", "@regression", etc.
 */

test('TC-001 @smoke example test', async ({ page }) => {
  await page.goto('/');

  // Prefer stable locators (data-testid) when available.
  await expect(page.getByTestId('header')).toBeVisible();

  // TODO: Implement remaining steps + assertions from the test case.
});

