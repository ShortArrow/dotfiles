#!/bin/bash
#
# migrate-project.sh — move a repository's directory while preserving
# `claude --resume` history for that project.
#
# Claude stores per-project session logs under
# ~/.claude/projects/<cwd-with-slashes-as-dashes>/, and each session
# .jsonl also records the absolute cwd as "cwd":"<path>". Moving a repo
# to a new path (e.g. into ghq layout) orphans that history unless BOTH
# the directory name and the in-file cwd are rewritten to the new path.
#
# This script rewrites both. It is dry-run by default; pass --apply to
# make changes. The projects directory is backed up before any write.
#
# Usage:
#   migrate-project.sh <old-abs-path> <new-abs-path>            # dry-run
#   migrate-project.sh --apply <old-abs-path> <new-abs-path>    # apply
#
# Guard: this script encodes assumptions about Claude's on-disk session
# format (see SUPPORTED_MAJOR). If `claude --version` reports a different
# major version, the format may have changed and the script refuses to
# run — re-verify the layout and bump SUPPORTED_MAJOR intentionally.

set -euo pipefail

# --- schema-version guard --------------------------------------------------
# Verified against the layout produced by Claude Code 2.x:
#   - ~/.claude/projects/<path-with-/-as-->/
#   - session *.jsonl containing "cwd":"<abs path>"
SUPPORTED_MAJOR=2

guard_version() {
  # Resolve claude even from a non-interactive shell where mise shims may
  # not be on PATH (this script is often invoked as `bash migrate-project.sh`).
  local claude_bin
  claude_bin="$(command -v claude || true)"
  if [ -z "$claude_bin" ] && [ -x "$HOME/.local/share/mise/shims/claude" ]; then
    claude_bin="$HOME/.local/share/mise/shims/claude"
  fi
  if [ -z "$claude_bin" ]; then
    echo "ABORT: 'claude' not found on PATH — cannot verify the session format version." >&2
    echo "       Run this from a shell where 'claude' resolves, or install it first." >&2
    exit 3
  fi

  local ver major
  ver="$("$claude_bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  if [ -z "$ver" ]; then
    echo "ABORT: could not read a version from '$claude_bin --version' — refusing to touch session files." >&2
    exit 3
  fi
  major="${ver%%.*}"
  if [ "$major" != "$SUPPORTED_MAJOR" ]; then
    echo "ABORT: claude major version is $major (v$ver) but this script was verified for $SUPPORTED_MAJOR." >&2
    echo "       Session storage format may have changed. Re-verify and bump SUPPORTED_MAJOR." >&2
    exit 3
  fi
}

# --- argument parsing -------------------------------------------------------
APPLY=0
if [ "${1:-}" = "--apply" ]; then APPLY=1; shift; fi

OLD="${1:-}"
NEW="${2:-}"
if [ -z "$OLD" ] || [ -z "$NEW" ]; then
  echo "usage: $0 [--apply] <old-abs-path> <new-abs-path>" >&2
  exit 2
fi
case "$OLD$NEW" in
  /*/*) : ;;
  *) echo "ABORT: both paths must be absolute." >&2; exit 2 ;;
esac

PROJECTS="$HOME/.claude/projects"
encode() { printf '%s' "$1" | tr '/' '-'; }
OLD_DIR="$PROJECTS/$(encode "$OLD")"
NEW_DIR="$PROJECTS/$(encode "$NEW")"

# --- preflight --------------------------------------------------------------
guard_version

if [ ! -d "$OLD_DIR" ]; then
  echo "No session history for $OLD (looked for $OLD_DIR) — nothing to migrate."
  exit 0
fi
if [ -e "$NEW_DIR" ]; then
  echo "ABORT: destination project dir already exists: $NEW_DIR" >&2
  exit 4
fi

# grep exits 1 on zero matches; under `set -e` that must not abort us.
hits="$(grep -rl "\"cwd\":\"$OLD\"" "$OLD_DIR" 2>/dev/null | wc -l || true)"

echo "Project session migration"
echo "  from : $OLD"
echo "  to   : $NEW"
echo "  dir  : $OLD_DIR"
echo "       -> $NEW_DIR"
echo "  jsonl files containing old cwd: $hits"

if [ "$APPLY" -ne 1 ]; then
  echo
  echo "DRY-RUN. Re-run with --apply as the first argument to perform the migration."
  exit 0
fi

# --- apply ------------------------------------------------------------------
BACKUP="$PROJECTS/.backup-$(encode "$OLD")"
echo "Backing up -> $BACKUP"
rm -rf "$BACKUP"
cp -a "$OLD_DIR" "$BACKUP"

# rewrite in-file cwd, then rename the directory
grep -rl "\"cwd\":\"$OLD\"" "$OLD_DIR" 2>/dev/null | while IFS= read -r f; do
  sed -i "s#\"cwd\":\"$OLD\"#\"cwd\":\"$NEW\"#g" "$f"
done || true
mv "$OLD_DIR" "$NEW_DIR"

# verify no stale cwd remains (grep exits 1 on zero matches — the good case)
remain="$(grep -rl "\"cwd\":\"$OLD\"" "$NEW_DIR" 2>/dev/null | wc -l || true)"
if [ "$remain" -ne 0 ]; then
  echo "WARNING: $remain file(s) still reference the old cwd. Backup kept at $BACKUP." >&2
  exit 5
fi

echo "Done. Migrated $hits file(s). Backup kept at $BACKUP (remove once verified)."
