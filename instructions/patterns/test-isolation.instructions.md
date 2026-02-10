---
description: 'Test isolation pattern for ensuring tests do not affect each other. Covers isolation strategies, setup and teardown patterns, state management, and anti-patterns.'
version: '1.0.0'
category: 'patterns'
applies-to:
  agents: ['test-writer', 'qa-automation', 'test-framework-developer']
  skills: ['test-design', 'test-maintenance', 'state-management']
  frameworks: ['jest', 'pytest', 'junit', 'testng', 'playwright', 'cypress', 'selenium']
priority: 'recommended'
compliance:
  must-follow: ['Each test must be able to run independently', 'Tests must not depend on execution order', 'Clean up all state changes after each test', 'Never share mutable state between tests', 'Use fresh fixtures for each test']
  should-follow: ['Reset database state between tests', 'Clean up files and temporary resources', 'Isolate external dependencies with mocks/stubs', 'Use unique identifiers for test data']
  can-ignore: ['Read-only shared immutable data', 'Expensive setup in performance tests with documented dependencies']
---

# Test Isolation Pattern

## Purpose

Test isolation ensures that each test runs independently without affecting or being affected by other tests. Isolated tests are more reliable, easier to debug, and can run in parallel for faster execution. When tests share state or depend on execution order, they become flaky and maintenance becomes difficult.

## Core Principles

1. **Independence**: Each test must run in complete isolation
2. **No Shared State**: Tests must not share mutable state
3. **Order Independence**: Tests must pass regardless of execution order
4. **Idempotency**: Running the same test multiple times should produce the same result
5. **Clean Slate**: Each test starts with a known, clean state

## Isolation Strategies

### 1. Test Scope Isolation

Each test should create and destroy its own data and state.

**Anti-Pattern (Shared State):**
```javascript
let user;

beforeAll(() => {
  // DON'T: Shared state across all tests
  user = createUser({ name: 'Test User' });
});

test('update user', () => {
  user.name = 'Updated Name';
  updateUser(user);
  expect(user.name).toBe('Updated Name');
});

test('delete user', () => {
  deleteUser(user.id);
  // DON'T: This affects other tests
});
```

**Correct Pattern (Isolated):**
```javascript
test('update user', async () => {
  // DO: Create fresh data for each test
  const user = await createUser({ name: 'Test User' });
  await updateUser(user.id, { name: 'Updated Name' });

  const updated = await getUser(user.id);
  expect(updated.name).toBe('Updated Name');
});

test('delete user', async () => {
  // DO: Fresh data, independent of other tests
  const user = await createUser({ name: 'Test User' });
  await deleteUser(user.id);

  const deleted = await getUser(user.id);
  expect(deleted).toBeNull();
});
```

### 2. Database Isolation

#### Transaction Rollback Pattern

```python
# tests/conftest.py
import pytest

@pytest.fixture
def db_session(db_connection):
    """Create a transaction that rolls back after each test"""
    transaction = db_connection.begin()
    session = Session(bind=db_connection)

    yield session

    # Rollback after test
    session.close()
    transaction.rollback()

# Tests use the session
def test_create_user(db_session):
    user = User(name="Test")
    db_session.add(user)
    db_session.commit()

    # Changes are rolled back after test
    assert db_session.query(User).count() == 1
```

#### Database Cleanup Pattern

```python
@pytest.fixture
def clean_database(db_connection):
    """Clean database before and after each test"""
    # Clean before
    db_connection.execute("TRUNCATE TABLE users CASCADE")
    db_connection.execute("TRUNCATE TABLE orders CASCADE")

    yield

    # Clean after
    db_connection.execute("TRUNCATE TABLE users CASCADE")
    db_connection.execute("TRUNCATE TABLE orders CASCADE")

# Alternative: Use test schema
@pytest.fixture
def test_schema(db_connection):
    """Create and use a fresh test schema"""
    schema_name = f"test_schema_{uuid.uuid4().hex[:8]}"

    # Create schema
    db_connection.execute(f"CREATE SCHEMA {schema_name}")
    db_connection.execute(f"SET search_path TO {schema_name}")

    # Run migrations
    run_migrations(schema_name)

    yield

    # Drop schema
    db_connection.execute(f"DROP SCHEMA {schema_name} CASCADE")
```

### 3. File System Isolation

