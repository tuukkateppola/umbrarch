#!/usr/bin/env bash
# Configure Wayland desktop portals and environment

log_info "Configuring Wayland desktop portals..."

log_info "Installing portal dependencies..."
ensure_pacman_pkg xdg-desktop-portal
ensure_pacman_pkg xdg-desktop-portal-wlr
ensure_pacman_pkg xdg-desktop-portal-gtk
ensure_pacman_pkg pipewire

if [[ "${UMBRARCH_DRY_RUN:-false}" == "true" ]]; then
    log_info "[DRY RUN] Would configure Wayland desktop portals and start services"
    log_success "Wayland desktop portals configuration complete (simulated)"
    return 0
fi

log_info "Configuring xdg-desktop-portal..."
deploy_config "$UMBRARCH_CONFIG/xdg-desktop-portal/portals.conf" ~/.config/xdg-desktop-portal/portals.conf

log_info "Ensuring PipeWire is enabled (required for wlr portal)..."
if systemctl --user is-enabled --quiet pipewire.service 2>/dev/null; then
    log_info "PipeWire service already enabled"
else
    systemctl --user enable --now pipewire.service 2>/dev/null || log_warn "Could not enable PipeWire service"
fi

log_info "Configuring systemd user environment for Wayland..."
deploy_config "$UMBRARCH_CONFIG/systemd/user.conf.d/wayland.conf" ~/.config/systemd/user.conf.d/wayland.conf
if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    systemctl --user set-environment "WAYLAND_DISPLAY=${WAYLAND_DISPLAY}" 2>/dev/null || true
fi
log_success "Systemd user environment configured for Wayland"

log_info "Starting portal services..."
systemctl --user start pipewire.service 2>/dev/null || log_warn "Could not start PipeWire service"

systemctl --user start xdg-desktop-portal-gtk.service 2>/dev/null || log_warn "Could not start xdg-desktop-portal-gtk service"
systemctl --user start xdg-desktop-portal-wlr.service 2>/dev/null || log_warn "Could not start xdg-desktop-portal-wlr service (this is OK if PipeWire isn't available)"

log_info "Restarting xdg-desktop-portal to pick up configuration..."
systemctl --user restart xdg-desktop-portal.service 2>/dev/null || log_warn "Could not restart xdg-desktop-portal service"

log_success "Wayland desktop portals configuration complete"

