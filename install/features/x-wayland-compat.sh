#!/usr/bin/env bash
# Install X/Wayland compatibility packages

log_info "Installing X/Wayland compatibility packages..."

ensure_pacman_pkg xdg-desktop-portal
ensure_pacman_pkg xdg-desktop-portal-gtk
ensure_pacman_pkg xwayland-satellite

log_info "Checking portal services status..."
if systemctl --user is-active --quiet xdg-desktop-portal.service 2>/dev/null; then
    log_success "xdg-desktop-portal.service is active"
else
    log_info "xdg-desktop-portal.service is not active"
    log_info "Portal services should start automatically when needed"
    log_info "If screen sharing doesn't work, try: systemctl --user start xdg-desktop-portal.service"
fi

log_success "X/Wayland compatibility packages installed"

