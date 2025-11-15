#!/usr/bin/env bash
# UmbrArch default installation targets
# Edit this file to customize which packages and features are installed
# Comment out lines (with #) to disable items

# Packages to install
# - If a script exists in install/packages/, it will be sourced
# - Otherwise, the package will be installed directly via yay
export PACKAGES=(
  fontconfig
  jetbrains-font
  niri
  waybar
  swaybg
  swaylock
  ghostty
  fuzzel
  mako
  firefox
  nautilus
  cursor
  github-cli
)

# Features to configure (must have corresponding scripts in install/features/)
export FEATURES=(
  x-wayland-compat
  git-config
  gtk-theme
  vm-support
  autologin-greetd
)

