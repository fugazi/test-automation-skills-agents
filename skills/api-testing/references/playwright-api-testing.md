# Playwright API Testing

Detailed reference for API testing with Playwright's request fixture, Supertest, and Zod schema validation in TypeScript.

## Using Request Fixture

The `request` fixture from `@playwright/test` provides an isolated HTTP client for API testing:

```typescript
import { test, expect } from "@playwright/test";

test.describe("Users API", () => {
  test("creates a user", async ({ request }) => {
    const response = await request.post("/api/users", {
      data: {
        name: "Test User",
        email: "test@example.com",
      },
    });
    expect(response.status()).toBe(201);
    const body = await response.json();
    expect(body).toHaveProperty("id");
    expect(body.name).toBe("Test User");
  });

  test("returns 401 without auth", async ({ request }) => {
    const response = await request.get("/api/admin/users");
    expect(response.status()).toBe(401);
  });
});
```

## Auth-Scoped API Tests

Use Playwright's `storageState` to pre-authenticate API tests:

```typescript
test.use({ storageState: ".auth/admin.json" });

test("admin can list all users", async ({ request }) => {
  const response = await request.get("/api/admin/users");
  expect(response.ok()).toBeTruthy();
});
```

## Custom API Fixtures

Create typed fixtures for API testing with dependency injection:

```typescript
// tests/fixtures/api.fixture.ts
import { test as base, APIRequestContext } from "@playwright/test";

type ApiFixtures = {
  apiContext: APIRequestContext;
  authToken: string;
};

export const apiTest = base.extend<ApiFixtures>({
  authToken: async ({ request }, use) => {
    const response = await request.post("/api/auth/login", {
      data: { username: "admin", password: "password" },
    });
    const { token } = await response.json();
    await use(token);
  },
});
```

## Using Supertest (Alternative)

Supertest is useful for testing Express/fastify apps directly without HTTP:

```typescript
import request from "supertest";
import { app } from "../src/app";

test("POST /api/users validates input", async () => {
  const response = await request(app)
    .post("/api/users")
    .send({ name: "", email: "invalid" });
  expect(response.status).toBe(400);
  expect(response.body.error.details).toHaveLength(2);
});
```

## Schema Validation with Zod

Validate response structure on every test:

```typescript
import { z } from "zod";

const UserSchema = z.strictObject({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
  created_at: z.string().datetime(),
});

test("response matches user schema", async ({ request }) => {
  const response = await request.get("/api/users/1");
  const body = await response.json();
  const user = UserSchema.parse(body); // throws if invalid
  expect(user.id).toBeDefined();
});
```

## Data-Driven API Tests

Use parameterized tests for multiple scenarios:

```typescript
const invalidEmails = [
  "",
  "not-an-email",
  "@missing.com",
  "missing@",
  "spaces in@email.com",
];

for (const email of invalidEmails) {
  test(`rejects invalid email: "${email}"`, async ({ request }) => {
    const response = await request.post("/api/users", {
      data: { name: "Test", email },
    });
    expect(response.status()).toBe(400);
  });
}
```

## Pagination Testing Pattern

```typescript
test.describe("Pagination", () => {
  test("returns paginated results", async ({ request }) => {
    const page1 = await request.get("/api/users?offset=0&limit=5");
    const body1 = await page1.json();

    expect(page1.status()).toBe(200);
    expect(body1.data.length).toBeLessThanOrEqual(5);

    if (body1.pagination.has_more) {
      const page2 = await request.get(`/api/users?offset=5&limit=5`);
      expect(page2.status()).toBe(200);
    }
  });

  test("returns 400 for negative offset", async ({ request }) => {
    const response = await request.get("/api/users?offset=-1&limit=10");
    expect(response.status()).toBe(400);
  });
});
```
