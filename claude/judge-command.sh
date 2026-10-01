#!/usr/bin/env bash
# PreToolUse advisor: ask a Jev-compatible decision model whether a shell
# command is hard to undo or reaches outside this machine, and record the
# answer. The model may only add a confirmation; it never allows and never
# denies. Known-bad shapes belong to the deterministic guards beside it.
#
# Reads the hook JSON on stdin. Configuration comes from the environment or
# from $JEV_ENV_FILE (default ~/.claude/jev.env, KEY=VALUE lines), because
# the endpoint belongs to one machine and settings.sample.json travels:
#
#   JEV_BASE_URL   endpoint root; unset means this machine does not take part
#   JEV_MODEL      model name sent with the request (default jev-latest)
#   JEV_API_KEY    bearer token, for a hosted endpoint
#   JEV_KEEP_ALIVE sent as keep_alive, for an Ollama-served model
#   JEV_MODE       log (default) records only; ask may also return "ask"
#   JEV_ASK_AT     cutoff for ask mode; without it ask mode only records,
#                  since a cutoff has to come from this machine's own log
#   JEV_LOG        where verdicts go (default ~/.claude/jev-log.jsonl)
#
# Every failure is silence: no endpoint, a timeout, a reply that is not the
# API's. A hook that blocks the session on an advisor's outage costs more
# than the advice is worth.
set -u

env_file=${JEV_ENV_FILE:-$HOME/.claude/jev.env}
# shellcheck disable=SC1090
[ -r "$env_file" ] && . "$env_file"
[ -n "${JEV_BASE_URL:-}" ] || exit 0

input=$(cat)
command_line=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0
[ -n "$command_line" ] || exit 0
tool=$(printf '%s' "$input" | jq -r '.tool_name // "shell"')

request=$(mktemp) || exit 0
trap 'rm -f "$request"' EXIT

jq -n --arg model "${JEV_MODEL:-jev-latest}" --arg tool "$tool" \
  --arg command "${command_line:0:8000}" --arg keep "${JEV_KEEP_ALIVE:-}" '
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

auth=()
[ -n "${JEV_API_KEY:-}" ] && auth=(-H "authorization: Bearer $JEV_API_KEY")

started=$(date +%s%3N)
reply=$(curl -sf --max-time 1.5 -H 'content-type: application/json' "${auth[@]}" \
  --data-binary "@$request" "${JEV_BASE_URL%/}/v1/systemone" 2>/dev/null) || exit 0
elapsed=$(( $(date +%s%3N) - started ))

verdict=$(printf '%s' "$reply" | jq -c '
  {irreversible: .answers.irreversible.noul, outward: .answers.outward.noul}
  | select((.irreversible | type) == "number" and (.outward | type) == "number")
' 2>/dev/null) || exit 0
[ -n "$verdict" ] || exit 0

printf '%s' "$verdict" | jq -c --arg command "$command_line" --arg tool "$tool" \
  --arg model "${JEV_MODEL:-jev-latest}" --argjson ms "$elapsed" \
  '{at: (now | todate), tool: $tool, model: $model, ms: $ms, command: $command} + .' \
  >> "${JEV_LOG:-$HOME/.claude/jev-log.jsonl}" 2>/dev/null

[ "${JEV_MODE:-log}" = ask ] && [ -n "${JEV_ASK_AT:-}" ] || exit 0

printf '%s' "$verdict" | jq -c --argjson at "$JEV_ASK_AT" '
  [ (if .irreversible >= $at then "hard to undo (p=\(.irreversible))" else empty end),
    (if .outward >= $at then "reaches outside this machine (p=\(.outward))" else empty end) ]
  | select(length > 0)
  | {hookSpecificOutput: {
       hookEventName: "PreToolUse",
       permissionDecision: "ask",
       permissionDecisionReason: ("Decision model judged this command " + join(" and ") + ". Confirm it is intended.")}}
' 2>/dev/null
exit 0
