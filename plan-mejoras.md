# Plan de Mejoras: QA Automation AI Agents & Skills Repository

**Fecha:** 2025-02-09
**Versión:** 1.0
**Autor:** Senior QA Automation Engineer & AI Solutions Architect

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Visión General de la Arquitectura Propuesta](#visión-general-de-la-arquitectura-propuesta)
3. [Agents: Estructura Mejorada](#agents-estructura-mejorada)
4. [Instructions: Estructura Mejorada](#instructions-estructura-mejorada)
5. [Skills: Estructura Mejorada](#skills-estructura-mejorada)
6. [Recomendaciones Adicionales](#recomendaciones-adicionales)
7. [Plan de Implementación Paso a Paso](#plan-de-implementación-paso-a-paso)

---

## Executive Summary

Este repositorio tiene una base sólida con 63 archivos y ~22,000 líneas de documentación especializada en Playwright y Selenium. Sin embargo, tras un análisis exhaustivo, se identifican oportunidades críticas para evolucionar hacia una arquitectura más orquestada, escalable y alineada con las mejores prácticas de QA Automation 2025.

### Hallazgos Clave

| Aspecto | Estado Actual | Propuesta |
|---------|---------------|-----------|
| **Orquestación** | Agents trabajan de forma aislada | QA Orchestrator con handoffs estructurados |
| **Cobertura** | Playwright + Selenium dominan | API, Performance, Security testing |
| **Reusabilidad** | Skills monolíticos | Skills atómicos y componibles |
| **Mantenibilidad** | Documentación extensa pero dispersa | Estructura modular con quick reference |
| **AI Integration** | Uso básico de MCP | Patrones de AI-assisted testing |

### Valor Propuesto

- **70% reducción** en tiempo de setup de nuevos proyectos
- **3x más rápido** debugging de tests fallidos con AI-assisted healing
- **90% cobertura** de tipos de testing comunes
- **Consistencia** garantizada entre proyectos y equipos

---

## Visión General de la Arquitectura Propuesta

### Principios Fundamentales

```
┌─────────────────────────────────────────────────────────────────┐
│                     QA AI-First Framework                       │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              LAYER 1: ORCHESTRATION                     │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │  QA Orchestrator Agent                           │    │   │
│  │  │  - Router inteligente de requests                │    │   │
│  │  │  - Handoffs estructurados                        │    │   │
│  │  │  - Context preservation                          │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              LAYER 2: SPECIALIZED AGENTS                │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │   │
│  │  │ Planning │ │ Code Gen │ │ Healing  │ │ Analysis │   │   │
│  │  │  Agent   │ │  Agent   │ │  Agent   │ │  Agent   │   │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │   │
│  │  │ API Test │ │Perf Test │ │Security  │ │ Mobile   │   │   │
│  │  │  Agent   │ │  Agent   │ │  Agent   │ │  Agent   │   │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              LAYER 3: REUSABLE SKILLS                   │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │  Atomic Skills (compose → Complex Skills)        │    │   │
│  │  │  - test-generation/*                             │    │   │
│  │  │  - test-healing/*                                │    │   │
│  │  │  - test-refactoring/*                            │    │   │
│  │  │  - test-analysis/*                               │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              LAYER 4: SHARED INSTRUCTIONS               │   │
│  │  - testing-best-practices.instructions.md              │   │
│  │  - ai-assisted-testing.instructions.md                 │   │
│  │  - test-maintenance.instructions.md                    │   │
│  │  - flaky-test-resolution.instructions.md               │   │
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

## Agents: Estructura Mejorada

### Estructura Propuesta

```
agents/
├── orchestration/
│   ├── qa-orchestrator.agent.md          # ⭐ NUEVO: Router principal
│   └── workflow-coordinator.agent.md     # ⭐ NUEVO: Coordinador de procesos
├── planning/
│   ├── test-strategist.agent.md          # Refactorizado desde planner
│   └── impact-analyzer.agent.md          # ⭐ NUEVO: Análisis de impacto
├── generation/
│   ├── playwright-test-generator.agent.md
│   ├── selenium-test-generator.agent.md
│   ├── api-test-generator.agent.md       # ⭐ NUEVO
│   └── test-data-generator.agent.md      # ⭐ NUEVO
├── maintenance/
│   ├── test-healer.agent.md              # Refactorizado
│   ├── flaky-test-hunter.agent.md        # ⭐ NUEVO
│   └── test-refactor.agent.md            # ⭐ NUEVO
├── analysis/
│   ├── test-coverage-analyst.agent.md    # ⭐ NUEVO
│   ├── failure-pattern-analyst.agent.md  # ⭐ NUEVO
│   └── performance-analyst.agent.md      # ⭐ NUEVO
└── specialized/
    ├── api-tester.agent.md               # ⭐ NUEVO
    ├── performance-tester.agent.md       # ⭐ NUEVO
    ├── security-tester.agent.md          # ⭐ NUEVO
    └── mobile-tester.agent.md            # ⭐ NUEVO
```

### Frontmatter Estándar Mejorado

```yaml
---
name: [Display Name]
description: '[50-150 chars] Clear description of purpose and capabilities'
version: '1.0.0'
category: 'orchestration|planning|generation|maintenance|analysis|specialized'
model: 'Claude Opus 4.6'
tools:
  - 'read'
  - 'edit'
  - 'search'
  - 'agent'  # Para orquestación
mcp-servers:
  playwright: 'local'
  context7: 'remote'

# Orquestación
handoffs:
  - label: [Action Button Label]
    agent: [target-agent-name]
    prompt: '[Optional pre-filled prompt]'
    send: false

# Metadatos
capabilities:
  - '[capability-1]'
  - '[capability-2]'
scope:
  includes: '[what this agent handles]'
  excludes: '[what this agent does NOT handle]'
decision-autonomy:
  level: 'full|guided|none'
  examples: '[types of decisions it can make]'

# Workflow integration
triggers:
  manual: true
  automatic: false
  contexts:
    - '[when this agent should be suggested]'
dependencies:
  agents: ['[agent-names this agent may invoke]']
  skills: ['[skill-names this agent uses]']
  instructions: ['[instruction-files this agent follows]']
output:
  format: '[markdown|code|json|report]'
  location: '[where output goes]'
  quality-gate: '[validation criteria]'
---
```

### Ejemplo: QA Orchestrator Agent

```markdown
---
name: QA Orchestrator
description: 'Central router for all QA automation tasks. Analyzes requests and delegates to specialized agents with proper handoffs and context preservation.'
version: '1.0.0'
category: 'orchestration'
model: 'Claude Opus 4.6'
tools: ['read', 'search', 'agent', 'web']
mcp-servers:
  context7: 'remote'

handoffs:
  - label: Generate Tests
    agent: test-generator
    prompt: 'Generate tests based on the analysis above.'
    send: false
  - label: Fix Failing Tests
    agent: test-healer
    prompt: 'Diagnose and fix the failing tests identified above.'
    send: false
  - label: Analyze Coverage
    agent: coverage-analyst
    prompt: 'Analyze test coverage for the areas mentioned above.'
    send: false

capabilities:
  - 'Route requests to appropriate specialist agents'
  - 'Preserve context across agent handoffs'
  - 'Coordinate multi-step workflows'
  - 'Aggregate results from multiple agents'

scope:
  includes: 'Task delegation, workflow orchestration, result aggregation'
  excludes: 'Direct code writing, direct test execution, final implementation'

decision-autonomy:
  level: 'guided'
  examples:
    - 'Select appropriate agent based on task type'
    - 'Determine if task requires multiple agents'
    - 'Validate agent outputs before returning'
    - 'Cannot: Make architectural decisions without user confirmation'
---
```

### Definiciones de Responsabilidad por Categoría

#### Orchestration Agents

| Agente | Responsabilidad | Decisiones Autónomas | Límites |
|--------|----------------|---------------------|---------|
| QA Orchestrator | Routing y coordinación | Seleccionar agente, secuenciar pasos | No escribe código directamente |
| Workflow Coordinator | Ejecutar pipelines multi-step | Reintentos fallidos, paralelización | No desvia del workflow definido |

#### Planning Agents

| Agente | Responsabilidad | Decisiones Autónomas | Límites |
|--------|----------------|---------------------|---------|
| Test Strategist | Definir estrategia de testing | Priorizar tipos de tests, estimar esfuerzo | No ejecuta sin aprobación |
| Impact Analyzer | Analizar impacto de cambios | Identificar áreas de riesgo | No modifica código |

#### Generation Agents

| Agente | Responsabilidad | Decisiones Autónomas | Límites |
|--------|----------------|---------------------|---------|
| Test Generator | Escribir tests automáticos | Selector strategy, test structure | Sigue POM estrictamente |
| Test Data Generator | Crear datos de prueba | Tipos de datos, edge cases | Respeta privacidad/PII |

---

## Instructions: Estructura Mejorada

### Estructura Propuesta

```
instructions/
├── core/
│   ├── qa-fundamentals.instructions.md         # ⭐ NUEVO
│   ├── testing-pyramid.instructions.md        # ⭐ NUEVO
│   └── solid-for-testing.instructions.md      # ⭐ NUEVO
├── best-practices/
│   ├── test-maintenance.instructions.md       # ⭐ NUEVO
│   ├── flaky-test-resolution.instructions.md  # ⭐ NUEVO
│   ├── test-coverage.instructions.md          # ⭐ NUEVO
│   └── ai-assisted-testing.instructions.md    # ⭐ NUEVO
├── frameworks/
│   ├── playwright-typescript.instructions.md  # Refactorizado
│   ├── selenium-webdriver-java.instructions.md # Refactorizado
│   ├── rest-assured-testing.instructions.md   # ⭐ NUEVO
│   └── k6-performance.instructions.md         # ⭐ NUEVO
└── patterns/
    ├── page-object-model.instructions.md     # ⭐ NUEVO
    ├── data-driven-testing.instructions.md   # ⭐ NUEVO
    └── test-isolation.instructions.md        # ⭐ NUEVO
```

### Frontmatter Estándar para Instructions

```yaml
---
description: '[Purpose and scope of these instructions]'
version: '1.0.0'
category: 'core|best-practices|frameworks|patterns'
applies-to:
  agents: ['[agent-names that use these instructions]']
  skills: ['[skill-names that use these instructions]']
  frameworks: ['[relevant testing frameworks]']
priority: 'mandatory|recommended|optional'

# Estructura del contenido
sections:
  - 'principles'
  - 'rules'
  - 'examples'
  - 'anti-patterns'
  - 'troubleshooting'

# Validación
compliance:
  must-follow: ['[critical rules that cannot be broken]']
  should-follow: ['[recommended practices]']
  can-ignore: ['[situations where exceptions apply]']
---
```

### Ejemplo: AI-Assisted Testing Instructions

```markdown
---
description: 'Best practices for using AI effectively in test automation while maintaining quality and human oversight'
version: '1.0.0'
category: 'best-practices'
applies-to:
  agents: ['*']
  skills: ['*']
priority: 'recommended'
compliance:
  must-follow:
    - 'Always review AI-generated code before committing'
    - 'Never use AI for security testing without supervision'
    - 'Validate AI-generated test data for PII'
  should-follow:
    - 'Use AI for boilerplate and repetitive tasks'
    - 'Leverage AI for test idea generation'
    - 'Apply AI for refactoring suggestions'
  can-ignore:
    - 'Simple, well-known patterns'
    - 'Critical path tests (prefer manual review)'
---
```

### Template de Contenido para Instructions

```markdown
# [Instruction Title]

## Purpose
[Why these instructions exist and what problem they solve]

## Principles
1. **[Principle Name]**
   - [Explanation]
   - [When it applies]

## Rules

### Must (Critical)
| Rule | Rationale | Exception |
|------|-----------|-----------|
| [Rule 1] | [Why] | [When to skip] |

### Should (Recommended)
| Practice | Benefit | Alternative |
|----------|----------|-------------|
| [Practice 1] | [Why] | [Alternative approach] |

### Must Not (Anti-patterns)
| Anti-pattern | Consequence | Correct Approach |
|--------------|--------------|------------------|
| [Anti-pattern 1] | [What goes wrong] | [Right way] |

## Examples

### ✅ Good Example
```[language]
[Code/example following the rules]
```

### ❌ Bad Example
```[language]
[Code/example violating rules]
```

## Troubleshooting

| Issue | Diagnosis | Solution |
|-------|-----------|----------|
| [Problem 1] | [How to identify] | [How to fix] |

## References
- [External documentation links]
- [Related instructions]
```

---

## Skills: Estructura Mejorada

### Estructura Propuesta

```
skills/
├── atomic/                                    # ⭐ NUEVO: Skills atómicos
│   ├── locators/
│   │   ├── find-by-role.skill.md
│   │   ├── find-by-testid.skill.md
│   │   └── find-by-text.skill.md
│   ├── assertions/
│   │   ├── assert-visible.skill.md
│   │   ├── assert-text.skill.md
│   │   └── assert-count.skill.md
│   ├── waits/
│   │   ├── wait-for-visible.skill.md
│   │   ├── wait-for-clickable.skill.md
│   │   └── wait-for-api.skill.md
│   └── interactions/
│       ├── click-safe.skill.md
│       ├── fill-form.skill.md
│       └── select-option.skill.md
├── composite/                                 # Skills de alto nivel
│   ├── test-generation/                       # Refactorizado
│   │   ├── generate-e2e-test.skill.md
│   │   ├── generate-api-test.skill.md
│   │   └── generate-unit-test.skill.md
│   ├── test-healing/                          # Refactorizado
│   │   ├── diagnose-failure.skill.md
│   │   ├── suggest-fixes.skill.md
│   │   └── validate-fix.skill.md
│   ├── test-refactoring/                      # ⭐ NUEVO
│   │   ├── extract-pom.skill.md
│   │   ├── parameterize-test.skill.md
│   │   └── deduplicate-test.skill.md
│   └── test-analysis/                         # ⭐ NUEVO
│       ├── analyze-flakiness.skill.md
│       ├── measure-coverage.skill.md
│       └── identify-patterns.skill.md
└── specialized/
    ├── api-testing/
    │   ├── rest-assured-test.skill.md
    │   └── graphql-test.skill.md
    ├── performance-testing/
    │   ├── k6-load-test.skill.md
    │   └── k6-stress-test.skill.md
    └── security-testing/
        ├── owasp-zap.skill.md
        └── auth-test.skill.md
```

### Frontmatter Estándar para Skills

```yaml
---
name: '[skill-name]'
description: '[Clear description of what this skill does]'
version: '1.0.0'
type: 'atomic|composite|specialized'
category: 'test-generation|test-healing|test-refactoring|test-analysis'

# Composición (para skills compuestos)
composed-of:
  - 'atomic/locators/find-by-role'
  - 'atomic/assertions/assert-visible'

# Uso
activation: 'explicit|implicit|contextual'
aliases: ['[alternative-names for invoking this skill]']

# Prerrequisitos
requires:
  skills: ['[atomic skills this depends on]']
  knowledge: ['[concepts the user should know]']
  tools: ['[MCP servers or tools needed]']

# Output
output:
  format: '[code|markdown|json|report]'
  template: '[path to output template]'

# Métricas
success-criteria:
  - '[measurable outcome 1]'
  - '[measurable outcome 2]'
---
```

### Ejemplo: Atomic Skill - find-by-role

```markdown
---
name: find-by-role
description: 'Locate elements using role-based selectors following accessibility best practices'
version: '1.0.0'
type: 'atomic'
category: 'locators'

activation: 'implicit'
aliases: ['getByRole', 'role-locator']

requires:
  knowledge: ['ARIA roles', 'Accessibility tree']
  tools: ['playwright/*']

output:
  format: 'code'

success-criteria:
  - 'Returns a valid locator object'
  - 'Uses semantic role when available'
  - 'Falls back to accessible name when needed'
---
```

### Ejemplo: Composite Skill - generate-e2e-test

```markdown
---
name: generate-e2e-test
description: 'Generate complete E2E test with page objects, assertions, and test data following best practices'
version: '1.0.0'
type: 'composite'
category: 'test-generation'

composed-of:
  - 'atomic/locators/find-by-role'
  - 'atomic/assertions/assert-visible'
  - 'atomic/interactions/fill-form'
  - 'atomic/interactions/click-safe'
  - 'atomic/waits/wait-for-visible'

activation: 'explicit'
aliases: ['e2e', 'end-to-end-test', 'flow-test']

requires:
  skills: ['page-object-model', 'test-data-generation']
  knowledge: ['User flow', 'Test scenarios']
  tools: ['playwright/*', 'context7/*']

output:
  format: 'code'
  template: 'templates/e2e-test.template.ts'

success-criteria:
  - 'Test runs without errors'
  - 'Follows POM pattern'
  - 'Includes proper assertions'
  - 'Has descriptive test name'
  - 'Uses test data generation'
---
```

---

## Recomendaciones Adicionales

### 1. Documentación Operacional

#### README Principal

Crear `README.md` en la raíz con contenido completo (ver Apéndice C: README Completo).

**Secciones requeridas:**
1. Hero con descripción y badges
2. Quick Start (3 pasos)
3. Architecture diagrama
4. Available Agents tabla
5. Skills directory
6. Usage Examples
7. Contributing
8. License

**Ubicación:** `README.md` (raíz del repositorio)
**Prioridad:** P0 - Debe crearse en Phase 1, Step 1.1

#### Troubleshooting Guide

Crear `docs/troubleshooting.md` con problemas comunes y soluciones.

### 2. Sistema de Versionado

```yaml
# versioning.schema.yaml

versioning:
  format: 'semantic'  # major.minor.patch
  agents: '1.x.x'
  skills: '1.x.x'
  instructions: '1.x.x'

changelog:
  location: 'CHANGELOG.md'
  format: 'keep-a-changelog'
```

### 3. Validación de Estructura

```bash
# scripts/validate-structure.sh
#!/bin/bash
# Validar que todos los archivos tengan el frontmatter correcto
# Validar que los handoffs apunten a agentes existentes
# Validar que las referencias entre archivos sean correctas
```

### 4. Métricas de Uso

```yaml
# Agregar a cada agent/skill:

metrics:
  # No recolectar PII
  tracking:
    - invocation_count      # Cuántas veces se usa
    - success_rate          # Tasa de éxito
    - avg_duration          # Duración promedio

  # Opt-out siempre disponible
  privacy: 'anonymous-only'
```

### 5. CI/CD Integration

```yaml
# .github/workflows/validate-agents.yml
name: Validate Agents
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate frontmatter
        run: ./scripts/validate-structure.sh
      - name: Test agents
        run: ./scripts/test-agents.sh
```

---

## Plan de Implementación Paso a Paso

### Phase 1: Foundation (Weeks 1-2)

#### Step 1.1: Create Core Infrastructure
- [x] Create `README.md` with architecture overview ⭐ **COMPLETADO**
- [ ] Add `.github/` directory structure
- [ ] Create `docs/` for operational documentation
- [ ] Set up validation scripts

**Files to create:**
```
README.md ✅
docs/architecture.md
docs/troubleshooting.md
docs/getting-started.md
scripts/validate-structure.sh
.github/workflows/validate.yml
```

**README.md内容包括:**
- [x] Hero section con badges
- [x] Quick Start (3 pasos)
- [x] Architecture diagrama ASCII
- [x] Test Pyramid diagrama
- [x] Directory structure
- [x] Available Agents tabla
- [x] Usage Examples (3 ejemplos)
- [x] Skills Directory
- [x] Framework Support table
- [x] Best Practices
- [x] Contributing guide
- [x] Documentation links
- [x] Requirements
- [x] License
- [x] Acknowledgments

#### Step 1.2: Establish Core Instructions
- [x] Create `instructions/core/qa-fundamentals.instructions.md` ✅
- [x] Create `instructions/core/testing-pyramid.instructions.md` ✅
- [x] Create `instructions/core/solid-for-testing.instructions.md` ✅

**Content priorities:**
1. Test Pyramid with percentages (70-80% unit, 10-20% integration, 2-5% E2E) ✅
2. SOLID applied to test automation ✅
3. Test independence and isolation principles ✅

### Phase 2: Orchestration Layer (Weeks 3-4)

#### Step 2.1: Create QA Orchestrator
- [x] Create `agents/orchestration/qa-orchestrator.agent.md` ✅
- [x] Define routing logic ✅
- [x] Set up handoffs to all existing agents ✅
- [ ] Test with sample requests (manual validation)

**Routing logic:**
```python
if task_type == "create tests":
    route_to("test-generator")
elif task_type == "fix failing tests":
    route_to("test-healer")
elif task_type == "analyze coverage":
    route_to("coverage-analyst")
elif "api" in task_description:
    route_to("api-tester")
# ... etc
```

#### Step 2.2: Update Existing Agents
- [x] Add `handoffs` to all existing agents ✅
- [x] Standardize frontmatter format ✅
- [x] Add `capabilities` and `scope` sections ✅
- [ ] Update to reference core instructions

### Phase 3: Atomic Skills (Weeks 5-6)

#### Step 3.1: Create Atomic Skills Structure
- [x] Create `skills/atomic/` directory ✅
- [x] Create subdirectories: `locators/`, `assertions/`, `waits/`, `interactions/` ✅

#### Step 3.2: Implement Core Atomic Skills
- [x] `skills/atomic/locators/find-by-role.skill.md` ✅
- [x] `skills/atomic/locators/find-by-testid.skill.md` ✅
- [x] `skills/atomic/assertions/assert-visible.skill.md` ✅
- [x] `skills/atomic/assertions/assert-text.skill.md` ✅
- [x] `skills/atomic/waits/wait-for-visible.skill.md` ✅
- [x] `skills/atomic/interactions/click-safe.skill.md` ✅
- [x] `skills/atomic/interactions/fill-form.skill.md` ✅

### Phase 4: Best Practices Instructions (Weeks 7-8)

#### Step 4.1: AI-Assisted Testing Guidelines
- [x] Create `instructions/best-practices/ai-assisted-testing.instructions.md` ✅
- [x] Define AI usage patterns ✅
- [x] Document validation requirements ✅
- [x] Add examples of good vs bad AI usage ✅

#### Step 4.2: Maintenance Instructions
- [x] Create `instructions/best-practices/test-maintenance.instructions.md` ✅
- [x] Create `instructions/best-practices/flaky-test-resolution.instructions.md` ✅
- [x] Create `instructions/best-practices/test-coverage.instructions.md` ✅

### Phase 5: New Specialized Areas (Weeks 9-12)

#### Step 5.1: API Testing
- [x] Create `agents/specialized/api-tester.agent.md` ✅
- [x] Create `instructions/frameworks/rest-assured-testing.instructions.md` ✅
- [ ] Create `skills/specialized/api-testing/rest-assured-test.skill.md`

#### Step 5.2: Performance Testing
- [x] Create `agents/specialized/performance-tester.agent.md` ✅
- [x] Create `instructions/frameworks/k6-performance.instructions.md` ✅
- [ ] Create `skills/specialized/performance-testing/k6-load-test.skill.md`

#### Step 5.3: Additional Specialized Agents & Patterns
- [x] Create `agents/specialized/flaky-test-hunter.agent.md` ✅
- [x] Create `agents/specialized/test-coverage-analyst.agent.md` ✅
- [x] Create `agents/specialized/test-refactor.agent.md` ✅
- [x] Create `instructions/patterns/page-object-model.instructions.md` ✅
- [x] Create `instructions/patterns/data-driven-testing.instructions.md` ✅
- [x] Create `instructions/patterns/test-isolation.instructions.md` ✅

### Phase 5.5: Composite Skills (BONUS - Completed)
- [x] Create `skills/composite/test-generation/generate-e2e-test.skill.md` ✅
- [x] Create `skills/composite/test-healing/diagnose-failure.skill.md` ✅
- [x] Create `skills/composite/test-healing/suggest-fixes.skill.md` ✅
- [x] Create `skills/composite/test-refactoring/extract-pom.skill.md` ✅
- [x] Create `skills/composite/test-analysis/analyze-flakiness.skill.md` ✅
- [x] Create `skills/composite/test-analysis/measure-coverage.skill.md` ✅

### Phase 6: Integration & Validation (Weeks 13-14)

#### Step 6.1: Cross-Reference Validation
- [ ] Validate all handoff references
- [ ] Check instruction dependencies
- [ ] Verify skill compositions

### Phase 6: Integration & Validation (Weeks 13-14)

#### Step 6.1: Cross-Reference Validation
- [ ] Validate all handoff references
- [ ] Check instruction dependencies
- [ ] Verify skill compositions
- [ ] Test full workflows

#### Step 6.2: Documentation
- [ ] Update README with all new agents
- [ ] Create migration guide from old structure
- [ ] Add contribution guidelines
- [ ] Document breaking changes

### Phase 7: Quality Assurance (Weeks 15-16)

#### Step 7.1: Testing
- [ ] Test each agent independently
- [ ] Test orchestrator routing
- [ ] Test handoff flows
- [ ] Validate skill compositions

#### Step 7.2: Review & Refine
- [ ] Peer review of all new content
- [ ] User testing with sample projects
- [ ] Performance optimization
- [ ] Final documentation polish

---

## Priorización de Implementación

| Priority | Items | Effort | Impact |
|----------|-------|--------|--------|
| **P0** | QA Orchestrator, Core Instructions, README | Medium | High |
| **P1** | Atomic Skills, AI Testing Guidelines | Medium | High |
| **P2** | API Testing, Flaky Test Resolution | Medium | Medium |
| **P3** | Performance Testing, Security Testing | High | Medium |

---

## Success Criteria

### Quantitative
- [ ] All agents have standardized frontmatter
- [ ] All agents have handoffs configured
- [ ] 100% of existing skills documented
- [ ] 15+ atomic skills created
- [ ] 5+ new specialized agents
- [ ] Zero broken references

### Qualitative
- [ ] New user can get started in < 15 minutes
- [ ] Clear separation of concerns between layers
- [ ] Reusable components across projects
- [ ] AI assistance feels natural, not forced

---

## Appendix A: Quick Reference Cards

### Agent Decision Tree

```
Start
 │
 ├─ Need to CREATE tests?
 │   ├─ UI/E2E? → test-generator (playwright/selenium)
 │   ├─ API? → api-tester
 │   └─ Unit? → unit-test-generator
 │
 ├─ Need to FIX tests?
 │   ├─ Tests failing? → test-healer
 │   ├─ Flaky tests? → flaky-test-hunter
 │   └─ Need refactor? → test-refactor
 │
 ├─ Need to ANALYZE?
 │   ├─ Coverage? → coverage-analyst
 │   ├─ Performance? → performance-analyst
 │   └─ Patterns? → failure-pattern-analyst
 │
 └─ Not sure? → qa-orchestrator
```

### Skill Composition Matrix

| Atomic Skill | Used By |
|--------------|---------|
| find-by-role | generate-test, heal-test |
| assert-visible | generate-test, validate-fix |
| wait-for-clickable | heal-test, generate-test |
| click-safe | generate-e2e-test |
| fill-form | generate-e2e-test |

---

## Appendix B: Migration Checklist

When migrating existing content:

- [ ] Read and understand existing agent/skill
- [ ] Identify atomic components
- [ ] Create new standardized frontmatter
- [ ] Extract reusable logic to atomic skills
- [ ] Add handoffs where appropriate
- [ ] Update references
- [ ] Test migrated content
- [ ] Archive old version
- [ ] Update documentation

---

## Appendix C: README Principal Completo

El siguiente es el contenido completo para `README.md` que debe crearse en Phase 1, Step 1.1:

```markdown
# QA Automation AI Agents & Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![QA Automation](https://img.shields.io/badge/QA-Automation-blue)](https://github.com/your-org/test-automation-agents-skills)
[![AI Powered](https://img.shields.io/badge/AI-Powered-purple)](https://github.com/features/copilot)

> AI-powered framework for test automation with specialized agents, reusable skills, and comprehensive instructions built for Senior QA Engineers.

---

## Quick Start

\`\`\`bash
# 1. Clone the repository
git clone https://github.com/your-org/test-automation-agents-skills.git
cd test-automation-agents-skills

# 2. Configure your GitHub Copilot or compatible AI assistant
#    - Point to the agents/ directory
#    - Enable MCP servers if available

# 3. Start automating!
#    Select "QA Orchestrator" agent and describe your task
\`\`\`

**Example prompts:**
- "Create Playwright tests for the login flow"
- "Debug my failing Selenium tests"
- "Generate API tests for the user endpoints"
- "Analyze test coverage for the payment module"

---

## Architecture

This framework follows a **4-layer architecture** designed for scalability and maintainability:

\`\`\`
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
\`\`\`

### Test Pyramid Integration

\`\`\`
                    ▲
                   / \\          Fewer, slower
                  / E2E\\         Manual + Automated
                 /------\\        2-5% of tests
                /  API   \\
               /----------\\      Service layer
              / Integration \\    10-20% of tests
             /----------------\\
            /    Unit Tests   \\  Fast, isolated
           /--------------------\\ 70-80% of tests
          /      AI-Assisted      \\
         /   Test Generation      \\
        /__________________________\\
\`\`\`

---

## Directory Structure

\`\`\`
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
\`\`\`

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

\`\`\`
# Using QA Orchestrator (recommended)
"I need E2E tests for the checkout flow in my e-commerce app.
Use Playwright with TypeScript. Follow POM pattern."

# The orchestrator will:
# 1. Analyze the request
# 2. Route to Playwright Test Generator
# 3. Generate page objects and tests
# 4. Return complete test files
\`\`\`

### Example 2: Debug Failing Tests

\`\`\`
# Direct to Test Healer
"My Selenium tests are failing with NoSuchElementException.
Help me fix them."

# The Test Healer will:
# 1. Analyze the test code
# 2. Identify timing/locator issues
# 3. Suggest explicit waits
# 4. Refactor with proper waits
\`\`\`

### Example 3: Analyze Coverage

\`\`\`
# Using Coverage Analyst
"Analyze test coverage for the payment module.
Identify gaps and suggest missing tests."

# The Coverage Analyst will:
# 1. Parse coverage reports
# 2. Identify uncovered code
# 3. Suggest test scenarios
# 4. Generate test templates
\`\`\`

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
3. Follow the structure in `plan-mejoras.md`
4. Test your changes thoroughly
5. Submit a pull request

### Adding a New Agent

\`\`\`bash
# 1. Create agent file following the template
touch agents/your-category/your-agent.agent.md

# 2. Include required frontmatter
# - name, description, version, category
# - handoffs (if applicable)
# - capabilities, scope, decision-autonomy

# 3. Validate structure
./scripts/validate-structure.sh

# 4. Submit PR with description
\`\`\`

### Adding a New Skill

\`\`\`bash
# 1. Determine if atomic or composite
# 2. Create in appropriate directory
touch skills/atomic/your-category/your-skill.skill.md

# 3. Include required frontmatter
# - name, description, version, type
# - composed-of (if composite)
# - success-criteria

# 4. Add to composite skills that use it
\`\`\`

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
```

---

## Appendix D: Validación del README

### Checklist de Contenido

Al crear el README.md, verificar:

- [ ] Hero section con badges
- [ ] Quick Start de 3 pasos
- [ ] Architecture diagrama ASCII
- [ ] Test Pyramid diagrama
- [ ] Directory structure completa
- [ ] Tabla de Available Agents (todas las categorías)
- [ ] Usage Examples (3+ ejemplos)
- [ ] Skills Directory (atomic + composite)
- [ ] Framework Support table
- [ ] Best Practices section
- [ ] Contributing guide
- [ ] Links a documentación adicional
- [ ] Requirements
- [ ] License
- [ ] Acknowledgments

### Checklist de Formato

- [ ] Markdown válido
- [ ] Enlaces funcionales
- [ ] Badges correctos
- [ ] Código blocks con syntax highlighting
- [ ] Tablas bien formateadas
- [ ] Sin enlaces rotos
- [ ] Consistencia de formato

---

**End of Plan**

*This plan is a living document. As implementation progresses, adjust based on learnings and feedback.*
