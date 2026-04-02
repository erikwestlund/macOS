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
brew install ansible age

# 4. Set up ansible vault password
echo 'your-vault-password' > ~/.vault_pass
chmod 600 ~/.vault_pass

# 5. Run playbook
# First run: install formulae, standard casks, dotfiles, secrets, prefs, and passwordless sudo
ANSIBLE_CONFIG=~/System/ansible/ansible.cfg ansible-playbook ~/System/ansible/playbook.yml -K

# Second run: install privileged pkg/script-backed casks after passwordless sudo is in place
ANSIBLE_CONFIG=~/System/ansible/ansible.cfg ansible-playbook ~/System/ansible/playbook.yml --tags packages -e install_privileged_casks=true
```

The first playbook run is also the secrets bootstrap. This repo already includes the encrypted `ansible/vault/secrets.yml` file, so unlike Omarchy there is no separate manual `rclone copy ...` bootstrap step to fetch it first. Ansible reads that vault file, writes `~/.config/secrets/config`, and runs `secrets-pull`, which syncs encrypted secrets from Backblaze B2 into `~/.secrets` before secrets-backed roles are applied. Privileged Homebrew casks that invoke macOS pkg or vendor installers are deferred to the second command so the initial bootstrap can complete reliably before they run.

## Secrets

Secrets are required for a working setup on a new machine.

```bash
# Re-sync encrypted secrets from Backblaze B2 into ~/.secrets/
secrets-pull

# Re-deploy secrets-backed files into their final locations
mac-secrets
```

## Notes

## Manual Installs

- `Logi Options+`: install manually from Logitech. Homebrew only stages Logitech's installer app and does not produce a fully installed `Logi Options+` application and services by itself.
- `JHU VPN (Ivanti Secure Access)`: install manually.

- Dotfiles and system configuration live in `~/System`.
- Secrets are bootstrapped through this repository on the first playbook run and follow the Omarchy pattern after that: `~/.secrets` is the local secrets store, `secrets-pull` syncs secrets locally, and `mac-secrets` deploys them into final locations.
- `rclone` is installed from Homebrew and its config is linked from `~/.secrets/rclone` when present.
- Privileged Homebrew casks are not installed on the first run; install them with `ansible-playbook ~/System/ansible/playbook.yml --tags packages -e install_privileged_casks=true` after the main bootstrap has enabled passwordless sudo.
- Mac App Store apps are installed through `mas` from the packages role when the user is signed into the App Store; the current managed set includes `Blackmagic Disk Speed Test`, `Pixelmator Pro`, and `xScope 4`.
- macOS-specific tracked files live under `config/macos`.
- Git is tracked in `config/git/gitconfig` and linked to `~/.gitconfig`.
- Positron keybindings are tracked in `config/positron/keybindings.json` and linked to `~/Library/Application Support/Positron/User/keybindings.json`.
- Shell aliases in `config/shell/aliases` include the Omarchy Git and Docker shortcuts, `mac-pull`/`mac-push` for updating this repo, `mac-save` for committing it with the standard message `update mac system configuration`, and project-scoped aliases like `d{alias}` and `dd{alias}` generated dynamically from `config/projects/projects.yml` by `project-meta`.
- SSH config is tracked in `config/ssh/config`; private SSH material is expected under `~/.secrets/ssh`.
- `/etc/hosts` can be deployed from `~/.secrets/hosts` via the `secrets` Ansible role.
- NAS credentials are managed via the `nas` role in `/etc/nsmb.conf` so Finder and SMB mounts can authenticate without prompts.
- The `prefs` Ansible role manages Finder defaults including Column View and showing all filename extensions.
- Project artifacts live on the NAS `WorkArtifacts` SMB share and are expected at `/Volumes/WorkArtifacts` when mounted locally; artifact scripts prefer that mounted share and only fall back to the older `syncthing.lan` SSH path for legacy setups.
- Local `.test` development domains are managed via the `localdev` role using `dnsmasq` and `caddy` on macOS through root LaunchDaemons.
- Machine-scoped Ansible roles are supported through `~/.machine`: if that file exists and contains exactly `laptop` or `desktop`, the matching scoped role runs after the shared roles; if the file is absent, neither scoped role runs.
- `yabai` also reads `~/.machine` directly for display-specific behavior; on `desktop` it reserves top workspace for SketchyBar with `external_bar` so tiled windows do not render underneath the bar on a notchless display, and re-applies that reservation after Dock restarts.
- `sketchybar` also reads `~/.machine` directly for display-specific behavior; on `desktop` it centers `now_playing`, while `laptop` keeps `now_playing` on the right.
- The SketchyBar right side includes a simple weather label immediately left of the clock, fetched from `wttr.in` and rendered as a temperature like `55°F`.
- SketchyBar also includes a compact workspace-apps popup next to the space selector that lists occupied workspaces as `Utility`, `1-12`, and `Scratch`, with each row focusing that space.
- The SketchyBar tmux popup lists each session with indented `open` and `kill` actions; `open` launches a new Ghostty window attached to that session and `kill` terminates only that tmux session.
- A daily Launchd job organizes `~/Screenshots` into `month/day` folders using each file's creation date, and `sso` runs that organizer on demand.
- The screenshot archive job runs the organizer first, then rsyncs new screenshots to `syncthing.lan:/srv/Files/Erik/Screenshots` while preserving the organized folder structure.
- Launchd jobs archive organized screenshots and move `~/Downloads` entries older than 7 days to `syncthing.lan:/srv/Files/Erik/...`.
- Syncthing is managed via the `syncthing` role and currently syncs `~/Docs` and `~/Work` to the existing Syncthing server profile from Omarchy.
- Yabai is installed by Ansible and copies tracked files from `config/yabai` into `~/.config/yabai`.
- Yabai floats utility apps like `Ivanti Secure Access`, `Tailscale`, `Weather`, and `logioptionsplus` by default so they stay out of the BSP tiling tree.
- Borders is installed by Ansible and uses a tracked `config/borders/bordersrc` under `~/.config/borders` for focused window borders.
- skhd is installed by Ansible and uses a tracked `config/skhd/skhdrc` symlinked to `~/.config/skhd/skhdrc`.
- SketchyBar is installed by Ansible and uses a tracked `config/sketchybar` under `~/.config/sketchybar`.
- Ansible enables the Mission Control setting `Displays have separate Spaces`, which yabai requires to start.
- yabai is configured for BSP tiling by default, creates up to 12 spaces on the primary display, and Borders provides a thin cyan focus border while skhd binds workspace navigation to `Option+1-0,-,=` with window focus/movement on `Option+h/j/k/l` and `Option+Shift+h/j/k/l`.
- Window resizing is bound to `Option+Shift+,` and `Option+Shift+.` for width, plus `Command+Option+Shift+,` and `Command+Option+Shift+.` for height.
- Ansible manages passwordless sudo for the local user via `/private/etc/sudoers.d/<user>`; the first apply still requires an authenticated sudo run.
- macOS still requires Accessibility permission for `skhd` and window manager permissions for `yabai` in System Settings.
- Chrome web apps are created manually, then customized from this repo. Create web apps for `Claude`, `ChatGPT`, and `YouTube`, then wire them into managed launchers and icons here.
