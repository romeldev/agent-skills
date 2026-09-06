# Stack detectors — how to find each stack's port mechanism

**Rule: these are starting hypotheses, never conclusions.** For every row:
1. Detect from files present;
2. Confirm by reading the actual config file / command;
3. Verify with `../assets/health-check.sh` (or the runtime's own mechanism).

If two detectors both match, read the files — the evidence wins, not the table.

## Web / Node ecosystem

| Detected by | Port mechanism | How to read it |
| --- | --- | --- |
| `package.json` + Next.js (`next` dep) | `next dev -p <port>` or `PORT` | scripts in `package.json`, `.env` `PORT` |
| `vite.config.*` (Vite/React/Vue/Svelte) | `server.port` in config, or `--port` | read `vite.config.*`; CLI flag overrides |
| `package.json` + Express/Nest/Fastify | `PORT` env var typically | `.env(.example)`, `process.env.PORT` reference |
| `package.json` + CRA (`react-scripts`) | `PORT` env var | `.env` or inline `PORT=… npm start` |
| `package.json` + any dev server | dev script may hardcode `-p` | read the `dev`/`start` script verbatim |
| `yarn.lock`/`pnpm-lock.yaml` present | package manager affects install only | run `pnpm`/`yarn`/`npm` as the lockfile says |

## PHP / Laravel

| Detected by | Port mechanism | How to read it |
| --- | --- | --- |
| `artisan` + `composer.json` | `php artisan serve --port=<p>` or `--host`; `.env` `APP_URL` | read `.env`; pass `--port` explicitly per worktree |
| plain PHP | `php -S host:port router.php` | CLI flag only |

## Go / Rust / compiled

| Detected by | Port mechanism | How to read it |
| --- | --- | --- |
| `go.mod` + `cmd/` or `main.go` | env var (commonly `PORT`/`BACKEND_PORT`) or hardcoded | grep for `PORT`/`Addr`/`ListenAndServe`; Makefile may export it |
| `Cargo.toml` | env var or `axum`/`actix` bind | grep for `bind(`/`PORT` |

## Ruby / Python

| Detected by | Port mechanism | How to read it |
| --- | --- | --- |
| `Gemfile` + `bin/rails` | `bin/rails server -p <port>` | CLI flag; `config/puma.rb` may override |
| `manage.py` (Django) | `python manage.py runserver <addr>:<port>` | CLI argument |
| `pyproject.toml` + FastAPI/Flask | `uvicorn --port <p>` / `flask run --port <p>` | CLI flag; `.env` sometimes |

## Mobile / desktop (no HTTP by default)

| Detected by | Port mechanism | How to verify |
| --- | --- | --- |
| `pubspec.yaml` (Flutter) | no HTTP server by default | run on device/emulator or `flutter run -d web-server --web-port <p>`; verify via the runtime, **never fake a curl** |
| `*.xcodeproj` / `android/` | device/app runtime | verify via that runtime's mechanism |

## Containers

| Detected by | Port mechanism | How to read it |
| --- | --- | --- |
| `compose.yaml`/`docker-compose.yml` | published ports map | `docker compose port <svc> <port>`; remap via env or compose override per worktree |
| `Dockerfile` only | `EXPOSE` is documentation | look at the actual entrypoint/env |

## Cross-cutting

- **Makefile / Taskfile / Justfile** may export ports to subprocesses (e.g. `make dev`). Read the targets — the project's own automation is the highest authority and must be used (Hard Rule 1).
- **Env remap files**: `.env`, `.env.example`, `.env.local`, `config/*.env`. These are per-worktree state (Hard Rule 4).
- When two services must talk (SPA → API), find the **link variable** (proxy URL, `NEXT_PUBLIC_API_URL`, `APP_URL`/API base, CORS origin) and point it at the worktree's own ports. Verifying that link is mandatory, not optional.