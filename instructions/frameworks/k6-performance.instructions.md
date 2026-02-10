---
description: 'K6 framework for performance and load testing. Covers test scenarios, thresholds, load modeling strategies, metrics, and reporting patterns.'
version: '1.0.0'
category: 'frameworks'
applies-to:
  agents: ['performance-tester', 'load-tester', 'qa-automation']
  skills: ['performance-testing', 'load-testing', 'stress-testing']
  frameworks: ['k6', 'grafana', 'prometheus', 'influxdb']
priority: 'recommended'
compliance:
  must-follow: ['Always define thresholds for SLA compliance', 'Never run load tests against production without approval', 'Use proper sleep between requests to simulate realistic behavior', 'Implement graceful teardown and cleanup']
  should-follow: ['Use scenarios for complex load patterns', 'Separate configuration from test logic', 'Implement proper error handling', 'Use environment variables for configuration']
  can-ignore: ['Sleep times in smoke/sanity tests', 'Detailed logging during test development']
---

# K6 Performance Testing Framework

## Purpose

K6 is an open-source load testing tool that makes performance testing easy and productive for engineers and QA teams. It uses JavaScript for scripting, provides powerful CI/CD integration, and offers excellent performance with low resource consumption.

## Installation

### Binary Installation

```bash
# macOS
brew install k6

# Linux
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6

# Windows (using Chocolatey)
chocolatey install k6
```

### Docker

```bash
docker pull grafana/k6
docker run --rm -i grafana/k6 run - <script.js
```

### Verify Installation

```bash
k6 version
```

## Basic Test Structure

### Hello World Test

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export default function () {
    const res = http.get('https://test-api.k6.io/public/crocodiles/1/');

    check(res, {
        'status is 200': (r) => r.status === 200,
        'response body contains name': (r) => r.body.includes('Bert'),
    });

    sleep(1);
}
```

### Running Tests

```bash
# Basic run
k6 run script.js

# With virtual users
k6 run --vus 10 --duration 30s script.js

# With environment variables
k6 run -e BASE_URL=https://api.example.com script.js

# JSON output
k6 run --out json=results.json script.js
```

## Test Scenarios

### Simple Load Test

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    vus: 50,              // Virtual users
    duration: '30s',      // Test duration
};

export default function () {
    const res = http.get('https://api.example.com/users');
    check(res, { 'status was 200': (r) => r.status == 200 });
    sleep(1);
}
```

### Advanced Scenarios

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    scenarios: {
        // Constant load scenario
        constant_load: {
            executor: 'constant-vus',
            vus: 100,
            duration: '5m',
            gracefulStop: '30s',
        },

        // Ramping up and down
        ramping_load: {
            executor: 'ramping-vus',
            startVUs: 0,
            stages: [
                { duration: '2m', target: 100 },   // Ramp up to 100 VUs
                { duration: '5m', target: 100 },   // Stay at 100 VUs
                { duration: '2m', target: 0 },     // Ramp down to 0 VUs
            ],
            gracefulRampDown: '30s',
        },

        // Constant arrival rate
        constant_arrival: {
            executor: 'constant-arrival-rate',
            rate: 100,             // 100 iterations per timeUnit
            timeUnit: '1s',
            duration: '5m',
            preAllocatedVUs: 50,   // Initial VU allocation
            maxVUs: 200,           // Maximum VU allocation
        },

        // Ramping arrival rate
        ramping_arrival: {
            executor: 'ramping-arrival-rate',
            startRate: 10,
            timeUnit: '1s',
            preAllocatedVUs: 20,
            maxVUs: 100,
            stages: [
                { duration: '2m', target: 50 },    // Ramp up to 50 iters/s
                { duration: '5m', target: 50 },    // Stay at 50 iters/s
                { duration: '2m', target: 100 },   // Ramp up to 100 iters/s
                { duration: '5m', target: 100 },   // Stay at 100 iters/s
                { duration: '1m', target: 0 },     // Ramp down
            ],
        },

        // Shared iterations (fixed total)
        shared_iterations: {
            executor: 'shared-iterations',
            vus: 10,
            iterations: 1000,
            maxDuration: '10m',
        },

        // Per VU iterations
        per_vu_iterations: {
            executor: 'per-vu-iterations',
            vus: 10,
            iterations: 100,
            maxDuration: '10m',
        },
    },
};

