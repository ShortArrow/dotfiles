#!/usr/bin/env bash
#
# Fail when a translated page is missing or has fallen behind its source.
#
# Hugo mirrors content under content/<lang>/, so a page exists in each
# language at the same relative path. Two things go wrong with that, and
# neither shows up in a build: a page is added in one language only, and a
# page is edited in one language while its counterpart keeps the old text.
# The second is the quiet one — the site still renders, just wrong.
#
# Staleness is judged by the commit that last touched each file, not by
# mtime, which a checkout does not preserve.
#
# Sections are opted in rather than enforced everywhere: the docs section is
# the tool readmes, mounted from beside the configuration they document, and
# those are English in both languages by design. Add a section here once both
# languages actually have their own pages.

set -euo pipefail

SECTIONS=("notes")
LANGS=("en" "ja")
EXCEPTIONS="scripts/parity-exceptions.txt"
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

fail=0

note() { printf '%s\n' "$1"; }
bad() { printf 'NG  %s\n' "$1"; fail=1; }

# Empty for a file git has never recorded, which `|| echo 0` does not catch
# because git itself succeeded. An unset value reaches [ as a syntax error and
# the comparison is skipped, so the check passes without having run.
last_commit_epoch() {
  local recorded
  recorded=$(git log -1 --format=%ct -- "$1" 2>/dev/null || true)
  printf '%s' "${recorded:-0}"
}

last_commit_sha() {
  git log -1 --format=%h -- "$1" 2>/dev/null || true
}

# Some edits belong to one language and have no counterpart: a Japanese
# spacing fix, an English article. Timestamps cannot tell those from a
# translation left behind, so they are declared instead — path and the commit
# that is allowed to stand alone, in scripts/parity-exceptions.txt.
declared_alone() {
  local path=$1 sha=$2
  [ -n "$sha" ] || return 1
  [ -f "$EXCEPTIONS" ] || return 1
  grep -vE '^[[:space:]]*(#|$)' "$EXCEPTIONS" |
    awk '{ print $1, $2 }' |
    grep -qxF "$path $sha"
}

for section in "${SECTIONS[@]}"; do
  note "== ${section} =="

  # Every page must exist in every language.
  for lang in "${LANGS[@]}"; do
    dir="content/${lang}/${section}"
    [ -d "$dir" ] || continue
    while IFS= read -r path; do
      rel="${path#content/${lang}/}"
      for other in "${LANGS[@]}"; do
        [ "$other" = "$lang" ] && continue
        counterpart="content/${other}/${rel}"
        if [ ! -e "$counterpart" ]; then
          bad "${counterpart} is missing (${path} exists)"
        fi
      done
    done < <(find "$dir" -name '*.md' -type f | sort)
  done

  # A page edited on one side and not the other is out of date, whichever
  # side is older. Reported once per pair, from the newer side.
  base="content/${LANGS[0]}/${section}"
  [ -d "$base" ] || continue
  while IFS= read -r path; do
    rel="${path#content/${LANGS[0]}/}"
    for other in "${LANGS[@]:1}"; do
      counterpart="content/${other}/${rel}"
      [ -e "$counterpart" ] || continue
      a=$(last_commit_epoch "$path")
      b=$(last_commit_epoch "$counterpart")
      if [ "$a" -gt "$b" ]; then
        declared_alone "$path" "$(last_commit_sha "$path")" ||
          bad "${counterpart} is behind ${path}"
      elif [ "$b" -gt "$a" ]; then
        declared_alone "$counterpart" "$(last_commit_sha "$counterpart")" ||
          bad "${path} is behind ${counterpart}"
      fi
    done
  done < <(find "$base" -name '*.md' -type f | sort)
done

if [ "$fail" -eq 0 ]; then
  note "OK  every opted-in section is in step across ${LANGS[*]}"
fi

exit "$fail"
