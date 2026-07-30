# Implementation Plan v2 — Context Engineering Audit

> **Historical baseline (pre-v3):** This completed plan reflects the 11-skill catalog at the time of its audit. For the v3 consolidation and migration map, see [implementation-plan-skills.md](./implementation-plan-skills.md).

**Repo:** `fugazi/test-automation-skills-agents`
**Branch:** `chore/context-engineering-optimization`
**Fecha:** 2026-07-25
**Autor:** Conito 🍦 (análisis basado en Context Engineering, Anthropic Claude 5)
**Sign-off:** Douglas Fugazi (2026-07-25) — CE-OD-1..4 aprobadas
**Estado:** ✅ Implementación completada (4 commits)
**Relación con v1:** Extiende el `implementation-plan.md` (v2, 334 líneas) con una auditoría desde los 6 paradigmas de Context Engineering. No reemplaza el plan v1 — lo complementa.

---

## §1 — Propósito

El plan v1 es una auditoría estructural sólida (hallazgos F1–F7, defectos D1–D13, 4 decisiones abiertas OD-1..4). Pero opera bajo el paradigma **old-school**: agregar secciones requeridas, expandir compliance, meter más estructura.

Context Engineering (CE) —basado en el artículo de Anthropic sobre Claude 5— demostró que **recortar 80% del system prompt no produjo pérdida medible en evals**. Los modelos modernos no necesitan micro-management; necesitan entornos mínimos pero ricos.

Este documento cruza el plan v1 contra CE y produce hallazgos nuevos (CE-F1..CE-F10), decisiones abiertas (CE-OD-1..4) y fases de trabajo integradas.

**Tensión central:** El plan v1 AGREGA estructura (Red Flags ×9, NOT-for ×10, back-links ×55). CE propone QUITAR carga frontal. La resolución no es "CE siempre gana" — es caso por caso con criterio de valor informacional.

---

## §2 — Metodología

### Marco: 6 paradigmas de Context Engineering

| # | Paradigma viejo | Paradigma nuevo (CE) |
|---|---|---|
| P1 | Reglas estrictas (NEVER/ALWAYS) | Juicio del modelo |
| P2 | Ejemplos extensos | Interfaces claras |
| P3 | Todo al frente (front-loading) | Progressive disclosure |
| P4 | Repetición para énfasis | Una sola fuente de verdad |
| P5 | Memoria manual (checklists) | Auto-memoria contextual |
| P6 | Texto plano describiendo código | Referencias ricas |

### Proceso

3 subagentes paralelos auditaron los 11 skills + 2 estándares del repo. Cada subagente leyó los archivos completos con evidencia `archivo:línea`. Reportes disponibles en:

- `.openclaw/tmp/ce-audit-playwright.md` — 18 hallazgos (CE-PW-1..18)
- `.openclaw/tmp/ce-audit-a11y-sel.md` — 24 hallazgos (CE-AS-1..24)
- `.openclaw/tmp/ce-audit-qa-standards.md` — 16+8 hallazgos (CE-QA + CE-STD)

Métricas verificadas independientemente:

