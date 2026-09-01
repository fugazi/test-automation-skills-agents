---
name: playwright-cli
description: 'Drive a live browser from the CLI with playwright-cli to navigate, interact, snapshot, and capture evidence. Use for ad-hoc browser commands, page inspection, screenshots, traces, network mocking, session management, or interactive debugging—not authoring @playwright/test specs. Keywords: playwright-cli, browser automation, live session, snapshot, console, tracing.'
license: 'Complete terms in LICENSE.txt'
---

# Browser Automation with playwright-cli

## Quick start

```bash
playwright-cli open
playwright-cli goto https://playwright.dev
playwright-cli click e15        # use refs from snapshot
playwright-cli type "search query"
playwright-cli press Enter
playwright-cli snapshot
playwright-cli close
```

## Commands

### Core

```bash
playwright-cli open [url]
playwright-cli goto <url>
playwright-cli type "<text>"
playwright-cli click <ref>
playwright-cli dblclick <ref>
playwright-cli fill <ref> "<text>" [--submit]
playwright-cli drag <ref> <ref>
playwright-cli drop <ref> [--path=<file> | --data="mime=value"]
playwright-cli hover <ref>
playwright-cli select <ref> "<value>"
playwright-cli upload <path>
playwright-cli check <ref>
playwright-cli uncheck <ref>
playwright-cli snapshot
playwright-cli find "<text>" | --regex "<pattern>" [--regex "/pattern/i"]
playwright-cli eval "<js>" [ref]
playwright-cli dialog-accept ["text"]
playwright-cli dialog-dismiss
playwright-cli resize <w> <h>
playwright-cli close
```

### Navigation & Keyboard

```bash
playwright-cli go-back | go-forward | reload
playwright-cli press <key>          # Enter, ArrowDown, etc.
playwright-cli keydown | keyup <key>
```

### Mouse

```bash
playwright-cli mousemove <x> <y>
playwright-cli mousedown [right]
playwright-cli mouseup [right]
playwright-cli mousewheel <dx> <dy>
```

### Save as

```bash
playwright-cli screenshot [ref] [--filename=<f>] [--hires]
playwright-cli pdf --filename=<f>
```

### Tabs

```bash
playwright-cli tab-list
playwright-cli tab-new [url]
playwright-cli tab-close [index]
playwright-cli tab-select <index>
```

### Storage

```bash
playwright-cli state-save [file] | state-load <file>
playwright-cli cookie-list [--domain=] | cookie-get <name>
playwright-cli cookie-set <name> <val> [--domain= --httpOnly --secure]
playwright-cli cookie-delete <name> | cookie-clear
playwright-cli localstorage-list | localstorage-get <key>
playwright-cli localstorage-set <key> <val> | localstorage-delete <key> | localstorage-clear
playwright-cli sessionstorage-list | sessionstorage-get <key>
playwright-cli sessionstorage-set <key> <val> | sessionstorage-delete <key> | sessionstorage-clear
```

### Network

```bash
playwright-cli route "<glob>" [--status= | --body=]
playwright-cli route-list
playwright-cli unroute ["<glob>"]
```

### DevTools

```bash
playwright-cli console [warning|error]
playwright-cli requests
playwright-cli request <index>
playwright-cli run-code "<js>" | --filename=<f>
playwright-cli tracing-start | tracing-stop
playwright-cli recording-start      # record user actions; print Playwright code on stop
playwright-cli recording-stop
playwright-cli video-start <file> | video-chapter "<title>" [--description= --duration=] | video-stop
playwright-cli video-show-actions [--duration= --position=] | video-hide-actions
playwright-cli show --annotate          # UI review / design feedback
playwright-cli generate-locator <ref> [--raw]
playwright-cli highlight <ref> [--style=] | highlight <ref> --hide | highlight --hide
```

## Raw output

`--raw` strips status/snapshot, returns only the result value.

