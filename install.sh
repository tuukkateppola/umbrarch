#!/usr/bin/env bash
# UmbrArch main installer orchestrator - executes modular install scripts

set -euo pipefail

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
        
        log_info "Applying feature: $feat_script"
        source "install/features/${feat_script}.sh"
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

