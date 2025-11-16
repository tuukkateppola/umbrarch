#!/usr/bin/env bash
# Configure greetd with tuigreet for autologin to niri

log_info "Checking greetd autologin configuration..."

GREETD_CONFIG="/etc/greetd/config.toml"
HAS_AUTOLOGIN=false

if [[ -f "$GREETD_CONFIG" ]]; then
    if grep -q "tuigreet.*--cmd.*niri-session" "$GREETD_CONFIG" 2>/dev/null; then
        HAS_AUTOLOGIN=true
        log_info "greetd autologin configuration detected"
        if ! ask_yesno "greetd autologin is already configured.\n\nRefresh configuration?" "no"; then
            log_info "Keeping existing greetd autologin configuration"
            log_success "greetd autologin configuration skipped"
            return 0
        fi
    else
        log_info "greetd config found but autologin not configured"
    fi
fi

if [[ "$HAS_AUTOLOGIN" == "false" ]]; then
    if ! ask_yesno "Enable greetd autologin with tuigreet (launches niri automatically)?" "yes"; then
        log_info "Autologin declined by user"
        log_success "greetd autologin configuration skipped"
        return 0
    fi
fi

log_info "Configuring greetd autologin..."

log_info "Installing greetd and tuigreet..."
ensure_pacman_pkg greetd
ensure_pacman_pkg greetd-tuigreet

NIRI_SESSION_WRAPPER="/usr/local/bin/niri-session"
NIRI_SESSION_BINARY="/usr/bin/niri-session"

if [[ ! -f "$NIRI_SESSION_BINARY" ]]; then
    log_warn "niri-session binary not found at $NIRI_SESSION_BINARY"
    log_warn "You may need to install niri first"
fi

if [[ -f "$NIRI_SESSION_WRAPPER" ]]; then
    log_info "niri-session wrapper already exists at $NIRI_SESSION_WRAPPER, skipping"
else
    log_info "Deploying niri-session wrapper..."
    sudo cp "$UMBRARCH_CONFIG/greetd/niri-session" "$NIRI_SESSION_WRAPPER"
    sudo chmod +x "$NIRI_SESSION_WRAPPER"
    log_success "Deployed niri-session wrapper"
fi

log_info "Deploying greetd config..."

# Create temporary config file with USER placeholder replaced
TEMP_CONFIG=$(mktemp)
sed "s/{USER}/$USER/g" "$UMBRARCH_CONFIG/greetd/config.toml.template" > "$TEMP_CONFIG"

if [[ -f "$GREETD_CONFIG" ]]; then
    BACKUP_FILE="${GREETD_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    log_info "Backing up existing greetd config to $BACKUP_FILE"
    sudo cp "$GREETD_CONFIG" "$BACKUP_FILE"
    log_success "Backed up greetd config"
else
    log_info "No existing greetd config found, creating new one"
    sudo mkdir -p "$(dirname "$GREETD_CONFIG")"
fi

sudo cp "$TEMP_CONFIG" "$GREETD_CONFIG"
rm "$TEMP_CONFIG"
log_success "Deployed greetd config"

log_info "Enabling greetd.service..."
if ! sudo systemctl is-enabled greetd.service &>/dev/null; then
    sudo systemctl enable greetd.service
    log_success "greetd.service enabled"
else
    log_info "greetd.service is already enabled"
fi

log_success "greetd autologin configuration complete"
log_info "The system will automatically log in to niri on next boot"

