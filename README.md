# ⚡ Personal macOS Dotfiles

A modular, clean, and keyboard-driven macOS development environment configured with modern CLI tools, terminal multiplexing, and Catppuccin styling.

---

## 📑 Table of Contents

- [Overview & Architecture](#-overview--architecture)
- [Directory Map & Targets](#-directory-map--targets)
- [Prerequisites & Package Installation](#-prerequisites--package-installation)
  - [1. Package Managers & Core Tools](#1-package-managers--core-tools)
  - [2. GUI Applications & Daemons](#2-gui-applications--daemons)
  - [3. Required Fonts](#3-required-fonts)
- [Quick Start (Automated Setup)](#-quick-start-automated-setup)
- [Manual Setup with GNU Stow](#-manual-setup-with-gnu-stow)
- [Post-Install Checklist](#-post-install-checklist)
  - [1. Install Tmux Plugins (TPM)](#1-install-tmux-plugins-tpm)
  - [2. Configure Hammerspoon Path](#2-configure-hammerspoon-path)
  - [3. macOS Security & Accessibility Permissions](#3-macos-security--accessibility-permissions)
- [SSH & Local Machine Configuration](#-ssh--local-machine-configuration)
- [Fork Personalization Status](#-fork-personalization-status)
- [Daily Keybindings & Workflow Cheatsheet](#-daily-keybindings--workflow-cheatsheet)
  - [Tmux (Multiplexer)](#tmux-multiplexer)
  - [Zsh Aliases & Navigation](#zsh-aliases--navigation)
- [Maintenance & Managing New Dotfiles](#-maintenance--managing-new-dotfiles)

---

## 🔭 Overview & Architecture

This repository brings together a cohesive Unix terminal and macOS developer workflow:

| Component | Tool | Purpose |
| :--- | :--- | :--- |
| **Terminal** | [Ghostty](https://ghostty.org/) | Fast, GPU-accelerated terminal emulator with custom shaders and blur |
| **Hotkeys** | [skhd](https://github.com/koekeishiya/skhd) | Simple hotkey daemon for quick application launching & AppleScripts |
| **Automation** | [Hammerspoon](https://www.hammerspoon.org/) | Lua desktop automation & widgets |
| **Key Remapping** | [Karabiner-Elements](https://karabiner-elements.pqrs.org/) / kindaVim | Low-level keyboard customizer & system-wide Vim navigation |
| **Shell** | [Zsh](https://www.zsh.org/) / [Nushell](https://www.nushell.sh/) | Vi-mode enabled shell with rich aliases, fuzzy finding, and autocompletion |
| **Prompt** | [Starship](https://starship.rs/) | Minimal, fast, and informative cross-shell prompt (Catppuccin Mocha) |
| **Multiplexers** | [tmux](https://github.com/tmux/tmux) / [Zellij](https://zellij.dev/) | Session persistence, floating scratchpad terminals (`floax`), and fuzzy session switching (`sessionx`) |
| **Editor** | [Neovim](https://neovim.io/) | Full IDE experience built on [LazyVim](https://www.lazyvim.org/) with Go, Conform, and surround support |
| **Fuzzy Finding** | [Television](https://github.com/alexpasmantier/television) & [fzf](https://github.com/junegunn/fzf) | High-speed fuzzy pickers for git, containers, k8s, processes, and files |
| **SSH Client** | OpenSSH | Configured with macOS Keychain integration, keep-alives, and jump-hosts |
| **System (Optional)** | [Nix-Darwin](https://github.com/LnL7/nix-darwin) | Declarative macOS system & Home Manager flakes |

---

## 🗺 Directory Map & Targets

Configurations in this repository are managed using [GNU Stow](https://www.gnu.org/software/stow/):

```
dotfiles/
├── .stowrc                 # Defines default Stow target (~/.config) and ignore rules
├── setup.sh                # Automated, idempotent installation & verification script
│
├── atuin/                  ───► ~/.config/atuin/config.toml
├── gh-dash/                ───► ~/.config/gh-dash/config.yml
├── ghostty/                ───► ~/.config/ghostty/config
├── hammerspoon/            ───► ~/.config/hammerspoon/init.lua
├── karabiner/              ───► ~/.config/karabiner/karabiner.json
├── nix/                    ───► ~/.config/nix/nix.conf
├── nix-darwin/             ───► ~/.config/nix-darwin/flake.nix
├── nushell/                ───► ~/.config/nushell/config.nu
├── nvim/                   ───► ~/.config/nvim/init.lua
├── skhd/                   ───► ~/.config/skhd/skhdrc
├── starship/               ───► ~/.config/starship/starship.toml
├── television/             ───► ~/.config/television/config.toml
├── tmux/                   ───► ~/.config/tmux/tmux.conf
├── zellij/                 ───► ~/.config/zellij/config.kdl
│
├── zshrc/                  ───► ~/.zshrc              (Targets $HOME, not ~/.config)
├── ssh/                    ───► ~/.ssh/config         (Targets $HOME, not ~/.config)
└── kindavim/               ───► ~/Library/Preferences/ (macOS preference plist)
```

---

## 📦 Prerequisites & Package Installation

Install [Homebrew](https://brew.sh/) if not already installed:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 1. Package Managers & Core Tools
```bash
brew install \
  stow \
  git \
  zsh \
  zsh-autosuggestions \
  neovim \
  tmux \
  starship \
  fzf \
  ripgrep \
  fd \
  bat \
  eza \
  zoxide \
  atuin \
  direnv \
  tree \
  xh
```

### 2. GUI Applications & Daemons
```bash
# Terminal & Hotkeys
brew install --cask ghostty
brew install koekeishiya/formulae/skhd
brew install --cask hammerspoon
brew install --cask karabiner-elements
```

### 3. Required Fonts
```bash
brew tap homebrew/cask-fonts 2>/dev/null || true
brew install --cask font-jetbrains-mono-nerd-font
```

---

## 🚀 Quick Start (Automated Setup)

An idempotent, safe `setup.sh` is provided in the root directory.

### Step 1: Run Simulation (Dry-Run)
Test the setup without modifying your filesystem:
```bash
cd ~/Dev/Bash/dotfiles
./setup.sh --dry-run
```

### Step 2: Apply the Configuration
```bash
./setup.sh
```

**What `setup.sh` automatically handles:**
- Verifies `stow` and `git` are installed.
- Scans for any remaining unmigrated username references.
- Creates `~/.config` and `~/.ssh` directories if absent.
- Symlinks all `~/.config` tool packages using GNU Stow cleanly.
- Safely links `~/.zshrc` (backing up any existing file to `~/.dotfiles_backup/`).
- Safely links `~/.ssh/config` (backing up existing configs and setting `600` permissions).
- Clones Tmux Plugin Manager (`tpm`) to `~/.tmux/plugins/tpm` if missing.
- Sets the Hammerspoon configuration path default in macOS.

---

## 🔧 Manual Setup with GNU Stow

If you prefer to link packages manually with GNU Stow:

```bash
# 1. Symlink all ~/.config applications
stow -v -d ~/Dev/Bash/dotfiles -t ~/.config .

# 2. Symlink zshrc into your $HOME directory
# Backup existing .zshrc first if you have one:
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.bak
stow -v -d ~/Dev/Bash/dotfiles -t ~ zshrc

# 3. Symlink SSH config
mkdir -p ~/.ssh
[ -f ~/.ssh/config ] && mv ~/.ssh/config ~/.ssh/config.bak
ln -sf ~/Dev/Bash/dotfiles/ssh/ssh-config ~/.ssh/config
chmod 600 ~/Dev/Bash/dotfiles/ssh/ssh-config
```

---

## ⚡ Post-Install Checklist

Complete these manual steps after linking files:

### 1. Install Tmux Plugins (TPM)
1. Ensure TPM is installed:
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```
2. Start a new tmux session:
   ```bash
   tmux
   ```
3. Inside tmux, press `Ctrl + a` (the prefix key) followed by `Shift + i` (`I`) to fetch and compile all plugins.

### 2. Configure Hammerspoon Path
Tell macOS to read Hammerspoon from `~/.config/hammerspoon/init.lua`:
```bash
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
```

### 3. macOS Security & Accessibility Permissions
Grant accessibility permissions to helper utilities:
1. Open **System Settings ➔ Privacy & Security ➔ Accessibility**.
2. Add and toggle **ON**:
   - `skhd`
   - `Hammerspoon`
   - `Karabiner-Elements` (also requires Input Monitoring)

---

## 🔐 SSH & Local Machine Configuration

### 1. SSH Architecture
- **Global & Host Config**: Tracked in [`ssh/ssh-config`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/ssh/ssh-config). It configures modern macOS OpenSSH defaults (`AddKeysToAgent yes`, `UseKeychain yes`, keep-alives) and maps your Git/server host aliases (`github-musahibrahimali`, `github-nkwabyte`, `github-datatrux`, `gitlab-knust`, `nkwabyte`, `bolvs-server`, `geetconsult`, `knust-gpu`, `ubuntu-rail`).
- **Private Key Safety**: Your private keys (`~/.ssh/id_*`, `*.pem`, `*.key`) and `known_hosts` are explicitly ignored in [`.gitignore`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/.gitignore) and are **never** committed to version control.
- **Local Overrides**: An `Include ~/.ssh/config.local` directive is enabled at the top of `ssh-config` so you can add temporary, private, or machine-specific keys without altering the tracked repository.

### 2. Local Zsh Overrides (`~/.zshrc.local`)
Your [`.zshrc`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/zshrc/.zshrc) dynamically sources `~/.zshrc.local` if it exists. Use this for secrets, temporary tokens, or work-specific paths that should not be committed to Git.

---

## 🔍 Fork Personalization Status

All hardcoded filesystem paths from the upstream author (`omerxx`) have been fully migrated and made dynamic across this repository:

| Component | Status | Description |
| :--- | :--- | :--- |
| **`zshrc/.zshrc`** | ✅ Complete | Dynamic `$HOME`, clean PATH order, preserved `fnm`, Docker completions, Antigravity, and C++ LLVM toolchain |
| **`ssh/ssh-config`** | ✅ Complete | Replaced legacy MACs with modern macOS keychain support and updated host aliases |
| **`tmux/tmux.conf`** | ✅ Complete | Points `@sessionx-custom-paths` to `~/Dev/Bash/dotfiles` |
| **`hammerspoon`** | ✅ Complete | Guarded calendar execution so missing paths don't throw errors |
| **`nushell/env.nu`** | ✅ Complete | Uses dynamic `$env.HOME` path joins for `local/bin` and Starship config |
| **`starship.toml`** | ✅ Complete | Increased `command_timeout = 3000` and purged upstream cluster references |
| **`nix-darwin`** | ✅ Complete | Updated `musahibrahimali` user and home directory in `flake.nix` and `home.nix` |

---

## ⌨️ Daily Keybindings & Workflow Cheatsheet

### Tmux (Multiplexer)

Prefix is **`Ctrl + a`** (rebound from `Ctrl + b`):

| Keybinding | Action |
| :--- | :--- |
| `Prefix` then `o` | **SessionX**: Fuzzy session picker and switcher (with Zoxide integration) |
| `Prefix` then `p` | **Floax**: Open floating scratchpad terminal overlay |
| `Prefix` then `|` / `\` | Split pane horizontally |
| `Prefix` then `-` | Split pane vertically |
| `Prefix` then `h` / `j` / `k` / `l` | Navigate between panes |
| `Prefix` then `z` | Zoom / toggle fullscreen pane |
| `Prefix` then `u` | **fzf-url**: Fuzzy search and open URLs from terminal buffer |
| `Prefix` then `I` | Install new TPM plugins |
| `Prefix` then `U` | Update TPM plugins |

### Zsh Aliases & Navigation

- **Directory Jumping & Listing:**
  - `l` ➔ `eza -l --icons --git -a` (modern ls)
  - `lt` ➔ `eza --tree --level=2 --long --icons --git`
  - `cx <dir>` ➔ `cd` into `<dir>` and list contents with `l`
  - `fcd` ➔ Interactive directory jump with `find` + `fzf`
  - `fv` ➔ Interactive fuzzy search for file and open in Neovim
  - `f` ➔ Fuzzy find file path and copy to macOS clipboard (`pbcopy`)
- **Git Shortcuts:**
  - `gs` / `gst` ➔ `git status`
  - `gc` / `gcm "msg"` ➔ `git commit` / `git commit -m`
  - `gp` ➔ `git push`
  - `gpu` ➔ `git pull origin`
  - `gl` ➔ `git log --oneline --graph --decorate`
  - `glog` ➔ Pretty colorized commit graph
  - `gdiff` ➔ `git diff`
- **Docker & K8s:**
  - `dco` ➔ `docker compose`
  - `dps` ➔ `docker ps`
  - `k` ➔ `kubectl`
  - `kc` ➔ `kubectx`
  - `kns` ➔ `kubens`

---

## 🛠 Maintenance & Managing New Dotfiles

### Adding a new config directory
1. Place the config directory inside this repository (e.g., `~/Dev/Bash/dotfiles/bat`).
2. Run Stow to link it to `~/.config`:
   ```bash
   stow -v -d ~/Dev/Bash/dotfiles -t ~/.config bat
   ```
3. Commit and push the changes to your fork.

### Updating or re-linking dotfiles
If you modify files or add subdirectories:
```bash
# Re-stow all configs
stow -R -v -d ~/Dev/Bash/dotfiles -t ~/.config .
```

### Removing symlinks (Unstow)
If you ever want to cleanly unlink a package:
```bash
stow -D -v -d ~/Dev/Bash/dotfiles -t ~/.config <package_name>
```
