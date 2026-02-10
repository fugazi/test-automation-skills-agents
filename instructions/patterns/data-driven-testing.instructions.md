---
description: 'Data-driven testing pattern for running tests with multiple data sets. Covers data sources (CSV, JSON, databases), parameterization patterns, and test data generation.'
version: '1.0.0'
category: 'patterns'
applies-to:
  agents: ['test-writer', 'qa-automation', 'api-tester']
  skills: ['test-design', 'data-management', 'parameterization']
  frameworks: ['jest', 'pytest', 'junit', 'testng', 'playwright', 'cypress']
priority: 'recommended'
compliance:
  must-follow: ['Never hardcode test data in test logic', 'Separate test data from test code', 'Use version control for test data files', 'Sanitize data between test runs', 'Ensure data privacy compliance']
  should-follow: ['Use descriptive data identifiers for debugging', 'Validate data before test execution', 'Handle data source failures gracefully', 'Document expected data format']
  can-ignore: ['Hardcoded values for legitimate constant fixtures', 'Simple boolean flag tests where clarity is improved']
---

# Data-Driven Testing Pattern

## Purpose

Data-driven testing (DDT) separates test logic from test data, allowing the same test to run multiple times with different input values. This pattern increases test coverage, reduces code duplication, makes tests more maintainable, and enables easy addition of new test cases without modifying test code.

## Core Concepts

### Separation of Concerns

```
┌─────────────────────────────────────┐
│           Test Runner               │
│  (Executes test with each dataset)  │
└─────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│         Test Logic Layer            │
│  (Test methods, assertions, setup)  │
└─────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│         Data Source Layer           │
│  (CSV, JSON, Database, API, etc.)   │
└─────────────────────────────────────┘
```

### Benefits

1. **Reusability**: Same test logic validates multiple scenarios
2. **Maintainability**: Add test cases by updating data, not code
3. **Coverage**: Easily test edge cases and boundary conditions
4. **Clarity**: Test data visible alongside expected results
5. **Scalability**: Support for hundreds of test cases with single test

## Data Sources

### JSON Data Source

#### Simple JSON Structure

```json
// testdata/login-valid.json
{
  "testCases": [
    {
      "id": "TC001",
      "description": "Login with valid admin credentials",
      "username": "admin@example.com",
      "password": "Admin@123",
      "expectedResult": "success",
      "expectedRedirect": "/dashboard"
    },
    {
      "id": "TC002",
      "description": "Login with valid user credentials",
      "username": "user@example.com",
      "password": "User@123",
      "expectedResult": "success",
      "expectedRedirect": "/home"
    }
  ]
}
```

#### Jest Example with JSON

```javascript
// tests/login.test.js
const loginData = require('../testdata/login-valid.json');

describe.each(loginData.testCases)('$description', ({ id, username, password, expectedResult, expectedRedirect }) => {
  test(`should login successfully for ${id}`, async ({ page }) => {
    const loginPage = new LoginPage(page);

    const dashboardPage = await loginPage.login(username, password);

    expect(dashboardPage.isLoaded()).toBeTruthy();
    expect(page.url()).toContain(expectedRedirect);
  });
});
```

#### Pytest Example with JSON

```python
# tests/test_login.py
import json
import pytest

@pytest.fixture
def login_data():
    with open('testdata/login-valid.json') as f:
        return json.load(f)['testCases']

@pytest.mark.parametrize("test_case", login_data())
def test_valid_login(test_case, page):
    """Test valid login scenarios"""
    login_page = LoginPage(page)

    dashboard_page = login_page.login(
        test_case['username'],
        test_case['password']
    )

    assert dashboard_page.is_loaded()
    assert test_case['expectedRedirect'] in page.url

    # Use test case ID for reporting
    pytest.current_test_node.add_marker(
        pytest.mark.id(test_case['id'])
    )
```

### CSV Data Source

#### CSV Structure

