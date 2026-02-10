# QA Automation AI Agents & Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![QA Automation](https://img.shields.io/badge/QA-Automation-blue)](https://github.com/your-org/test-automation-agents-skills)
[![AI Powered](https://img.shields.io/badge/AI-Powered-purple)](https://github.com/features/copilot)

> AI-powered framework for test automation with specialized agents, reusable skills, and comprehensive instructions built for Senior QA Engineers.

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/your-org/test-automation-agents-skills.git
cd test-automation-agents-skills

# 2. Configure your GitHub Copilot or compatible AI assistant
#    - Point to the agents/ directory
#    - Enable MCP servers if available

# 3. Start automating!
#    Select "QA Orchestrator" agent and describe your task
```

**Example prompts:**
- "Create Playwright tests for the login flow"
- "Debug my failing Selenium tests"
- "Generate API tests for the user endpoints"
- "Analyze test coverage for the payment module"

---

## Architecture

This framework follows a **4-layer architecture** designed for scalability and maintainability:

```
┌─────────────────────────────────────────────────────────────────┐
│                     QA AI-First Framework                       │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              LAYER 1: ORCHESTRATION                     │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │  QA Orchestrator Agent                           │    │   │
│  │  │  - Intelligent task routing                      │    │   │
│  │  │  - Structured handoffs                           │    │   │
│  │  │  - Context preservation                          │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              LAYER 2: SPECIALIZED AGENTS                │   │
│  │  Planning │ Generation │ Maintenance │ Analysis        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              LAYER 3: REUSABLE SKILLS                   │   │
│  │  Atomic Skills → Composite Skills → Specialized         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              LAYER 4: SHARED INSTRUCTIONS               │   │
│  │  Best Practices │ Frameworks │ Patterns                 │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Test Pyramid Integration

```
                    ▲
                   / \          Fewer, slower
                  / E2E\         Manual + Automated
                 /------\        2-5% of tests
                /  API   \
               /----------\      Service layer
              / Integration \    10-20% of tests
             /----------------\
            /    Unit Tests   \  Fast, isolated
           /--------------------\ 70-80% of tests
          /      AI-Assisted      \
         /   Test Generation      \
        /__________________________\
```

---

## Directory Structure

```
test-automation-agents-skills/
├── agents/                    # Specialized AI agents
│   ├── orchestration/         # ⭐ QA Orchestrator (start here!)
│   ├── planning/              # Test strategy, impact analysis
│   ├── generation/            # Test generators (UI, API, Unit)
│   ├── maintenance/           # Healing, refactoring, flaky tests
│   ├── analysis/              # Coverage, patterns, performance
│   └── specialized/           # API, Performance, Security, Mobile
│
├── skills/                    # Reusable capabilities
│   ├── atomic/                # ⭐ Building blocks (locators, assertions)
│   ├── composite/             # High-level skills (generation, healing)
│   └── specialized/           # Domain-specific skills
│
├── instructions/              # Shared guidelines
│   ├── core/                  # ⭐ QA fundamentals, testing pyramid
│   ├── best-practices/        # AI-assisted testing, maintenance
│   ├── frameworks/            # Playwright, Selenium, REST Assured, k6
│   └── patterns/              # POM, data-driven, isolation
│
├── docs/                      # Operational documentation
│   ├── architecture.md        # Detailed architecture guide
│   ├── troubleshooting.md     # Common issues and solutions
│   └── getting-started.md     # Step-by-step tutorials
│
└── scripts/                   # Utility scripts
    └── validate-structure.sh  # Validate repository structure
```

---

## Available Agents

### Orchestration

| Agent | Description | When to Use |
|-------|-------------|-------------|
| **QA Orchestrator** | Central router for all tasks | **Start here!** Routes to specialists |
| Workflow Coordinator | Manages multi-step pipelines | Complex workflows with dependencies |

### Planning

| Agent | Description | When to Use |
|-------|-------------|-------------|
| Test Strategist | Defines test strategy | New features, release planning |
| Impact Analyzer | Analyzes change impact | Before deployment, refactoring |

### Generation

| Agent | Description | When to Use |
|-------|-------------|-------------|
| Playwright Test Generator | Creates Playwright/TypeScript tests | Web UI testing |
| Selenium Test Generator | Creates Selenium/Java tests | Web UI testing (Java) |
| API Test Generator | Creates API tests | Backend testing |
| Test Data Generator | Generates test data | Data-driven testing |

### Maintenance

| Agent | Description | When to Use |
|-------|-------------|-------------|
| Test Healer | Diagnoses and fixes failing tests | Tests are failing |
| Flaky Test Hunter | Identifies flaky tests | Intermittent failures |
| Test Refactor | Improves test code quality | Code reviews, cleanup |

### Analysis

| Agent | Description | When to Use |
|-------|-------------|-------------|
| Coverage Analyst | Measures test coverage | Coverage reports |
| Failure Pattern Analyst | Identifies failure patterns | Recurring issues |
| Performance Analyst | Analyzes test performance | Slow tests |

### Specialized

| Agent | Description | When to Use |
|-------|-------------|-------------|
| API Tester | API and integration testing | Backend services |
| Performance Tester | Load and stress testing | Performance testing |
| Security Tester | Security vulnerability scanning | Security audits |
| Mobile Tester | Mobile app testing | iOS/Android apps |

---

## Usage Examples

### Example 1: Generate E2E Tests

```
# Using QA Orchestrator (recommended)
"I need E2E tests for the checkout flow in my e-commerce app.
Use Playwright with TypeScript. Follow POM pattern."

# The orchestrator will:
# 1. Analyze the request
# 2. Route to Playwright Test Generator
# 3. Generate page objects and tests
# 4. Return complete test files
```

### Example 2: Debug Failing Tests

```
# Direct to Test Healer
"My Selenium tests are failing with NoSuchElementException.
Help me fix them."

# The Test Healer will:
# 1. Analyze the test code
# 2. Identify timing/locator issues
# 3. Suggest explicit waits
# 4. Refactor with proper waits
```

### Example 3: Analyze Coverage

```
# Using Coverage Analyst
"Analyze test coverage for the payment module.
Identify gaps and suggest missing tests."

# The Coverage Analyst will:
# 1. Parse coverage reports
# 2. Identify uncovered code
# 3. Suggest test scenarios
# 4. Generate test templates
```

---

## Skills Directory

### Atomic Skills (Building Blocks)

| Category | Skills |
|----------|--------|
| **Locators** | `find-by-role`, `find-by-testid`, `find-by-text` |
| **Assertions** | `assert-visible`, `assert-text`, `assert-count` |
| **Waits** | `wait-for-visible`, `wait-for-clickable`, `wait-for-api` |
| **Interactions** | `click-safe`, `fill-form`, `select-option` |

### Composite Skills

| Category | Skills |
|----------|--------|
| **Generation** | `generate-e2e-test`, `generate-api-test`, `generate-unit-test` |
| **Healing** | `diagnose-failure`, `suggest-fixes`, `validate-fix` |
| **Refactoring** | `extract-pom`, `parameterize-test`, `deduplicate-test` |
| **Analysis** | `analyze-flakiness`, `measure-coverage`, `identify-patterns` |

---

## Framework Support

| Framework | Language | Status | Agent | Instructions |
|-----------|----------|--------|-------|--------------|
| **Playwright** | TypeScript/JS | ✅ Full Support | `playwright-test-generator` | `playwright-typescript.instructions.md` |
| **Selenium** | Java | ✅ Full Support | `selenium-test-generator` | `selenium-webdriver-java.instructions.md` |
| **REST Assured** | Java | 🚧 In Progress | `api-test-generator` | `rest-assured-testing.instructions.md` |
| **k6** | JavaScript | 🚧 Planned | `performance-tester` | `k6-performance.instructions.md` |

---

## Best Practices

This framework enforces industry best practices:

### Testing Pyramid
- **70-80%** Unit tests (fast, isolated)
- **10-20%** Integration tests (service layer)
- **2-5%** E2E tests (critical paths)

### SOLID Principles for Tests
- **S**ingle Responsibility: One test, one assertion
- **O**pen/Closed: Extensible page objects
- **L**iskov Substitution: Interchangeable test data
- **I**nterface Segregation: Focused page methods
- **D**ependency Inversion: Abstract test dependencies

### AI-Assisted Testing
- ✅ Review all AI-generated code before committing
- ✅ Use AI for boilerplate and repetitive tasks
- ❌ Never use AI for security testing without supervision
- ❌ Don't accept AI suggestions without understanding

---

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Contribution Guide

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-skill`)
3. Follow the structure in [plan-mejoras.md](plan-mejoras.md)
4. Test your changes thoroughly
5. Submit a pull request

### Adding a New Agent

```bash
# 1. Create agent file following the template
touch agents/your-category/your-agent.agent.md

# 2. Include required frontmatter
# - name, description, version, category
# - handoffs (if applicable)
# - capabilities, scope, decision-autonomy

# 3. Validate structure
./scripts/validate-structure.sh

# 4. Submit PR with description
```

### Adding a New Skill

```bash
# 1. Determine if atomic or composite
# 2. Create in appropriate directory
touch skills/atomic/your-category/your-skill.skill.md

# 3. Include required frontmatter
# - name, description, version, type
# - composed-of (if composite)
# - success-criteria

# 4. Add to composite skills that use it
```

---

## Documentation

- [Architecture Guide](docs/architecture.md) - Detailed system architecture
- [Getting Started](docs/getting-started.md) - Step-by-step tutorials
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- [Improvement Plan](plan-mejoras.md) - Roadmap and implementation plan

---

## Requirements

- GitHub Copilot or compatible AI assistant
- MCP servers (optional but recommended):
  - `playwright-mcp-server` for browser automation
  - `context7` for documentation lookup
- Node.js 18+ (for Playwright)
- Java 17+ (for Selenium)
- Python 3.10+ (for some utilities)

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Acknowledgments

Built with best practices from:
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
- [Google Testing Blog](https://testing.googleblog.com/)
- [Martin Fowler's Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html)
- [ISTQB Foundation Level](https://www.istqb.org/)

---

**Built with ❤️ for QA Automation Engineers**

*Questions? Open an issue or start a discussion!*
