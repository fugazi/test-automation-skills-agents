# Contract Testing

Contract testing patterns for verifying the agreement between API producer and consumer. Focuses on request/response shape, status codes, and headers — not business logic.

## What Is a Contract Test

- Verifies the AGREEMENT between producer and consumer
- Focuses on: request shape, response shape, status codes, headers
- Does NOT test business logic (that is for functional tests)

## Request Contract

```typescript
// TypeScript — verify POST accepts valid payload and returns expected response
test("POST /api/users accepts valid payload", async ({ request }) => {
  const response = await request.post("/api/users", {
    headers: { "Content-Type": "application/json" },
    data: { name: "Test", email: "test@example.com" },
  });
  // Contract: must return 201 with location header
  expect(response.status()).toBe(201);
  expect(response.headers()["location"]).toMatch(/\/api\/users\/.+/);
});
```

```java
// Java — verify POST contract
@Test
@DisplayName("POST /users contract: returns 201 with Location header")
void createUserContract() {
    given()
        .contentType(ContentType.JSON)
        .body("{ \"name\": \"Test\", \"email\": \"test@example.com\" }")
    .when()
        .post("/users")
    .then()
        .statusCode(201)
        .header("Location", matchesRegex(".+/api/users/.+"));
}
```

## Idempotency Testing

Verify that repeated identical requests produce the same result:

```typescript
test("PUT /api/users/:id is idempotent", async ({ request }) => {
  const payload = { name: "Same Name", email: "same@example.com" };

  const first = await request.put("/api/users/1", { data: payload });
  const second = await request.put("/api/users/1", { data: payload });

  expect(first.status()).toBe(second.status());
  // Same request = same result
  const body1 = await first.json();
  const body2 = await second.json();
  expect(body1).toEqual(body2);
});
```

```java
@Test
@DisplayName("PUT /users/:id is idempotent")
void putIsIdempotent() {
    String payload = "{ \"name\": \"Same\", \"email\": \"same@example.com\" }";

    Response first = given().contentType(ContentType.JSON).body(payload).put("/users/1");
    Response second = given().contentType(ContentType.JSON).body(payload).put("/users/1");

    assertThat(first.statusCode()).isEqualTo(second.statusCode());
    assertThat(first.body().asString()).isEqualTo(second.body().asString());
}
```

## Versioning Contracts

Verify that newer API versions maintain backward compatibility:

```typescript
test("API v2 maintains backward compatibility with v1", async ({ request }) => {
  const v1 = await request.get("/api/v1/users/1");
  const v2 = await request.get("/api/v2/users/1");

  // V2 must include all V1 fields
  const body1 = await v1.json();
  const body2 = await v2.json();
  Object.keys(body1).forEach((key) => {
    expect(body2).toHaveProperty(key);
  });
});
```

## Response Shape Contract

```typescript
test("GET /api/users response has required top-level fields", async ({
  request,
}) => {
  const response = await request.get("/api/users");
  const body = await response.json();

  // Contract: response must have these top-level keys
  expect(body).toHaveProperty("data");
  expect(body).toHaveProperty("pagination");
  expect(Array.isArray(body.data)).toBeTruthy();
  expect(body.pagination).toHaveProperty("total");
  expect(body.pagination).toHaveProperty("has_more");
});
```
