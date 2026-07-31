# Alacritty

The fallback terminal. WezTerm is the daily driver; Alacritty is what
gets opened when WezTerm will not start — after a bad config edit, a
broken update, or a GPU driver problem that takes its renderer down.

That role is why it stays configured even when it is not installed. A
fallback is worth having only if its config is already in place before
it is needed.

On Linux the same role belongs to Ghostty, which is why this config is
not linked there in practice. Ghostty is left at its own defaults and
has no directory here.

## Usage

Make SymbolicLink.

### Windows

```powershell
./setup.ps1
```

### Linux

```bash
./setup.sh
```