```csv
# testdata/invalid-login.csv
id,description,username,password,expected_error
TC101,Empty username,,password123,Username is required
TC102,Empty password,user@example.com,,Password is required
TC103,Invalid username,invalid@example.com,wrong123,Invalid credentials
TC104,Invalid password,valid@example.com,wrongpass,Invalid credentials
TC105,SQL injection attempt,"admin' OR '1'='1",password,Invalid credentials
```

#### Python CSV Example

```python
# tests/test_login_validation.py
import csv
import pytest

def get_csv_data(csv_path):
    """Read test data from CSV file"""
    test_cases = []
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            test_cases.append(row)
    return test_cases

@pytest.mark.parametrize("test_case", get_csv_data('testdata/invalid-login.csv'))
def test_invalid_login(test_case, page):
    """Test invalid login scenarios"""
    login_page = LoginPage(page)
    login_page.navigate()

    login_page.enter_username(test_case['username'])
    login_page.enter_password(test_case['password'])
    login_page.click_login()

    error_message = login_page.get_error_message()
    assert test_case['expected_error'] in error_message
```

#### Java CSV Example

```java
// tests/LoginValidationTest.java
import com.opencsv.CSVReader;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;

import java.io.FileReader;
import java.util.List;
import java.util.stream.Stream;

class LoginValidationTest {

    static Stream<LoginTestCase> csvDataProvider() throws Exception {
        CSVReader reader = new CSVReader(new FileReader("testdata/invalid-login.csv"));
        List<String[]> rows = reader.readAll();

        // Skip header row
        return rows.stream()
            .skip(1)
            .map(row -> new LoginTestCase(
                row[0], // id
                row[1], // description
                row[2], // username
                row[3], // password
                row[4]  // expected_error
            ));
    }

    @ParameterizedTest(name = "{1}")
    @MethodSource("csvDataProvider")
    void testInvalidLogin(LoginTestCase testCase) {
        LoginPage loginPage = new LoginPage(driver);
        loginPage.navigate();

        loginPage.enterUsername(testCase.username());
        loginPage.enterPassword(testCase.password());
        loginPage.clickLogin();

        String errorMessage = loginPage.getErrorMessage();
        assertTrue(errorMessage.contains(testCase.expectedError()));
    }

    record LoginTestCase(
        String id,
        String description,
        String username,
        String password,
        String expectedError
    ) {}
}
```

### YAML Data Source

#### YAML Structure

```yaml
# testdata/api-tests.yaml
users:
  - id: U001
    name: John Doe
    email: john@example.com
    role: admin
    expected_status: 201

  - id: U002
    name: Jane Smith
    email: jane@example.com
    role: user
    expected_status: 201

login_scenarios:
  - scenario: valid_credentials
    username: admin@example.com
    password: SecurePass123
    expected_status: 200
    expected_token_present: true

  - scenario: invalid_credentials
    username: admin@example.com
    password: WrongPassword
    expected_status: 401
    expected_error: "Invalid credentials"
```

#### Pytest YAML Example

```python
# tests/test_api.py
import pytest
import yaml

@pytest.fixture
def api_data():
    with open('testdata/api-tests.yaml') as f:
        return yaml.safe_load(f)

@pytest.mark.parametrize("user", api_data()['users'])
def test_create_user(api_client, user):
    """Test user creation with various data"""
    response = api_client.create_user({
        'name': user['name'],
        'email': user['email'],
        'role': user['role']
    })

    assert response.status_code == user['expected_status']
    assert response.json()['id'] is not None
```

### Database Data Source

#### Database Connection Example (Python)

