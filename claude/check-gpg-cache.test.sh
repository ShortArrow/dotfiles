#!/usr/bin/env bash
# Exercise check-gpg-cache.sh against the tool_input shapes the hook sees.
#
# The agent state is faked: a temporary directory holds a `gpg` that signs
# only while $FAKE_UNLOCKED is set, as a real gpg run with --pinentry-mode
# error succeeds only when the agent can sign without asking. It knows the
# key 0000000000000001 alone and logs every argument list, so the test can
# see which key the trial signature named. A temporary repository points
# gpg.program at the fake, so the test needs no real key and leaves the real
# agent alone.
set -u

script="$(dirname "$0")/check-gpg-cache.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

fake="$work/bin"
mkdir -p "$fake"
export FAKE_GPG_LOG="$work/gpg.log"
cat > "$fake/gpg" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$FAKE_GPG_LOG"
known=0
case " $* " in *" 0000000000000001 "*) known=1 ;; esac
case " $* " in
  *" --clearsign "*)
    cat > /dev/null
    if [ "$known" -eq 1 ] && [ -n "${FAKE_UNLOCKED:-}" ]; then
      echo "-----BEGIN PGP SIGNED MESSAGE-----"; exit 0
    fi
    echo "gpg: signing failed: No pinentry" >&2; exit 2 ;;
  *" -K "*)
    [ "$known" -eq 1 ] && { echo "sec:u:255:22:0000000000000001:::::::scESC:"; exit 0; }
    echo "gpg: error reading key: No secret key" >&2; exit 2 ;;
esac
exit 2
EOF
chmod +x "$fake/gpg"

repo="$work/repo"
git init -q "$repo"
git -C "$repo" config commit.gpgsign true
git -C "$repo" config user.signingkey 0000000000000001
git -C "$repo" config gpg.program "$fake/gpg"

unknown="$work/unknown"
git init -q "$unknown"
git -C "$unknown" config commit.gpgsign true
git -C "$unknown" config user.signingkey 00000000000000FF
git -C "$unknown" config gpg.program "$fake/gpg"

unsigned="$work/unsigned"
git init -q "$unsigned"
git -C "$unsigned" config commit.gpgsign false

pass=0
fail=0

# verdict <command> <cwd> -> "deny" or "allow"
verdict() {
  local out
  out=$(jq -nc --arg c "$1" --arg d "$2" '{tool_input:{command:$c},cwd:$d}' | bash "$script")
  if [ -n "$out" ]; then echo deny; else echo allow; fi
}

check() { # <expected> <label> <command> <cwd>
  local got
  got=$(verdict "$3" "$4")
  if [ "$got" = "$1" ]; then
    pass=$((pass + 1))
    printf '  ok   %-6s %s\n' "$1" "$2"
  else
    fail=$((fail + 1))
    printf '  FAIL want=%s got=%s  %s\n' "$1" "$got" "$2"
  fi
}

echo "denies a signed operation while the key cannot sign without pinentry"
FAKE_UNLOCKED="" check deny "commit" 'git commit -m "feat: x"' "$repo"
FAKE_UNLOCKED="" check deny "merge" 'git merge topic' "$repo"
FAKE_UNLOCKED="" check deny "tag" 'git tag -a v1 -m v1' "$repo"
FAKE_UNLOCKED="" check deny "chained" 'git add -A && git commit -m x' "$repo"

echo "allows once the key signs without pinentry"
FAKE_UNLOCKED=1 check allow "commit" 'git commit -m x' "$repo"

echo "the trial signature names the signing key and never prompts"
: > "$FAKE_GPG_LOG"
FAKE_UNLOCKED=1 verdict 'git commit -m x' "$repo" > /dev/null
trial=$(grep -- '--clearsign' "$FAKE_GPG_LOG" || true)
if printf '%s' "$trial" | grep -q -- '--local-user 0000000000000001' &&
   printf '%s' "$trial" | grep -q -- '--pinentry-mode error'; then
  pass=$((pass + 1)); echo "  ok   trial: $trial"
else
  fail=$((fail + 1)); echo "  FAIL trial: ${trial:-<none>}"
fi

echo "allows what does not sign"
FAKE_UNLOCKED="" check allow "push" 'git push origin main' "$repo"
FAKE_UNLOCKED="" check allow "log" 'git log --oneline -3' "$repo"
FAKE_UNLOCKED="" check allow "status" 'git status' "$repo"
FAKE_UNLOCKED="" check allow "no-gpg-sign" 'git commit --no-gpg-sign -m x' "$repo"
FAKE_UNLOCKED="" check allow "gpgsign=false" 'git -c commit.gpgsign=false commit -m x' "$repo"
FAKE_UNLOCKED="" check allow "unsigned repo" 'git commit -m x' "$unsigned"
FAKE_UNLOCKED="" check allow "outside a repo" 'git commit -m x' "$work"
FAKE_UNLOCKED="" check allow "mentions commit" 'echo "git commit later"' "$repo"
FAKE_UNLOCKED="" check allow "key not in the keyring" 'git commit -m x' "$unknown"

echo "handles malformed input"
FAKE_UNLOCKED="" check allow "no command field" "" "$repo"

echo "the deny reason carries the unlock command for the signing key"
out=$(jq -nc --arg c 'git commit -m x' --arg d "$repo" '{tool_input:{command:$c},cwd:$d}' | FAKE_UNLOCKED="" bash "$script")
if printf '%s' "$out" | grep -q -- '-u 0000000000000001 --clearsign > /dev/null' && printf '%s' "$out" | grep -q 'gpg.program'; then
  pass=$((pass + 1)); echo "  ok   reason names gpg.program, the key and --clearsign"
else
  fail=$((fail + 1)); echo "  FAIL reason: $out"
fi

echo
printf 'pass=%d fail=%d\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
