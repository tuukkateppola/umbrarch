#!/usr/bin/env bash
# Install swaybg and ensure wallpaper directory exists

log_info "Installing swaybg..."

ensure_pacman_pkg swaybg

log_info "Ensuring wallpaper directory exists..."
ensure_dir ~/Pictures/Wallpapers

WALLPAPER_FILE="$HOME/Pictures/Wallpapers/default.jpg"
WALLPAPER_URL="https://w.wallhaven.cc/full/yq/wallhaven-yqxzol.jpg"

if [[ ! -f "$WALLPAPER_FILE" ]]; then
    log_info "Downloading default wallpaper..."
    if run_verbose curl -L -o "$WALLPAPER_FILE" "$WALLPAPER_URL"; then
        log_success "Downloaded default wallpaper to $WALLPAPER_FILE"
    else
        log_error "Failed to download default wallpaper"
    fi
else
    log_info "Default wallpaper already exists at $WALLPAPER_FILE"
fi

log_success "swaybg installed and wallpaper configured"
log_info "You can add more wallpapers to ~/Pictures/Wallpapers/"
log_info "Use Mod+Shift+S in niri to switch to a random wallpaper from that folder"

