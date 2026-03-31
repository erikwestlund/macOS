# Dotfiles Tracking

This file tracks the migration of relevant dotfile and system-management patterns from `~/Code/System/Omarchy` into this `macOS` repo.

## Scope

Current focus:

- secrets push/pull workflow
- SSH config and key placement
- `/etc/hosts` management
- Git config and credentials

Not in scope yet:

- full dotfile parity with Omarchy
- every app config from Omarchy
- Linux-specific system config

## High-Level Conclusion

The Omarchy secrets/SSH/Git model can be reused almost directly on macOS.

The strongest reusable pattern is:

- store sensitive material under `~/.secrets`
- sync with `rclone`
- symlink or copy from `~/.secrets` into final locations
- keep non-secret behavior in tracked repo config
- use Ansible to enforce deployment and permissions

This fits the current macOS repo well.

## Omarchy Sources Reviewed

- `~/Code/System/Omarchy/README.md`
- `~/Code/System/Omarchy/scripts/secrets-setup.sh`
- `~/Code/System/Omarchy/scripts/secrets-pull.sh`
- `~/Code/System/Omarchy/scripts/secrets-push.sh`
- `~/Code/System/Omarchy/home/.ssh/config`
- `~/Code/System/Omarchy/home/.gitconfig`
- `~/Code/System/Omarchy/ansible/roles/secrets/tasks/main.yml`
- `~/Code/System/Omarchy/ansible/roles/dotfiles/tasks/main.yml`
- `~/Code/System/Omarchy/ansible/roles/webapps/tasks/main.yml`

## Trackable Decisions

### Secrets Sync

Status: Ready to port

What Omarchy does:

- keeps sync metadata in `~/.secrets/config`
- uses `rclone sync` for pull/push
- stores SSH, AWS, GPG, hosts, rclone, and secret dotfiles under `~/.secrets`
- deploys secrets via Ansible after sync

macOS assessment:

- this model should work essentially unchanged
- `rclone` is already present in this repo ecosystem
- `~/.secrets` is a good cross-platform convention
- `/etc/hosts` still exists on macOS, so the same management model is valid

What to move:

- `scripts/secrets-setup.sh`
- `scripts/secrets-pull.sh`
- `scripts/secrets-push.sh`
- aliases or launchers for `secrets-pull` and `secrets-push`
- Ansible role/tasks for deploying synced secrets into final locations

Open question:

- Omarchy docs mention both B2 and R2 patterns. Before porting, confirm the canonical remote for this macOS repo.

### SSH

Status: Ready to port

What Omarchy does:

- keeps private keys in `~/.secrets/ssh`
- symlinks `~/.ssh` to `~/.secrets/ssh`
- manages `~/.ssh/config` from secrets
- enforces file permissions with Ansible

macOS assessment:

- this model should work directly on macOS
- SSH config syntax is portable here
- host aliases and `IdentityFile` paths can remain the same if key names remain the same

What to move:

- `home/.ssh/config`
- Ansible tasks that symlink `~/.ssh` to `~/.secrets/ssh`
- permission-fix tasks for private/public SSH files

Potential adaptation:

- if some hosts are obsolete or Linux-only, trim them during migration instead of copying blindly

### /etc/hosts

Status: Ready to port

What Omarchy does:

- stores a managed hosts file in `~/.secrets/hosts`
- copies it to `/etc/hosts` via Ansible with sudo

macOS assessment:

- same approach works on macOS
- this should remain a secrets-managed or local-private file if it contains LAN/private infrastructure names

What to move:

- Ansible task to deploy `/etc/hosts` from `~/.secrets/hosts`

### Git

Status: Mostly ready to port

What Omarchy does:

- tracks `home/.gitconfig`
- sets user identity, aliases, GitHub SSH rewrite, and OHDSI-JHU HTTPS override
- stores OHDSI-JHU PAT in `~/.git-credentials-ohdsi-jhu`
- deploys PAT file from secrets variables through Ansible

macOS assessment:

- almost all of this is portable as-is
- credential handling model still makes sense
- URL rewrite behavior still makes sense
- aliases are portable

Likely adaptation:

- editor should probably be `nvim` or explicit `/opt/homebrew/bin/nvim` instead of plain `vim`
- review whether `credential.helper = cache` is still desired on macOS versus Keychain integration

What to move:

- tracked git config structure
- GitHub SSH rewrite rules
- OHDSI-JHU HTTPS override
- optional PAT credential deployment

## Concrete Migration List

### First wave

- port secrets shell scripts into this repo
- add Ansible role or tasks for secrets sync/deploy
- port `~/.ssh/config`
- symlink `~/.ssh` from `~/.secrets/ssh`
- add `/etc/hosts` deployment from `~/.secrets/hosts`
- port `~/.gitconfig` into tracked repo config
- add Git credential deployment for special cases

### Second wave

- migrate `~/.aws` symlink from secrets
- migrate `~/.config/rclone` symlink from secrets
- migrate GPG import step if still needed on this machine
- decide whether any secret dotfiles should land directly in `$HOME`

### Explicitly not worth moving

- Linux-only `/etc` content from Omarchy
- Hyprland/Waybar-specific patterns
- machine-targeting model unless this macOS repo grows into multiple hosts

## Recommended Implementation Shape For macOS Repo

### Repo-managed, non-secret

- `config/git/gitconfig`
- `config/ssh/config` only if it is safe to track publicly
- shell aliases or wrappers for secrets commands
- Ansible tasks for symlink/copy deployment

### Secrets-managed

- `~/.secrets/ssh`
- `~/.secrets/aws`
- `~/.secrets/rclone`
- `~/.secrets/hosts`
- Git PAT material
- GPG private material

## Progress

- Reviewed Omarchy reference files: complete
- Confirmed secrets/SSH/hosts/Git model is portable to macOS: complete
- Added `secrets` Ansible role: complete
- Added `secrets-setup`, `secrets-pull`, and `secrets-push`: complete
- Added tracked `~/.gitconfig` and global gitignore: complete
- Added tracked SSH config deployment: complete
- Added `/etc/hosts` deployment from `~/.secrets/hosts`: complete
- Full migration of existing private SSH keys and other secret payloads into `~/.secrets`: pending

## Next Recommended Steps

1. Run `secrets-setup` and `secrets-pull` with the real R2 credentials.
2. Move or sync existing private SSH keys into `~/.secrets/ssh`.
3. Add any needed secret payloads under `~/.secrets/git`, `~/.secrets/aws`, and `~/.secrets/rclone`.
4. Run `ms-secrets` again after secrets land locally.
5. Decide whether to fully symlink `~/.ssh` to `~/.secrets/ssh` once the local migration is complete.
