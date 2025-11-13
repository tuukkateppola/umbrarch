#!/usr/bin/env bash
# Install niri compositor and deploy configuration

log_info "Installing niri compositor..."

ensure_pacman_pkg niri

log_info "Deploying niri configuration..."
deploy_config config/niri/config.kdl ~/.config/niri/config.kdl

log_success "niri compositor installed and configured"

