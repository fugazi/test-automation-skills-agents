# AGENTS.md

AI Agents & Skills repository for **test automation**. Content is **tool-agnostic** — usable with GitHub Copilot, Claude, Cursor, OpenCode, Windsurf, and similar AI assistants, and consumed by multiple frontier models (Claude 5, GPT-Sol, GLM-5.2, and others). File formats and folder conventions follow widely-shared conventions; any tool-specific adapters (e.g., `.github/`, `.claude-plugin/`) are optional integration layers, not the source of truth.

This file holds only the rules you **cannot infer** from the filesystem. Authoring depth lives in the canonical guides — don't duplicate it here.

## Layout

```text
agents/           # *.agent.md  — agent definitions
skills/           # */SKILL.md  — testing skills (with references/ scripts/ templates/)
instructions/     # *.instructions.md — lean, description-activated coding essentials
docs/             # setup guides + authoring standards (references/ enhancements/ archive/)
references/       # shared reference material
scripts/          # lint-skills.mjs — structural linter (the only validation)
.claude-plugin/   # Claude Code plugin/marketplace metadata (optional adapter)
CHANGELOG.md      # release history (Keep a Changelog + SemVer)
```

## Lint (the only validation)

No build system. Structural lint enforces the skill-anatomy standard — **0 errors required**:

```bash
node scripts/lint-skills.mjs        # exit code 0 = pass
```

Checks (errors): frontmatter with `name` + `description`, `name` matches folder, description ≤ 1024 chars, `SKILL.md` ≤ 500 lines, intra-skill link resolution, kebab-case filenames, Selenium rules (no WebDriverManager anywhere; Maven-only, no Gradle). Warnings (allowed): references > 300 lines, missing back-link headers. Runs in CI on PRs touching `skills/`, `agents/`, or `instructions/`.

## Non-inferable rules

- **No pinned models.** Do not set `model` in frontmatter — the harness selects it.
- **Skills are agent-agnostic.** Skills never reference specific agents.
- **Single-tag taxonomy.** Exactly one tag per test — `@smoke`, `@sanity`, `@regression`, `@e2e`, `@api`, `@destructive` — never on `test.describe()`/class level, never combined; `@destructive` (mutates shared/global state) is excluded from parallel runs and run sequentially.
- **YAML quoting.** `description` values MUST use single quotes (`description: '...'`). The `name` field follows Agent Skills conventions and may be unquoted (`name: skill-name`).
- **Tool aliases** in frontmatter use lowercase: `read`, `edit`, `search`, `execute`, `agent`, `web`. MCP servers: `playwright/*`, `github/*`, `server-name/tool-name`.
- **Dynamic values** in prompts use `${variableName}`.
- **Lean instructions, deep skills.** Instructions stay short (30–60 lines) with non-negotiable rules only; all depth lives in the matching skill, loaded progressively.
- **Test Constitution.** The QA Orchestrator (`agents/qa-orchestrator.agent.md`) owns the canonical MUST DO / WON'T DO set; specialist agents carry only the domain-relevant subset — never duplicate the full set. Only the orchestrator sets `infer: false`.

## Where authoring detail lives

- **Authoring a skill** → [docs/skill-anatomy.md](./docs/skill-anatomy.md) (required sections, progressive disclosure, resource types, naming)
- **Authoring an agent** → [docs/references/authoring-agents.md](./docs/references/authoring-agents.md) (frontmatter fields, handoffs, orchestration)
- **Frontmatter fields & formatting** → [docs/references/authoring-skills.md](./docs/references/authoring-skills.md)
- **Setup / quick start** → [docs/getting-started.md](./docs/getting-started.md)
- **Anti-patterns** → [references/testing-anti-patterns.md](./references/testing-anti-patterns.md)
