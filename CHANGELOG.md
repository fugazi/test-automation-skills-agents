# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.4.1] - 2026-09-26

Corrects outdated sampling-parameter advice in the **`grill-me-qa`** skill, closing a Claude Code audit finding.

### Fixed

- **`grill-me-qa` references** (`ai-testing-interrogation.md`, `qa-decision-tree.md`) — replaced the "use low-temperature settings (0.0-0.3)" recommendations and rephrased the interrogation questions that assumed decode settings were the randomness lever. Current models no longer accept sampling parameters (removed, or rejected with a 400 on adaptive-thinking models); the guidance now points to structural variance control — explicit specs, schema-shaped outputs, live validation, canary, and feedback metrics.
- **Plugin version bump** `.claude-plugin/plugin.json` `4.4.0` → `4.4.1` — so Claude Code / `npx skills update` pick up the corrected skill.

---

## [4.4.0] - 2026-09-26

Aligns the **`playwright-cli`** skill with upstream `playwright-cli` v0.1.21 (Microsoft), closing the gaps found in a side-by-side comparison of the bundled skill against this repo's curated version.

### Added

- **Emulation commands** (`set-color-scheme`, `set-reduced-motion`, `set-forced-colors`, `set-contrast`, `set-media` + `clear-*`) in the `playwright-cli` SKILL.md command reference — new in upstream v0.1.21; emulate media features mid-session for dark mode, reduced motion, forced colors, contrast, and print styles.
- **WebMCP** section in the `playwright-cli` SKILL.md — page-registered tools show up in the snapshot and can be called with `webmcp-call` (experimental; page-provided input is treated as untrusted).

### Changed

- **`session-management.md`** — documents the headless idle timeout (sessions auto-close after an hour) and the `open --idle-timeout=<ms>` knob.
- **`windows-notes.md`** — adds the PowerShell `--%` escaping alternative to the `cmd.exe` `^&` note.
- **Plugin version bump** `.claude-plugin/plugin.json` `4.3.0` → `4.4.0` — so Claude Code picks up the updated skill.

---

## [4.3.0] - 2026-09-01

Aligns the **`playwright-cli`** skill with upstream `playwright-cli` v0.1.19 (Microsoft), closing the one functional gap found in a side-by-side comparison.

### Added

- **`recording-start` / `recording-stop`** to the `playwright-cli` SKILL.md command reference — these record the actions you perform in the live browser and print ready-to-paste Playwright code on stop. This was the only command pair present in upstream v0.1.19 that was missing from this repo's skill.
- **`Recording user actions as Playwright code`** section in `skills/playwright-cli/references/video-recording.md` — covers the manual-record → codegen workflow, when to use it (bootstrap a spec from a repro, share a reproduction, seed actions), and the caveat that it is an exploration/codegen aid, not a CI runner.

### Changed

- **Plugin version bump** `.claude-plugin/plugin.json` `4.2.1` → `4.3.0` — so Claude Code picks up the updated skill.

---

## [4.2.1] - 2026-08-31

Adjusts the **`qa-investigation`** skill documentation granularity to the investment level, so a low-value flake does not require the full three-file record.

### Changed

- **`qa-investigation` skill** — file scope now scales by triaged investment: **P1** (blocking) uses `plan` + `findings` + `progress`; **P2** (medium) uses `plan` + `findings`; **P3** (cosmetic flake) uses `findings` only (which serves as the plan). The `findings` file is created first for a P3. Skipped: no longer forces all three files for every case.
- **Plugin version bump** `.claude-plugin/plugin.json` `4.2.1` — so Claude Code picks up the updated skill.

---

## [4.2.0] - 2026-08-31

Adds the **`qa-investigation`** skill — a persistent, file-backed investigation journal for failing tests. It detects whether a failure is flaky (intermittent) or a deterministic bug during reproduction, then documents the evidence, the decision, and the why.

### Added

