# Context Engineering Audit — Claude 5 Alignment

> **Role:** Principal AI Software Architect review.
> **Subject:** `test-automation-skills-agents` @ commit `2149484` (branch `chore/skills-qa-automation-v3`).
> **Baseline:** Anthropic — *"The new rules of context engineering for Claude 5 generation models"* + *"Effective context engineering for AI agents"* + *Agent Skills* (engineering blog + platform docs best-practices).
> **Date:** 2026-07-30.
> **Branch produced by this audit:** `chore/ce-audit-claude5` (from `main`).

---

## Legend: claim type

Throughout this document each substantive claim is tagged so the reader can weigh it:

- **[FACT]** — directly observed in the repository or in an Anthropic source (cited).
- **[INFER]** — derived from observed facts via reasoning.
- **[OPINION]** — architect's judgment, not provable from evidence alone.
- **[REC]** — a recommendation (directional; see Roadmap for the concrete plan).

---

## 1. Executive Summary

The repository is **genuinely strong**. At commit `2149484` it already implements the **single most important Claude 5 context-engineering principle — progressive disclosure — across 9 skills**: every skill has a lean `SKILL.md` body plus a `references/` tree loaded on demand. This is exactly the *"well-organized manual that starts with a table of contents"* pattern Anthropic recommends. No skill exceeds 500 lines; the median is ~236. Two skills (`api-testing`, `playwright-regression-testing`) are textbook models of the lean-index ideal. **[FACT]**

However, the repo **preaches context engineering without consistently applying it to its own scaffolding**. The gaps cluster into four themes:

1. **Memory & workspace files are bloated.** `CLAUDE.md` (105 lines) and `AGENTS.md` (222 lines) re-teach orchestration patterns, locator tables, and domain rules that already live in skills/docs — the opposite of Anthropic's *"lightweight, gotchas-only, removed 80% of the system prompt with no loss"* guidance. **[FACT]**
2. **Authoring knowledge is fragmented across 6 files (~2,098 lines)** with frontmatter rules, progressive-loading, resource-types, and naming each repeated 3–4×. **[FACT]**
3. **Agents are over-constrained with copy-pasted "Constitutions."** The Test Orchestration Pattern (TOP) Constitution is repeated in 6 agents, with proven leakage — e.g. `api-tester-specialist` carries *"NEVER use XPath selectors (irrelevant for API but inherited from Constitution — skip if N/A)"*. This is the textbook anti-pattern Anthropic names: *"rigid, absolute constraints to avoid worst-case scenarios."* **[FACT]**
4. **Two internal contradictions** undermine the docs' credibility: *"Common Rationalizations"* is marked **Removed** in the canonical `skill-anatomy.md` but still **mandated** in `writing-principles.md` and exemplified in `example-skill-template.md`; and the "instructions should be 30–60 lines" rule is violated by `selenium-webdriver-java` (607) and `cicd-testing` (222). **[FACT]**

**Critical caveat (the most important paragraph in this document).** The repository is **explicitly tool-agnostic but optimized for GitHub Copilot** (per `AGENTS.md`), while the *new* context-engineering rules apply principally to **Claude 5**. The strongest guidance — *"remove rigid rules, trust the model's judgment, delete 80% of the prompt"* — is calibrated to Claude Opus/Sonnet 5-class models. Copilot's model layer is heterogeneous and historically benefits *more* from explicit constraints. **Therefore this audit treats the "reduce over-constraining" recommendations as CONDITIONAL on target model:** high-confidence for Claude-targeted consumption; apply with judgment for Copilot-primary consumption (see §6, Gap G-04, and the Adversarial Review §6). **[INFER]**

**Net assessment.** Of the 10 gaps found, **2 are Critical** (both are correctness/contradiction defects, not philosophy debates), **4 are High** (token-efficiency / DRY-of-prompt wins with clear Anthropic backing), and **4 are Medium/Low**. The repo is ~70% aligned with Claude 5 CE principles; the roadmap can take it to ~90% in 4 small PRs without breaking the public skill/agent contract.

---

## 2. Research: Context Engineering Principles (Anthropic)

Sources studied (primary unless noted):

- **[S1]** *"The new rules of context engineering for Claude 5 generation models"* — `claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models`
- **[S2]** *"Effective context engineering for AI agents"* — `anthropic.com/engineering/effective-context-engineering-for-ai-agents`
- **[S3]** *"Equipping agents for the real world with Agent Skills"* — `anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills`
- **[S4]** *Agent Skills — Best Practices* — `platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices`
- **[S5]** *Agent Skills — Overview* — `platform.claude.com/docs/en/agents-and-tools/agent-skills/overview`
- **[S6]** *Claude Code — Memory* — `code.claude.com/docs/en/memory`

