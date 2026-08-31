#!/usr/bin/env bash

set -euo pipefail

readonly PLUGIN_ID=plebdev.theme-rotator
PROJECT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly PROJECT_DIR
readonly OMARCHY_CONFIG_HOME="$HOME/.config"
readonly CONFIG_HOME=${XDG_CONFIG_HOME:-"$OMARCHY_CONFIG_HOME"}
readonly BIN_HOME=${XDG_BIN_HOME:-"$HOME/.local/bin"}
readonly PLUGIN_DIR="$OMARCHY_CONFIG_HOME/omarchy/plugins/$PLUGIN_ID"
readonly CONFIG_FILE="$CONFIG_HOME/omarchy/theme-rotator.conf"
readonly LEGACY_SERVICE="$OMARCHY_CONFIG_HOME/systemd/user/omarchy-theme-rotator.service"

usage() {
  cat <<EOF
Usage: ./install.sh [install|uninstall]

  install     Install or upgrade the plugin (default)
  uninstall   Remove runtime files while preserving config and state
EOF
}

require_command() {
  command -v "$1" >/dev/null || {
    printf 'Theme Rotator requires %s, but it was not found on PATH.\n' "$1" >&2
    exit 1
  }
}

validate_target() {
  [[ $PLUGIN_DIR == "$OMARCHY_CONFIG_HOME/omarchy/plugins/$PLUGIN_ID" ]]
  [[ $PLUGIN_DIR != / && $PLUGIN_DIR != "$HOME" && $PLUGIN_DIR != "$OMARCHY_CONFIG_HOME" ]]
}

disable_legacy_service() {
  if [[ -e $LEGACY_SERVICE ]]; then
    if ! systemctl --user disable --now omarchy-theme-rotator.service >/dev/null 2>&1; then
      printf 'Could not stop the legacy Theme Rotator service; installation aborted.\n' >&2
      exit 1
    fi
    mv -- "$LEGACY_SERVICE" "$LEGACY_SERVICE.legacy-disabled"
    systemctl --user daemon-reload >/dev/null 2>&1 || true
  fi
}

install_plugin() {
  require_command jq
  require_command omarchy
  require_command flock
  omarchy plugin validate "$PROJECT_DIR"
  validate_target
  disable_legacy_service

  mkdir -p "$OMARCHY_CONFIG_HOME/omarchy/plugins" "$CONFIG_HOME/omarchy" "$BIN_HOME"
  if [[ $PROJECT_DIR != "$PLUGIN_DIR" ]]; then
    local staging="$OMARCHY_CONFIG_HOME/omarchy/plugins/.theme-rotator.install.$$"
    rm -rf -- "$staging"
    mkdir -p "$staging"
    cp -a -- "$PROJECT_DIR/." "$staging/"
    rm -rf -- "$PLUGIN_DIR"
    mv -- "$staging" "$PLUGIN_DIR"
  fi

  install -m 0755 "$PROJECT_DIR/bin/omarchy-theme-rotator" "$BIN_HOME/omarchy-theme-rotator"
  if [[ ! -e $CONFIG_FILE ]]; then
    install -m 0644 "$PROJECT_DIR/theme-rotator.conf.example" "$CONFIG_FILE"
  fi

  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
  omarchy plugin enable "$PLUGIN_ID" --section right >/dev/null

  printf 'Installed Theme Rotator 2.0.0.\n'
  printf 'Configuration: %s\n' "$CONFIG_FILE"
}

uninstall_plugin() {
  validate_target
  if [[ $PROJECT_DIR == "$PLUGIN_DIR" ]]; then
    printf 'Refusing to remove the repository while running from its installed path.\n' >&2
    printf 'Use: omarchy plugin remove %s\n' "$PLUGIN_ID" >&2
    exit 1
  fi
  omarchy plugin disable "$PLUGIN_ID" >/dev/null 2>&1 || true
  rm -rf -- "$PLUGIN_DIR"
  rm -f -- "$BIN_HOME/omarchy-theme-rotator"
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
  printf 'Uninstalled Theme Rotator; configuration and state were preserved.\n'
}

case ${1:-install} in
  install) install_plugin ;;
  uninstall) uninstall_plugin ;;
  help | -h | --help) usage ;;
  *) printf 'Unknown action: %s\n' "$1" >&2; usage >&2; exit 2 ;;
esac
