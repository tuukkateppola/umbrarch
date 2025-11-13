#!/usr/bin/env bash
# Install ghostty and deploy configuration

log_info "Installing ghostty..."

ensure_pacman_pkg ghostty

log_info "Deploying ghostty configuration..."
deploy_config config/ghostty/config ~/.config/ghostty/config

log_success "ghostty installed and configured"

