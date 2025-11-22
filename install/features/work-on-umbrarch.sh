#!/usr/bin/env bash
# Clone umbrarch repository to ~/Work/umbrarch if it doesn't exist

log_info "Checking for umbrarch repository..."

TARGET_DIR="$HOME/Work/umbrarch"

if [[ -d "$TARGET_DIR" ]]; then
    log_info "Directory $TARGET_DIR already exists"
    
    if [[ -d "$TARGET_DIR/.git" ]]; then
        log_info "Git repository already exists at $TARGET_DIR"
        log_success "Repository already cloned"
        return 0
    else
        log_warn "Directory exists but is not a git repository"
        if ask_yesno "Directory $TARGET_DIR exists but is not a git repository.\n\nRemove it and clone fresh?" "no"; then
            log_info "Removing existing directory..."
            run_verbose rm -rf "$TARGET_DIR"
        else
            log_info "Skipping repository clone"
            return 0
        fi
    fi
fi

log_info "Cloning umbrarch repository to $TARGET_DIR..."
ensure_dir "$HOME/Work"

if run_verbose git clone "https://github.com/tuukkateppola/umbrarch.git" "$TARGET_DIR"; then
    log_success "Repository cloned successfully"
else
    log_error "Failed to clone repository"
    return 1
fi

log_success "umbrarch repository cloned to $TARGET_DIR"

