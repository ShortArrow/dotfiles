#!/usr/bin/env bash
# Exercise check-gpg-cache.sh against the tool_input shapes the hook sees.
#
# The agent state is faked: a temporary directory holds a `gpg` that prints
# colon output for one key with a signing subkey, and a `gpg-connect-agent`
# that reports the keygrips cached or not according to $FAKE_CACHED. A
# temporary repository points gpg.program at the fake, so the test needs no
# real key and leaves the real agent alone.
set -u

script="$(dirname "$0")/check-gpg-cache.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

fake="$work/bin"
mkdir -p "$fake"
cat > "$fake/gpg" <<'EOF'
#!/usr/bin/env bash
# -K with colons: primary [SC] with keygrip AAAA, encryption subkey [E] with
# keygrip BBBB, signing subkey [S] with keygrip CCCC.
cat <<'OUT'
sec:u:255:22:0000000000000001:1728691200:::u:::scESC:::+:::ed25519:::0:
fpr:::::::::0000000000000000000000000000000000000001:
grp:::::::::AAAA:
ssb:u:255:18:0000000000000002:1728691200::::::e:::+:::cv25519::
grp:::::::::BBBB:
ssb:u:255:22:0000000000000003:1728691200::::::s:::+:::ed25519::
grp:::::::::CCCC:
OUT
EOF
cat > "$fake/gpg-connect-agent" <<'EOF'
#!/usr/bin/env bash
c=${FAKE_CACHED:-}
flag() { case " $c " in *" $1 "*) echo 1 ;; *) echo - ;; esac; }
echo "S KEYINFO AAAA D - - $(flag AAAA) P - - -"
echo "S KEYINFO BBBB D - - $(flag BBBB) P - - -"
echo "S KEYINFO CCCC D - - $(flag CCCC) P - - -"
echo OK
EOF
chmod +x "$fake/gpg" "$fake/gpg-connect-agent"

repo="$work/repo"
git init -q "$repo"
git -C "$repo" config commit.gpgsign true
git -C "$repo" config user.signingkey 0000000000000001
git -C "$repo" config gpg.program "$fake/gpg"

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

echo "denies a signed operation while nothing is cached"
FAKE_CACHED="" check deny "commit" 'git commit -m "feat: x"' "$repo"
FAKE_CACHED="" check deny "merge" 'git merge topic' "$repo"
FAKE_CACHED="" check deny "tag" 'git tag -a v1 -m v1' "$repo"
FAKE_CACHED="" check deny "chained" 'git add -A && git commit -m x' "$repo"
FAKE_CACHED="BBBB" check deny "only the encryption subkey cached" 'git commit -m x' "$repo"

echo "allows once a signing key is cached"
FAKE_CACHED="AAAA" check allow "primary cached" 'git commit -m x' "$repo"
FAKE_CACHED="CCCC" check allow "signing subkey cached" 'git commit -m x' "$repo"

echo "allows what does not sign"
FAKE_CACHED="" check allow "push" 'git push origin main' "$repo"
FAKE_CACHED="" check allow "log" 'git log --oneline -3' "$repo"
FAKE_CACHED="" check allow "status" 'git status' "$repo"
FAKE_CACHED="" check allow "no-gpg-sign" 'git commit --no-gpg-sign -m x' "$repo"
FAKE_CACHED="" check allow "gpgsign=false" 'git -c commit.gpgsign=false commit -m x' "$repo"
FAKE_CACHED="" check allow "unsigned repo" 'git commit -m x' "$unsigned"
FAKE_CACHED="" check allow "outside a repo" 'git commit -m x' "$work"
FAKE_CACHED="" check allow "mentions commit" 'echo "git commit later"' "$repo"

echo "handles malformed input"
FAKE_CACHED="" check allow "no command field" "" "$repo"

echo "the deny reason carries the unlock command"
out=$(jq -nc --arg c 'git commit -m x' --arg d "$repo" '{tool_input:{command:$c},cwd:$d}' | FAKE_CACHED="" bash "$script")
if printf '%s' "$out" | grep -q -- '--clearsign > /dev/null' && printf '%s' "$out" | grep -q 'gpg.program'; then
  pass=$((pass + 1)); echo "  ok   reason names gpg.program and --clearsign"
else
  fail=$((fail + 1)); echo "  FAIL reason: $out"
fi

echo
printf 'pass=%d fail=%d\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
