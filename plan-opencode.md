# Plan de Mejoras: QA Automation AI Agents Repository

> **Versión**: 1.0  
> **Fecha**: 2026-02-10  
> **Autor**: Senior QA Automation Engineer & AI Solutions Architect  
> **Estado**: Planificación

---

## 📊 Resumen Ejecutivo

Este documento define un plan completo para mejorar el repositorio de agents, instructions y skills de QA Automation, haciéndolo más completo, escalable y alineado con las mejores prácticas de testing a nivel Senior.

### Objetivos Principales

1. **Arquitectura Escalable**: Implementar patrón de orquestación multi-agente
2. **Cobertura Completa**: UI, API, Performance, Security, Accessibility testing
3. **Calidad Senior**: SOLID principles, Test Pyramid, Maintainability
4. **Reusabilidad**: Skills atómicos componibles entre proyectos
5. **AI-First**: Integración efectiva de AI en todo el ciclo de testing

---

## 🔍 Análisis del Estado Actual

### Inventario Existente

| Categoría | Cantidad | Archivos |
|-----------|----------|----------|
| **Agents** | 9 | playwright-test-generator, architect, playwright-test-healer, playwright-test-planner, selenium-test-specialist, principal-software-engineer, docs-agent, implementation-plan, selenium-test-executor |
| **Instructions** | 5 | playwright-typescript, selenium-webdriver-java, agent-skills, a11y, agents |
| **Skills** | 8 | webapp-playwright-testing, webapp-selenium-testing, qa-test-planner, qa-manual-istqb, playwright-e2e-testing, accessibility-selenium-testing, a11y-playwright-testing |

### Fortalezas Identificadas

- ✅ Buena cobertura de Playwright y Selenium
- ✅ Documentación extensa en skills (ej: qa-test-planner con 897 líneas)
- ✅ Estructura de referencias y templates bien organizada
- ✅ Uso apropiado de frontmatter YAML en agents
- ✅ Referencias a mejores prácticas (POM, locator strategies)

### Áreas de Mejora

- ❌ **Sin orquestación**: No hay agente que coordine workflows multi-agente
- ❌ **Sin API Testing**: No hay agente ni skills especializados en APIs
- ❌ **Sin Performance Testing**: Falta cobertura de testing de rendimiento
- ❌ **Sin CI/CD Integration**: No hay instructions para pipelines
- ❌ **Sin handoffs**: Los agentes no pueden transferirse el control
- ❌ **Sin debugging especializado**: No hay skill de análisis de flakiness

---

## 🏗️ Arquitectura Propuesta

### 1. Estructura de Directorios

```
repository/
├── agents/
│   ├── orchestration/              # NUEVO: Agente orquestador
│   │   └── qa-orchestrator.agent.md
│   ├── testing/                    # REORGANIZAR: Agentes de testing
│   │   ├── playwright/
│   │   │   ├── test-generator.agent.md
│   │   │   ├── test-healer.agent.md
│   │   │   ├── test-reviewer.agent.md
│   │   │   └── e2e-specialist.agent.md
│   │   ├── selenium/
│   │   │   ├── test-executor.agent.md
│   │   │   └── test-specialist.agent.md
│   │   ├── api/                    # NUEVO
│   │   │   └── api-test-generator.agent.md
│   │   ├── performance/            # NUEVO
│   │   │   └── performance-test-agent.agent.md
│   │   └── security/               # NUEVO
│   │       └── security-auditor.agent.md
│   ├── analysis/                   # NUEVO
│   │   ├── coverage-analyst.agent.md
│   │   ├── flakiness-detective.agent.md
│   │   └── test-refactor.agent.md
│   └── architecture/
│       ├── implementation-plan.agent.md
│       ├── architect.agent.md
│       ├── docs-agent.agent.md
│       └── principal-engineer.agent.md
│
├── instructions/
│   ├── frameworks/
│   │   ├── playwright-typescript.instructions.md
│   │   ├── selenium-webdriver-java.instructions.md
│   │   ├── restassured-api.instructions.md        # NUEVO
│   │   ├── k6-performance.instructions.md         # NUEVO
│   │   └── cypress-javascript.instructions.md     # NUEVO
│   ├── patterns/
│   │   ├── page-object-model.instructions.md      # NUEVO
│   │   ├── test-pyramid.instructions.md           # NUEVO
│   │   ├── solid-testing.instructions.md          # NUEVO
│   │   └── data-driven-testing.instructions.md    # NUEVO
│   ├── processes/
│   │   ├── ci-cd-integration.instructions.md      # NUEVO
│   │   ├── test-strategy.instructions.md          # NUEVO
│   │   └── regression-planning.instructions.md    # NUEVO
│   ├── core/
│   │   ├── agents.instructions.md
│   │   ├── agent-skills.instructions.md
│   │   └── a11y.instructions.md
│   └── quality/
│       ├── code-review.instructions.md            # NUEVO
│       └── test-maintainability.instructions.md   # NUEVO
│
└── skills/
    ├── atomic/                       # NUEVO: Skills básicos reutilizables
    │   ├── locators/
    │   │   ├── role-based-locators.skill.md
    │   │   ├── data-testid-locators.skill.md
    │   │   └── custom-locators.skill.md
    │   ├── assertions/
    │   │   ├── web-first-assertions.skill.md
    │   │   └── api-assertions.skill.md
    │   ├── waits/
    │   │   ├── auto-waiting.skill.md
    │   │   └── explicit-waits.skill.md
    │   └── fixtures/
    │       └── test-data-management.skill.md
    │
    ├── composite/                    # NUEVO: Skills compuestos
    │   ├── page-object-model/
    │   │   ├── pom-factory.skill.md
    │   │   ├── pom-fluent-interface.skill.md
    │   │   └── pom-component-model.skill.md
    │   ├── test-patterns/
    │   │   ├── data-driven.skill.md
    │   │   ├── keyword-driven.skill.md
    │   │   └── behavior-driven.skill.md
    │   └── test-runners/
    │       ├── playwright-runner.skill.md
    │       ├── jest-runner.skill.md
    │       └── testng-runner.skill.md
    │
    ├── domain/                       # NUEVO: Skills específicos de dominio
    │   ├── authentication/
    │   │   ├── login-flows.skill.md
    │   │   └── oauth-testing.skill.md
    │   ├── e-commerce/
    │   │   ├── cart-workflows.skill.md
    │   │   ├── checkout-flows.skill.md
    │   │   └── payment-testing.skill.md
    │   └── forms/
    │       ├── form-validation.skill.md
    │       └── file-upload.skill.md
    │
    └── existing/                     # REORGANIZAR: Skills actuales
        ├── webapp-playwright-testing/
        ├── webapp-selenium-testing/
        ├── qa-test-planner/
        ├── qa-manual-istqb/
        ├── playwright-e2e-testing/
        ├── accessibility-selenium-testing/
        └── a11y-playwright-testing/
```

---

## 🤖 Agents: Estructura y Ejemplos

### 1. Agente de Orquestación (NUEVO)

**Archivo**: `agents/orchestration/qa-orchestrator.agent.md`