```python
# tests/conftest.py
import pytest
import tempfile
import shutil

@pytest.fixture
def temp_dir():
    """Create a temporary directory that is cleaned up after test"""
    temp_path = tempfile.mkdtemp()

    yield temp_path

    # Cleanup: remove directory and all contents
    shutil.rmtree(temp_path)

# Usage
def test_file_processing(temp_dir):
    test_file = os.path.join(temp_dir, "test.txt")
    with open(test_file, "w") as f:
        f.write("test content")

    result = process_file(test_file)

    # temp_dir is automatically cleaned up
    assert result.success
```

```javascript
// tests/setup.js
const fs = require('fs-extra');
const tempy = require('tempy');

beforeEach(async () => {
  // Create temporary directory for this test
  global.tempDir = tempy.directory();
});

afterEach(async () => {
  // Clean up temporary directory
  await fs.remove(global.tempDir);
});

// Usage
test('processes files', async () => {
  const testFile = path.join(global.tempDir, 'test.txt');
  await fs.writeFile(testFile, 'content');

  const result = await processFile(testFile);

  expect(result.success).toBe(true);
});
```

### 4. HTTP Request Isolation

```python
# tests/conftest.py
import pytest

@pytest.fixture
def mock_api():
    """Isolate external API calls"""
    with responses.RequestsMock() as rsps:
        # Add mock responses
        rsps.add(
            responses.POST,
            'https://api.example.com/users',
            status=201,
            json={'id': '123', 'name': 'Test User'}
        )
        yield rsps

# Test is isolated from real API
def test_create_user(mock_api, client):
    response = client.create_user({'name': 'Test'})

    assert response.status_code == 201
    assert mock_api.call_count == 1
```

```javascript
// tests/api.test.js
import { rest } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  rest.post('https://api.example.com/users', (req, res, ctx) => {
    return res(ctx.status(201), ctx.json({ id: '123', name: 'Test User' }));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('creates user', async () => {
  // Test is isolated from real API
  const response = await apiClient.createUser({ name: 'Test' });

  expect(response.status).toBe(201);
});
```

### 5. Browser/Session Isolation (Playwright)

```typescript
// tests/fixtures.ts
import { test as base } from '@playwright/test';

type CustomFixtures = {
  authenticatedPage: Page;
  cleanDatabase: void;
};

export const test = base.extend<CustomFixtures>({
  authenticatedPage: async ({ page }, use) => {
    // Create fresh user for each test
    const user = await createTestUser();

    // Login
    await page.goto('/login');
    await page.fill('[data-testid="username"]', user.email);
    await page.fill('[data-testid="password"]', user.password);
    await page.click('[data-testid="login-button"]');

    await use(page);

    // Cleanup
    await deleteTestUser(user.id);
    await page.context().clearCookies();
  },

  cleanDatabase: async ({}, use) => {
    // Reset database state
    await db.truncateAllTables();

    await use();

    // Clean up after test
    await db.truncateAllTables();
  },
});
```

### 6. Environment Variable Isolation

```python
# tests/conftest.py
import pytest
import os

@pytest.fixture
def clean_env():
    """Save and restore environment variables"""
    # Save original environment
    original_env = os.environ.copy()

    yield

    # Restore original environment
    os.environ.clear()
    os.environ.update(original_env)

# Usage
def test_with_env_vars(clean_env, monkeypatch):
    monkeypatch.setenv('API_KEY', 'test-key')
    monkeypatch.setenv('DEBUG', 'true')

    # Test with isolated environment
    result = get_config()

    assert result.api_key == 'test-key'

    # Environment is restored after test
```

```javascript
// tests/setup.js
const originalEnv = { ...process.env };

beforeEach(() => {
  // Reset to original environment before each test
  process.env = { ...originalEnv };
});

afterEach(() => {
  // Restore original environment
  process.env = { ...originalEnv };
});

// Usage
test('reads config', () => {
  process.env.API_KEY = 'test-key';

  const config = getConfig();

  expect(config.apiKey).toBe('test-key');
});
```

### 7. Time Isolation

```python
# tests/conftest.py
import pytest
from freezegun import freeze_time

@pytest.fixture
def frozen_time():
    """Freeze time for deterministic tests"""
    with freeze_time('2024-01-01 12:00:00'):
        yield

# Usage
def test_time_based_logic(frozen_time):
    user = create_user()
    assert user.created_at == datetime(2024, 1, 1, 12, 0, 0)
```

