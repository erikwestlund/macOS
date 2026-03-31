# System Configuration

System configuration for this Mac.

## Quick Start (New Machine)

```bash
# 1. Clone repo
git clone https://github.com/erikwestlund/system ~/System

# 2. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Install core tools
brew install --cask 1password
brew install ansible rclone age

# 4. Set up ansible vault password
printf '%s\n' 'your-vault-password' > ~/.vault_pass
chmod 600 ~/.vault_pass

# 5. Run playbook
# -K prompts for sudo password
ANSIBLE_CONFIG=~/System/ansible/ansible.cfg ansible-playbook ~/System/ansible/playbook.yml -K
```

The first playbook run is also the secrets bootstrap. It reads `ansible/vault/secrets.yml`, writes `~/.config/secrets/config`, and runs `secrets-pull` so `~/.secrets` is populated before secrets-backed roles are applied.

## Secrets

Secrets are required for a working setup on a new machine.

```bash
# Re-sync encrypted secrets into ~/.secrets/
secrets-pull

# Re-deploy secrets-backed files into their final locations
ms-secrets
```

## Notes

- Dotfiles and system configuration live in `~/System`.
- Secrets are bootstrapped through this repository on the first playbook run and follow the Omarchy pattern after that: `~/.secrets` is the local secrets store, `secrets-pull` syncs secrets locally, and `ms-secrets` deploys them into final locations.
- macOS-specific tracked files live under `config/macos`.
- Git is tracked in `config/git/gitconfig` and linked to `~/.gitconfig`.
- SSH config is tracked in `config/ssh/config`; private SSH material is expected under `~/.secrets/ssh`.
- `/etc/hosts` can be deployed from `~/.secrets/hosts` via the `secrets` Ansible role.
- NAS credentials are managed via the `nas` role in `/etc/nsmb.conf` so Finder and SMB mounts can authenticate without prompts.
- Local `.test` development domains are managed via the `localdev` role using `dnsmasq` and `caddy` on macOS through root LaunchDaemons.
- Launchd jobs archive `~/Screenshots` and move `~/Downloads` entries older than 7 days directly over SSH to `syncthing.lan:/srv/Files/Erik/...`.
- Syncthing is managed via the `syncthing` role and currently syncs `~/Docs` and `~/Work` to the existing Syncthing server profile from Omarchy.
- Yabai is installed by Ansible and copies tracked files from `config/yabai` into `~/.config/yabai`.
- Borders is installed by Ansible and uses a tracked `config/borders/bordersrc` under `~/.config/borders` for focused window borders.
- skhd is installed by Ansible and uses a tracked `config/skhd/skhdrc` symlinked to `~/.config/skhd/skhdrc`.
- SketchyBar is installed by Ansible and uses a tracked `config/sketchybar` under `~/.config/sketchybar`.
- Ansible enables the Mission Control setting `Displays have separate Spaces`, which yabai requires to start.
- yabai is configured for BSP tiling by default, creates up to 12 spaces on the primary display, and Borders provides a thin cyan focus border while skhd binds workspace navigation to `Option+1-0,-,=` with window focus/movement on `Option+h/j/k/l` and `Option+Shift+h/j/k/l`.
- Window resizing is bound to `Option+Shift+,` and `Option+Shift+.` for width, plus `Command+Option+Shift+,` and `Command+Option+Shift+.` for height.
- Ansible manages passwordless sudo for the local user via `/private/etc/sudoers.d/<user>`; the first apply still requires an authenticated sudo run.
- macOS still requires Accessibility permission for `skhd` and window manager permissions for `yabai` in System Settings.
- Chrome web apps are created manually, then customized from this repo. Create web apps for `Claude`, `ChatGPT`, and `YouTube`, then wire them into managed launchers and icons here.
