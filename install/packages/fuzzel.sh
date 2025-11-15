#!/usr/bin/env bash
# Install fuzzel and deploy configuration

log_info "Installing fuzzel..."

ensure_pacman_pkg fuzzel

log_info "Deploying fuzzel configuration..."
deploy_config "$UMBRARCH_CONFIG/fuzzel/fuzzel.ini" ~/.config/fuzzel/fuzzel.ini

log_info "Deploying .desktop overrides..."
ensure_dir ~/.local/share/applications

if [[ -d "$UMBRARCH_PATH/applications" ]]; then
    for desktop_file in "$UMBRARCH_PATH/applications"/*.desktop; do
        if [[ -f "$desktop_file" ]]; then
            filename=$(basename "$desktop_file")
            deploy_config "$desktop_file" ~/.local/share/applications/"$filename"
            log_info "Deployed desktop override: $filename"
        fi
    done
else
    log_warn "applications/ directory not found, skipping .desktop overrides"
fi

log_success "fuzzel installed and configured"