```yaml
---
name: qa-orchestrator
description: 'Central orchestrator for QA automation workflows. Delegates tasks to specialized testing agents, manages multi-step testing processes, and ensures quality gates are met.'
tools:
  - read
  - search
  - agent
  - todo
model: Claude Opus 4.5 (copilot)
handoffs:
  - label: Generate Tests
    agent: playwright-test-generator
    prompt: 'Generate automated tests based on the requirements provided.'
    send: false
  - label: Review Tests
    agent: test-reviewer
    prompt: 'Review the generated tests for quality and best practices.'
    send: false
  - label: Fix Failing Tests
    agent: playwright-test-healer
    prompt: 'Analyze and fix the failing tests identified.'
    send: false
  - label: API Testing
    agent: api-test-generator
    prompt: 'Generate API tests for the specified endpoints.'
    send: false
  - label: Performance Analysis
    agent: performance-test-agent
    prompt: 'Create performance tests and analyze results.'
    send: false
---

# QA Orchestrator Agent

You are the central orchestrator for QA automation workflows. Your role is to coordinate multiple specialized agents to deliver comprehensive testing solutions.

## Primary Responsibilities

1. **Workflow Coordination**: Manage end-to-end testing processes
2. **Agent Delegation**: Route tasks to appropriate specialized agents
3. **Quality Gates**: Ensure deliverables meet quality standards
4. **Process Optimization**: Identify bottlenecks and optimize workflows

## Dynamic Parameters

- **projectName**: Name of the project being tested
- **testingScope**: UI, API, Performance, or Full Suite
- **priority**: Critical, High, Medium, Low
- **timeline**: Expected delivery timeframe

## Decision Matrix

| User Request | Primary Agent | Secondary Agent | Quality Gate |
|--------------|---------------|-----------------|--------------|
| Create E2E tests | playwright-test-generator | test-reviewer | Code review pass |
| Fix flaky tests | flakiness-detective | playwright-test-healer | Tests pass 3x |
| API validation | api-test-generator | coverage-analyst | 80%+ coverage |
| Performance check | performance-test-agent | - | SLA thresholds |
| Full regression | test-planner | Multiple agents | All P0 pass |

## Workflow Patterns

### Pattern 1: Sequential Test Generation
```
1. Plan → test-planner
2. Generate → playwright-test-generator
3. Review → test-reviewer
4. Fix → playwright-test-healer (if needed)
5. Report → qa-test-planner
```

### Pattern 2: Parallel API + UI Testing
```
┌─────────────┐     ┌─────────────┐
│   API Tests │     │   UI Tests  │
│   Generator │     │   Generator │
└──────┬──────┘     └──────┬──────┘
       │                   │
       └─────────┬─────────┘
                 ▼
          ┌─────────────┐
          │   Coverage  │
          │   Analyst   │
          └─────────────┘
```

## Rules

- **ALWAYS** create a plan before delegating
- **NEVER** delegate more than 3 agents simultaneously
- **MUST** verify quality gates before completion
- **SHOULD** provide progress updates every 2-3 steps
- **MUST** ask for clarification on ambiguous requests

## Output Format

All orchestration sessions must end with:

```markdown
## Orchestration Summary

### Workflow Executed
- Steps completed: N
- Agents invoked: [list]
- Duration: [time]

### Deliverables
- [ ] Test files created
- [ ] Review completed
- [ ] Quality gates passed

### Next Actions
1. [Action 1]
2. [Action 2]
```
```

### 2. API Test Generator Agent (NUEVO)

**Archivo**: `agents/testing/api/api-test-generator.agent.md`

```yaml
---
name: api-test-generator
description: 'Specialized agent for generating API tests using REST Assured, Playwright API testing, or Supertest. Handles endpoint validation, schema validation, and contract testing.'
tools:
  - read
  - edit
  - search
  - web
model: Claude Sonnet 4.5
target: vscode
---

# API Test Generator Agent

You are an expert in API testing and automation. Your specialty is creating comprehensive, maintainable API tests that validate functionality, performance, and contract compliance.

## Core Responsibilities

1. **Endpoint Testing**: Generate tests for RESTful and GraphQL APIs
2. **Schema Validation**: Validate request/response schemas
3. **Contract Testing**: Ensure API contracts are maintained
4. **Integration Testing**: Test API interactions and dependencies
5. **Error Handling**: Test edge cases and error scenarios

## Scope

### In Scope
- REST API testing (GET, POST, PUT, DELETE, PATCH)
- GraphQL query and mutation testing
- Authentication/Authorization testing
- Request/response validation
- Schema validation (JSON Schema, OpenAPI)
- Status code verification
- Headers validation
- Error response testing

### Out of Scope
- UI testing (use playwright-test-generator)
- Database testing (direct queries)
- Infrastructure testing
- Load/Performance testing (use performance-test-agent)

## Decision Authority

**Can Decide:**
- Test framework selection (REST Assured, Playwright API, Supertest)
- Assertion strategies
- Test data generation approach
- Test organization and grouping

**Must Escalate:**
- Changes to API contracts
- Security-related findings
- Breaking changes in responses

## Testing Approach

### Test Pyramid Alignment

```
     /\
    /  \\     Contract Tests
   /____\\    (Few)
  /      \\
 /        \\  Integration Tests
/__________\\ (Medium)
/            \\
/______________\\ Unit/Component Tests
                  (Many)
```

### Test Structure

```typescript
// Example API Test Structure
describe('User API', () => {
  describe('POST /users', () => {
    describe('Happy Path', () => { ... });
    describe('Validation Errors', () => { ... });
    describe('Authorization', () => { ... });
  });
  
  describe('GET /users/:id', () => {
    describe('Existing User', () => { ... });
    describe('Non-existent User', () => { ... });
  });
});
```

## Best Practices

### SOLID Principles Applied

1. **SRP**: Each test validates one specific behavior
2. **OCP**: Tests are open for new scenarios, closed for modifications
3. **LSP**: Test fixtures can be substituted without breaking tests
4. **ISP**: Separate interfaces for different API operations
5. **DIP**: Depend on abstractions (API client), not concrete implementations

### API Testing Standards

- **Base URL**: Use environment variables
- **Auth Tokens**: Refresh automatically, store securely
- **Test Data**: Use factories, not hardcoded values
- **Cleanup**: Always clean up created resources
- **Idempotency**: Tests must be runnable multiple times

### Priorities

1. **MUST**: Happy path scenarios
2. **MUST**: Input validation and error handling
3. **SHOULD**: Authentication/Authorization
4. **SHOULD**: Contract/schema validation
5. **COULD**: Edge cases and boundary values
```

### 3. Performance Test Agent (NUEVO)

**Archivo**: `agents/testing/performance/performance-test-agent.agent.md`

```yaml
---
name: performance-test-agent
description: 'Creates and executes performance tests using k6, Artillery, or Playwright. Analyzes response times, throughput, and resource utilization.'
tools:
  - read
  - edit
  - search
  - execute
model: Claude Sonnet 4.5
---

# Performance Test Agent

You are a performance testing specialist. You design, execute, and analyze performance tests to ensure applications meet performance SLAs.

## Core Responsibilities

1. **Load Testing**: Simulate expected user load
2. **Stress Testing**: Find breaking points
3. **Spike Testing**: Test sudden load changes
4. **Endurance Testing**: Test sustained load over time
5. **Performance Analysis**: Identify bottlenecks

## Performance Test Types

| Type | Purpose | Duration | Load Pattern |
|------|---------|----------|--------------|
| Smoke | Validate test works | 1-5 min | Minimal |
| Load | Expected load | 10-30 min | Gradual ramp |
| Stress | Breaking point | 10-20 min | Gradual + sustained |
| Spike | Sudden changes | 5-10 min | Sudden jumps |
| Soak | Memory leaks | 2-24 hours | Sustained |

## SLAs and Thresholds

**Web Application:**
- Page Load: < 3 seconds (95th percentile)
- Time to Interactive: < 5 seconds
- First Contentful Paint: < 1.8 seconds
- Error Rate: < 0.1%

**API Endpoints:**
- Response Time (p95): < 500ms
- Response Time (p99): < 1000ms
- Throughput: > 1000 RPS per instance
- Error Rate: < 0.5%

## Testing Approach

```javascript
// k6 Example Structure
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 }, // Ramp up
    { duration: '5m', target: 100 }, // Sustained
    { duration: '2m', target: 200 }, // Ramp up
    { duration: '5m', target: 200 }, // Sustained
    { duration: '2m', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.1'],
  },
};