```python
# tests/conftest.py
import pytest
import psycopg2

@pytest.fixture
def db_connection():
    """Create database connection for test data"""
    conn = psycopg2.connect(
        host="localhost",
        database="testdb",
        user="testuser",
        password="testpass"
    )
    yield conn
    conn.close()

def get_test_cases_from_db(conn, test_suite):
    """Fetch test cases from database"""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT test_id, description, input_data, expected_result
        FROM test_cases
        WHERE test_suite = %s AND active = true
        ORDER BY test_id
    """, (test_suite,))

    return [
        {
            'test_id': row[0],
            'description': row[1],
            'input_data': row[2],
            'expected_result': row[3]
        }
        for row in cursor.fetchall()
    ]

# tests/test_from_db.py
@pytest.mark.parametrize("test_case", get_test_cases_from_db(conn, "login_tests"))
def test_login_from_db(test_case, page):
    """Test login using database test cases"""
    input_data = json.loads(test_case['input_data'])
    expected_result = json.loads(test_case['expected_result'])

    login_page = LoginPage(page)
    result = login_page.login(input_data['username'], input_data['password'])

    assert result['status'] == expected_result['status']
    assert result['message'] == expected_result['message']
```

#### Database Connection Example (Java)

```java
// tests/DatabaseTestDataProvider.java
import org.junit.jupiter.params.provider.Arguments;

import java.sql.*;
import java.util.stream.Stream;

public class DatabaseTestDataProvider {

    public static Stream<Arguments> getLoginTestCases() {
        List<Arguments> testCases = new ArrayList<>();

        try (Connection conn = DriverManager.getConnection(
                "jdbc:postgresql://localhost/testdb", "testuser", "testpass")) {

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(
                "SELECT test_id, description, username, password, expected_status " +
                "FROM test_cases WHERE test_suite = 'login' AND active = true"
            );

            while (rs.next()) {
                testCases.add(Arguments.of(
                    rs.getString("test_id"),
                    rs.getString("description"),
                    rs.getString("username"),
                    rs.getString("password"),
                    rs.getInt("expected_status")
                ));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to load test data", e);
        }

        return testCases.stream();
    }
}

// tests/LoginTest.java
@ParameterizedTest(name = "{1}")
@MethodSource("DatabaseTestDataProvider#getLoginTestCases")
void testLogin(String testId, String description, String username,
               String password, int expectedStatus) {
    // Test implementation
}
```

### Excel Data Source

#### Python with openpyxl

```python
# tests/test_excel_data.py
import pytest
from openpyxl import load_workbook

def get_excel_data(sheet_name):
    """Read test data from Excel file"""
    wb = load_workbook('testdata/tests.xlsx')
    ws = wb[sheet_name]

    test_cases = []
    headers = [cell.value for cell in ws[1]]

    for row in ws.iter_rows(min_row=2, values_only=True):
        test_cases.append(dict(zip(headers, row)))

    return test_cases

@pytest.mark.parametrize("test_case", get_excel_data('LoginTests'))
def test_login_with_excel(test_case, page):
    login_page = LoginPage(page)
    result = login_page.login(
        test_case['Username'],
        test_case['Password']
    )

    assert result['success'] == test_case['ExpectedSuccess']
```

## Parameterization Patterns

### Simple Parameterization (Jest)

```javascript
// tests/calculator.test.js
describe.each([
  { a: 1, b: 2, expected: 3 },
  { a: 1, b: -2, expected: -1 },
  { a: -1, b: -2, expected: -3 },
  { a: 0, b: 0, expected: 0 },
])('Calculator: add($a, $b)', ({ a, b, expected }) => {
  test(`returns ${expected}`, () => {
    expect(add(a, b)).toBe(expected);
  });
});
```

### Table-Driven Tests (Go)

```go
// login_test.go
package tests

func TestLogin(t *testing.T) {
    tests := []struct {
        name     string
        username string
        password string
        wantErr  bool
        errMsg   string
    }{
        {
            name:     "Valid admin login",
            username: "admin@example.com",
            password: "admin123",
            wantErr:  false,
        },
        {
            name:     "Invalid password",
            username: "admin@example.com",
            password: "wrong",
            wantErr:  true,
            errMsg:   "Invalid credentials",
        },
        {
            name:     "Empty username",
            username: "",
            password: "password",
            wantErr:  true,
            errMsg:   "Username is required",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Login(tt.username, tt.password)

            if tt.wantErr {
                assert.Error(t, result.Error)
                assert.Contains(t, result.Error.Error(), tt.errMsg)
            } else {
                assert.NoError(t, result.Error)
                assert.NotNil(t, result.Token)
            }
        })
    }
}
```

