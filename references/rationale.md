# Rationale and honest limits

## Why this design

The problem this skill solves is not "create a worktree" — `git worktree add`
is one line. The problem is that a worktree is a cold checkout with **no
runtime**: no env, no ports, no services, no way to see it in the browser.
Meanwhile, the surrounding ecosystem handles the mechanics of git (branch
isolation, cleanup) and the orchestration of parallel agents, but leaves the
**development runtime** to convention or ad-hoc chat instructions.

The design choices follow from that gap:

1. **Method, not values.** A skill that hardcodes "Laravel = 8000, Next = 3000"
   ages and lies, exactly like any documentation that drifts from real
   practice. Instead the skill teaches *discovery* (read the config mechanism
   present) and *verification* (prove the service responds). Values live only
   as heuristics in `assets/stack-detectors.md`, explicitly subordinate to
   evidence.
2. **Delegate to project automation.** Every healthy project grows its own
   tooling (`make worktree-env`, env remappers). A generic skill that ignores
   it would fight the project. Rule 1 makes project tooling the authority.
3. **Evidence is the anti-drift mechanism.** The skill's "ready" definition is
   a passing HTTP check, not a convincing config edit. This is what prevents
   the recurring failure "I changed the port but the browser still shows the
   old app": the check runs against what is *actually listening*.
4. **State locality.** `.env` lives in `.gitignore` precisely so each checkout
   can differ; sharing it verbatim breaks the isolation that worktrees exist
   to provide. The skill copies secrets through the project's own mechanism
   and never prints them into the conversation.

## Honest limits

- **Skills are advisory, not enforcement.** No skill can guarantee the agent
  follows it. What this skill does is make the correct path the cheapest one:
  run the script, read the evidence, report the table. The verification step
  is explicit so a skipped step is visible in the output contract.
- **Project policy wins.** If a project has a stronger convention (different
  port scheme, shared-env mandate, no worktrees allowed), the project wins.
  The skill records that and adapts.
- **The convention is for ports, not infrastructure.** Databases and other
  shared infrastructure stay shared unless the project explicitly decides
  otherwise. The skill must not silently spin up per-worktree databases.
- **Non-HTTP runtimes.** Flutter/web and desktop runtimes do not answer curl.
  The skill refuses to fake success and verifies through the runtime's own
  mechanism — which may be a manual confirmation from the user.
- **The four-digit port scheme** assumes local dev on one host. Containerized
  or remote runtimes (dev containers, remote hosts) need their own mapping;
  the same method (audit, allocate, verify) still applies.

## What this skill deliberately is not

- Not an orchestrator: it does not decompose tasks or distribute work across
  parallel agent sessions.
- Not a git authority: commit, push, merge, cleanup are ordinary repository
  policy; the skill only prepares a working runtime.
- Not a substitute for reading the project: the first step of every run is
  inspecting what the project already provides.