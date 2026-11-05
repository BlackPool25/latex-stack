# Sync model — GitHub is the truth, every machine is a peer

There is exactly one shared state: the GitHub repo. Aldine (localhost),
VSCodium, and agents on each laptop all read/write through git.

## Daily loop (every machine, humans and agents)
```bash
git fetch --all --prune
git pull --rebase --autostash   # your branches only; main stays fast-forward
# ... edit (Aldine: use its Push/Pull buttons, same thing underneath) ...
make lint paper verify-refs
git push
```

## Two machines, one branch — the only procedure
1. Machine A pushes. Machine B runs `git pull --rebase --autostash`.
2. `.tex` conflict? Markers land in the file; open it, keep BOTH sentences
   unless they say the same thing (sentence-per-line makes this a 30s job).
3. `git add <file> && git rebase --continue`, then `make paper`, then push.
4. Never `push --force` on a shared branch. Your own branch with your own
   unpushed... no — even then, prefer a fixup commit. Force is banned by the
   ruleset on `main` and by convention everywhere else.

## Aldine rule (read carefully)
Aldine mounts the SAME clone you push from (`./paper` bind or volume copy —
see docs/setup.md option A/B). One editing place at a time: if Aldine has
unsaved work, don't edit those files in VSCodium until Aldine's Pull/Push
lands it in git. Git commits are the handoff, never the filesystem.

## Offline
Work freely; commits are local. On reconnect: fetch, rebase, push.
If someone merged first, you rebase — your work is never lost, only replayed.
