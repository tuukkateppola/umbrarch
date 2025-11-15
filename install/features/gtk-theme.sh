#!/usr/bin/env bash
# Configure GTK theme to dark

log_info "Configuring GTK theme..."

log_info "Deploying GTK3 configuration..."
deploy_config "$UMBRARCH_CONFIG/gtk-3.0/settings.ini" ~/.config/gtk-3.0/settings.ini

log_info "Deploying GTK4 configuration..."
deploy_config "$UMBRARCH_CONFIG/gtk-4.0/settings.ini" ~/.config/gtk-4.0/settings.ini

log_success "GTK theme configuration complete"

