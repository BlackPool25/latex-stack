#!/usr/bin/env bash
# backup.sh — snapshot the repo state + Aldine volumes. Run daily/weekly.
# Usage: ./scripts/backup.sh [/var/backups/latex-stack]
set -euo pipefail
DEST="${1:-$HOME/backups/latex-stack}"
mkdir -p "$DEST"
STAMP="$(date +%F)"
# 1. Git bundle of every branch (full clone recovery without the forge)
git bundle create "$DEST/repo-$STAMP.bundle" --all
# 2. Aldine project volumes, if present
for vol in aldine-data aldine-secrets; do
  if docker volume inspect "$vol" >/dev/null 2>&1; then
    docker run --rm -v "$vol:/src:ro" -v "$DEST:/out" alpine \
      tar -czf "/out/$vol-$STAMP.tar.gz" -C /src .
  fi
done
ls -la "$DEST"
echo "restore: git clone repo-*.bundle ; docker volume create + tar -xzf (fresh names first)"
