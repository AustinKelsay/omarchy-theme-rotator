#!/usr/bin/env bash

# shellcheck source=tests/test_helper.bash
source "$(dirname -- "${BASH_SOURCE[0]}")/test_helper.bash"

install_lifecycle_adapters() {
  cat >"$TEST_ROOT/bin/omarchy" <<'ADAPTER'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-} ${2:-}" in
  "plugin validate") jq -e '.id == "plebdev.theme-rotator"' "$3/manifest.json" >/dev/null ;;
  "plugin enable"|"plugin disable") printf '%s\n' "$*" >>"$TEST_ROOT/omarchy-calls" ;;
  *) exit 64 ;;
esac
ADAPTER
  cat >"$TEST_ROOT/bin/omarchy-shell" <<'ADAPTER'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TEST_ROOT/shell-calls"
ADAPTER
  cat >"$TEST_ROOT/bin/systemctl" <<'ADAPTER'
#!/usr/bin/env bash
[[ ${SYSTEMCTL_FAIL:-false} != true ]] || exit 1
printf '%s\n' "$*" >>"$TEST_ROOT/systemctl-calls"
ADAPTER
  chmod +x "$TEST_ROOT/bin/omarchy" "$TEST_ROOT/bin/omarchy-shell" "$TEST_ROOT/bin/systemctl"
}

test_install_aborts_when_the_legacy_daemon_cannot_stop() {
  setup_test
  install_lifecycle_adapters
  export XDG_BIN_HOME="$HOME/.local/bin"
  mkdir -p "$HOME/.config/systemd/user"
  printf '[Service]\n' >"$HOME/.config/systemd/user/omarchy-theme-rotator.service"

  local exit_code=0
  SYSTEMCTL_FAIL=true "$REPO_ROOT/install.sh" install >/dev/null 2>"$TEST_ROOT/errors" || exit_code=$?
  [[ $exit_code -ne 0 ]]
  [[ -f $HOME/.config/systemd/user/omarchy-theme-rotator.service ]]
  assert_file_absent "$HOME/.config/systemd/user/omarchy-theme-rotator.service.legacy-disabled"
  assert_file_absent "$HOME/.config/omarchy/plugins/plebdev.theme-rotator"
  assert_file_absent "$HOME/.local/bin/omarchy-theme-rotator"
  assert_file_contains "$TEST_ROOT/errors" "Could not stop the legacy Theme Rotator service"
  teardown_test
}

test_install_upgrade_and_uninstall_are_safe_and_idempotent() {
  setup_test
  install_lifecycle_adapters
  export XDG_BIN_HOME="$HOME/.local/bin"
  export XDG_CONFIG_HOME="$HOME/custom-config"
  mkdir -p "$HOME/.config/systemd/user" "$XDG_CONFIG_HOME/omarchy"
  printf 'INTERVAL_SECONDS=42\n' >"$XDG_CONFIG_HOME/omarchy/theme-rotator.conf"
  printf '[Service]\n' >"$HOME/.config/systemd/user/omarchy-theme-rotator.service"

  "$REPO_ROOT/install.sh" install
  "$REPO_ROOT/install.sh" install

  local installed="$HOME/.config/omarchy/plugins/plebdev.theme-rotator"
  [[ -x $HOME/.local/bin/omarchy-theme-rotator ]]
  [[ -f $installed/Service.qml ]]
  assert_eq "INTERVAL_SECONDS=42" "$(cat "$XDG_CONFIG_HOME/omarchy/theme-rotator.conf")"
  [[ -f $HOME/.config/systemd/user/omarchy-theme-rotator.service.legacy-disabled ]]

  "$REPO_ROOT/install.sh" uninstall
  assert_file_absent "$installed"
  assert_file_absent "$HOME/.local/bin/omarchy-theme-rotator"
  [[ -f $XDG_CONFIG_HOME/omarchy/theme-rotator.conf ]]
  teardown_test
}
