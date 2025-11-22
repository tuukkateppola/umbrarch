#!/usr/bin/env bash
# Shared helper library for UmbrArch install scripts.
# Provides logging, user prompts, package installation wrappers, and
# configuration deployment helpers. All functions return 0 on success and
# non-zero on failure so callers can react accordingly.

set -euo pipefail

: "${UMBRARCH_LOG_FILE:="$HOME/.umbrarch-install.log"}"
: "${UMBRARCH_DEBUG_LOG:="$HOME/.umbrarch-install-debug.log"}"

_umbrarch_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

init_logs() {
    # Initialize/truncate log files
    : > "$UMBRARCH_LOG_FILE"
    : > "$UMBRARCH_DEBUG_LOG"
}

_umbrarch_log_append() {
    local level=$1
    shift
    local message="$*"

    local timestamp
    timestamp="$(_umbrarch_timestamp)"
    printf '%s [%s] %s\n' "$timestamp" "$level" "$message" >>"$UMBRARCH_LOG_FILE"
    printf '%s [%s] %s\n' "$timestamp" "$level" "$message" >>"$UMBRARCH_DEBUG_LOG"
}

# Runs a command, redirecting stdout/stderr to the debug log
# Usage: run_verbose command [args...]
run_verbose() {
    if [[ $# -eq 0 ]]; then
        return 0
    fi
    
    echo ">> Running: $*" >>"$UMBRARCH_DEBUG_LOG"
    
    "$@" >>"$UMBRARCH_DEBUG_LOG" 2>&1
    local status=$?
    
    echo ">> Exit code: $status" >>"$UMBRARCH_DEBUG_LOG"
    return "$status"
}

log_info() {
    local message="$*"
    _umbrarch_log_append "INFO" "$message"
    printf '[INFO] %s\n' "$message"
}

log_warn() {
    local message="$*"
    _umbrarch_log_append "WARN" "$message"
    printf '[WARN] %s\n' "$message" >&2
}

log_error() {
    local message="$*"
    _umbrarch_log_append "ERROR" "$message"
    printf '[ERROR] %s\n' "$message" >&2
}

log_success() {
    local message="$*"
    _umbrarch_log_append "SUCCESS" "$message"
    printf '[OK] %s\n' "$message"
}

ask_yesno() {
    local prompt="$1"
    local default="${2:-yes}"
    
    if [[ "$default" == "yes" ]]; then
        dialog --stdout --yesno "$prompt" 0 0 2>/dev/tty
    else
        dialog --stdout --defaultno --yesno "$prompt" 0 0 2>/dev/tty
    fi
}

ask_input() {
    local prompt="$1"
    local default="${2:-}"
    local required="${3:-false}"
    
    local result
    if [[ -n "$default" ]]; then
        result=$(dialog --stdout --inputbox "$prompt" 0 0 "$default" 2>/dev/tty || echo "")
    else
        result=$(dialog --stdout --inputbox "$prompt" 0 0 2>/dev/tty || echo "")
    fi
    
    if [[ -z "$result" && -n "$default" ]]; then
        result="$default"
    fi
    
    if [[ -z "$result" && "$required" == "true" ]]; then
        log_error "Input is required"
        return 1
    fi
    
    echo "$result"
}

ask_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    local dialog_args=("--stdout" "--menu" "$title" "0" "0" "0")
    local i=0
    for option in "${options[@]}"; do
        dialog_args+=("$i" "$option")
        ((i++))
    done
    
    local choice
    choice=$(dialog "${dialog_args[@]}" 2>/dev/tty || echo "")
    
    if [[ -z "$choice" ]]; then
        return 1
    fi
    
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        local index=$choice
        if [[ $index -ge 0 && $index -lt ${#options[@]} ]]; then
            echo "${options[$index]}"
            return 0
        fi
    fi
    
    return 1
}

confirm_or_exit() {
    local prompt="${1:-Are you sure?}"
    
    if ask_yesno "$prompt" "yes"; then
        log_info "User confirmed: $prompt"
        return 0
    else
        log_warn "User declined: $prompt"
        exit 1
    fi
}

ensure_dir() {
    local target=$1

    if [[ -d "$target" ]]; then
        return 0
    fi

    mkdir -p "$target"
    log_info "Created directory: $target"
}

ensure_pacman_pkg() {
    local package=$1

    if pacman -Q "$package" &>/dev/null; then
        log_info "Package already installed: $package"
        return 0
    fi

    log_info "Installing $package via pacman"
    if run_verbose sudo pacman -S --noconfirm --needed "$package"; then
        log_success "Installed $package via pacman"
    else
        log_error "Failed to install $package via pacman. Check $UMBRARCH_DEBUG_LOG for details."
        return 1
    fi
}

ensure_yay_pkg() {
    local package=$1

    if pacman -Q "$package" &>/dev/null; then
        log_info "Package already installed (AUR): $package"
        return 0
    fi

    if ! command -v yay >/dev/null 2>&1; then
        log_error "yay is required but not found in PATH."
        return 1
    fi

    log_info "Installing $package via yay"
    if run_verbose yay -S --noconfirm --needed "$package"; then
        log_success "Installed $package via yay"
    else
        log_error "Failed to install $package via yay. Check $UMBRARCH_DEBUG_LOG for details."
        return 1
    fi
}

deploy_config() {
    local src=$1
    local dst=$2

    if [[ ! -e "$src" ]]; then
        log_error "Source config missing: $src"
        return 1
    fi

    if [[ -d "$src" ]]; then
        ensure_dir "$dst"

        if command -v rsync >/dev/null 2>&1; then
            run_verbose rsync -a --delete "$src"/ "$dst"/
        else
            run_verbose cp -a "$src"/. "$dst"/
        fi

        log_success "Synced directory: $src -> $dst"
        return 0
    fi

    ensure_dir "$(dirname "$dst")"

    if [[ -e "$dst" ]]; then
        if cmp -s "$src" "$dst"; then
            log_info "Config already up to date: $dst"
            return 0
        fi

        local backup
        backup="${dst}.backup.$(date +%Y%m%d_%H%M%S)"
        run_verbose cp -p "$dst" "$backup"
        log_warn "Existing config backed up to $backup"
    fi

    run_verbose cp -p "$src" "$dst"
    log_success "Deployed config: $src -> $dst"
}

ensure_service() {
    local service=$1
    local scope=${2:-system}

    local ctl_cmd="systemctl"
    local sudo_cmd="sudo"
    local flags=""

    if [[ "$scope" == "user" ]]; then
        ctl_cmd="systemctl --user"
        sudo_cmd=""
        flags="--user"
    fi

    log_info "Ensuring service is active: $service ($scope)"

    if ! $ctl_cmd is-enabled "$service" &>/dev/null; then
        run_verbose $sudo_cmd systemctl $flags enable "$service"
        log_success "Enabled $service"
    else
        log_info "$service is already enabled"
    fi

    if ! $ctl_cmd is-active --quiet "$service" 2>/dev/null; then
        run_verbose $sudo_cmd systemctl $flags start "$service"
        log_success "Started $service"
    else
        log_info "$service is already started"
    fi
}

run_step() {
    local label=$1
    local script=$2

    if [[ ! -f "$script" ]]; then
        log_error "Step script not found: $script"
        return 1
    fi

    log_info "Starting step: $label"
    if bash "$script"; then
        log_success "Completed step: $label"
    else
        local status=$?
        log_error "Step failed: $label (exit code $status)"
        return "$status"
    fi
}

