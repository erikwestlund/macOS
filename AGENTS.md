# AGENTS

This repository manages system configuration for this Mac.

It is being ported over gradually from an older Linux-based setup, located at ~/Code/System/Omarchy.

This repository should serve as a reference for needs on this machine, but the modus operandi is to check in on each decision and follow the user's direction when settings things up.

# Differences of Omarchy vs macOS System

- The mac uses Brew as a package manager, orchestrated by ansible. 
- The mac uses zsh, not bash.

# Idioms

## README.md

The README should provide declarative context. Try not to be redundant with this repository. REAMDE.md is the source of truth; this file tells the system how to work.

Keep `README.md` current when repository behavior changes. In particular, document alias coverage inherited from Omarchy and machine-scoped Ansible behavior such as `~/.machine` driving `laptop` and `desktop` roles.

## Symlinks

Where it is *not* fragile, we should symlink config in this repository. However, if symlinks are fragile we should prefer copying over files. An inventory of which should be kept in the README.md.

## Packages

Use Ansible to manage *all* system settings, applications, and packages. *NEVER* install packages or edit config files outside of this repository manually.

When ansible cannot be used, make a note in this file.

## File Structure

Put config files in `config` in an appropriate directory. Group like files in subdirectories. 

Do not use . prefixes in this repository.

## Aliases

Aliases are used to speed up common tasks. An ~/.aliases file is ingested by zsh.

Project-scoped aliases are also generated dynamically from `config/projects/projects.yml` via `project-meta`, including `d{alias}` and `dd{alias}` for Docker Compose.

The main ansible playbook which runs everything should have an alias of "mac-sys". This is equivalent to "om" in the Omarchy repository.

Common ansible runs should be aliased, using commands like:

- mac-packages: Run ansible role to install all packages.
- mac-dotfiles: Run ansible role to install all dotfiles.
- mac-prefs: Run ansible to configure default macOS preferences not covered by dotfiles.
