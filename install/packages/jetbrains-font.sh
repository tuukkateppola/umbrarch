#!/usr/bin/env bash
# Install JetBrains Mono Nerd Font

log_info "Installing JetBrains Mono Nerd Font..."

WAS_INSTALLED=false
if pacman -Q ttf-jetbrains-mono-nerd &>/dev/null; then
    WAS_INSTALLED=true
fi

ensure_yay_pkg ttf-jetbrains-mono-nerd

# Refresh font cache only if package was newly installed
if [[ "$WAS_INSTALLED" == "false" ]]; then
    log_info "Refreshing font cache..."
    run_verbose fc-cache -f
    log_success "Font cache refreshed"
fi

log_success "JetBrains Mono Nerd Font installed"

