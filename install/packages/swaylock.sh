#!/usr/bin/env bash
# Install swaylock and deploy configuration

log_info "Installing swaylock..."

ensure_pacman_pkg swaylock

log_info "Deploying swaylock configuration..."
deploy_config config/swaylock ~/.config/swaylock

log_success "swaylock installed and configured"

