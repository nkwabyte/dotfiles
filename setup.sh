#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Setup Script
# Idempotent installation, symlinking, and setup verification
# ==============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false

# ANSI colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ ${NC}$1"; }
log_success() { echo -e "${GREEN}✔ ${NC}$1"; }
log_warn() { echo -e "${YELLOW}⚠ ${NC}$1"; }
log_error() { echo -e "${RED}✖ ${NC}$1"; }

usage() {
    cat <<EOF
Usage: ./setup.sh [OPTIONS]

Options:
    -n, --dry-run     Simulate actions without modifying filesystem
    -h, --help        Show this help message

Description:
    Links dotfiles to ~/.config and \$HOME, configures Hammerspoon,
    installs TPM, compiles sketchybar helper, and verifies prerequisites.
EOF
    exit 0
}

# Parse flags
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--dry-run) DRY_RUN=true; shift ;;
        -h|--help) usage ;;
        *) log_error "Unknown option: $1"; usage ;;
    esac
done

echo -e "${BOLD}=========================================${NC}"
echo -e "${BOLD}       Dotfiles Setup & Verification     ${NC}"
echo -e "${BOLD}=========================================${NC}"
log_info "Dotfiles directory: $DOTFILES_DIR"

if [ "$DRY_RUN" = true ]; then
    log_warn "Running in SIMULATION MODE (dry-run). No changes will be made."
fi

# 1. Check prerequisites
echo ""
log_info "Step 1: Checking essential prerequisites..."
if ! command -v stow >/dev/null 2>&1; then
    log_error "GNU Stow is not installed. Please install it first: 'brew install stow'"
    exit 1
fi
log_success "GNU Stow found: $(command -v stow)"

if ! command -v git >/dev/null 2>&1; then
    log_error "Git is not installed. Please install it first."
    exit 1
fi
log_success "Git found: $(command -v git)"

# 2. Check for hardcoded usernames
echo ""
log_info "Step 2: Checking for un-migrated 'omerxx' references in config files..."
HARDCODED_MATCHES=$(grep -rnE "(/Users/omerxx|omerxx@)" \
    --exclude-dir=".git" \
    --exclude="setup.sh" \
    --exclude="README.md" \
    --exclude="*.plist" \
    "$DOTFILES_DIR" | wc -l || true)

if [ "$HARDCODED_MATCHES" -gt 0 ]; then
    log_warn "Found $HARDCODED_MATCHES occurrence(s) of upstream user paths in config files."
    log_warn "Review these files to customize paths for your user ($USER):"
    grep -rnE "(/Users/omerxx|omerxx@)" \
        --exclude-dir=".git" \
        --exclude="setup.sh" \
        --exclude="README.md" \
        --exclude="*.plist" \
        "$DOTFILES_DIR" | head -n 5 || true
    echo "  (See README.md for the complete personalization checklist)"
else
    log_success "No hardcoded user paths or accounts found."
fi

# 3. Ensure target directories exist
echo ""
log_info "Step 3: Preparing directory structure..."
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.ssh"
fi
log_success "Base target directories verified (~/.config, ~/.ssh)"

# 4. Stow ~/.config directories
echo ""
log_info "Step 4: Symlinking configs into ~/.config via GNU Stow..."
if [ "$DRY_RUN" = true ]; then
    stow -n -v -d "$DOTFILES_DIR" -t "$HOME/.config" .
else
    stow -v -d "$DOTFILES_DIR" -t "$HOME/.config" .
fi
log_success "~/.config packages linked."

# 5. Handle ~/.zshrc
echo ""
log_info "Step 5: Managing ~/.zshrc symlink..."
TARGET_ZSHRC="$HOME/.zshrc"
SOURCE_ZSHRC="$DOTFILES_DIR/zshrc/.zshrc"

if [ -L "$TARGET_ZSHRC" ] && [ "$(readlink "$TARGET_ZSHRC")" = "$SOURCE_ZSHRC" ]; then
    log_success "~/.zshrc is already linked to dotfiles."
