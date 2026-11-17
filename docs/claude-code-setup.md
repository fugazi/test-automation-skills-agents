# Setup: Claude Code

Integration guide for using test-automation-skills-agents with [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

> **Tool-agnostic by design.** This repository is not a Claude-only plugin: its source of truth is `skills/`, `agents/`, and `instructions/`. Claude Code reads skills and agents natively when they are installed as a plugin or copied into a `.claude/` folder. The other options below give Claude *read access* to the files without registering them as Claude Code components.

## Installation

### Option A (recommended): Install via the Claude Code plugin marketplace

This registers all 7 agents and 10 skills with Claude Code.

```bash
/plugin marketplace add fugazi/test-automation-skills-agents
/plugin install test-automation-skills-agents@fugazi-test-automation
```

> **SSH errors?** The marketplace clones repos via SSH. If you don't have SSH keys set up on GitHub, either [add your SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) or switch to HTTPS for fetches only:
> ```bash
> git config --global url."https://github.com/".insteadOf "git@github.com:"
> ```

### Option B: Copy skills and agents into your project

Claude Code discovers project-level skills at `.claude/skills/<name>/SKILL.md` and subagents at `.claude/agents/<name>.md`.

```bash
mkdir -p .claude/skills .claude/agents

# Skills: copy the folders as-is
cp -r /path/to/test-automation-skills-agents/skills/* .claude/skills/

# Agents: the repo uses Copilot's `.agent.md` suffix; Claude Code expects `.md`
for f in /path/to/test-automation-skills-agents/agents/*.agent.md; do
  cp "$f" ".claude/agents/$(basename "$f" .agent.md).md"
done
```

This is the most portable manual option: no plugin metadata, and the same content works in other tools.

### Option C: Add the repository as an external directory (file access only)

```bash
claude --add-dir /path/to/test-automation-skills-agents
```

`--add-dir` grants Claude Code read access to the directory. It does **not** register `skills/` or `agents/` as Claude Code components, so Claude will not activate a skill or subagent automatically. Point Claude at a specific file instead:

```text
Read /path/to/test-automation-skills-agents/skills/playwright-e2e-testing/SKILL.md and follow its workflow.
```

### Option D: Git submodule

```bash
git submodule add https://github.com/fugazi/test-automation-skills-agents.git .claude/test-automation-skills-agents
```

Then reference it from your project's own `CLAUDE.md`:

```markdown
See .claude/test-automation-skills-agents/CLAUDE.md for QA automation skills and agents.
```

### Option E: Copy `CLAUDE.md` only

Copy the repo's `CLAUDE.md` to your project root. Claude Code reads it at session start.

```bash
cp test-automation-skills-agents/CLAUDE.md ./CLAUDE.md
```

This gives Claude the QA conventions, but not the skills or agents as loadable components.

## How Claude Code loads these paths

| Path | How Claude Code uses it |
| --- | --- |
| `CLAUDE.md` (project root) | Project instructions, loaded at session start. A folder added with `--add-dir` is for file access and does not register skills or agents. |
| `skills/<name>/SKILL.md` | Loaded on demand when the skill is installed as a plugin or lives under `.claude/skills/`. |
| `agents/*.agent.md` | Loaded when installed as a plugin. For project-level agents, copy them to `.claude/agents/<name>.md`. |
| `instructions/*.instructions.md` | **Not loaded by Claude Code.** These are Copilot adapter files; use them as reference or copy the rules into `CLAUDE.md`. |

## Agent frontmatter compatibility

The agent body is portable. These frontmatter fields behave differently per tool:

| Field | Claude Code | Notes |
| --- | --- | --- |
| `name`, `description` | Read | Used for discovery and display. |
| `tools` | Read | Use the canonical names: `Read`, `Edit`, `Write`, `Grep`, `Glob`, `Bash`, `Task`, `WebFetch`, `WebSearch`, `TodoWrite`. |
| `model` | Read | This repo intentionally does not pin a model. |
| `handoffs` | Ignored | Copilot/VS Code only. In Claude Code, delegate with the `Task` tool. |
| `infer` | Ignored | Copilot/VS Code only. Claude Code auto-selects agents by `description`. |
| `mcp-servers` | Ignored | Configure MCP servers at the Claude Code or plugin level instead. |
| `target`, `capabilities`, `scope`, `decision-autonomy` | Ignored | Documentation only; the body must stand on its own. |

To delegate in Claude Code, the orchestrator needs `Task` in its `tools` list (it has it). Invoke it explicitly:

```text
Use the qa-orchestrator agent to plan, generate, and heal the tests for the checkout flow.
```

## Activating skills

Skills activate automatically when you describe a testing task:

```text
You: "Write E2E tests for the login page"
→ Activates: playwright-e2e-testing skill

You: "Create API tests for the users endpoint"
→ Activates: api-testing skill

You: "This test is flaky, fix it"
→ Activates: qa-investigation skill (or the playwright-test-healer agent)
```

If a skill doesn't activate automatically, reference it explicitly:

```text
You: "Use the playwright-regression-testing skill to organize my test suite"
```

## Using agents

Reference agents by name in your prompt (the `description` drives selection):

```text
You: "Use the playwright-test-planner to create a test plan for the checkout flow"
You: "Have the api-tester-specialist design tests for the /orders endpoint"
You: "Ask the playwright-test-healer to analyze this failing test"
You: "Use the selenium-test-specialist to create Java tests for the profile page"
```

## Custom slash commands

Create `.claude/commands/` in your project for quick access to common workflows:

```bash
mkdir -p .claude/commands
```

Example `.claude/commands/test-plan.md`:

```markdown
Use the playwright-test-planner agent to create a comprehensive test plan for: $ARGUMENTS
```

Example `.claude/commands/api-tests.md`:

```markdown
Use the api-tester-specialist agent to design and generate API tests for: $ARGUMENTS
Include schema validation, auth testing, and error states.
```

Example `.claude/commands/fix-flaky.md`:

```markdown
Use the playwright-test-healer agent to investigate and fix this flaky test: $ARGUMENTS
```

Then invoke them in Claude Code:

```text
/test-plan the checkout flow
/api-tests the /users endpoint
/fix-flaky tests/login.spec.ts
```

## Tips

- **`CLAUDE.md` in your project root is always loaded.** Put project-wide QA conventions there. Skills and agents load on demand.
- **Use `/` commands for repeated workflows.** Any prompt you use frequently should become a slash command.
- **Reference resources explicitly.** When you need a specific reference or template, say so: "Use the file-map-template from the playwright-e2e-testing skill."
- **Memory persists across sessions.** Claude Code remembers your project context. Tell it once about your tech stack and it applies that knowledge going forward.
