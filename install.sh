#!/usr/bin/env bash
# UmbrArch main installer orchestrator - executes modular install scripts

set -euo pipefail

# Determine the repository root directory and change to it
# This ensures all relative paths work correctly regardless of where the script is sourced from
# When install.sh is sourced, BASH_SOURCE[0] points to install.sh, so dirname gives us the repo root
if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ "${BASH_SOURCE[0]}" != "-" ]]; then
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$REPO_ROOT" || {
        echo "[ERROR] Failed to change to repository root: $REPO_ROOT" >&2
        exit 1
    }
else
    # If we can't determine the script location, assume we're in the repo root
    # and log a warning
    echo "[WARN] Could not determine script location, assuming current directory is repo root" >&2
fi

# Verify we're in the correct directory by checking for install/lib.sh
if [[ ! -f "install/lib.sh" ]]; then
    echo "[ERROR] install/lib.sh not found. Current directory: $(pwd)" >&2
    echo "[ERROR] Please ensure install.sh is run from the repository root." >&2
    exit 1
fi

source install/lib.sh

log_info "=== UmbrArch Installation Started ==="

log_info "Running preflight checks..."
source install/preflight.sh

log_info "Loading installation targets..."
source install/targets.sh

log_info "Ensuring yay AUR helper is available..."
source install/yay.sh

log_info "=== Installing Packages ==="

if [[ -n "${UMBRARCH_SELECTED_PACKAGES:-}" ]]; then
    # Convert space or newline-separated list to array
    readarray -t package_scripts <<<"$UMBRARCH_SELECTED_PACKAGES"
    
    for pkg_script in "${package_scripts[@]}"; do
        # Skip empty entries
        [[ -z "$pkg_script" ]] && continue
        
        # Check if custom install script exists
        if [[ -f "install/packages/${pkg_script}.sh" ]]; then
            log_info "Installing package: $pkg_script (custom script)"
            source "install/packages/${pkg_script}.sh"
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
        
        feat_script_path="install/features/${feat_script}.sh"
        if [[ ! -f "$feat_script_path" ]]; then
            log_error "Feature script not found: $feat_script_path (current directory: $(pwd))"
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
log_info "Review the installation log at: $UMBRARCH_LOG_FILE"

if [[ "${UMBRARCH_ONLINE_INSTALL:-false}" == "true" ]]; then
    log_info "Cleaning up installation files..."
    rm -rf ~/.local/share/umbrarch/
    log_info "Removed temporary installation directory"
fi

