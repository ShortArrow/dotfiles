---
title: "An irreversible action is not authorised by a yes in the conversation"
description: "An agent asked to push, or to delete, has the call refused by the approval classifier — and having agreed in chat beforehand changes nothing. Only a choice made through AskUserQuestion counts, and this turned out not to be about push at all."
summary: "The handshake that gets a destructive action executed, and how it stopped being a git rule."
---

Ask an agent to `git push` and the call is refused, even when you said yes
a moment earlier. Agreement in the conversation is not the signal read at
the moment of execution.

What passes is the shape where the agent puts the choice through
**AskUserQuestion** and acts on what was selected. Without knowing that,
the refusal looks like a broken tool.

## It looked like a rule about push

The handshake was written for push. Then a `curl -X DELETE` against ollama,
clearing out models too large for an 8 GB card, came back with the same
thing:

```
Permission for this action was denied by the Claude Code auto mode classifier.
```

No git anywhere. **The refusal was not about pushing; it was about not
being able to take it back.**

Asked again through AskUserQuestion, naming all eight models and their
sizes, the identical command ran and freed 152 GB. Not one character of it
changed.

## What to establish before asking

The question is worth nothing unless it **names what will happen**, read
back from the system rather than from memory.

| Action | Read back first |
|---|---|
| push | the branch, and `git log @{u}..HEAD` |
| force push, history rewrite | how many commits change, whether the content is identical, that other clones need `reset --hard` |
| `amend`, `reset --hard`, `rebase` | what is discarded, and whether it has been pushed |
| `revert` | which commit. A revert adds a commit and destroys nothing — say so |
| deleting files, models, images | the list, each size, the total, whether it can be fetched again |
| stopping a service or a container | what goes down, who else is on it, how it comes back |

The `revert` row points the other way. **Listing a risk that is not there
is how the next real one gets waved through.**

## When approval is not enough

Sometimes the action is refused even after the choice was made. Stop there.
Say what was being attempted and what it needs, and hand it over.

Do not reach for a different tool that produces the same effect. The
refusal is not an obstacle in front of the goal; it is the signal to stop.

## One selection covers one action

What was chosen covers the action the question named. It does not extend to
the next one, or to a wider version of the same one. Running a second thing
on the strength of one approval leaves the record and the events describing
different days.

The question text becomes the record. Write it so that whoever reads the
log later can tell what was authorised without reconstructing it.
