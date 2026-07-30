# Locator Strategies Quick Reference

> Part of the `webapp-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original locator-strategies.md. See the other related files in this folder.

## Quick Reference

| Need            | Locator                                         |
| --------------- | ----------------------------------------------- |
| Button by ID    | `By.id("submit-btn")`                           |
| Input by name   | `By.name("email")`                              |
| By test ID      | `By.cssSelector("[data-testid='name']")`        |
| By aria-label   | `By.cssSelector("[aria-label='Close']")`        |
| By type         | `By.cssSelector("input[type='password']")`      |
| Link by text    | `By.linkText("Sign up")`                        |
| Row in table    | `By.cssSelector("table tbody tr:nth-child(2)")` |
| By text (XPath) | `By.xpath("//button[text()='Submit']")`         |
| Parent element  | `By.xpath("//input[@id='x']/parent::div")`      |

---

## Locator Checklist

Before implementing a locator, verify:

- [ ] Is there a unique ID? → Use `By.id()`
- [ ] Is there a `data-testid`? → Use `By.cssSelector("[data-testid='x']")`
- [ ] Is there a unique `name`? → Use `By.name()`
- [ ] Can I use semantic CSS? → Use `By.cssSelector()`
- [ ] Do I need text matching? → Consider XPath
- [ ] Is it an anchor tag? → Consider `By.linkText()`
- [ ] Am I using absolute XPath? → **Refactor immediately!**
````
