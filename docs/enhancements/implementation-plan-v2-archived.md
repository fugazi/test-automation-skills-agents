# Implementation Plan — Skills Optimization for QA Automation Engineers

> **Branch:** `chore/skills-qa-automation-optimization`
> **Scope:** `skills/` (11 skills), plus repo-level tooling (`scripts/lint-skills.mjs`, one CI workflow),
> `SKILLS-INDEX.md`, and two doc touch-points (`docs/skill-anatomy.md`, `AGENTS.md`)
> **Audience:** QA Automation Engineers, SDETs, QA Leads consuming this repository through AI coding tools
> (GitHub Copilot, Claude, Cursor, OpenCode, Windsurf)
> **Status:** v2 — revised after independent adversarial review (see §10 Revision Log)

---

## 1. Purpose

Bring the 11 existing skills up to the repository's own quality bar (`docs/skill-anatomy.md`, `AGENTS.md`,
`instructions/agent-skills.instructions.md`) and to current industry best practices for Agent Skills, with every
change evaluated through the lens of a QA Automation Engineer: does this make the right skill trigger, on the
right task, with the right workflow, at the lowest context cost?

This plan **does not** rename skills, delete skills, or change public frontmatter `name` fields — those are
breaking changes for consumers. It fixes, deduplicates (with managed trade-offs, §5 Phase 3), restructures, and
sharpens.

---

## 2. Sources and Methodology

| Source | What it contributed |
| ------ | ------------------- |
| Audit of all 11 `SKILL.md` files + `references/` inventory | Evidence-based findings (line counts, missing sections, broken references, drift) |
| **Adversarial review (independent model, QA Automation posture)** | Verified findings, caught 8 errors in v1, surfaced 11 blind spots — incorporated in v2 |
| `docs/skill-anatomy.md` (repo standard, 839 lines) | Required sections, 500-line SKILL.md limit, 300-line reference limit, back-link headers, cross-skill reference rules, naming conventions |
| `instructions/agent-skills.instructions.md` (GitHub Copilot) | Frontmatter rules, description = WHAT + WHEN + KEYWORDS, resource-type matrix, cross-platform script preference |
| Anthropic — Skill authoring best practices (platform.claude.com) | Concise-is-key, third-person descriptions, progressive disclosure, one-level-deep references, TOC for files >100 lines, degrees of freedom, evaluation-first iteration |
| `skill-creator` skill (global) | "Pushy" descriptions to combat under-triggering, eval-driven improvement loop, trigger-query eval sets |
| VS Code Agent Skills docs + awesome-copilot examples | Description patterns (`Trigger for:`, `USE FOR / DO NOT USE FOR`), `/skill-name` explicit invocation |

**Audit coverage note (corrected in v2):** v1 audited SKILL.md + references only. The adversarial review proved
that `scripts/` and `templates/` were never inspected (missed defects D9, D11). v2 adds an explicit audit phase
(Phase 0, T0.1) covering scripts and templates before any phase touches them.

---

## 3. Findings (Evidence-Based Gap Analysis — corrected after adversarial verification)

### F1 — Structural non-compliance with the repo's own skill anatomy

| Rule (source) | Status today | Evidence |
| ------------- | ------------ | -------- |
| `## Red Flags` is a **required** section (skill-anatomy.md L110) | Missing in **9 of 11** skills | Only `grill-me-qa` (Anti-Patterns & Red Flags) and `qa-test-planner` (Anti-Patterns table) have functional equivalents. `playwright-regression-testing` does **not** (verified: 114 lines, Rationalizations only) |
| `## When to Use` must include negative exclusions ("NOT for Y") | Missing in **10 of 11** skills | Only `grill-me-qa` L36 has a "When NOT to Use" section. `qa-test-planner` has **zero** negative exclusions (verified) |
| `## Verification` checklist | **9 of 11 comply** | Missing in `playwright-cli` **and** `grill-me-qa` (has `## Stopping Criteria`, not a `- [ ]` checklist). `qa-test-planner` has **two divergent** verification blocks (L252 artifact-focused vs L472 generic-strategy) — see D13 |
| Reference files must start with title + back-link to SKILL.md | **0 of 55** reference files comply | Verified by scanning first 3 lines of every `references/*.md` |
| Cross-references must be documented in `SKILLS-INDEX.md` | File **does not exist** | `Test-Path SKILLS-INDEX.md` → False |
| Reference/template files must be `lowercase-hyphen-separated` (skill-anatomy.md L459-460) | **~15 files are snake_case** | `locator_strategies.md` (×3), `page_object_model.md` (×3), `wait_strategies.md`, `axe_patterns.md`, `aria_patterns.md`, `api_testing.md`, `common_patterns.md`, `bug_report_templates.md`, `test_case_templates.md`, `regression_testing.md`, `playwright_automation.md`. Note: anatomy's own example at L459 ironically shows `locator_strategies.md` as the hyphenated example — the standard contradicts itself; see Open Decision OD-4 |

