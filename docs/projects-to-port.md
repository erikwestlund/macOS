# Projects To Port

This file tracks the Omarchy project workflow port into the macOS repo.

## Goal

Port the full active Omarchy project registry and then deepen the project workflow by type.

Type rollout order:

1. Laravel: `peq`
2. R/stats: `cholera`
3. Python: `na`

## Imported Project Registry

All active Omarchy projects are now represented in `config/projects/projects.yml`.

Imported aliases:

- `peq`
- `bs`
- `fw`
- `fws`
- `park`
- `na`
- `hl`
- `fl`
- `tnt`
- `drtp`
- `mhmi`
- `om`
- `r50code`
- `r50`
- `geulegal`
- `wg`
- `wsm`
- `obsr`
- `cdv`
- `career`
- `cholera`
- `aitools`
- `lr`
- `lrf`
- `fwa`
- `canehr`
- `peanuts`

## Current State

What works now for all imported projects:

- generated aliases/functions in zsh from `project-meta`
- `s{alias}` light setup/scaffold without Docker builds
- `b{alias}` bootstrap with per-type behavior and optional project-specific hooks
- `l{alias}` generic service launch without opening windows
- `k{alias}` generic kill
- `tm{alias}` tmux attach in current terminal
- `t{alias}` Ghostty + tmux attach
- `z{alias}` open in Zed
- `p{alias}` open in Positron
- `v{alias}` open configured view URL
- `d{alias}` / `dd{alias}` for `docker compose up/down`
- project secrets deployment during `secrets-pull`

What is still generic and not yet parity with Omarchy:

- generated project management scripts under `~/System/projects/<name>`
- Laravel `.env` generation/template logic
- Laravel compose generation/template logic
- richer tmux layouts per type
- project-aware browser/view workflows beyond `v{alias}`
- port allocation logic in `pm-new`
- repo-specific Docker ARM64 adjustments inside existing project repos

## Deep Port Tracking

### 1. Laravel: `peq`

Status: in progress

Implemented:

- imported registry entry and alias set
- bootstrap clones repo if needed
- required secrets copy (`auth.json`, `.env`)
- docker build during bootstrap
- composer install via container
- npm install
- local runtime now comes up successfully (`php`, `nginx`, `queue`, `postgres`, `redis`)
- stale local env was corrected to use `CACHE_STORE=redis` and `QUEUE_CONNECTION=redis`
- immediate local host mapping added for `academic.test` and `app.academic.test`

Still needed:

- laravel env generation
- laravel compose generation assumptions
- laravel tmux layout parity
- wildcard `*.academic.test` local routing via later `dnsmasq` / `caddy` port
- ARM64 vs amd64 compose strategy inside project repo

### 2. R/stats: `cholera`

Status: in progress

Implemented:

- imported registry entry and alias set
- bootstrap clones repo if needed
- Positron-first editor default
- `renv` restore attempt during bootstrap
- npm install if frontend exists

Still needed:

- rstats tmux layout parity
- project env deployment expectations
- optional Python/R mixed workflow helpers

### 3. Python: `na`

Status: in progress

Implemented:

- imported registry entry and alias set
- bootstrap clones repo if needed
- required `.env` secret copy
- docker build during bootstrap
- project-specific bootstrap commands:
  - mock-idp cert generation
  - `docker compose up -d`
  - migrations
  - seed/init commands
- npm install if frontend exists

Still needed:

- tmux session parity
- project secrets behavior validation

## ARM64 Note

Desired policy:

- local development on this Mac should prefer `linux/arm64`
- production-oriented images/workflows can remain `linux/amd64` when required
- if prudent, projects may need an explicit development override for platform

Current status:

- this repo now has the project control layer
- it does not yet rewrite or patch existing project repo Dockerfiles/compose files
- ARM64 compatibility still needs to be handled inside the project repos themselves

Recommended next step for Docker:

- audit `pequod`, `cholera`, and `naaccord-data-depot` compose/Dockerfiles
- default local dev to ARM64 where possible
- only pin amd64 where an image or toolchain truly requires it

## Notes

- Active work lives under `~/Projects`
- `~/Code` is for reference code, old repos, and non-active checkouts
- `launch` should not open windows
- `t{alias}` should open a new Ghostty window and enter tmux
- `tm{alias}` should attach in the current terminal
