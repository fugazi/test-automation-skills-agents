---
name: api-testing
description: "Comprehensive API testing for REST and GraphQL endpoints. Use when asked to create, run, or debug API tests, validate schemas, test authentication, verify contracts, or check error handling. Covers Playwright request fixture (TypeScript) and REST Assured (Java 21+)."
---

# API Testing (Playwright + REST Assured)

Comprehensive API testing skill covering both Playwright TypeScript (request fixture, Supertest, Zod) and Java (REST Assured, AssertJ, JSON Schema Validator). Provides deep domain expertise for the `api-tester-specialist` agent.

## When to Use This Skill

- Create API tests for REST or GraphQL endpoints
- Validate request/response schemas (Zod, JSON Schema)
- Test authentication flows (OAuth2, JWT, API keys, Bearer tokens)
- Verify error handling (400, 401, 403, 404, 409, 422, 500)
- Test pagination, filtering, sorting edge cases
- Validate idempotency for PUT/DELETE operations
- Contract testing between services
- Rate limiting validation

## Prerequisites

| Stack      | Requirements                                                          |
| ---------- | --------------------------------------------------------------------- |
| TypeScript | Node.js 18+, `@playwright/test` or `supertest`, `zod`                 |
| Java       | Java 21+, REST Assured 5.x, AssertJ, Jackson, `json-schema-validator` |

## Core Principles

1. **Schema validation on every response** — never trust an unvalidated response
2. **Test all HTTP status codes** — happy path AND error states
3. **Auth testing is mandatory** — verify 401/403 for protected endpoints
4. **Data-driven** — test with valid, invalid, boundary, and empty values
5. **Stateless where possible** — each test cleans up or uses unique data

## Quick Reference — Playwright

```typescript
import { test, expect } from "@playwright/test";

test("GET /api/users returns 200 with valid schema", async ({ request }) => {
  const response = await request.get("/api/users");
  expect(response.ok()).toBeTruthy();
  const body = await response.json();
  expect(body).toMatchObject({ data: expect.any(Array) });
});
```

## Quick Reference — REST Assured

```java
import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;

import java.util.List;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@Test
@DisplayName("GET /api/users returns 200 with valid schema")
void getUsers() {
    String token = "test-token";

    given()
        .header("Authorization", "Bearer " + token)
    .when()
        .get("/api/users")
    .then()
        .statusCode(200)
        .body("data", is(instanceOf(List.class)))
        .body("data.size()", greaterThan(0));
}
```

## Common Rationalizations

> Common shortcuts and "good enough" excuses that erode test quality — and the reality behind each.

| Rationalization                                 | Reality                                                                                                      |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| "Schema validation is overkill"                 | Without schema validation, a silent field rename becomes a production incident. Validate every response.     |
| "Happy path testing is enough"                  | Error states (400, 401, 403, 404, 409, 500) are where real failures happen. Test all status codes.           |
| "Auth tests can wait"                           | Unauthenticated access to protected endpoints is a security vulnerability, not a backlog item.               |
| "This endpoint won't change"                    | APIs evolve. Contract tests catch breaking changes before they reach production.                             |
| "Manual API testing with Postman is sufficient" | Manual testing isn't repeatable, can't run in CI, and doesn't scale. Automate API tests.                     |
| "Idempotency doesn't matter"                    | Duplicate requests happen in production. Without idempotency testing, you get duplicate records and charges. |

---

## References

| Document                                                         | Content                                             |
| ---------------------------------------------------------------- | --------------------------------------------------- |
| [REST API Patterns](./references/rest-api-patterns.md)           | CRUD, pagination, filtering, error patterns         |
| [Playwright API Testing](./references/playwright-api-testing.md) | Request fixture, Supertest, TypeScript patterns     |
| [REST Assured Testing](./references/rest-assured-testing.md)     | REST Assured, AssertJ, Java patterns                |
| [Schema Validation](./references/schema-validation.md)           | Zod (TS), JSON Schema (Java), strict vs loose       |
| [Contract Testing](./references/contract-testing.md)             | Request/response contracts, idempotency, versioning |

## Templates

- [Playwright API Spec](./templates/playwright-api-spec.ts) — starter test file for API testing
- [REST Assured Test](./templates/rest-assured-test.java) — starter Java test class

## Scripts

- [API Health Check](./scripts/api-health-check.sh) — validate API endpoints respond correctly

## Troubleshooting

| Issue                          | Solution                                                                       |
| ------------------------------ | ------------------------------------------------------------------------------ |
| 401 on authenticated endpoints | Verify token is fresh; check expiry; re-authenticate                           |
| Flaky API tests                | Add retry logic; check for rate limiting; use unique test data                 |
| Schema validation too strict   | Use `.passthrough()` (Zod) or `additionalProperties: true` for flexible fields |
| Timeout on slow endpoints      | Increase `timeout` in request options; check for server load                   |

---

## Verification

After completing this skill's workflow, confirm:

- [ ] **All CRUD operations tested** — POST, GET, PUT, PATCH, DELETE covered for the resource
- [ ] **Status codes verified** — Success (2xx) AND error codes (4xx, 5xx) tested
- [ ] **Schema validation in place** — Every response validated against a schema (Zod or JSON Schema)
- [ ] **Authentication tested** — 401 returned for protected endpoints without valid credentials
- [ ] **Idempotency verified** — PUT/DELETE produce same result when called multiple times
- [ ] **Edge cases covered** — Empty payloads, invalid types, boundary values, SQL injection attempts
- [ ] **All tests pass** — Playwright API tests or REST Assured tests exit successfully
