#!/usr/bin/env bash
# Install waybar and deploy configuration

log_info "Installing waybar..."

ensure_pacman_pkg waybar

log_info "Deploying waybar configuration..."
deploy_config "$UMBRARCH_CONFIG/waybar" ~/.config/waybar

log_success "waybar installed and configured"