export default function () {
  const response = http.get('https://api.example.com/users');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
}
```

## Analysis Checklist

- [ ] Response time percentiles (p50, p95, p99)
- [ ] Error rate analysis
- [ ] Throughput metrics
- [ ] Resource utilization (CPU, Memory)
- [ ] Bottleneck identification
- [ ] Recommendations for optimization
```

### 4. Flakiness Detective Agent (NUEVO)

**Archivo**: `agents/analysis/flakiness-detective.agent.md`

```yaml
---
name: flakiness-detective
description: 'Analyzes failing or flaky tests to identify root causes. Detects timing issues, race conditions, environmental dependencies, and test isolation problems.'
tools:
  - read
  - search
  - web
model: Claude Sonnet 4.5
---

# Flakiness Detective Agent

You are a debugging specialist focused on identifying and resolving flaky tests. You analyze test failures, identify patterns, and provide actionable solutions.

## Core Responsibilities

1. **Failure Analysis**: Analyze test failure patterns
2. **Root Cause Detection**: Identify sources of flakiness
3. **Pattern Recognition**: Spot common anti-patterns
4. **Solution Design**: Propose fixes and improvements
5. **Prevention**: Recommend practices to avoid future flakiness

## Common Flakiness Causes

| Category | Examples | Detection |
|----------|----------|-----------|
| **Timing** | Hard waits, race conditions | Inconsistent pass/fail |
| **Environment** | Network issues, resource limits | Infrastructure errors |
| **Data** | Shared state, stale data | Data-dependent failures |
| **Concurrency** | Parallel execution conflicts | Intermittent locks |
| **External** | Third-party services | Timeout errors |

## Analysis Process

### Step 1: Gather Evidence
```
1. Review test failure history
2. Analyze error messages and stack traces
3. Check test execution logs
4. Review recent code changes
5. Examine CI/CD pipeline logs
```

### Step 2: Pattern Analysis
```
1. Identify failure frequency
2. Check for timing correlations
3. Analyze environment-specific failures
4. Look for data dependencies
5. Check parallel execution impact
```

### Step 3: Root Cause Classification

**Timing Issues:**
- Symptom: Tests pass locally, fail in CI
- Causes: Hard-coded waits, animation timing
- Solution: Auto-waiting, explicit waits

**State Pollution:**
- Symptom: Tests fail when run together, pass individually
- Causes: Shared state, missing cleanup
- Solution: Isolation, setup/teardown

**External Dependencies:**
- Symptom: Random failures with network errors
- Causes: Third-party APIs, databases
- Solution: Mocking, test data management

## Solution Patterns

### Pattern 1: Replace Hard Waits
```typescript
// ❌ Flaky
await page.waitForTimeout(2000);
await page.click('button');

// ✅ Stable
await page.getByRole('button').waitFor({ state: 'visible' });
await page.getByRole('button').click();
```

### Pattern 2: Isolate Test Data
```typescript
// ❌ Shared state
test('creates user', async () => { ... }); // Creates user@test.com

// ✅ Isolated data
test('creates user', async () => {
  const uniqueEmail = `user-${Date.now()}@test.com`;
  // Use unique data
});
```

### Pattern 3: Stabilize Assertions
```typescript
// ❌ Rigid assertions
await expect(page.locator('.price')).toHaveText('$10.00');

// ✅ Flexible assertions
await expect(page.locator('.price')).toContainText('$10');
```

## Output Format

```markdown
## Flakiness Analysis Report

### Test Information
- **Test Name**: [name]
- **File**: [path]
- **Failure Rate**: [X% over Y runs]

### Failure Patterns
1. [Pattern 1 with evidence]
2. [Pattern 2 with evidence]

### Root Cause
**Category**: [Timing/Environment/Data/Concurrency/External]
**Description**: [Detailed explanation]
**Evidence**: [Logs, screenshots, traces]

### Recommended Fixes
1. **Immediate**: [Quick fix]
2. **Short-term**: [Better approach]
3. **Long-term**: [Structural improvement]

### Prevention Checklist
- [ ] Review all hard waits
- [ ] Implement test data isolation
- [ ] Add proper cleanup
- [ ] Review parallel execution settings
```
```

---

## 📋 Instructions: Estructura y Ejemplos

### 1. SOLID Testing Principles (NUEVO)

**Archivo**: `instructions/patterns/solid-testing.instructions.md`

```yaml
---
description: 'SOLID principles applied to test automation. Guidelines for creating maintainable, scalable, and robust test code.'
applyTo: '**/*.spec.{ts,js,java}'
---

# SOLID Principles for Test Automation

## Overview

Apply SOLID principles to your test automation code to improve maintainability, readability, and scalability.

## S - Single Responsibility Principle (SRP)

**Principle**: A test should have one reason to change.

### Guidelines

1. **One Concept Per Test**: Each test validates exactly one behavior
2. **Focused Assertions**: Limit to 1-3 related assertions per test
3. **Clear Test Names**: Name should describe the specific behavior

### Examples

```typescript
// ❌ Violates SRP - tests multiple things
test('login works', async () => {
  await page.goto('/login');
  await page.fill('email', 'user@test.com');
  await page.fill('password', 'pass123');
  await page.click('submit');
  await expect(page).toHaveURL('/dashboard');
  await expect(page.locator('.welcome')).toContainText('Welcome');
  await expect(page.locator('.profile')).toBeVisible();
  await page.click('logout');
  await expect(page).toHaveURL('/login');
});

// ✅ Follows SRP - single responsibility per test
test('redirects to dashboard after successful login', async () => {
  await loginPage.login('user@test.com', 'pass123');
  await expect(page).toHaveURL('/dashboard');
});

test('displays welcome message after login', async () => {
  await loginPage.login('user@test.com', 'pass123');
  await expect(page.locator('.welcome')).toContainText('Welcome');
});
```

## O - Open/Closed Principle (OCP)

**Principle**: Tests should be open for extension, closed for modification.

### Guidelines

1. **Parametrized Tests**: Use data providers for variations
2. **Test Factories**: Create reusable test builders
3. **Environment Configuration**: Externalize environment-specific values

### Examples

```typescript
// ❌ Violates OCP - needs modification for new scenarios
test('calculates discount for regular user', () => {
  const price = calculateDiscount(100, 'regular');
  expect(price).toBe(100);
});

test('calculates discount for premium user', () => {
  const price = calculateDiscount(100, 'premium');
  expect(price).toBe(90);
});

// ✅ Follows OCP - easy to add new user types
test.describe('discount calculation', () => {
  const testCases = [
    { type: 'regular', price: 100, expected: 100 },
    { type: 'premium', price: 100, expected: 90 },
    { type: 'vip', price: 100, expected: 80 },
  ];
  
  testCases.forEach(({ type, price, expected }) => {
    test(`calculates discount for ${type} user`, () => {
      expect(calculateDiscount(price, type)).toBe(expected);
    });
  });
});
```

## L - Liskov Substitution Principle (LSP)

**Principle**: Derived test fixtures should be substitutable for base fixtures.

### Guidelines

1. **Fixture Inheritance**: Child fixtures must maintain parent behavior
2. **Consistent Interfaces**: Test data providers should be interchangeable
3. **Behavioral Compatibility**: Substituted components must not break tests

### Examples

```typescript
// ✅ Follows LSP - interchangeable data providers
interface UserDataProvider {
  getValidUser(): User;
  getInvalidUser(): User;
}

