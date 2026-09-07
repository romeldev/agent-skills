# Worktree runtime report

Copy this block into the conversation when Execution Step 8 runs. Replace the
example rows. Keep evidence columns filled from actual script output — a report
without evidence is a promise, not a result.

```markdown
## Worktree runtime — <feature/branch name>

### Service table

| Worktree | Branch | Service | URL | Verified? | Evidence |
| --- | --- | --- | --- | --- | --- |
| `main` | `main` | frontend | http://localhost:3009 | yes | HTTP 200 |
| `main` | `main` | api | http://localhost:8009/health | yes | HTTP 200 |
| `pakamuros-feat-a` | `feat/a` | frontend | http://localhost:3011 | yes | HTTP 200 |
| `pakamuros-feat-a` | `feat/a` | api | http://localhost:8011/health | yes | HTTP 200 |
| `pakamuros-feat-a` | `feat/a` | front→api link | http://localhost:3011 → API | yes | proxy URL remapped |

### Port audit (evidence)

```text
$ bash .agents/skills/worktree-runtime/assets/port-audit.sh 3011 8011
FREE      :3011
FREE      :8011
```

### Convention

- Convention applied / recorded at: `AGENTS.md` (or none existed → recorded now).
- Mapping: main=`09`, worktrees=`10`, `11`, …

### Boot / teardown

```bash
# bootstrap
cd ../pakamuros-feat-a
make worktree-env      # or the project's env tooling
<install deps>         # per lockfile
make run-frontend &    # per project
make run-backend &     # per project

# teardown (only when the user asks)
git -C ../pakamuros-feat-a worktree remove ../pakamuros-feat-a
```

### Residual risks

- [ ] Shared database across worktrees (by design) — schema changes affect both.
- [ ] Runtime type without HTTP check (Flutter/desktop) — verified via its own mechanism.
- [ ] Secrets copied via project mechanism, never printed to chat.
```