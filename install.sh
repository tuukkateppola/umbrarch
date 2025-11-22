#!/usr/bin/env bash
# UmbrArch main installer orchestrator - executes modular install scripts

set -euo pipefail

# Determine the repository root directory
# When install.sh is sourced, BASH_SOURCE[0] points to install.sh, so dirname gives us the repo root
if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ "${BASH_SOURCE[0]}" != "-" ]]; then
    UMBRARCH_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    echo "[WARN] Could not determine script location, assuming current directory is repo root" >&2
    UMBRARCH_PATH="$(pwd)"
fi


UMBRARCH_INSTALL="$UMBRARCH_PATH/install"
UMBRARCH_CONFIG="$UMBRARCH_PATH/config"
export UMBRARCH_PATH
export UMBRARCH_INSTALL
export UMBRARCH_CONFIG

if [[ ! -f "$UMBRARCH_INSTALL/lib.sh" ]]; then
    echo "[ERROR] install/lib.sh not found at $UMBRARCH_INSTALL/lib.sh. Current directory: $(pwd)" >&2
    echo "[ERROR] Please ensure install.sh is run from the repository root." >&2
    exit 1
fi
source "$UMBRARCH_INSTALL/lib.sh"
init_logs

log_info "=== UmbrArch Installation Started ==="

log_info "Running preflight checks..."
source "$UMBRARCH_INSTALL/preflight.sh"

log_info "Loading installation targets..."
source "$UMBRARCH_INSTALL/targets.sh"

log_info "Ensuring yay AUR helper is available..."
source "$UMBRARCH_INSTALL/yay.sh"

log_info "=== Installing Packages ==="

if [[ -n "${UMBRARCH_SELECTED_PACKAGES:-}" ]]; then
    # Convert space or newline-separated list to array
    readarray -t package_scripts <<<"$UMBRARCH_SELECTED_PACKAGES"
    
    for pkg_script in "${package_scripts[@]}"; do
        # Skip empty entries
        [[ -z "$pkg_script" ]] && continue
        
        pkg_script_path="$UMBRARCH_INSTALL/packages/${pkg_script}.sh"
        
        # Check if custom install script exists
        if [[ -f "$pkg_script_path" ]]; then
            log_info "Installing package: $pkg_script (custom script)"
            source "$pkg_script_path"
            log_success "Package installed: $pkg_script"
        else
            log_info "Installing package: $pkg_script"
            ensure_yay_pkg "$pkg_script"
            log_success "Package installed: $pkg_script"
        fi
    done
else
    log_info "No packages selected for installation"
fi

log_info "=== Applying Features ==="

if [[ -n "${UMBRARCH_SELECTED_FEATURES:-}" ]]; then
    # Convert space or newline-separated list to array
    readarray -t feature_scripts <<<"$UMBRARCH_SELECTED_FEATURES"
    
    for feat_script in "${feature_scripts[@]}"; do
        # Skip empty entries
        [[ -z "$feat_script" ]] && continue
        
        feat_script_path="$UMBRARCH_INSTALL/features/${feat_script}.sh"
        if [[ ! -f "$feat_script_path" ]]; then
            log_error "Feature script not found: $feat_script_path (UMBRARCH_PATH: $UMBRARCH_PATH, current directory: $(pwd))"
            exit 1
        fi
        
        log_info "Applying feature: $feat_script"
        source "$feat_script_path"
        log_success "Feature applied: $feat_script"
    done
else
    log_info "No features selected for installation"
fi

log_success "=== UmbrArch Installation Complete ==="
log_info "Installation log: $UMBRARCH_LOG_FILE"
log_info "Debug log: $UMBRARCH_DEBUG_LOG"

if [[ "${UMBRARCH_IS_ONLINE_INSTALL:-false}" == "true" ]]; then
    log_info "Cleaning up installation files..."
    rm -rf ~/.local/share/umbrarch/
    log_info "Removed temporary installation directory"
    cd ~ || {
        log_error "Failed to change to home directory"
        exit 1
    }
fi

if ask_yesno "Reboot now to apply all changes?" "yes"; then
    log_info "Rebooting system..."
    sudo reboot
else
    log_info "Skipping reboot. You may need to reboot later."
fi

