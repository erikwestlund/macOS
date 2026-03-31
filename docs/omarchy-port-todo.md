# Omarchy Port TODO

This report summarizes what remains unported from `~/Code/System/Omarchy`, what should not be ported directly, and what should be prioritized next for a productive macOS-based project workflow.

## Current Baseline

What is already in place in this macOS repo:

- packages
- dotfiles
- secrets
- prefs
- `yabai` / `skhd` / `SketchyBar`
- tracked Git config
- tracked SSH config with `~/.ssh -> ~/.secrets/ssh`
- web app launchers and icon management for `Claude`, `ChatGPT`, and `YouTube`
- core shell aliases and zsh improvements

What is still missing is the larger Omarchy workflow layer: project bootstrap, service orchestration, editor sync, local dev DNS/proxy, and several convenience roles.

## High Priority Gaps

### 1. Project Workflow Layer

Omarchy has a full project system that this macOS repo does not yet reproduce.

Relevant Omarchy sources:

- `ansible/roles/projects/tasks/main.yml`
- `ansible/roles/bootstrap/tasks/main.yml`
- `ansible/roles/bootstrap/tasks/python.yml`
- `ansible/roles/bootstrap/tasks/rstats.yml`
- `ansible/roles/bootstrap/tasks/laravel.yml`
- `config/projects/projects.yml`
- `home/bin/pm-new`
- `projects/CLAUDE.md`

What is missing here:

- project registry / source of truth
- project bootstrap entrypoints
- workspace generation
- per-project launcher scripts
- project service assumptions
- secret injection into project directories

Recommendation:

- Port this next.
- Keep one repo-managed project registry similar to Omarchy’s `config/projects/projects.yml`.
- Build a macOS-first version of the workflow around:
  - Zed for code-heavy work
  - Positron for stats/data work
  - OrbStack for containers
  - `yabai` / `skhd` / Raycast for launching and switching

### 2. Local Dev DNS and Reverse Proxy

Omarchy relies on a local domain and reverse-proxy workflow that is not yet reproduced here.

Relevant Omarchy sources:

- `ansible/roles/dnsmasq/tasks/main.yml`
- `ansible/roles/dnsmasq/templates/dnsmasq-dev.conf.j2`
- `ansible/roles/caddy/tasks/main.yml`
- `ansible/roles/caddy/defaults/main.yml`

Why this matters:

- you explicitly want to keep `dnsmasq` / `caddy` because that workflow works well
- it is central to making local web projects feel consistent

What needs to happen:

- port `dnsmasq` to Homebrew + macOS resolver conventions
- port `caddy` to Homebrew + launchd / `brew services`
- define local dev domains in a tracked source of truth
- wire project ports into the local proxy setup

Recommendation:

- This is the second major thing to port after project workflow.

### 3. Editor Workflow: Zed / Positron / VS Code Decision

You want:

- Zed as the main code-oriented editor
- Positron for stats workflows
- to try living without VS Code

Relevant Omarchy sources:

- `config/zed/settings.json`
- `config/zed/keymap.json`
- `config/positron/settings.json`
- `ansible/roles/vscode/tasks/main.yml`
- `config/vscode/settings.json`
- `config/vscode/extensions.txt`

Current gap:

- Zed config here is still light
- Positron is installed but not configured from repo
- VS Code is not installed or managed, which is fine if intentional

Recommendation:

- Treat this as a deliberate two-editor system:
  - Zed: code, terminal-heavy work, web/PHP/Python tasks
  - Positron: R, notebooks, stats workflows, exploratory analysis
- Do not add VS Code back yet.
- Revisit only if a concrete workflow breaks.

Project layout convention should mirror Omarchy:

- `~/Projects`: active working repositories
- `~/Code`: inspection checkouts, old repos, and non-active code

### 4. Shared Local Dev Services

Relevant Omarchy sources:

- `services/mailpit/docker-compose.yml`
- `ansible/roles/projects/templates/laravel-env.j2`
- `ansible/roles/caddy/defaults/main.yml`

Likely missing services or assumptions:

- Mailpit
- MinIO or equivalent local object storage
- project-specific DB / Redis assumptions

Recommendation:

- Move these into an explicit shared-services section of this repo.
- Prefer OrbStack-managed compose services over ad hoc local servers where possible.

## Medium Priority Gaps

### 5. OCR Role

Relevant Omarchy sources:

- `ansible/roles/ocr/tasks/main.yml`
- `ansible/roles/ocr/defaults/main.yml`

Current status:

- core OCR system packages are now installed here
- the dedicated OCR role is not yet ported
- no `ocrmypdf` or PaddleOCR venv workflow yet

Recommendation:

- Port a macOS version of the OCR role later.
- Keep it as an optional role, not part of the base playbook.

### 6. Syncthing

Relevant Omarchy source:

- `ansible/roles/syncthing/tasks/main.yml`

Recommendation:

- Port only if you still actively use Syncthing on the Mac.
- Use a macOS-native service management path.

### 7. NAS / Backup Workflow

Relevant Omarchy sources:

- `ansible/roles/nas/tasks/main.yml`
- `ansible/roles/backup/tasks/main.yml`
- `docs/manual/27-nas-backups.md`

Recommendation:

- Revisit later.
- Do not port Linux autofs/systemd patterns literally.

### 8. Ollama

Relevant Omarchy source:

- `ansible/roles/ollama/tasks/main.yml`

Recommendation:

- Leave out for now, as requested.
- If you bring it back later, use Homebrew/launchd rather than Linux assumptions.