### Pytest Parameterization

```python
# tests/test_calculator.py
import pytest

@pytest.mark.parametrize("a, b, expected", [
    (1, 2, 3),
    (1, -2, -1),
    (-1, -2, -3),
    (0, 0, 0),
    (999, 1, 1000),
])
def test_add(a, b, expected):
    assert add(a, b) == expected

# Parametrize with IDs
@pytest.mark.parametrize("input, expected", [
    ("valid@email.com", True),
    ("invalid-email", False),
    ("@nodomain.com", False),
    ("no@tld", False),
], ids=["valid", "invalid_format", "no_domain", "no_tld"])
def test_email_validation(input, expected):
    assert is_valid_email(input) is expected
```

### JUnit 5 Parameterization

```java
// tests/CalculatorTest.java
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.*;

class CalculatorTest {

    @ParameterizedTest
    @CsvSource({
        "1, 2, 3",
        "1, -2, -1",
        "-1, -2, -3",
        "0, 0, 0"
    })
    void testAdd(int a, int b, int expected) {
        assertEquals(expected, Calculator.add(a, b));
    }

    @ParameterizedTest
    @CsvFileSource(resources = "/login-tests.csv", numLinesToSkip = 1)
    void testLogin(String username, String password, boolean expectedSuccess) {
        boolean result = AuthService.login(username, password);
        assertEquals(expectedSuccess, result);
    }

    @ParameterizedTest
    @MethodSource("provideEdgeCases")
    void testEdgeCases(int input, int expected) {
        assertEquals(expected, Calculator.process(input));
    }

    static Stream<Arguments> provideEdgeCases() {
        return Stream.of(
            Arguments.of(Integer.MIN_VALUE, 0),
            Arguments.of(Integer.MAX_VALUE, 0),
            Arguments.of(-1, -1),
            Arguments.of(0, 0),
            Arguments.of(1, 1)
        );
    }

    @ParameterizedTest
    @EnumSource(value = UserRole.class, names = {"ADMIN", "USER"})
    void testWithRoles(UserRole role) {
        assertTrue(role.hasPermission());
    }
}
```

### TestNG Parameterization

```java
// tests/LoginTest.java
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

public class LoginTest {

    @DataProvider(name = "loginData")
    public Object[][] getLoginData() {
        return new Object[][] {
            {"admin@example.com", "admin123", true},
            {"user@example.com", "user123", true},
            {"wrong@example.com", "wrong", false},
            {"", "password", false},
        };
    }

    @Test(dataProvider = "loginData")
    public void testLogin(String username, String password, boolean expectedSuccess) {
        boolean result = AuthService.login(username, password);
        assertEquals(result, expectedSuccess);
    }

    @DataProvider(name = "userDataFromXML")
    public Object[][] getUserDataFromXML() {
        // Load from XML file
        return loadDataFromXML("testdata/users.xml");
    }

    @Test(dataProvider = "userDataFromXML")
    public void testCreateUser(String name, String email, String role, int expectedStatus) {
        // Test implementation
    }
}
```

### Playwright Data-Driven Tests

```typescript
// tests/login.spec.ts
import { test } from '@playwright/test';

const loginData = [
  {
    name: 'Valid Admin Login',
    username: 'admin@example.com',
    password: 'Admin@123',
    expected: 'success'
  },
  {
    name: 'Invalid Password',
    username: 'admin@example.com',
    password: 'WrongPassword',
    expected: 'error'
  }
];

for (const { name, username, password, expected } of loginData) {
  test(name, async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.navigate();

    const result = await loginPage.login(username, password);

    if (expected === 'success') {
      expect(await result.isSuccess()).toBeTruthy();
    } else {
      expect(await result.getErrorMessage()).toBeTruthy();
    }
  });
}
```

## Test Data Generation

### Faker.js for Synthetic Data

