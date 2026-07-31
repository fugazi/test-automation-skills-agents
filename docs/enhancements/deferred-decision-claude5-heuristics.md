# Deferred Decision: Convert Agent Constitutions to Claude 5 Heuristics

> **Status:** Deferred · **Decided:** 2026-07-31 (v4.0.0 release) · **Owner:** Douglas Fugazi
> **Type:** Architectural decision record (follow-up candidate)

## Context

During the Claude 5 context-engineering alignment (v4.0.0), the repo implemented Anthropic's *"new rules"* with one principle applied **conditionally** rather than fully:

> **Anthropic Rule #1 — "Rules → Judgment":** *"Eliminate rigid, absolute rules; let the model use its judgment."* Anthropic removed over 80% of Claude Code's system prompt with no loss in coding-eval performance.

This rule is **calibrated to Claude 5-class models** (Opus/Sonnet 5), which have strong inherent judgment and need fewer explicit constraints.

## The decision taken in v4.0.0

The 7 agents **retain slim Constitutions** (`MUST DO` / `WON'T DO` with `NEVER` rules) rather than being converted to open-ended 2–3-line heuristics. What *was* removed (the universal anti-patterns):

- **Constitution duplication** — the TOP Constitution was copy-pasted across 6 agents.
- **Rule leakage** — e.g., `api-tester-specialist` carried *"NEVER use XPath selectors (irrelevant for API but inherited from Constitution)"*.
- **Intra-file repetition** — the `Thread.sleep` prohibition appeared ~5× in one file.

What was **kept**: the per-agent slim Constitution itself (~5–9 rules each).

## Why it was deferred

The repo is declared **genuinely multi-model** (Claude 5, GPT-Sol, GLM-5.2, and others) — confirmed by the maintainer on 2026-07-31. For models with **more variable judgment**, explicit `NEVER` rules are a **legitimate hedge**, not an anti-pattern. Applying Anthropic's "delete the rules" guidance literally to a heterogeneous model layer would be cargo-culting a recommendation outside its calibration range.

The conservative approach (dedup + fix leakage, but keep slim Constitutions) is correct **for the current multi-model positioning**.

## When to revisit this (~15% additional alignment)

This decision should be revisited **if and only if** the consumption pattern shifts toward Claude 5 being the dominant/primary model. Triggers to watch for:

1. **Claude 5 becomes the de-facto primary consumer** (e.g., >70% of usage, or the repo is repositioned as Claude-Code-first).
2. **Empirical evidence** that the current `NEVER` rules cause over-constraining or brittle behavior with Claude 5 (e.g., the model refuses reasonable actions, or follows the letter while violating the spirit).
3. **A controlled before/after eval** showing that heuristic-based agents perform equal-or-better on Claude 5 with no regression on other models.

## What "Phase 4b" would entail (the deferred work)

If revisited, the work is:

- **Phase 4b (Claude-targeted only):** convert each agent's `NEVER` / `NON-NEGOTIABLE` Constitution lists into 2–3 affirmative heuristics (e.g., *"prefer role-based locators and match the surrounding test style"* instead of a list of `NEVER use XPath / NEVER hard waits / …`).
- **Centralize the Constitution** in `qa-orchestrator.agent.md` (the canonical TOP source) and have worker agents reference it by path, rather than each carrying a copy. **Migration caveat (from the audit §6.2):** keep a path-reference fallback, not full deletion — handoff context does not propagate reliably on all runtimes, so workers must still be able to load the Constitution.
- This is **reversible** — heuristics can be tightened back to explicit rules if a model regresses.

## Risk if ignored

Low. The current state is not *wrong* — it's a defensible multi-model trade-off. The only cost is leaving ~15% of potential Claude 5 alignment on the table, which only materializes if Claude 5 becomes primary.

## References

- Architectural audit: [`ce-claude5-audit.md`](./ce-claude5-audit.md) — see §6.1 (Adversarial Review) and Gap G-04.
- Anthropic source: *"The new rules of context engineering for Claude 5 generation models"* — paradigm shift #1 (Rules → Judgment).
- Release: v4.0.0 CHANGELOG.
