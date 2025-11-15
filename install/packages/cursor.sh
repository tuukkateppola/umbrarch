#!/usr/bin/env bash
# Install cursor and deploy configuration

log_info "Installing cursor..."

ensure_yay_pkg cursor-bin

log_info "Deploying Cursor configuration..."
deploy_config "$UMBRARCH_CONFIG/Cursor/User/settings.json" ~/.config/Cursor/User/settings.json
deploy_config "$UMBRARCH_CONFIG/Cursor/User/keybindings.json" ~/.config/Cursor/User/keybindings.json
deploy_config "$UMBRARCH_CONFIG/Cursor/electron34-flags.conf" ~/.config/electron34-flags.conf

log_info "Deploying Cursor desktop file override..."
ensure_dir ~/.local/share/applications
if [[ -f "$UMBRARCH_PATH/applications/cursor.desktop" ]]; then
    deploy_config "$UMBRARCH_PATH/applications/cursor.desktop" ~/.local/share/applications/cursor.desktop
    log_success "Cursor desktop file override deployed"
else
    log_warn "Cursor desktop file override not found, skipping"
fi

# Configure nautilus as default file manager for xdg-open (needed for Cursor to open directories)
log_info "Configuring nautilus as default file manager..."
if ! command -v nautilus >/dev/null 2>&1; then
    log_error "nautilus is not installed"
    log_error "nautilus is required for Cursor to open directories"
    return 1
fi

xdg-mime default org.gnome.Nautilus.desktop inode/directory 2>/dev/null || true
xdg-mime default org.gnome.Nautilus.desktop application/x-directory 2>/dev/null || true
log_success "Nautilus configured as default file manager"

log_success "cursor installed and configured"

