# LaTeX Stack — IEEE papers, self-hosted, CI-gated

Self-hosted collaborative LaTeX (Aldine) + local VSCodium editing +
GitHub as source of truth + CI that blocks bad PDFs.

## Install (every teammate, every machine)

```bash
git clone <repo-url> latex-stack && cd latex-stack
./scripts/setup.sh    # .env + git sync policy + toolchain check + gate proof
docker compose up -d  # Aldine at http://localhost:8080
```

Needs: git, Docker, TeX Live (`texlive-basic texlive-binextra
texlive-latexrecommended texlive-latexextra texlive-fontsrecommended
texlive-publishers texlive-bibtexextra` on Arch).

## Layout

| Path | What |
|---|---|
| `docker-compose.yml` / `.env.example` | Aldine app + sandboxed compiler |
| `paper/` | IEEEtran template: `main.tex`, `sections/`, `refs.bib`, latexmk/chktex/latexindent configs |
| `.github/workflows/latex.yml` | CI: chktex gate → latexmk build → undefined-ref grep → PDF artifact |
| `AGENTS.md` | Rules AI agents must follow here |
| `docs/sync.md` | Multi-machine workflow + conflict procedure |

## Publish to GitHub

```bash
cd latex-stack && git init -b main  # (already done if cloned from here)
gh repo create <org|user>/<name> --private --source=. --push
```

See `docs/sync.md` for the daily loop, second-machine pickup, and conflicts.
