# Implementation Plan v3 — Test Automation Skills & Agents Optimization

> **Repository:** `test-automation-skills-agents`  
> **Branch:** `chore/skills-qa-automation-v3`  
> **Location:** `docs/enhancements/implementation-plan-v3.md`  
> **Audience:** QA Automation Engineers, SDETs, QA Leads  
> **Status:** Executed (2026-07-30) — adapted to the post-consolidation repo state (9 skills / 7 agents). All applicable tasks landed; structural lint (`scripts/lint-skills.mjs`) passes with 0 errors / 0 warnings. See the session output for the implementation summary, eval results, and final diagnosis.  

---

## 1. Decisiones y Orientaciones Confirmadas por el Usuario

1. **Regla de Frontmatter en AGENTS.md:** `name: skill-name` sin comillas simples sigue la convención de creación de skills de Anthropic. Se actualizará `AGENTS.md` (L87) para corregir la regla y reflejar que `name` en `SKILL.md` no requiere comillas simples obligatorias.
2. **Plantilla Inexistente (`qa-test-planner`):** Eliminar la referencia a `templates/regression-suite.md` en el Workflow 4 del planner.
3. **Selenium Manager vs WebDriverManager:** Eliminar completamente cualquier mención a `WebDriverManager` de Boni Garcia. Usar exclusivamente **Selenium Manager** (built-in Selenium 4.6+).
4. **Build Tool (Maven vs Gradle):** Eliminar cualquier mención de Gradle por completo. Toda la automatización de Selenium Java utilizará exclusivamente **Maven** (`pom.xml`, `mvn test`).
5. **Baseline Java:** Estandarizar a **Java 21+** (versión estable y actual) en todos los agentes, skills e instrucciones de Selenium y API testing Java.
6. **Agente-Agnóstico (`api-testing`):** Eliminar el acoplamiento directo entre `api-testing/SKILL.md` y `api-tester-specialist` agent.
7. **Duplicación de Archivos (OD-1):** Sincronizar las copias locales de referencias (`locator-strategies.md`, `page-object-model.md`) dentro de cada carpeta de skill para permitir su exportación/copia independiente.
8. **Alcance WCAG en Accesibilidad Selenium (OD-2):** Actualizar la descripción y el contenido del skill de accesibilidad Selenium a **WCAG 2.2 AA**.
9. **Índice del Repositorio (`SKILLS-INDEX.md`):** **Omitir.** No se creará `SKILLS-INDEX.md`.
10. **Linter Automatizado:** Incluir el script de auditoría automatizada (`scripts/lint-skills.mjs`) para prevención de errores sintácticos y estructurales.

---

## 2. Plan de Implementación Priorizado por Fases

### Fase 0: Corrección de Documentación Central, Defectos y Java 21+ Baseline [P0]
- **Task 0.1:** Actualizar `AGENTS.md` para corregir la regla de frontmatter de `name: skill-name`.
- **Task 0.2:** Actualizar `skills/qa-test-planner/SKILL.md` eliminando la referencia a `templates/regression-suite.md` y corrigiendo la ruta en el diagrama (L106).
- **Task 0.3:** Actualizar `skills/webapp-selenium-testing/SKILL.md` eliminando `WebDriverManager` y remplazando `gradle test` por `mvn test`.
- **Task 0.4:** Actualizar `agents/selenium-test-specialist.agent.md` elevando el prerrequisito de Java 11 a Java 21+.
- **Task 0.5:** Actualizar `skills/api-testing/SKILL.md` removiendo el acoplamiento directo con `api-tester-specialist`.

### Fase 1: Estandarización de Anatomía de Skills y WCAG 2.2 [P1]
- **Task 1.1:** Actualizar descripciones de todos los `SKILL.md` para corregir la sub-activación (eliminar "only triggered when called by name").
- **Task 1.2:** Agregar sección `## Red Flags` en los 7 skills faltantes.
- **Task 1.3:** Agregar exclusiones negativas ("DO NOT USE FOR...") en `## When to Use`.
- **Task 1.4:** Normalizar sección `## Verification` con listas de comprobación `- [ ]`.
- **Task 1.5:** Actualizar `accessibility-selenium-testing` a WCAG 2.2 AA.

### Fase 2: Archivos de Referencia, Progresividad y Sincronización Local [P2]
- **Task 2.1:** Refactorizar/dividir o agregar TOC a los 22 archivos de referencias mayores a 300 líneas.
- **Task 2.2:** Renombrar archivos `snake_case` a `kebab-case` (`locator_strategies.md` -> `locator-strategies.md`, etc.) y actualizar hipervínculos internos.
- **Task 2.3:** Sincronizar copias locales de referencias manteniendo particularidades de cada stack.
- **Task 2.4:** Agregar cabecera con *Back-link* en la parte superior de los 55 archivos en `references/`.

### Fase 3: Scripting de Auditoría y Pipeline CI [P3]
- **Task 3.1:** Crear `scripts/lint-skills.mjs`.
- **Task 3.2:** Crear `.github/workflows/lint.yml`.

---

## 3. Plan de Verificación

### Pruebas Automatizadas
- Ejecutar `node scripts/lint-skills.mjs` y verificar 0 errores/warnings.

### Verificación Manual
- Validar enlaces Markdown entre `SKILL.md` y `references/*.md` tras el renombrado.
- Probar la carga progresiva simulando consultas en herramientas de IA.
