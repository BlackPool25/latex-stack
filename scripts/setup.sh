#!/usr/bin/env bash
# One-command teammate bootstrap. Idempotent — safe to re-run.
# Usage: ./scripts/setup.sh
set -euo pipefail
cd "$(dirname "$0")/.."

# 1. Environment file (never committed; holds ports/versions only, no secrets)
if [ ! -f .env ]; then
  cp .env.example .env
  echo "created .env from .env.example"
fi

# 2. Sync discipline, enforced as LOCAL repo config (travels with neither
#    global state nor memory — every clone gets it via this script)
git config pull.rebase true
git config rebase.autostash true
git config fetch.prune true
git config push.autoSetupRemote true
echo "git sync policy applied (rebase + autostash + prune + autoSetupRemote)"

# 3. Toolchain presence check — fail fast with the exact fix
missing=0
for t in git docker latexmk chktex latexindent; do
  command -v "$t" >/dev/null 2>&1 || { echo "MISSING: $t"; missing=1; }
done
for c in IEEEtran.cls IEEEtran.bst; do
  kpsewhich "$c" >/dev/null 2>&1 || { echo "MISSING TeX class: $c (Arch: sudo pacman -S texlive-publishers texlive-bibtexextra)"; missing=1; }
done
[ "$missing" -eq 0 ] && echo "toolchain OK" || { echo "install the MISSING items above, then re-run"; exit 1; }

# 4. Prove the gates on the template paper
make lint && make paper
echo "setup complete: Aldine at http://localhost:$(grep ALDINE_PORT .env | cut -d= -f2)"
