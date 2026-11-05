# Setup guide — from zero to green gates

## 1. Prerequisites (all OSes)
- **Git** + **Docker** (Docker Desktop on Windows/macOS; engine on Linux).
  Windows runs everything inside WSL2 — install Docker Desktop with WSL2 backend.
- A GitHub account with access to this repo.

## 2. Clone + bootstrap
```bash
git clone <repo-url> latex-stack && cd latex-stack
./scripts/setup.sh
```
`setup.sh` creates `.env`, applies repo-local sync policy (rebase + autostash +
prune, sentence-aware word diff), checks Docker, then proves the gates through
the pinned container toolchain: `make lint`, `make paper`, `verify-refs --offline`.

## 3. Optional: local TeX fast path (skips container startup)
| OS | Command |
|----|---------|
| Arch/Omarchy | `sudo pacman -S --needed texlive-basic texlive-binextra texlive-latexrecommended texlive-latexextra texlive-fontsrecommended texlive-publishers texlive-bibtexextra biber chktex` |
| Ubuntu/Debian | `sudo apt install -y texlive-latex-recommended texlive-latex-extra texlive-publishers texlive-bibtex-extra biber chktex latexmk python3` |
| Fedora | `sudo dnf install -y texlive-scheme-medium texlive-collection-publishers texlive-collection-bibtexextra biber chktex latexmk` |
| macOS | MacTeX (full) or BasicTeX + missing packages; `brew install chktex` |
With complete local TeX, `make` uses it automatically (`USE_DOCKER=auto`).
Force either path: `make paper USE_DOCKER=0` (local) or `=1` (container).

## 4. Aldine (optional solo editor, per machine)
```bash
docker compose up -d   # http://localhost:8080, no login (localhost-only)
```
- **Option A (same clone):** point Aldine at `./paper` via a project rooted in
  this checkout — commits you make in Aldine are commits you push.
- **Option B (separate):** keep Aldine's copy in `~/aldine/` and move text
  across via `git pull/push` between the two clones.
- Rule: one editing place at a time — git commits are the handoff (docs/sync.md).

## 5. SSH commit signing (required within a week of joining)
```bash
ssh-keygen -t ed25519 -C "you@example.org"   # or reuse your auth key
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
# GitHub → Settings → SSH and GPG keys → New SSH key → Signing Key, paste the .pub
```
The branch ruleset will start rejecting unsigned commits after rollout.

## 6. Branch protection (maintainer, once per repo)
```bash
gh api repos/{owner}/{repo}/rulesets --input infra/github-rulesets/main.json
# then replace @TEAM-HANDLE / @BIB-HANDLE in .github/CODEOWNERS with real handles
```

## 7. New paper from this template
```bash
# fork the template repo per paper (recommended): GitHub → Use this template,
# or: git clone template && git remote set-url origin <new-repo-url>
git checkout -b paper/<slug>
# fill paper/main.tex, paper/sections/*, paper/refs.bib (real DOIs only)
make lint paper verify-refs && git push   # open PR, get review, human merges
```
Tags drive the lifecycle: `v1.0.0-submitted-<venue><yy>`, `v1.1.0-R1`,
`v2.0.0-camera`, `arxiv-vN`. Pushing a `v*` tag builds `final.pdf` +
`arxiv.tar.gz` and attaches them to a GitHub Release (Zenodo mints the DOI).
