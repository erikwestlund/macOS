# Project Workflow

Project commands are generated from `config/projects/projects.yml`.

Current assumptions:

- active project code lives under `~/Projects`
- `~/Code` is for reference code, old repos, and non-active checkouts
- project management metadata lives under `~/System/projects`
- `launch` does not open windows
- `t{alias}` opens a new Ghostty window and attaches to the tmux session
- `tm{alias}` attaches in the current terminal

## Command Pattern

For a project alias like `na`:

- `sna`: setup/scaffold project locally without Docker builds
- `bna`: bootstrap project
- `lna`: launch project services and ensure tmux session exists
- `kna`: kill project services and tmux session
- `tmna`: attach to project tmux in the current terminal
- `tna`: open a new Ghostty window and attach to project tmux
- `zna`: open project in Zed
- `vna`: open project view URL if configured
- `pna`: open project in Positron
- `dna`: `docker compose up -d`
- `ddna`: `docker compose down`
- `tpna`: open the project's local database in TablePlus
- `pullartna`: pull project artifacts into the repo
- `pushartna`: push project artifacts from the repo
- `projectctl tableplus na`: open the project's local database in TablePlus
- `na`: cd to project code directory
- `pmna`: cd to project management directory under `~/System/projects`

## Secrets

`secrets-pull` now runs project secret deployment after decrypting secrets.

If a project path exists, it syncs from any of:

- `~/.secrets/<project-name>/`
- `~/.secrets/projects-env/<project-name>/`
- `~/.secrets/projects-vault/<project-name>/`
- `~/.secrets/projects-kamal/<project-name>/`

into the project directory.

## Artifacts

Artifacts are synced to the mounted `WorkArtifacts` SMB share at `/Volumes/WorkArtifacts/<project>/` when available.

The legacy SSH path on `syncthing.lan:/srv/Files/Erik/WorkArtifacts/<project>/` is kept as a fallback for older setups.

Rules:

- if a project has a `.artifacts` file, those patterns are used as an override
- otherwise, framework-style data projects are inferred by convention and sync:
  - `inputs/private/`
  - `reference/private/`
  - `outputs/private/`
  - `framework.db*`

Commands are generated per project:

- `pullart{alias}`
- `pushart{alias}`

## Current Seeded Project

- `naaccord-data-depot`
  - alias: `na`
  - type: `python`
  - editor: `zed`
  - docker compose: `true`
  - path: `~/Projects/naaccord-data-depot`
  - view URL: `http://naaccord.test`

If the real path differs, update `config/projects/projects.yml`.

## New Projects

Use:

```bash
pm-new
```

This appends a new project entry to `config/projects/projects.yml` and creates its management directory under `~/System/projects`.

Reload shell afterward:

```bash
exec zsh
```

## Setup vs Build

- `s{alias}`: clone repo if needed, create management dir, deploy secrets, and run light setup only
- `b{alias}`: run setup plus heavier build/bootstrap work

For database-backed projects, use `tp{alias}` or `projectctl tableplus <alias>` to open the derived local DSN in TablePlus when needed.

Examples:

- `speq`: prepare `pequod` without Docker build
- `bpeq`: build/bootstrap `pequod`