## Things That Should Not Be Ported Directly

These are Omarchy-specific or Linux-specific and should stay out unless replaced with a macOS-native equivalent.

- Hyprland / Waybar / darkman desktop stack
- `keyd`
- `systemd` service roles
- UFW / ufw-docker firewall assumptions
- autofs/cifs-utils NAS implementation
- Snapper / btrfs snapshot logic
- GPU tuning roles
- Framework-specific hardware roles
- Linux printer/network recovery helpers
- libvirt/QEMU Windows VM workflow

## Software Present in Omarchy But Not Yet Managed Here

Potentially relevant to revisit:

- `tailscale`
- `syncthing`
- `gnupg`
- `yt-dlp`
- `doctl`
- `quarto`
- `gcalcli`
- `firefox`
- `beekeeper-studio`
- `zotero`

Recommendation:

- Add only in response to an actual workflow need.
- Do not mirror Omarchy’s package breadth by default.

## Project Workflow Assessment

### Zed as Primary Code Editor

This is realistic.

What is still needed:

- fuller Zed settings parity with Omarchy
- project opening conventions
- terminal-first workflow refinements
- terminal zoom/focus behavior

On the requested Zed hotkey:

- You want a fast way to zoom in/out on the terminal, something like `Cmd+Shift+T`.
- This likely needs to be a Zed keymap action rather than a global hotkey.
- The exact action name still needs confirmation in Zed docs/default keymap.

Likely path:

- bind a Zed-specific terminal panel maximize/toggle action
- avoid making it global, because `Cmd+Shift+T` collides in many apps

Recommendation:

- Revisit Zed keymap once we inspect the available terminal panel actions.
- Keep this as a Zed-local shortcut, not a system-wide one.

### Positron for Stats Workflows

This also makes sense.

What is still needed:

- tracked Positron settings
- package/library assumptions for R workflows
- optional Java config for R packages that need it
- a documented “use Positron for X, Zed for Y” convention

Recommendation:

- Add managed Positron config next time we touch editor setup.

### Living Without VS Code

This is a reasonable experiment.

Recommendation:

- Do not port VS Code yet.
- Revisit only if you hit a specific blocker:
  - extension-only workflow
  - debugger gap
  - remote development gap

## Remote vs Local Service Workflow

You said you want the desktop workflow to support both remote and local services for:

- PostgreSQL
- MySQL
- Redis

That means the workflow should not assume one mode.

What needs to be designed:

### 1. Service Profiles

Projects should be able to choose between:

- local containerized services
- remote LAN services
- remote server services

That likely belongs in a project registry, for example:

- db mode: local / remote
- db host
- db port
- redis mode: local / remote

### 2. Client Tooling Is Ready, But Runtime Switching Is Not

We now have the client side mostly covered:

- `psql` via `libpq`
- `mysql` via `mysql-client`
- `redis-cli` via `redis`

What is missing:

- env generation conventions
- shell helpers for switching targets
- project bootstrap templates that know local vs remote

Recommendation:

- Encode service mode into the future project registry.
- Avoid hardcoding localhost assumptions in project templates.

### 3. OrbStack Role

Since you want OrbStack, the container path should be:

- local stack when needed
- remote service when preferred

Recommendation:

- use local containers only when the project actually needs local state
- otherwise prefer network services for shared DB/Redis where that improves workflow

## ARM Container Assessment

You want to prefer ARM containers whenever possible on Apple Silicon.

That is the right default.

### Good News

Most mainstream images now support ARM64:

- `postgres`
- `mysql`
- `mariadb`
- `redis`
- `nginx`
- `php`
- `node`
- `caddy`
- `mailpit`
- `minio`

For typical Laravel/PHP/Python/R support containers, ARM is usually fine.

### Likely Risk Areas

These are the places where ARM64 may still break or behave differently:

- old pinned base images
- old private images
- old Dockerfiles assuming Debian/Ubuntu x86 packages
- proprietary vendor binaries
- browser automation images if pinned to older builds
- database utility images with no ARM manifest
- legacy PHP extensions that compile poorly on ARM
- Java/R packages with native binaries

### What Needs To Be Done

1. Audit all current project Dockerfiles and compose files.
2. Remove forced `platform: linux/amd64` where not needed.
3. Only keep `linux/amd64` for specific images that truly require it.
4. Document those exceptions explicitly.
5. Prefer upstream multi-arch images.

### Practical Rule

- default to ARM64
- only opt into amd64 per-service, not globally

### Things Most Likely To Need Attention

From Omarchy’s Laravel/bootstrap patterns:

- copied reference Dockerfiles
- project-specific `docker/php/Dockerfile`
- custom package installs inside app images
- browser test tooling

Recommendation:

- When the project workflow is ported, make ARM64 the baseline assumption in generated compose files.
- Add explicit `platform` only as an exception.

## Suggested Next Order of Work

1. Port project registry + bootstrap workflow.
2. Port `dnsmasq` + `caddy` for local dev domains.
3. Add tracked Positron config.
4. Reconcile and deepen Zed config.
5. Build shared local service management for Mailpit and similar tools.
6. Audit current project Dockerfiles/compose files for ARM64.
7. Add optional OCR role.

## Explicit Recommendations

- Keep Zed as the default code editor.
- Keep Positron as the default stats editor.
- Keep VS Code out unless a real missing workflow forces it back.
- Prefer OrbStack over local server installs where containers make sense.
- Prefer networked DB/Redis services when they improve workflow, but keep local container fallback.
- Prefer ARM64 containers by default and document exceptions.