export default function (data) {
    // Test logic here
}
```

## Thresholds

### Threshold Configuration

```javascript
export const options = {
    thresholds: {
        // HTTP response time metrics
        http_req_duration: ['p(95)<500', 'p(99)<1000'],  // 95% of requests under 500ms
        http_req_failed: ['rate<0.01'],                   // Error rate < 1%

        // Custom rate metrics
        my_custom_metric: ['count>100', 'rate>10'],

        // Multiple conditions
        http_req_duration: [
            'p(95)<500',     // 95th percentile < 500ms
            'p(99)<1000',    // 99th percentile < 1000ms
            'avg<200',       // Average < 200ms
            'min>0',         // Minimum > 0ms
            'max<2000',      // Maximum < 2000ms
        ],

        // Failed requests
        http_req_failed: [
            'rate<0.01',     // Error rate < 1%
            'rate<0.05',     // Warning: error rate < 5%
        ],

        // Checks (custom validation)
        checks: ['rate>0.95'],  // 95% of checks should pass

        // Specific request tags
        'http_req_duration{type:api}': ['p(95)<300'],
        'http_req_duration{type:static}': ['p(95)<100'],

        // Threshold with abort
        http_req_duration: [
            { threshold: 'p(95)<1000', abortOnFail: true, delayAbortEval: '10s' },
        ],
    },
};
```

### Threshold Conditions

| Syntax | Description | Example |
|--------|-------------|---------|
| `avg<value` | Average value | `avg<200` |
| `p(pct)<value` | Percentile | `p(95)<500` |
| `min<value` | Minimum value | `min>0` |
| `max<value` | Maximum value | `max<2000` |
| `rate>value` | Rate per second | `rate>100` |
| `count>value` | Total count | `count>1000` |

### Custom Metrics

```javascript
import http from 'k6/http';
import { Trend, Rate, Counter, Gauge } from 'k6/metrics';

// Custom metrics
const apiResponseTime = new Trend('api_response_time');
const apiErrors = new Rate('api_errors');
const requestCount = new Counter('request_count');
const activeConnections = new Gauge('active_connections');

export default function () {
    const res = http.get('https://api.example.com/data');

    // Add custom metric data
    apiResponseTime.add(res.timings.duration);
    apiErrors.add(res.status !== 200);
    requestCount.add(1);
    activeConnections.add(1);

    // Clean up gauge value
    setTimeout(() => activeConnections.add(-1), 1000);
}

export const options = {
    thresholds: {
        'api_response_time': ['p(95)<500', 'p(99)<1000'],
        'api_errors': ['rate<0.01'],
    },
};
```

## Load Modeling Strategies

### Real User Behavior Modeling

```javascript
import http from 'k6/http';
import { check, sleep, randomSeed } from 'k6';
import { SharedArray } from 'k6/data';

// Load test data once
const testData = new SharedArray('users', function () {
    return JSON.parse(open('./users.json')).users;
});

randomSeed(12345);  // Reproducible tests

export const options = {
    scenarios: {
        // Mimic real user patterns
        realistic_load: {
            executor: 'ramping-arrival-rate',
            startRate: 10,
            timeUnit: '1s',
            preAllocatedVUs: 50,
            maxVUs: 200,
            stages: [
                { duration: '10m', target: 50 },   // Morning ramp-up
                { duration: '30m', target: 50 },   // Steady morning
                { duration: '10m', target: 150 },  // Peak traffic
                { duration: '1h', target: 150 },   // Sustained peak
                { duration: '10m', target: 100 },  // Afternoon
                { duration: '30m', target: 100 },  // Steady afternoon
                { duration: '10m', target: 0 },    // Ramp down
            ],
        },
    },
};

export default function () {
    const user = testData[Math.floor(Math.random() * testData.length)];

    // Login
    let loginRes = http.post('https://api.example.com/login', JSON.stringify({
        username: user.username,
        password: user.password,
    }), {
        headers: { 'Content-Type': 'application/json' },
    });

    check(loginRes, {
        'login successful': (r) => r.status === 200,
        'has token': (r) => r.json('token') !== undefined,
    });

    const token = loginRes.json('token');

    // Browse products
    let browseRes = http.get('https://api.example.com/products', {
        headers: { 'Authorization': `Bearer ${token}` },
    });

    sleep(randomIntBetween(2, 5));  // Think time

    // View product
    const productId = browseRes.json('products[0].id');
    http.get(`https://api.example.com/products/${productId}`, {
        headers: { 'Authorization': `Bearer ${token}` },
        tags: { name: 'ViewProduct' },
    });

    sleep(randomIntBetween(1, 3));

    // Add to cart (30% of users)
    if (Math.random() < 0.3) {
        http.post(`https://api.example.com/cart/items`, JSON.stringify({
            productId: productId,
            quantity: 1,
        }), {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json',
            },
        });
    }

    sleep(randomIntBetween(1, 2));
}
```

### Spike Testing

```javascript
export const options = {
    scenarios: {
        spike_test: {
            executor: 'constant-vus',
            vus: 10,
            duration: '2m',
            gracefulStop: '30s',
            exec: 'baseline',
        },
        spike: {
            executor: 'constant-vus',
            vus: 500,
            duration: '2m',
            startTime: '2m',
            gracefulStop: '30s',
            exec: 'spike',
        },
    },
};

