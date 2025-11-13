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
    if ! ask_yesno "Enable greetd autologin with tuigreet (launches niri automatically)?" "no"; then
        log_info "Autologin declined by user"
        log_success "greetd autologin configuration skipped"
        return 0
    fi
fi

log_info "Configuring greetd autologin..."

log_info "Installing greetd and tuigreet..."
ensure_pacman_pkg greetd
ensure_pacman_pkg tuigreet

NIRI_SESSION_WRAPPER="/usr/local/bin/niri-session"
NIRI_SESSION_BINARY="/usr/bin/niri-session"

if [[ ! -f "$NIRI_SESSION_BINARY" ]]; then
    log_warn "niri-session binary not found at $NIRI_SESSION_BINARY"
    log_warn "You may need to install niri first"
fi

if [[ ! -f "$NIRI_SESSION_WRAPPER" ]]; then
    log_info "Creating niri-session wrapper at $NIRI_SESSION_WRAPPER..."
    sudo tee "$NIRI_SESSION_WRAPPER" >/dev/null <<'EOF'
#!/bin/sh
exec dbus-run-session /usr/bin/niri
EOF
    sudo chmod +x "$NIRI_SESSION_WRAPPER"
    log_success "Created niri-session wrapper"
else
    log_info "niri-session wrapper already exists at $NIRI_SESSION_WRAPPER"
fi

if [[ -f "$GREETD_CONFIG" ]]; then
    BACKUP_FILE="${GREETD_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    log_info "Backing up existing greetd config to $BACKUP_FILE"
    sudo cp "$GREETD_CONFIG" "$BACKUP_FILE"
    log_success "Backed up greetd config"
else
    log_info "No existing greetd config found, creating new one"
    sudo mkdir -p "$(dirname "$GREETD_CONFIG")"
fi

log_info "Writing greetd config..."
sudo tee "$GREETD_CONFIG" >/dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd niri-session --remember --time"
user = "$USER"
EOF

log_success "greetd config written"

log_info "Checking for other display managers..."
DM_FOUND=()
for dm in gdm sddm lightdm lxdm; do
    if systemctl is-enabled "${dm}.service" &>/dev/null 2>&1; then
        DM_FOUND+=("$dm")
    fi
done

if [[ ${#DM_FOUND[@]} -gt 0 ]]; then
    log_warn "Found enabled display managers: ${DM_FOUND[*]}"
    for dm in "${DM_FOUND[@]}"; do
        if ask_yesno "Disable ${dm}.service?" "yes"; then
            log_info "Disabling ${dm}.service..."
            sudo systemctl disable "${dm}.service" || true
            sudo systemctl stop "${dm}.service" || true
            log_success "Disabled ${dm}.service"
        fi
    done
fi

log_info "Enabling and starting greetd.service..."
if ! sudo systemctl is-enabled greetd.service &>/dev/null; then
    sudo systemctl enable greetd.service
    log_success "greetd.service enabled"
else
    log_info "greetd.service is already enabled"
fi

if ! sudo systemctl is-active --quiet greetd.service 2>/dev/null; then
    sudo systemctl start greetd.service
    log_success "greetd.service started"
else
    log_info "greetd.service is already active"
fi

log_success "greetd autologin configuration complete"
log_info "The system will automatically log in to niri on next boot"

