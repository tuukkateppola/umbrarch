#!/usr/bin/env bash
# Ensure yay AUR helper is installed

log_info "Checking for yay AUR helper..."

if command -v yay >/dev/null 2>&1; then
    log_info "yay is already installed"
    log_success "yay AUR helper available"
    return 0
fi

log_info "yay not found, installing from AUR..."

START_DIR=$(pwd)
TEMP_DIR=$(mktemp -d)
# Cleanup: remove temp directory and return to original directory
trap 'cd "$START_DIR" 2>/dev/null; rm -rf "$TEMP_DIR"' EXIT

log_info "Cloning yay-bin from AUR..."
cd "$TEMP_DIR" || exit
git clone https://aur.archlinux.org/yay-bin.git >/dev/null 2>&1
cd yay-bin || exit

log_info "Building yay..."
makepkg -s --noconfirm

log_info "Installing yay..."
PKG_FILE=$(ls -t *.pkg.tar* 2>/dev/null | head -1)
if [[ -n "$PKG_FILE" ]]; then
    sudo pacman -U --noconfirm "$PKG_FILE"
else
    log_error "Failed to find built package file"
    exit 1
fi

cd "$START_DIR" || true

if command -v yay >/dev/null 2>&1; then
    log_success "yay installed successfully"
else
    log_error "yay installation failed"
    exit 1
fi

