#!/usr/bin/env bash
# Fetch the pinned OpenCraft sources (Pojlib + Unity wrapper).
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v git-lfs >/dev/null 2>&1; then
  echo "git-lfs is required (Pojlib stores its native .so libraries in LFS)." >&2
  echo "Install it with: brew install git-lfs && git lfs install" >&2
  exit 1
fi

git submodule update --init --recursive pojlib wrapper
git -C pojlib lfs pull

echo
echo "Pinned sources:"
git -C pojlib  log -1 --format='  pojlib   %h  %ad  %s' --date=short
git -C wrapper log -1 --format='  wrapper  %h  %ad  %s' --date=short
