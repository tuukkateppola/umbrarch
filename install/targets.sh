#!/usr/bin/env bash
# Target selector - loads manifest and exports package/feature lists

MANIFEST_FILE="$UMBRARCH_INSTALL/targets/default.sh"

log_info "Loading installation targets from $MANIFEST_FILE"

if [[ ! -f "$MANIFEST_FILE" ]]; then
    log_error "Manifest file not found: $MANIFEST_FILE"
    exit 1
fi

source "$MANIFEST_FILE"

PACKAGE_COUNT=${#PACKAGES[@]}
FEATURE_COUNT=${#FEATURES[@]}

# Convert arrays to newline-separated strings for install.sh
UMBRARCH_SELECTED_PACKAGES=$(printf '%s\n' "${PACKAGES[@]}")
UMBRARCH_SELECTED_FEATURES=$(printf '%s\n' "${FEATURES[@]}")

export UMBRARCH_SELECTED_PACKAGES
export UMBRARCH_SELECTED_FEATURES

log_success "Loaded $PACKAGE_COUNT packages and $FEATURE_COUNT features"

if [[ $PACKAGE_COUNT -gt 0 ]]; then
    log_info "Packages: ${PACKAGES[*]}"
fi

if [[ $FEATURE_COUNT -gt 0 ]]; then
    log_info "Features: ${FEATURES[*]}"
fi

if [[ $PACKAGE_COUNT -eq 0 && $FEATURE_COUNT -eq 0 ]]; then
    log_warn "No packages or features enabled in manifest"
fi

