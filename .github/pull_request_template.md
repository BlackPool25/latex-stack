## What / Why

## Checklist
- [ ] `make paper` clean (or CI `latex-build` green)
- [ ] `make arxiv` tarball standalone-compiles from empty dir
- [ ] Review build attached (no author names, metadata scrubbed)
- [ ] No committed PDFs, aux files, or secrets (`git status --porcelain` clean except `.tex/.bib/.yaml/.rc`)
- [ ] Citations: every `\cite` resolves, every DOI opened or verified
