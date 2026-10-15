#!/usr/bin/env bash
# Exercise check-content-parity.sh in throwaway repositories, one per case,
# laid out as the site is: content/<section>/<name>.<lang>.md.
set -u

script="$(cd "$(dirname "$0")" && pwd)/check-content-parity.sh"

pass=0
fail=0

# fresh -> path of a new repository holding the script under scripts/
fresh() {
  local dir
  dir=$(mktemp -d)
  git -C "$dir" init -q
  git -C "$dir" config user.email test@example.invalid
  git -C "$dir" config user.name test
  git -C "$dir" config commit.gpgsign false
  mkdir -p "$dir/scripts" "$dir/content/notes"
  cp "$script" "$dir/scripts/"
  printf '%s\n' "$dir"
}

# page <repo> <relative path> <text>
page() { printf '%s\n' "$3" >"$1/$2"; }

# commit <repo> <message> [date]
commit() {
  git -C "$1" add -A
  GIT_AUTHOR_DATE=${3:-} GIT_COMMITTER_DATE=${3:-} git -C "$1" commit -q -m "$2"
}

# run <repo> -> sets $out and $code
run() {
  out=$(cd "$1" && bash scripts/check-content-parity.sh 2>&1)
  code=$?
}

check() { # <label> <want exit> [text the output must contain]
  if [ "$code" -eq "$2" ] && { [ -z "${3:-}" ] || grep -qF -- "$3" <<<"$out"; }; then
    pass=$((pass + 1))
    printf '  ok   %s\n' "$1"
  else
    fail=$((fail + 1))
    printf '  FAIL %s (exit %s)\n%s\n' "$1" "$code" "$(sed 's/^/       /' <<<"$out")"
  fi
}

echo "pages present and edited together pass"
r=$(fresh)
page "$r" content/notes/a.en.md "a"
page "$r" content/notes/a.ja.md "あ"
page "$r" content/notes/_index.en.md "index"
page "$r" content/notes/_index.ja.md "索引"
commit "$r" both
run "$r"
check "a pair in step" 0 "OK"

echo "a page in one language only fails"
r=$(fresh)
page "$r" content/notes/a.en.md "a"
commit "$r" en-only
run "$r"
check "missing Japanese counterpart" 1 "content/notes/a.ja.md is missing (content/notes/a.en.md exists)"

r=$(fresh)
page "$r" content/notes/a.ja.md "あ"
commit "$r" ja-only
run "$r"
check "missing English counterpart" 1 "content/notes/a.en.md is missing (content/notes/a.ja.md exists)"

echo "a page edited on one side fails, from either side"
r=$(fresh)
page "$r" content/notes/a.en.md "a"
page "$r" content/notes/a.ja.md "あ"
commit "$r" both "2026-01-01T00:00:00Z"
page "$r" content/notes/a.en.md "a, revised"
commit "$r" en-edit "2026-01-02T00:00:00Z"
run "$r"
check "Japanese behind" 1 "content/notes/a.ja.md is behind content/notes/a.en.md"

r=$(fresh)
page "$r" content/notes/a.en.md "a"
page "$r" content/notes/a.ja.md "あ"
commit "$r" both "2026-01-01T00:00:00Z"
page "$r" content/notes/a.ja.md "あ、改訂"
commit "$r" ja-edit "2026-01-02T00:00:00Z"
run "$r"
check "English behind" 1 "content/notes/a.en.md is behind content/notes/a.ja.md"

echo "a declared one-sided edit passes"
page "$r" scripts/parity-exceptions.txt "content/notes/a.ja.md $(git -C "$r" rev-parse HEAD)"
commit "$r" declare "2026-01-03T00:00:00Z"
run "$r"
check "exception for the newest commit" 0 "OK"

echo "an uncommitted page is not judged"
r=$(fresh)
page "$r" content/notes/a.en.md "a"
page "$r" content/notes/a.ja.md "あ"
commit "$r" both
page "$r" content/notes/a.ja.md "あ、未コミット"
run "$r"
check "dirty tree" 1 "not committed"

echo "pages outside the opted-in sections are not compared"
r=$(fresh)
page "$r" content/notes/a.en.md "a"
page "$r" content/notes/a.ja.md "あ"
page "$r" content/privacypolicy.en.md "policy"
mkdir -p "$r/content/docs"
page "$r" content/docs/_index.en.md "docs"
commit "$r" extra
run "$r"
check "English-only page outside notes" 0 "OK"

printf '\npass=%d fail=%d\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
