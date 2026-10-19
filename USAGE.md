# 📖 Dotfiles Usage & Daily Workflow Guide

This guide explains how to use, customize, and extend your dotfiles, including managing SSH configurations, shell overrides, and adding new application configs.

> [!TIP]
> For security cautions, strict file permissions, and architecture options (tracked vs. private configs), see the [Cautions & Options Guide (info.md)](info.md).

---

## 📑 Table of Contents

- [SSH Configuration & Management](#-ssh-configuration--management)
  - [Where to add new SSH connections](#where-to-add-new-ssh-connections)
  - [Do I need to run anything after editing?](#do-i-need-to-run-anything-after-editing)
  - [Public/Tracked Hosts vs. Secret/Private Hosts](#publictracked-hosts-vs-secretprivate-hosts)
  - [Generating and Linking New SSH Keys](#generating-and-linking-new-ssh-keys)
- [Zsh & Shell Overrides](#-zsh--shell-overrides)
  - [Adding Global Aliases](#adding-global-aliases)
  - [Adding Private / Work-Specific Overrides (`~/.zshrc.local`)](#adding-private--work-specific-overrides-zshrclocal)
- [Starship Prompt Customization](#-starship-prompt-customization)
- [Adding New Application Configs to Dotfiles](#-adding-new-application-configs-to-dotfiles)
- [Maintenance & Useful Commands](#-maintenance--useful-commands)

---

## 🔐 SSH Configuration & Management

### Where to add new SSH connections

Because `~/.ssh/config` is a **direct symlink** to `~/Dev/Bash/dotfiles/ssh/ssh-config`:

```text
~/.ssh/config  ───(symlink)───►  ~/Dev/Bash/dotfiles/ssh/ssh-config
```

* **Editing either file edits the exact same file on disk.**
* You can open either `~/.ssh/config` or `~/Dev/Bash/dotfiles/ssh/ssh-config` in your editor (`nvim ~/.ssh/config`).

### Do I need to run anything after editing?

**No!** 
* OpenSSH reads `~/.ssh/config` dynamically every single time you run `ssh <host>`, `git push`, or `scp`.
* There are no daemons to restart, no re-stow commands, and no reloads needed. Your changes are live the instant you save the file.

---

### Public/Tracked Hosts vs. Secret/Private Hosts

You have two ways to organize SSH hosts depending on whether you want them backed up in Git:

#### Option 1: Tracked Hosts (Backed up to your GitHub repository)
Use this for public/general servers, personal VPSs, and Git services:
1. Open [`ssh/ssh-config`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/ssh/ssh-config) (or `~/.ssh/config`).
2. Add your host block at the bottom:
   ```ssh
   Host myserver
       HostName 123.45.67.89
       User ubuntu
       IdentityFile ~/.ssh/id_ed25519_myserver
       IdentitiesOnly yes
   ```
3. Commit and push to your dotfiles repository:
   ```bash
   cd ~/Dev/Bash/dotfiles
   git add ssh/ssh-config
   git commit -m "feat(ssh): add myserver host"
   git push origin master
   ```

#### Option 2: Private / Confidential Hosts (Never pushed to Git)
Use this for work servers, private VPN tunnels, client hosts, or internal corporate IPs:
1. Open or create `~/.ssh/config.local`:
   ```bash
   nvim ~/.ssh/config.local
   ```
2. Add your private host block:
   ```ssh
   Host internal-work-server
       HostName 10.0.1.50
       User developer
       IdentityFile ~/.ssh/id_work_key
   ```
3. **How it works**:
   - [`ssh/ssh-config`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/ssh/ssh-config) includes `Include ~/.ssh/config.local` at line 16.
   - [`.gitignore`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/.gitignore) explicitly ignores `*.local`.
   - Your private hosts work seamlessly with `ssh internal-work-server`, but will **never** leak into Git.

---

### Generating and Linking New SSH Keys

> [!CAUTION]
> **Never copy private keys into the `dotfiles/` directory.**
> Private keys must always stay inside `~/.ssh/`.

1. Generate a secure Ed25519 key:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519_newservice
   ```
2. Ensure correct permissions on the key files:
   ```bash
   chmod 600 ~/.ssh/id_ed25519_newservice
   chmod 644 ~/.ssh/id_ed25519_newservice.pub
   ```
3. Add the key to macOS Keychain so you never have to re-type passphrases:
   ```bash
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519_newservice
   ```
4. Reference the key in `ssh-config`:
   ```ssh
   IdentityFile ~/.ssh/id_ed25519_newservice
   ```

---

## 🐚 Zsh & Shell Overrides

### Adding Global Aliases
To add aliases or functions that you want synced across all machines:
1. Edit [`zshrc/.zshrc`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/zshrc/.zshrc) (or `~/.zshrc`).
2. Add your alias in the Aliases section:
   ```zsh
   alias mycmd="echo 'hello world'"
   ```
3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

### Adding Private / Work-Specific Overrides (`~/.zshrc.local`)
For API keys, work proxy variables, or secrets:
1. Create or edit `~/.zshrc.local`:
   ```bash
   nvim ~/.zshrc.local
   ```
2. Add your environment variables:
   ```zsh
   export OPENAI_API_KEY="sk-..."
   export GITHUB_TOKEN="ghp_..."
   ```
3. [`.gitignore`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/.gitignore) ignores `.zshrc.local`, so your secrets remain safe on your local machine.

---

## 🎨 Starship Prompt Customization

Your prompt configuration lives in [`starship/starship.toml`](file:///Users/musahibrahimali/Dev/Bash/dotfiles/starship/starship.toml).

* **Preset**: Pastel Powerline (pill transitions).
* **Live Reloading**: Any change to `starship.toml` is applied instantly upon hitting **Enter** in your terminal.
* **Toggling Modules**: To enable or disable any module (e.g. `docker_context`, `nodejs`, `python`), set:
  ```toml
  [python]
  disabled = false
  ```

---

## 📦 Adding New Application Configs to Dotfiles

When you want to track a new CLI or GUI app in your dotfiles:

### Example: Tracking `bat` config
1. Move or create the config directory inside your `dotfiles` repo:
   ```bash
   mkdir -p ~/Dev/Bash/dotfiles/bat
   touch ~/Dev/Bash/dotfiles/bat/config
   ```
2. Use GNU Stow to link it into `~/.config`:
   ```bash
   stow -v -d ~/Dev/Bash/dotfiles -t ~/.config bat
   ```
3. Verify the link:
   ```bash
   ls -l ~/.config/bat
   # Output: ~/.config/bat -> ../Dev/Bash/dotfiles/bat
   ```
4. Commit and push:
   ```bash
   cd ~/Dev/Bash/dotfiles
   git add bat/
   git commit -m "feat: add bat configuration"
   git push origin master
   ```

---

## 🛠 Maintenance & Useful Commands

### Re-linking / Restowing all dotfiles
If you ever pull updates or delete a symlink by accident:
```bash
./setup.sh
```

### Dry-Run Simulation
To preview what `./setup.sh` would do without touching anything:
```bash
./setup.sh --dry-run
```

### Unlinking a package (Unstow)
If you decide you no longer want a package managed by Stow:
```bash
stow -D -v -d ~/Dev/Bash/dotfiles -t ~/.config <package_name>
```
