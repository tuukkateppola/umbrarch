#!/usr/bin/env bash
# Install firefox and configure dark theme

log_info "Installing firefox..."

ensure_pacman_pkg firefox

log_info "Configuring Firefox dark theme..."

FIREFOX_PROFILE_DIR="$HOME/.mozilla/firefox"

ensure_dir "$FIREFOX_PROFILE_DIR"

if ! find "$FIREFOX_PROFILE_DIR" -maxdepth 1 -type d -name "*.default*" | head -1 >/dev/null 2>&1; then
    log_info "Creating Firefox profile..."
    firefox --headless --createprofile "default $FIREFOX_PROFILE_DIR/default" 2>/dev/null || {
        log_warn "Could not create Firefox profile automatically (Firefox may need to be run once)"
    }
fi

# Find the default profile (usually ends with .default or .default-release)
PROFILE_DIR=$(find "$FIREFOX_PROFILE_DIR" -maxdepth 1 -type d -name "*.default*" | head -1)

if [[ -n "$PROFILE_DIR" && -d "$PROFILE_DIR" ]]; then
    log_info "Using Firefox profile: $PROFILE_DIR"
    USER_JS="$PROFILE_DIR/user.js"
    
    if [[ -f "$USER_JS" ]]; then
        if grep -q "ui.systemUsesDarkTheme" "$USER_JS" 2>/dev/null && \
           grep -q "sidebar.verticalTabs" "$USER_JS" 2>/dev/null; then
            log_info "Firefox preferences already configured"
        else
            cat "$UMBRARCH_CONFIG/firefox/user.js" >> "$USER_JS"
            log_success "Added Firefox configuration to existing user.js"
        fi
    else
        deploy_config "$UMBRARCH_CONFIG/firefox/user.js" "$USER_JS"
        log_success "Deployed Firefox configuration"
    fi
else
    log_error "Could not find or create Firefox profile"
    return 1
fi

log_success "firefox installed and configured"

