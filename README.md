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
brew install ansible rclone

# 4. Run playbook
# -K prompts for sudo password
ANSIBLE_CONFIG=~/System/ansible/ansible.cfg ansible-playbook ~/System/ansible/playbook.yml -K
```

## Notes

- Dotfiles and system configuration live in `~/System`.
- Secrets are already set up separately and are not bootstrapped through this repository.
- Yabai is installed by Ansible and uses a tracked `config/yabai/yabairc` symlinked to `~/.config/yabai/yabairc`.
- Borders is installed by Ansible and uses a tracked `config/borders/bordersrc` under `~/.config/borders` for focused window borders.
- skhd is installed by Ansible and uses a tracked `config/skhd/skhdrc` symlinked to `~/.config/skhd/skhdrc`.
- SketchyBar is installed by Ansible and uses a tracked `config/sketchybar` under `~/.config/sketchybar`.
- Ansible enables the Mission Control setting `Displays have separate Spaces`, which yabai requires to start.
- yabai is configured for BSP tiling by default, creates up to 12 spaces on the primary display, and Borders provides a thin cyan focus border while skhd binds workspace navigation to `Option+1-0,-,=` with window focus/movement on `Option+h/j/k/l` and `Option+Shift+h/j/k/l`.
- Window resizing is bound to `Option+Shift+,` and `Option+Shift+.` for width, plus `Command+Option+Shift+,` and `Command+Option+Shift+.` for height.
- Ansible manages passwordless sudo for the local user via `/private/etc/sudoers.d/<user>`; the first apply still requires an authenticated sudo run.
- macOS still requires Accessibility permission for `skhd` and window manager permissions for `yabai` in System Settings.
- Chrome web apps are created manually, then customized from this repo. Create web apps for `Claude`, `ChatGPT`, and `YouTube`, then wire them into managed launchers and icons here.
