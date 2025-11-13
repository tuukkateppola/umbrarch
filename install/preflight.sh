#!/usr/bin/env bash
# Preflight checks - verify environment before installation

log_info "Starting preflight checks..."

# Verify we're on Arch Linux
if [[ ! -f /etc/os-release ]]; then
    log_error "Cannot detect operating system: /etc/os-release not found"
    exit 1
fi

if ! grep -q '^ID=arch$' /etc/os-release; then
    log_error "This script is designed for Arch Linux only"
    log_error "Detected OS: $(grep '^ID=' /etc/os-release || echo 'unknown')"
    exit 1
fi

log_success "Arch Linux detected"

log_info "Updating system packages..."
sudo pacman -Syu --noconfirm
log_success "System packages updated"

log_info "Installing prerequisites..."
ensure_pacman_pkg base-devel
ensure_pacman_pkg git
ensure_pacman_pkg dialog
log_success "Prerequisites installed"

log_success "Preflight checks complete"