### F2 — Reference files exceed the 300-line limit (progressive disclosure debt)

22 of 55 reference files violate the repo's 300-line rule (all counts independently re-verified). Worst offenders:

| File | Lines | Over by |
| ---- | ----- | ------- |
| `playwright-e2e-testing/references/snippets.md` | 786 | +162% |
| `webapp-selenium-testing/references/page_object_model.md` | 770 | +157% |
| `webapp-playwright-testing/references/api_testing.md` | 718 | +139% |
| `accessibility-selenium-testing/references/axe_patterns.md` | 708 | +136% |
| `playwright-e2e-testing/references/page_object_model.md` | 678 | +126% |
| `webapp-selenium-testing/references/wait_strategies.md` | 675 | +125% |
| `a11y-playwright-testing/references/snippets.md` | 654 | +118% |

Per Anthropic guidance, files >100 lines also need a table of contents; none of the 22 has one.
**v2 refinement:** before splitting, each file is classified as *agent-loaded deep-dive* (split) vs
*human-consumed checklist/catalog* (TOC, optionally kept whole — e.g., `wcag21aa-checklist.md` is a print-ready
audit checklist whose value is single-document completeness). See P2.1.

### F3 — Duplicated content with real drift between copies

| Content | Copies | Sizes (lines) | Drift |
| ------- | ------ | ------------- | ----- |
| `locator_strategies.md` | 3 (e2e, webapp-pw, selenium) | 465 / 335 / 414 | Diverged — **and the webapp-pw copy carries unique MCP-session content** (snapshot-based debugging patterns at L312/L317) that the e2e copy lacks |
| `page_object_model.md` | 3 (e2e, webapp-pw, selenium) | 678 / 592 / 770 | Selenium copy legitimately differs (Java); the two Playwright copies diverged |
| WCAG 2.1 AA checklist | 2 (a11y-pw, a11y-selenium) | 84 / 384 | Same topic, 4.5× size difference |

Violates skill-anatomy.md cross-reference rule #1 ("Never duplicate content between skills") — **but** deleting
copies conflicts with the skills' distribution model (copy-one-folder install, §5 Phase 3). Resolution strategy
is an explicit design decision (OD-1), not a default.

### F4 — Concrete defects and internal contradictions

