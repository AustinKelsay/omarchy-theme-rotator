#!/bin/bash

set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
bin_home=${XDG_BIN_HOME:-"$HOME/.local/bin"}
plugin_dir="$config_home/omarchy/plugins/plebdev.theme-rotator"
service_dir="$config_home/systemd/user"

command -v omarchy >/dev/null || {
  printf 'Omarchy is required but was not found on PATH.\n' >&2
  exit 1
}

for command_name in jq flock systemctl; do
  command -v "$command_name" >/dev/null || {
    printf 'Required command not found: %s\n' "$command_name" >&2
    exit 1
  }
done

mkdir -p "$plugin_dir" "$bin_home" "$service_dir" "$config_home/omarchy"
install -m 0644 "$project_dir/BarWidget.qml" "$plugin_dir/BarWidget.qml"
install -m 0644 "$project_dir/manifest.json" "$plugin_dir/manifest.json"
install -m 0755 "$project_dir/omarchy-theme-rotator" "$bin_home/omarchy-theme-rotator"
install -m 0644 "$project_dir/omarchy-theme-rotator.service" \
  "$service_dir/omarchy-theme-rotator.service"

if [[ ! -e "$config_home/omarchy/theme-rotator.conf" ]]; then
  install -m 0644 "$project_dir/theme-rotator.conf.example" \
    "$config_home/omarchy/theme-rotator.conf"
fi

systemctl --user daemon-reload
systemctl --user enable --now omarchy-theme-rotator.service

if command -v omarchy-shell >/dev/null; then
  omarchy-shell shell rescanPlugins || true
fi

printf 'Installed Omarchy Theme Rotator.\n'
printf 'Configure it at %s\n' "$config_home/omarchy/theme-rotator.conf"

