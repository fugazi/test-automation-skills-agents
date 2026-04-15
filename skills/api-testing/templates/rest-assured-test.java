import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.*;
import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;

@DisplayName("{Feature} API Tests")
class {Feature}ApiTest {

    @BeforeAll
    static void setup() {
        String apiBaseUrl = System.getenv("API_BASE_URL");
        if (apiBaseUrl == null || apiBaseUrl.isBlank()) {
            throw new IllegalStateException("Missing required environment variable: API_BASE_URL");
        }
        RestAssured.baseURI = apiBaseUrl;
        RestAssured.basePath = "/api/{resource}";
    }

    @Test
    @DisplayName("GET returns list of {resources}")
    void getList() {
        given()
            .header("Authorization", "Bearer " + getToken())
        .when()
            .get()
        .then()
            .statusCode(200)
            .body("data", is(instanceOf(java.util.List.class)));
    }

    @Test
    @DisplayName("POST creates a new {resource}")
    void create() {
        given()
            .contentType(ContentType.JSON)
            .header("Authorization", "Bearer " + getToken())
            .body("{ \"name\": \"Test\" }")
        .when()
            .post()
        .then()
            .statusCode(201);
    }

    @Test
    @DisplayName("GET /:id returns single {resource}")
    void getOne() {
        given()
            .header("Authorization", "Bearer " + getToken())
        .when()
            .get("/1")
        .then()
            .statusCode(200);
    }

    @Test
    @DisplayName("returns 401 without authentication")
    void unauthorized() {
        given()
        .when()
            .get("/protected")
        .then()
            .statusCode(401);
    }

    private String getToken() {
        // Implement token retrieval (env var, auth endpoint, etc.)
        return System.getenv("API_TOKEN");
    }
}
