#!/usr/bin/env bash
# Install firefox and configure dark theme

log_info "Installing firefox..."

ensure_pacman_pkg firefox

log_info "Configuring Firefox dark theme..."

FIREFOX_PROFILE_DIR="$HOME/.mozilla/firefox"
PROFILES_INI="$FIREFOX_PROFILE_DIR/profiles.ini"

ensure_dir "$FIREFOX_PROFILE_DIR"

# Find existing profile or create one
PROFILE_DIR=$(find "$FIREFOX_PROFILE_DIR" -maxdepth 1 -type d -name "*.default*" | head -1)

if [[ -z "$PROFILE_DIR" || ! -d "$PROFILE_DIR" ]]; then
    log_info "Creating Firefox profile structure..."
    
    # Generate a random profile prefix (like Firefox does)
    # Format: 8 random lowercase characters + ".default-release"
    PROFILE_PREFIX=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 8)
    PROFILE_NAME="${PROFILE_PREFIX}.default-release"
    PROFILE_DIR="$FIREFOX_PROFILE_DIR/$PROFILE_NAME"
    
    ensure_dir "$PROFILE_DIR"
    
    # Create profiles.ini if it doesn't exist
    if [[ ! -f "$PROFILES_INI" ]]; then
        # Replace {PROFILE_NAME} placeholder in template
        sed "s/{PROFILE_NAME}/$PROFILE_NAME/g" "$UMBRARCH_CONFIG/firefox/profiles.ini.template" > "$PROFILES_INI"
        log_info "Created profiles.ini"
    else
        log_warn "profiles.ini already exists, not updating"
        log_warn "Firefox profile $PROFILE_NAME created but may not be set as default"
    fi
    
    log_success "Created Firefox profile: $PROFILE_NAME"
fi

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

log_success "firefox installed and configured"

