import { test, expect } from "@playwright/test";

test.describe("{Feature} API", () => {
  const baseUrl = "/api/{resource}";

  test("GET returns list of {resources}", async ({ request }) => {
    const response = await request.get(baseUrl);
    expect(response.ok()).toBeTruthy();
    const body = await response.json();
    expect(Array.isArray(body.data)).toBeTruthy();
  });

  test("POST creates a new {resource}", async ({ request }) => {
    const response = await request.post(baseUrl, {
      data: {
        /* test data */
      },
    });
    expect(response.status()).toBe(201);
  });

  test("GET /:id returns single {resource}", async ({ request }) => {
    const response = await request.get(`${baseUrl}/1`);
    expect(response.ok()).toBeTruthy();
  });

  test("PUT /:id updates {resource}", async ({ request }) => {
    const response = await request.put(`${baseUrl}/1`, {
      data: {
        /* updated data */
      },
    });
    expect(response.ok()).toBeTruthy();
  });

  test("DELETE /:id removes {resource}", async ({ request }) => {
    const response = await request.delete(`${baseUrl}/1`);
    expect(response.status()).toBe(204);
  });

  test("returns 401 without authentication", async ({ request }) => {
    const response = await request.get(`${baseUrl}/protected`);
    expect(response.status()).toBe(401);
  });

  test("returns 400 for invalid payload", async ({ request }) => {
    const response = await request.post(baseUrl, {
      data: { invalid: "data" },
    });
    expect(response.status()).toBe(400);
  });
});
