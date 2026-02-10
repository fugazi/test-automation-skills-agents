---
description: 'REST Assured framework for API testing in Java. Covers setup, HTTP methods (GET, POST, PUT, DELETE), authentication, headers, and response validation patterns.'
version: '1.0.0'
category: 'frameworks'
applies-to:
  agents: ['test-writer', 'api-tester', 'qa-automation']
  skills: ['api-testing', 'rest-api-testing', 'java-testing']
  frameworks: ['rest-assured', 'junit', 'testng', 'maven', 'gradle']
priority: 'recommended'
compliance:
  must-follow: ['Always use REST Assured DSL methods (given/when/then)', 'Implement proper response validation', 'Handle authentication securely (never hardcode credentials)', 'Use proper HTTP methods for each operation']
  should-follow: ['Use static imports for cleaner DSL', 'Implement reusable request specifications', 'Add proper assertions for both status and body', 'Log responses for debugging in test setup']
  can-ignore: ['Logging in production test runs for performance', 'Additional headers when not required by API']
---

# REST Assured Testing Framework

## Purpose

REST Assured is a Java DSL for testing REST services. It simplifies testing of REST APIs by providing a fluent interface with given-when-then syntax, making tests readable and maintainable.

## Setup and Configuration

### Maven Dependency

```xml
<dependency>
    <groupId>io.rest-assured</groupId>
    <artifactId>rest-assured</artifactId>
    <version>5.4.0</version>
    <scope>test</scope>
</dependency>
```

### Gradle Dependency

```groovy
testImplementation 'io.rest-assured:rest-assured:5.4.0'
```

### Static Imports (Recommended)

```java
import static io.restassured.RestAssured.*;
import static io.rest-assured.matcher.RestAssuredMatchers.*;
import static org.hamcrest.Matchers.*;
```

### Base Configuration

```java
@BeforeClass
public static void setup() {
    RestAssured.baseURI = "https://api.example.com";
    RestAssured.basePath = "/v1";
    RestAssured.authentication = oauth2("your-token");
}
```

## HTTP Method Patterns

### GET Request

```java
@Test
public void getUsersTest() {
    given()
        .queryParam("page", 1)
        .queryParam("limit", 10)
    .when()
        .get("/users")
    .then()
        .statusCode(200)
        .body("size()", equalTo(10))
        .body("[0].name", notNullValue())
        .body("[0].email", containsString("@"));
}

// Get single resource
@Test
public void getUserByIdTest() {
    given()
        .pathParam("userId", 123)
    .when()
        .get("/users/{userId}")
    .then()
        .statusCode(200)
        .body("id", equalTo(123))
        .body("name", notNullValue());
}
```

### POST Request

```java
@Test
public void createUserTest() {
    String requestBody = """
        {
            "name": "John Doe",
            "email": "john.doe@example.com",
            "role": "developer"
        }
        """;

    given()
        .contentType(ContentType.JSON)
        .body(requestBody)
    .when()
        .post("/users")
    .then()
        .statusCode(201)
        .body("id", notNullValue())
        .body("name", equalTo("John Doe"))
        .body("email", equalTo("john.doe@example.com"));
}

// Using POJO for request body
@Test
public void createUserWithPojotest() {
    User user = new User("Jane Doe", "jane@example.com");

    given()
        .contentType(ContentType.JSON)
        .body(user)
    .when()
        .post("/users")
    .then()
        .statusCode(201)
        .body("id", notNullValue());
}
```

### PUT Request

```java
@Test
public void updateUserTest() {
    String updateBody = """
        {
            "name": "John Smith",
            "email": "john.smith@example.com"
        }
        """;

    given()
        .pathParam("userId", 123)
        .contentType(ContentType.JSON)
        .body(updateBody)
    .when()
        .put("/users/{userId}")
    .then()
        .statusCode(200)
        .body("id", equalTo(123))
        .body("name", equalTo("John Smith"));
}
```

### DELETE Request

```java
@Test
public void deleteUserTest() {
    given()
        .pathParam("userId", 123)
    .when()
        .delete("/users/{userId}")
    .then()
        .statusCode(204);
}

// Verify deletion
@Test
public void verifyUserDeletedTest() {
    given()
        .pathParam("userId", 123)
    .when()
        .get("/users/{userId}")
    .then()
        .statusCode(404);
}
```

## Authentication and Headers

### Bearer Token Authentication

```java
@Test
public void authenticatedRequestTest() {
    given()
        .auth().oauth2("your-access-token")
    .when()
        .get("/protected/users")
    .then()
        .statusCode(200);
}
```

