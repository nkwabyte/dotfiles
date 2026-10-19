# ℹ️ Dotfiles: Cautions & Options Reference

This document serves as a dedicated reference for **security cautions, best practices, and configuration options** when managing this dotfiles repository.

---

## 📑 Table of Contents

- [⚠️ Critical Cautions & Security Rules](#️-critical-cautions--security-rules)
  - [1. Never Commit Private Keys or Secrets](#1-never-commit-private-keys-or-secrets)
  - [2. Strict File & Directory Permissions](#2-strict-file--directory-permissions)
  - [3. Beware of Tools Overwriting Symlinks](#3-beware-of-tools-overwriting-symlinks)
  - [4. Protecting Environment Variables & API Tokens](#4-protecting-environment-variables--api-tokens)
  - [5. Git Remote & Commit Verification](#5-git-remote--commit-verification)
- [⚙️ Configuration Options & Architecture](#️-configuration-options--architecture)
  - [Option A: SSH Configuration (Tracked vs. Local)](#option-a-ssh-configuration-tracked-vs-local)
  - [Option B: Shell Configuration (Global vs. Local)](#option-b-shell-configuration-global-vs-local)
  - [Option C: Prompt & Terminal Profiles](#option-c-prompt--terminal-profiles)
  - [Option D: GNU Stow Operations](#option-d-gnu-stow-operations)
  - [Option E: Backups & Restorations](#option-e-backups--restorations)
- [📊 Quick Reference Matrix](#-quick-reference-matrix)

---

## ⚠️ Critical Cautions & Security Rules

### 1. Never Commit Private Keys or Secrets

> [!CAUTION]
> **NEVER copy private keys (`id_ed25519`, `id_rsa`, `*.pem`, `*.key`) or credentials into the `dotfiles/` directory.**
> 
> * Once a secret is committed to a Git repository, it remains in Git history even if deleted in a later commit.
> * If your dotfiles repo is pushed to GitHub, private keys will be exposed to repository viewers or scanners.
> * Keep all private keys directly in `~/.ssh/` on your local machine only.

### 2. Strict File & Directory Permissions

> [!WARNING]
> OpenSSH enforces strict permission audits. If permissions on `~/.ssh` or private keys are too loose (e.g. readable by group or others), SSH will refuse connections with:
> `Permissions 0777 for 'id_...' are too open. It is recommended that your private key files are NOT accessible by others.`

Set and maintain standard permissions:

```bash
# SSH directory itself (only you can read/write/list)
chmod 700 ~/.ssh

# Private keys (strictly read/write for owner only)
chmod 600 ~/.ssh/id_*
chmod 600 ~/.ssh/*.pem

# Public keys (safe to be readable by others)
chmod 644 ~/.ssh/*.pub

# SSH config & authorized keys
chmod 600 ~/.ssh/config.local
chmod 644 ~/.ssh/config  # Note: ~/.ssh/config is a symlink; permission applies to dotfiles/ssh/ssh-config
chmod 600 ~/.ssh/authorized_keys
chmod 644 ~/.ssh/known_hosts
```

### 3. Beware of Tools Overwriting Symlinks

> [!IMPORTANT]
> The dotfiles setup relies on **symbolic links** pointing from your home directory (`~/.ssh/config`, `~/.zshrc`, `~/.config/...`) into `~/Dev/Bash/dotfiles/`.
>
> * Some text editors or GUI tools perform "atomic saves" by writing a temporary file and renaming it, which **destroys the symlink** and replaces it with a standalone file.
> * When a symlink is broken:
>   - Edits you make in your home folder will stop syncing with your Git dotfiles repository.
>   - Re-running `./setup.sh` will warn about a file conflict and back up the standalone file.
>
> **Verify your symlinks at any time:**
> ```bash
> ls -l ~/.ssh/config
> # Expected: ~/.ssh/config -> /Users/.../Dev/Bash/dotfiles/ssh/ssh-config
>
> ls -l ~/.zshrc
> # Expected: ~/.zshrc -> /Users/.../Dev/Bash/dotfiles/zshrc/.zshrc
> ```

### 4. Protecting Environment Variables & API Tokens

> [!CAUTION]
> Never export plain-text API tokens (`OPENAI_API_KEY`, `GITHUB_TOKEN`, `AWS_SECRET_ACCESS_KEY`) in [`.zshrc`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/zshrc/.zshrc).
>
> * Place all secrets in `~/.zshrc.local`.
> * `~/.zshrc.local` is ignored in [`.gitignore`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/.gitignore) and will never be pushed to your repository.

### 5. Git Remote & Commit Verification

> [!TIP]
> Before running `git push`, always review modified files:
> ```bash
> git status
> git diff
> ```
> Verify your remote points to your personal repository:
> ```bash
> git remote -v
> # Expected: origin https://github.com/nkwabyte/dotfiles.git
> ```

---

## ⚙️ Configuration Options & Architecture

### Option A: SSH Configuration (Tracked vs. Local)

You have two complementary options for managing SSH connections:

#### Option 1: Tracked Hosts (`dotfiles/ssh/ssh-config`)
* **Location**: [`ssh/ssh-config`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/ssh/ssh-config) (or `~/.ssh/config`)
* **Tracked by Git**: **Yes**
* **Best used for**:
  - Personal cloud VPS (DigitalOcean, AWS, Linode)
  - Code hosting platforms (GitHub, GitLab, Bitbucket)
  - Public jumpboxes / non-confidential homelab devices
* **Instant Effect**: No reload command required. OpenSSH reads `~/.ssh/config` dynamically on every command.

#### Option 2: Private / Local Hosts (`~/.ssh/config.local`)
* **Location**: `~/.ssh/config.local`
* **Tracked by Git**: **No** (`*.local` is ignored in `.gitignore`)
* **Best used for**:
  - Work/employer servers and corporate intranets
  - Client production machines and confidential IP addresses
  - Special internal jump proxies
* **How it works**: Included automatically at line 16 of [`ssh/ssh-config`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/ssh/ssh-config):
  ```ssh
  Include ~/.ssh/config.local
  ```

---

### Option B: Shell Configuration (Global vs. Local)

#### Option 1: Global Zsh Config (`dotfiles/zshrc/.zshrc`)
* **Location**: [`zshrc/.zshrc`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/zshrc/.zshrc) (or `~/.zshrc`)
* **Tracked by Git**: **Yes**
* **Best used for**:
  - General shell aliases (`ll`, `gs`, `gco`)
  - Shared PATH configurations (`$HOME/bin`, brew paths)
  - Universal tools (fzf, zoxide, atuin, starship prompt)
* **To apply changes**:
  ```bash
  source ~/.zshrc
  ```

#### Option 2: Machine-Local Zsh Config (`~/.zshrc.local`)
* **Location**: `~/.zshrc.local`
* **Tracked by Git**: **No** (`.zshrc.local` is ignored in `.gitignore`)
* **Best used for**:
  - Machine-specific API keys and confidential environment variables
  - Work-specific internal proxies or company VPN paths
  - Local workstation hardware tweaks
* **How it works**: Sourced automatically at the end of [`.zshrc`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/zshrc/.zshrc):
  ```zsh
  [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
  ```

---

### Option C: Prompt & Terminal Profiles

#### Ghostty vs. macOS Terminal.app
* **Nerd Fonts**: Both terminals require a Nerd Font (e.g. `MesloLGS NF` or `JetBrainsMono Nerd Font`) to display Starship's powerline pill icons without missing character glyphs.
* **Window Dragging in Ghostty**:
  - Configured in [`ghostty/config`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/ghostty/config):
    ```ini
    macos-titlebar-style = "transparent"
    window-padding-x = 12
    window-padding-y = 10
    ```
  - Allows full dragging anywhere along the top title bar area.
* **macOS Terminal.app Shell Command**:
  - In *Terminal > Settings > Profiles > Shell*, ensure **Run command** is unchecked unless you specifically intend to run a command on startup.
  - Set **Shells open with** to *Default login shell*.

---

### Option D: GNU Stow Operations

GNU Stow manages symlinks between the dotfiles repository and target destinations.

| Action | Command | Purpose |
| :--- | :--- | :--- |
| **Full Installation** | `./setup.sh` | Installs brew packages and links all configurations |
| **Dry Run Preview** | `./setup.sh --dry-run` | Shows actions without modifying any files |
| **Re-stow Package** | `stow -R -v -d ~/Dev/Bash/dotfiles -t ~/.config <pkg>` | Refreshes/rebuilds symlinks for a specific package |
| **Un-stow / Remove** | `stow -D -v -d ~/Dev/Bash/dotfiles -t ~/.config <pkg>` | Safely deletes symlinks for a package without touching source files |

---

### Option E: Backups & Restorations

Whenever [`setup.sh`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/setup.sh) encounters existing non-symlink files, it moves them to:

```text
~/.dotfiles_backup/<timestamp>/
```

* **Purpose**: Guarantees zero data loss during installation.
* **Restoring a backed-up file**:
  ```bash
  # Check your backups
  ls -la ~/.dotfiles_backup/
  
  # Copy back any original configuration if needed
  cp -R ~/.dotfiles_backup/<timestamp>/<filename> <destination>
  ```

---

## 📊 Quick Reference Matrix

| File / Component | Location | Tracked in Git? | Permissions | Purpose |
| :--- | :--- | :---: | :---: | :--- |
| **Shared SSH Config** | [`ssh/ssh-config`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/ssh/ssh-config) | **Yes** | `644` | Public / general host configs |
| **Private SSH Config** | `~/.ssh/config.local` | **No** | `600` | Confidential / work / client hosts |
| **Private SSH Keys** | `~/.ssh/id_*` | **NEVER** | `600` | Identity files / authentication |
| **Public SSH Keys** | `~/.ssh/id_*.pub` | **NEVER** (keep in `~/.ssh/`) | `644` | Public keys for servers |
| **Global Shell Config** | [`zshrc/.zshrc`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/zshrc/.zshrc) | **Yes** | `644` | Common shell aliases & PATH |
| **Local Shell Config** | `~/.zshrc.local` | **No** | `600` | Secrets, API tokens, local PATH |
| **Starship Prompt** | [`starship/starship.toml`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/starship/starship.toml) | **Yes** | `644` | Prompt theme & style modules |
| **Ghostty Terminal** | [`ghostty/config`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/ghostty/config) | **Yes** | `644` | Terminal theme, fonts, titlebar |
| **Safety Backups** | `~/.dotfiles_backup/` | **No** | `700` | Pre-stow original files |
