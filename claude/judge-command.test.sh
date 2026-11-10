#!/usr/bin/env bash
# Exercise judge-command.sh without a model.
#
# A fake `curl` on PATH stands in for the endpoint: it records the request
# body it was handed and prints the reply named by $FAKE_REPLY, or fails like
# an unreachable host when $FAKE_REPLY is "down". The settings file is a
# temporary one, so the test never reads the machine's own systemone.env.
set -u

script="$(dirname "$0")/judge-command.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

fake="$work/bin"
mkdir -p "$fake"
cat > "$fake/curl" <<'FAKE'
#!/usr/bin/env bash
for a in "$@"; do case $a in @*) cp "${a#@}" "$FAKE_DIR/request.json" ;; esac; done
printf '%s
' "$@" > "$FAKE_DIR/args"
case ${FAKE_REPLY:-} in
  down) exit 7 ;;
  garbage) echo '<html>proxy</html>' ;;
  *) printf '{"model":"m","answers":{"irreversible":{"type":"noul","noul":%s},"outward":{"type":"noul","noul":%s}}}\n' \
       "${FAKE_IRREVERSIBLE:-0.01}" "${FAKE_OUTWARD:-0.01}" ;;
esac
FAKE
chmod +x "$fake/curl"
export PATH="$fake:$PATH" FAKE_DIR="$work"

pass=0
fail=0

# run <settings lines> -- <command>: prints the hook's stdout.
run() {
  local settings=$1 command=$2
  printf '%s\n' "$settings" > "$work/systemone.env"
  jq -nc --arg c "$command" '{tool_name: "Bash", tool_input: {command: $c}}' |
    SYSTEMONE_ENV_FILE="$work/systemone.env" SYSTEMONE_LOG="$work/log.jsonl" bash "$script"
}

expect() {
  local name=$1 want=$2 got=$3
  if [ "$want" = "$got" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf 'FAIL %s: want %s, got %s\n' "$name" "$want" "$got" >&2
  fi
}

verdict() {
  if [ -z "$1" ]; then echo silent; else printf '%s' "$1" | jq -r '.hookSpecificOutput.permissionDecision'; fi
}

base=$'SYSTEMONE_BASE_URL=http://judge.invalid:11434
SYSTEMONE_MODEL=tev1:4b'

# No endpoint configured: this machine does not take part, nothing is sent.
rm -f "$work/request.json"
expect 'unconfigured is silent' silent "$(verdict "$(run '' 'git push --force origin main')")"
expect 'unconfigured sends nothing' absent "$([ -e "$work/request.json" ] && echo sent || echo absent)"

# An endpoint without a model: there is no default model, nothing is sent.
rm -f "$work/request.json"
expect 'no model is silent' silent "$(verdict "$(run 'SYSTEMONE_BASE_URL=http://judge.invalid:11434' 'git push --force origin main')")"
expect 'no model sends nothing' absent "$([ -e "$work/request.json" ] && echo sent || echo absent)"

# The endpoint is a local Ollama: the request names the configured model and carries no credential.
rm -f "$work/args"
run "$base"$'
JEV_API_KEY=secret
SYSTEMONE_API_KEY=secret' 'git status' > /dev/null
expect 'request names the configured model' 'tev1:4b' "$(jq -r '.model' "$work/request.json")"
expect 'request carries no authorization' absent "$(grep -qi '^authorization' "$work/args" && echo sent || echo absent)"
expect 'request goes to the systemone path' yes "$(grep -qx 'http://judge.invalid:11434/v1/systemone' "$work/args" && echo yes || echo no)"

# Log mode, the default: every verdict is recorded, none is acted on.
rm -f "$work/log.jsonl"
out=$(FAKE_IRREVERSIBLE=0.99 run "$base" 'git push --force origin main')
expect 'log mode is silent' silent "$(verdict "$out")"
expect 'log mode records the command' 'git push --force origin main' "$(jq -r '.command' "$work/log.jsonl")"
expect 'log mode records the probability' 0.99 "$(jq -r '.irreversible' "$work/log.jsonl")"
expect 'request carries the command as state' 'git push --force origin main' "$(jq -r '.state.command' "$work/request.json")"
expect 'request asks both questions as noul' 'noul noul' "$(jq -r '[.questions.irreversible.type, .questions.outward.type] | join(" ")' "$work/request.json")"

# Ask mode without a threshold stays in log mode: no cutoff is assumed.
expect 'ask without threshold is silent' silent \
  "$(verdict "$(FAKE_IRREVERSIBLE=0.99 run "$base"$'\nSYSTEMONE_MODE=ask' 'git push --force origin main')")"

ask="$base"$'\nSYSTEMONE_MODE=ask\nSYSTEMONE_ASK_AT=0.9'
expect 'irreversible above cutoff asks' ask "$(verdict "$(FAKE_IRREVERSIBLE=0.95 run "$ask" 'git reset --hard')")"
expect 'outward above cutoff asks' ask "$(verdict "$(FAKE_OUTWARD=0.95 run "$ask" 'gh pr merge 12')")"
expect 'below cutoff is silent' silent "$(verdict "$(FAKE_IRREVERSIBLE=0.5 FAKE_OUTWARD=0.5 run "$ask" 'git status')")"
reason=$(FAKE_IRREVERSIBLE=0.95 run "$ask" 'git reset --hard' | jq -r '.hookSpecificOutput.permissionDecisionReason')
expect 'reason names the probability' yes "$(case $reason in *0.95*) echo yes ;; *) echo no ;; esac)"

# Never an allow or a deny, whatever the model says.
expect 'certainty still only asks' ask "$(verdict "$(FAKE_IRREVERSIBLE=1 FAKE_OUTWARD=1 run "$ask" 'rm -rf /')")"

# Fail open: an unreachable endpoint or an answer that is not the API's is silence.
expect 'unreachable is silent' silent "$(verdict "$(FAKE_REPLY=down run "$ask" 'git reset --hard')")"
expect 'garbage is silent' silent "$(verdict "$(FAKE_REPLY=garbage run "$ask" 'git reset --hard')")"

# Nothing to judge: an empty command sends no request.
rm -f "$work/request.json"
expect 'empty command is silent' silent "$(verdict "$(run "$ask" '')")"
expect 'empty command sends nothing' absent "$([ -e "$work/request.json" ] && echo sent || echo absent)"

printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