class StaticUserProvider implements UserDataProvider { ... }
class DynamicUserProvider implements UserDataProvider { ... }
class ApiUserProvider implements UserDataProvider { ... }

// All providers can be used interchangeably
test('creates user with valid data', async ({ userProvider }) => {
  const user = userProvider.getValidUser();
  await userApi.create(user);
  await expect(userApi.get(user.id)).toBeTruthy();
});
```

## I - Interface Segregation Principle (ISP)

**Principle**: Tests shouldn't depend on interfaces they don't use.

### Guidelines

1. **Focused Page Objects**: Split large page objects
2. **Role-Based Interfaces**: Create specific interfaces for different user roles
3. **Minimal Dependencies**: Only import what's needed

### Examples

```typescript
// ❌ Violates ISP - depends on full admin interface
class AdminPage {
  async createUser() { ... }
  async deleteUser() { ... }
  async viewReports() { ... }
  async manageSettings() { ... }
  async auditLogs() { ... }
}

// ✅ Follows ISP - segregated interfaces
class UserManagementPage {
  async createUser() { ... }
  async deleteUser() { ... }
}

class ReportingPage {
  async viewReports() { ... }
}

class SettingsPage {
  async manageSettings() { ... }
}
```

## D - Dependency Inversion Principle (DIP)

**Principle**: Depend on abstractions, not concrete implementations.

### Guidelines

1. **Abstract Test Infrastructure**: Use interfaces for browser, API, database
2. **Configurable Drivers**: Allow swapping test runners, browsers
3. **Mock External Services**: Don't depend on real third-party APIs

### Examples

```typescript
// ❌ Violates DIP - depends on concrete implementation
test('sends notification', async () => {
  const emailService = new SendGridEmailService();
  await emailService.send('user@test.com', 'Welcome!');
});

// ✅ Follows DIP - depends on abstraction
interface NotificationService {
  send(to: string, message: string): Promise<void>;
}

test('sends notification', async ({ notificationService }) => {
  await notificationService.send('user@test.com', 'Welcome!');
});
```

## Priority Checklist

When writing tests, prioritize in this order:

1. **MUST**: Apply SRP - one behavior per test
2. **MUST**: Apply DIP - depend on abstractions
3. **SHOULD**: Apply OCP - make tests extensible
4. **SHOULD**: Apply ISP - keep interfaces focused
5. **COULD**: Apply LSP - ensure substitutability

## Anti-Patterns to Avoid

- ❌ God tests (testing everything)
- ❌ Hard-coded dependencies
- ❌ Copy-paste test code
- ❌ Testing implementation details
- ❌ Brittle assertions
```

### 2. Test Pyramid Instructions (NUEVO)

**Archivo**: `instructions/patterns/test-pyramid.instructions.md`

```yaml
---
description: 'Test Pyramid implementation guidelines. Balance between unit, integration, and E2E tests for optimal ROI.'
applyTo: '**/*test*'
---

# Test Pyramid Guidelines

## The Pyramid

```
         /\
        /  \\     E2E Tests
       /____\\    (10% - Slow, Expensive)
      /      \\
     /        \\  Integration Tests
    /__________\\ (30% - Medium speed/cost)
   /            \\
  /______________\\ Unit Tests
                    (60% - Fast, Cheap)
```

## Layer Definitions

### Unit Tests (Base - 60%)

**Characteristics:**
- Fast execution (< 10ms per test)
- No external dependencies
- Test single functions/methods
- High isolation

**When to Write:**
- Business logic validation
- Utility function testing
- Data transformation testing
- Algorithm validation

**Guidelines:**
```typescript
// ✅ Good Unit Test
describe('calculateTotal', () => {
  it('sums item prices correctly', () => {
    const items = [
      { price: 10, quantity: 2 },
      { price: 5, quantity: 1 }
    ];
    expect(calculateTotal(items)).toBe(25);
  });
  
  it('applies discount correctly', () => {
    const items = [{ price: 100, quantity: 1 }];
    expect(calculateTotal(items, 0.1)).toBe(90);
  });
});
```

### Integration Tests (Middle - 30%)

**Characteristics:**
- Test component interactions
- May use test database
- External services mocked
- Medium execution speed

**When to Write:**
- API endpoint testing
- Database interaction testing
- Service integration testing
- Repository layer testing

**Guidelines:**
```typescript
// ✅ Good Integration Test
describe('User API', () => {
  it('creates user and stores in database', async () => {
    const userData = { name: 'John', email: 'john@test.com' };
    const response = await request(app)
      .post('/api/users')
      .send(userData);
    
    expect(response.status).toBe(201);
    
    const savedUser = await db.users.findById(response.body.id);
    expect(savedUser.email).toBe(userData.email);
  });
});
```

### E2E Tests (Top - 10%)

**Characteristics:**
- Full application stack
- Real browser interactions
- Slow execution (seconds)
- Validate user workflows

**When to Write:**
- Critical user journeys
- Cross-component workflows
- Regression scenarios
- Smoke tests

**Guidelines:**
```typescript
// ✅ Good E2E Test
test('complete purchase flow', async ({ page }) => {
  await test.step('add item to cart', async () => {
    await page.goto('/products');
    await page.getByRole('button', { name: 'Add to Cart' }).first().click();
    await expect(page.locator('.cart-count')).toHaveText('1');
  });
  
  await test.step('proceed to checkout', async () => {
    await page.getByRole('link', { name: 'Cart' }).click();
    await page.getByRole('button', { name: 'Checkout' }).click();
  });
  
  await test.step('complete payment', async () => {
    await page.fill('[name="cardNumber"]', '4111111111111111');
    await page.fill('[name="expiry"]', '12/25');
    await page.fill('[name="cvv"]', '123');
    await page.getByRole('button', { name: 'Pay' }).click();
  });
  
  await expect(page.locator('.confirmation')).toContainText('Order confirmed');
});
```

## Decision Matrix

| Scenario | Recommended Layer | Example |
|----------|------------------|---------|
| Input validation | Unit | Email format check |
| Business logic | Unit | Discount calculation |
| API contract | Integration | REST endpoint |
| Database query | Integration | Repository method |
| User registration | E2E | Signup flow |
| Checkout process | E2E | Payment flow |
| Service communication | Integration | Microservices |
| UI component behavior | Unit | React component |

## Anti-Patterns

### The Ice Cream Cone (Inverted Pyramid)

```
        //\\
       //  \\     Too many E2E tests
      //____\\    (Slow, brittle)
     //      \\
    //        \\  Too few integration tests
   //__________\\
  //            \\
 //______________\\ Too few unit tests
```

### The Hourglass

```
        /\
       /  \\     Many E2E tests
      /____\\
     /      \\
    |        |   Missing integration tests
    |        |
   /__________\\
  /            \\
 /______________\\ Many unit tests
```

## ROI Considerations

| Layer | Speed | Cost | Maintenance | Coverage | Priority |
|-------|-------|------|-------------|----------|----------|
| Unit | ⚡⚡⚡ | $ | Low | Function | P0 |
| Integration | ⚡⚡ | $$ | Medium | Component | P1 |
| E2E | ⚡ | $$$ | High | Workflow | P2 |

## Priority Guidelines

1. **Always** maximize unit test coverage first
2. **Then** add integration tests for critical paths
3. **Finally** add E2E tests for user journeys
4. **Never** have more E2E tests than integration tests
5. **Monitor** test execution time and maintainability
```

