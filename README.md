# latex-stack — IEEE conference paper factory

Template + gates + automation for multi-author LaTeX papers. GitHub is the
single shared truth; every machine (Linux/Windows/macOS) builds identically
through a pinned container toolchain.

## Install (5 min)
1. Install Git + Docker ([details](docs/setup.md)).
2. `git clone <repo-url> latex-stack && cd latex-stack && ./scripts/setup.sh`
3. Optional solo editor: `docker compose up -d` (Aldine, localhost only).

## Daily use
| Task | Command |
|------|---------|
| Sync | `git fetch --all --prune && git pull --rebase --autostash` |
| Lint / build / citations | `make lint paper verify-refs` |
| Review (anon) / camera-ready | `make review` / `make final` |
| arXiv tarball | `make arxiv` |
| Backup | `./scripts/backup.sh` |

## How it connects
- **Format** — `paper/main.tex` locks IEEEtran conf + LuaLaTeX; `.chktexrc`,
  `latexindent.yaml`, `.latexmkrc` (warnings-as-errors) enforced by `make` and CI.
- **Sync** — [docs/sync.md](docs/sync.md): fetch → rebase → push; Aldine commits
  through git; conflicts keep both sentences.
- **AI agents** — [AGENTS.md](AGENTS.md): branch-per-paper, PR-only, humans merge.
- **Reviews** — [responses/](responses/): one letter per round, tagged per release.
- **Joining/leaving** — [docs/setup.md](docs/setup.md), [docs/offboarding.md](docs/offboarding.md).

## CI gates (all required on `main`)
`latex-build` (ChkTeX + build + standalone arXiv check) · `cite-check`
(key/DOI integrity) · `pre-commit` (format, markers, secrets). Weekly schedule
catches template rot. `v*` tags trigger the `release` workflow (PDF + tarball).