```bash
playwright-cli --raw eval "JSON.stringify(performance.timing)"
playwright-cli --raw snapshot > before.yml
playwright-cli click e5
playwright-cli --raw snapshot > after.yml
diff before.yml after.yml
```

For JSON wrapping: `playwright-cli list --json`

## Open parameters

```bash
playwright-cli open --browser=chrome|firefox|webkit|msedge
playwright-cli open --mobile | --device="iPhone 15"
playwright-cli open --persistent | --profile=/path/to/profile
playwright-cli attach --extension=chrome | --cdp=chrome|msedge|http://host:port
playwright-cli open --config=<file>
playwright-cli delete-data
```

> **Windows:** See [`references/windows-notes.md`](references/windows-notes.md) for URL escaping rules.

## Snapshots

After each command, playwright-cli provides a snapshot of the current browser state.

```bash
playwright-cli snapshot [ref] [--filename=] [--depth=N] [--boxes]
playwright-cli find "<text>"
playwright-cli find --regex "\\$[0-9]+\\.[0-9]{2}"
```

## Targeting elements

```bash
playwright-cli click e15                               # ref from snapshot
playwright-cli click "#main > button.submit"           # CSS selector
playwright-cli click "getByRole('button', { name: 'Submit' })"  # role locator
playwright-cli click "getByTestId('submit-button')"    # test id
```

## Browser sessions

```bash
playwright-cli -s=<name> open [url] [--persistent | --profile=<dir>]
playwright-cli -s=<name> click e6
playwright-cli -s=<name> close
playwright-cli list
playwright-cli close-all
playwright-cli kill-all
```

## Installation

```bash
# Check local version
npx --no-install playwright --version
# Use local
npx playwright cli
# Install global
npm install -g @playwright/cli@latest
```

## When NOT to Use This Skill

- Authoring or maintaining versioned `@playwright/test` spec files (use `playwright-e2e-testing`).
- Selenium/Java browser automation (use `webapp-selenium-testing`).
- Governing a large regression suite, tiers, or CI sharding (use `playwright-regression-testing`).
- Long-running recorded test suites — playwright-cli drives a single live, interactive session, not a parallel run.

## Red Flags

- Relying on `--debug=cli` as a permanent test runner — it is an exploration/debug aid, not a CI executor.
- Leaving background debug sessions running between scenarios — they leak state and ports; always stop them.
- Opening the app URL directly instead of going through the seed test — custom setup in the test is then missed.
- Using sleeps or `networkidle` as a fix for timing issues — prefer web-first assertions.

---

## References

- **Playwright tests** [references/playwright-tests.md](references/playwright-tests.md)
- **Request mocking** [references/request-mocking.md](references/request-mocking.md)
- **Running code** [references/running-code.md](references/running-code.md)
- **Session management** [references/session-management.md](references/session-management.md)
- **Storage state** [references/storage-state.md](references/storage-state.md)
- **Test generation** [references/test-generation.md](references/test-generation.md)
- **Tracing** [references/tracing.md](references/tracing.md)
- **Video recording** [references/video-recording.md](references/video-recording.md)
- **Element attributes** [references/element-attributes.md](references/element-attributes.md)
- **Spec-driven testing** [references/spec-driven-testing.md](references/spec-driven-testing.md)
- **Spec-driven healing** [references/spec-driven-heal.md](references/spec-driven-heal.md)

---

## Verification

- [ ] **Session lifecycle managed** — every `playwright-cli open`/`-s=<name> open` is paired with a `close`/`close-all`; no orphan sessions left running.
- [ ] **Elements addressed by ref** — interactions use snapshot refs (`e15`) or generated locators, not guessed CSS selectors.
- [ ] **Evidence captured where needed** — screenshots, traces, or console/request logs recorded for the task at hand.
- [ ] **Background debug sessions stopped** — `--debug=cli` runs are terminated before moving on or finishing.
