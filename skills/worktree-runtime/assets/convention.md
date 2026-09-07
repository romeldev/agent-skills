# Minimal port convention (only when the project has none)

Every real project eventually needs a convention; do not invent per-worktree
ad-hoc numbers forever. The convention below is the smallest that works. If the
project already has one — even an undocumented one visible in `.env` files or
the Makefile — obey the existing one (Hard Rule 6) and record it.

## Rule

`<service-prefix><worktree-suffix>` — four digits:

- **prefix** (first two digits) identifies the **service family**;
- **suffix** (last two digits) identifies the **worktree index**.

All services of one worktree share the same suffix. The suffix also names the
front→back link (proxy/API base), so the whole graph stays tied together.

## Suggested prefixes (any consistent scheme works)

| Service family | Prefix | Example |
| --- | --- | --- |
| Web frontend / SPA | `30` | `3011` |
| API / backend | `80` | `8011` |
| Admin/UI tooling | `50` | `5011` |
| Auxiliary (workers, mail, metrics) | `60` + custom | `6011` |
| Database admin (never the DB itself) | `54` | `5411` |

These are the prefixes this repository uses (`30<XX>`/`80<XX>`) — any pair of
families keeps working with the same method.

## Suffix allocation

- Base/main checkout keeps a fixed suffix (here `09`, non-breaking).
- Each new worktree takes **the next free suffix**: `max(existing suffixes) + 1`.
- Before using it, run `../assets/port-audit.sh <30XX> <80XX>` — an occupied
  port is evidence; move to the next suffix instead of trusting the table.
- The mapping is dynamic. Record it, and re-run the audit on every new worktree
  (a worktree may have been removed; a stale `.env` may still hold its suffix).

## Recording

Write the chosen mapping into the project's policy file
(`AGENTS.md` or `README.md`), e.g.:

```markdown
## Worktree ports
`<service-prefix><worktree-suffix>`; suffix = next free, audited with
`.agents/skills/worktree-runtime/assets/port-audit.sh`.

| Worktree | Branch | Frontend | API |
| --- | --- | --- | --- |
| main | main | 3009 | 8009 |
| pakamuros-feat-a | feat/a | 3011 | 8011 |
```

Worktree checkouts follow the location default in `SKILL.md` (Hard Rule 8):
siblings of the main checkout, named `<project>-<branch>` — never a
`.worktrees/` folder inside the repo unless the policy file declares it.

## What the convention deliberately does NOT cover

- **Database ports** — the DB port is infrastructure, not worktree state. If
  worktrees share one DB (common and fine), do not remap the DB port; only API
  and frontend need worktree-unique ports. If a worktree needs a separate DB,
  that is an explicit project decision, not a convention default.
- **Orchestration of parallel agents** — this skill ends where runtime works;
  splitting tasks across sessions is out of scope.