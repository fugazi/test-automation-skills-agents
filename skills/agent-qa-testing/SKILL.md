---
name: agent-qa-testing
description: 'Validates and runs agent-qa web/mobile regression tests and triages recorded results. Use when asked to validate agent-qa YAML, run a selected agent-qa test, or inspect failed/healed runs and advanced memidex memory with self-improvement.'
license: Apache-2.0
---

# agent-qa testing

Use agent-qa for web, Android, and iOS regression tests with advanced memidex memory and self-improvement. Work with the project's existing tests, targets, and model configuration.

## When to Use

- Validate or run a selected agent-qa regression test in an initialized project.
- Investigate a failed or healed agent-qa run using recorded evidence.
- Inspect the memidex knowledge associated with that run.


Do NOT use for:

- Authoring Playwright TypeScript specs: use `playwright-e2e-testing`.
- Authoring Selenium Java tests: use `webapp-selenium-testing`.
- General failure investigation without agent-qa evidence: use `qa-investigation`.

## Core Process

### 1. Establish the test scope

- Locate `agent-qa.config.yaml` and the requested test or suite. Run from that project directory; a global `--config <path>` must appear before the command.
- Use the project's installed version and package manager. The examples below assume an npm installation and use `--no-install` to avoid downloading a different version. Replace `tests/checkout.yaml` with the selected test path.
- agent-qa requires Node.js 24+. If it is not installed or initialized, use the [official quickstart](https://vostride.com/docs/agent-qa/quickstart) and the user's chosen provider; preserve existing configuration and credentials.

```sh
npx --no-install agent-qa --version
npx --no-install agent-qa run --help
```

### 2. Validate before executing

```sh
npx --no-install agent-qa validate tests/checkout.yaml
npx --no-install agent-qa run tests/checkout.yaml --dry-run
```

Validation checks configuration, test structure, and references. A dry run lists the selected tests without executing them. Neither proves that an application flow passes. Check the selected target and test files before running; omitting the path runs all discovered tests.

For suite selection or mobile device overrides, consult the installed command's help and existing project configuration. `doctor` can help diagnose setup failures, but its checks may contact the configured model provider.

### 3. Run the selected flow

Run against the environment and test data authorized by the user. Application actions can change data, and configured providers may charge for execution.

```sh
npx --no-install agent-qa run tests/checkout.yaml --junit-output results.xml
```

Preserve the exit status and report path. Exit `0` means passed or healed, `1` failed, `2` could not run, and `130` cancelled. Inspect the verdict to distinguish a clean pass from a healed run; treat setup failures as unresolved execution, not application failures.

### 4. Triage from recorded evidence

```sh
npx --no-install agent-qa runs list --verdict failed --limit 10 --json
npx --no-install agent-qa runs overview RUN_ID --json
npx --no-install agent-qa runs knowledge RUN_ID --json
npx --no-install agent-qa knowledge inspect --json
```

Replace `RUN_ID` with the relevant recorded run ID. Use `runs list --json` without the verdict filter when investigating a healed run or another outcome.

If a run has no completed verdict or its knowledge view reports `evidence-incomplete`, report that gap. Do not infer a completed application outcome from an incomplete record.

Read the failed step and available evidence before proposing a correction. Edit tests or application code only when the user has authorized that change. Distinguish an application defect, a test expectation problem, and an environment/provider failure. Use the run's knowledge view to see what memidex supplied or learned. Do not erase the cache or knowledge store merely to obtain a passing result.

### 5. Verify and report

Rerun the selected flow after an evidence-based correction. Stop and report an unchanged failure when no new corrective action is justified. Report the command, run ID, verdict, relevant evidence/report paths, and what remains unverified; redact credentials and sensitive application data.

## Verification

- [ ] Selected files and target match the requested scope; validation and dry-run results are recorded separately from execution.
- [ ] Exit status and completed verdict are both inspected; a healed run or incomplete record is identified explicitly.
- [ ] Report includes the run ID, evidence paths and unresolved checks, with sensitive values redacted.

## References

- [CLI commands and exit codes](https://vostride.com/docs/agent-qa/cli)
- [Inspect and correct memory](https://vostride.com/docs/agent-qa/memory/inspect)
- [agent-qa repository](https://github.com/vostride/agent-qa)

These original instructions use Apache-2.0; see [LICENSE.txt](./LICENSE.txt). The separately installed agent-qa package uses FSL-1.1-ALv2. Model, browser, and device providers have their own requirements and costs.
