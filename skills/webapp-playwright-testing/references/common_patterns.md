# Common Test Patterns

Reusable patterns and utilities for Playwright testing with MCP.

---

## Page Validation Patterns

### Verify Page Loaded

```typescript
test("page loads correctly", async ({ page }) => {
  await page.goto("/dashboard");

  await test.step("Verify page elements", async () => {
    await expect(page).toHaveURL(/.*dashboard/);
    await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
    await expect(page.getByRole("navigation")).toBeVisible();
  });
});
```

### Verify Accessibility Structure

```typescript
test("page has correct structure", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByRole("main")).toMatchAriaSnapshot(`
    - main:
      - heading "Welcome" [level=1]
      - navigation:
        - list:
          - listitem:
            - link "Home"
          - listitem:
            - link "Products"
  `);
});
```

---

## Form Patterns

### Complete Form Submission

```typescript
test("submits form successfully", async ({ page }) => {
  await page.goto("/contact");

  await test.step("Fill form fields", async () => {
    await page.getByRole("textbox", { name: "Name" }).fill("John Doe");
    await page.getByRole("textbox", { name: "Email" }).fill("john@example.com");
    await page.getByRole("textbox", { name: "Message" }).fill("Hello!");
  });

  await test.step("Submit form", async () => {
    await page.getByRole("button", { name: "Send" }).click();
  });

  await test.step("Verify success", async () => {
    await expect(page.getByRole("alert")).toContainText("Message sent");
  });
});
```

### Form Validation Errors

```typescript
test("shows validation errors", async ({ page }) => {
  await page.goto("/register");

  await test.step("Submit empty form", async () => {
    await page.getByRole("button", { name: "Register" }).click();
  });

  await test.step("Verify error messages", async () => {
    await expect(page.getByText("Email is required")).toBeVisible();
    await expect(page.getByText("Password is required")).toBeVisible();
  });
});
```

### Password Visibility Toggle

```typescript
test("toggles password visibility", async ({ page }) => {
  await page.goto("/login");

  const passwordField = page.getByRole("textbox", { name: "Password" });
  const toggleButton = page.getByRole("button", { name: /show password/i });

  await passwordField.fill("secret123");

  // Initially hidden
  await expect(passwordField).toHaveAttribute("type", "password");

  // Show password
  await toggleButton.click();
  await expect(passwordField).toHaveAttribute("type", "text");

  // Hide again
  await toggleButton.click();
  await expect(passwordField).toHaveAttribute("type", "password");
});
```

---

## Navigation Patterns

### Header Navigation

```typescript
test("navigates via header menu", async ({ page }) => {
  await page.goto("/");

  await test.step("Navigate to Products", async () => {
    await page
      .getByRole("navigation")
      .getByRole("link", { name: "Products" })
      .click();
    await expect(page).toHaveURL(/.*products/);
  });

  await test.step("Navigate to About", async () => {
    await page
      .getByRole("navigation")
      .getByRole("link", { name: "About" })
      .click();
    await expect(page).toHaveURL(/.*about/);
  });
});
```

### Mobile Navigation with Hamburger

```typescript
test("mobile navigation works", async ({ page }) => {
  // Set mobile viewport
  await page.setViewportSize({ width: 375, height: 667 });
  await page.goto("/");

  await test.step("Open mobile menu", async () => {
    await page.getByRole("button", { name: /menu/i }).click();
    await expect(page.getByRole("navigation")).toBeVisible();
  });

  await test.step("Navigate via menu", async () => {
    await page.getByRole("link", { name: "Products" }).click();
    await expect(page).toHaveURL(/.*products/);
    await expect(page.getByRole("navigation")).toBeHidden();
  });
});
```

### Breadcrumb Navigation

```typescript
test("breadcrumb navigation works", async ({ page }) => {
  await page.goto("/products/category/item");

  const breadcrumb = page.getByRole("navigation", { name: "Breadcrumb" });

  await breadcrumb.getByRole("link", { name: "Category" }).click();
  await expect(page).toHaveURL(/.*category/);
});
```

---

## Modal and Dialog Patterns

### Open and Close Modal

```typescript
test("modal opens and closes", async ({ page }) => {
  await page.goto("/");

  await test.step("Open modal", async () => {
    await page.getByRole("button", { name: "Open Settings" }).click();
    await expect(page.getByRole("dialog")).toBeVisible();
  });

  await test.step("Close with X button", async () => {
    await page.getByRole("button", { name: "Close" }).click();
    await expect(page.getByRole("dialog")).toBeHidden();
  });
});
```

### Confirm Dialog

```typescript
test("confirmation dialog works", async ({ page }) => {
  await page.goto("/items");

  await test.step("Click delete", async () => {
    await page.getByRole("button", { name: "Delete Item" }).click();
  });

  await test.step("Confirm deletion", async () => {
    const dialog = page.getByRole("alertdialog");
    await expect(dialog).toContainText("Are you sure?");
    await dialog.getByRole("button", { name: "Confirm" }).click();
  });

  await test.step("Verify deleted", async () => {
    await expect(page.getByText("Item deleted")).toBeVisible();
  });
});
```

### Modal with Form

```typescript
test("modal form submission", async ({ page }) => {
  await page.goto("/users");

  // Open add user modal
  await page.getByRole("button", { name: "Add User" }).click();

  const modal = page.getByRole("dialog");

  // Fill form in modal
  await modal.getByRole("textbox", { name: "Name" }).fill("New User");
  await modal.getByRole("textbox", { name: "Email" }).fill("new@test.com");
  await modal.getByRole("button", { name: "Save" }).click();

  // Verify modal closed and user added
  await expect(modal).toBeHidden();
  await expect(page.getByText("New User")).toBeVisible();
});
```

