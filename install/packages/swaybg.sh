#!/usr/bin/env bash
# Install swaybg and ensure wallpaper directory exists

log_info "Installing swaybg..."

ensure_pacman_pkg swaybg

log_info "Ensuring wallpaper directory exists..."
ensure_dir ~/Pictures/Wallpapers

WALLPAPER_FILE="$HOME/Pictures/Wallpapers/wallpaper.png"

if [[ ! -f "$WALLPAPER_FILE" ]]; then
    log_warn "Wallpaper file not found: $WALLPAPER_FILE"
    log_warn "Please place your wallpaper image at: $WALLPAPER_FILE"
fi

log_success "swaybg installed and wallpaper directory ready"

