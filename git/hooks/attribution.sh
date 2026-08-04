#!/usr/bin/env bash
# Shared matcher for the commit-msg and pre-push hooks beside it.
#
# has_attribution reads a commit message on stdin and exits 0 when the message
# carries an attribution trailer or a session link, 1 otherwise.
#
# The forms are the same ones claude/check-attribution.sh refuses at the tool
# boundary. That script cannot source this file — it is symlinked into
# ~/.claude and would have to resolve back into the checkout — so the two lists
# are kept in step by hooks.test.sh, which runs one corpus through both and
# requires the verdicts to agree.
#
# Dependabot's lowercase `Co-authored-by:` is left alone: it credits a real
# author and belongs in the history.

has_attribution() {
  local message
  message=$(cat)
  case $message in
    *Claude-Session:* | \
    *"Co-Authored-By: Claude"* | \
    *"Generated with Claude Code"* | \
    *claude.ai/code/session_*)
      return 0
      ;;
  esac
  return 1
}

# Print the offending lines so the caller does not have to search a long
# message for the one that has to go.
show_attribution() {
  grep -n -E 'Claude-Session:|Co-Authored-By: Claude|Generated with Claude Code|claude\.ai/code/session_' -- "$1" |
    sed 's/^/    /'
}
