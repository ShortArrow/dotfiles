#!/usr/bin/env bash
# Exercise check-attribution.sh against the tool_input shapes the hook sees.
#
# The patterns are assembled from fragments rather than written out, because
# the live hook reads this file's own command line: spelling a trailer here
# would make the test suite unrunnable.
set -u

script="$(dirname "$0")/check-attribution.sh"

TRAILER="Claude""-Session:"
SESSION_URL="claude.ai/code/session_"
COAUTHOR="Co-Authored""-By: Claude"
GENERATED="Generated with Claude"" Code"

pass=0
fail=0

# verdict <command> -> "deny" or "allow"
verdict() {
  local out
  out=$(jq -nc --arg c "$1" '{tool_input:{command:$c}}' | bash "$script")
  if [ -n "$out" ]; then echo deny; else echo allow; fi
}

check() { # <expected> <label> <command>
  local got
  got=$(verdict "$3")
  if [ "$got" = "$1" ]; then
    pass=$((pass + 1))
    printf '  ok   %-6s %s\n' "$1" "$2"
  else
    fail=$((fail + 1))
    printf '  FAIL want=%s got=%s  %s\n' "$1" "$got" "$2"
  fi
}

echo "denies attribution in a commit message"
check deny "trailer" "git commit -m \"fix

$TRAILER https://${SESSION_URL}abc\""
check deny "co-author" "git commit -m \"fix

$COAUTHOR <noreply@anthropic.com>\""
check deny "generated-with" "git commit -m \"fix

$GENERATED\""
check deny "bare session url" "git commit -m \"fix

https://${SESSION_URL}abc\""

echo "denies attribution in a gh body"
check deny "pr create" "gh pr create --title t --body \"body

https://${SESSION_URL}abc\""
check deny "issue comment" "gh issue comment 1 --body \"https://${SESSION_URL}abc\""
check deny "release notes" "gh release create v1 --notes \"$TRAILER https://${SESSION_URL}abc\""

echo "allows everything else"
check allow "clean commit" 'git commit -m "feat(claude): add the claude code skill"'
check allow "clean pr" 'gh pr create --title "feat(claude): x" --body "claude code settings"'
check allow "gh read" 'gh pr list --state all'
check allow "gh api" 'gh api repos/ShortArrow/dotfiles'
check allow "docs link" 'gh pr create --body "see https://docs.claude.com/en/docs"'
check allow "dependabot" 'git commit -m "ci: bump x

Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>"'

echo "leaves commands that only mention the pattern alone"
check allow "log --grep" "git log --grep='$TRAILER'"
check allow "grep in a file" "grep -rn '$TRAILER' ."
check allow "unrelated command" "echo $TRAILER"

echo "handles malformed input"
check allow "no command field" ""

echo
printf 'pass=%d fail=%d\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
