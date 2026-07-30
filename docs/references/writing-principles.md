## Writing Principles

1. **Process over knowledge.** Skills are workflows, not reference docs. Steps, not facts. An agent reading the skill should know exactly what to DO.

2. **Specific over general.** "Run `npx playwright test --reporter=html`" beats "verify the tests pass". "Use `getByRole('button', { name: 'Submit' })`" beats "find the submit button".

3. **Evidence over assumption.** Every verification checkbox requires proof. "All tests pass" must be backed by "exit code is 0" or "HTML report shows 0 failures".

4. **Affirmative principles over anticipated excuses.** Do NOT use a `## Common Rationalizations` table — that pattern anticipates model excuses (micro-management) and Anthropic eliminated it from Claude Code with no eval loss. If you observe a *real, recurring* model failure on a step, express the fix as a 1-line affirmative principle (e.g., "Always review the diff image before updating a baseline") rather than as a counter-argument table.

5. **Progressive disclosure.** Main SKILL.md is the entry point. Supporting files are loaded only when the workflow reaches a step that references them.

6. **Token-conscious.** Every section must justify its inclusion. If removing it wouldn't change agent behavior, remove it.

7. **Dual-stack aware.** When writing a skill that could apply to both Playwright and Selenium, clearly separate the content. Never mix TypeScript and Java in the same code block.

8. **QA-domain specific.** This repository is for QA Automation Engineers. Write for that audience — assume familiarity with testing concepts (POM, assertions, fixtures, test data management).

---