### 3. CI/CD Integration Instructions (NUEVO)

**Archivo**: `instructions/processes/ci-cd-integration.instructions.md`

```yaml
---
description: 'Integration of test automation into CI/CD pipelines. Guidelines for test execution, reporting, and quality gates.'
applyTo: '.github/workflows/*.yml, .gitlab-ci.yml, Jenkinsfile'
---

# CI/CD Integration for Test Automation

## Pipeline Stages

### Stage 1: Pre-Commit (Fast Feedback)

**Trigger**: On every commit  
**Duration**: < 2 minutes  
**Tests**: Linting, unit tests, type checking

```yaml
# .github/workflows/pre-commit.yml
name: Pre-Commit Checks
on: [push]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Lint
        run: npm run lint
      - name: Type Check
        run: npm run type-check
      - name: Unit Tests
        run: npm run test:unit -- --coverage --maxWorkers=2
```

### Stage 2: Integration (Component Testing)

**Trigger**: On PR creation/update  
**Duration**: < 10 minutes  
**Tests**: Integration tests, API tests

```yaml
# .github/workflows/integration.yml
name: Integration Tests
on: [pull_request]
jobs:
  integration:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
    steps:
      - uses: actions/checkout@v3
      - name: Integration Tests
        run: npm run test:integration
      - name: API Tests
        run: npm run test:api
```

### Stage 3: E2E (Full Validation)

**Trigger**: On PR approval, scheduled  
**Duration**: < 30 minutes  
**Tests**: E2E tests, visual regression

```yaml
# .github/workflows/e2e.yml
name: E2E Tests
on:
  schedule:
    - cron: '0 2 * * *'  # Nightly
  workflow_dispatch:
jobs:
  e2e:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        browser: [chromium, firefox, webkit]
    steps:
      - uses: actions/checkout@v3
      - name: Install Playwright
        run: npx playwright install --with-deps
      - name: Run E2E Tests
        run: npx playwright test --project=${{ matrix.browser }}
      - name: Upload Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
```

## Quality Gates

### Gate 1: Code Quality

```yaml
quality-gates:
  linting:
    max-warnings: 0
    fail-on-error: true
  
  type-coverage:
    min-coverage: 95%
    fail-on-error: true
  
  code-coverage:
    unit:
      min-lines: 80%
      min-functions: 90%
      min-branches: 75%
    integration:
      min-lines: 60%
```

### Gate 2: Test Results

```yaml
test-gates:
  unit:
    max-failures: 0
    max-skipped: 5
    
  integration:
    max-failures: 0
    block-on-timeout: true
    
  e2e:
    critical-paths:
      max-failures: 0
    other:
      max-failures: 10%
```

### Gate 3: Performance

```yaml
performance-gates:
  build-time:
    max-duration: 5m
    
  test-execution:
    unit:
      max-duration: 2m
    integration:
      max-duration: 10m
    e2e:
      max-duration: 30m
      
  bundle-size:
    max-increase: 10%
    max-total: 500kb
```

## Test Parallelization

### Unit Tests

```javascript
// jest.config.js
module.exports = {
  maxWorkers: '50%',
  testTimeout: 10000,
};
```

### E2E Tests

```javascript
// playwright.config.js
module.exports = {
  workers: process.env.CI ? 4 : undefined,
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
};
```

## Reporting and Notifications

### Test Reports

```yaml
- name: Generate Test Report
  if: always()
  run: npm run test:report

- name: Upload to Test Management
  if: always()
  run: |
    curl -X POST \
      -H "Authorization: Bearer ${{ secrets.TESTRail_TOKEN }}" \
      -F "file=@test-results.xml" \
      https://testrail.company.com/api/import
```

### Notifications

```yaml
- name: Notify Slack on Failure
  if: failure()
  uses: slack-action@v1
  with:
    webhook: ${{ secrets.SLACK_WEBHOOK }}
    message: "❌ Tests failed in ${{ github.ref }}"
```

## Best Practices

1. **Fail Fast**: Run quick tests first
2. **Parallelize**: Use all available workers
3. **Cache**: Cache dependencies and build artifacts
4. **Isolate**: Each test job should be independent
5. **Report**: Always generate and archive reports
6. **Retry**: Retry flaky tests in CI (max 2 retries)
7. **Notify**: Alert on failures, summarize on success

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Slow pipelines | Parallelize, cache, optimize selectors |
| Flaky tests | Retry logic, better waits, isolation |
| Resource limits | Use test sharding, reduce workers |
| Long E2E runs | Run critical paths only on PR, full suite nightly |
```

---

## 🛠️ Skills: Estructura y Ejemplos

### 1. Atomic Skills (NUEVO)

#### Locators Skill

**Archivo**: `skills/atomic/locators/role-based-locators.skill.md`

```markdown
---
name: role-based-locators
description: 'Priority-based locator strategy using ARIA roles for accessible and resilient element selection'
---

# Role-Based Locators Skill

## Priority Order

### Level 1: ARIA Roles (BEST)
Most accessible and resilient to UI changes.

```typescript
// ✅ RECOMMENDED: Button with visible text
page.getByRole('button', { name: 'Submit' })

// ✅ RECOMMENDED: Textbox with label
page.getByRole('textbox', { name: 'Email Address' })

// ✅ RECOMMENDED: Link by text
page.getByRole('link', { name: 'Sign Up' })

// ✅ RECOMMENDED: Heading level
page.getByRole('heading', { name: 'Welcome', level: 1 })
```

### Level 2: User-Facing Attributes

```typescript
// ✅ GOOD: Label text
page.getByLabel('Password')

// ✅ GOOD: Placeholder text
page.getByPlaceholder('Enter your name')

// ✅ GOOD: Visible text
page.getByText('Welcome back')

// ✅ GOOD: Title attribute
page.getByTitle('Close dialog')
```

### Level 3: Test IDs

```typescript
// ✅ ACCEPTABLE: When roles not available
page.getByTestId('submit-button')
page.getByTestId('user-menu')
```

### Level 4: CSS Selectors (AVOID)

```typescript
// ⚠️ AVOID: Brittle, tied to implementation
page.locator('.btn-primary')
page.locator('#submit-btn')
page.locator('div > button:nth-child(2)')

// ❌ NEVER: XPath is extremely brittle
page.locator('//div[@class="form"]/button[1]')
```

## Usage Guidelines

1. **Start with roles** - Check accessibility tree first
2. **Use exact matching** - `{ exact: true }` for precise matches
3. **Handle duplicates** - Add more context if multiple matches
4. **Document choices** - Comment why a specific locator is used

## Common Patterns

```typescript
// Form interaction
await page.getByRole('textbox', { name: 'Email' }).fill('test@example.com');
await page.getByRole('textbox', { name: 'Password' }).fill('password123');
await page.getByRole('button', { name: 'Sign In' }).click();

// Navigation
await page.getByRole('navigation')
  .getByRole('link', { name: 'Products' })
  .click();

