# Setup: Devin Desktop (formerly Windsurf)

Integration guide for using test-automation-skills-agents with [Devin Desktop](https://devin.ai), the agent-native IDE formerly known as Windsurf. The IDE, extensions, settings, and plans carry over; only the name and branding changed.

> **Why the rename:** Cognition renamed Windsurf to Devin Desktop. See the [announcement](https://devin.ai/blog/windsurf-is-now-devin-desktop) and the [Devin Desktop FAQ](https://docs.devin.ai/desktop/devin-desktop-faq).
>
> **Backward compatibility:** Devin Desktop still imports the legacy `.windsurfrules`, `.windsurf/rules/*.md`, and `.windsurf/skills/` paths, so existing Windsurf setups keep working. Prefer `AGENTS.md` and the `.devin/` locations for new work.

## How Devin Desktop loads customizations

Devin Desktop runs two agent surfaces:

- **Devin Local** (recommended) — shares the Devin CLI harness. Reads `AGENTS.md`, `.devin/rules/`, `.devin/skills/`, MCP servers, and hooks.
- **Cascade (legacy)** — the original Windsurf agent. Still supports memories, rules, skills, workflows, and MCP.

Both read the portable content in this repository. The table below maps what this repo ships to the Devin Desktop location:

| This repo | Devin Desktop (Devin Local) | Notes |
| --- | --- | --- |
| `CLAUDE.md` / `AGENTS.md` | `AGENTS.md` at project root | Always-on rules. `CLAUDE.md` and `AGENT.md` are also read. |
| `instructions/*.instructions.md` | `.devin/rules/*.md` | Add `trigger: glob` to scope by file type. |
| `skills/<name>/SKILL.md` | `.devin/skills/<name>/SKILL.md` | Progressive disclosure; invoke with `/skill-name`. |
| `agents/*.agent.md` | Prompt reference, or wrap the persona in a skill | Devin Desktop does not consume Copilot's `.agent.md` frontmatter. |
| Legacy `.windsurfrules`, `.windsurf/rules/`, `.windsurf/skills/` | Still imported | Prefer `AGENTS.md` / `.devin/` for new work. |

## Option A (recommended): `AGENTS.md` + skills

Devin Local reads `AGENTS.md` at the workspace root (and in subdirectories) as always-on rules. Skills are loaded only when relevant, which keeps the context window lean.

1. Copy the skills into your project:

```bash
mkdir -p .devin/skills
cp -r /path/to/test-automation-skills-agents/skills/* .devin/skills/
```

2. Add a short `AGENTS.md` at your project root. Keep it focused on conventions and on which skills to use:

```markdown
# QA Automation Rules

- Use the skills under `.devin/skills/` for deep workflows; do not inline them in rules.
- Playwright E2E: use the `playwright-e2e-testing` skill.
- API contracts: use the `api-testing` skill.
- Accessibility: use the `a11y-playwright-testing` or `accessibility-selenium-testing` skill.
- Regression strategy: use the `playwright-regression-testing` skill.
- Never use `Thread.sleep()` in Selenium tests; use explicit waits.
- Exactly one tag per test: `@smoke`, `@sanity`, `@regression`, `@e2e`, `@api`, or `@destructive`.
```

3. Start a new session. Devin Local injects `AGENTS.md` at session start and invokes a skill by its `description` when your request matches. You can also force one with `/playwright-e2e-testing`.

> If your team already uses `CLAUDE.md`, Devin Desktop reads it too. Keep a single source of truth and avoid duplicating the same rules in both files.

## Option B: Rule files with triggers

For language- or path-specific rules, use `.devin/rules/*.md` with `trigger` frontmatter. This is the preferred replacement for the legacy `.windsurf/rules/` directory.

```bash
mkdir -p .devin/rules
```

Example: apply the Playwright conventions only to spec files.

```markdown
---
trigger: glob
globs: "**/*.spec.ts"
---

Use Playwright's web-first assertions and role-based locators.
Never use fixed sleeps; rely on auto-waiting.
```

Example: apply the Selenium conventions only to Java and Maven files.

```markdown
---
trigger: glob
globs: ["**/*.java", "**/pom.xml"]
---

Use the Page Object Model and `WebDriverWait` with `ExpectedConditions`.
Never use `Thread.sleep()` or `WebDriverManager`.
```

| `trigger` value | When the rule reaches the agent |
| --- | --- |
| `always_on` | Every session |
| `glob` | When the agent works with files matching `globs` |
| `model_decision` | When the agent decides the rule is relevant |
| `manual` | Only when you invoke it |

Use `.devin/global_rules.md` for a single always-on file, and `~/.devin/rules/*.md` for rules that apply to every project.

## Option C: Legacy Windsurf paths (still imported)

If you already have a Windsurf setup, it keeps working after the rename:

- `.windsurfrules` — workspace rules (always-on).
- `.windsurf/rules/*.md` — rule files with the same `trigger` frontmatter.
- `.windsurf/skills/<name>/SKILL.md` — skills (`.agents/skills/` is also read).

Devin Desktop loads `.devin/` and `.windsurf/` rule files together, but `.devin/global_rules.md` takes precedence over `.windsurf/global_rules.md`. Move to `.devin/` when convenient; it is the documented location and avoids ambiguity.

## Option D: Package the content as a Devin plugin

If you want one install step for your team, bundle the rules and skills as a Devin agent plugin and install it from a Git repository:

- Plugin skills are invoked as `/<plugin>:<skill>`.
- Plugins can contribute rules, skills, hooks, MCP servers, and subagents.
- See [Devin CLI plugins](https://docs.devin.ai/cli/extensibility/plugins/overview) for the manifest and `devin plugins` commands.

> Devin *agent* plugins are different from the **Windsurf Plugins** for JetBrains/VS Code editors. The JetBrains plugin keeps the Windsurf name and remains available.

## Using the agent personas

Devin Desktop does not use the Copilot frontmatter in `agents/*.agent.md` (`handoffs`, `infer`, `mcp-servers`). The persona body is still useful. Reference the file explicitly:

```text
Read agents/playwright-test-healer.agent.md and follow its workflow to debug this failing test.
```

For repeated use, wrap the persona in a skill so Devin can invoke it by description:

```markdown
---
name: playwright-test-healer
description: Debug and fix failing Playwright tests using the healer workflow.
---

Read and follow `agents/playwright-test-healer.agent.md`.
```

## Verify Devin Desktop loaded the customizations

1. Open the **Agents** window and select **Customize**. The **Rules** and **Skills** tabs list what the current workspace has loaded.
2. Start a new session and ask: "Which rules and skills do you have loaded?"
3. Invoke a skill by name (for example `/playwright-e2e-testing`) to confirm it is available.

## Migration checklist (Windsurf → Devin Desktop)

- [ ] Update the app. The rename arrives as a standard over-the-air update; plans, extensions, settings, and in-progress work carry over.
- [ ] Keep `.windsurfrules` if it works, or move its content to `AGENTS.md`.
- [ ] Move `.windsurf/rules/` to `.devin/rules/` (optional; both load).
- [ ] Move `.windsurf/skills/` to `.devin/skills/` (optional; both are read).
- [ ] Replace `.codeiumignore` with `.devinignore`. Devin Desktop uses `.devinignore` for indexing, Tab, and DeepWiki.
- [ ] Remove Copilot-only frontmatter from anything you convert to a Devin rule or skill.

## Tips

- **Keep `AGENTS.md` short.** Rules are injected into every session, so they cost tokens on every message.
- **Prefer skills for depth.** Progressive disclosure loads `SKILL.md` and its resources only when relevant.
- **Scope rules with `trigger: glob`.** Language- and path-specific rules stay out of unrelated work.
- **Reference files, don't inline them.** Point the agent at a skill or agent file so it reads the full content on demand.
- **One source of truth.** Keep the QA conventions in this repo and sync them into `.devin/` (or `.windsurf/` during the transition) instead of forking the content.