```javascript
// tests/time.test.js
import { jest } from '@jest/globals';

beforeEach(() => {
  // Mock Date to return consistent time
  jest.useFakeTimers();
  jest.setSystemTime(new Date('2024-01-01T12:00:00Z'));
});

afterEach(() => {
  // Restore real time
  jest.useRealTimers();
});

test('time-based calculation', () => {
  const user = createUser();
  expect(user.createdAt).toBe(new Date('2024-01-01T12:00:00Z'));
});
```

## Setup and Teardown Patterns

### Jest Setup/Teardown

```javascript
// tests/setup.js

// Per-file setup (before all tests in file)
beforeAll(() => {
  // Initialize shared resources (read-only)
  initializeTestDatabase();
});

// Per-file teardown (after all tests in file)
afterAll(() => {
  // Cleanup shared resources
  closeDatabaseConnection();
});

// Per-test setup
beforeEach(() => {
  // Reset state for each test
  resetDatabase();
  clearCache();
});

// Per-test teardown
afterEach(async () => {
  // Clean up after each test
  await cleanupTempFiles();
  await clearSession();
});

// Test suite with setup/teardown
describe('User Operations', () => {
  let userId;

  beforeEach(async () => {
    // Create fresh user for each test
    const user = await createTestUser();
    userId = user.id;
  });

  afterEach(async () => {
    // Clean up user
    if (userId) {
      await deleteTestUser(userId);
    }
  });

  test('should update user', async () => {
    await updateUser(userId, { name: 'Updated' });
    const user = await getUser(userId);
    expect(user.name).toBe('Updated');
  });

  test('should delete user', async () => {
    await deleteUser(userId);
    const user = await getUser(userId);
    expect(user).toBeNull();
  });
});
```

### Pytest Setup/Teardown

```python
# tests/conftest.py

import pytest

# Session scope (once per test session)
@pytest.fixture(scope="session")
def database_engine():
    """Initialize database connection for all tests"""
    engine = create_engine(os.getenv('TEST_DATABASE_URL'))
    yield engine
    engine.dispose()

# Module scope (once per module)
@pytest.fixture(scope="module")
def api_client():
    """Initialize API client for module"""
    client = APIClient()
    yield client
    client.close()

# Function scope (each test function) - DEFAULT
@pytest.fixture
def db_session(database_engine):
    """Create fresh session for each test"""
    connection = database_engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection)

    yield session

    session.close()
    transaction.rollback()
    connection.close()

# Class scope (once per test class)
@pytest.fixture(scope="class")
def authenticated_client():
    """Create authenticated client for test class"""
    client = APIClient()
    client.login('test@example.com', 'password')
    yield client
    client.logout()

# Autouse fixtures (automatically used by all tests)
@pytest.fixture(autouse=True)
def reset_time():
    """Freeze time for all tests"""
    with freeze_time('2024-01-01'):
        yield

@pytest.fixture(autouse=True)
def clean_redis():
    """Clear Redis before each test"""
    redis_client.flushdb()
    yield
    redis_client.flushdb()

# Test class with fixtures
class TestUserOperations:

    @pytest.fixture(autouse=True)
    def setup_user(self, db_session):
        """Automatically create and cleanup user for all tests in class"""
        user = User(name='Test User', email='test@example.com')
        db_session.add(user)
        db_session.commit()
        self.user_id = user.id

        yield

        # Cleanup
        db_session.query(User).filter_by(id=self.user_id).delete()
        db_session.commit()

    def test_update_user(self, db_session):
        user = db_session.query(User).get(self.user_id)
        user.name = 'Updated'
        db_session.commit()

        updated = db_session.query(User).get(self.user_id)
        assert updated.name == 'Updated'
```

### JUnit 5 Setup/Teardown