// Complex queries
await page.getByRole('main')
  .getByRole('article')
  .filter({ hasText: 'Featured' })
  .getByRole('button', { name: 'Add to Cart' })
  .click();
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Strict mode violation | Multiple elements match | Add more specific filters |
| Element not found | Role not implemented | Check accessibility tree |
| Timeout | Element not visible | Add `waitFor()` or check state |
```

### 2. Composite Skills (NUEVO)

#### Page Object Model Factory

**Archivo**: `skills/composite/page-object-model/pom-factory.skill.md`

```markdown
---
name: pom-factory
description: 'Factory pattern for creating Page Objects with dependency injection and configuration'
---

# Page Object Model Factory

## Architecture

```
┌─────────────────────────────────────────┐
│         PageObjectFactory               │
│  ┌─────────────────────────────────┐    │
│  │  - Dependency Injection         │    │
│  │  - Configuration Management     │    │
│  │  - Lifecycle Management         │    │
│  └─────────────────────────────────┘    │
└──────────────────┬──────────────────────┘
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐
   │LoginPage│ │HomePage │ │CartPage │
   └─────────┘ └─────────┘ └─────────┘
```

## Implementation

### Base Page Class

```typescript
// pages/BasePage.ts
import { Page, Locator } from '@playwright/test';

export abstract class BasePage {
  constructor(protected page: Page) {}

  async goto(url: string): Promise<void> {
    await this.page.goto(url);
  }

  async waitForLoad(): Promise<void> {
    await this.page.waitForLoadState('networkidle');
  }

  async screenshot(name: string): Promise<void> {
    await this.page.screenshot({ path: `./screenshots/${name}.png` });
  }
}
```

### Page Factory

```typescript
// pages/PageFactory.ts
import { Page } from '@playwright/test';
import { BasePage } from './BasePage';
import { LoginPage } from './LoginPage';
import { HomePage } from './HomePage';
import { CartPage } from './CartPage';

export class PageFactory {
  private static instances = new Map<string, BasePage>();

  static getLoginPage(page: Page): LoginPage {
    return this.getInstance('login', page, LoginPage);
  }

  static getHomePage(page: Page): HomePage {
    return this.getInstance('home', page, HomePage);
  }

  static getCartPage(page: Page): CartPage {
    return this.getInstance('cart', page, CartPage);
  }

  private static getInstance<T extends BasePage>(
    key: string,
    page: Page,
    PageClass: new (page: Page) => T
  ): T {
    if (!this.instances.has(key)) {
      this.instances.set(key, new PageClass(page));
    }
    return this.instances.get(key) as T;
  }

  static clearInstances(): void {
    this.instances.clear();
  }
}
```

### Concrete Page Implementation

```typescript
// pages/LoginPage.ts
import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class LoginPage extends BasePage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    super(page);
    this.emailInput = page.getByRole('textbox', { name: 'Email' });
    this.passwordInput = page.getByRole('textbox', { name: 'Password' });
    this.submitButton = page.getByRole('button', { name: 'Sign In' });
    this.errorMessage = page.getByRole('alert');
  }

  async login(email: string, password: string): Promise<void> {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string): Promise<void> {
    await expect(this.errorMessage).toContainText(message);
  }

  async isLoaded(): Promise<boolean> {
    return await this.emailInput.isVisible();
  }
}
```

### Usage in Tests

```typescript
// tests/login.spec.ts
import { test, expect } from '@playwright/test';
import { PageFactory } from '../pages/PageFactory';

test.describe('Login Flow', () => {
  test('successful login redirects to home', async ({ page }) => {
    const loginPage = PageFactory.getLoginPage(page);
    const homePage = PageFactory.getHomePage(page);

    await loginPage.goto('/login');
    await loginPage.login('user@example.com', 'password123');
    
    await expect(page).toHaveURL('/home');
    expect(await homePage.isLoaded()).toBe(true);
  });
});
```

## Best Practices

1. **Single Responsibility**: Each page class handles one page/screen
2. **Fluent Interface**: Return `this` for method chaining
3. **Encapsulation**: Hide locators, expose actions
4. **Validation**: Include state verification methods
5. **Navigation**: Pages should know their URLs

## Advanced Features

### Component-Based Pages

```typescript
// components/Header.ts
export class Header extends BaseComponent {
  readonly searchBox: Locator;
  readonly cartIcon: Locator;
  readonly userMenu: Locator;

  async search(query: string): Promise<void> {
    await this.searchBox.fill(query);
    await this.searchBox.press('Enter');
  }
}

// pages/HomePage.ts
export class HomePage extends BasePage {
  readonly header: Header;

  constructor(page: Page) {
    super(page);
    this.header = new Header(page.locator('header'));
  }
}
```
```

### 3. Domain Skills (NUEVO)

#### Authentication Testing

**Archivo**: `skills/domain/authentication/login-flows.skill.md`

```markdown
---
name: login-flows
description: 'Complete authentication testing including login, logout, session management, and security validations'
---

# Login Flows Testing

## Test Scenarios

### 1. Basic Authentication

```typescript
test.describe('Basic Login', () => {
  test('successful login with valid credentials', async ({ page }) => {
    await page.goto('/login');
    await page.getByRole('textbox', { name: 'Email' }).fill('valid@user.com');
    await page.getByRole('textbox', { name: 'Password' }).fill('ValidPass123!');
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
  });

  test('failed login with invalid password', async ({ page }) => {
    await page.goto('/login');
    await page.getByRole('textbox', { name: 'Email' }).fill('valid@user.com');
    await page.getByRole('textbox', { name: 'Password' }).fill('wrongpassword');
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    await expect(page.getByRole('alert')).toContainText('Invalid credentials');
    await expect(page).toHaveURL('/login');
  });

  test('failed login with non-existent user', async ({ page }) => {
    await page.goto('/login');
    await page.getByRole('textbox', { name: 'Email' }).fill('nonexistent@test.com');
    await page.getByRole('textbox', { name: 'Password' }).fill('anypassword');
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    await expect(page.getByRole('alert')).toContainText('Invalid credentials');
  });
});
```

### 2. Input Validation

```typescript
test.describe('Login Input Validation', () => {
  test('validates email format', async ({ page }) => {
    await page.goto('/login');
    await page.getByRole('textbox', { name: 'Email' }).fill('invalid-email');
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    await expect(page.getByText('Please enter a valid email')).toBeVisible();
  });

  test('validates required fields', async ({ page }) => {
    await page.goto('/login');
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    await expect(page.getByText('Email is required')).toBeVisible();
    await expect(page.getByText('Password is required')).toBeVisible();
  });

  test('validates password minimum length', async ({ page }) => {
    await page.goto('/login');
    await page.getByRole('textbox', { name: 'Email' }).fill('user@test.com');
    await page.getByRole('textbox', { name: 'Password' }).fill('123');
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    await expect(page.getByText('Password must be at least 8 characters')).toBeVisible();
  });
});
```

### 3. Session Management

```typescript
test.describe('Session Management', () => {
  test('maintains session across page navigation', async ({ page }) => {
    // Login
    await login(page, 'user@test.com', 'password123');
    
    // Navigate to different pages
    await page.goto('/profile');
    await expect(page.getByRole('heading', { name: 'Profile' })).toBeVisible();
    
    await page.goto('/settings');
    await expect(page.getByRole('heading', { name: 'Settings' })).toBeVisible();
    
    // Return to dashboard - still logged in
    await page.goto('/dashboard');
    await expect(page.getByText('Welcome back')).toBeVisible();
  });

  test('logout clears session', async ({ page }) => {
    await login(page, 'user@test.com', 'password123');
    
    // Logout
    await page.getByRole('button', { name: 'Logout' }).click();
    
    // Try to access protected page
    await page.goto('/dashboard');
    await expect(page).toHaveURL('/login?redirect=/dashboard');
  });

  test('session timeout', async ({ page }) => {
    await login(page, 'user@test.com', 'password123');
    
    // Simulate timeout (if testable)
    await page.evaluate(() => {
      localStorage.removeItem('auth_token');
    });
    
    await page.reload();
    await expect(page).toHaveURL('/login');
  });
});
```

