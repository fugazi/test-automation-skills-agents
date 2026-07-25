## Usage Examples

### Example 1: Basic Navigation Test

```typescript
// Navigate to a page and verify heading
await page.goto("http://localhost:3000");
await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
```

### Example 2: Form Interaction (Role-Based Locators)

```typescript
// Fill out and submit a form using accessible locators
await page.getByRole("textbox", { name: "Username" }).fill("testuser");
await page.getByRole("textbox", { name: "Password" }).fill("password123");
await page.getByRole("button", { name: "Login" }).click();
await expect(page).toHaveURL(/.*dashboard/);
```

### Example 3: Screenshot Capture

```typescript
// Capture a full-page screenshot for debugging
await page.screenshot({ path: "debug.png", fullPage: true });
```

### Example 4: Accessibility Snapshot Assertion

```typescript
// Verify page structure with aria snapshot
await expect(page.getByRole("main")).toMatchAriaSnapshot(`
  - main:
    - heading "Welcome" [level=1]
    - form:
      - textbox "Email"
      - textbox "Password"
      - button "Login"
`);
```

