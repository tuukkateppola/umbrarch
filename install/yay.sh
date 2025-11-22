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

if [[ "${UMBRARCH_DRY_RUN:-false}" == "true" ]]; then
    log_info "[DRY RUN] Skipping yay build and install"
    # Mock success for dry run
    log_success "[DRY RUN] yay installation simulated"
    return 0
fi

cd "$TEMP_DIR" || exit
run_verbose git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin || exit

log_info "Building yay..."
run_verbose makepkg -s --noconfirm

log_info "Installing yay..."
PKG_FILE=$(ls -t yay-bin-*.pkg.tar* 2>/dev/null | grep -v "debug" | head -1)

if [[ -z "$PKG_FILE" ]]; then
    log_error "Failed to find built package file"
    exit 1
fi

log_info "Installing package: $PKG_FILE"
run_verbose sudo pacman -U --noconfirm "$PKG_FILE"

cd "$START_DIR" || true

if command -v yay >/dev/null 2>&1; then
    log_success "yay installed successfully"
else
    log_error "yay installation failed"
    exit 1
fi

