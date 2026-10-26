# Contributing

Thanks for your interest in this repository. It is a curated, **tool-agnostic** catalog of QA
automation skills, agents, and instructions — maintained by one author, consumed by multiple AI
assistants and frontier models.

Because it is curated rather than aggregated, the bar for inclusion is authoring quality, not
volume. Please read the scope below before opening a pull request.

## Scope

**In scope**

- Original skills (`skills/<name>/SKILL.md`) for test automation: Playwright, Selenium, API
  testing, accessibility, ISTQB-aligned QA artifacts, CI/CD, failure investigation.
- Agent definitions (`agents/*.agent.md`) and lean instructions (`instructions/*.instructions.md`).
- Corrections to existing skills: fixed commands, accurate exit codes, clarified prerequisites,
  removed obsolete workarounds.
- Fixes to documentation, links, and the linter (`scripts/lint-skills.mjs`).

**Out of scope**

- **Submissions that document or promote a third-party tool.** This repository is not a
  directory, marketplace listing, or marketing surface for external products. A skill whose
  purpose is to explain how to use someone else's product belongs in that product's own
  documentation.
- Vendored copies of upstream instructions. Skills here are original; attribution and license
  notices are required when content derives from another source.
- Changes to `.claude-plugin/plugin.json` version or the skill/agent counts by external
  contributors. Version bumps are made by the maintainer when a release ships.
- Anything unrelated to QA automation authoring.

## Authoring requirements

Before opening a PR, read the canonical guides — do not re-derive the conventions from other skills:

- [Skill anatomy](./docs/skill-anatomy.md) — required sections, progressive disclosure, resource
  types, naming
- [Authoring skills](./docs/references/authoring-skills.md) — frontmatter fields and formatting
- [Authoring agents](./docs/references/authoring-agents.md) — frontmatter fields, handoffs,
  orchestration
- [AGENTS.md](./AGENTS.md) — the non-inferable rules in one page

The rules that most often fail review:

- `SKILL.md` stays at or under 500 lines (body, standard included); long reference material goes
  in a bundled file, linked from the step that needs it.
- `description` is single-quoted, states WHAT + WHEN + KEYWORDS, and stays under 1024 characters
  (≤450 is the ideal); `name` matches the folder in kebab-case and is ≤64 characters.
- No pinned `model` in frontmatter — the harness selects it.
- Skills are agent-agnostic: never reference a specific agent.
- Every step ends on a checkable completion criterion. Procedures, not records — logs and task
  outputs belong in memory, not skills.

## Validation

The structural linter is the only validation in this repository. It must pass with **0 errors**:

```bash
node scripts/lint-skills.mjs
```

It checks frontmatter, name/folder agreement, description length, line limits, intra-skill link
resolution, kebab-case filenames, and the Selenium rules (no WebDriverManager; Maven only, no
Gradle).

CI runs the same check on pull requests touching `skills/`, `agents/`, or `instructions/`. A
contributor's local run does not replace CI — if the check shows as `action_required` because the
workflow needs approval for first-time contributors, it has not run yet.

## Pull requests

- Keep one logical change per PR, with a title in the repository's existing style (`feat:`,
  `fix:`, `docs:`).
- Describe what changed and why, and state what you actually verified — not what you expect to
  be true.
- Update `CHANGELOG.md` under `[Unreleased]` when the change is user-facing.
- Do not bump the plugin version or edit the skill counts in `README.md`, `CLAUDE.md`, or the
  setup guides; the maintainer reconciles those at release.

## Licensing

Contributions are accepted under the repository's existing license. If a submission includes
material derived from another project, state the source and its license in the PR and include the
license text alongside the skill.

## Review

Every submission is reviewed for scope first, then for accuracy. Submissions outside the scope above
are closed with a short explanation — this is not a judgement of the work's quality, only of its fit
for this repository.
