#!/usr/bin/env bash
# Configure Git identity (user.name and user.email)

log_info "Checking Git configuration..."

CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [[ "${UMBRARCH_DRY_RUN:-false}" == "true" ]]; then
    log_info "[DRY RUN] Would configure Git identity (current: name='$CURRENT_NAME', email='$CURRENT_EMAIL')"
    log_success "Git configuration complete (simulated)"
    return 0
fi

if [[ -n "$CURRENT_NAME" && -n "$CURRENT_EMAIL" ]]; then
    log_info "Git user.name is set to: $CURRENT_NAME"
    log_info "Git user.email is set to: ${CURRENT_EMAIL%%@*}@***"
    
    if ask_yesno "Current Git identity:\n\nName:  $CURRENT_NAME\nEmail: $CURRENT_EMAIL\n\nKeep these settings?" "yes"; then
        log_info "Keeping existing Git configuration"
        log_success "Git configuration complete"
        return 0
    fi
fi

log_info "Configuring Git identity..."

if [[ -z "$CURRENT_NAME" ]]; then
    GIT_NAME=$(ask_input "Git user.name is not set.\n\nEnter your name:" "" "true")
    if [[ -z "$GIT_NAME" ]]; then
        log_error "Git user.name is required"
        return 1
    fi
else
    GIT_NAME=$(ask_input "Enter Git user.name:" "$CURRENT_NAME")
    if [[ -z "$GIT_NAME" ]]; then
        GIT_NAME="$CURRENT_NAME"
    fi
    if [[ "$GIT_NAME" != "$CURRENT_NAME" ]]; then
        log_info "Using provided name: $GIT_NAME"
    else
        log_info "Keeping existing name: $GIT_NAME"
    fi
fi

if [[ -z "$CURRENT_EMAIL" ]]; then
    GIT_EMAIL=$(ask_input "Git user.email is not set.\n\nEnter your email:" "" "true")
    if [[ -z "$GIT_EMAIL" ]]; then
        log_error "Git user.email is required"
        return 1
    fi
else
    GIT_EMAIL=$(ask_input "Enter Git user.email:" "$CURRENT_EMAIL")
    if [[ -z "$GIT_EMAIL" ]]; then
        GIT_EMAIL="$CURRENT_EMAIL"
    fi
    if [[ "$GIT_EMAIL" != "$CURRENT_EMAIL" ]]; then
        log_info "Using provided email"
    else
        log_info "Keeping existing email"
    fi
fi

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

log_success "Git user.name set to: $GIT_NAME"
log_success "Git user.email set to: ${GIT_EMAIL%%@*}@***"

log_success "Git configuration complete"