---

## Table Patterns

### Find and Interact with Row

```typescript
test("edit table row", async ({ page }) => {
  await page.goto("/users");

  const userRow = page.getByRole("row").filter({ hasText: "john@example.com" });

  await userRow.getByRole("button", { name: "Edit" }).click();

  await expect(page.getByRole("dialog")).toBeVisible();
});
```

### Verify Table Contents

```typescript
test("table displays correct data", async ({ page }) => {
  await page.goto("/products");

  const table = page.getByRole("table");

  // Verify headers
  await expect(table.getByRole("columnheader", { name: "Name" })).toBeVisible();
  await expect(
    table.getByRole("columnheader", { name: "Price" }),
  ).toBeVisible();

  // Verify row count
  await expect(table.getByRole("row")).toHaveCount(11); // 10 data + 1 header
});
```

### Sort Table

```typescript
test("sorts table by column", async ({ page }) => {
  await page.goto("/products");

  // Click column header to sort
  await page.getByRole("columnheader", { name: "Price" }).click();

  // Verify sort indicator
  await expect(
    page.getByRole("columnheader", { name: "Price" }),
  ).toHaveAttribute("aria-sort", "ascending");
});
```

---

## Search and Filter Patterns

### Search with Results

```typescript
test("search returns results", async ({ page }) => {
  await page.goto("/products");

  await test.step("Enter search query", async () => {
    await page.getByRole("searchbox").fill("laptop");
    await page.getByRole("button", { name: "Search" }).click();
  });

  await test.step("Verify results", async () => {
    await expect(page.getByRole("listitem")).toHaveCount.greaterThan(0);
    await expect(page.getByText(/laptop/i).first()).toBeVisible();
  });
});
```

### Filter with Checkboxes

```typescript
test("filters by category", async ({ page }) => {
  await page.goto("/products");

  await page.getByRole("checkbox", { name: "Electronics" }).check();

  // Wait for filtered results
  await expect(page.getByRole("listitem")).toHaveCount.greaterThan(0);

  // All visible items should be electronics
  const items = page.getByRole("listitem");
  await expect(items.first()).toContainText("Electronics");
});
```

---

## Error Handling Patterns

### Screenshot on Failure

```typescript
test("captures screenshot on failure", async ({ page }) => {
  await page.goto("/checkout");

  try {
    await page.getByRole("button", { name: "Pay Now" }).click();
    await expect(page.getByText("Payment successful")).toBeVisible();
  } catch (error) {
    await page.screenshot({
      path: `screenshots/failure-${Date.now()}.png`,
      fullPage: true,
    });
    throw error;
  }
});
```

### Retry Flaky Action

```typescript
test("handles flaky element", async ({ page }) => {
  await page.goto("/dashboard");

  // Wait for dynamic content to stabilize
  await expect(async () => {
    await page.getByRole("button", { name: "Refresh" }).click();
    await expect(page.getByText("Updated")).toBeVisible();
  }).toPass({ timeout: 10000 });
});
```

---

## Responsive Testing Patterns

### Test Multiple Viewports

```typescript
const viewports = [
  { width: 375, height: 667, name: "iPhone SE" },
  { width: 768, height: 1024, name: "iPad" },
  { width: 1920, height: 1080, name: "Desktop" },
];

for (const viewport of viewports) {
  test(`layout correct on ${viewport.name}`, async ({ page }) => {
    await page.setViewportSize({
      width: viewport.width,
      height: viewport.height,
    });
    await page.goto("/");

    await page.screenshot({ path: `screenshots/${viewport.name}.png` });

    if (viewport.width < 768) {
      await expect(page.getByRole("button", { name: /menu/i })).toBeVisible();
    } else {
      await expect(
        page.getByRole("navigation").getByRole("link"),
      ).toHaveCount.greaterThan(0);
    }
  });
}
```

---

## Authentication Patterns

### Login Before Tests

```typescript
test.describe("Authenticated tests", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/login");
    await page.getByRole("textbox", { name: "Email" }).fill("user@test.com");
    await page.getByRole("textbox", { name: "Password" }).fill("password");
    await page.getByRole("button", { name: "Login" }).click();
    await expect(page).toHaveURL(/.*dashboard/);
  });

  test("can view profile", async ({ page }) => {
    await page.getByRole("link", { name: "Profile" }).click();
    await expect(
      page.getByRole("heading", { name: "My Profile" }),
    ).toBeVisible();
  });
});
```

### Session Storage Login

```typescript
test.describe("With stored session", () => {
  test.use({ storageState: "auth.json" });

  test("already logged in", async ({ page }) => {
    await page.goto("/dashboard");
    await expect(
      page.getByRole("heading", { name: "Dashboard" }),
    ).toBeVisible();
  });
});
```

---

## Playwright MCP Quick Patterns

### Validate Page with MCP

```
"Navigate to http://localhost:3000/login"
"Get the accessibility snapshot"
"Verify there is a form with email and password fields"
"Take a screenshot"
```

### Debug Issue with MCP

```
"Navigate to http://localhost:3000/checkout"
"Get the accessibility snapshot"
"Click the 'Proceed' button"
"Check for console errors"
"Take a screenshot"
```

### Test Responsive with MCP

```
"Navigate to http://localhost:3000"
"Resize browser to 375x667"
"Verify hamburger menu is visible"
"Take a screenshot"
"Resize browser to 1920x1080"
"Verify navigation links are visible"
```
