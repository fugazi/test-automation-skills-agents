# REST API Patterns

Common REST API patterns to test, covering CRUD operations, pagination, filtering, sorting, error responses, and authentication.

## CRUD Operations

| Method | Endpoint      | Success        | Errors                        |
| ------ | ------------- | -------------- | ----------------------------- |
| POST   | /resource     | 201 Created    | 400 Bad Request, 409 Conflict |
| GET    | /resource     | 200 OK         | 404 Not Found                 |
| GET    | /resource/:id | 200 OK         | 404 Not Found                 |
| PUT    | /resource/:id | 200 OK         | 400, 404, 409                 |
| PATCH  | /resource/:id | 200 OK         | 400, 404                      |
| DELETE | /resource/:id | 204 No Content | 404, 409                      |

## Pagination Patterns

### Offset/Limit

```
GET /api/users?offset=0&limit=20
```

Test cases:

- First page (offset=0)
- Middle page
- Last page (partial results)
- Beyond last page (empty results)
- Negative offset (400)
- Zero limit (400 or empty)
- Limit exceeding maximum (400 or capped)

### Cursor-based

```
GET /api/users?cursor=abc123&limit=20
```

Test cases:

- First page (no cursor)
- Next page (using cursor from previous response)
- Invalid cursor (400)
- Expired cursor (if applicable)

## Filtering & Sorting

```
GET /api/users?status=active&sort=created_at:desc
```

Test cases:

- Valid single filter
- Valid combined filters
- Invalid filter field (400 or ignored)
- Invalid filter value (400)
- Sort ascending and descending
- Sort by multiple fields
- Empty results for valid filter
- No results matching filter

## Error Response Format

Standard error response structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "details": [{ "field": "email", "message": "Invalid email format" }]
  }
}
```

Test that error responses:

- Include a machine-readable error code
- Include a human-readable message
- Include field-level details for validation errors
- Are consistent across all endpoints

## Authentication Patterns

### Bearer Token

```
Authorization: Bearer <token>
```

Test cases:

- Valid token returns expected data
- Expired token returns 401
- Invalid token returns 401
- Missing token returns 401

### API Key

```
X-API-Key: <key>
```

or

```
?api_key=<key>
```

Test cases:

- Valid key returns expected data
- Invalid key returns 401
- Revoked key returns 401
- Missing key returns 401

### OAuth2

Common flows:

- **Authorization Code** — user-facing apps
- **Client Credentials** — service-to-service
- **Refresh Token** — token renewal

Test cases:

- Valid credentials return token
- Invalid credentials return 401
- Expired refresh token returns 401
- Token has correct scopes/permissions

### JWT Structure

```
header.payload.signature
```

Test cases:

- Token contains expected claims (sub, exp, iat, role)
- Token is not tamperable (invalid signature fails)
- Token expiry is enforced