- **`qa-investigation` skill** (`skills/qa-investigation/`) — the execution layer for failure investigation. Resolves a specific test failure to its root cause; it does not validate strategy (`grill-me-qa`) nor generate QA artifacts (`qa-manual-istqb`).
  - **Unified flaky + bug:** the classification is discovered in Phase 1 (reproduction/triage), never assumed up front.
  - **Non-reproducible path:** records non-reproducible failures with partial evidence and escalation rather than forcing a label.
  - **Self-contained:** full decision tracking; no dependency on another skill being installed.
  - **Tool-agnostic:** browser/selector/CI-vs-local are illustrative, not requirements — works for web, API, mobile, embedded, and unit-test stacks.
  - **Exit criteria + file lifecycle:** defines when an investigation is done and how to close/archive generated files.
  - **Aligned to Anthropic / CE best practices:** progressive disclosure (SKILL.md 89 lines), description ≤ 450 chars, back-link headers on all reference files.
- **Plugin version bump** `.claude-plugin/plugin.json` `4.1.0` → `4.2.0`; description updated to reflect 10 reusable skills.

### Changed

- **Catalog count updated to 10 skills** across `README.md`, `CLAUDE.md`, `docs/claude-code-setup.md`, and `docs/windsurf-setup.md` (was 9).
- **README.md:** added `qa-investigation` to the skills catalog table, the skills.sh install commands, the typical-triggers list, and the `Key Features` mention.

---

## [4.1.0] - 2026-08-14

Single-tag taxonomy release — standardizes test classification across the whole library and aligns every existing tag reference with it.

### Added

- **Single-tag taxonomy** documented as a non-negotiable rule in `instructions/playwright-typescript.instructions.md` and `instructions/selenium-webdriver-java.instructions.md`: exactly one tag per test (`@smoke`, `@sanity`, `@regression`, `@e2e`, `@api`, `@destructive`), never on `test.describe()`/class level, never combined. `@destructive` is reserved for tests that mutate shared/global state — excluded from parallel runs (`--grep-invert @destructive` / `-Dgroups=destructive -DforkCount=1 -Djunit.jupiter.execution.parallel.enabled=false`) and run sequentially.

### Changed

- **Tag usage aligned repo-wide** to the single-tag taxonomy (14 files):
  - `instructions/cicd-testing.instructions.md`: tag-by-tier rule now uses `{ tag: '@smoke' }` (never in test titles) and the full 6-tag set.
  - `agents/selenium-test-specialist.agent.md`: `mvn test -Psmoke` → `mvn test -Dgroups=smoke`; checklist requires exactly one `@Tag`.
  - `skills/qa-manual-istqb/` (strategy + templates): tag annotation replaces tags-in-titles; `@full` removed from the tag conventions (not part of the taxonomy).
  - `skills/playwright-regression-testing/` (SKILL.md, strategy, selection, flaky-management, best-practices, catalogs, ci-cd-integration): combined tag arrays (`["@smoke", "@regression"]`) and tags in `describe()`/titles replaced with a single execution tag per test; key tags and CLI quick reference aligned to the 6-tag set.

---

## [4.0.0] - 2026-07-30

A major alignment release with Anthropic's *"The new rules of context engineering for Claude 5 generation models"* and *"Effective context engineering for AI agents"*, plus a repositioning to **tool-agnostic / multi-model** (Claude 5, GPT-Sol, GLM-5.2, and others).

This release is the outcome of a full architectural audit (`docs/enhancements/ce-claude5-audit.md`) and a 6-phase roadmap. It removes **~1,600 lines** of duplicated/bloated content while preserving the public skill/agent contract. **The MAJOR bump is driven by the removal of the `applyTo` frontmatter field**, which Copilot consumers may have depended on for deterministic context-scoping.

### ⚠️ Breaking changes

- **`applyTo` removed from all instructions and authoring docs.** This field is GitHub Copilot / VS Code-specific and is not recognized by other harnesses (Claude Code, Cursor, Windsurf, OpenCode). Instructions now activate by `description` matching — the same portable mechanism skills use.
  - **Migration:** If you relied on `applyTo` for context-scoping in Copilot, the instruction `description` now carries the target-file-type signal (e.g., *"Applied to .spec.ts files"*). Per-tool adapters can re-introduce scoping where a harness supports it.
- **`docs/references/section-details-guide.md` reduced to a redirect stub.** Its content was consolidated into `docs/skill-anatomy.md` as the single source of truth. Update any deep links to point at the corresponding section of `skill-anatomy.md`.
- **Four `docs/enhancements/implementation-plan-*` files moved to `docs/archive/enhancements/`.** They were completed/stale planning logs marketed as "future improvements". Paths are preserved under `archive/`.

