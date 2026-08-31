#!/usr/bin/env bash

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export CLI="$REPO_ROOT/bin/omarchy-theme-rotator"

setup_test() {
  TEST_ROOT=$(mktemp -d)
  export TEST_ROOT
  export HOME="$TEST_ROOT/home"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_STATE_HOME="$HOME/.local/state"
  export XDG_RUNTIME_DIR="$TEST_ROOT/runtime"
  export PATH="$TEST_ROOT/bin:/usr/bin:/bin"
  export THEME_ROTATOR_NOW=1000
  mkdir -p "$HOME" "$XDG_CONFIG_HOME/omarchy" "$XDG_STATE_HOME" "$XDG_RUNTIME_DIR" "$TEST_ROOT/bin"
  printf 'Ristretto\n' >"$TEST_ROOT/current-theme"
  printf 'Ristretto\nTokyo Night\nCatppuccin\nRed Pill\n' >"$TEST_ROOT/themes-all"
  printf 'Catppuccin\nRed Pill\n' >"$TEST_ROOT/themes-extras"
  install_fake_omarchy
}

teardown_test() {
  rm -rf -- "$TEST_ROOT"
}

install_fake_omarchy() {
  cat >"$TEST_ROOT/bin/omarchy" <<'ADAPTER'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-} ${2:-}" in
  "theme current") cat "$TEST_ROOT/current-theme" ;;
  "theme list") [[ ${OMARCHY_LIST_FAIL:-false} != true ]] || exit 8; cat "$TEST_ROOT/themes-all" ;;
  "theme extras") [[ ${OMARCHY_LIST_FAIL:-false} != true ]] || exit 8; cat "$TEST_ROOT/themes-extras" ;;
  "theme set")
    [[ ${OMARCHY_SET_FAIL:-false} != true ]] || exit 9
    [[ -z ${OMARCHY_SET_DELAY:-} ]] || sleep "$OMARCHY_SET_DELAY"
    printf '%s\n' "$3" >"$TEST_ROOT/current-theme"
    printf '%s\n' "$3" >>"$TEST_ROOT/rotations"
    ;;
  *) printf 'unexpected omarchy call: %s\n' "$*" >&2; exit 64 ;;
esac
ADAPTER
  chmod +x "$TEST_ROOT/bin/omarchy"
}

write_config() {
  cat >"$XDG_CONFIG_HOME/omarchy/theme-rotator.conf"
}

assert_eq() {
  local expected=$1 actual=$2 message=${3:-}
  if [[ $actual != "$expected" ]]; then
    printf 'expected: %s\nactual:   %s\n%s\n' "$expected" "$actual" "$message" >&2
    exit 1
  fi
}

assert_file_absent() {
  [[ ! -e $1 ]] || { printf 'expected file to be absent: %s\n' "$1" >&2; exit 1; }
}

assert_file_contains() {
  grep -F -- "$2" "$1" >/dev/null || { printf '%s does not contain: %s\n' "$1" "$2" >&2; exit 1; }
}
