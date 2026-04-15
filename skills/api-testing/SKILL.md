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

| Stack | Requirements |
|-------|-------------|
| TypeScript | Node.js 18+, `@playwright/test` or `supertest`, `zod` |
| Java | Java 21+, REST Assured 5.x, AssertJ, Jackson, `json-schema-validator` |

## Core Principles

1. **Schema validation on every response** — never trust an unvalidated response
2. **Test all HTTP status codes** — happy path AND error states
3. **Auth testing is mandatory** — verify 401/403 for protected endpoints
4. **Data-driven** — test with valid, invalid, boundary, and empty values
5. **Stateless where possible** — each test cleans up or uses unique data

## Quick Reference — Playwright

```typescript
import { test, expect } from '@playwright/test';

test('GET /api/users returns 200 with valid schema', async ({ request }) => {
  const response = await request.get('/api/users');
  expect(response.ok()).toBeTruthy();
  const body = await response.json();
  expect(body).toMatchObject({ data: expect.any(Array) });
});
```

## Quick Reference — REST Assured

```java
import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;

@Test
@DisplayName('GET /api/users returns 200 with valid schema')
void getUsers() {
    given()
        .header('Authorization', 'Bearer ' + token)
    .when()
        .get('/api/users')
    .then()
        .statusCode(200)
        .body('data', is(instanceOf(List.class)))
        .body('data.size()', greaterThan(0));
}
```

## References

| Document | Content |
|----------|---------|
| [REST API Patterns](./references/rest-api-patterns.md) | CRUD, pagination, filtering, error patterns |
| [Playwright API Testing](./references/playwright-api-testing.md) | Request fixture, Supertest, TypeScript patterns |
| [REST Assured Testing](./references/rest-assured-testing.md) | REST Assured, AssertJ, Java patterns |
| [Schema Validation](./references/schema-validation.md) | Zod (TS), JSON Schema (Java), strict vs loose |
| [Contract Testing](./references/contract-testing.md) | Request/response contracts, idempotency, versioning |

## Templates

- [Playwright API Spec](./templates/playwright-api-spec.ts) — starter test file for API testing
- [REST Assured Test](./templates/rest-assured-test.java) — starter Java test class

## Scripts

- [API Health Check](./scripts/api-health-check.sh) — validate API endpoints respond correctly

## Troubleshooting

| Issue | Solution |
|-------|----------|
| 401 on authenticated endpoints | Verify token is fresh; check expiry; re-authenticate |
| Flaky API tests | Add retry logic; check for rate limiting; use unique test data |
| Schema validation too strict | Use `.passthrough()` (Zod) or `additionalProperties: true` for flexible fields |
| Timeout on slow endpoints | Increase `timeout` in request options; check for server load |
