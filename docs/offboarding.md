# Offboarding a collaborator

Run within 24h of departure. GitHub first (fastest to abuse), Aldine second.

## GitHub
1. Repo → Settings → Collaborators & teams → remove person/team.
2. Settings → Secrets and variables → Actions → rotate every secret.
3. Revoke their access tokens: org/team audit, their PATs (ask them to delete;
   you cannot delete another user's PAT — rotate exposed secrets instead).
4. Check Settings → Deploy keys / Installed GitHub Apps; remove theirs.
5. Confirm no open PRs/branches owned solely by them that must be kept.
6. Review repo audit log (Insights → Audit) for exfiltration signs.

## Local / Aldine (per-machine, each owner does their own)
1. Nothing shared to revoke — Aldine runs solo localhost, no accounts.
2. If the shared GitHub repo held secrets used locally (it must not), rotate them.
3. Wipe `.env` and build caches if handing the laptop on.

## Verification
- `git ls-remote` shows no unexpected keys; collaborator list is current.
- CI still green on `main` after secret rotation (re-run `latex-build`).
