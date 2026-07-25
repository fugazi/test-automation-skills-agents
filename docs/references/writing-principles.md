## Writing Principles

1. **Process over knowledge.** Skills are workflows, not reference docs. Steps, not facts. An agent reading the skill should know exactly what to DO.

2. **Specific over general.** "Run `npx playwright test --reporter=html`" beats "verify the tests pass". "Use `getByRole('button', { name: 'Submit' })`" beats "find the submit button".

3. **Evidence over assumption.** Every verification checkbox requires proof. "All tests pass" must be backed by "exit code is 0" or "HTML report shows 0 failures".

4. **Anti-rationalization.** Every skip-worthy step needs a counter-argument in the Common Rationalizations table. If agents routinely skip a step, document why they shouldn't.

5. **Progressive disclosure.** Main SKILL.md is the entry point. Supporting files are loaded only when the workflow reaches a step that references them.

6. **Token-conscious.** Every section must justify its inclusion. If removing it wouldn't change agent behavior, remove it.

7. **Dual-stack aware.** When writing a skill that could apply to both Playwright and Selenium, clearly separate the content. Never mix TypeScript and Java in the same code block.

8. **QA-domain specific.** This repository is for QA Automation Engineers. Write for that audience — assume familiarity with testing concepts (POM, assertions, fixtures, test data management).

---

