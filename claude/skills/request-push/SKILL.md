---
name: request-push
description: Obtain explicit, classifier-recognized confirmation before pushing to a remote, via AskUserQuestion. Use whenever a push is pending or wanted, or when a push was blocked by the auto-approval classifier (e.g. push requires confirmation; triggers like "push", "pushして", "push 申請", "push approval", push denied).
---

A push to a remote requires explicit confirmation. A casual "ok" / "yes" /
"いいよ" in chat does NOT satisfy the auto-approval classifier, so a direct
`git push` gets denied. The reliable way to get a recognized approval is to ask
through **AskUserQuestion** and act on the selected option.

**Localize:** phrase the question and the option labels in whatever language the
user is communicating in. The labels below are English examples — translate them
to match the conversation.

Do this:

1. Identify what would be pushed:
   - `git rev-parse --abbrev-ref HEAD` (current branch)
   - `git log @{u}..HEAD --oneline` (unpushed commits; if there is no upstream,
     say so and show recent local commits instead).
2. Call **AskUserQuestion** with a single confirmation question summarizing the
   branch and the unpushed commits (short hash + one-line subject each). Offer
   options such as:
   - "Push (as-is)" — push the commits unchanged.
   - "Tidy up first, then push" — squash/rebase/fixup first (only if cleanup is
     plausibly wanted).
   - "Don't push now" — leave local.
   Put the recommended option first; keep labels concrete (mention the branch /
   commit count).
3. On a push-approving answer, run `git push <remote> <branch>` (or the chosen
   form) and report the resulting ref update (`old..new branch -> branch`). For
   "tidy first", do the cleanup, re-show the result, then push. For "don't push",
   stop and leave the commits local.

Notes:
- Never push to any remote (especially the default branch) without this
  confirmation, even if the user just said "ok".
- Never use `--force` / `--no-verify` unless the user explicitly asks.
- This skill only governs the push approval handshake; commit work as usual.
