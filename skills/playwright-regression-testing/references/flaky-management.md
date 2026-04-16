# Flaky Test Management

Detailed reference for managing flaky tests in Playwright regression suites. Covers retry policies, quarantine strategies, detection checklists, and suite health metrics.

## Retry Policy

```typescript
// playwright.config.ts
export default defineConfig({
  retries: process.env.CI ? 2 : 0, // Retry only in CI
  reporter: [["html"], ["json", { outputFile: "test-results/results.json" }]],
  use: {
    trace: "on-first-retry", // Capture trace on retry
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },
});
```

## Quarantine Flaky Tests

Isolate known flaky tests to prevent blocking the pipeline while tracking them for fixes:

```typescript
// Mark flaky tests with fixme — skipped but tracked
test.fixme("intermittent timeout on slow network @flaky", async ({ page }) => {
  // TODO: investigate — see issue #1234
});

// Or use a dedicated tag for quarantine reporting
test(
  "payment callback race condition @quarantine",
  {
    tag: ["@quarantine", "@regression"],
    annotation: {
      type: "issue",
      description: "https://github.com/org/repo/issues/1234",
    },
  },
  async ({ page }) => {
    test.skip(!!process.env.CI, "Quarantined — flaky in CI, see linked issue");
    // Test body here
  },
);
```

## Flaky Test Detection Checklist

| Symptom                       | Common Cause                       | Fix                                                            |
| ----------------------------- | ---------------------------------- | -------------------------------------------------------------- |
| Passes locally, fails in CI   | Timing, environment differences    | Use web-first assertions; match CI env settings                |
| Fails intermittently          | Race condition, animation, network | Add `test.step()`, wait for specific state, mock APIs          |
| Different results per browser | Browser-specific rendering         | Add browser-specific assertions or skip with `test.skip()`     |
| Order-dependent failures      | Shared state between tests         | Ensure full test isolation; use fixtures for setup             |
| Timeout errors                | Slow element rendering             | Check for overlays/loaders; use `waitFor` on specific elements |

## Suite Health Metrics

Track these metrics to maintain regression suite quality:

| Metric                     | Target   | Action if Exceeded                          |
| -------------------------- | -------- | ------------------------------------------- |
| Smoke suite duration       | < 2 min  | Split or move slow tests to Tier 2          |
| Full regression duration   | < 60 min | Add sharding, reduce redundant coverage     |
| Flake rate (retried tests) | < 2%     | Quarantine and fix; investigate root causes |
| Test pass rate             | > 98%    | Triage failures within 24 hours             |
| Escaped defects per sprint | < 2      | Add regression tests for escaped bugs       |

## Troubleshooting

| Problem                | Cause                             | Solution                                                              |
| ---------------------- | --------------------------------- | --------------------------------------------------------------------- |
| Smoke suite too slow   | Too many tests tagged `@smoke`    | Keep smoke under 10 tests; move others to `@regression`               |
| Shards unbalanced      | Test durations vary widely        | Use `--shard` with `fullyParallel: true`; split large describe blocks |
| CI flakes not local    | Environment or timing differences | Match CI config locally; use `trace: 'on-first-retry'`                |
| Tag not filtering      | Missing `tag` annotation          | Use `{ tag: ['@smoke'] }` in test options, not just title             |
| Merge reports fail     | Artifact names mismatch           | Ensure consistent `upload-artifact` naming pattern per shard          |
| Auth setup fails       | Login page changed                | Update `auth.setup.ts`; check `storageState` path                     |
| Tests run out of order | Missing `dependencies` in config  | Set project `dependencies: ['setup']` for auth                        |
