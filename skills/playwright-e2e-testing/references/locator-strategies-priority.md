# Locator Strategies: Priority Hierarchy & Role Locators

> Part of the `playwright-e2e-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original `locator-strategies.md`. See the other `locator-strategies-*.md` files in this folder for related sections.

## Locator Priority Hierarchy

Always prefer locators higher in this list for maximum resilience:

| Priority | Locator Type           | Example                                   | Why                                |
| -------- | ---------------------- | ----------------------------------------- | ---------------------------------- |
| 1        | Role + accessible name | `getByRole('button', { name: 'Submit' })` | Accessible, user-facing, resilient |
| 2        | Label                  | `getByLabel('Email')`                     | Tied to accessibility              |
| 3        | Placeholder            | `getByPlaceholder('Enter email')`         | User-visible text                  |
| 4        | Text                   | `getByText('Welcome')`                    | Content-based                      |
| 5        | Alt text               | `getByAltText('Company logo')`            | Images, accessible                 |
| 6        | Title                  | `getByTitle('Close dialog')`              | Tooltips                           |
| 7        | Test ID                | `getByTestId('submit-btn')`               | Stable, explicit                   |
| 8        | CSS                    | `locator('.btn-primary')`                 | Brittle, avoid                     |
| 9        | XPath                  | `locator('//button')`                     | Extremely brittle, never use       |

---

## Role-Based Locators

### Common ARIA Roles

```typescript
// Buttons
page.getByRole("button", { name: "Submit" });
page.getByRole("button", { name: /submit/i }); // case-insensitive

// Links
page.getByRole("link", { name: "Home" });
page.getByRole("link", { name: "Read more" });

// Form controls
page.getByRole("textbox", { name: "Email" });
page.getByRole("textbox", { name: "Password" });
page.getByRole("checkbox", { name: "Remember me" });
page.getByRole("radio", { name: "Credit card" });
page.getByRole("combobox", { name: "Country" });
page.getByRole("spinbutton", { name: "Quantity" });
page.getByRole("slider", { name: "Volume" });

// Dropdowns
page.getByRole("listbox");
page.getByRole("option", { name: "United States" });

// Navigation
page.getByRole("navigation");
page.getByRole("menu");
page.getByRole("menuitem", { name: "Settings" });
page.getByRole("menubar");
page.getByRole("tab", { name: "Details" });
page.getByRole("tabpanel");

// Headings (semantic structure)
page.getByRole("heading", { name: "Welcome" });
page.getByRole("heading", { level: 1 });
page.getByRole("heading", { level: 2, name: "Features" });

// Page structure
page.getByRole("main");
page.getByRole("banner"); // <header>
page.getByRole("contentinfo"); // <footer>
page.getByRole("complementary"); // <aside>
page.getByRole("region", { name: "Sidebar" });

// Tables
page.getByRole("table");
page.getByRole("row");
page.getByRole("cell", { name: "Total" });
page.getByRole("columnheader", { name: "Price" });
page.getByRole("rowheader");

// Dialogs
page.getByRole("dialog");
page.getByRole("alertdialog");
page.getByRole("alert");

// Lists
page.getByRole("list");
page.getByRole("listitem");

// Media
page.getByRole("img", { name: "Product photo" });
page.getByRole("figure");

// Search
page.getByRole("searchbox");
page.getByRole("search");
```

### Role Modifiers

```typescript
// Exact match (default is substring)
page.getByRole("button", { name: "Submit", exact: true });

// State modifiers
page.getByRole("button", { pressed: true }); // Toggle buttons
page.getByRole("button", { expanded: true }); // Accordions, dropdowns
page.getByRole("checkbox", { checked: true }); // Checkboxes
page.getByRole("option", { selected: true }); // Select options
page.getByRole("button", { disabled: true }); // Disabled state
page.getByRole("tab", { selected: true }); // Active tab

// Include hidden elements (default: false)
page.getByRole("button", { includeHidden: true });
```

---
