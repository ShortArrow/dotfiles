#!/usr/bin/env bash
# PreToolUse guard: refuse a command that would publish an attribution
# trailer or a session link.
#
# Reads the hook's tool_input JSON on stdin. Prints a deny verdict and exits 0
# when the command carries attribution; prints nothing otherwise. Silence is
# the allow verdict — the hook only acts on output.
#
# Two gates, in this order:
#
#   1. Is this a command that publishes? Only `git commit` and `gh` write a
#      message or a body. Everything else is none of this script's business,
#      including `git log --grep` and `grep`, which carry the pattern as a
#      search term and must keep working — the pattern was grepped for in
#      this repository while the guard was being written.
#
#   2. Does it carry attribution? The trailer forms, and the bare session URL
#      a pull request body is asked to end with, which no trailer key
#      precedes.
#
# The gate is decided here rather than in the hook's `if` field: `if` takes a
# permission rule, and a rule naming a tool that does not accept one fails by
# never firing, which is the one way a guard must not fail. Here it is a case
# statement with a test suite pointed at it.
#
# Dependabot's lowercase `Co-authored-by:` is left alone: it credits a real
# author and belongs in the history.
set -u

command_line=$(jq -r '.tool_input.command // ""')

case $command_line in
  *"git commit"* | *"gh "*) ;;
  *) exit 0 ;;
esac

case $command_line in
  *Claude-Session:* | *"Co-Authored-By: Claude"* | *"Generated with Claude Code"* | *claude.ai/code/session_*)
    jq -nc '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: "Attribution trailer or session link detected. This repository does not carry them in commits, pull requests, issues or releases. Remove the line and retry."
      }
    }'
    ;;
  *) exit 0 ;;
esac
