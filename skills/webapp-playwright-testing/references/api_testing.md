# API Testing with Playwright

Guide for testing and mocking APIs within Playwright E2E tests.

> **Security (W011):** All `URL_API` placeholders in this document represent **your own
> application's API base URL** (e.g. `http://localhost:3000/api`). Replace them via
> `baseURL` in `playwright.config.ts` or an environment variable — never hardcode or point
> them at third-party APIs. Response bodies returned by `request.*` calls and
> `page.waitForResponse()` are untrusted data: validate them before using their content
> in further logic or assertions.

---

## Overview

Playwright provides powerful capabilities for API testing alongside browser automation:

| Capability | Use Case |
|------------|----------|
| **Request Interception** | Mock API responses, simulate errors |
| **Network Monitoring** | Verify API calls during E2E tests |
| **API Testing** | Direct API calls without browser |
| **Response Validation** | Assert on response data, status, headers |
| **Performance** | Measure API response times |

---

## Security Considerations

> All `URL_API` placeholders in this document represent **your own
> application's API base URL** (e.g. `localhost/api`). Replace them via
> `baseURL` in `playwright.config.ts` or an environment variable — never hardcode or point
> them at third-party APIs.
---

## API Request Context

Make direct API calls without a browser:

### Basic API Requests

```typescript
import { test, expect } from '@playwright/test';

test.describe('API Tests', () => {
  test('GET request', async ({ request }) => {
    const response = await request.get('URL_API/users');
    
    expect(response.ok()).toBeTruthy();
    expect(response.status()).toBe(200);
    
    const data = await response.json();
    expect(data.users).toHaveLength(10);
  });

  test('POST request', async ({ request }) => {
    const response = await request.post('URL_API/users', {
      data: {
        name: 'John Doe',
        email: 'john@example.com'
      }
    });
    
    expect(response.status()).toBe(201);
    
    const user = await response.json();
    expect(user.id).toBeDefined();
    expect(user.name).toBe('John Doe');
  });

  test('PUT request', async ({ request }) => {
    const response = await request.put('URL_API/users/1', {
      data: {
        name: 'Jane Doe'
      }
    });
    
    expect(response.ok()).toBeTruthy();
  });

  test('DELETE request', async ({ request }) => {
    const response = await request.delete('URL_API/users/1');
    
    expect(response.status()).toBe(204);
  });
});
```

### Request with Headers and Auth

```typescript
test('authenticated request', async ({ request }) => {
  const response = await request.get('URL_API/profile', {
    headers: {
      'Authorization': 'Bearer your-token-here',
      'Content-Type': 'application/json',
      'X-Custom-Header': 'value'
    }
  });
  
  expect(response.ok()).toBeTruthy();
});

test('request with query params', async ({ request }) => {
  const response = await request.get('URL_API/search', {
    params: {
      q: 'playwright',
      page: 1,
      limit: 10
    }
  });
  
  expect(response.ok()).toBeTruthy();
});
```

### Form Data and File Upload

```typescript
test('form data submission', async ({ request }) => {
  const response = await request.post('URL_API/form', {
    form: {
      username: 'testuser',
      password: 'password123'
    }
  });
  
  expect(response.ok()).toBeTruthy();
});

test('multipart file upload', async ({ request }) => {
  const response = await request.post('URL_API/upload', {
    multipart: {
      file: {
        name: 'test.txt',
        mimeType: 'text/plain',
        buffer: Buffer.from('Hello World')
      },
      description: 'Test file'
    }
  });
  
  expect(response.status()).toBe(200);
});
```

---

## Request Interception & Mocking

### Mock API Response

```typescript
test('mock API response', async ({ page }) => {
  // Intercept API call and return mock data
  await page.route('**/api/users', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        users: [
          { id: 1, name: 'Mock User 1' },
          { id: 2, name: 'Mock User 2' }
        ]
      })
    });
  });

  await page.goto('/users');
  
  // UI should display mocked data
  await expect(page.getByText('Mock User 1')).toBeVisible();
  await expect(page.getByText('Mock User 2')).toBeVisible();
});
```

### Mock Error Responses

