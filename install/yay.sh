#!/usr/bin/env bash
# Ensure yay AUR helper is installed

log_info "Checking for yay AUR helper..."

if command -v yay >/dev/null 2>&1; then
    log_info "yay is already installed"
    log_success "yay AUR helper available"
    return 0
fi

log_info "yay not found, installing from AUR..."

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

log_info "Cloning yay-bin from AUR..."
cd "$TEMP_DIR" || exit
git clone https://aur.archlinux.org/yay-bin.git >/dev/null 2>&1
cd yay-bin || exit

log_info "Building and installing yay..."
makepkg -si --noconfirm

if command -v yay >/dev/null 2>&1; then
    log_success "yay installed successfully"
else
    log_error "yay installation failed"
    exit 1
fi

