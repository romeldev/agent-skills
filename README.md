# agent-skills

A curated collection of **stack-agnostic, harness-agnostic agent skills** for
development workflows. Each skill is a self-contained folder with a `SKILL.md`
runtime contract (plus `assets/` scripts and docs, and `references/` when
needed), following the [Agent Skills](https://agentskills.io/specification)
format.

## Skills

| Skill | What it does | Status |
| --- | --- | --- |
| [worktree-runtime](skills/worktree-runtime/) | Set up and **verify** an isolated dev runtime (services, ports, env, browser URLs) for a git worktree running in parallel with the main checkout. Stack-agnostic (Laravel, Next/React, Node, Go, …) and harness-agnostic (Pi, Claude Code, Cursor, Codex, OpenClaw, …). | ✅ v1.0.0 |

## Install

Copy or symlink each skill folder into your harness's skill location. See
`skills/worktree-runtime/references/multi-harness-install.md` for the full
per-harness table, and the "Developing from the source repository" section for
the recommended symlink workflow.

```bash
# Example: Pi global skills
ln -sfn "$PWD/skills/worktree-runtime" ~/.pi/agent/skills/worktree-runtime
```

## Contributing

- Each skill keeps its own files; the repo is the single source of truth.
- Keep `SKILL.md` as a concise LLM runtime contract — see
  `skills/worktree-runtime/references/rationale.md` for the design principles
  (method, not values; evidence before success; delegate to project automation).
- Update `CHANGELOG.md` when a skill changes user-visible behavior.

## License

MIT — see [LICENSE](LICENSE).