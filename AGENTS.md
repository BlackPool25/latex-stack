# AGENTS.md — rules for AI agents working in this repo

## Stack
- Venue default: IEEE conference (`paper/main.tex`, IEEEtran, conf mode).
- Engine: LuaLaTeX only, via `make paper`. Never add `fontspec`.
- Bibliography: classic BibTeX + `IEEEtran.bst` for submissions.
  biblatex is allowed in drafts only, never in `main.tex`.

## Definition of done (all must pass)
1. `make lint` exits 0 (ChkTeX must-fail gate).
2. `make paper` exits 0 (warnings-as-errors; force with `latexmk -g` if stale).
3. No `undefined`/`multiply defined` in `main.log`.
4. Every number in prose matches a table, figure, or log.
5. Every `\cite` resolves: key exists in `refs.bib`, DOI verified via
   CrossRef/Semantic Scholar. Fabricated citations = task failure.

## Git discipline
- One branch per paper/feature: `paper/<slug>` or `feat/<what>`.
- `git pull --rebase --autostash` before pushing. Never force-push `main`.
- One file per commit when possible; conventional messages
  (`paper:`, `fix:`, `ci:`, `docs:`, `chore:`).
- Never commit PDFs, aux files, or `.env` (all gitignored).

## Editing limits
- Never edit `docker-compose.yml` images or `.cls`/`.bst` files.
- `latexindent.yaml`, `.chktexrc`, `.latexmkrc` change only with human approval.
- Anonymized review builds (when asked): anonymous mode + SubmissionID,
  scrub PDF metadata, no self-identifying prose; `git log` must stay clean.
