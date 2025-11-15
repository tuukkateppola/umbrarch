#!/usr/bin/env bash
# Configure GTK theme to dark

log_info "Configuring GTK theme..."

log_info "Deploying GTK3 configuration..."
deploy_config "$UMBRARCH_CONFIG/gtk-3.0/settings.ini" ~/.config/gtk-3.0/settings.ini

log_info "Deploying GTK4 configuration..."
deploy_config "$UMBRARCH_CONFIG/gtk-4.0/settings.ini" ~/.config/gtk-4.0/settings.ini

# Set gsettings for libadwaita apps (GTK4 apps like Nautilus 49+ ignore config files)
log_info "Setting gsettings for dark theme..."
if ! command -v gsettings >/dev/null 2>&1; then
    log_error "gsettings is required for dark theme but not found"
    return 1
fi

gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || {
    log_error "Could not set gtk-theme via gsettings"
    return 1
}
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || {
    log_error "Could not set color-scheme via gsettings"
    return 1
}
log_success "gsettings configured for dark theme"


log_success "GTK theme configuration complete"