```java
// tests/UserTest.java
import org.junit.jupiter.api.*;

@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class UserTest {

    private UserService userService;
    private DatabaseCleaner dbCleaner;

    @BeforeAll
    static void setUpClass() {
        // Run once before all tests in class
        initializeTestDatabase();
    }

    @AfterAll
    static void tearDownClass() {
        // Run once after all tests in class
        shutdownTestDatabase();
    }

    @BeforeEach
    void setUp() {
        // Run before each test
        userService = new UserService();
        dbCleaner = new DatabaseCleaner();
        dbCleaner.cleanAllTables();
    }

    @AfterEach
    void tearDown() {
        // Run after each test
        dbCleaner.cleanAllTables();
        userService = null;
    }

    @Test
    void testCreateUser() {
        User user = userService.create("test@example.com", "password");

        assertNotNull(user.getId());
    }

    @Test
    void testDeleteUser() {
        User user = userService.create("test@example.com", "password");

        userService.delete(user.getId());

        assertNull(userService.findById(user.getId()));
    }

    // Nested test classes with their own setup
    @Nested
    class WhenUserExists {

        private Long userId;

        @BeforeEach
        void createExistingUser() {
            User user = userService.create("existing@example.com", "password");
            userId = user.getId();
        }

        @Test
        void shouldAllowUpdate() {
            userService.update(userId, "updated@example.com");

            User updated = userService.findById(userId);
            assertEquals("updated@example.com", updated.getEmail());
        }

        @Test
        void shouldAllowDeletion() {
            userService.delete(userId);

            assertNull(userService.findById(userId));
        }
    }
}
```

### Playwright Setup/Teardown

```typescript
// tests/fixtures.ts
import { test as base } from '@playwright/test';

type MyFixtures = {
  authenticatedPage: Page;
  testData: TestData;
};

export const test = base.extend<MyFixtures>({
  // Per-test fixture
  authenticatedPage: async ({ page }, use) => {
    // Setup: Login
    const user = await createTestUser();
    await page.goto('/login');
    await page.fill('[name=email]', user.email);
    await page.fill('[name=password]', user.password);
    await page.click('[type=submit]');
    await page.waitForURL('/dashboard');

    // Use page in test
    await use(page);

    // Teardown: Cleanup
    await deleteTestUser(user.id);
    await page.context().clearCookies();
  },

  // Per-test data
  testData: async ({}, use) => {
    const data = await generateTestData();

    await use(data);

    await cleanupTestData(data);
  },
});

// Usage in tests
test('user can update profile', async ({ authenticatedPage }) => {
  await authenticatedPage.goto('/profile');
  await authenticatedPage.fill('[name=name]', 'Updated Name');
  await authenticatedPage.click('[type=submit]');

  await expect(authenticatedPage.locator('.success')).toBeVisible();
});
```

## State Management Patterns

### 1. Unique Identifiers

```python
# tests/utils.py
import uuid
import random
import string

def generate_unique_email():
    """Generate unique email for each test"""
    unique_id = uuid.uuid4().hex[:8]
    return f"test_{unique_id}@example.com"

def generate_unique_username():
    """Generate unique username for each test"""
    return f"user_{uuid.uuid4().hex}"

def generate_unique_phone():
    """Generate unique phone number for each test"""
    return f"+1555{random.randint(1000000, 9999999)}"

# Usage
def test_user_registration(client):
    user_data = {
        'email': generate_unique_email(),
        'username': generate_unique_username(),
        'phone': generate_unique_phone(),
    }

    response = client.register(user_data)

    assert response.status_code == 201
```

### 2. Database Snapshot Pattern

```python
# tests/conftest.py
@pytest.fixture
def db_snapshot(db_connection):
    """Snapshot database state and restore after test"""
    # Get table names
    tables = get_all_tables(db_connection)

    # Capture snapshot
    snapshot = {}
    for table in tables:
        snapshot[table] = db_connection.execute(
            f"SELECT * FROM {table}"
        ).fetchall()

    yield

    # Restore snapshot
    db_connection.execute("SET FOREIGN_KEY_CHECKS=0")
    for table in tables:
        db_connection.execute(f"TRUNCATE TABLE {table}")
        for row in snapshot[table]:
            db_connection.execute(
                f"INSERT INTO {table} VALUES {row}"
            )
    db_connection.execute("SET FOREIGN_KEY_CHECKS=1")
```

### 3. Container Isolation (Docker)

```python
# tests/conftest.py
import docker
import pytest

@pytest.fixture(scope="session")
def docker_client():
    return docker.from_env()

@pytest.fixture
def test_database(docker_client):
    """Create isolated database container for test"""
    container = docker_client.containers.run(
        "postgres:15",
        environment={
            "POSTGRES_PASSWORD": "test",
            "POSTGRES_DB": "testdb"
        },
        ports={"5432/tcp": None},  # Random port
        detach=True
    )

    # Wait for database to be ready
    container.exec_run("pg_isready -U postgres")

    # Get the mapped port
    port = container.ports["5432/tcp"][0]["HostPort"]
    database_url = f"postgresql://postgres:test@localhost:{port}/testdb"

    yield database_url

    # Cleanup
    container.stop()
    container.remove()
```