### 4. Security Testing

```typescript
test.describe('Login Security', () => {
  test('SQL injection prevention', async ({ page }) => {
    await page.goto('/login');
    await page.getByRole('textbox', { name: 'Email' }).fill("' OR '1'='1");
    await page.getByRole('textbox', { name: 'Password' }).fill("' OR '1'='1");
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    await expect(page.getByRole('alert')).toContainText('Invalid credentials');
  });

  test('XSS prevention in error messages', async ({ page }) => {
    await page.goto('/login');
    await page.getByRole('textbox', { name: 'Email' }).fill('<script>alert("xss")</script>');
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    // Verify script is not executed
    const alertCount = await page.evaluate(() => {
      return window.alertCalls || 0;
    });
    expect(alertCount).toBe(0);
  });

  test('rate limiting on failed attempts', async ({ page }) => {
    await page.goto('/login');
    
    // Attempt multiple failed logins
    for (let i = 0; i < 5; i++) {
      await page.getByRole('textbox', { name: 'Email' }).fill('user@test.com');
      await page.getByRole('textbox', { name: 'Password' }).fill('wrong');
      await page.getByRole('button', { name: 'Sign In' }).click();
    }
    
    // Should be rate limited
    await expect(page.getByText('Too many attempts')).toBeVisible();
  });

  test('password is masked', async ({ page }) => {
    await page.goto('/login');
    const passwordInput = page.getByRole('textbox', { name: 'Password' });
    
    await passwordInput.fill('secretpassword');
    const inputType = await passwordInput.getAttribute('type');
    expect(inputType).toBe('password');
  });
});
```

## Checklist

- [ ] Valid login with correct credentials
- [ ] Invalid login with wrong password
- [ ] Invalid login with non-existent user
- [ ] Email format validation
- [ ] Required field validation
- [ ] Password minimum length
- [ ] Session persistence
- [ ] Logout functionality
- [ ] Session timeout handling
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] Rate limiting
- [ ] Password masking
- [ ] Remember me functionality (if applicable)
- [ ] Password reset flow (if applicable)
- [ ] Multi-factor authentication (if applicable)
```

---

## 📈 Recomendaciones Adicionales

### 1. Sistema de Versionado

Implementar versionado semántico para agentes y skills:

```yaml
# agents/testing/playwright/test-generator.agent.md
---
name: playwright-test-generator
version: 2.1.0
description: '...'
changelog:
  2.1.0:
    - Added support for API test generation
    - Improved locator strategy selection
  2.0.0:
    - Breaking: Changed output format
    - Added handoffs support
---
```

### 2. Testing del Repositorio

Crear tests para validar la estructura de agents, instructions y skills:

```typescript
// tests/agents/agent-structure.spec.ts
test('all agents have required frontmatter', async () => {
  const agents = await glob('agents/**/*.agent.md');
  
  for (const agent of agents) {
    const content = await readFile(agent, 'utf-8');
    const frontmatter = parseFrontmatter(content);
    
    expect(frontmatter.name).toBeDefined();
    expect(frontmatter.description).toBeDefined();
    expect(frontmatter.description.length).toBeLessThan(150);
  }
});
```

### 3. Documentación Centralizada

Crear un `README.md` principal con:

- Mapa de agents y sus relaciones
- Diagrama de handoffs
- Guía de contribución
- Ejemplos de uso
- Troubleshooting

### 4. Métricas de Uso

Implementar tracking de:

- Qué agents se usan más frecuentemente
- Tiempo promedio de ejecución
- Tasa de éxito/fallo
- Cuello de botella en workflows

### 5. Integración Continua

Pipeline para validar cambios:

```yaml
validate-structure:
  - Check YAML syntax in frontmatter
  - Validate markdown formatting
  - Verify agent references exist
  - Check for circular handoffs
  - Run agent unit tests
