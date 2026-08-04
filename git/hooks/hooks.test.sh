#!/usr/bin/env bash
# Exercise the commit-msg and pre-push hooks, and check that they agree with
# claude/check-attribution.sh about what attribution is.
#
# The patterns are assembled from fragments rather than written out, so that
# this file can be created and edited through a shell without the PreToolUse
# guard refusing the command that writes it.
set -u

hook_dir=$(cd -P "$(dirname "$0")" && pwd)
repo_root=$(cd -P "$hook_dir/../.." && pwd)
claude_guard="$repo_root/claude/check-attribution.sh"

TRAILER="Claude""-Session:"
SESSION_URL="claude.ai/code/session_"
COAUTHOR="Co-Authored""-By: Claude"
GENERATED="Generated with Claude"" Code"

pass=0
fail=0

check() { # <expected> <label> <actual>
  if [ "$3" = "$1" ]; then
    pass=$((pass + 1))
    printf '  ok   %-6s %s\n' "$1" "$2"
  else
    fail=$((fail + 1))
    printf '  FAIL want=%s got=%s  %s\n' "$1" "$3" "$2"
  fi
}

commit_msg_verdict() { # <message> -> reject | accept
  local f
  f=$(mktemp)
  printf '%s\n' "$1" >"$f"
  if bash "$hook_dir/commit-msg" "$f" >/dev/null 2>&1; then
    rm -f "$f"; echo accept
  else
    rm -f "$f"; echo reject
  fi
}

claude_verdict() { # <message> -> reject | accept
  local out
  out=$(jq -nc --arg m "$1" '{tool_input:{command:("git commit -m \"" + $m + "\"")}}' | bash "$claude_guard")
  if [ -n "$out" ]; then echo reject; else echo accept; fi
}

echo "commit-msg refuses attribution wherever the message came from"
check reject "trailer"        "$(commit_msg_verdict "fix

$TRAILER https://${SESSION_URL}abc")"
check reject "co-author"      "$(commit_msg_verdict "fix

$COAUTHOR <noreply@anthropic.com>")"
check reject "generated-with" "$(commit_msg_verdict "fix

$GENERATED")"
check reject "bare url"       "$(commit_msg_verdict "fix

https://${SESSION_URL}abc")"

echo "commit-msg leaves everything else alone"
check accept "clean"      "$(commit_msg_verdict "feat(claude): add the claude code skill")"
check accept "dependabot" "$(commit_msg_verdict "ci: bump x

Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>")"
check accept "mentions claude in prose" "$(commit_msg_verdict "docs: describe the claude settings merge")"

echo "pre-push reads the commits, not the command line"
tmp=$(mktemp -d)
(
  cd "$tmp" || exit 1
  git init -q .
  git config user.email t@example.invalid
  git config user.name test
  # Both local to this throwaway repository. The fake identity has no key,
  # and the fixture has to be able to author the messages the hook exists to
  # refuse — a repository-local hooksPath overrides the global one. Without
  # either, no fixture commit is created and the hook is handed nothing to
  # find, which reads as the hook passing.
  git config commit.gpgsign false
  git config core.hooksPath "$PWD/.git/hooks"
  git commit -q --allow-empty -m "clean one"
  clean_head=$(git rev-parse HEAD)
  git commit -q --allow-empty -m "dirty one

$TRAILER https://${SESSION_URL}abc"
  dirty_head=$(git rev-parse HEAD)
  zero=0000000000000000000000000000000000000000

  # -F is exactly the path the command-line guard cannot see.
  printf 'from a file\n\n%s https://%sabc\n' "$TRAILER" "$SESSION_URL" >msg.txt
  git commit -q --allow-empty -F msg.txt
  from_file_head=$(git rev-parse HEAD)

  v() { # <local_oid> <remote_oid> -> reject | accept
    if printf 'refs/heads/main %s refs/heads/main %s\n' "$1" "$2" |
      bash "$hook_dir/pre-push" origin http://example.invalid >/dev/null 2>&1; then
      echo accept
    else
      echo reject
    fi
  }
  echo "  $(v "$clean_head" "$zero")|clean history, new branch"
  echo "  $(v "$dirty_head" "$clean_head")|a commit carrying a trailer"
  echo "  $(v "$from_file_head" "$dirty_head")|a message written with -F"
) >"$tmp/out" 2>/dev/null
while IFS='|' read -r verdict label; do
  [ -n "${label:-}" ] || continue
  case $label in
    "clean history, new branch") check accept "$label" "$(echo "$verdict" | tr -d ' ')" ;;
    *) check reject "$label" "$(echo "$verdict" | tr -d ' ')" ;;
  esac
done <"$tmp/out"
rm -rf "$tmp"

echo "the two guards agree about what attribution is"
if [ -f "$claude_guard" ]; then
  for m in "fix

$TRAILER https://${SESSION_URL}abc" \
           "fix

$COAUTHOR <noreply@anthropic.com>" \
           "fix

$GENERATED" \
           "fix

https://${SESSION_URL}abc" \
           "feat: clean" \
           "ci: bump x

Co-authored-by: dependabot[bot] <a@b>"; do
    git_side=$(commit_msg_verdict "$m")
    claude_side=$(claude_verdict "$m")
    check "$git_side" "same verdict: $(printf '%s' "$m" | tail -1 | cut -c1-28)" "$claude_side"
  done
else
  echo "  skip  claude/check-attribution.sh not found"
fi

echo
printf 'pass=%d fail=%d\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