## Anti-Patterns

### 1. Shared Mutable State

**Anti-Pattern:**
```javascript
// DON'T: Shared state
let currentUser;

beforeEach(() => {
  currentUser = createUser();
});

test('update user', () => {
  currentUser.name = 'Updated';  // Modifies shared state
  // This affects subsequent tests if cleanup fails
});
```

**Correct Pattern:**
```javascript
// DO: Fresh state each test
test('update user', () => {
  const user = createUser();  // Fresh instance
  user.name = 'Updated';
  // No impact on other tests
});
```

### 2. Order-Dependent Tests

**Anti-Pattern:**
```javascript
// DON'T: Tests that depend on order
describe('User Flow', () => {
  let userId;

  test('create user', () => {
    const user = createUser();
    userId = user.id;  // Shared state
  });

  test('update user', () => {
    // Depends on create running first
    updateUser(userId, { name: 'Updated' });
  });
});
```

**Correct Pattern:**
```javascript
// DO: Independent tests
test('create and update user', () => {
  const user = createUser();
  const updated = updateUser(user.id, { name: 'Updated' });
  expect(updated.name).toBe('Updated');
});

test('create and delete user', () => {
  const user = createUser();
  deleteUser(user.id);
  expect(findUser(user.id)).toBeNull();
});
```

### 3. Leaking Resources

**Anti-Pattern:**
```javascript
// DON'T: Resources not cleaned up
test('process file', async () => {
  const file = '/tmp/test.txt';
  fs.writeFileSync(file, 'content');
  processFile(file);
  // File not cleaned up - affects next test
});
```

**Correct Pattern:**
```javascript
// DO: Always cleanup
test('process file', async () => {
  const file = `/tmp/test-${Date.now()}.txt`;
  fs.writeFileSync(file, 'content');

  try {
    processFile(file);
  } finally {
    // Ensure cleanup even if test fails
    fs.unlinkSync(file);
  }
});
```

### 4. Global State Modification

**Anti-Pattern:**
```javascript
// DON'T: Modify global state
const originalConfig = config.get();

beforeEach(() => {
  config.set({ featureFlag: true });  // Global change
});

test('with feature flag', () => {
  // Test with flag enabled
});

// Other tests might depend on original config
```

**Correct Pattern:**
```javascript
// DO: Save and restore
beforeEach(() => {
  originalConfig = config.get();
  config.set({ featureFlag: true });
});

afterEach(() => {
  config.set(originalConfig);  // Always restore
});
```

### 5. Shared Database Without Cleanup

**Anti-Pattern:**
```python
# DON'T: Shared database without cleanup
@pytest.fixture(scope="module")
def db_session():
    session = create_session()
    yield session
    # Data from previous tests remains!
```

**Correct Pattern:**
```python
# DO: Clean or use transactions
@pytest.fixture
def db_session():
    connection = engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection)

    yield session

    session.close()
    transaction.rollback()  # Always clean up
```

### 6. Time-Dependent Tests

**Anti-Pattern:**
```python
# DON'T: Tests dependent on actual time
def test_scheduled_task():
    task = create_task(schedule_at=datetime.now() + timedelta(hours=1))
    assert task.status == 'pending'
    # Fails at midnight, month boundaries, etc.
```

**Correct Pattern:**
```python
# DO: Use frozen time
@pytest.mark.freeze_time('2024-01-01 12:00:00')
def test_scheduled_task():
    task = create_task(schedule_at=datetime(2024, 1, 1, 13, 0))
    assert task.status == 'pending'
    # Always passes regardless of when test runs
```

## Best Practices Summary

1. **Create Fresh State**: Each test should create its own test data
2. **Clean Up Always**: Use teardown blocks to clean up resources
3. **Use Unique Identifiers**: Generate unique IDs for data that might conflict
4. **Isolate External Dependencies**: Mock external services and APIs
5. **Reset Global State**: Save and restore global state in tests
6. **Use Transactions**: For database tests, use transactions with rollback
7. **Avoid Shared Fixtures**: Prefer per-test fixtures over shared ones
8. **Test Independence**: Ensure each test can run in any order
9. **Run in Parallel**: Design tests to run in parallel safely
10. **Idempotent Operations**: Tests should produce the same result on repeated runs