### Basic Authentication

```java
given()
    .auth().basic("username", "password")
.when()
    .get("/protected/resource")
.then()
    .statusCode(200);
```

### API Key Authentication

```java
given()
    .header("X-API-Key", "your-api-key")
.when()
    .get("/protected/resource")
.then()
    .statusCode(200);
```

### Custom Headers

```java
given()
    .header("Content-Type", "application/json")
    .header("Accept", "application/json")
    .header("X-Custom-Header", "custom-value")
    .header("X-Request-ID", UUID.randomUUID().toString())
.when()
    .get("/resource")
.then()
    .statusCode(200);
```

### Request Specification (Reusable)

```java
public class BaseApiTest {
    protected RequestSpecification requestSpec;

    @Before
    public void setupRequestSpec() {
        requestSpec = new RequestSpecBuilder()
            .setBaseUri("https://api.example.com")
            .setBasePath("/v1")
            .setContentType(ContentType.JSON)
            .addHeader("X-API-Key", System.getenv("API_KEY"))
            .log(LogDetail.ALL)
            .build();
    }
}

// Using the spec
@Test
public void testWithSpec() {
    given()
        .spec(requestSpec)
    .when()
        .get("/users")
    .then()
        .statusCode(200);
}
```

## Response Validation

### Status Code Validation

```java
// Single status code
.then().statusCode(200)

// Multiple acceptable status codes
.then().statusCode(anyOf(is(200), is(201)))

// Status code matching
.then().statusCode(equalTo(200))
```

### Body Validation with Matchers

```java
@Test
public void validateResponseBodyTest() {
    given()
    .when()
        .get("/users/123")
    .then()
        .statusCode(200)
        // Simple field validation
        .body("id", equalTo(123))
        .body("name", equalTo("John Doe"))
        // Nested fields
        .body("address.city", equalTo("New York"))
        // Array validation
        .body("roles.size()", equalTo(2))
        .body("roles[0]", equalTo("admin"))
        // Collection matching
        .body("roles", hasItem("admin"))
        .body("roles", hasItems("admin", "user"))
        // Null checks
        .body("deletedAt", nullValue())
        .body("createdAt", notNullValue());
}
```

### JSON Path Validation

```java
// Validate multiple fields
.then()
    .body("data.size()", greaterThan(0))
    .body("data.findAll {it.status == 'active'}.size()", greaterThan(0))
    .body("data.find {it.id == 123}.name", equalTo("John Doe"))

// Validate response structure
.then()
    .body("$", hasKey("data"))
    .body("data", hasKey("users"))
    .body("data.users", everyItem(hasKey("id")))
```

### Extracting Response Data

```java
// Extract full response
String responseBody = get("/users/123").asString();

// Extract specific field
int userId = get("/users/123")
    .jsonPath()
    .getInt("id");

String userName = get("/users/123")
    .jsonPath()
    .getString("name");

// Extract to POJO
User user = get("/users/123")
    .jsonPath()
    .getObject(".", User.class);

// Extract and use in subsequent test
String userId = given()
    .body(newUser)
.when()
    .post("/users")
.then()
    .statusCode(201)
    .extract()
    .path("id");
```

### Schema Validation

```java
// JSON Schema validation
given()
    .get("/users/123")
.then()
    .statusCode(200)
    .body(matchesJsonSchemaInClasspath("schemas/user-schema.json"));
```

## Advanced Patterns

### Chained Requests (Test Workflow)

```java
@Test
public void userWorkflowTest() {
    // 1. Create user
    String userId = given()
        .body(createUserRequest())
    .when()
        .post("/users")
    .then()
        .statusCode(201)
        .extract().path("id");

    // 2. Get created user
    given()
        .pathParam("userId", userId)
    .when()
        .get("/users/{userId}")
    .then()
        .statusCode(200)
        .body("id", equalTo(userId));

    // 3. Update user
    given()
        .pathParam("userId", userId)
        .body(updateUserRequest())
    .when()
        .put("/users/{userId}")
    .then()
        .statusCode(200)
        .body("name", equalTo("Updated Name"));

    // 4. Delete user
    given()
        .pathParam("userId", userId)
    .when()
        .delete("/users/{userId}")
    .then()
        .statusCode(204);
}
```

### Error Handling Validation