```

### 6. Comunidad y Contribuciones

- Template para nuevos agents
- Checklist de code review
- Guía de estilo
- Proceso de solicitud de features

---

## ✅ Plan de Implementación Paso a Paso

### Fase 1: Fundamentos (Semanas 1-2)

#### Semana 1: Estructura Base

**Día 1-2: Reorganización de Directorios**
- [ ] Crear estructura de carpetas propuesta
- [ ] Mover agents existentes a nueva estructura
- [ ] Actualizar referencias cruzadas

**Día 3-4: QA Orchestrator Agent**
- [ ] Crear `agents/orchestration/qa-orchestrator.agent.md`
- [ ] Definir matriz de decisión
- [ ] Configurar handoffs iniciales

**Día 5: Validación**
- [ ] Probar orquestación con casos simples
- [ ] Documentar primera versión

#### Semana 2: Instructions Core

**Día 1-2: SOLID Testing Instructions**
- [ ] Crear `instructions/patterns/solid-testing.instructions.md`
- [ ] Incluir ejemplos por principio
- [ ] Definir prioridades

**Día 3-4: Test Pyramid Instructions**
- [ ] Crear `instructions/patterns/test-pyramid.instructions.md`
- [ ] Definir decision matrix por capa
- [ ] Incluir anti-patterns

**Día 5: CI/CD Instructions**
- [ ] Crear `instructions/processes/ci-cd-integration.instructions.md`
- [ ] Configurar quality gates
- [ ] Documentar troubleshooting

**Entregable Fase 1**: Base estructural funcional con orquestador operativo

---

### Fase 2: Agentes Especializados (Semanas 3-5)

#### Semana 3: API Testing

**Día 1-2: API Test Generator Agent**
- [ ] Crear `agents/testing/api/api-test-generator.agent.md`
- [ ] Definir scope (REST, GraphQL)
- [ ] Configurar herramientas (REST Assured, Supertest)

**Día 3-4: REST Assured Instructions**
- [ ] Crear `instructions/frameworks/restassured-api.instructions.md`
- [ ] Incluir best practices
- [ ] Definir estructura de tests

**Día 5: Skills Atómicos**
- [ ] Crear `skills/atomic/assertions/api-assertions.skill.md`
- [ ] Crear `skills/atomic/fixtures/test-data-management.skill.md`

**Entregable**: Agente de API testing funcional

#### Semana 4: Performance Testing

**Día 1-2: Performance Test Agent**
- [ ] Crear `agents/testing/performance/performance-test-agent.agent.md`
- [ ] Definir tipos de tests (load, stress, spike)
- [ ] Configurar thresholds

**Día 3-4: k6 Instructions**
- [ ] Crear `instructions/frameworks/k6-performance.instructions.md`
- [ ] Incluir SLAs y thresholds
- [ ] Definir reportes

**Día 5: Integration**
- [ ] Conectar con orchestrator
- [ ] Probar flujo completo

**Entregable**: Agente de performance testing operativo

#### Semana 5: Análisis y Debugging

**Día 1-2: Flakiness Detective Agent**
- [ ] Crear `agents/analysis/flakiness-detective.agent.md`
- [ ] Definir patrones de flakiness
- [ ] Crear formato de reporte

**Día 3-4: Coverage Analyst Agent**
- [ ] Crear `agents/analysis/coverage-analyst.agent.md`
- [ ] Definir métricas de cobertura
- [ ] Integrar con herramientas de coverage

**Día 5: Test Refactor Specialist**
- [ ] Crear `agents/analysis/test-refactor.agent.md`
- [ ] Definir técnicas de refactoring
- [ ] Incluir SOLID principles

**Entregable Fase 2**: Tres agentes especializados funcionando

---

### Fase 3: Skills y Reusabilidad (Semanas 6-8)

#### Semana 6: Skills Atómicos

**Día 1-2: Locators**
- [ ] Crear `skills/atomic/locators/role-based-locators.skill.md`
- [ ] Crear `skills/atomic/locators/data-testid-locators.skill.md`
- [ ] Crear `skills/atomic/locators/custom-locators.skill.md`

**Día 3-4: Waits y Assertions**
- [ ] Crear `skills/atomic/waits/auto-waiting.skill.md`
- [ ] Crear `skills/atomic/waits/explicit-waits.skill.md`
- [ ] Crear `skills/atomic/assertions/web-first-assertions.skill.md`

**Día 5: Integración**
- [ ] Validar que skills funcionan en agents existentes
- [ ] Documentar uso

**Entregable**: 6 skills atómicos listos

#### Semana 7: Skills Compuestos

**Día 1-3: Page Object Model**
- [ ] Crear `skills/composite/page-object-model/pom-factory.skill.md`
- [ ] Crear `skills/composite/page-object-model/pom-fluent-interface.skill.md`
- [ ] Crear `skills/composite/page-object-model/pom-component-model.skill.md`

**Día 4-5: Test Patterns**
- [ ] Crear `skills/composite/test-patterns/data-driven.skill.md`
- [ ] Crear `skills/composite/test-patterns/keyword-driven.skill.md`
- [ ] Crear `skills/composite/test-patterns/behavior-driven.skill.md`

**Entregable**: Skills compuestos para POM y patrones

#### Semana 8: Domain Skills

**Día 1-2: Authentication**
- [ ] Crear `skills/domain/authentication/login-flows.skill.md`
- [ ] Crear `skills/domain/authentication/oauth-testing.skill.md`

**Día 3: E-commerce**
- [ ] Crear `skills/domain/e-commerce/cart-workflows.skill.md`
- [ ] Crear `skills/domain/e-commerce/checkout-flows.skill.md`
- [ ] Crear `skills/domain/e-commerce/payment-testing.skill.md`

**Día 4-5: Form Testing**
- [ ] Crear `skills/domain/forms/form-validation.skill.md`
- [ ] Crear `skills/domain/forms/file-upload.skill.md`

**Entregable Fase 3**: Skills atómicos, compuestos y de dominio completos

---

### Fase 4: Integración y Validación (Semanas 9-10)

#### Semana 9: Integración Completa

**Día 1-2: Actualizar Agents Existentes**
- [ ] Refactorizar `playwright-test-generator` para usar nuevo POM skill
- [ ] Actualizar `playwright-test-healer` para usar flakiness detective
- [ ] Integrar skills atómicos en agents relevantes

**Día 3-4: Handoffs entre Agentes**
- [ ] Configurar handoffs en qa-orchestrator
- [ ] Probar flujos: Plan → Generate → Review → Fix
- [ ] Documentar handoffs disponibles

**Día 5: Testing del Repositorio**
- [ ] Crear tests de validación de estructura
- [ ] Implementar CI/CD para el repositorio
- [ ] Validar que todos los agents tienen frontmatter válido

**Entregable**: Todos los agents integrados con nuevo sistema

#### Semana 10: Validación y Documentación

**Día 1-2: End-to-End Testing**
- [ ] Crear proyecto de prueba real
- [ ] Probar flujo completo: API + UI tests
- [ ] Medir tiempos y calidad

**Día 3-4: Documentación**
- [ ] Crear README.md principal con arquitectura
- [ ] Documentar mapa de agents
- [ ] Crear guía de contribución
- [ ] Documentar troubleshooting

**Día 5: Refinamiento**
- [ ] Recoger feedback
- [ ] Ajustar agents según resultados
- [ ] Optimizar handoffs

**Entregable Fase 4**: Repositorio validado y documentado

---

### Fase 5: Mejoras y Escalabilidad (Semanas 11-12)

#### Semana 11: Features Avanzadas

**Día 1-2: Security Auditor Agent**
- [ ] Crear `agents/testing/security/security-auditor.agent.md`
- [ ] Integrar con OWASP guidelines
- [ ] Definir security testing checklist

**Día 3-4: Visual Regression Testing**
- [ ] Crear skill de visual regression
- [ ] Integrar con Playwright screenshots
- [ ] Definir baseline management

**Día 5: Mobile Testing**
- [ ] Crear instructions para Appium/Detox
- [ ] Adaptar skills para mobile

**Entregable**: Features avanzados implementados

#### Semana 12: Optimización y Futuro

**Día 1-2: Métricas y Analytics**
- [ ] Implementar tracking de uso de agents
- [ ] Crear dashboard de métricas
- [ ] Identificar oportunidades de mejora

**Día 3-4: Templates y Generators**
- [ ] Crear template para nuevos agents
- [ ] Crear template para nuevos skills
- [ ] Script para scaffold de nuevos componentes

**Día 5: Roadmap Futuro**
- [ ] Documentar próximos features planeados
- [ ] Crear sistema de feedback
- [ ] Definir proceso de releases

**Entregable Fase 5**: Sistema maduro con roadmap definido

---

## 📊 Métricas de Éxito

### Métricas Técnicas

- **Cobertura de Testing**: UI (✅), API (🆕), Performance (🆕), Security (🆕)
- **Tiempo de Generación de Tests**: Reducir 50% con nuevo orquestador
- **Reusabilidad**: 80%+ de skills son reutilizables entre proyectos
- **Mantenibilidad**: Todos los tests siguen SOLID principles

### Métricas de Negocio

- **Adopción**: 100% de QA engineers usan el sistema
- **Satisfacción**: NPS > 50
- **Eficiencia**: Reducción de 30% en tiempo de creación de tests
- **Calidad**: Reducción de 40% en bugs escapados

---

## 🚨 Riesgos y Mitigaciones

| Riesgo | Impacto | Probabilidad | Mitigación |
|--------|---------|--------------|------------|
| Complejidad excesiva | Alto | Media | Fasear implementación, documentar bien |
| Resistencia al cambio | Medio | Alta | Demostrar valor, training gradual |
| Dependencia de herramientas | Medio | Baja | Diseñar para ser agnóstico |
| Mantenimiento | Medio | Media | Tests automáticos, CI/CD |
| Performance de agents | Alto | Baja | Optimizar prompts, caching |

---

## 📝 Conclusión

Este plan de mejoras transforma el repositorio actual en una **plataforma completa de QA Automation AI-First** que:

1. **Orquesta** múltiples agents especializados
2. **Cubre** UI, API, Performance, Security testing
3. **Aplica** SOLID principles y Test Pyramid
4. **Proporciona** skills reutilizables atómicos y compuestos
5. **Integra** con CI/CD pipelines
6. **Escalan** según las necesidades del proyecto

**Estimación Total**: 12 semanas (3 meses)  
**Recursos Requeridos**: 1 Senior QA Automation Engineer (tiempo completo)  
**ROI Esperado**: 30% reducción en tiempo de testing, 40% mejora en calidad

---

## 📞 Soporte y Contacto

Para preguntas o sugerencias sobre este plan:
- **Issues**: Crear issue en el repositorio
- **Discussions**: Usar GitHub Discussions
- **Email**: qa-automation-team@company.com

---

*Última actualización: 2026-02-10*  
*Próxima revisión: 2026-03-10*
