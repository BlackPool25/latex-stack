# Agent rules — latex-stack (IEEE conference, LuaLaTeX-only)

## Stack (do not change unilaterally)
- Build: `make paper` (LuaLaTeX, warnings-as-errors). Container-first: Makefile
  auto-uses the pinned toolchain image when local TeX is incomplete.
- Lint: `make lint` (paper/.chktexrc). Format: `make format` (paper/latexindent.yaml).
- Citations: `make verify-refs` (blocking). Placeholder/EXAMPLE DOIs fail CI — replace with real ones.
- MCP: `.mcp.json` pins the servers; shell `make` is the fallback. Never invent another build path.

## Workflow
- One paper = one branch `paper/<slug>[-<agent>]`. Never push to `main`.
- Rebase before pushing: `git pull --rebase --autostash`. Conflicts: keep both
  text, never delete the other author's sentences; ask if semantic.
- Sentence-per-line in `.tex` (one sentence per line, wrap at 80 cols) — this is
  what makes merges and diffs readable. `.gitconfig` word-diff is auto-loaded by setup.sh.
- Commits: `paper:/fix:/ci:/docs:/chore:` prefix, one file per commit.
  Sign every commit (SSH signing per docs/setup.md).
  Add trailer for agent work: `Co-authored-by: <agent-name> <agent@example.invalid>`.

## Authority (hard limits)
- Agents may: create branches, push branches, open PRs, run all gates.
- Agents may NOT: merge PRs, push to `main`, approve PRs, edit `infra/`,
  `.github/workflows/`, `docker-compose*.yml` without a human-approved plan.
- `main` merges are human-only after 1 review + green CI (`latex-build`, `cite-check`, `pre-commit`).

## Done = all of
1. `make lint paper verify-refs` green locally (or identical CI jobs green).
2. Every number in prose matches a table/figure/log value.
3. Every DOI resolves (script-checked, not claimed).
4. PR description lists what changed + the verification run.
5. No PDFs/aux/`.env`/anonymous.flag committed (`git status --porcelain` shows only sources).

## Never
- Read `.env` contents into chat/commits. No secrets in repo, ever.
- Edit images/`.cls`/`.bst`, or `git push --force` (owner-only `--force-with-lease` on your own branch).
- Commit build artifacts — CI publishes PDFs as artifacts/Releases.