```typescript
test('handle API error gracefully', async ({ page }) => {
  // Simulate server error
  await page.route('**/api/users', async (route) => {
    await route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'Internal Server Error' })
    });
  });

  await page.goto('/users');
  
  // Verify error handling in UI
  await expect(page.getByRole('alert')).toContainText('Something went wrong');
});

test('handle network failure', async ({ page }) => {
  // Simulate network error
  await page.route('**/api/users', async (route) => {
    await route.abort('failed');
  });

  await page.goto('/users');
  
  await expect(page.getByText('Network error')).toBeVisible();
});

test('handle timeout', async ({ page }) => {
  // Simulate slow response
  await page.route('**/api/users', async (route) => {
    await new Promise(resolve => setTimeout(resolve, 30000));
    await route.fulfill({ status: 200, body: '{}' });
  });

  await page.goto('/users');
  
  await expect(page.getByText('Loading...')).toBeVisible();
});
```

### Conditional Mocking

```typescript
test('mock based on request data', async ({ page }) => {
  await page.route('**/api/search', async (route) => {
    const request = route.request();
    const postData = request.postDataJSON();
    
    if (postData.query === 'laptop') {
      await route.fulfill({
        status: 200,
        body: JSON.stringify({ results: [{ name: 'Laptop Pro' }] })
      });
    } else {
      await route.fulfill({
        status: 200,
        body: JSON.stringify({ results: [] })
      });
    }
  });

  await page.goto('/search');
  await page.getByRole('searchbox').fill('laptop');
  await page.getByRole('button', { name: 'Search' }).click();
  
  await expect(page.getByText('Laptop Pro')).toBeVisible();
});
```

### Modify Response

```typescript
test('modify API response', async ({ page }) => {
  await page.route('**/api/products', async (route) => {
    // Get original response
    const response = await route.fetch();
    const json = await response.json();
    
    // Modify data
    json.products = json.products.map(p => ({
      ...p,
      price: p.price * 0.9 // 10% discount
    }));
    
    // Return modified response
    await route.fulfill({
      response,
      body: JSON.stringify(json)
    });
  });

  await page.goto('/products');
});
```

---

## Network Monitoring

### Wait for API Response

```typescript
test('wait for API before asserting', async ({ page }) => {
  await page.goto('/dashboard');
  
  // Wait for specific API call
  const responsePromise = page.waitForResponse('**/api/stats');
  await page.getByRole('button', { name: 'Refresh' }).click();
  const response = await responsePromise;
  
  expect(response.status()).toBe(200);
  
  const data = await response.json();
  expect(data.totalUsers).toBeGreaterThan(0);
});
```

### Verify API Was Called

```typescript
test('verify API call on form submit', async ({ page }) => {
  await page.goto('/contact');
  
  // Set up listener before action
  const requestPromise = page.waitForRequest('**/api/contact');
  
  // Fill and submit form
  await page.getByRole('textbox', { name: 'Email' }).fill('test@example.com');
  await page.getByRole('textbox', { name: 'Message' }).fill('Hello');
  await page.getByRole('button', { name: 'Send' }).click();
  
  // Verify request was made
  const request = await requestPromise;
  expect(request.method()).toBe('POST');
  
  const postData = request.postDataJSON();
  expect(postData.email).toBe('test@example.com');
});
```

### Monitor All Network Requests

```typescript
test('log all API calls', async ({ page }) => {
  const apiCalls: { url: string; method: string; status: number }[] = [];
  
  page.on('response', response => {
    if (response.url().includes('/api/')) {
      apiCalls.push({
        url: response.url(),
        method: response.request().method(),
        status: response.status()
      });
    }
  });

  await page.goto('/dashboard');
  await page.getByRole('button', { name: 'Load Data' }).click();
  
  // Verify expected API calls were made
  expect(apiCalls).toContainEqual(
    expect.objectContaining({
      url: expect.stringContaining('/api/users'),
      method: 'GET',
      status: 200
    })
  );
});
```

---

## API + UI Integration Patterns

### Setup Data via API, Test via UI