export function baseline() {
    http.get('https://api.example.com/endpoint');
}

export function spike() {
    http.get('https://api.example.com/endpoint');
}
```

### Soak Testing (Endurance)

```javascript
export const options = {
    scenarios: {
        soak_test: {
            executor: 'ramping-arrival-rate',
            startRate: 50,
            timeUnit: '1s',
            preAllocatedVUs: 100,
            maxVUs: 200,
            stages: [
                { duration: '5m', target: 50 },    // Warm up
                { duration: '12h', target: 50 },   // Soak for 12 hours
                { duration: '5m', target: 0 },     // Cool down
            ],
        },
    },
    thresholds: {
        http_req_duration: ['p(95)<500'],
        http_req_failed: ['rate<0.01'],
        'checks{type:memory}': ['rate>0.95'],  // Check for memory leaks
    },
};
```

### Stress Testing

```javascript
export const options = {
    scenarios: {
        stress_test: {
            executor: 'ramping-vus',
            startVUs: 0,
            stages: [
                { duration: '5m', target: 100 },   // Normal load
                { duration: '5m', target: 200 },   // Moderate load
                { duration: '5m', target: 300 },   // High load
                { duration: '5m', target: 400 },   // Near breaking point
                { duration: '5m', target: 500 },   // Over capacity
                { duration: '5m', target: 0 },     // Recovery
            ],
        },
    },
};
```

## HTTP Methods and Requests

### GET Request

```javascript
// Simple GET
const res = http.get('https://api.example.com/users');

// GET with query parameters
const res = http.get('https://api.example.com/users', {
    query: { page: 1, limit: 10 },
});

// GET with headers
const res = http.get('https://api.example.com/users', {
    headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/json',
    },
    tags: { name: 'GetUsers' },  // For metrics filtering
});
```

### POST Request

```javascript
const payload = JSON.stringify({
    name: 'John Doe',
    email: 'john@example.com',
});

const res = http.post('https://api.example.com/users', payload, {
    headers: { 'Content-Type': 'application/json' },
});

check(res, {
    'status is 201': (r) => r.status === 201,
    'user created': (r) => r.json('id') !== undefined,
});
```

### PUT/PATCH Requests

```javascript
const updateData = JSON.stringify({
    name: 'Jane Doe',
});

const res = http.patch('https://api.example.com/users/1', updateData, {
    headers: { 'Content-Type': 'application/json' },
});
```

### DELETE Request

```javascript
const res = http.del('https://api.example.com/users/1', null, {
    headers: { 'Authorization': `Bearer ${token}` },
});

check(res, {
    'status is 204': (r) => r.status === 204,
});
```

### Batch Requests

```javascript
// Multiple requests in sequence
export default function () {
    const responses = http.batch([
        ['GET', 'https://api.example.com/users', null, { tags: { name: 'UsersAPI' } }],
        ['GET', 'https://api.example.com/products', null, { tags: { name: 'ProductsAPI' } }],
        ['GET', 'https://api.example.com/orders', null, { tags: { name: 'OrdersAPI' } }],
    ]);

    check(responses[0], { 'users loaded': (r) => r.status === 200 });
    check(responses[1], { 'products loaded': (r) => r.status === 200 });
    check(responses[2], { 'orders loaded': (r) => r.status === 200 });
}
```

## Authentication

### Bearer Token

```javascript
const token = 'your-access-token';

export default function () {
    http.get('https://api.example.com/protected', {
        headers: {
            'Authorization': `Bearer ${token}`,
        },
    });
}
```

### Basic Authentication

```javascript
import http from 'k6/http';

export default function () {
    const credentials = `${username}:${password}`;
    const encoded = btoa(credentials);

    http.get('https://api.example.com/protected', {
        headers: {
            'Authorization': `Basic ${encoded}`,
        },
    });
}
```

### OAuth2 Flow

```javascript
import http from 'k6/http';