else
    if [ -f "$TARGET_ZSHRC" ] || [ -L "$TARGET_ZSHRC" ]; then
        log_warn "Existing ~/.zshrc found."
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$BACKUP_DIR"
            cp -L "$TARGET_ZSHRC" "$BACKUP_DIR/.zshrc.bak"
            log_info "Backed up existing ~/.zshrc to $BACKUP_DIR/.zshrc.bak"
            rm -f "$TARGET_ZSHRC"
            ln -s "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
            log_success "Linked $TARGET_ZSHRC -> $SOURCE_ZSHRC"
        else
            log_info "[Dry-Run] Would back up ~/.zshrc to $BACKUP_DIR and link to $SOURCE_ZSHRC"
        fi
    else
        if [ "$DRY_RUN" = false ]; then
            ln -s "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
            log_success "Linked $TARGET_ZSHRC -> $SOURCE_ZSHRC"
        else
            log_info "[Dry-Run] Would link $TARGET_ZSHRC -> $SOURCE_ZSHRC"
        fi
    fi
fi

# 6. Handle SSH config
echo ""
log_info "Step 6: Managing ~/.ssh/config symlink..."
TARGET_SSH="$HOME/.ssh/config"
SOURCE_SSH="$DOTFILES_DIR/ssh/ssh-config"

if [ -L "$TARGET_SSH" ] && [ "$(readlink "$TARGET_SSH")" = "$SOURCE_SSH" ]; then
    log_success "~/.ssh/config is already linked to dotfiles."
else
    if [ -f "$TARGET_SSH" ] || [ -L "$TARGET_SSH" ]; then
        log_warn "Existing ~/.ssh/config found."
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$BACKUP_DIR"
            cp -L "$TARGET_SSH" "$BACKUP_DIR/ssh_config.bak"
            log_info "Backed up existing ~/.ssh/config to $BACKUP_DIR/ssh_config.bak"
            rm -f "$TARGET_SSH"
            ln -s "$SOURCE_SSH" "$TARGET_SSH"
            chmod 600 "$SOURCE_SSH"
            log_success "Linked $TARGET_SSH -> $SOURCE_SSH"
        else
            log_info "[Dry-Run] Would back up ~/.ssh/config to $BACKUP_DIR and link to $SOURCE_SSH"
        fi
    else
        if [ "$DRY_RUN" = false ]; then
            ln -s "$SOURCE_SSH" "$TARGET_SSH"
            chmod 600 "$SOURCE_SSH"
            log_success "Linked $TARGET_SSH -> $SOURCE_SSH"
        else
            log_info "[Dry-Run] Would link $TARGET_SSH -> $SOURCE_SSH"
        fi
    fi
fi

# 7. Tmux Plugin Manager (TPM)
echo ""
log_info "Step 7: Checking Tmux Plugin Manager (TPM)..."
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    log_info "Installing TPM..."
    if [ "$DRY_RUN" = false ]; then
        git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
        log_success "TPM installed to $TPM_DIR"
    else
        log_info "[Dry-Run] Would git clone TPM to $TPM_DIR"
    fi
else
    log_success "TPM is already installed at $TPM_DIR"
fi

# 8. Hammerspoon configuration path
echo ""
log_info "Step 8: Configuring Hammerspoon config path..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ "$DRY_RUN" = false ]; then
        defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua" 2>/dev/null || true
        log_success "Hammerspoon default config path configured."
    else
        log_info "[Dry-Run] Would run: defaults write org.hammerspoon.Hammerspoon MJConfigFile '~/.config/hammerspoon/init.lua'"
    fi
fi

# 9. Summary & Next Steps
echo ""
echo -e "${BOLD}=========================================${NC}"
echo -e "${GREEN}${BOLD}         Setup Complete! 🎉             ${NC}"
echo -e "${BOLD}=========================================${NC}"
echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo "1. Reload your shell: 'source ~/.zshrc' or open a new terminal."
echo "2. In tmux, press 'Ctrl-a' followed by 'I' (capital i) to install all tmux plugins via TPM."
echo "3. Grant macOS Accessibility permissions for skhd / Hammerspoon if needed in System Settings."
echo "4. Install missing Homebrew formulae / casks if needed (see README.md)."
echo ""