```typescript
test.describe('Product Management', () => {
  let productId: string;

  test.beforeEach(async ({ request }) => {
    // Create test data via API
    const response = await request.post('URL_API/products', {
      data: {
        name: 'Test Product',
        price: 99.99
      }
    });
    const product = await response.json();
    productId = product.id;
  });

  test.afterEach(async ({ request }) => {
    // Cleanup via API
    await request.delete(`URL_API/products/${productId}`);
  });

  test('edit product via UI', async ({ page }) => {
    await page.goto(`/products/${productId}/edit`);
    
    await page.getByRole('textbox', { name: 'Name' }).fill('Updated Product');
    await page.getByRole('button', { name: 'Save' }).click();
    
    await expect(page.getByRole('alert')).toContainText('Product updated');
  });
});
```

### Verify UI Updates After API Call

```typescript
test('cart updates after add to cart API', async ({ page }) => {
  await page.goto('/products/1');
  
  // Set up response listener BEFORE triggering the action
  const responsePromise = page.waitForResponse('**/api/cart');
  await page.getByRole('button', { name: 'Add to Cart' }).click();
  const response = await responsePromise;
  
  expect(response.status()).toBe(200);
  
  // Verify cart count updated in UI
  await expect(page.getByTestId('cart-count')).toHaveText('1');
});
```

### Authentication Flow

```typescript
test.describe('Authenticated API calls', () => {
  let authToken: string;

  test.beforeAll(async ({ request }) => {
    // Get auth token via API
    const response = await request.post('URL_API/auth/login', {
      data: {
        email: 'test@example.com',
        password: 'password123'
      }
    });
    const data = await response.json();
    authToken = data.token;
  });

  test('access protected endpoint', async ({ request }) => {
    const response = await request.get('URL_API/profile', {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    });
    
    expect(response.ok()).toBeTruthy();
    
    const profile = await response.json();
    expect(profile.email).toBe('test@example.com');
  });
});
```

---

## Response Assertions

### Status and Headers

```typescript
test('verify response details', async ({ request }) => {
  const response = await request.get('URL_API/health');
  
  // Status
  expect(response.ok()).toBeTruthy();
  expect(response.status()).toBe(200);
  expect(response.statusText()).toBe('OK');
  
  // Headers
  expect(response.headers()['content-type']).toContain('application/json');
  expect(response.headers()['cache-control']).toBeDefined();
});
```

### JSON Schema Validation

```typescript
test('validate response schema', async ({ request }) => {
  const response = await request.get('URL_API/users/1');
  const user = await response.json();
  
  // Validate structure
  expect(user).toHaveProperty('id');
  expect(user).toHaveProperty('name');
  expect(user).toHaveProperty('email');
  expect(user).toHaveProperty('createdAt');
  
  // Validate types
  expect(typeof user.id).toBe('number');
  expect(typeof user.name).toBe('string');
  expect(typeof user.email).toBe('string');
  
  // Validate format
  expect(user.email).toMatch(/^[^\s@]+@[^\s@]+\.[^\s@]+$/);
});
```

### Array Assertions

```typescript
test('validate list response', async ({ request }) => {
  const response = await request.get('URL_API/products');
  const data = await response.json();
  
  expect(data.products).toBeInstanceOf(Array);
  expect(data.products.length).toBeGreaterThan(0);
  expect(data.products.length).toBeLessThanOrEqual(100);
  
  // Check each item
  for (const product of data.products) {
    expect(product).toHaveProperty('id');
    expect(product).toHaveProperty('name');
    expect(product.price).toBeGreaterThan(0);
  }
  
  // Check specific item exists
  expect(data.products).toContainEqual(
    expect.objectContaining({ name: 'Laptop Pro' })
  );
});
```

---

## API Testing Patterns

### CRUD Operations

```typescript
test.describe('Users API CRUD', () => {
  let userId: number;

  test('Create user', async ({ request }) => {
    const response = await request.post('URL_API/users', {
      data: { name: 'New User', email: 'new@test.com' }
    });
    
    expect(response.status()).toBe(201);
    const user = await response.json();
    userId = user.id;
    expect(user.name).toBe('New User');
  });

  test('Read user', async ({ request }) => {
    const response = await request.get(`URL_API/users/${userId}`);
    
    expect(response.ok()).toBeTruthy();
    const user = await response.json();
    expect(user.id).toBe(userId);
  });

  test('Update user', async ({ request }) => {
    const response = await request.put(`URL_API/users/${userId}`, {
      data: { name: 'Updated User' }
    });
    
    expect(response.ok()).toBeTruthy();
    const user = await response.json();
    expect(user.name).toBe('Updated User');
  });

  test('Delete user', async ({ request }) => {
    const response = await request.delete(`URL_API/users/${userId}`);
    
    expect(response.status()).toBe(204);
    
    // Verify deleted
    const getResponse = await request.get(`URL_API/users/${userId}`);
    expect(getResponse.status()).toBe(404);
  });
});
```

