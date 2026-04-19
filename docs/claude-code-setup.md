# Setup: Claude Code

Integration guide for using test-automation-skills-agents with [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Installation

### Option A: Add as External Directory

```bash
git clone https://github.com/fugazi/test-automation-skills-agents.git
cd your-project
claude --add-dir /path/to/test-automation-skills-agents
```

Claude Code will load `CLAUDE.md` from the added directory and have access to all agents, skills, and instructions.

### Option B: Install via Claude Code Plugin Marketplace

Subscribe to this repository as a plugin marketplace directly from Claude Code:

```bash
/plugin marketplace add fugazi/test-automation-skills-agents
```

Then install the plugin:

```bash
/plugin install qa-automation@fugazi-test-automation
```

This will make all 13 specialized QA agents and 10 reusable skills available in your Claude Code session.

> **SSH errors?** The marketplace clones repos via SSH. If you don't have SSH keys set up on GitHub, either [add your SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) or switch to HTTPS for fetches only:
> ```bash
> git config --global url."https://github.com/".insteadOf "git@github.com:"
> ```

**Local / development:**

```bash
git clone https://github.com/fugazi/test-automation-skills-agents.git
claude --add-dir /path/to/test-automation-skills-agents
```

### Option C: Copy CLAUDE.md to Your Project

Copy the repo's `CLAUDE.md` to your project root. Claude Code automatically reads it on startup.

```bash
cp test-automation-skills-agents/CLAUDE.md ./CLAUDE.md
```

### Option D: Git Submodule

```bash
git submodule add https://github.com/fugazi/test-automation-skills-agents.git .claude/test-automation-skills-agents
```

Then reference it from your project's own `CLAUDE.md`:

```markdown
See .claude/test-automation-skills-agents/CLAUDE.md for QA automation skills and agents.
```

## How It Works

Claude Code reads files in this order:

1. **CLAUDE.md** — Project-level instructions (automatically loaded at session start)
2. **agents/\*.agent.md** — Agent personas (loaded when referenced in prompts)
3. **skills/\*/SKILL.md** — Skill workflows (loaded on demand based on task)
4. **instructions/\*.instructions.md** — Rules and conventions (loaded when relevant)

## Activating Skills

Skills activate automatically when you describe a testing task:

```
You: "Write E2E tests for the login page"
→ Activates: playwright-e2e-testing skill

You: "Create API tests for the users endpoint"
→ Activates: api-testing skill

You: "This test is flaky, fix it"
→ Activates: playwright-test-healer agent
```

If a skill doesn't activate automatically, reference it explicitly:

```
You: "Use the playwright-regression-testing skill to organize my test suite"
```

## Using Agents

Reference agents by name in your prompt:

```
You: "Use the playwright-test-planner to create a test plan for the checkout flow"
You: "Have the api-tester-specialist design tests for the /orders endpoint"
You: "Ask the flaky-test-hunter to analyze this failing test"
You: "Use the selenium-test-specialist to create Java tests for the profile page"
```

## Custom Slash Commands

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
Use the flaky-test-hunter agent to investigate and fix this flaky test: $ARGUMENTS
```

Then invoke them in Claude Code:

```
/test-plan the checkout flow
/api-tests the /users endpoint
/fix-flaky tests/login.spec.ts
```

## Tips

- **CLAUDE.md is always loaded.** Put project-wide QA conventions there. Skills and agents load on demand.
- **Use `/` commands for repeated workflows.** Any prompt you use frequently should become a slash command.
- **Reference resources explicitly.** When you need a specific reference or template, say so: "Use the file-map-template from the playwright-e2e-testing skill."
- **Memory persists across sessions.** Claude Code remembers your project context. Tell it once about your tech stack and it applies that knowledge going forward.
