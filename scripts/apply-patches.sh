#!/usr/bin/env bash
# Applies the patches listed in patches/series inside the blink submodule.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -s "$ROOT/patches/series" ]; then
  echo "==> patch series empty, nothing to apply"
  exit 0
fi

cd "$ROOT/blink"

while IFS= read -r line || [ -n "$line" ]; do
  patch="${line%%#*}"
  patch="${patch//[[:space:]]/}"
  [ -z "$patch" ] && continue
  echo "==> $patch"
  git apply "$ROOT/patches/$patch"
done < "$ROOT/patches/series"

echo "==> patches applied"
