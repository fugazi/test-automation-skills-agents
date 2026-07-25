# Windows Notes

## URLs with `&` on Windows

On Windows, `cmd.exe` treats `&` as a command separator, so URLs with multiple query parameters get truncated before `playwright-cli` runs. Escape `&` with `^&` in `cmd.exe`:

```batch
playwright-cli goto "https://example.com/?a=1^&b=2"
```