```javascript
// utils/test-data-generator.js
const faker = require('faker');

class TestDataGenerator {
  static user() {
    return {
      firstName: faker.name.firstName(),
      lastName: faker.name.lastName(),
      email: faker.internet.email(),
      phone: faker.phone.phoneNumber(),
      address: {
        street: faker.address.streetAddress(),
        city: faker.address.city(),
        state: faker.address.stateAbbr(),
        zip: faker.address.zipCode(),
        country: faker.address.country()
      },
      dateOfBirth: faker.date.past(30, new Date(2000, 0, 1))
    };
  }

  static users(count) {
    return Array.from({ length: count }, () => this.user());
  }

  static product() {
    return {
      name: faker.commerce.productName(),
      price: parseFloat(faker.commerce.price()),
      category: faker.commerce.department(),
      description: faker.lorem.paragraph(),
      sku: faker.datatype.uuid()
    };
  }

  static order() {
    return {
      orderId: faker.datatype.uuid(),
      customer: this.user(),
      items: [
        {
          product: this.product(),
          quantity: faker.datatype.number({ min: 1, max: 10 })
        }
      ],
      status: faker.helpers.randomize(['pending', 'processing', 'shipped', 'delivered']),
      createdAt: faker.date.recent()
    };
  }
}

module.exports = TestDataGenerator;

// Usage in tests
const testData = TestDataGenerator.users(100); // Generate 100 test users
```

### Python Faker

```python
# utils/test_data_generator.py
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()

class TestDataGenerator:
    @staticmethod
    def user():
        return {
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'email': fake.email(),
            'phone': fake.phone_number(),
            'address': {
                'street': fake.street_address(),
                'city': fake.city(),
                'state': fake.state_abbr(),
                'zip_code': fake.zipcode(),
                'country': fake.country()
            },
            'date_of_birth': fake.date_of_birth(minimum_age=18, maximum_age=90)
        }

    @classmethod
    def users(cls, count):
        return [cls.user() for _ in range(count)]

    @staticmethod
    def product():
        return {
            'name': fake.sentence(nb_words=3)[:-1],
            'price': round(random.uniform(10, 1000), 2),
            'category': fake.word(),
            'description': fake.paragraph(),
            'sku': fake.uuid4()
        }

    @staticmethod
    def order():
        return {
            'order_id': fake.uuid4(),
            'customer': TestDataGenerator.user(),
            'items': [
                {
                    'product': TestDataGenerator.product(),
                    'quantity': random.randint(1, 10)
                }
            ],
            'status': random.choice(['pending', 'processing', 'shipped', 'delivered']),
            'created_at': fake.date_time_this_year()
        }

    @staticmethod
    def date_range(start_date, end_date, count):
        """Generate dates within a range"""
        delta = end_date - start_date
        return [
            start_date + timedelta(days=random.randint(0, delta.days))
            for _ in range(count)
        ]
```

### Boundary Value Data Generation

```python
# utils/boundary_generator.py
class BoundaryValueGenerator:
    """Generate test data for boundary value analysis"""

    @staticmethod
    def numeric_boundaries(min_val, max_val):
        """Generate values at and around boundaries"""
        return [
            min_val - 1,           # Below minimum
            min_val,               # At minimum
            min_val + 1,           # Just above minimum
            (min_val + max_val) // 2,  # Middle value
            max_val - 1,           # Just below maximum
            max_val,               # At maximum
            max_val + 1            # Above maximum
        ]

    @staticmethod
    def string_length_boundaries(min_length, max_length):
        """Generate strings of various boundary lengths"""
        return [
            '',                                     # Empty
            'a' * (min_length - 1),                # Too short
            'a' * min_length,                      # Exactly minimum
            'a' * (min_length + 1),                # Just above minimum
            'a' * ((min_length + max_length) // 2), # Middle
            'a' * (max_length - 1),                # Just below maximum
            'a' * max_length,                      # Exactly maximum
            'a' * (max_length + 1)                 # Too long
        ]

# Usage
@pytest.mark.parametrize("age", BoundaryValueGenerator.numeric_boundaries(18, 100))
def test_age_validation(age):
    is_valid = validate_age(age)
    expected = 18 <= age <= 100
    assert is_valid == expected
```

