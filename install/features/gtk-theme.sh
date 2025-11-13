#!/usr/bin/env bash
# Configure GTK theme to dark

log_info "Configuring GTK theme..."

if ! command -v gsettings >/dev/null 2>&1; then
    log_error "gsettings is not available (GNOME settings daemon may not be running)"
    log_error "GTK theme configuration requires gsettings"
    return 1
fi

log_info "Setting GTK theme to Adwaita-dark..."
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

CURRENT_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "")
if [[ "$CURRENT_THEME" == "'Adwaita-dark'" ]]; then
    log_success "GTK theme set to Adwaita-dark"
else
    log_warn "GTK theme may not have been set correctly (current: $CURRENT_THEME)"
fi

log_info "Setting color scheme to prefer-dark..."
if gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null; then
    log_success "Color scheme set to prefer-dark"
else
    log_info "color-scheme schema not available (may not be supported on this system)"
fi

log_success "GTK theme configuration complete"

