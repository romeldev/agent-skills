# worktree-runtime

Stack-agnostic, harness-agnostic skill that sets up and **verifies** an
isolated development runtime (services, ports, env, browser URLs) for a git
worktree running in parallel with the main checkout.

**Trigger words** (for auto-loading): `worktree`, `parallel development`,
`dev server ports`, `port allocation`, `isolated dev environment`, `preview
multiple branches in the browser`.

## What it solves

`git worktree add` gives you an isolated checkout but **no runtime**: no env,
no ports, no running services, nothing to open in the browser. Existing
community skills handle branch isolation or multi-agent orchestration but
hardcode one harness (Claude Code) and often one port scheme. This skill is
the missing piece: discover the stack's config mechanism, allocate
collision-free ports with evidence, keep state per-worktree, and refuse to
call a worktree ready until the services actually respond.

## Layout

```text
worktree-runtime/
├── SKILL.md                      # the LLM runtime contract (load this)
├── assets/
│   ├── port-audit.sh             # listen-port inventory / free-port check
│   ├── health-check.sh           # HTTP verification loop (evidence)
│   ├── stack-detectors.md        # recognize each stack's port mechanism
│   ├── convention.md             # minimal port convention when none exists
│   └── report-template.md        # Output Contract template
└── references/
    ├── multi-harness-install.md  # install table for Pi/Claude/Cursor/Codex…
    └── rationale.md              # design rationale and honest limits
```

## Usage

```bash
# Port evidence before allocating
bash assets/port-audit.sh 3011 8011

# Verify a worktree's stack is actually answering
bash assets/health-check.sh frontend http://localhost:3011 api http://localhost:8011/health
```

For agent use: load `SKILL.md` and follow its Execution Steps. The scripts are
advisory reference tooling — project automation (`make worktree-*`,
`scripts/worktree*.sh`) always wins over this skill's generic flow.

## License

MIT. Designed to be shared; see `references/multi-harness-install.md` for
install locations across harnesses and publishing notes.