let accessToken;

export function setup() {
    // Get access token
    const res = http.post('https://auth.example.com/oauth/token', {
        grant_type: 'client_credentials',
        client_id: __ENV.CLIENT_ID,
        client_secret: __ENV.CLIENT_SECRET,
    });

    return { token: res.json('access_token') };
}

export default function (data) {
    http.get('https://api.example.com/protected', {
        headers: {
            'Authorization': `Bearer ${data.token}`,
        },
    });
}
```

## Checks and Assertions

### Basic Checks

```javascript
import { check } from 'k6';

export default function () {
    const res = http.get('https://api.example.com/users');

    check(res, {
        'status is 200': (r) => r.status === 200,
        'has users': (r) => r.json('users').length > 0,
        'response time < 500ms': (r) => r.timings.duration < 500,
    });
}
```

### Advanced Checks

```javascript
export default function () {
    const res = http.get('https://api.example.com/users');

    check(res, {
        'status is 200': (r) => r.status === 200,
        'content-type is JSON': (r) => r.headers['Content-Type'].includes('application/json'),
        'response time < 500ms': (r) => r.timings.duration < 500,
        'response time > 0ms': (r) => r.timings.duration > 0,

        // Body checks
        'has users array': (r) => r.json().hasOwnProperty('users'),
        'has at least 5 users': (r) => r.json('users').length >= 5,
        'first user has name': (r) => r.json('users[0].name') !== undefined,

        // JSON path checks
        'user count matches': (r) => r.json('meta.count') === r.json('users').length,

        // Header checks
        'has server header': (r) => 'Server' in r.headers,
        'cache-control present': (r) => r.headers['Cache-Control'] !== undefined,

        // Negative checks
        'not an error': (r) => !r.body.includes('error'),
        'no sensitive data': (r) => !r.body.includes('password'),
    });
}
```

### Grouped Checks

```javascript
import { group, check } from 'k6';

export default function () {
    group('User Flow', () => {
        group('Login', () => {
            const res = http.post('https://api.example.com/login', {
                username: 'test',
                password: 'test',
            });
            check(res, { 'login success': (r) => r.status === 200 });
        });

        group('Browse', () => {
            const res = http.get('https://api.example.com/products');
            check(res, { 'products loaded': (r) => r.status === 200 });
        });
    });
}
```

## Setup and Teardown

### Setup Function

```javascript
export function setup() {
    // Runs once before the test
    // Return data to be passed to default and teardown

    const loginRes = http.post('https://api.example.com/auth', {
        username: 'admin',
        password: 'secret',
    });

    return {
        token: loginRes.json('token'),
        userId: loginRes.json('userId'),
    };
}
```

### Teardown Function

```javascript
export function teardown(data) {
    // Runs once after the test completes
    // Use data returned from setup

    const res = http.post('https://api.example.com/logout', {
        token: data.token,
    });

    console.log(`Teardown complete: ${res.status}`);
}
```

### Complete Setup/Teardown Example

```javascript
import http from 'k6/http';
import { check } from 'k6';

export function setup() {
    // Create test data
    const user = http.post('https://api.example.com/users', JSON.stringify({
        name: 'Test User',
        email: 'test@example.com',
    }), { headers: { 'Content-Type': 'application/json' } });

    return { userId: user.json('id') };
}

export default function (data) {
    // Use created test data
    const res = http.get(`https://api.example.com/users/${data.userId}`);
    check(res, { 'status 200': (r) => r.status === 200 });
}

export function teardown(data) {
    // Clean up test data
    http.del(`https://api.example.com/users/${data.userId}`);
    console.log(`Cleaned up user ${data.userId}`);
}
```

## Modules and Reusability

### Parameterized Tests

```javascript
// config.js
export const BASE_URL = __ENV.BASE_URL || 'https://api.example.com';
export const TIMEOUT = '30s';

// utils.js
import { check } from 'k6';

export function checkResponse(res, checks) {
    const result = check(res, checks);
    if (!result) {
        console.log(`Failed: ${res.status} - ${res.body}`);
    }
    return result;
}

export function createAuthHeaders(token) {
    return {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
    };
}

// main.js
import { BASE_URL } from './config.js';
import { checkResponse, createAuthHeaders } from './utils.js';