### Random Data Generation with Seeding

```javascript
// utils/random-seed.js
class SeededRandomGenerator {
  constructor(seed = 12345) {
    this.seed = seed;
  }

  // Simple linear congruential generator
  next() {
    this.seed = (this.seed * 1103515245 + 12345) & 0x7fffffff;
    return this.seed / 0x7fffffff;
  }

  nextInt(min, max) {
    return Math.floor(this.next() * (max - min + 1)) + min;
  }

  nextString(length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(this.nextInt(0, chars.length - 1));
    }
    return result;
  }

  nextEmail() {
    return `user${this.nextInt(1, 10000)}@example.com`;
  }

  // Reproducible test data
  generateUserData(id) {
    return {
      id: id,
      username: `user${id}`,
      email: `user${id}@example.com`,
      age: this.nextInt(18, 80),
      score: this.nextInt(0, 100)
    };
  }
}

// Usage: Same seed always produces same data
const gen1 = new SeededRandomGenerator(12345);
const gen2 = new SeededRandomGenerator(12345);
console.log(gen1.nextEmail()); // Same as gen2.nextEmail()
```

## Combining Multiple Data Sources

### Pytest Example

```python
# tests/test_combined_data.py
import pytest
import json
import yaml

def get_combined_test_data():
    """Combine data from multiple sources"""
    # Load base configurations
    with open('testdata/base-configs.yaml') as f:
        configs = yaml.safe_load(f)

    # Load variations
    with open('testdata/variations.json') as f:
        variations = json.load(f)

    # Combine
    test_cases = []
    for config in configs['configs']:
        for variation in variations['variations']:
            test_cases.append({
                **config,
                **variation,
                'test_id': f"{config['name']}_{variation['name']}"
            })

    return test_cases

@pytest.mark.parametrize("test_case", get_combined_test_data())
def test_with_combined_data(test_case, page):
    # Test using combined configuration
    pass
```

## Dynamic Test Creation

### Pytest Dynamic Tests

```python
# tests/test_dynamic.py
import pytest

def pytest_generate_tests(metafunc):
    """Generate tests dynamically based on data"""
    if 'browser' in metafunc.fixturenames:
        # Read browsers from config file
        browsers = load_config('browsers.json')
        metafunc.parametrize('browser', browsers)

    if 'test_data' in metafunc.fixturenames:
        # Generate test cases based on data
        test_cases = generate_test_cases_from_api()
        metafunc.parametrize('test_data', test_cases, ids=lambda x: x['id'])

# Alternative: Using pytest hook
def pytest_collection_modifyitems(session, config, items):
    """Modify test collection dynamically"""
    for item in items:
        # Add markers based on test data
        if 'slow' in item.name:
            item.add_marker(pytest.mark.slow)
```

### Jest Dynamic Tests

```javascript
// tests/dynamic.test.js
const testData = require('../testdata/dynamic-cases.json');

describe('Dynamic API Tests', () => {
  testData.cases.forEach((testCase) => {
    test(testCase.description, async () => {
      const response = await apiClient.execute(testCase.request);

      if (testCase.expectedSuccess) {
        expect(response.status).toBe(testCase.expectedStatus);
        expect(response.data).toMatchObject(testCase.expectedResponse);
      } else {
        expect(response.status).toBeGreaterThanOrEqual(400);
      }
    });
  });
});
```

## Best Practices

1. **Keep Data External**: Store test data separate from test code
2. **Use Version Control**: Commit test data files alongside tests
3. **Document Data Format**: Include schema or README for data files
4. **Validate Data**: Check data integrity before test execution
5. **Use Descriptive IDs**: Include test case IDs for traceability
6. **Handle Failures Gracefully**: Continue with remaining test cases on failure
7. **Sanitize Between Runs**: Clean up test data between test runs
8. **Use Factories**: Create data generation for complex objects
9. **Consider Privacy**: Mask or anonymize sensitive test data
10. **Balance Coverage**: Don't create excessive test cases without value
