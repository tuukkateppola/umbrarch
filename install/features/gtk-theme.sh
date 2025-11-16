#!/usr/bin/env bash
# Configure GTK theme

log_info "Configuring GTK theme..."

# Ensure required packages are installed
log_info "Installing GTK dependencies..."
ensure_pacman_pkg gnome-themes-extra
ensure_pacman_pkg adwaita-icon-theme
ensure_pacman_pkg papirus-icon-theme
ensure_pacman_pkg xdg-desktop-portal
ensure_pacman_pkg xdg-desktop-portal-wlr
ensure_pacman_pkg xdg-desktop-portal-gtk

log_info "Deploying GTK3 configuration..."
deploy_config "$UMBRARCH_CONFIG/gtk-3.0/settings.ini" ~/.config/gtk-3.0/settings.ini

log_info "Deploying GTK4 configuration..."
deploy_config "$UMBRARCH_CONFIG/gtk-4.0/settings.ini" ~/.config/gtk-4.0/settings.ini

log_info "Configuring xdg-desktop-portal..."
deploy_config "$UMBRARCH_CONFIG/xdg-desktop-portal/portals.conf" ~/.config/xdg-desktop-portal/portals.conf

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

log_info "Configuring Flatpak applications..."
if command -v flatpak >/dev/null 2>&1; then
    flatpak override --user --env=GTK_THEME=Adwaita-dark 2>/dev/null || log_warn "Could not set Flatpak GTK_THEME override"
    flatpak override --user --env=GTK_APPLICATION_PREFER_DARK_THEME=1 2>/dev/null || log_warn "Could not set Flatpak GTK_APPLICATION_PREFER_DARK_THEME override"
    flatpak override --user --env=GTK_USE_PORTAL=1 2>/dev/null || log_warn "Could not set Flatpak GTK_USE_PORTAL override"
    log_success "Flatpak dark theme overrides configured"
else
    log_info "Flatpak not installed, skipping Flatpak overrides"
fi

log_info "Restarting xdg-desktop-portal services..."
killall xdg-desktop-portal xdg-desktop-portal-wlr 2>/dev/null || true

log_success "GTK theme configuration complete"

