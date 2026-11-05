#!/usr/bin/env bash
# setup.sh — one-command teammate bootstrap. Idempotent, safe to re-run.
# Docker-first: the container toolchain is the default. Local TeX is an
# optional fast path. Usage: ./scripts/setup.sh
set -euo pipefail
cd "$(dirname "$0")/.."

OS="unknown"
[ -f /etc/os-release ] && . /etc/os-release
case "${ID:-}${WSL_DISTRO_NAME:-}" in
  *arch*|omarchy) PKG="sudo pacman -S --needed texlive-basic texlive-binextra texlive-latexrecommended texlive-latexextra texlive-fontsrecommended texlive-publishers texlive-bibtexextra biber chktex" ;;
  *ubuntu*|*debian*) PKG="sudo apt install -y texlive-latex-recommended texlive-latex-extra texlive-publishers texlive-bibtex-extra biber chktex latexmk python3" ;;
  *fedora*) PKG="sudo dnf install -y texlive-scheme-medium texlive-collection-publishers texlive-collection-bibtexextra biber chktex latexmk" ;;
  *) PKG="(see docs/setup.md for your OS)" ;;
esac

[ -f .env ] || { cp .env.example .env; echo "created .env"; }

git config pull.rebase true
git config rebase.autostash true
git config fetch.prune true
git config push.autoSetupRemote true
git config include.path ../.gitconfig 2>/dev/null || git config include.path .gitconfig
echo "git sync policy + tex word-diff applied (repo-local)"

command -v docker >/dev/null || { echo "MISSING docker — install Docker Desktop (docs/setup.md), then re-run"; exit 1; }
docker info >/dev/null 2>&1 || { echo "docker installed but daemon not running — start it, then re-run"; exit 1; }

LOCAL_TEX=0
if command -v lualatex chktex latexindent biber python3 >/dev/null 2>&1 \
   && kpsewhich IEEEtran.cls >/dev/null 2>&1; then
  LOCAL_TEX=1
fi
if [ "$LOCAL_TEX" = 1 ]; then
  echo "local TeX complete — Make will use the fast path (USE_DOCKER=auto)"
else
  echo "local TeX incomplete — Make will use the container toolchain."
  echo "optional fast path later: $PKG"
fi

if ! git config user.signingkey >/dev/null; then
  echo "NOTE: no SSH signing key configured — see docs/setup.md (signing rolls out this week)"
fi

make lint USE_DOCKER=1 && make paper USE_DOCKER=1 && python3 scripts/verify-refs.py --offline
echo "setup complete: gates green via container. Aldine: docker compose up -d"
