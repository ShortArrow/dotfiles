#!/usr/bin/env bash
# PreToolUse advisor: ask a SystemOne model served by a local Ollama whether a
# shell command is hard to undo or reaches outside this machine, and record
# the answer. The model may only add a confirmation; it never allows and
# never denies. Known-bad shapes belong to the deterministic guards beside it.
#
# Reads the hook JSON on stdin. Configuration comes from the environment or
# from $SYSTEMONE_ENV_FILE (default ~/.claude/systemone.env, KEY=VALUE lines),
# because the endpoint belongs to one machine and settings.sample.json travels:
#
#   SYSTEMONE_BASE_URL   Ollama root; unset means this machine does not take part
#   SYSTEMONE_MODEL      model name sent with the request; unset, nothing is sent
#   SYSTEMONE_KEEP_ALIVE sent as keep_alive, so the model stays loaded
#   SYSTEMONE_MODE       log (default) records only; ask may also return "ask"
#   SYSTEMONE_ASK_AT     cutoff for ask mode; without it ask mode only records,
#                        since a cutoff has to come from this machine's own log
#   SYSTEMONE_LOG        where verdicts go (default ~/.claude/systemone-log.jsonl)
#
# Every failure is silence: no endpoint, a timeout, a reply that is not the
# API's. A hook that blocks the session on an advisor's outage costs more
# than the advice is worth.
set -u

env_file=${SYSTEMONE_ENV_FILE:-$HOME/.claude/systemone.env}
# shellcheck disable=SC1090
[ -r "$env_file" ] && . "$env_file"
[ -n "${SYSTEMONE_BASE_URL:-}" ] && [ -n "${SYSTEMONE_MODEL:-}" ] || exit 0

input=$(cat)
command_line=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0
[ -n "$command_line" ] || exit 0
tool=$(printf '%s' "$input" | jq -r '.tool_name // "shell"')

request=$(mktemp) || exit 0
trap 'rm -f "$request"' EXIT

jq -n --arg model "$SYSTEMONE_MODEL" --arg tool "$tool" \
  --arg command "${command_line:0:8000}" --arg keep "${SYSTEMONE_KEEP_ALIVE:-}" '
  def noul(statement; yes; no):
    {type: "noul",
     instructions: {task: "Judge only the command in the state, as it would run in a developer shell.",
                    statement: statement},
     criteria: {true: yes, false: no}};
  {model: $model,
   state: {tool: $tool, command: $command},
   questions: {
     irreversible: noul(
       "Running this command destroys, overwrites or discards data, history or work in a way that is hard to undo.";
       "It deletes, overwrites, force-pushes, resets or drops something that cannot easily be recovered";
       "It only reads, or what it changes is easy to undo"),
     outward: noul(
       "Running this command changes something outside this machine that other people or systems can see.";
       "It pushes, publishes, deploys, sends, posts, merges or edits shared remote state";
       "Its effects stay on this machine")}}
  + (if $keep == "" then {} else {keep_alive: ($keep | tonumber? // $keep)} end)
' > "$request" || exit 0

started=$(date +%s%3N)
reply=$(curl -sf --max-time 1.5 -H 'content-type: application/json' \
  --data-binary "@$request" "${SYSTEMONE_BASE_URL%/}/v1/systemone" 2>/dev/null) || exit 0
elapsed=$(( $(date +%s%3N) - started ))

verdict=$(printf '%s' "$reply" | jq -c '
  {irreversible: .answers.irreversible.noul, outward: .answers.outward.noul}
  | select((.irreversible | type) == "number" and (.outward | type) == "number")
' 2>/dev/null) || exit 0
[ -n "$verdict" ] || exit 0

printf '%s' "$verdict" | jq -c --arg command "$command_line" --arg tool "$tool" \
  --arg model "$SYSTEMONE_MODEL" --argjson ms "$elapsed" \
  '{at: (now | todate), tool: $tool, model: $model, ms: $ms, command: $command} + .' \
  >> "${SYSTEMONE_LOG:-$HOME/.claude/systemone-log.jsonl}" 2>/dev/null

[ "${SYSTEMONE_MODE:-log}" = ask ] && [ -n "${SYSTEMONE_ASK_AT:-}" ] || exit 0

printf '%s' "$verdict" | jq -c --argjson at "$SYSTEMONE_ASK_AT" '
  [ (if .irreversible >= $at then "hard to undo (p=\(.irreversible))" else empty end),
    (if .outward >= $at then "reaches outside this machine (p=\(.outward))" else empty end) ]
  | select(length > 0)
  | {hookSpecificOutput: {
       hookEventName: "PreToolUse",
       permissionDecision: "ask",
       permissionDecisionReason: ("Decision model judged this command " + join(" and ") + ". Confirm it is intended.")}}
' 2>/dev/null
exit 0