### 2.1 The six paradigm shifts for Claude 5 [S1]

| # | Then (anti-pattern) | Now (best practice) |
|---|---|---|
| 1 | Rigid absolute rules to avoid worst cases | Let the model use context + its own judgment; *"write code that reads like the surrounding code"* |
| 2 | Tool-usage examples in the prompt (constrains exploration) | Design expressive tool interfaces (params, enums); keep usage in tool descriptions |
| 3 | Upfront-load everything in the system prompt | **Progressive disclosure** — load the right context at the right time; move workflows into skills |
| 4 | Repeat instructions in system prompt AND tool descriptions | Put tool instructions in tool descriptions only; remove duplicate examples |
| 5 | Manual memory (user hits `#` to save) | Auto-memory: the model saves relevant context itself |
| 6 | Simple markdown specs only | Rich references (HTML artifacts, **code files** as high-fidelity references, rubrics) |

Headline result Anthropic reports: **"removed over 80% of Claude Code's system prompt with no loss in coding-eval performance."** [S1]

### 2.2 The four context-engineering techniques [S2]

1. **Writing context** — system prompt, tools, examples. Find the *Goldilocks altitude*: specific enough to guide, flexible enough to be a heuristic. Use XML/Markdown delimiters. Curate a **minimal viable set of tools** — *"if a human can't say which tool to use, the AI can't either."* Examples are *"pictures worth a thousand words"* — prefer diverse canonical examples over endless edge-case rules.
2. **Selecting context (just-in-time / agentic search)** — maintain lightweight identifiers (paths, links), use **metadata as context** (folder hierarchy, naming, timestamps), and **progressive disclosure**. Hybrid strategy: pre-load cheap data, explore autonomously for the rest.
3. **Compressing context** — auto-compact, **clear tool results** once consumed (*"why see the raw result again?"*), tune compaction prompts (maximize recall first, then improve precision).
4. **Isolating context** — **sub-agents** with clean windows that *"explore tens of thousands of tokens but return only a distilled summary"*; **structured note-taking** (`NOTES.md`, to-do lists) externalized outside the context window for multi-hour state recovery.

Core law [S2]: *"finding the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."*

### 2.3 Agent Skills architecture [S3][S4][S5]

- **Progressive disclosure is THE core design principle.** Analogy: *"a well-organized manual: table of contents → chapters → detailed appendix."* [S3]
- **Three tiers of loading:** Level 1 = frontmatter name+description only (injected into system prompt at startup); Level 2 = `SKILL.md` body read on demand; Level 3+ = bundled reference files discovered as needed. Because of this, *"context is effectively unbounded."* [S3]
- **`SKILL.md` is a lean index**, not a tutorial. *"When SKILL.md becomes unwieldy, split its content into separate files and reference them."* Segregate mutually-exclusive content to cut tokens. [S3]
- **Concrete limits [S4]:** body **< 500 lines**; name **≤ 64 chars**; description **≤ 1024 chars**, non-empty, **third person** (first/second person breaks discovery).
- **References one level deep** from `SKILL.md`; for refs > 100 lines, include a table of contents at the top. [S4]
- **Bundled scripts** are both executable tools and reference docs — *"make it clear whether Claude should run them or read them."* [S4]
- **Do:** forward slashes in paths, descriptive filenames. **Don't:** vague names (`helper`/`utils`/`tools`), time-sensitive content, assuming packages are installed, deferring script errors to the model. [S4]

### 2.4 Memory files (CLAUDE.md) [S1][S6]

- Keep **lightweight and brief**; describe repo purpose + **gotchas the model can't infer from the filesystem**.
- Avoid stating the obvious. Focus tokens on *"gotchas inside the codebase"* (e.g. types kept in one monolithic file).
- Use modular prompts: if you have complex verification logic, **create a skill and reference it** rather than inlining.
- When a memory file nears its limit: *"one line per entry, move detail into topic files, merge or drop stale entries."* [S6]

### 2.5 Principles applied as the audit yardstick

From the above, the audit scores the repo against **ten operative principles (P1–P10)**:

