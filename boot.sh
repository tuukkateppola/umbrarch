#!/usr/bin/env bash

set -euo pipefail

export UMBRARCH_IS_ONLINE_INSTALL="${UMBRARCH_IS_ONLINE_INSTALL:-false}"

ascii_art=' █    ██  ███▄ ▄███▓ ▄▄▄▄    ██▀███   ▄▄▄       ██▀███   ▄████▄   ██░ ██ 
 ██  ▓██▒▓██▒▀█▀ ██▒▓█████▄ ▓██ ▒ ██▒▒████▄    ▓██ ▒ ██▒▒██▀ ▀█  ▓██░ ██▒
▓██  ▒██░▓██    ▓██░▒██▒ ▄██▓██ ░▄█ ▒▒██  ▀█▄  ▓██ ░▄█ ▒▒▓█    ▄ ▒██▀▀██░
▓▓█  ░██░▒██    ▒██ ▒██░█▀  ▒██▀▀█▄  ░██▄▄▄▄██ ▒██▀▀█▄  ▒▓▓▄ ▄██▒░▓█ ░██ 
▒▒█████▓ ▒██▒   ░██▒░▓█  ▀█▓░██▓ ▒██▒ ▓█   ▓██▒░██▓ ▒██▒▒ ▓███▀ ░░▓█▒░██▓
░▒▓▒ ▒ ▒ ░ ▒░   ░  ░░▒▓███▀▒░ ▒▓ ░▒▓░ ▒▒   ▓▒█░░ ▒▓ ░▒▓░░ ░▒ ▒  ░ ▒ ░░▒░▒
░░▒░ ░ ░ ░  ░      ░▒░▒   ░   ░▒ ░ ▒░  ▒   ▒▒ ░  ░▒ ░ ▒░  ░  ▒    ▒ ░▒░ ░
 ░░░ ░ ░ ░      ░    ░    ░   ░░   ░   ░   ▒     ░░   ░ ░         ░  ░░ ░
   ░            ░    ░         ░           ░  ░   ░     ░ ░       ░  ░  ░
                          ░                             ░                '

clear
echo "$ascii_art"
echo ""
echo "Welcome to UmbrArch installation"
echo ""

if [[ $EUID -eq 0 ]]; then
    echo "[WARN] This script is running as root."
    echo "[WARN] UmbrArch should normally be installed as a regular user."
    echo "[WARN] Sudo will be invoked when necessary for privileged operations."
    echo ""
    read -p "Continue as root anyway? [y/N]: " -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
else
    echo "Refreshing sudo credentials (you may be prompted for your password)..."
    sudo -v
    echo ""
fi

# Determine if running in online mode (curl | bash) or local mode
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ "${BASH_SOURCE[0]}" != "-" ]]; then
    # Check if BASH_SOURCE[0] points to an actual file
    if [[ -f "${BASH_SOURCE[0]}" ]]; then
        script_dirname="$(dirname "${BASH_SOURCE[0]}")"
        # Only set SCRIPT_DIR if dirname returns a non-empty path
        if [[ -n "$script_dirname" ]]; then
            SCRIPT_DIR="$(cd "$script_dirname" && pwd)"
        fi
    fi
fi

if [[ -z "$SCRIPT_DIR" ]] || [[ ! -f "$SCRIPT_DIR/install.sh" ]]; then
    echo "Preparing online installation..."
    sudo pacman -Syu --noconfirm --needed git
    
    UMBRARCH_REPO="${UMBRARCH_REPO:-tuukkateppola/umbrarch}"
    
    echo "Cloning UmbrArch from: https://github.com/${UMBRARCH_REPO}.git"
    rm -rf ~/.local/share/umbrarch/
    git clone "https://github.com/${UMBRARCH_REPO}.git" ~/.local/share/umbrarch >/dev/null
    
    UMBRARCH_REF="${UMBRARCH_REF:-master}"
    if [[ $UMBRARCH_REF != "master" ]]; then
        echo "Using branch: $UMBRARCH_REF"
        cd ~/.local/share/umbrarch
        git fetch origin "${UMBRARCH_REF}" && git checkout "${UMBRARCH_REF}"
        cd - >/dev/null
    fi
    
    echo ""
    echo "Installation starting..."
    UMBRARCH_IS_ONLINE_INSTALL=true
    INSTALL_DIR=~/.local/share/umbrarch
else
    INSTALL_DIR="$SCRIPT_DIR"
fi

cd "$INSTALL_DIR"
source install.sh