export default function () {
    const res = http.get(`${BASE_URL}/users`);
    checkResponse(res, { 'status 200': (r) => r.status === 200 });
}
```

### Data-Driven Testing

```javascript
// users.json
[
    { "username": "user1", "password": "pass1", "role": "admin" },
    { "username": "user2", "password": "pass2", "role": "user" },
    { "username": "user3", "password": "pass3", "role": "user" }
]

// test.js
import { SharedArray } from 'k6/data';
import http from 'k6/http';

const users = new SharedArray('users', function () {
    return JSON.parse(open('./users.json'));
});

export default function () {
    const user = users[Math.floor(Math.random() * users.length)];

    http.post('https://api.example.com/login', JSON.stringify({
        username: user.username,
        password: user.password,
    }), {
        headers: { 'Content-Type': 'application/json' },
        tags: { role: user.role },
    });
}
```

## Output and Reporting

### JSON Output

```bash
k6 run --out json=results.json script.js
```

### InfluxDB + Grafana

```bash
k6 run \
    --out influxdb=http://localhost:8086/k6 \
    script.js
```

### Prometheus Remote Write

```bash
k6 run \
    --out experimental-prometheus-rw \
    script.js
```

### Cloud Outputs

```bash
# k6 Cloud
k6 cloud script.js

# Grafana Cloud
k6 run --out cloud script.js
```

## Environment Variables

```javascript
const BASE_URL = __ENV.BASE_URL || 'https://api.example.com';
const VUS = parseInt(__ENV.VUS) || 10;
const DURATION = __ENV.DURATION || '1m';

export const options = {
    vus: VUS,
    duration: DURATION,
};

export default function () {
    http.get(`${BASE_URL}/users`);
}
```

```bash
# Run with environment variables
BASE_URL=https://staging.example.com VUS=50 DURATION=5m k6 run script.js
```

## Complete Examples

### E-commerce Load Test

```javascript
import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { SharedArray } from 'k6/data';

const products = new SharedArray('products', function () {
    return JSON.parse(open('./products.json'));
});

export const options = {
    scenarios: {
        e-commerce_load: {
            executor: 'ramping-arrival-rate',
            startRate: 10,
            timeUnit: '1s',
            preAllocatedVUs: 100,
            maxVUs: 500,
            stages: [
                { duration: '5m', target: 50 },
                { duration: '10m', target: 100 },
                { duration: '5m', target: 50 },
                { duration: '5m', target: 0 },
            ],
        },
    },
    thresholds: {
        http_req_duration: ['p(95)<500', 'p(99)<1000'],
        http_req_failed: ['rate<0.01'],
        checks: ['rate>0.95'],
    },
};

export default function () {
    const baseUrl = __ENV.BASE_URL || 'https://api.example.com';

    group('Browse Products', () => {
        const res = http.get(`${baseUrl}/products`, {
            tags: { name: 'BrowseProducts' },
        });
        check(res, {
            'products loaded': (r) => r.status === 200,
            'has products': (r) => r.json('products').length > 0,
        });
        sleep(randomIntBetween(1, 3));
    });

    group('View Product', () => {
        const product = products[Math.floor(Math.random() * products.length)];
        const res = http.get(`${baseUrl}/products/${product.id}`, {
            tags: { name: 'ViewProduct' },
        });
        check(res, { 'product loaded': (r) => r.status === 200 });
        sleep(randomIntBetween(1, 2));
    });

    // 20% of users add to cart
    if (Math.random() < 0.2) {
        group('Add to Cart', () => {
            const product = products[Math.floor(Math.random() * products.length)];
            const res = http.post(
                `${baseUrl}/cart/items`,
                JSON.stringify({ productId: product.id, quantity: 1 }),
                { headers: { 'Content-Type': 'application/json' } }
            );
            check(res, { 'added to cart': (r) => r.status === 201 });
        });
    }

    sleep(randomIntBetween(2, 4));
}
```

## Best Practices

1. **Start Small**: Begin with smoke tests (few VUs, short duration)
2. **Use Scenarios**: Model realistic user behavior patterns
3. **Define Thresholds**: Set clear pass/fail criteria
4. **Parameterize Tests**: Use environment variables for configuration
5. **Share Data**: Use SharedArray for read-only test data
6. **Add Think Time**: Include sleep to simulate real user behavior
7. **Tag Requests**: Use tags for filtering metrics by request type
8. **Clean Up**: Use teardown to remove test data
9. **Monitor Resources**: Watch CPU/memory on both load generator and target
10. **Version Control**: Store test scripts and configurations in git