| Métrica | Valor |
|---|---|
| SKILL.md totales | 3.371 líneas → **2.612 líneas (−22.5%)** |
| Código inline total | 931 líneas |
| Common Rationalizations | **143 líneas en 9 skills → ELIMINADAS** |
| `<details>` ilusorios (qa-test-planner) | 76 líneas → **movidos a references/** |
| skill-anatomy.md | 839 → **394 líneas (−53%)** |
| Verification Checklist del estándar | 44 → **15 ítems (−66%)** |

---

## §3 — Hallazgos CE

### CE-F1: Common Rationalizations — boilerplate anti-CE impuesto por el estándar ⭐

**Paradigma:** P1 (reglas estrictas → juicio)
**Severidad:** 🔴 Alta
**Evidencia:** 143 líneas en 9 skills (15-21 c/u). Tablas "Rationalization vs Reality" que anticipan excusas del modelo.

El estándar `docs/skill-anatomy.md` L177 **requiere** esta sección como una de las "6 Core Sections". Esto explica por qué aparece en 9 skills: es compliance, no decisión editorial.

Anthropic eliminó exactamente este patrón de Claude Code (anticipar excusas = micro-management) sin pérdida en evals.

**Excepción:** `qa-manual-istqb` tiene 6 entradas ISTQB-specific con valor de dominio real. `grill-me-qa` fusiona Anti-Patterns + Red Flags en una sola sección — el modelo correcto.

**Acción:** Eliminar de los 9 skills. Si 1-2 entradas tienen valor de dominio genuino, convertirlas en principio afirmativo de 1 línea. Actualizar estándar: de "requerida" a "opcional — solo si documenta un fallo real observado en producción".

---

### CE-F2: El estándar skill-anatomy.md es 60% paradigma viejo

**Paradigma:** P1/P4/P5
**Severidad:** 🔴 Alta
**Evidencia:**

- 839 líneas predican progressive disclosure pero imponen compliance estructural
- 6 secciones requeridas + 4 de facto → cada skill carga ~9-10 secciones obligatorias
- Verification Checklist de **44 ítems** (L688-712) — anti-CE puro (items triviales: indentación, quotes, links)
- `<details>` promocionado como ahorro de tokens (L315) — **FALSO**: los tokens siguen en contexto
- Contradicciones: double vs single quotes (L359 vs L366), snake_case vs kebab-case (L260 vs L459), "keep under 500 lines" siendo 839

**Acción:** Reducir a ~400 líneas aplicando su propio progressive disclosure. Secciones requeridas: 6→3-4. Checklist: 44→15 ítems. Mover ejemplo completo (Section 16) a `references/`.

---

### CE-F3: Repetición intra-skill — múltiples fuentes de verdad

**Paradigma:** P4
**Severidad:** 🔴 Alta
**Evidencia:**

| Skill | Problema | Líneas |
|---|---|---|
| qa-test-planner | 2 verificaciones + 3 secciones calidad + proceso dual | ~120 (25%) |
| webapp-playwright | Triple cobertura MCP (Tools Ref + Quick Cmds + Workflows) | ~51 |
| accessibility-selenium | Quick Ref duplica Code Patterns + Core Capabilities | ~50 |
| webapp-selenium | Quick Reference duplica Core Patterns | ~14 |

**Acción:** Una sola fuente de verdad por concepto. Fusionar o eliminar duplicados.

---

### CE-F4: Carga frontal diferible — catálogos y API references inline

**Paradigma:** P3
**Severidad:** 🟡 Media-Alta
**Evidencia:**

| Skill | Contenido diferible | Líneas |
|---|---|---|
| accessibility-selenium | 3 tablas API + JUnit 5 class + WCAG levels | ~112 |
| webapp-playwright | MCP Tools Reference (3 tablas) | ~29 |
| playwright-regression | Tier Model + Tag Taxonomy + CLI Ref | ~48 |
| a11y-playwright | Axe-Core Tags Reference | ~28 |
| playwright-cli | Windows escaping + installation + snapshot | ~30 |

**Acción:** Mover a `references/`. Dejar resumen de 1-5 líneas en el body.

---

### CE-F5: Verification checklists — tensión pro/anti-CE

**Paradigma:** P5
**Severidad:** 🟡 Media
**Evidencia:** Los 3 subagentes divergieron:
- Playwright: recomienda eliminar (−44L, "inferibles")
- A11y/Sel: los evalúa como PRO-CE ("guías accionables, no compliance")
- QA/Estándar: matiz — depende del contenido

**Caso concreto:** webapp-selenium Verification (L258-271) tiene 3 defectos de contenido (@FindBy contradice body L44, WebDriverManager contradice Selenium Manager, gradle en skill Maven). Un checklist defectuoso es peor que ningún checklist.

**Acción:** NO eliminar a ciegas. Compactar a 3-5 items no-inferibles y específicos del dominio. Eliminar triviales ("tests pasan", "sin errores de sintaxis").

---

### CE-F6: Reglas estrictas inferibles — webapp-playwright 9 guidelines

**Paradigma:** P1
**Severidad:** 🟡 Media
**Evidencia:** Análisis regla por regla de L103-111:

| # | Regla | Veredicto CE |
|---|---|---|
| 1 | Always verify app running | Inferible — eliminar |
| 2 | Use explicit waits | Default de Playwright — eliminar |
| 3 | Capture screenshots | En troubleshooting — eliminar |
| 4 | Clean up resources | Runtime lo hace — eliminar |
| 5 | Handle timeouts | Vago, sin valores — eliminar |
| 6 | Test incrementally | Micro-management — eliminar |
| 7 | Use selectors wisely | Duplicado en Locator Strategy — eliminar |
| 8 | Only navigate to your own app | **SEGURIDAD — mantener** |
| 9 | Security Considerations (4 reglas) | **No inferibles — mantener** |

**Acción:** De 9 reglas a 2-3 (solo seguridad). ~7 líneas eliminadas.

---

### CE-F7: Contenido meta/prosa redundante

**Paradigma:** P6
**Severidad:** 🟡 Media
**Evidencia:**
- webapp-playwright L23-33: 11 líneas explicando qué hace (redundante con description)
- accessibility-selenium: "Your Role" (6L meta-instrucción), "Core Capabilities" (24L) que repite Code Patterns

**Acción:** Eliminar — la description ya hace ese trabajo.

---

### CE-F8: `<details>` como falso progressive disclosure

**Paradigma:** P3
**Severidad:** 🟡 Media
**Evidencia:** qa-test-planner: 3 bloques `<details>`, 76 líneas. El estándar L315 lo promueve como ahorro de tokens. **Los tokens dentro de `<details>` SÍ se procesan** — el colapso es visual, no de contexto.

**Acción:** Mover contenido a `references/`. Documentar en el estándar que `<details>` es cosmético, no ahorro de tokens.

---

### CE-F9: Common Mistakes inferibles en AGENTS.md

**Paradigma:** P5
**Severidad:** 🟢 Baja
**Evidencia:** L117-125: missing description, YAML inválido, paths absolutos, credenciales hardcodeadas — todo inferible por modelo moderno. 9 líneas.

**Acción:** Eliminar o reducir a 1-2 items repo-específicos.

---

### CE-F10: playwright-cli — caso justificado de código inline

**Paradigma:** P2 (excepción)
**Severidad:** 🟢 Info
**Evidencia:** 67% código (285L/420L), 27 bloques. Pero los comandos SON la interfaz — es una CLI reference legítima, no "enseñar patrones".

**Acción:** Mantener estructura. Solo extraer periféricos (Windows, installation, snapshot detail) a `references/` (~30L).

---

### Lo que está BIEN según CE (modelo a seguir)

| Skill | Grade | Por qué |
|---|---|---|
| grill-me-qa | **A** | Progressive disclosure real, sin repetición, fusión Anti-Patterns+Red Flags, Question Budget |
| api-testing | **A-** | 131 líneas, principios densos, máxima delegación |
| playwright-cli | **A-** | Código como interfaz justificado |
| qa-manual-istqb | **B+** | Bien externalizado, sin duplicación |
| playwright-e2e | **B** | Buen balance, necesita poda |
| playwright-regression | **B** | Compacto pero 52% diferible |
| a11y-playwright | **B-** | Sólido, Tags Ref diferible |
| webapp-selenium | **B-** | Quick Ref duplicado, resto OK |
| qa-test-planner | **C** | 25% redundante, 17 H2 |
| webapp-playwright | **C** | 9 reglas P1, triple duplicación MCP |
| accessibility-selenium | **C** | 42% diferible, el más inflado |

---

## §4 — Cross-Analysis: Plan v1 × Context Engineering

### ADOPTAR del v1 (compatible con CE)

| Elemento v1 | Razón |
|---|---|
| D1–D13 (correctness fixes) | Defectos reales, no paradigma |
| T4.1 progressive disclosure | CE puro (split references >300L, TOCs) |
| T4.4 token budget descriptions (≤600/≤450) | Economía de contexto |
| T0.3 evals baseline | Medir antes de optimizar |
| OD-1c inline routing-critical (10%) | Front-loading mínimo |
| Eliminación persona-framing boilerplate | Menos prosa = menos tokens |

### MODIFICAR del v1 (tensión con CE)

| Elemento v1 | Postura CE | Resolución |
|---|---|---|
| F1: Red Flags ×9 | Solo si contenido genuino no-inferible | Condicionar, no obligar. grill-me-qa fusiona = modelo correcto |
| F2: NOT-for ×10 | 1-2 bullets en skills con riesgo real de misrouting | Solo los 3 Playwright + 2 planners |
| F4: back-links ×55 | La ruta ya orienta en references cortos | Solo en references >100 líneas |
| Verification checklists | Compactar, no expandir | 3-5 items no-inferibles máximo |

### RECHAZAR del v1

Nada se rechaza completamente. El v1 es sólido en correctness. El desacuerdo es de énfasis: el v1 mira la estructura, CE mira la economía de contexto.

### NUEVO en v2 (lo que v1 no ve)

CE-F1 (Rationalizations 143L), CE-F2 (reforma estándar 839→400), CE-F3 (deduplicación intra-skill ~200L), CE-F8 (`<details>` ilusorio), CE-F9 (AGENTS.md common mistakes).

---

## §5 — Decisiones CE (Aprobadas ✅)

### CE-OD-1: Common Rationalizations — ✅ APROBADA Opción A

> **Decisión Douglas (2026-07-25):** Eliminar de 9 skills; contenido de dominio genuino → 1 línea de principio afirmativo.

| Opción | Descripción | Impacto | Estado |
|---|---|---|---|
| **A ✓** | Eliminar de 9 skills; dominio genuino → 1 línea principio afirmativo | −143 líneas | **Aprobada** |
| B | Condensar a 2-3 entradas por skill | −80 líneas | ~ |
| C | Mantener status quo | 0 | ~ |

**Riesgo mitigado:** Las 2-3 racionalizaciones QA-specific con valor de dominio (ej. ISTQB) se preservan como principios afirmativos.

### CE-OD-2: Verification checklists — ✅ APROBADA Opción B

> **Decisión Douglas (2026-07-25):** Compactar a 3-5 items no-inferibles/específicos del dominio.

| Opción | Descripción | Impacto | Estado |
|---|---|---|---|
| A | Eliminar todos | −44L, riesgo de omitir checks de dominio | ~ |
| **B ✓** | Compactar a 3-5 items no-inferibles/específicos | −30L neto | **Aprobada** |
| C | Mantener | 0 | ~ |

### CE-OD-3: Reforma skill-anatomy.md — ✅ APROBADA Opción A

> **Decisión Douglas (2026-07-25):** Reforma completa — 839→~400, secciones 6→4, checklist 44→15, corregir contradicciones.

| Opción | Descripción | Impacto | Estado |
|---|---|---|---|
| **A ✓** | 839→~400, secciones 6→4, checklist 44→15, corregir contradicciones | Estándar CE-aligned | **Aprobada** |
| B | Solo corregir contradicciones (quotes, snake_case, 500-line) | Mínimo | ~ |
| C | No tocar estándar, solo skills | El lint/CI reintroducirá patrones | ~ |

**Nota:** Arreglar skills sin arreglar el estándar = trabajo en vano. El estándar es la FUENTE del boilerplate.

### CE-OD-4: ¿Fases CE integradas o branch separado? — ✅ APROBADA Opción A

> **Decisión Douglas (2026-07-25):** Integrar como Phase 1.5 y 2.5 en branch existente.

| Opción | Descripción | Estado |
|---|---|---|
| **A ✓** | Integrar como Phase 1.5 y 2.5 en branch existente | **Aprobada** |
| B | Branch separado `chore/context-engineering` | ~ |

**Nota:** Los cambios tocan los mismos archivos que fases 1-2 del v1. Branches separados = conflictos masivos.

---

## §6 — Plan de Trabajo Integrado

Las fases CE se insertan entre las fases existentes del plan v1.

### Phase 0.5 (nueva) — CE Baseline

| Tarea | Descripción | Output |
|---|---|---|
| T0.5.1 | ~~Sign-off CE-OD-1..4~~ | ✅ Aprobadas (2026-07-25) |
| T0.5.2 | Baseline de líneas/tokens por skill | ✅ Medido |
| T0.5.3 | Evals baseline T0.3 | 📋 Aplazado por decisión de Douglas — requiere diseñar ~54 queries + framework de evaluación |

### Phase 1.5 (nueva, después de D1–D13) — Eliminación de carga anti-CE

| Tarea | Descripción | Líneas |
|---|---|---|
| T1.5.1 | ✅ Eliminar Common Rationalizations (CE-OD-1: Opción A) | −110 líneas |
| T1.5.2 | ✅ Eliminar prosa meta redundante (CE-F7) | −41 líneas |
| T1.5.3 | ✅ Compactar Verification checklists (CE-OD-2: Opción B) | −30 líneas |
| T1.5.4 | ✅ Eliminar reglas inferibles en webapp-playwright (CE-F6) | −7 líneas |
| T1.5.5 | ✅ Corregir defectos webapp-selenium (@FindBy, WebDriverManager) | — |
| T1.5.6 | ✅ Acortar description qa-manual-istqb (534→309 chars) | — |

**Criterio de aceptación:** `grep -r "Common Rationalizations" skills/` devuelve 0 (o excepciones firmadas).

### Phase 2.5 (nueva, junto a boundary design) — Deduplicación + Progressive Disclosure

| Tarea | Descripción | Líneas |
|---|---|---|
| T2.5.1 | ✅ qa-test-planner: 17→12 H2; fusionar verificación dual, calidad triple, proceso dual, `<details>` → references/ | −203 líneas |
| T2.5.2 | ✅ webapp-playwright: unificar triple cobertura MCP, eliminar Core Cap, compactar Troubleshooting | −65 líneas |
| T2.5.3 | ✅ accessibility-selenium: Quick Ref, API tables, Code Patterns, WCAG table → references/ | −156 líneas |
| T2.5.4 | ✅ webapp-selenium: Quick Reference → eliminar | −14 líneas |
| T2.5.5 | ✅ Catálogos inline → references/ (axe-tags, regression-catalogs, axe-api) | −96 líneas |
| T2.5.6 | ✅ playwright-cli: Windows & escaping → references/ | −9 líneas |

### Phase 5.5 (nueva, en remediation) — Reforma del estándar

| Tarea | Descripción | Output |
|---|---|---|
| T5.5.1 | ✅ skill-anatomy.md 839→394 (CE-OD-3: Opción A), checklist 44→15, secciones 6→3 | Estándar CE-aligned |
| T5.5.2 | ✅ AGENTS.md: Common Mistakes inferibles eliminados | −10 líneas |
| T5.5.3 | ✅ Estándar actualizado: Rationalizations de requerida → no recomendada | ✅ |
| T5.5.4 | ✅ `<details>` documentado como cosmético en el estándar | ✅ |
| T5.5.5 | ✅ Section Details, Writing Principles, Cross-Skill Refs → references/ | −200 líneas del estándar |

---

## §7 — Métricas y Presupuesto de Tokens

### Reducción real por grupo (medición post-implementación)

| Grupo | Antes | Después | Reducción |
|---|---|---|---|
| Playwright (4 skills) | 1.236 | 1.005 | −19% |
| A11y/Selenium/API (4 skills) | 1.188 | 936 | −21% |
| QA (3 skills) | 947 | 671 | −29% |
| **Total SKILL.md** | **3.371** | **2.612** | **−22.5%** |
| skill-anatomy.md | 839 | 394 | −53% |
| AGENTS.md | 224 | 214 | −4% |

### Ahorro de tokens real

A ~10 tokens por línea: **~7.590 tokens menos** en la carga completa de skills + estándar.

### Commits en `chore/context-engineering-optimization`

```
6c4f2a1 — fix: compact webapp-pw MCP tables to inline reference
ed62a63 — refactor: complete yellow items — slim standard + skills under 300 lines
23ebe61 — fix: complete remaining CE tasks (5 red items)
c316f28 — feat: apply Context Engineering optimization (Phase 1.5, 2.5, 5.5)
```

### Archivos de references creados (12)

| Archivo | Origen |
|---|---|
| `docs/references/example-skill-template.md` | Ejemplo completo de skill (skill-anatomy.md Section 16) |
| `docs/references/section-details-guide.md` | Section Details, Supporting Files, Instructions Layer |
| `docs/references/writing-principles.md` | Writing Principles |
| `skills/qa-test-planner/references/workflow-examples.md` | Ejemplos `<details>` |
| `skills/a11y-playwright-testing/references/axe-tags-reference.md` | Axe-Core Tags Reference |
| `skills/accessibility-selenium-testing/references/axe-api-reference.md` | AxeBuilder API tables |
| `skills/accessibility-selenium-testing/references/code-patterns.md` | Code Patterns + Running Tests |
| `skills/webapp-playwright-testing/references/usage-examples.md` | Usage Examples |
| `skills/playwright-regression-testing/references/regression-catalogs.md` | Tier Model, Tag Taxonomy |
| `skills/playwright-cli/references/windows-notes.md` | Windows & escaping |

---

---

## §8 — Matriz CE por Skill

| Skill | Grade | % Diferible | Top issue | Reducción est. |
|---|---|---|---|---|
| grill-me-qa | A | 14% | Trigger Phrases podría ir a references/ | −32L |
| api-testing | A- | 24% | Common Rationalizations (14L) | −31L |
| playwright-cli | A- | 14% | Periféricos (Windows, install) | −60L |
| qa-manual-istqb | B+ | 26% | Description 534 chars, Quick Start compactable | −63L |
| playwright-e2e | B | 38% | Rationalizations + checklist + config | −112L |
| playwright-regression | B | 52% | 4 tablas de catálogo diferibles | −59L |
| a11y-playwright | B- | 28% | Tags Ref + Rationalizations | −87L |
| webapp-selenium | B- | 26% | Quick Ref duplicado + Rationalizations | −71L |
| qa-test-planner | C | 42% | 25% redundante, 17 H2, `<details>` ilusorio | −202L |
| webapp-playwright | C | 41% | 9 reglas P1, triple MCP, prosa meta | −170L |
| accessibility-selenium | C | 42% | API tables inline, JUnit class, Quick Ref | −199L |

---

## §9 — Definición de Terminado (DoD)

- [x] 0 secciones "Common Rationalizations" (`grep -r "Common Rationalizations" skills/` = 0)
- [x] 0 secciones duplicadas (un concepto = una fuente)
- [x] skill-anatomy.md ≤ 450 líneas (394) con checklist ≤ 15 ítems (15)
- [x] Cada SKILL.md ≤ 300 líneas (excepción: playwright-cli como CLI reference, 410)
- [ ] Evals de routing no regresionan vs baseline (T0.3 del v1) — 📋 **Aplazado por decisión de Douglas (2026-07-25)**
- [x] 0 `<details>` en skills (movidos a references/); cosmético documentado en estándar
- [x] Descriptions ≤ 450 chars con WHAT+WHEN+KEYWORDS (qa-manual-istqb corregido: 534→309)
- [x] Estándar actualizado: Rationalizations no recomendada, secciones requeridas 6→3

---

## §10 — Apéndice: Checklist CE para Nuevos Skills

Antes de aprobar un skill nuevo, verificar:

1. **¿Cada sección cambia lo que el modelo hace?** Si no, eliminarla.
2. **¿Hay otra sección que diga lo mismo?** Una sola fuente de verdad.
3. **¿El contenido es diferible?** Mover a `references/`, dejar 1-5 líneas de resumen.
4. **¿La description es ≤450 chars con WHAT+WHEN+KEYWORDS?**
5. **¿Hay reglas NEVER/ALWAYS que el modelo inferiría?** Eliminarlas.
6. **¿Hay "Common Rationalizations"?** No agregar. Si hay fallo real documentado, 1 línea de principio afirmativo.
7. **¿Hay `<details>`?** Los tokens siguen en contexto — es cosmético, no ahorro.
8. **¿Checklist de verification > 5 items?** Compactar a los no-inferibles.
9. **¿Código inline > 15 líneas que no sea una CLI reference?** Extraer a `references/` o `templates/`.
10. **¿El skill completo ≤ 300 líneas?** (Excepción: CLI references justificadas)

---

*Fin del documento. Reportes de auditoría completos en `.openclaw/tmp/ce-audit-*.md`.*
