# Axe-Core Tags Reference

> Part of the `a11y-playwright-testing` skill. See [SKILL.md](../SKILL.md) for full context.

| Tag             | WCAG Level   | Use Case                   |
| --------------- | ------------ | -------------------------- |
| `wcag2a`        | Level A      | Minimum compliance         |
| `wcag2aa`       | Level AA     | **Standard target**        |
| `wcag2aaa`      | Level AAA    | Enhanced (rarely full)     |
| `wcag21a`       | 2.1 Level A  | WCAG 2.1 specific A        |
| `wcag21aa`      | 2.1 Level AA | **WCAG 2.1 standard**      |
| `best-practice` | Beyond WCAG  | Additional recommendations |

## Default Tags (WCAG 2.1 AA)

```typescript
const WCAG21AA_TAGS = ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"];
```
