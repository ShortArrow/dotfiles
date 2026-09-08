---
title: "A guard that reads the command line only guards the command line"
description: "Keeping a particular line out of commit messages. Checking just before the tool call catches the -m case and nothing else: a message passed with -F, an --amend, or a commit written on another machine and pulled in all go straight through."
summary: "The six routes past a check placed on the command line, and the one route left after moving it into git."
---

There are lines that should not reach a commit message — the attribution
trailers and session links an agent tends to add, which a public repository
has no use for.

The first attempt put the check immediately before the agent runs a shell
command: look at the command string, refuse it if it contains `git commit`
or `gh` together with one of the patterns. That works. It just does not
work over much.

## Six routes straight past it

The same check, given the same intent in different shapes:

| Route | Result |
|---|---|
| `git commit -m "…"`, written inline | refused |
| `git commit -F msg.txt` | **passes** |
| `git commit --amend --no-edit` | **passes** |
| `gh pr create --body-file body.md` | **passes** |
| a message assembled at run time | **passes** |
| `git push` of commits written elsewhere | **passes** |

The check can read the command line and nothing else. The moment the
message is in a file, or arrives through a shell variable, there is nothing
there to see.

The five that had actually got in were written on another machine and
arrived by pull. **This check could not have stopped a single one of
them.** What it was watching and what it was meant to catch were not in the
same place.

There was a second hole beside it: the same settings file turns on the
PowerShell tool while the check was attached to Bash alone. Two tools, one
of them watched, so it reads as installed and lets half the traffic by.

## Where the message is

Git hands over the finished message itself at two points.

- **`commit-msg`** receives the message as a file. `-m`, `-F`, `--amend`
  and the editor all arrive here.
- **`pre-push`** can enumerate the commits about to leave. Anything written
  elsewhere, or written before the hook existed, is caught here.

Those two close all five routes that were passing. Nothing got cleverer:
the check stopped enumerating the ways a message can be written and moved
to the place every written message has to pass.

Setting `core.hooksPath` globally covers every repository on the machine.
It also replaces `.git/hooks` everywhere, so both hooks end by calling the
repository's own version with the same arguments.

## What is left, and what it costs

`--no-verify` still skips all of it. A hook cannot do anything about that.

The cost was the part I had not thought about. **You cannot write a commit
message about this guard.** The check compares strings, so a message
explaining why a trailer is refused looks exactly like a message carrying
one.

The test suite has to spell its patterns from fragments for the same
reason:

```sh
TRAILER="Claude""-Session:"
```

At run time that is the original string, but the sequence appears neither
in the file nor on the command line. It is what makes the file writable
through a shell; running the suite never needed it. **The workaround and
the way past the guard are the same move**, which is why that one stays
open.
