# Installing this skill on common AI harnesses

The skill is a standard `SKILL.md` with YAML frontmatter (`name`,
`description`), which is the de-facto format shared by the major agent
harnesses. The reference scripts are plain POSIX bash; they have **zero
harness-specific dependencies** (`git`, `ss`/`lsof`, `curl` — available on any
developer machine).

This table shows where to put the skill directory (the folder
`worktree-runtime/` containing `SKILL.md`). Where a
harness supports project-local skills, prefer that over a global install.

| Harness | Install location | Notes |
| --- | --- | --- |
| **Pi** (pi-coding-agent) | `~/.pi/agent/skills/worktree-runtime/` (global) or repo `.agents/skills/worktree-runtime/` | Repo-local is read by the agent automatically; reload skills after install |
| **Claude Code** (Anthropic) | `~/.claude/skills/worktree-runtime/` or `.claude/skills/` in repo | Standard Agent Skills format |
| **Cursor** | `.cursor/skills/` or `~/.cursor/skills/` | Agent Skills compatible |
| **Codex CLI** (OpenAI) | `~/.codex/skills/` or repo `skills/` | YAML frontmatter skills supported |
| **OpenClaw** | `~/.openclaw/skills/` or repo `skills/` | Follows the same SKILL.md convention |
| **Generic** | any harness reading `SKILL.md` + frontmatter | Keep the folder name equal to `name:` |

## Developing from the source repository

This skill is maintained in its own git repository. For development, do not
copy the folder into every harness: symlink the repo root into each skill
location so edits in the repo deploy everywhere immediately.

```bash
ln -sfn ~/projects/worktree-runtime ~/.pi/agent/skills/worktree-runtime
ln -sfn ~/projects/worktree-runtime <repo>/.agents/skills/worktree-runtime
```

Keep the symlink name equal to the folder name (`worktree-runtime`) — discovery
keys on the `SKILL.md`/folder name and frontmatter `name:`.

## Reusing the reference scripts standalone

The scripts do not need the skill loaded:

```bash
bash <path-to-skill>/worktree-runtime/assets/port-audit.sh 3011 8011
bash <path-to-skill>/worktree-runtime/assets/health-check.sh frontend http://localhost:3011 api http://localhost:8011/health
```

## Forking / publishing

- The skill is MIT-licensed; keep the `license: MIT` field when publishing.
- If you rename the directory, update `name:` in the frontmatter to match.
- The `description` trigger words are what make harnesses auto-load it — keep
  `worktree`, `parallel development`, `ports`, `dev server` near the front.