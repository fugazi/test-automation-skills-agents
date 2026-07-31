# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
