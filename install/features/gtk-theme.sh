#!/usr/bin/env bash
# Configure GTK theme to dark

log_info "Configuring GTK theme..."

if ! command -v dconf >/dev/null 2>&1; then
    log_error "dconf is not available"
    log_error "GTK theme configuration requires dconf"
    return 1
fi

log_info "Setting GTK theme to Adwaita-dark..."
if dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'" 2>/dev/null; then
    log_success "GTK theme set to Adwaita-dark"
else
    log_error "Failed to set GTK theme via dconf"
    return 1
fi

log_info "Setting color scheme to prefer-dark..."
if dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'" 2>/dev/null; then
    log_success "Color scheme set to prefer-dark"
else
    log_info "color-scheme key not available (may not be supported on this system)"
fi

VERIFY_THEME=$(dconf read /org/gnome/desktop/interface/gtk-theme 2>/dev/null || echo "")
if [[ "$VERIFY_THEME" == "'Adwaita-dark'" ]]; then
    log_success "Verified: GTK theme is set to Adwaita-dark"
else
    log_warn "Verification failed: GTK theme is $VERIFY_THEME (expected 'Adwaita-dark')"
fi

log_success "GTK theme configuration complete"