| # | Skill | Defect | Evidence | Status |
| - | ----- | ------ | -------- | ------ |
| D1 | `qa-test-planner` | Workflow 4 L178 points to nonexistent `templates/regression-suite.md` | `templates/` holds only test-plan, test-case, playwright-test, bug-report | Verified |
| D2 | `qa-test-planner` | How-It-Works diagram says "template from **assets/**" — folder is `templates/` | SKILL.md L106 | Verified |
| D3 | `qa-test-planner` | "Triggered **only** when explicitly called by name" contradicts description-based discovery → guaranteed under-triggering | SKILL.md L11 | Verified |
| D4 | `webapp-selenium-testing` | Verification demands "WebDriverManager used"; body says Selenium Manager (built-in 4.6+) | SKILL.md L32 vs L266 | Verified |
| D5 | `webapp-selenium-testing` | Verification demands `@FindBy` annotations; POM section teaches plain-`By` POM | SKILL.md L265 | Verified. (Adversarial claim of `@FindBy` in `file-map-template.md` was checked and is **false** — no occurrence) |
| D6 | Selenium skills (×2) + `api-testing` | Java baseline inconsistent: 11+ / 21+ / 21+ across three skills | All three SKILL.md files | Verified — **scope expanded in v2** to include `api-testing` |
| D7 | `api-testing` | Intro couples skill to `api-tester-specialist` agent; skills must stand alone | SKILL.md L8 | Verified |
| D8 | `accessibility-selenium-testing` | Description advertises "WCAG 2.1/2.2"; body covers only 2.1 tags | Description vs body | Verified — resolution escalated (OD-2) |
| D9 | `webapp-selenium-testing` | Verification mentions `gradle test` in a Maven-only skill | SKILL.md L271 | Verified (caught by adversarial review) |
| D10 | `qa-test-planner` | Workflow 4 self-contradiction: L178 (missing template) vs L184 "use `test-case.md` grouped by priority"; Quick Start L44 and Quick Reference L57-62 route to test-case.md | SKILL.md | Verified (caught by adversarial review; supersedes half of v1's P0.1) |
| D11 | `playwright-e2e-testing` + `webapp-playwright-testing` | Non-ASCII symbol markers (✅/❌-style, mojibake-prone) inside locator references; AGENTS.md bans emojis in files | e2e locator_strategies.md L332/L341/L351; mirrored in webapp-pw copy | Verified (caught by adversarial review) |
| D12 | `docs/skill-anatomy.md` | Naming-rule table L459 shows `locator_strategies.md` (snake_case) as the example of `lowercase-hyphen-separated.md` | skill-anatomy.md L459 | Verified — standard self-contradiction |
| D13 | `qa-test-planner` | Two divergent verification sections: `## Verification Checklist` (L252, artifact-scoped) vs `## Verification` (L472, generic strategy content: "Test levels defined", "Stakeholder sign-off") | SKILL.md | Verified (caught by adversarial review) |

### F5 — Discovery & boundary weaknesses (QA Automation focus)

1. **Overlapping triggers, no routing guidance.** Three Playwright skills compete on the same prompts:
   `playwright-e2e-testing` (author specs), `webapp-playwright-testing` (live browser via MCP),
   `playwright-cli` (live browser via CLI). `webapp-playwright-testing`'s When-to-Use ("Create Playwright tests
   for web applications") directly invades `playwright-e2e-testing`'s core. None says when **not** to pick it.
2. **`qa-test-planner` vs `qa-manual-istqb`** overlap on plans, cases, bug reports, regression, and Playwright
   scaffolding with no documented boundary (planner = template-driven artifacts; istqb = methodology/techniques).
3. **Description quality inconsistent.** Good models: `playwright-cli`, `playwright-regression-testing`.
   Thinnest: `webapp-selenium-testing`. Voice/pattern varies across the 11.
4. **`license` frontmatter in only 2 of 11** skills (`playwright-cli`, `qa-test-planner`) though all ship `LICENSE.txt`.
5. **Daily-bread workflow unrouted:** CI failure triage (trace → product-bug vs test-bug vs flake → quarantine)
   is scattered across `playwright-regression-testing/references/flaky-management.md` and
   `playwright-e2e-testing/references/debugging.md` with no cross-skill routing (caught by adversarial review).

### F6 — Context-economy issues in SKILL.md bodies

- `accessibility-selenium-testing` (479 lines) inlines a full JUnit 5 test class (~60 lines) — extract.
- `qa-test-planner` (482 lines) is **compliant** with the 500-line cap and its long examples already use the
  sanctioned `<details>` pattern — **v2 drops v1's plan to extract them** (no violation, real link-rot risk).
  Only its D13 duplicate-verification consolidation is retained.
- `playwright-cli` (420 lines) needs boundary framing + Verification, not slimming.

### F7 — QA Automation coverage gaps (new-skill candidates, Phase 6 RFC only)

Not covered today: visual regression testing, test data management/factories, performance testing (k6),
contract testing (beyond a 109-line reference). **Proposals only** — nothing built without user sign-off.

### Skills in good shape (minimal changes)

- `playwright-regression-testing` — lean, strong description. Needs: Red Flags, NOT-for, back-links, license.
- `grill-me-qa` — best-structured. Needs: license, back-links, **and a real `## Verification` checklist** (F1).
- `api-testing` — lean. Needs: D7, Red Flags, NOT-for, back-links, license.

---

## 4. Open Decisions (require user sign-off — flagged by adversarial review)

| ID | Decision | Options | Recommendation |
| -- | -------- | ------- | -------------- |
| OD-1 | **Duplication vs self-containment** (Phase 3). Skills are distributed by copying single folders; cross-skill by-name links break for single-skill installs | (a) Delete duplicates, link by skill name (breaks single-skill installs); (b) Keep duplicates with canonical-copy headers + lint drift-check; (c) Inline the critical ~10% (locator priority table, POM skeleton) into each dependent SKILL.md, keep one canonical full reference | **(c) + (b) hybrid**: inline the routing-critical tables into each SKILL.md (self-contained), designate one canonical full reference per topic per stack, mark duplicates with `> Canonical copy: skills/<owner>/references/<file>` headers, lint drift-checks the copies |
| OD-2 | **WCAG 2.2 coverage** (D8). axe-core 4.10 (the skill's own prerequisite) already supports `wcag22` tags; WCAG 2.2 is the current W3C recommendation | (a) Claim 2.1 only (reduce advertised scope); (b) Add 2.2 tags + checklist deltas to both a11y skills | **(b)** — increases value for QA engineers; matches the prerequisite already declared |
| OD-3 | **Java baseline** (D6) | Align all three Java-touching skills to **21+** (current LTS, 2 of 3 already say it), including `api-testing` and the a11y-selenium *description* text | **21+** |
| OD-4 | **snake_case reference files** (~15 files violate anatomy L459-460; anatomy's own example contradicts the rule, D12) | (a) Rename files (breaks inbound links from consumers); (b) Fix the anatomy example, grandfather existing names, enforce hyphen-case only for *new* files | **(b)** — no breaking changes; standard made self-consistent |

---

## 5. Work Plan (re-sequenced after adversarial review)

**Sequencing rationale (v2):** design decisions (OD-1..OD-4) and the eval baseline come **before** any work that
depends on them; no hygiene effort is spent on files a later phase may delete; boundary *design* precedes
boundary *writing*.

### Phase 0 — Decisions, extended audit, and measurement baseline

| ID | Task | Files | Acceptance |
| -- | ---- | ----- | ---------- |
| T0.1 | **Extended audit of `scripts/` and `templates/`** (the layer v1 missed): verify pom-template dependency versions against SKILL.md prerequisite tables (both Selenium skills); check all ~20 templates against the Template File Template header rule; note cross-platform gaps (`setup-maven-project.ps1` is Windows-only; `api-health-check.sh` is bash-only) | audit notes appended to this plan's PR | Findings list appended as Appendix A.4; each finding routed to a phase |
| T0.2 | **Resolve OD-1..OD-4 with the user** and record outcomes in §4 | this file | User sign-off recorded |
| T0.3 | **Eval harness + baseline run**: build trigger-eval sets for the 3 boundary zones (Playwright tri-skill, planner pair, a11y pair) — 8-10 should-trigger + 8-10 near-miss should-not-trigger queries each, realistic QA phrasing, **with expected routing defined for ambiguous queries** (e.g., "write a Playwright test for the login page" → `playwright-e2e-testing`). Run the **current** descriptions as the baseline: 3 trials per query, record routing accuracy per zone | `evals/trigger-evals/*.json`, baseline results (temp workspace, not committed) | Baseline numbers exist for before/after comparison; user signs off on eval sets |
| T0.4 | **Lint script v1 + CI gate**: author `scripts/lint-skills.mjs` (Node — the repo already depends on Node; avoids pwsh-on-Linux runner issues) checking: frontmatter fields, name-matches-dir, SKILL.md <500, references ≤300 + back-link header, intra-skill links resolve, canonical-copy drift (OD-1). Add `.github/workflows/lint-skills.yml` running it on PRs touching `skills/` | `scripts/lint-skills.mjs`, `.github/workflows/lint-skills.yml` | CI fails on violations; runs green on `main` after Phase 4 |

### Phase 1 — Correctness fixes (no restructuring)

| ID | Task | Files | Acceptance |
| -- | ---- | ----- | ---------- |
| T1.1 | D1+D10 cheap fix: point Workflow 4 L178 at `test-case.md` grouped by priority (aligning with L184, L44, L57-62). **No new template** until the planner/istqb boundary (T3.3) decides regression-suite ownership | `skills/qa-test-planner/SKILL.md` | All regression references in the skill point to one consistent artifact |
| T1.2 | D2: "assets/" → "templates/" in the diagram | `skills/qa-test-planner/SKILL.md` | Grep clean |
| T1.3 | D3: remove "triggered only when explicitly called by name"; keep `/qa-test-planner` as documented explicit path | `skills/qa-test-planner/SKILL.md` | Activation note removed; description carries triggers (T4.1) |
| T1.4 | D4+D5+D9: align Verification with the skill's actual teaching — "Selenium Manager (4.6+) initializes drivers"; drop `@FindBy` requirement; drop `gradle test` | `skills/webapp-selenium-testing/SKILL.md` | Checklist matches body; `scripts/pom-template.xml` verified WebDriverManager-free in T0.1 |
| T1.5 | D6 per OD-3: align Java baseline across `webapp-selenium-testing`, `accessibility-selenium-testing` (prerequisites **and description**), `api-testing` | 3 SKILL.md files | Same JDK floor everywhere |
| T1.6 | D7: rewrite `api-testing` intro to stand alone | `skills/api-testing/SKILL.md` | No agent coupling |
| T1.7 | D8 per OD-2: add `wcag22` tags + WCAG 2.2 deltas to both a11y skills (or reduce claim — per sign-off) | both a11y SKILL.md + checklists | Description matches body |
| T1.8 | D11: emoji/mojibake cleanup pass in both locator copies (replace symbol markers with ASCII) — **before** any canonicalization touches these files | 2 reference files | ASCII-only; AGENTS.md-compliant |
| T1.9 | D13: consolidate `qa-test-planner`'s two verification blocks into one artifact-scoped `## Verification` (drop the L472 strategy-generic block) | `skills/qa-test-planner/SKILL.md` | Single coherent checklist |
| T1.10 | D12 per OD-4: fix anatomy's L459 example (hyphenated example); add "grandfathered names" note | `docs/skill-anatomy.md` | Standard self-consistent |

### Phase 2 — Boundary design, then structural compliance

| ID | Task | Files | Acceptance |
| -- | ---- | ----- | ---------- |
| T2.1 | **Design the routing boundaries** (decision content only, written into each skill's NOT-for list): author-specs → `playwright-e2e-testing`; live MCP session → `webapp-playwright-testing`; live CLI session → `playwright-cli`; template artifacts → `qa-test-planner`; ISTQB methodology → `qa-manual-istqb`; strategy grilling → `grill-me-qa`; CI-failure triage route (regression↔e2e debugging, F5.5) | design notes inline in T2.2 diffs | Boundary table added to `SKILLS-INDEX.md` (T2.4) |
| T2.2 | Add `## Red Flags` (≥3 observable, code-detectable entries) to the 9 skills missing it; add `## Verification` checklist to `playwright-cli` and `grill-me-qa` | 10 SKILL.md files | Anatomy required-sections check passes |
| T2.3 | Add "NOT for" exclusions (using T2.1 boundaries) to the 10 skills missing them | 10 SKILL.md files | Each When-to-Use has ≥2 routed NOT-for bullets |
| T2.4 | Create `SKILLS-INDEX.md`: inventory, one-line purpose per skill, boundary/routing table (T2.1), dependency map; link from `AGENTS.md` | `SKILLS-INDEX.md`, `AGENTS.md` | Anatomy cross-reference rule #4 satisfied |
| T2.5 | Add `license: 'Complete terms in LICENSE.txt'` to the 9 skills missing it | 9 frontmatters | All 11 uniform |

### Phase 3 — Managed deduplication (per OD-1)

| ID | Task | Files | Acceptance |
| -- | ---- | ----- | ---------- |
| T3.1 | **Locator strategies:** canonical = `playwright-e2e-testing` copy (most complete); port the webapp-pw MCP-unique content (snapshot debugging patterns) into the canonical under a clearly-marked section; inline the locator-priority table into `webapp-playwright-testing/SKILL.md`; mark the webapp-pw bundled copy with a canonical-copy header (kept for single-skill installs per OD-1); Selenium copy untouched (Java-specific) | 2 skills | Content-preservation check: canonical = old e2e ∪ MCP-unique; no content lost; copies drift-linted |
| T3.2 | **Page Object Model:** same pattern — canonical Playwright POM in `playwright-e2e-testing`; POM skeleton inlined in `webapp-playwright-testing/SKILL.md`; canonical-copy header on the bundled copy | 2 skills | Same acceptance pattern as T3.1 |
| T3.3 | **WCAG checklist:** canonical = `accessibility-selenium-testing/references/wcag21aa-checklist.md` (384 lines, complete); a11y-pw keeps its 84-line quick checklist, explicitly scoped as "quick checklist" with pointer to the canonical deep version; add WCAG 2.2 rows per OD-2 | both a11y skills | One deep checklist; quick checklist clearly scoped |
| T3.4 | Document the managed-duplication pattern (canonical + canonical-copy header + drift lint) in `docs/skill-anatomy.md` Cross-Skill References | `docs/skill-anatomy.md` | Standard matches practice |

### Phase 4 — Progressive disclosure + descriptions

| ID | Task | Files | Acceptance |
| -- | ---- | ----- | ---------- |
| T4.1 | **Classify then split:** tag each of the 22 oversized references as agent-loaded (split into focused ≤300-line files, one hop from SKILL.md) or human-consumed checklist/catalog (keep whole, add TOC). Add TOC to every reference >100 lines. Add back-link headers to all references **in the same edits** (no separate blanket pass) | per classification table produced here | No reference >300 lines unless classified human-consumed; content-preservation check per split (split-parts ∪ = original, diff-verified) |
| T4.2 | Slim `accessibility-selenium-testing` (479→~350): extract JUnit 5 test class + violation logger into `references/junit-patterns.md` | `skills/accessibility-selenium-testing/` | SKILL.md ≤ 400 lines; content preserved |
| T4.3 | Add "when to use this vs alternatives" routing block to `playwright-cli` (boundaries from T2.1) | `skills/playwright-cli/SKILL.md` | Boundary documented |
| T4.4 | **Description rewrites** (all 11): third-person WHAT + WHEN + routed NOT-for + keywords; slightly pushy per skill-creator guidance — **within a token budget: ≤600 chars max, ≤450 average across the 11** (every description rides in every session's system prompt; pushiness is not free). Each PR hunk states its char count | 11 frontmatters | Budget respected; routing evals (T4.5) improve vs T0.3 baseline |
| T4.5 | **Re-run trigger evals** on new descriptions (same harness, 3 trials/query) and compare against the T0.3 baseline; iterate on the worst skills only | eval results (temp workspace) | Held-out routing accuracy ≥ baseline +10 pts or ≥90% absolute per zone, with zero regressions on near-miss queries |

### Phase 5 — Extended-audit remediation + proposals

| ID | Task | Files | Acceptance |
| -- | ---- | ----- | ---------- |
| T5.1 | Fix T0.1 findings: pom-template version drift vs prerequisite tables; add Template File Template headers where missing; ship `setup-maven-project.sh` twin (or document Windows-only limitation in the skill) | scripts/templates per audit | Audit findings closed |
| T5.2 | **Phase 6 RFC (not in this branch):** one-page proposals for `visual-regression-testing`, `test-data-management`, `performance-testing-k6`, `contract-testing` — problem statement, draft description, why existing skills don't cover it | `docs/rfc-new-skills.md` (optional) | User picks follow-ups |
| T5.3 | Versioning note for consumers: add per-skill changelog entries to the PR description **and** a `## Changelog` section convention documented in `docs/skill-anatomy.md` (vendored copies don't see PR descriptions) | `docs/skill-anatomy.md` | Convention documented |

---

## 6. Per-Skill Work Matrix (v2 — counts corrected)

| Skill | Correctness | Red Flags | NOT-for | Verification | Back-links | Refactor >300 | Dedup role | Description | License |
| ----- | ----------- | --------- | ------- | ------------ | ---------- | ------------- | ---------- | ----------- | ------- |
| a11y-playwright-testing | T1.7, T1.8(shared) | ✔ | ✔ | has | 3 files | 2 (snippets 654, aria 587) | WCAG quick-list owner | rewrite | add |
| accessibility-selenium-testing | T1.5, T1.7 | ✔ | ✔ | has | 2 files | 2 (axe 708, wcag 384) + slim body | WCAG canonical owner | rewrite | add |
| api-testing | T1.5, T1.6 | ✔ | ✔ | has | 5 files | — | — | rewrite | add |
| grill-me-qa | — | has it | has it | **add** | 2 files | — | — | tune | add |
| playwright-cli | — | ✔ | ✔ | **add** | 10 files | 2 (test-gen 433, spec-driven 305) | boundary block | tune | has |
| playwright-e2e-testing | T1.8 | ✔ | ✔ | has | 5 files | 4 (snippets 786, pom 678, debug 525, loc 465) | canonical locators+POM | rewrite | add |
| playwright-regression-testing | — | ✔ | ✔ | has | 3 files | 1 (strategy 419) | triage route | tune | add |
| qa-manual-istqb | — | ✔ | ✔ | has | 13 files | — (all ≤248) | boundary vs planner | tune | add |
| qa-test-planner | T1.1, T1.2, T1.3, T1.9 | has | ✔ | **consolidate** | 4 files | 4 (pw-auto 514, bug 457, tc 457, regression 406) | boundary vs istqb | rewrite | has |
| webapp-playwright-testing | T1.8(shared) | ✔ | ✔ | has | 4 files | 4 (api 718, pom 592, common 472, loc 335) | inline tables + copy headers | rewrite | add |
| webapp-selenium-testing | T1.4, T1.5 | ✔ | ✔ | fix | 4 files | 3 (pom 770, waits 675, loc 414) | keeps Java refs | rewrite | add |

**Dropped from v1 (adversarial review):** persona-framing lines in 10 skills (boilerplate, violates conciseness);
qa-test-planner examples extraction (compliant + sanctioned `<details>` pattern); blanket back-link pass
(folded into T4.1 edits); hygiene work on files pending dedup decisions.

---

## 7. Risks & Mitigations

| Risk | Impact | Mitigation |
| ---- | ------ | ---------- |
| Canonical-copy drift after T3 | Med | Drift-check rule in lint CI (T0.4); canonical header states the source of truth |
| Description rewrites shift triggering | High | T0.3 baseline + T4.5 re-run on identical harness; near-miss queries are 50% of every eval set; char budget caps the system-prompt tax |
| Over-splitting references | Med | T4.1 classifies before splitting; content-preservation diff check per split |
| Scope creep into agents/ instructions/ | Med | Scope fixed: `skills/`, lint+CI, `SKILLS-INDEX.md`, evals, 3 doc touch-points |
| Lint false positives | Med | No semantic rules in v1 lint (no "Thread.sleep advocacy" checks — that is review work, not lint); YAML quote rule deferred until repo standard is unambiguous (anatomy says single quotes, its own examples disagree) |
| Eval harness non-portable across consumers | Med | Document runtime + model in eval notes; treat Copilot-style system-prompt injection as the reference runtime; results are directional, not absolute |

---

## 8. Definition of Done (follow-up implementation PRs)

- [ ] All findings F1–F6 closed; each phase lands as its own commit set
- [ ] OD-1..OD-4 signed off and recorded in §4
- [ ] `scripts/lint-skills.mjs` green on `main` **and wired into a PR workflow** (T0.4)
- [ ] Trigger evals: T4.5 thresholds met on the same harness as the T0.3 baseline
- [ ] No SKILL.md >500 lines; no agent-loaded reference >300 lines; all references back-linked
- [ ] Content-preservation diffs clean for every split/merge (T3.1, T3.2, T4.1, T4.2)
- [ ] `SKILLS-INDEX.md` merged and linked from `AGENTS.md`
- [ ] Zero broken intra-skill links (CI-verified on every PR, not once)
- [ ] Per-skill changelog in PR description + changelog convention documented (T5.3)

---

## 9. Validation Design (made falsifiable after adversarial review)

| Element | Specification |
| ------- | ------------- |
| Harness | Skill-creator trigger-eval methodology: queries presented with the skill name+description list; routing decision recorded. Reference runtime = Copilot-style system-prompt injection |
| Trials | 3 runs per query (description triggering is non-deterministic) |
| Eval set size | 3 zones × (8-10 should-trigger + 8-10 near-miss should-not-trigger) = 48-90 queries |
| Ambiguous queries | Expected routing defined in the eval JSON (authored in T0.3, user-signed) |
| Pass criterion | Held-out routing accuracy ≥90% per zone **or** ≥+10 points vs baseline; zero near-miss regressions |
| Smoke test (v1 P5.4) | Downgraded to sanity pass — n=2-3 real QA tasks, recorded model/tool, rubric = "routed to expected skill AND followed its workflow sections"; explicitly not acceptance evidence |

---

## 10. Revision Log

### v2 (this version) — after independent adversarial review (QA Automation posture)

**Verified errors corrected:** F1 Verification 10/11 → 9/11 (`grill-me-qa` also lacks it; `qa-test-planner` has
two divergent blocks → new D13); F1 Red Flags 8 → 9 missing (dropped the unsupported "arguably" hedge); F1
NOT-for 9 → 10 missing (`qa-test-planner` has zero); §6 matrix counts fixed (webapp-pw 3→4 files, planner 3→4);
P0.1 rescoped (self-contradicting Workflow 4 — new D10); P0.4 rescoped to include `api-testing` and the
a11y-selenium description; added missed defects D9 (gradle), D11 (emoji/mojibake), D12 (anatomy self-
contradiction). One adversarial claim rejected after re-verification: `@FindBy` does **not** appear in
`file-map-template.md`.

**Blind spots incorporated:** Phase 3 redesigned around OD-1 (single-skill install model — v1 violated its own
Principle 7); webapp-pw's unique MCP content preserved in T3.1; CI gate added (T0.4); scripts/templates audit
added (T0.1, T5.1); linter moved to Node (repo's existing dependency); description token budget added (T4.4);
ambiguous-query routing defined in evals (T0.3); canonical-file emoji cleanup sequenced before dedup (T1.8);
snake_case tension escalated to OD-4; consumer versioning convention added (T5.3); CI-failure-triage routing
added to boundary design (F5.5, T2.1).

**Over-scoping cut:** qa-test-planner examples extraction (P2.2 v1); persona-framing lines (P4.5 v1); blanket
back-link pass (folded into T4.1); blanket split-all-22 (now classify-first, T4.1).

**Sequencing fixed:** boundary design (T2.1) before NOT-for writing (T2.3); eval baseline (T0.3) before
description rewrites (T4.4); no hygiene on files pending dedup; T1.1 takes the cheap fix pending the
planner/istqb boundary decision.

**Validation hardened:** §9 specifies harness, trials, set sizes, ambiguous-query handling, pass criteria;
v1's unfalsifiable "≥90% routing" now has a baseline, a runtime, and a variance allowance; non-lintable rules
removed from the linter scope.

---

## Appendix A — Evidence Tables

### A.1 Reference files over the 300-line limit (22, re-verified)

snippets.md (e2e) 786 · page_object_model.md (selenium) 770 · api_testing.md (webapp-pw) 718 · axe_patterns.md (a11y-selenium) 708 · page_object_model.md (e2e) 678 · wait_strategies.md (selenium) 675 · snippets.md (a11y-pw) 654 · page_object_model.md (webapp-pw) 592 · aria_patterns.md (a11y-pw) 587 · debugging.md (e2e) 525 · playwright_automation.md (planner) 514 · common_patterns.md (webapp-pw) 472 · locator_strategies.md (e2e) 465 · bug_report_templates.md (planner) 457 · test_case_templates.md (planner) 457 · test-generation.md (cli) 433 · regression-strategy.md (regression) 419 · locator_strategies.md (selenium) 414 · regression_testing.md (planner) 406 · wcag21aa-checklist.md (a11y-selenium) 384 · locator_strategies.md (webapp-pw) 335 · spec-driven-testing.md (cli) 305

### A.2 Thin references (review during T4.1 — merge or flesh out)

`qa-manual-istqb`: defect-lifecycle.md (20), bug-report-quality.md (22), regression-suite-strategy.md (29),
automation-playwright-best-practices.md (29), test-process-and-deliverables.md (33).

### A.3 snake_case reference files (~15, per OD-4 grandfathered)

locator_strategies.md (×3) · page_object_model.md (×3) · wait_strategies.md · axe_patterns.md ·
aria_patterns.md · api_testing.md · common_patterns.md · bug_report_templates.md · test_case_templates.md ·
regression_testing.md · playwright_automation.md

### A.4 Extended audit findings (scripts/templates) — *populated by T0.1*

Pending.
