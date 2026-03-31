# Config Revisit

This file tracks config decisions we intentionally skipped, deferred, or only partially implemented so they can be revisited later.

## Window Manager

- Add a richer Hyprland-like `yabai` baseline beyond current BSP setup.
- Add more `skhd` window-management bindings:
  - float/tile toggle refinements
  - fullscreen toggle
  - rotate/mirror BSP tree
  - additional resize and insertion controls
- Review whether app-specific float rules should be expanded beyond:
  - `System Settings`
  - `1Password`
  - `Messages`
- Revisit scratch workspace behavior if it needs to feel closer to Hyprland special workspaces.

## SketchyBar

- Continue tuning the bar design language toward the reference style.
- Revisit workspace occupancy coloring if stale or ambiguous behavior returns.
- Decide whether the workspace bracket border should remain or become even subtler.
- Add richer right-side status items if desired:
  - wifi
  - battery
  - volume
- Consider app icons or improved front-app display.

## Borders

- Revisit focused window border color/width if visibility changes with different apps/themes.
- Consider whether inactive windows should get a faint border instead of fully transparent.

## Shell

- Revisit zsh behavior and keybindings after using the new autosuggestion/completion setup.
- Decide whether to add more `oh-my-zsh`-like behavior directly, or keep the current minimal plugin stack.
- Review merged aliases later and trim redundant or low-value ones.

## Secrets

- Harden secrets scripts further if needed.
- Consider whether to restore more of the full Omarchy secrets workflow:
  - project `.env` sync
  - project vault sync
  - `.kamal` secret sync
- Clean up old or noisy payload in remote secrets store:
  - `backups/**`
  - stray `.DS_Store`
  - any stale secret files no longer needed
- Decide whether `~/.secrets/ssh/config.bak` and other legacy SSH artifacts should remain.

## SSH / Git / Hosts

- Revisit whether tracked SSH config should eventually include all current hosts or be pruned.
- Revisit Git credential strategy:
  - keep `credential.helper = cache`
  - or switch to macOS Keychain integration later
- Confirm whether `/etc/hosts` should remain fully secrets-driven or move into tracked config.

## Web Apps

- Add focus-or-launch helpers for Chrome web apps if needed in addition to always-new launchers.
- Revisit icon management for web apps if Chrome updates replace bundle icons.
- Consider whether more web apps should be standardized and documented.

## System / macOS

- Decide later whether to manage main volume naming (`macOS` / `macOS - Data`) via Ansible or keep manual.
- Revisit a non-Karabiner approach for suppressing accidental `Cmd+H`, or move to Karabiner if needed.

## Launchers

- Build more launcher helpers using the new patterns:
  - focus-or-launch existing app
  - always open a new window
- Consider a generic launcher convention for hotkeys so app bindings stay predictable.
