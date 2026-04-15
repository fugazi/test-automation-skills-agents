# REST Assured Testing

Detailed reference for API testing with REST Assured 5.x, AssertJ, and JSON Schema Validator in Java 21+.

## Base Test Class

```java
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;
import static org.assertj.core.api.Assertions.*;

public class UserApiTest {

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = System.getenv().getOrDefault("API_BASE_URL", "http://localhost:3000");
        RestAssured.basePath = "/api";
    }
}
```

## CRUD Tests

### Create (POST)

```java
@Test
@DisplayName("POST /users creates a new user")
void createUser() {
    String requestBody = """
        {
            "name": "Test User",
            "email": "test@example.com"
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
        .body("name", equalTo("Test User"))
        .body("email", equalTo("test@example.com"));
}
```

### Read (GET)

```java
@Test
@DisplayName("GET /users returns paginated list")
void getUsersPaginated() {
    given()
        .queryParam("offset", 0)
        .queryParam("limit", 10)
    .when()
        .get("/users")
    .then()
        .statusCode(200)
        .body("data.size()", lessThanOrEqualTo(10))
        .body("pagination.total", greaterThan(0));
}

@Test
@DisplayName("GET /users/:id returns single user")
void getUserById() {
    given()
    .when()
        .get("/users/1")
    .then()
        .statusCode(200)
        .body("id", notNullValue())
        .body("name", notNullValue());
}
```

### Update (PUT/PATCH)

```java
@Test
@DisplayName("PUT /users/:id updates user")
void updateUser() {
    String updateBody = """
        {
            "name": "Updated Name"
        }
        """;

    given()
        .contentType(ContentType.JSON)
        .body(updateBody)
    .when()
        .put("/users/1")
    .then()
        .statusCode(200)
        .body("name", equalTo("Updated Name"));
}
```

### Delete

```java
@Test
@DisplayName("DELETE /users/:id removes user")
void deleteUser() {
    given()
    .when()
        .delete("/users/1")
    .then()
        .statusCode(204);
}
```

## Authentication Testing

```java
@Test
@DisplayName("GET /admin/users returns 401 without token")
void adminUsersRequiresAuth() {
    given()
    .when()
        .get("/admin/users")
    .then()
        .statusCode(401);
}

@Test
@DisplayName("GET /admin/users returns 200 with valid token")
void adminUsersWithAuth() {
    given()
        .header("Authorization", "Bearer " + getAdminToken())
    .when()
        .get("/admin/users")
    .then()
        .statusCode(200);
}
```

## Schema Validation

Using `json-schema-validator`:

```java
import io.restassured.module.jsv.JsonSchemaValidator;

@Test
@DisplayName("Response matches user JSON schema")
void validateUserSchema() {
    given()
    .when()
        .get("/users/1")
    .then()
        .statusCode(200)
        .body(JsonSchemaValidator.matchesJsonSchemaInClasspath("schemas/user-schema.json"));
}
```

## Deserialization with AssertJ

```java
@Test
@DisplayName("Deserialize and validate user object")
void deserializeUser() {
    User user = given()
    .when()
        .get("/users/1")
    .then()
        .statusCode(200)
        .extract()
        .as(User.class);

    SoftAssertions.assertSoftly(softly -> {
        softly.assertThat(user.getName()).as("Name").isNotBlank();
        softly.assertThat(user.getEmail()).as("Email").contains("@");
        softly.assertThat(user.getId()).as("ID").isNotNull();
    });
}
```

## Error Response Testing

```java
@Test
@DisplayName("POST /users returns 400 for invalid input")
void createUserInvalidInput() {
    String invalidBody = """
        {
            "name": "",
            "email": "not-an-email"
        }
        """;

    given()
        .contentType(ContentType.JSON)
        .body(invalidBody)
    .when()
        .post("/users")
    .then()
        .statusCode(400)
        .body("error.code", equalTo("VALIDATION_ERROR"))
        .body("error.details.size()", greaterThan(0));
}
```
