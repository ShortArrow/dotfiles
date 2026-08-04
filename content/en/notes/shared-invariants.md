---
title: "Invariants written once, run two ways"
description: "Neovim can freeze while the configuration is correct, because what is wrong is the state of the machine rather than anything in the repository. The assertions live in one module and are called from both :checkhealth and the headless CI probes."
summary: "Why `:checkhealth my` and headless CI share one set of checks, and why proving an absence means waiting for it."
---

Neovim freezes and the configuration is fine. The fault is outside the
repository.

- mason has three C# language servers installed: omnisharp, omnisharp-mono
  and csharp-language-server. All three attach to a `.cs` buffer, so the
  solution loads three times and the UI thread stays blocked until the
  first highlight. The configuration asks for one. The other two are
  simply present.
- `lsp.log` is several megabytes. Some server is flooding WARN, and every
  line of it is written synchronously while you edit.
- blink.cmp loaded before InsertEnter. Requiring it costs about a second
  on [the machine](/machine/), and that second is now on every file open.

None of these show up in a linter. What is in the repository is right, and
what is around it has drifted.

## The assertions live in one module

`nvim/src/lua/my/checks/init.lua` holds all of them. Each function returns
a list of `{ ok, msg }` and touches neither the display nor the exit code.

```lua
M.lsp_log_size = function()
  local max_bytes = 5 * 1024 * 1024
  local path = vim.lsp.get_log_path()
  local stat = vim.uv.fs_stat(path)
  local size = stat and stat.size or 0
  return { result(size < max_bytes,
    ("lsp.log is %.1f MB (%s)"):format(size / 1024 / 1024, path)) }
end
```

The same checks are wanted in two places: interactively, and in CI.
Written twice, one copy gets fixed and the other quietly stops agreeing.

## `:checkhealth my` reports what is true now

`lua/my/health.lua` pushes each result into `vim.health.ok` or `.error`.

The LSP attachment check is the exception, because it needs an open buffer
to say anything. So it walks the loaded buffers and looks only at the
filetypes with a declared expectation, and says so when none qualify.

```lua
M.expected_lsp_clients = { cs = { "omnisharp" }, lua = { "lua_ls" } }
M.lsp_client_noise = { copilot = true, ["null-ls"] = true, ["GitHub Copilot"] = true }
```

The noise list is there because clients that belong to no language attach
to the same buffer. Without it, having copilot running is enough to fail
the comparison.

## CI has to create the state first

Headless, there are no open buffers. `nvim/tests/cs_single_lsp.lua` opens a
fixture `.cs` file and waits up to 120 seconds for omnisharp to attach.

Then it waits five seconds more.

```lua
vim.wait(5000) -- let any unexpected second server show itself
```

"No second server attached" cannot be observed at an instant. The second
one may simply not have arrived. An absence has to be waited for.

The probe skips when omnisharp is not installed. The workflow runs
`MasonInstall omnisharp` explicitly, so the skip cannot quietly swallow the
check on CI.

## Exit codes, and getting them to run

Each probe ends in `cq!` or `qa!`. `cq!` is the non-zero one.

`nvim/tests/run.sh` walks `nvim/tests/*.lua`. Two things catch it out:

- **Check for GNU `timeout` before using it.** Windows ships a different
  program under the same name in `System32`. The probe is whether
  `timeout 1 true` succeeds.
- **Hand Neovim a native path.** Neovim on Windows cannot open an
  MSYS-style `/d/...` path, so each file goes through `cygpath -m` first.

The workflow runs them on ubuntu and windows, and only when `nvim/**`
changes.
