#!/usr/bin/env bash
# Install firefox and configure dark theme

log_info "Installing firefox..."

ensure_pacman_pkg firefox

log_info "Configuring Firefox dark theme..."

FIREFOX_PROFILE_DIR="$HOME/.mozilla/firefox"

if [[ -d "$FIREFOX_PROFILE_DIR" ]]; then
    # Find the default profile (usually ends with .default or .default-release)
    PROFILE_DIR=$(find "$FIREFOX_PROFILE_DIR" -maxdepth 1 -type d -name "*.default*" | head -1)
    
    if [[ -n "$PROFILE_DIR" && -d "$PROFILE_DIR" ]]; then
        log_info "Found Firefox profile: $PROFILE_DIR"
        USER_JS="$PROFILE_DIR/user.js"
        
        if [[ -f "$USER_JS" ]]; then
            if grep -q "ui.systemUsesDarkTheme" "$USER_JS" 2>/dev/null; then
                log_info "Firefox dark theme preference already configured"
            else
                cat "$UMBRARCH_CONFIG/firefox/user.js" >> "$USER_JS"
                log_success "Added Firefox dark theme configuration to existing user.js"
            fi
        else
            deploy_config "$UMBRARCH_CONFIG/firefox/user.js" "$USER_JS"
            log_success "Deployed Firefox dark theme configuration"
        fi
    else
        log_info "Firefox profile not found, creating default profile structure..."
        DEFAULT_PROFILE_DIR="$FIREFOX_PROFILE_DIR/default"
        ensure_dir "$DEFAULT_PROFILE_DIR"
        deploy_config "$UMBRARCH_CONFIG/firefox/user.js" "$DEFAULT_PROFILE_DIR/user.js"
        log_success "Created default Firefox profile with dark theme configuration"
        log_info "Firefox will use this profile when first launched"
    fi
else
    log_info "Firefox profile directory not found, creating default profile structure..."
    ensure_dir "$FIREFOX_PROFILE_DIR"
    DEFAULT_PROFILE_DIR="$FIREFOX_PROFILE_DIR/default"
    ensure_dir "$DEFAULT_PROFILE_DIR"
    deploy_config "$UMBRARCH_CONFIG/firefox/user.js" "$DEFAULT_PROFILE_DIR/user.js"
    log_success "Created default Firefox profile with dark theme configuration"
    log_info "Firefox will use this profile when first launched"
fi

log_success "firefox installed and configured"

