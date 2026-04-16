<div align="center">
  <img src="copilot-banner.jpg" width="500" alt="Test Automation AI Agents & Skills - Copilot DAWless Live Set">
</div>

# Test Automation AI Agents & Skills (Tool-Agnostic) 🚀

A practical library of **agents**, **instructions**, and **skills** designed specifically for QA Automation Engineers, focusing on production-oriented solutions.

This repository is **tool-agnostic by design**: the concepts and content can be used with GitHub Copilot, Claude, Cursor, OpenCode, Windsurf, and similar AI assistants.

---

## Key Features

This repository is designed to be **copied/embedded into real testing projects** so your AI assistant can actively assist with:

- UI, API, E2E, smoke, and regression testing
- Accessibility testing (WCAG 2.1 AA)
- Flaky test investigation and stabilization
- Test planning (ISTQB-aligned) and documentation
- Framework patterns (Playwright TypeScript, Selenium Java)

> Important: This repository is a **documentation/knowledge base**. It has **no build/lint/test** system.

## What you get

- **Agents** (in `agents/`): persona + responsibilities + boundaries for specialized AI behavior
- **Instructions** (in `instructions/`): operational rules and standards that guide work consistently
- **Skills** (in `skills/`): reusable workflows + references + scripts/templates (progressively loaded in Copilot; otherwise used as playbooks)

## Repository structure

```
agents/           # Custom agent definitions (*.agent.md)
instructions/     # Authoring & operational guidelines (*.instructions.md)
skills/           # Reusable capabilities (skills/*/SKILL.md + resources)
docs/             # Setup guides and documentation
references/       # Shared reference material (anti-patterns, patterns)
AGENTS.md         # House style, file standards, frontmatter rules
CLAUDE.md         # Additional guidance (legacy + architecture notes)
```

## Quick start (recommended workflow)

This repo is a **catalog**. Choose the integration style for your tool.

### Integration choices

- **GitHub Copilot (customizations)**: use `.github/agents`, `.github/instructions`, and `.github/skills`.
- **Claude/Cursor/OpenCode/Windsurf/etc.**: copy the same content into the tool’s repo/workspace rules system, keeping the same structure and naming so your team shares a consistent vocabulary.

### Setup guides

| Tool           | Setup Guide                                              |
| -------------- | -------------------------------------------------------- |
| Claude Code    | [docs/claude-code-setup.md](./docs/claude-code-setup.md) |
| Cursor         | [docs/cursor-setup.md](./docs/cursor-setup.md)           |
| GitHub Copilot | [docs/copilot-setup.md](./docs/copilot-setup.md)         |
| Gemini CLI     | [docs/gemini-cli-setup.md](./docs/gemini-cli-setup.md)   |
| Windsurf       | [docs/windsurf-setup.md](./docs/windsurf-setup.md)       |

### Option A — Copy into your target repository (most reliable)

1. Copy agents:
   - From: `agents/`
   - To: `.github/agents/`

2. Copy instructions:
   - From: `instructions/`
   - To: `.github/instructions/`

3. Copy skills:
   - From: `skills/<skill-name>/`
   - To: `.github/skills/<skill-name>/`

4. Commit the files to your target repo.

### Verify Copilot can see the assets

In your target repository:

1. Confirm files exist at the expected paths:
   - `.github/agents/*.agent.md`
   - `.github/instructions/*.instructions.md`
   - `.github/skills/<skill-name>/SKILL.md`

2. In VS Code, reload the window (or restart VS Code) to refresh Copilot customizations.

3. Open Copilot Chat:
   - Ensure your `agents` appear in the agent selector dropdown.
   - If a `skill` does not seem to trigger automatically, explicitly mention it by name in your prompt.

### Verify other AI tools can use the content

If you are using Claude/Cursor/OpenCode/Windsurf (or another assistant), verification is typically:

1. Ensure the files are present in the tool’s configured rules/prompts scope (repo-level or workspace-level).
2. Start a new chat session so the tool reloads instructions.
3. Ask for a response that should clearly follow a rule (e.g., “avoid `Thread.sleep()`; use explicit waits”).

### Option B — Git submodule (centralized updates)

Add this repo as a submodule, then **copy/sync** assets into `.github/*` as part of your internal workflow.

### Option C — Install skills via skills.sh

You can install skills directly from this repository using **skills.sh**:

- Browse the skills list for this repo: `https://skills.sh/?q=fugazi/test-automation-skills-agents`

Copy/paste any of these commands:

```bash
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill playwright-e2e-testing
```

```bash
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill a11y-playwright-testing
```

```bash
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill webapp-playwright-testing
```

```bash
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill qa-test-planner
```

```bash
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill webapp-selenium-testing
```

```bash
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill qa-manual-istqb
```

```bash
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill accessibility-selenium-testing
```