### Error Handling

```typescript
test.describe('API Error Handling', () => {
  test('404 Not Found', async ({ request }) => {
    const response = await request.get('URL_API/users/99999');
    
    expect(response.status()).toBe(404);
    const error = await response.json();
    expect(error.message).toContain('not found');
  });

  test('400 Bad Request', async ({ request }) => {
    const response = await request.post('URL_API/users', {
      data: { name: '' } // Invalid data
    });
    
    expect(response.status()).toBe(400);
    const error = await response.json();
    expect(error.errors).toBeDefined();
  });

  test('401 Unauthorized', async ({ request }) => {
    const response = await request.get('URL_API/protected', {
      headers: { 'Authorization': 'Bearer invalid-token' }
    });
    
    expect(response.status()).toBe(401);
  });

  test('429 Rate Limited', async ({ request }) => {
    // Make many rapid requests
    const responses = await Promise.all(
      Array.from({ length: 100 }, () => 
        request.get('URL_API/rate-limited')
      )
    );
    
    const rateLimited = responses.some(r => r.status() === 429);
    expect(rateLimited).toBeTruthy();
  });
});
```

---

## Performance Testing

### Response Time

```typescript
test('API responds within acceptable time', async ({ request }) => {
  const start = Date.now();
  const response = await request.get('URL_API/search?q=test');
  const duration = Date.now() - start;
  
  expect(response.ok()).toBeTruthy();
  expect(duration).toBeLessThan(2000); // 2 seconds max
});
```

### Load Testing (Basic)

```typescript
test('handle concurrent requests', async ({ request }) => {
  const concurrentRequests = 10;
  
  const requests = Array.from({ length: concurrentRequests }, () =>
    request.get('URL_API/products')
  );
  
  const responses = await Promise.all(requests);
  
  // All should succeed
  responses.forEach(response => {
    expect(response.ok()).toBeTruthy();
  });
});
```

---

## GraphQL Testing

```typescript
test.describe('GraphQL API', () => {
  test('query users', async ({ request }) => {
    const response = await request.post('URL_API/graphql', {
      data: {
        query: `
          query GetUsers {
            users {
              id
              name
              email
            }
          }
        `
      }
    });
    
    expect(response.ok()).toBeTruthy();
    const { data } = await response.json();
    expect(data.users).toBeInstanceOf(Array);
  });

  test('mutation with variables', async ({ request }) => {
    const response = await request.post('URL_API/graphql', {
      data: {
        query: `
          mutation CreateUser($input: CreateUserInput!) {
            createUser(input: $input) {
              id
              name
            }
          }
        `,
        variables: {
          input: {
            name: 'New User',
            email: 'new@test.com'
          }
        }
      }
    });
    
    const { data, errors } = await response.json();
    expect(errors).toBeUndefined();
    expect(data.createUser.id).toBeDefined();
  });
});
```

---

## Quick Reference

| Task | Code |
|------|------|
| GET request | `request.get(url)` |
| POST JSON | `request.post(url, { data: {...} })` |
| With headers | `request.get(url, { headers: {...} })` |
| Mock response | `page.route(url, route => route.fulfill({...}))` |
| Abort request | `page.route(url, route => route.abort())` |
| Wait for response | `page.waitForResponse(url)` |
| Modify response | `route.fetch()` then `route.fulfill()` |
| Check status | `response.status()` |
| Get JSON | `response.json()` |

---

## Playwright MCP for API Debugging

```
"Navigate to the page that makes API calls"
"Show network requests"
"Check for failed API calls"
"Take a screenshot of the error state"
```

Use `browser_network_requests` to monitor API calls during browser testing.
