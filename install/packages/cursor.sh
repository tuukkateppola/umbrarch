#!/usr/bin/env bash
# Install cursor and deploy configuration

log_info "Installing cursor..."

ensure_yay_pkg cursor-bin

log_info "Deploying Cursor configuration..."
deploy_config config/Cursor/User/settings.json ~/.config/Cursor/User/settings.json
deploy_config config/Cursor/User/keybindings.json ~/.config/Cursor/User/keybindings.json
deploy_config config/Cursor/electron34-flags.conf ~/.config/electron34-flags.conf

log_success "cursor installed and configured"

