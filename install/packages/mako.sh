#!/usr/bin/env bash
# Install mako and deploy configuration

log_info "Installing mako..."

ensure_pacman_pkg mako
# Note: For sending test notifications, you can use:
# - dbus-send (built-in, see test-notifications.sh for examples)
# - fyi package: pacman -S fyi (notify-send alternative)
# libnotify provides the library but not the notify-send command

log_info "Deploying mako configuration..."
deploy_config "$UMBRARCH_CONFIG/mako/config" ~/.config/mako/config

log_info "Mako will be auto-started by niri compositor (configured in niri config.kdl)"

log_success "mako installed and configured"

