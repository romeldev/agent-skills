---
name: worktree-runtime
description: "Trigger: worktree, parallel development, dev server ports, port allocation, isolated dev environment, preview multiple branches in the browser. Set up and verify an isolated development runtime (services, ports, env, browser URLs) for a git worktree in any project, stack, or agent harness."
license: MIT
metadata:
  author: el gentleman + miclinica
  version: "1.0"
---

# worktree-runtime

Isolate a git worktree's development runtime so it can run in parallel with the main checkout: services on collision-free ports, project-local state, and evidence that the stack actually responds before calling it ready.

## Activation Contract

Use when the user wants parallel development in a worktree and any of these applies:
- "work in parallel", "create a worktree for X while I keep Y";
- "configure the ports", "I can't see the worktree in the browser", "port collision";
- a second checkout needs its own dev servers, env, or URLs.

Do not use when: the worktree is already running and the task is only code, review, or commit. Do not use for orchestrating multiple agents or decomposing tasks; this skill is runtime setup and verification only.

Always inspect what exists first: an earlier setup or a project-specific worktree command wins over this skill's generic flow.

## Hard Rules

1. **Delegate, never reinvent.** If the project has worktree automation (`make worktree-*`, `scripts/worktree*.sh`, env-remap tooling), use it. This skill is the fallback method, not a replacement.
2. **Discover, never assume.** Read the project's policy file first — `AGENTS.md`, `CLAUDE.md`, `.cursorrules` or the harness's project instructions — for declared worktree/port conventions and boot tooling; they win over this skill. Then read the actual config mechanism (Makefile, `.env(.example)`, `package.json` scripts, `compose.yaml`, runtime flags) to learn how each service takes its port. `assets/stack-detectors.md` is a starting heuristic; only evidence from the actual files counts.
3. **Evidence before success.** Inventory listening ports with `assets/port-audit.sh` (or `ss -tlnp`) before choosing. Never declare a worktree ready without an HTTP/health check (`assets/health-check.sh` or curl) returning success for every service and for the front-to-back link.
4. **State is per-worktree.** Env and generated config stay local to the worktree and are never shared verbatim across checkouts. Copy through the project's own mechanism (`.env` from main + remap) and never print secrets into the conversation.
5. **One writer per worktree.** Do not run two parallel write flows inside the same checkout. Parallelism requires separate worktrees.
6. **Convention before invention.** If the project has a port convention, obey it. If it has none, apply the minimal convention in `assets/convention.md` and record it in the project's `AGENTS.md`/`README` as part of your output.
7. **Collision = evidence, not guesswork.** An occupied port is proof it is taken; choose the next free one. If no free port fits the convention, escalate to the human instead of breaking it.

## Decision Gates

| Situation | Action |
| --- | --- |
| Project has `make worktree-*` / `scripts/worktree*.sh` | Run that tooling; skip straight to verification |
| Stack unknown | Detect via `assets/stack-detectors.md`, confirm by reading config files |
| Port occupied | `port-audit.sh` shows it; allocate the next free port in convention |
| No convention exists | Apply `assets/convention.md`, record it in the repo |
| No free port fits convention | Stop; ask the human |
| Multiple services | Map the graph (front → proxy/API → DB) and verify each link, not just each port |
| Runtime without HTTP (Flutter device, desktop app) | Verify via that runtime's own mechanism; never fake a curl success |

## Execution Steps

1. **Preflight.** Confirm the source checkout is clean enough to branch from; list existing worktrees (`git worktree list`) and their ports.
2. **Discover policy + service graph.** Read `AGENTS.md`/`CLAUDE.md` (or the harness project instructions) for declared worktree conventions: existing automation, port tables, boot commands, network/URL constraints. Then identify every dev service, how it takes its port, and how it links to the others (proxy URL, API base, CORS origin).
3. **Create the worktree.** `git worktree add <worktree-dir> -b feat/<name>` from the agreed base branch. Confirm it is a real checkout.
4. **Allocate ports.** Audit with `assets/port-audit.sh`. Pick free ports following the project convention or `assets/convention.md`. Same worktree suffix across all its services.
5. **Isolate state.** Generate the worktree's local env from the main checkout via the project mechanism; set the allocated ports; never share `.env` files across worktrees.
6. **Boot services.** Start each service in the worktree on its allocated port (install deps first in that checkout).
7. **Verify with evidence.** Run `assets/health-check.sh` against every service and the front→back URL. Only a passing check counts.
8. **Report.** Emit the Output Contract; record the convention if one was created.

## Output Contract

Return:
- Worktree table: `| worktree path | branch | service | URL | verified? |`;
- Evidence: port-audit output and health-check output for each service and link;
- Convention: ports chosen and where they were recorded (`AGENTS.md`/`README`);
- Boot/teardown commands for the worktree;
- Residual risks: shared DB, unverified runtime types, secrets handled by project mechanism.

## References

- `assets/port-audit.sh` — POSIX port inventory / free-port check.
- `assets/health-check.sh` — POSIX HTTP verification loop.
- `assets/stack-detectors.md` — how to recognize each stack's port mechanism from files present.
- `assets/convention.md` — minimal port convention when the project has none.
- `assets/report-template.md` — the Output Contract table template.
- `references/multi-harness-install.md` — how to install this skill on common agent harnesses.
- `references/rationale.md` — design rationale and honest limits.