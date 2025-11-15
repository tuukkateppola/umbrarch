#!/usr/bin/env bash
# Install mako and deploy configuration

log_info "Installing mako..."

ensure_pacman_pkg mako

log_info "Deploying mako configuration..."
deploy_config "$UMBRARCH_CONFIG/mako/config" ~/.config/mako/config

log_info "Enabling and starting mako.service..."
if ! systemctl --user is-enabled mako.service &>/dev/null; then
    systemctl --user enable --now mako.service
    log_success "mako.service enabled and started"
else
    log_info "mako.service is already enabled"
    if ! systemctl --user is-active mako.service &>/dev/null; then
        systemctl --user start mako.service
        log_info "mako.service started"
    else
        log_info "mako.service is already active"
    fi
fi

if systemctl --user is-active mako.service &>/dev/null; then
    log_success "mako.service is active"
else
    log_warn "mako.service is not active (may need to reload)"
    systemctl --user status mako.service || true
fi

log_success "mako installed and configured"