```java
@Test
public void validationErrorTest() {
    given()
        .body("{ \"invalid\": \"data\" }")
    .when()
        .post("/users")
    .then()
        .statusCode(400)
        .body("error", equalTo("Validation Error"))
        .body("message", notNullValue())
        .body("fieldErrors", not(empty()));
}

@Test
public void notFoundTest() {
    given()
        .pathParam("userId", 99999)
    .when()
        .get("/users/{userId}")
    .then()
        .statusCode(404)
        .body("error", equalTo("Not Found"));
}
```

### Logging and Debugging

```java
// Log all request and response details
given()
    .log().all()
.when()
    .get("/users")
.then()
    .log().all();

// Log only on failure
given()
    .log().ifValidationFails()
.when()
    .get("/users")
.then()
    .log().ifValidationFails();

// Log specific details
given()
    .log().params()    // Query params, form params
    .log().body()     // Request body
.when()
    .get("/users")
.then()
    .log().status()   // Status line
    .log().body();    // Response body
```

### Filter Configuration

```java
// Global filters
RestAssured.filters(
    new RequestLoggingFilter(LogDetail.ALL),
    new ResponseLoggingFilter(LogDetail.ALL)
);

// Timing filter
given()
    .filter(new ResponseTimeFilter())
.when()
    .get("/users")
.then()
    .statusCode(200);
```

## Complete Test Class Example

```java
import static io.restassured.RestAssured.*;
import static io.restassured.matcher.RestAssuredMatchers.*;
import static org.hamcrest.Matchers.*;
import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.specification.RequestSpecification;

public class UserApiTest {

    private RequestSpecification requestSpec;

    @BeforeClass
    public static void globalSetup() {
        RestAssured.baseURI = "https://api.example.com";
        RestAssured.basePath = "/v1";
    }

    @Before
    public void setup() {
        requestSpec = new RequestSpecBuilder()
            .setContentType(ContentType.JSON)
            .addHeader("X-API-Key", System.getenv("API_KEY"))
            .log(LogDetail.ALL)
            .build();
    }

    @Test
    public void getUsers_ShouldReturn200() {
        given()
            .spec(requestSpec)
        .when()
            .get("/users")
        .then()
            .statusCode(200)
            .body("data", not(empty()));
    }

    @Test
    public void createUser_ShouldReturn201() {
        User user = new User("Test User", "test@example.com");

        given()
            .spec(requestSpec)
            .body(user)
        .when()
            .post("/users")
        .then()
            .statusCode(201)
            .body("id", notNullValue())
            .body("name", equalTo("Test User"))
            .body("email", equalTo("test@example.com"));
    }

    @Test
    public void getUserById_ShouldReturnUser() {
        given()
            .spec(requestSpec)
            .pathParam("userId", 1)
        .when()
            .get("/users/{userId}")
        .then()
            .statusCode(200)
            .body("id", equalTo(1))
            .body("name", notNullValue());
    }
}
```

## Best Practices

1. **Use Static Imports**: Import REST Assured static methods for cleaner, fluent DSL syntax
2. **Create Reusable Specifications**: Use `RequestSpecBuilder` for common request configurations
3. **Validate Responses Thoroughly**: Check both status codes and response body content
4. **Use Path Parameters**: For dynamic values in URLs (e.g., `/users/{id}`)
5. **Handle Authentication Securely**: Use environment variables or config files for credentials
6. **Implement Proper Assertions**: Use Hamcrest matchers for readable assertions
7. **Log for Debugging**: Use request/response logging during test development
8. **Extract When Needed**: Extract values from responses for use in chained requests
9. **Test Error Cases**: Validate API behavior with invalid inputs
10. **Use POJOs**: For complex request/response bodies, use Java classes

## Common Matchers Reference

| Matcher | Description | Example |
|---------|-------------|---------|
| `equalTo(value)` | Exact match | `body("name", equalTo("John"))` |
| `hasItem(value)` | Contains item | `body("items", hasItem("apple"))` |
| `hasItems(...)` | Contains items | `body("items", hasItems("a", "b"))` |
| `nullValue()` | Is null | `body("deletedAt", nullValue())` |
| `notNullValue()` | Is not null | `body("id", notNullValue())` |
| `greaterThan(n)` | Greater than | `body("count", greaterThan(0))` |
| `lessThan(n)` | Less than | `body("age", lessThan(100))` |
| `containsString(s)` | Contains substring | `body("email", containsString("@"))` |
| `everyItem(matcher)` | All items match | `body("users", everyItem(hasKey("id")))` |
| `hasKey(key)` | Has key | `body("$", hasKey("data"))` |