### Context engineering (Claude 5 alignment)

- **Progressive disclosure consolidated.** The Playwright locator-priority table is now single-source (`locator-strategies-priority.md`); verbatim copies in `playwright-e2e-testing/SKILL.md` and `regression-best-practices.md` replaced with pointers.
- **Memory/workspace files slimmed** to Anthropic's "lightweight, gotchas-only" guidance: `CLAUDE.md` 105 → 18 lines, `AGENTS.md` 222 → 41 lines. Domain locator tables and orchestration patterns removed (they live in skills/docs).
- **Authoring docs de-fragmented.** Six overlapping authoring files consolidated around `docs/skill-anatomy.md` as the canonical source (frontmatter rules, progressive loading, resource types, naming each now appear exactly once).
- **Instructions made lean.** `selenium-webdriver-java.instructions.md` 607 → 32 lines, `cicd-testing.instructions.md` 222 → 29 lines. Full templates/workflows moved to the matching skills' `references/`; `playwright-typescript` (29 lines) was already the model.
- **Agents de-duplicated (conservative, multi-model).** The Test Orchestration Pattern (TOP) Constitution was repeated across 6 agents with copy-paste leakage (e.g., `api-tester-specialist` carried an XPath rule that "is irrelevant for API"). Duplicate Must/Must-Not pairs, repeated prohibitions (the `Thread.sleep` rule appeared ~5× in one file), boilerplate sections, and full tutorial code removed. Each rule now appears once per agent.
  - **Design note:** Constitutions are kept slim but **retained** (not converted to open-ended heuristics) because the repo is genuinely multi-model; models with more variable judgment benefit from explicit constraints. The anti-pattern that *was* removed — duplication and inapplicable-rule leakage — is universal.
- **`infer` convention documented.** Only `qa-orchestrator` sets `infer: false` (dispatcher, never auto-activates); specialists omit it (default `true`, auto-selectable). Now documented in `authoring-agents.md` and with an inline comment.

### Tool-agnostic / multi-model repositioning

- The repo is now explicitly declared **tool-agnostic and multi-model** (Claude 5, GPT-Sol, GLM-5.2, …) across `AGENTS.md`, `CLAUDE.md`, `README.md`, and the authoring guides. Prior "optimized for GitHub Copilot" framing removed.
- Agent frontmatter fields (`tools`, `mcp-servers`, `handoffs`, `infer`, `target`) documented as **optional adapter fields** specific to Copilot/VS Code in `authoring-agents.md` — the agent *body* (role, Constitution, workflow) is the portable part.

### Linter alignment

- `lint-skills.mjs` S4: description limit raised **600 → 1024 chars** (Anthropic's official Agent Skills limit).
- `lint-skills.mjs` S7: back-link-header check demoted **ERROR → WARNING** (cosmetic; does not change agent behavior).

### Documentation

- Added `docs/enhancements/ce-claude5-audit.md` — the full architectural review (gap analysis, adversarial review, roadmap) this release implements.
- Refreshed `README.md`, `docs/getting-started.md`, `docs/copilot-setup.md`: fixed a dead link to the archived migration plan, corrected the Instructions count (7 → 3), replaced the retired "Flaky Test Hunter" persona with "Playwright Test Healer", and aligned framing with the tool-agnostic positioning.

### Summary of size reductions

| Area | Before | After |
| --- | --- | --- |
| `CLAUDE.md` | 105 | 18 |
| `AGENTS.md` | 222 | 41 |
| `selenium-webdriver-java.instructions.md` | 607 | 32 |
| `cicd-testing.instructions.md` | 222 | 29 |
| `test-refactor-specialist.agent.md` | 606 | 272 |
| `selenium-test-specialist.agent.md` | 333 | 87 |
| `section-details-guide.md` | 247 | 5 (stub) |
| **Net across the release** | — | **−~1,600 lines** |

---

## [3.2.0] - 2026-07-30 (prior release)

Instructions cleanup v3.2 — context engineering optimization (constitution, tool cleanup, skill independence, size optimization). See git history for details.