```bash
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill playwright-regression-testing
```

```bash
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill playwright-cli
```

```bash
npx skills add https://github.com/fugazi/test-automation-skills-agents --skill api-testing
```

---

> Note: Copilot’s discovery typically looks at canonical locations like `.github/agents` and `.github/skills`. Keeping this repo as a submodule is fine, but you will generally still want a sync step into `.github/*`.

> Packaging note: the current folder layout and `frontmatter` conventions are optimized for `GitHub Copilot` customizations.
> If you use another tool, you can still reuse the same content by mapping it to that tool’s
> equivalent mechanisms (rules files, system prompts, playbooks, templates).

---

## Core concepts

### 1) Agents: “who does the work and how”

Agents define:

- Identity and specialization (e.g., flaky test hunter)
- Scope boundaries (what the agent will / will not do)
- Tool access (least-privilege when possible)
- Workflow expectations and output format

Agents live in files named like:

- `lowercase-with-hyphens.agent.md`

Each file includes YAML `frontmatter` within this repo. See `AGENTS.md` for local standards.

Tool-agnostic mapping:

- **Copilot**: custom agent file under `.github/agents/`
- **Other tools**: use the agent body as a dedicated system prompt / mode / persona, and keep the same boundaries

### 2) Instructions: “the operating system”

Instructions are cross-cutting rules that keep outputs consistent:

- Playwright coding standards, locator strategy, POM patterns
- Selenium Java standards, explicit waits, AssertJ, Allure
- Accessibility expectations (WCAG 2.1 AA)
- CI/CD test pipeline configuration (GitHub Actions, test tiers, parallel execution)
- Agent authoring guidelines (frontmatter, handoffs, tool selection)

In practice:

- Use instructions when you want **consistent conventions across teams/repos**.
- Treat instructions as **non-negotiable constraints** for day-to-day work.

Tool-agnostic mapping:

- Put the instruction content into your tool’s repo-level rules (often a single “rules” file), or keep them split by domain (Playwright, Selenium, a11y) like this repo does.
- If your tool supports file globs/scopes, mirror the intent (e.g., Playwright rules apply to `**/*.spec.ts`).

## Compatibility notes (VS Code vs GitHub)

Customizations can behave slightly differently depending on where you run Copilot.

- **VS Code**
  - Supports agent `model` and `handoffs` (depending on version).
  - Great for interactive workflows (planning → generate → debug → heal).
- **GitHub (Copilot Coding Agent)**
  - Commonly expects agents under `.github/agents/`.
  - Some frontmatter fields may be ignored depending on the environment.

When in doubt, keep the frontmatter minimal and portable:

- Agents: `description` (required), plus optional `name`, `tools`, `target`, `infer`
- Skills: `name` + `description` (required), optional `license`

## Tool-agnostic usage (Claude/Cursor/OpenCode/Windsurf)

Use this repo as a shared “QA automation brain” for your team:

1. Keep this repository as the source of truth.
2. Sync/copy its content into whichever format your AI tool supports.
3. Keep the same names so prompts remain consistent across tools:
   - “Use the Flaky Test Hunter agent.”
   - “Follow the Playwright TypeScript instructions.”
   - “Apply the playwright-e2e-testing skill playbook.”

Copilot-specific parts are mainly:

- The `.github/*` discovery paths
- Some frontmatter fields that other tools ignore

The testing guidance itself (locator strategies, waits, POM patterns, a11y workflows, ISTQB artifacts) is portable.

### 3) Skills: “reusable playbooks + resources”

Skills are folder-based capabilities that Copilot can load on-demand.

Key characteristics (by design):

- Progressive loading
  - Level 1: Copilot reads only `name` + `description` to decide relevance
  - Level 2: Copilot loads the body of `SKILL.md` when relevant
  - Level 3: Copilot loads references/scripts/templates only when linked/needed

- Resource bundling
  - `references/`: docs loaded into context when referenced
  - `scripts/`: executable helpers (deterministic behavior)
  - `templates/`: starter code that AI may modify
  - `assets/`: static files used as-is

## How to use agents (day-to-day)

### In VS Code (Copilot Chat)

1. Open Copilot Chat.
2. Select the agent from the agent dropdown (Custom Agents).
3. Give a task prompt.

Prompt examples:

- “Use Flaky Test Hunter: investigate why `checkout.spec.ts` fails intermittently in CI and propose fixes.”
- “As API Tester Specialist: create negative tests for `/v1/orders` covering auth failures and schema validation.”
- “As Selenium Test Specialist: generate POM + JUnit 5 tests for login + forgot password.”

### In GitHub (Copilot Coding Agent)

If you’re using Copilot on GitHub (agent workflows), keep the agents under `.github/agents/`.

Recommended pattern:

- Use a planning agent (e.g., implementation plan) to produce an execution plan
- Hand off to a specialist agent (Playwright generator/healer, flaky hunter, etc.)

## What agents exist in this repo

This repo currently includes the following agents (see `agents/`):

- **QA Orchestrator**: routes test tasks to specialist agents, enforces Test Constitution
- **Architect**: orchestrator-style agent (delegation-focused)
- **API Tester Specialist**: API test creation (REST Assured / Playwright API / Supertest), auth, contracts, schemas
- **Flaky Test Hunter**: identifies root causes of flaky tests, applies stabilization strategies
- **Playwright Test Planner**: explores an app and produces a structured test plan
- **Playwright Test Generator**: generates Playwright tests from a plan using Playwright MCP
- **Playwright Test Healer**: runs/debugs failing Playwright tests and fixes them iteratively
- **Selenium Test Specialist**: writes maintainable Selenium Java tests (POM, explicit waits, JUnit5, AssertJ)
- **Selenium Test Executor**: runs/debugs Selenium suites and provides actionable failure analysis
- **Test Refactor Specialist**: refactors test suites (DRY, POM extraction, parameterization)
- **Docs Agent**: technical writer focused on docs output (note: its default paths reference a typical app repo)
- **Implementation Plan Generation Mode**: produces deterministic implementation plans (no code changes)
- **Principal Software Engineer**: principal-level guidance (architecture, quality, pragmatic trade-offs)

> Note: Some agents are intended for orchestration or cross-repo workflows. Use the specialists for daily QA tasks.

## How to use instructions (when and why)

Use instructions when you want **consistent automation standards** across:

- Multiple QA engineers
- Multiple repositories
- Different test stacks (Playwright vs Selenium)

Examples:

- Add Playwright standards to a new repo: copy `instructions/playwright-typescript.instructions.md` into
  `.github/instructions/`.
- Ensure Selenium suites never use `Thread.sleep()`: copy `instructions/selenium-webdriver-java.instructions.md` into
  `.github/instructions/`.
- Standardize a11y approach: copy `instructions/a11y.instructions.md`.

## How to use skills (when they help most)

Skills are best when the team repeats the same “playbook” frequently.

Typical triggers:

- “Write Playwright E2E tests with POM and stable locators” → `playwright-e2e-testing`
- “Run axe-core checks, keyboard navigation, WCAG 2.1 AA” → `a11y-playwright-testing` or `accessibility-selenium-testing`
- “Plan, organize, or optimize regression test suites” → `playwright-regression-testing`
- “Generate ISTQB-aligned artifacts: test plan / bug report / traceability” → `qa-manual-istqb`
- “Browser-based exploration and debugging” → `webapp-playwright-testing`

### Skills catalog (this repo)

| Skill                            | Best for                                                     | Typical prompts                                                                          |
| -------------------------------- | ------------------------------------------------------------ | ---------------------------------------------------------------------------------------- |
| `playwright-e2e-testing`         | Playwright TypeScript E2E + API-in-test patterns             | “Write Playwright tests for checkout with POM and stable locators.”                      |
| `webapp-playwright-testing`      | Live browser interaction + debugging via Playwright MCP      | “Navigate to /login, fill the form, and verify validation errors.”                       |
| `a11y-playwright-testing`        | WCAG 2.1 AA checks using Playwright + axe-core               | “Add automated a11y scans for auth pages and keyboard nav tests.”                        |
| `webapp-selenium-testing`        | Selenium Java automation patterns                            | “Create Selenium POM + JUnit 5 tests for login and profile update.”                      |
| `accessibility-selenium-testing` | A11y scanning with Selenium + axe-core                       | “Scan key pages for WCAG issues and generate an Allure-friendly report.”                 |
| `playwright-regression-testing`  | Regression strategy + test selection + CI/CD optimization    | “Organize tests into tiers (smoke, selective, full) and set up GitHub Actions pipeline.” |
| `qa-manual-istqb`                | ISTQB-aligned artifacts + test design techniques             | “Create a risk-based regression suite and a traceability matrix.”                        |
| `qa-test-planner`                | Test plans + test cases + bug reports + Playwright artifacts | “Use the skill qa-test-planner to create a test plan for payments.”                      |
| `api-testing`                    | REST/GraphQL testing with Playwright and REST Assured        | “Create API tests for user endpoints with schema validation.”                            |

> Note: `qa-test-planner` is intentionally strict: it is designed to trigger only when you call it by name.

### How skill discovery works

Copilot primarily uses the `description` in `SKILL.md` frontmatter to decide whether to load a skill.

To improve activation:

- Include WHAT the skill does
- Include WHEN to use it
- Include KEYWORDS users will naturally type

If a skill still does not activate automatically:

- Explicitly reference it in your prompt (e.g., “use the skill playwright-e2e-testing”).
- Copy the skill folder into `.github/skills/` (not just `skills/`) in your target repo.

## Suggested end-to-end workflows

### Workflow 1 — From requirements to tests (Playwright)

1. Use `qa-manual-istqb` skill to draft test conditions and test cases.
2. Use Playwright Test Planner agent to create an E2E plan.
3. Use Playwright Test Generator agent to generate tests from the plan.
4. Use Playwright E2E Testing skill as the best-practices reference during implementation.

### Workflow 2 — Stabilize a flaky suite

1. Use Flaky Test Hunter agent to identify patterns and root causes.
2. Apply changes (wait strategy, locators, isolation, data seeding).
3. Use Playwright Test Healer agent to validate and repair remaining failures.

### Workflow 3 — Accessibility regression prevention

1. Pick the stack:
   - Playwright + axe-core: `a11y-playwright-testing`
   - Selenium + axe-core: `accessibility-selenium-testing`
2. Add a11y checks to critical flows (auth, checkout, forms, modals).
3. Fail CI on WCAG 2.1 AA violations (with triage exceptions documented).

### Workflow 4 — Regression testing strategy

1. Use `playwright-regression-testing` skill to design your regression approach.
2. Organize tests into tiers:
   - Tier 0: Smoke (< 2 min) — critical path, every commit
   - Tier 1: Sanity (< 10 min) — core features, every PR
   - Tier 2: Selective (< 30 min) — change-based, on merge
   - Tier 3: Full (< 60 min) — complete regression, nightly/pre-release
3. Implement test selection strategies (change-based, risk-based, time-budget).
4. Set up CI/CD pipeline with GitHub Actions (smoke → selective → full).
5. Add flaky test management (retry policies, quarantine, suite health metrics).

### Workflow 5 — API contract validation

1. Use API Tester Specialist agent.
2. Cover:
   - Auth (401/403)
   - Validation errors (400)
   - Schema/contract checks
   - Idempotency where relevant
   - Pagination/sorting/filtering edge cases
3. Use `api-testing` skill for schema validation patterns (Zod, JSON Schema) and contract testing.

### Workflow 6 — CI/CD pipeline setup

1. Use `cicd-testing` instruction for pipeline configuration guidance.
2. Set up tiered GitHub Actions workflows:
   - Smoke (every commit, < 2 min)
   - Sanity (every PR, < 10 min)
   - Selective regression (on merge, < 30 min)
   - Full regression (nightly, < 60 min)
3. Configure parallel execution with sharding.
4. Add deployment gates, flaky test handling, and failure notifications.

## Contributing

### Add a new agent

1. Create `agents/<new-agent>.agent.md`.
2. Follow the structure in `AGENTS.md`:
   - Required: frontmatter `description` (single-quoted)
   - Recommended: `name`, `tools`, `model`, `target`, `handoffs`
3. Keep the scope explicit (includes/excludes) and avoid tool overreach.

### Add a new skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter:
   - `name`: lowercase-with-hyphens, ≤64 chars
   - `description`: WHAT + WHEN + KEYWORDS (critical)
2. Add supporting resources:
   - `references/` for long docs
   - `scripts/` for deterministic automation
   - `templates/` for scaffolds Copilot can modify
   - `assets/` for static content used as-is

## Security & safety

- Do not store secrets in agents/skills/instructions.
- Prefer environment variables and secret managers.
- Avoid destructive scripts; require explicit confirmation flags for irreversible actions.

## Troubleshooting

| Symptom                            | Likely cause                                              | Fix                                                                       |
| ---------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------------------- |
| Agent not visible in selector      | Wrong folder path                                         | Ensure `.github/agents/*.agent.md` in target repo                         |
| Skill never triggers               | Description too vague or folder not in canonical location | Improve `description` and ensure `.github/skills/<skill>/SKILL.md`        |
| `qa-test-planner` doesn’t activate | Designed to be explicit-only                              | Mention it by name: “use the skill qa-test-planner …”                     |
| Generated tests are unstable       | Locator/wait anti-patterns                                | Follow the locator priority + web-first assertions from Playwright skills |
| Selenium tests flaky               | `Thread.sleep()` or missing explicit waits                | Use `WebDriverWait` patterns from Selenium instructions/skills            |

---

## 🏠 Author

- Name: `Douglas Urrea Ocampo`
- Job: `SDET - Software Developer Engineer in Test`
- Country: `Colombia`
- City: `Medellin`
- E-mail: `info@douglasfugazi.co`
- LinkedIn: [https://www.linkedin.com/in/douglasfugazi](https://www.linkedin.com/in/douglasfugazi)
- Contact: [https://douglasfugazi.co](https://douglasfugazi.co)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<p align="center">Built with ❤️ by Douglas Urrea Ocampo for the QA Community.</p>
