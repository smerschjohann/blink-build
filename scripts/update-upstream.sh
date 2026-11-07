#!/usr/bin/env bash
# Moves the blink submodule to the latest upstream 'raw' commit and verifies
# that every patch in patches/series still applies (dry run only, no commit).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

git submodule update --init --remote --depth 1 blink
echo "==> blink now at $(git -C blink rev-parse --short HEAD)"

if [ ! -s "$ROOT/patches/series" ]; then
  echo "==> patch series empty"
  exit 0
fi

fail=0
while IFS= read -r line || [ -n "$line" ]; do
  patch="${line%%#*}"
  patch="${patch//[[:space:]]/}"
  [ -z "$patch" ] && continue
  if git -C blink apply --check "$ROOT/patches/$patch"; then
    echo "ok       $patch"
  else
    echo "CONFLICT $patch"
    fail=1
  fi
done < "$ROOT/patches/series"

exit "$fail"
