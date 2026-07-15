#!/usr/bin/env bash
# Run every headless probe under nvim/tests/. Exit non-zero if any fails.
set -u

dir="$(cd "$(dirname "$0")" && pwd)"
fail=0

for t in "$dir"/*.lua; do
  echo "== ${t##*/}"
  if nvim --headless "+luafile $t" 2>&1; then
    echo "   PASS"
  else
    echo "   FAIL"
    fail=1
  fi
done

exit "$fail"
