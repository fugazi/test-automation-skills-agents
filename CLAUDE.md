# CLAUDE.md

AI Agents & Skills repository for **test automation** (Playwright/TS, Selenium/Java, API, a11y, manual QA, CI/CD). **Tool-agnostic**, consumed by multiple frontier models (Claude 5, GPT-Sol, GLM-5.2, and others). Full standards live in [AGENTS.md](./AGENTS.md); authoring guides in [docs/](./docs/).

## Gotchas (non-inferable rules)

- **No pinned models.** Agents and skills MUST NOT set a `model` in frontmatter — the tool harness selects the model.
- **Skills are agent-agnostic.** Skills provide domain expertise only; they never reference specific agents. The harness decides activation.
- **Lean instructions, deep skills.** Instructions (activated by their `description`) stay short (30–60 lines) with non-negotiable rules only. Deep content belongs in skills, loaded progressively to avoid context tax.
- **Dual-stack discipline.** Never mix TypeScript and Java in the same code block; keep Playwright and Selenium content clearly separated.
- **Test Constitution.** The QA Orchestrator (`agents/qa-orchestrator.agent.md`) defines the central MUST DO / WON'T DO rules; delegated agents inherit the subset relevant to their domain.

## Where things live

- **Standards & formatting** → [AGENTS.md](./AGENTS.md)
- **Author a skill / agent** → [docs/skill-anatomy.md](./docs/skill-anatomy.md), [docs/references/authoring-agents.md](./docs/references/authoring-agents.md), [docs/references/authoring-skills.md](./docs/references/authoring-skills.md)
- **Domain depth** → the matching skill in `skills/` (loaded on-demand)
- **Anti-patterns** → [references/testing-anti-patterns.md](./references/testing-anti-patterns.md)
