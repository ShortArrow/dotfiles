#!/usr/bin/env bash
# Run every headless probe under nvim/tests/. Exit non-zero if any fails.
set -u

dir="$(cd "$(dirname "$0")" && pwd)"
fail=0

# Windows nvim cannot open MSYS-style /d/... paths; hand it native ones.
to_native() {
  cygpath -m "$1" 2>/dev/null || echo "$1"
}

# GNU timeout guards against a probe that never reaches qa!/cq!.
# Windows System32 timeout.exe is a different tool; probe for the GNU one.
runner=()
if timeout 1 true 2>/dev/null; then
  runner=(timeout 300)
fi

for t in "$dir"/*.lua; do
  echo "== ${t##*/}"
  if "${runner[@]}" nvim --headless "+luafile $(to_native "$t")" 2>&1; then
    echo "   PASS"
  else
    echo "   FAIL"
    fail=1
  fi
done

exit "$fail"
