---
title: "One set of health checks for :checkhealth and for CI"
description: "Neovim can freeze even when the configuration is correct, because the problem is in the state of the machine: an extra language server, a huge log file, a plugin loaded too early. The checks that catch these live in one module and are run both from :checkhealth and from headless CI probes. This note explains that arrangement and why checking that something is absent means waiting for it."
summary: "Why `:checkhealth my` and the headless CI probes share one set of checks, and why proving an absence takes a wait."
---

Neovim sometimes freezes on this machine while the configuration in the
repository is correct. The cause in each case has been the state of the
machine around the configuration:

- mason had three C# language servers installed: omnisharp, omnisharp-mono
  and csharp-language-server. All three attach to a `.cs` buffer, so the
  solution is loaded three times and the UI thread stays blocked until the
  first syntax highlight appears. The configuration asks for one server;
  the other two were simply installed as well.
- `lsp.log` had grown to several megabytes. Some server was logging WARN
  lines continuously, and each line is written synchronously while you
  edit.
- blink.cmp was being loaded before `InsertEnter`. Requiring it takes about
  a second on [this machine](/machine/), and that second was being paid on
  every file open.

A linter cannot find any of these, because the files in the repository are
fine. What has changed is the environment they run in.

## The checks live in one module

`nvim/src/lua/my/checks/init.lua` contains every check. Each function
returns a list of `{ ok, msg }` results and does nothing else: it does not
print, and it does not set an exit code.

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

The same checks are needed in two places, interactively in the editor and
in CI. If they were written twice, one copy would get fixed and the other
would keep reporting the old answer.

## `:checkhealth my` reports the current state

`lua/my/health.lua` runs each check and passes the results to
`vim.health.ok` or `vim.health.error`.

The check for attached LSP clients works differently from the others,
because it needs an open buffer to have anything to report. It goes through
the loaded buffers, considers only the filetypes that have an expectation
declared, and says so when no buffer qualifies.

```lua
M.expected_lsp_clients = { cs = { "omnisharp" }, lua = { "lua_ls" } }
M.lsp_client_noise = { copilot = true, ["null-ls"] = true, ["GitHub Copilot"] = true }
```

The noise list exists because clients that are not tied to a language, such
as copilot, attach to the same buffers. Without the list, having copilot
running would be enough to make the comparison fail.

## CI has to create the state before checking it

In a headless Neovim there are no open buffers, so the CI probe has to
produce the situation itself. `nvim/tests/cs_single_lsp.lua` opens a fixture
`.cs` file and waits up to 120 seconds for omnisharp to attach.

Then it waits five more seconds:

```lua
vim.wait(5000) -- let any unexpected second server show itself
```

The claim being checked is that no second server attaches. That cannot be
confirmed at a single moment, because a second server might just not have
started yet. The only way to check that something is absent is to wait long
enough for it to have appeared.

The probe skips itself when omnisharp is not installed. To make sure that
skip never hides the check in CI, the workflow runs `MasonInstall omnisharp`
explicitly before the probes.

## Exit codes and the runner

Each probe ends with either `cq!` or `qa!`; `cq!` is the one that exits
non-zero.

`nvim/tests/run.sh` runs every file in `nvim/tests/*.lua`. Two details are
needed for it to work on Windows:

- It checks for GNU `timeout` before using it. Windows has an unrelated
  program with the same name in `System32`, so the runner tests whether
  `timeout 1 true` succeeds before relying on it.
- It passes Neovim a native path. Neovim on Windows cannot open an
  MSYS-style path such as `/d/...`, so each test file is converted with
  `cygpath -m` first.

The workflow runs the probes on ubuntu and on windows, and only when
something under `nvim/**` has changed.
