# AGENTS.md

AI Agents & Skills repository for **test automation**. Content is **tool-agnostic** — usable with GitHub Copilot, Claude, Cursor, OpenCode, Windsurf, and similar AI assistants, and consumed by multiple frontier models (Claude 5, GPT-Sol, GLM-5.2, and others). File formats and folder conventions follow widely-shared conventions; any tool-specific adapters (e.g., `.github/`, `.claude-plugin/`) are optional integration layers, not the source of truth.

This file holds only the rules you **cannot infer** from the filesystem. Authoring depth lives in the canonical guides — don't duplicate it here.

## Layout

```
agents/           # *.agent.md  — agent definitions
skills/           # */SKILL.md  — testing skills (with references/ scripts/ templates/)
instructions/     # *.instructions.md — lean, applyTo-scoped coding essentials
docs/             # setup guides + authoring standards
references/       # shared reference material
```

## Lint (the only validation)

No build system. Structural lint enforces the skill-anatomy standard — **0 errors required**:

```bash
node scripts/lint-skills.mjs        # exit code 0 = pass
```

Checks: frontmatter present, `name` matches folder, `SKILL.md` ≤ 500 lines, back-link headers on references, intra-skill link resolution, kebab-case naming, Selenium (Maven-only / Selenium Manager) rules. Runs in CI on PRs touching `skills/`, `agents/`, or `instructions/`.

## Non-inferable rules

- **No pinned models.** Do not set `model` in frontmatter — the harness selects it.
- **Skills are agent-agnostic.** Skills never reference specific agents.
- **YAML quoting.** `description` values MUST use single quotes (`description: '...'`). The `name` field follows Agent Skills conventions and may be unquoted (`name: skill-name`).
- **Tool aliases** in frontmatter use lowercase: `read`, `edit`, `search`, `execute`, `agent`, `web`. MCP servers: `playwright/*`, `github/*`, `server-name/tool-name`.
- **Dynamic values** in prompts use `${variableName}`.

## Where authoring detail lives

- **Authoring a skill** → [docs/skill-anatomy.md](./docs/skill-anatomy.md) (required sections, progressive disclosure, resource types, naming)
- **Authoring an agent** → [docs/references/authoring-agents.md](./docs/references/authoring-agents.md) (frontmatter fields, handoffs, orchestration)
- **Frontmatter fields & formatting** → [docs/references/authoring-skills.md](./docs/references/authoring-skills.md)
- **Setup / quick start** → [docs/getting-started.md](./docs/getting-started.md)
- **Anti-patterns** → [references/testing-anti-patterns.md](./references/testing-anti-patterns.md)
