# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A **documentation/knowledge catalog** (no build system, no package.json) of AI agents, skills, and instructions for QA automation — Playwright/TS, Selenium/Java, API, a11y, ISTQB, CI/CD. **Tool-agnostic** by design (Claude Code, Copilot, Cursor, Windsurf, …) and consumed by multiple frontier models (Claude 5, GPT-Sol, GLM-5.2, and others). Also published as a Claude Code plugin via `.claude-plugin/`.

Current catalog: 7 agents (`agents/`), 9 skills (`skills/`), 3 instructions (`instructions/`).

## Commands

The only validation is a dependency-free structural linter — **0 errors required** (warnings allowed):

```bash
node scripts/lint-skills.mjs
```

Runs in CI ([lint.yml](.github/workflows/lint.yml)) on PRs touching `skills/`, `agents/`, or `instructions/`. It enforces the skill-anatomy standard: frontmatter present, `name` matches folder, `SKILL.md` ≤ 500 lines, description ≤ 1024 chars, intra-skill links resolve, kebab-case filenames, Selenium rules (S10). Run it after any content change — there is nothing else to build or test.

## Architecture

Three content types, all activated the same portable way — **the harness picks them by their `description` frontmatter** (there is no `applyTo` or scoping field):

- **`agents/*.agent.md`** — persona + slim Constitution (MUST DO / WON'T DO) + workflow. The QA Orchestrator (`agents/qa-orchestrator.agent.md`) owns the canonical Test Constitution and routes work to specialists via `handoffs`; each specialist inherits only the domain-relevant subset — never duplicate the full set. Only the orchestrator sets `infer: false`.
- **`skills/<name>/SKILL.md`** — deep domain playbooks. Progressive disclosure: Level 1 = `description` only, Level 2 = SKILL.md body, Level 3 = `references/`, `scripts/`, `templates/` loaded on demand.
- **`instructions/*.instructions.md`** — lean (30–60 lines) non-negotiable coding essentials; all depth lives in the matching skill.

Deeper standards: [AGENTS.md](./AGENTS.md) (house rules, lint detail) · [docs/skill-anatomy.md](./docs/skill-anatomy.md) + [docs/references/](./docs/references/) (authoring guides) · [references/testing-anti-patterns.md](./references/testing-anti-patterns.md) (anti-patterns).

## Gotchas (non-inferable rules)

- **No pinned models.** Agents and skills MUST NOT set a `model` in frontmatter — the tool harness selects the model.
- **Skills are agent-agnostic.** Skills provide domain expertise only; they never reference specific agents. The harness decides activation.
- **Single-tag taxonomy.** Exactly one tag per test — `@smoke`, `@sanity`, `@regression`, `@e2e`, `@api`, or `@destructive` — never on `test.describe()`/class level, never combined. `@destructive` (mutates shared/global state) is excluded from parallel runs and run sequentially.
- **YAML quoting.** `description` values use single quotes (`description: '...'`); `name` may be unquoted.
- **Selenium = Maven + Selenium Manager.** No WebDriverManager anywhere; no Gradle in Selenium content. Enforced by linter rule S10.
- **Dual-stack discipline.** Never mix TypeScript and Java in the same code block; keep Playwright and Selenium content clearly separated.
- **Lean instructions, deep skills.** Instructions stay short (30–60 lines) with non-negotiable rules only. Deep content belongs in skills, loaded progressively to avoid context tax.