| ID | Principle | Source |
|---|---|---|
| P1 | Progressive disclosure (lean index + on-demand references) | S1, S3, S4 |
| P2 | Memory/workspace files lightweight & gotchas-only | S1, S6 |
| P3 | Minimal viable tool set; usage lives in tool descriptions | S2 |
| P4 | Single source of truth; no duplicated instructions (DRY-of-prompt) | S1 (shift #4) |
| P5 | Trust model judgment; avoid rigid absolute rules | S1 (shift #1) |
| P6 | Few-shot examples > edge-case rule lists | S2 |
| P7 | Context isolation via sub-agents / structured notes | S2 |
| P8 | Authoring docs themselves obey progressive disclosure (don't bloat the *meta*-layer) | S1, S4 |
| P9 | Consistency: docs must not contradict the canonical standard | (inference from S1/S4) |
| P9b | No stale planning artifacts in the live tree | (inference from P2) |
| P10 | Rich/code references preferred over prose | S1 (shift #6), S4 |

---

## 3. Repository Evaluation

**Shape at `2149484` [FACT]:** 166 files; 137 Markdown. 9 skills, 7 agents, 3 instructions, 6 authoring/reference docs, 4 enhancement-plan logs, root `AGENTS.md` + `CLAUDE.md` + `README.md` (488 lines), 1 linter (`scripts/lint-skills.mjs`, 299 lines) wired to a GitHub Actions workflow.

### 3.1 What the repo does well [FACT]

- **P1 (progressive disclosure) is implemented at the skill layer.** All 9 skills use a `SKILL.md` + `references/` tree; 6 of 9 also carry `templates/` or `scripts/`. Median skill body ≈ 236 lines; **none exceed the 500-line limit.** `api-testing` (134) and `playwright-regression-testing` (82) are exemplars.
- **P1 Level-1 trigger surface is strong.** 8 of 9 skills carry a rich `description` stating WHAT + WHEN + a keywords clause for matching. `accessibility-selenium-testing` is best-in-class.
- **P10 (rich/code references) is practiced.** Skills ship executable scripts (`AccessibilityHelper.java`, `pom-template.xml`, `qa_artifacts.mjs`, `setup-maven-project.ps1`, `api-health-check.sh`) and real template files (`.ts`, `.java`, `.csv`, `.html`) — exactly the *"code as high-fidelity reference"* guidance.
- **P7 (context isolation) is structurally present** in the agent layer: a `qa-orchestrator` delegates to specialists, mirroring the sub-agent pattern.
- **"Do NOT Use For" cross-routing** in every skill is deliberate, beneficial Level-1 disambiguation — *not* duplication to fix.

### 3.2 Where the repo diverges from the principles

Findings are consolidated into the Gap Analysis (§5). Headline divergences:

- **P2 violated** — `CLAUDE.md` (105 lines) and `AGENTS.md` (222 lines) re-teach domain/orchestration content. **[FACT]**
- **P4 violated** — the TOP Constitution is repeated across 6 agents; the Playwright locator-priority table is duplicated 3–4×. **[FACT]**
- **P5 violated** — pervasive `NEVER`/`NON-NEGOTIABLE` Constitutions (40+ absolute rules total) with proven copy-paste leakage. **[FACT]**
- **P8 violated** — authoring guidance fragmented across 6 files (~2,098 lines) with key rules repeated 3–4×. **[FACT]**
- **P9 violated** — *Common Rationalizations* simultaneously "Removed" and "mandated." **[FACT]**
- **P9b violated** — 4 completed enhancement-plan logs (899 lines) live in the tree. **[FACT]**

---

## 4. Methodology Note — How this audit used context engineering on itself

To keep this document high-signal, the analysis itself followed Anthropic's **context isolation** principle [S2]: three specialized sub-agents analyzed disjoint slices of the repo (skills / agents / docs) in isolated windows and returned **distilled summaries with file:line evidence**, rather than flooding the main context with raw file dumps. The headline facts cited below (e.g. the XPath-leakage line, the 5× Thread.sleep repetition, the Common-Rationalizations contradiction) were **independently re-verified** against `git show 2149484:<path>` before being asserted as **[FACT]**. [INFER on method; FACT on verification]

---

## 5. Gap Analysis

Priority legend: **Critical** = correctness/contract defect or direct contradiction. **High** = clear Anthropic backing + material token/behavior impact. **Medium** = worthwhile, some judgment. **Low** = polish.

| ID | Anthropic recommendation | Principle | Current state | Gap | Impact | Priority | Effort | Risk | Benefit |
|---|---|---|---|---|---|---|---|---|---|
| **G-01** | Docs must not contradict the canonical standard (P9) | P9 | `skill-anatomy.md:122` & `:374` mark `## Common Rationalizations` **Removed**; `writing-principles.md:9` **mandates** it; `example-skill-template.md:77` contains a live example | Three files disagree on whether a required section exists | Authors following docs produce *non-conforming* skills; trust erosion | **Critical** | S (~30 min) | Low | Removes a live contradiction; single source of truth |
| **G-02** | No duplicated instructions; trust model judgment (P4, P5) | P4, P5 | TOP Constitution copy-pasted into 6 agents; `api-tester-specialist` carries *"NEVER use XPath selectors (irrelevant for API but inherited from Constitution — skip if N/A)"* (proof of blind inheritance); 40+ absolute `NEVER` rules total | Same rule repeated across orchestrator + each agent; leakage of inapplicable rules | Wasted tokens every delegation; contradictory guidance; brittle | **Critical** | M (centralize) | Med (behavior change — see Breaking Changes) | ~hundreds of lines removed; behavior expressed once |
| **G-03** | Memory/workspace files lightweight & gotchas-only (P2) | P2 | `CLAUDE.md` (105 lines) re-teaches orchestration + locator tables; `AGENTS.md` (222 lines) inlines frontmatter/formatting rules duplicated in `docs/` | Always-loaded files carry content that belongs in on-demand skills | Highest token cost — these load at session start on *every* task | **High** | S–M | Low–Med | Largest single token reduction in the repo |
| **G-04** | Avoid rigid absolute rules; trust judgment (P5) | P5 | Agents open Constitutions with *"NON-NEGOTIABLE"* and stack `NEVER`s; `selenium-test-specialist` repeats `Thread.sleep` prohibition **~5×** in one file | Over-constraining; same prohibition stated multiple times | Conditional on target model — see caveat. For Claude 5: reduces brittleness; for Copilot: may need retention | **High** | M | Med | Leaner, judgment-based prompts |
| **G-05** | Single source of truth for shared doctrine (P4) | P4 | Playwright locator-priority table duplicated in `playwright-e2e-testing/SKILL.md`, its `references/locator-strategies-priority.md`, `playwright-regression-testing/references/regression-best-practices.md`, and prose-restated in `qa-manual-istqb` | 3–4 copies of one table | Drift risk; edits fix one copy | **High** | S | Low | One canonical table, pointers elsewhere |
| **G-06** | Authoring docs obey progressive disclosure (P8) | P8 | 6 authoring files (~2,098 lines): frontmatter rules ×4, progressive-loading ×6, resource-types ×4, naming ×4. `authoring-agents.md` (1066) is ~60% generic Copilot feature docs | Meta-layer is bloated & fragmented | Authors can't find the canonical rule; high maintenance load | **High** | M–L | Med | One source for skill-authoring, one for agent-authoring |
| **G-07** | Instructions lean; defer depth to skills (P2, P8) | P2, P8 | `selenium-webdriver-java.instructions.md` (607) & `cicd-testing` (222) violate the repo's own "30–60 line" rule (`CLAUDE.md:95-99`); `playwright-typescript` (29) is the correct model | Two always-on instructions carry full tutorials/templates | Always-loaded token bloat + contradicts stated philosophy | **High** | M | Med | Instructions become true lean essentials |
| **G-08** | No stale planning artifacts in live tree (P9b) | P9b | 4 completed enhancement-plan logs (899 lines) in `docs/enhancements/`, marketed as "future improvements" but retrospective | Stale history in the active tree | Mild context noise; misleading labels | **Medium** | S | Low | Cleaner tree; accurate labeling |
| **G-09** | `SKILL.md` is a lean index, not a tutorial (P1) | P1 | `playwright-e2e-testing` (302) & `a11y-playwright-testing` (294) retain full inline code blocks that duplicate their own `snippets-*` references; `webapp-selenium-testing` frontmatter **lacks a keywords clause** (8/9 have one) | Two skills are mini-tutorials; one frontmatter inconsistent | Uneven progressive disclosure; weaker discovery for one skill | **Medium** | S | Low | Bodies become true indexes; consistent Level-1 surface |
| **G-10** | Linter thresholds match official limits; don't over-constrain (P5, P8) | P5, P8 | `lint-skills.mjs` S4 (description ≤600) & S5 (body ≤500) & S7 (mandatory back-link header) are hard **ERROR**s; Anthropic's description cap is 1024; S7 is cosmetic | Arbitrary hard errors tighter than official limits | Blocks valid skills; cosmetic compliance overhead | **Low** | S | Low | Linter aligns with official limits; fewer false failures |

---

## 6. Adversarial Review

*Second pass. I assume the role of a maximally critical reviewer and challenge the primary analysis. Where I change my mind, I say so.*

### 6.1 "Reduce over-constraining" may be WRONG for this repo's primary consumer

**Challenge (G-04).** The primary analysis accepts Anthropic's "trust the model, delete the rules" guidance. But `AGENTS.md` declares this repo **tool-agnostic, optimized for GitHub Copilot**. Anthropic's 80%-cut result is specific to **Claude Opus/Sonnet 5-class judgment**. Copilot's model layer is heterogeneous; for weaker or non-Claude models, explicit `NEVER` rules and Constitutions are a **legitimate hedge**, not an anti-pattern.

**Revised position.** I partially agree with the challenger. The recommendation should be **conditional**:
- For **Claude-targeted consumption**: apply G-04 fully (convert `NEVER` lists to 2–3 heuristics).
- For **Copilot-primary consumption**: keep a *slim* Constitution but **eliminate pure duplication** (G-02) and **fix the leakage** — these hold regardless of model.
- **Net:** G-02 stays Critical (duplication/leakage is wrong under any model); G-04 is downgraded from "High-universal" to **"High-if-Claude, Medium-if-Copilot."** This nuance was missing from the primary analysis. *(I changed my mind.)* **[INFER]**

### 6.2 "Centralize the Constitution" could break a real coordination pattern

**Challenge (G-02).** The primary analysis recommends centralizing the TOP Constitution in `qa-orchestrator` and deleting per-agent copies. Risk: the orchestrator's handoff prompt is the *only* mechanism that would carry the rules downstream — and **handoff context does not always survive** across all tools/runtimes (handoffs are a VS Code 1.106+ Copilot feature per `AGENTS.md`; other consumers may not honor them). Deleting per-agent copies could leave worker agents with **no constitution at all** on non-Copilot runtimes.

**Revised position.** Valid concern. The migration must be **staged and tool-aware**:
- Phase 1: **deduplicate within each agent** (remove the second `## Guidelines and Constraints` Must/Must-Not pair; collapse the 5× Thread.sleep to once) — zero risk, pure win.
- Phase 2: centralize **only if** a reliable context-passing mechanism exists for the target runtime; otherwise keep a *single canonical block* referenced by path (`See agents/qa-orchestrator.agent.md → Constitution`) rather than fully deleted.
- **Net:** the *end state* of G-02 is right, but the *migration* must preserve a fallback. I add this as a Breaking-Change migration note. **[INFER]**

### 6.3 `webapp-selenium-testing` missing-keywords may be intentional

**Challenge (G-09).** The "missing keywords" finding assumes parity is required. But the description is otherwise descriptive; and skill discovery in some runtimes matches on the body too, not just frontmatter. Is this a real gap or pedantry?

**Verdict.** It is a **real but Low** gap, not Medium. Consistency across the Level-1 surface matters for predictable discovery, and it's a 2-minute fix — but it is not architecturally significant. I keep it but it does **not** belong in the "High" tier. *(Minor revision.)* **[INFER]**

### 6.4 The 500-line / 1024-char limits — are we sure S4 is authoritative here?

**Challenge (G-10).** The linter enforces 600-char descriptions and 500-line bodies. The primary analysis cites S4's 1024-char official cap. But this repo also targets **Agent Skills Specification** (`agentskills.io`) and GitHub Copilot, whose limits may differ. Over-tightening might be deliberate portability hedging.

**Verdict.** Partially valid. 500-line is Anthropic's *own* stated optimum, so S5 as a hard error is defensible — **keep it.** But 600-char description is **tighter than Anthropic's 1024** with no cited reason, and S7 (mandatory back-link header) is cosmetic. I narrow G-10 to: relax S4 to 1024 (or document why 600); make S7 a **WARN**, not ERROR. S5 stays. *(Narrowed.)* **[INFER]**

### 6.5 Is `README.md` (488 lines) really a problem?

**Challenge.** A README is a *human* artifact, not context the model loads. Trimming it saves zero model tokens. Why is it in scope?

**Verdict.** The challenger is **mostly right.** README bloat is a **DX/maintainability** issue, not a context-engineering issue. I **drop README trimming from the CE gap list** (it appeared only lightly in §3). It remains a minor DX note in the Roadmap, explicitly labeled non-CE. *(Removed from CE scope.)* **[INFER]**

### 6.6 Did the primary analysis over-count "duplication"?

**Challenge.** Some "duplicates" are legitimate language parallelism: the Playwright vs Selenium POM basics legitimately share a *conceptual scaffold* (benefits table) but differ in language specifics. Calling that "duplication" overstates the case.

**Verdict.** Agreed for the **POM scaffold** — that is defensible parallelism, keep it. But the **verbatim locator-priority table** (identical rows, identical text across 3 files) is true duplication — G-05 stands. I sharpen G-05 to target only *verbatim* copies, not conceptual parallels. *(Sharpened.)* **[INFER]**

---

## 7. Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Centralizing Constitution leaves workers unguarded on non-Copilot runtimes | Med | High | Stage migration; keep path-reference fallback (§6.2) |
| Trimming agent rules degrades Copilot (non-Claude) behavior | Med | Med | Conditional application of G-04 (§6.1) |
| Doc consolidation breaks inbound links / bookmarks to `authoring-agents.md` etc. | Med | Low | Keep moved files as thin redirect stubs for one release |
| `lint` relaxation lets an oversized skill slip in | Low | Low | Keep S5 as hard error; only relax S4/S7 (§6.4) |
| Removing `docs/enhancements/*` loses audit trail | Low | Low | Move to a git tag / `docs/archive/` rather than delete |
| Over-trimming `CLAUDE.md` loses a genuine gotcha | Low | Med | Keep a "gotchas" allow-list; only remove inferable/teaching content |

---

## 8. Opportunities

Ranked by leverage (CE impact × confidence):

1. **Make the memory layer actually lightweight (G-03).** Biggest token win in the repo; always-loaded files are the most expensive tokens. **[REC]**
2. **Fix the live contradiction (G-01).** A 30-minute fix that restores doc credibility and unblocks consistent authoring. **[REC]**
3. **Establish a single shared-doctrine source (G-05, G-02 Phase 1).** Locator table + Constitution dedup removes drift risk permanently. **[REC]**
4. **Make the meta-layer walk its own talk (G-06, G-07).** Consolidating authoring docs and slimming the two fat instructions aligns the repo with its *own stated* philosophy. **[REC]**
5. **Model-conditional agent slimming (G-04).** Convert `NEVER` stacks to heuristics *where the target is Claude 5*; document the Copilot fallback. **[REC, conditional]**
6. **Even out the skill index discipline (G-09).** Two skills to lean-index form; one frontmatter fix. **[REC]**

---

## 9. Roadmap (phased, PR-sized)

Each phase is independently mergeable. Acceptance criteria are testable without a model eval (behavioral claims are flagged as **[needs-eval]**).

### Phase 0 — Quick Wins (same day, 1 PR)

**Objective:** remove contradictions & stale artifacts; zero behavioral risk.
**Changes:** Resolve G-01 (Common Rationalizations) by deleting the mandate in `writing-principles.md:9` and the example in `example-skill-template.md:77-79`, aligning both to `skill-anatomy.md`. Archive `docs/enhancements/*` → `docs/archive/enhancements/` (G-08). Add the missing keywords clause to `webapp-selenium-testing` frontmatter (G-09 partial). Fix the stale "7 instructions" count → "3".
**Files:** `docs/references/writing-principles.md`, `docs/references/example-skill-template.md`, `docs/enhancements/*` (move), `skills/webapp-selenium-testing/SKILL.md`, `README.md`, `docs/getting-started.md`.
**Priority:** Critical/High. **Dependencies:** none. **Risk:** Low. **Effort:** ~30–45 min. **Acceptance:** `grep -ri "common rationalization"` returns only the `skill-anatomy.md` "Removed" note; archived folder exists; lint passes.

### Phase 1 — Memory & workspace slimming (1 PR)

**Objective:** cut the highest-cost tokens (P2).
**Changes:** Reduce `CLAUDE.md` to ~20–30 lines: repo purpose + pointers to `AGENTS.md`/skills + 2–3 genuine gotchas only. Remove orchestration pattern and locator tables (they live in `docs/references/authoring-agents.md` and the skills). Trim `AGENTS.md` to gotchas + a *pointer* to the consolidated authoring doc (created in Phase 2), removing the inlined frontmatter/formatting tables duplicated in `docs/`.
**Files:** `CLAUDE.md`, `AGENTS.md`.
**Priority:** High. **Dependencies:** none (Phase 2 can follow). **Risk:** Low–Med. **Effort:** ~2–3 h. **Acceptance:** `CLAUDE.md` < 35 lines; no domain locator tables remain in it; `AGENTS.md` < 120 lines with no verbatim duplicate of `docs/` tables. **[needs-eval]** spot-check that the model still locates skills correctly.

### Phase 2 — Meta-layer consolidation (1 PR)

**Objective:** single source of truth for authoring (P8).
**Changes:** Merge the 6 authoring files into **two**: a canonical `docs/authoring-skills.md` (absorbing `skill-anatomy.md`, `authoring-skills.md`, `section-details-guide.md`, `example-skill-template.md`, `writing-principles.md`) and a lean `docs/authoring-agents.md` (cutting the 1066-line generic Copilot feature docs down to repo-specific guidance + a link to the official Copilot docs). Leave redirect stubs at old paths for one release.
**Files:** `docs/skill-anatomy.md`, `docs/references/authoring-*.md`, `docs/references/section-details-guide.md`, `docs/references/example-skill-template.md`, `docs/references/writing-principles.md`.
**Priority:** High. **Dependencies:** Phase 0 (contradiction resolved). **Risk:** Med (inbound links). **Effort:** ~4–6 h. **Acceptance:** one file defines each rule (frontmatter, progressive-loading, resource-types, naming each appear exactly once); old paths redirect; lint passes.

### Phase 3 — Shared-doctrine & instruction slimming (1 PR)

**Objective:** eliminate verbatim duplication; lean instructions (P4, P2/P8).
**Changes:**
- Locator table: keep `references/locator-strategies-priority.md` as the single source; replace the verbatim copies in `playwright-e2e-testing/SKILL.md` and `playwright-regression-testing/references/regression-best-practices.md` with pointers (G-05).
- Slim `selenium-webdriver-java.instructions.md` (607→≤60) and `cicd-testing.instructions.md` (222→≤60) to lean essentials that **defer** to the skills, matching the `playwright-typescript` (29-line) model (G-07).
**Files:** the two instruction files; `skills/playwright-e2e-testing/SKILL.md`; `skills/playwright-regression-testing/references/regression-best-practices.md`.
**Priority:** High. **Dependencies:** none. **Risk:** Med (instruction behavior). **Effort:** ~3–4 h. **Acceptance:** each instruction ≤60 lines; locator table exists in exactly one file. **[needs-eval]** instruction-driven test generation still correct.

### Phase 4 — Agent de-constraining (conditional, 1 PR)

**Objective:** trust model judgment where appropriate (P5) — **only if Claude-targeted** (§6.1).
**Changes:** Phase 4a (always): within each agent, dedupe the second `## Guidelines and Constraints` Must/Must-Not pair and collapse intra-file repetition (e.g. the 5× `Thread.sleep` in `selenium-test-specialist`) to a single statement; trim `test-refactor-specialist` (606) tutorial code to examples-only. Phase 4b (Claude-targeted only): convert the `NEVER`/`NON-NEGOTIABLE` Constitution lists to 2–3 affirmative heuristics; centralize TOP per §6.2 (path-reference fallback, not full deletion).
**Files:** all `agents/*.agent.md`.
**Priority:** High-if-Claude / Medium-if-Copilot. **Dependencies:** Phase 3. **Risk:** Med. **Effort:** ~4–6 h. **Acceptance:** no agent restates the same prohibition >1×; no agent carries an inapplicable rule (the XPath-API leak is gone); total agent-line count ↓ ≥30%. **[needs-eval]** delegation/handoff still produces conforming tests.

### Phase 5 — Linter & skill-index polish (1 PR)

**Objective:** align tooling with official limits; finish progressive-disclosure parity (P1, P5).
**Changes:** Relax `lint-skills.mjs` S4 to 1024 (or document the 600 rationale); demote S7 (back-link header) from ERROR to WARN; keep S5 (G-10). Move the inline tutorial code blocks out of `playwright-e2e-testing/SKILL.md` and `a11y-playwright-testing/SKILL.md` into their existing `snippets-*` references so the bodies become true indexes (G-09).
**Files:** `scripts/lint-skills.mjs`; the two skills' `SKILL.md` + references.
**Priority:** Medium/Low. **Dependencies:** none. **Risk:** Low. **Effort:** ~2–3 h. **Acceptance:** lint passes; both skill bodies now read as indexes (pointer-heavy, code-light); no skill >500 lines.

---

## 10. Quick Wins (< 30 min each, by impact)

1. **Resolve the Common Rationalizations contradiction (G-01).** Delete mandate + example; align to `skill-anatomy.md`. *Highest credibility fix per minute.* **[REC]**
2. **Add keywords to `webapp-selenium-testing` frontmatter (G-09).** 2 minutes; restores Level-1 parity.
3. **Fix the "7 instructions" stale count → "3"** in `README.md` and `getting-started.md`.
4. **Archive `docs/enhancements/*` (G-08).** One `git mv`; removes 899 stale lines from the live tree.
5. **Replace the verbatim locator-table copies with pointers (G-05 partial).** Fast, removes drift risk.

---

## 11. Breaking Changes & Migration

| Change | Breaks what? | Migration strategy |
|---|---|---|
| **Centralize TOP Constitution / remove per-agent copies (G-02, Phase 4b)** | Downstream consumers that rely on each `.agent.md` being self-contained; non-Copilot runtimes where handoff context doesn't propagate | **(a)** Ship Phase 4a (intra-file dedup) first — no breakage. **(b)** For 4b, keep a **path-reference** (`See agents/qa-orchestrator.agent.md → Constitution`) instead of deleting outright, so workers can still load it. **(c)** Document in CHANGELOG that self-contained agent files now require the orchestrator Constitution to be in scope. |
| **Relocate authoring docs (G-06, Phase 2)** | Inbound links/bookmarks to `authoring-agents.md`, `skill-anatomy.md`, etc. | Leave **redirect stubs** at old paths for one release ("Moved to `docs/authoring-skills.md`"), then remove. |
| **Trim agent rules (G-04, Phase 4b)** | Copilot/non-Claude behavior may rely on explicit `NEVER`s | **Conditional rollout**: keep slim Constitution for Copilot-primary; full heuristic-conversion only behind a Claude-targeted flag/profile. |
| **Slim instructions (G-07, Phase 3)** | Users who copy from instruction files directly | Move removed content into the corresponding skill's `references/` (not deleted), and have the instruction link to it. |
| **Archive `docs/enhancements/*` (Phase 0)** | Any link referencing those paths | Use `docs/archive/enhancements/` (path-preserving suffix) and update the one `README.md` pointer. |

**Public skill/agent contract is NOT broken** by Phases 0–3 and 5: skill folders, `SKILL.md`, frontmatter shape, and agent filenames/`description`s remain stable. Only Phase 4b touches agent *body* semantics, and only conditionally.

---

## 12. Final Recommendations

1. **Do Phase 0 today.** It is pure correctness, zero risk, and removes a live contradiction plus 899 lines of stale history. **[REC]**
2. **Treat `CLAUDE.md`/`AGENTS.md` (Phase 1) as the highest-leverage CE win**, because always-loaded tokens are the most expensive. **[REC]**
3. **Centralize shared doctrine (locator table, Constitution) but migrate with a fallback** — the end state is right; the path must not strand worker agents on non-Copilot runtimes. **[REC]**
4. **Make the meta-layer obey its own rules (Phase 2).** A repo that *teaches* context engineering must *apply* it to its own authoring docs. **[REC]**
5. **Apply the "trust the model" guidance conditionally**, keyed to the target runtime (Claude 5 vs Copilot). Do not cargo-cult Anthropic's 80%-cut into a context where the model layer is heterogeneous. **[REC]**
6. **Keep the linter, but align its hard-errors to Anthropic's official limits** (description ≤1024, body ≤500) and demote cosmetic rules to WARN. **[REC]**

---

## 13. Next Steps

1. Review this audit on branch `chore/ce-audit-claude5`.
2. Confirm the **target-model assumption** (Claude 5 vs Copilot-primary) — it gates Phase 4b and G-04 severity. *(See clarifying question.)*
3. Merge Phase 0 as a standalone PR; then sequence Phases 1→2→3.
4. Decide Phase 4 scope (4a always; 4b conditional) based on the model-target decision.
5. For every phase carrying a **[needs-eval]** tag, run a small before/after sample (e.g., generate one Playwright spec, one Selenium page object) to confirm no behavioral regression before merging.

---

## Sources

Primary (Anthropic official):
- [The new rules of context engineering for Claude 5 generation models](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models)
- [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Agent Skills — Best Practices (platform docs)](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Agent Skills — Overview (platform docs)](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Claude Code — Memory](https://code.claude.com/docs/en/memory)

Repository evidence (all at commit `2149484`, verified via `git show`):
- `AGENTS.md` (222 lines), `CLAUDE.md` (105 lines), `README.md` (488 lines)
- `docs/skill-anatomy.md:122,:374` (Common Rationalizations — Removed)
- `docs/references/writing-principles.md:9` (Common Rationalizations — mandated)
- `docs/references/example-skill-template.md:77` (Common Rationalizations — exemplified)
- `agents/api-tester-specialist.agent.md` (XPath-leakage line; duplicate Must/Must-Not)
- `agents/selenium-test-specialist.agent.md` (5× `Thread.sleep` repetition; L17/82/91/232/262)
- `agents/qa-orchestrator.agent.md:46-62,:95` (canonical Constitution + context-passing template)
- `agents/test-refactor-specialist.agent.md` (606 lines)
- `skills/*` line counts and locator-table duplication (cross-verified)
- `scripts/lint-skills.mjs` (S4/S5/S7 rules)
