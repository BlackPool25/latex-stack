# Multi-machine sync

GitHub is the source of truth. Aldine holds a live editing copy;
the repo holds the history. Never treat two Aldine instances as peers.

## First-time setup (every machine)

```bash
git clone <repo-url> latex-stack && cd latex-stack
./scripts/setup.sh    # .env + git sync policy + toolchain check + gate proof
docker compose up -d  # Aldine at http://localhost:8080
```

(`setup.sh` applies the sync policy as repo-local git config, so every
machine and teammate gets rebase + autostash + prune automatically.)

## Daily loop

```bash
make update                 # git rebase-pull + fresh images + restart
# ... edit in VSCodium and/or Aldine ...
git checkout -b paper/<slug>
git add paper/sections/results.tex paper/refs.bib
git commit -m "paper: add throughput results + 2 cites"
make lint && make paper
git push -u origin paper/<slug>   # open a PR; CI runs the gates
```

## Second computer picks up work

```bash
git fetch --all --prune
git checkout paper/<slug>   # or: git pull --rebase --autostash on main
make paper                  # rebuilds from history; latexmk -g if stale
```

## Conflicts (.tex)

1. `git status` — open each conflicted file in VSCodium, keep both sides'
   prose where valid, keep only one copy of labels/cite keys.
2. Never keep both `<<<<<<<` markers; never union-merge blindly.
3. Re-run `make lint && make paper` before `git add`.
4. Never force-push `main`. Force-push a feature branch only if you own it:
   `git push --force-with-lease`.

## Aldine <-> repo rule

- Edit in one place at a time. Before switching editors, commit or export.
- Aldine has real git branches: push Aldine work to the repo branch, then
  `git pull --rebase` on the other machine. No direct Aldine-to-Aldine sync.
