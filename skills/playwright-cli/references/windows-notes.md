# Windows Notes

> Part of the `playwright-cli` skill. See [SKILL.md](../SKILL.md) for full context.

## URLs with `&` on Windows

On Windows, `cmd.exe` treats `&` as a command separator, so URLs with multiple query parameters get truncated before `playwright-cli` runs. Escape `&` with `^&` in `cmd.exe`:

```batch
playwright-cli goto "https://example.com/?a=1^&b=2"
```
