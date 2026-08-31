#!/usr/bin/env bash

# shellcheck source=tests/test_helper.bash
source "$(dirname -- "${BASH_SOURCE[0]}")/test_helper.bash"

test_status_exposes_the_widget_contract() {
  setup_test
  local output
  output=$($CLI status)
  assert_eq "Ristretto" "$(jq -r .theme <<<"$output")"
  assert_eq "false" "$(jq -r .paused <<<"$output")"
  assert_eq "300" "$(jq -r .intervalSeconds <<<"$output")"
  assert_eq "random" "$(jq -r .mode <<<"$output")"
  assert_eq "all" "$(jq -r .source <<<"$output")"
  teardown_test
}

test_tick_waits_until_the_schedule_is_due() {
  setup_test
  write_config <<'CONFIG'
MODE="sequential"
CONFIG
  mkdir -p "$XDG_STATE_HOME/omarchy-theme-rotator"
  printf '900\n' >"$XDG_STATE_HOME/omarchy-theme-rotator/last-rotation"
  $CLI tick
  assert_file_absent "$TEST_ROOT/rotations"
  THEME_ROTATOR_NOW=1200 $CLI tick
  assert_file_contains "$TEST_ROOT/rotations" "Tokyo Night"
  teardown_test
}

test_pause_blocks_tick_but_manual_rotation_still_works() {
  setup_test
  write_config <<'CONFIG'
MODE="sequential"
CONFIG
  $CLI pause
  $CLI tick
  assert_file_absent "$TEST_ROOT/rotations"
  $CLI next
  assert_file_contains "$TEST_ROOT/rotations" "Tokyo Night"
  teardown_test
}

test_sequential_rotation_wraps_and_honors_exclusions() {
  setup_test
  printf 'Catppuccin\n' >"$TEST_ROOT/current-theme"
  write_config <<'CONFIG'
MODE="sequential"
EXCLUDE_THEMES=("red-pill")
CONFIG
  $CLI next
  assert_eq "Ristretto" "$(cat "$TEST_ROOT/current-theme")"
  teardown_test
}

test_failed_rotation_does_not_advance_the_schedule() {
  setup_test
  mkdir -p "$XDG_STATE_HOME/omarchy-theme-rotator"
  printf '500\n' >"$XDG_STATE_HOME/omarchy-theme-rotator/last-rotation"
  local exit_code=0
  OMARCHY_SET_FAIL=true $CLI next >/dev/null 2>&1 || exit_code=$?
  [[ $exit_code -ne 0 ]]
  assert_eq "500" "$(cat "$XDG_STATE_HOME/omarchy-theme-rotator/last-rotation")"
  teardown_test
}

test_theme_source_failure_reports_the_failed_operation() {
  setup_test
  local exit_code=0
  OMARCHY_LIST_FAIL=true $CLI next >/dev/null 2>"$TEST_ROOT/errors" || exit_code=$?
  [[ $exit_code -ne 0 ]]
  assert_file_contains "$TEST_ROOT/errors" "could not list themes from the 'all' source"
  teardown_test
}

test_invalid_config_falls_back_and_warns() {
  setup_test
  write_config <<'CONFIG'
INTERVAL_SECONDS=nope
MODE="chaos"
THEME_SOURCE="internet"
NOTIFY=maybe
CONFIG
  local output errors
  output=$($CLI config 2>"$TEST_ROOT/errors")
  errors=$(cat "$TEST_ROOT/errors")
  assert_eq "300" "$(jq -r .intervalSeconds <<<"$output")"
  assert_eq "random" "$(jq -r .mode <<<"$output")"
  assert_eq "all" "$(jq -r .source <<<"$output")"
  [[ $errors == *"invalid INTERVAL_SECONDS"* ]]
  teardown_test
}

test_resume_restarts_the_schedule() {
  setup_test
  $CLI pause
  THEME_ROTATOR_NOW=1100 $CLI resume
  assert_eq "1100" "$(cat "$XDG_STATE_HOME/omarchy-theme-rotator/last-rotation")"
  assert_file_absent "$XDG_STATE_HOME/omarchy-theme-rotator/paused"
  teardown_test
}

test_help_and_unknown_commands_are_actionable() {
  setup_test
  [[ $($CLI help) == *"Usage:"* ]]
  local exit_code=0
  $CLI wat 2>"$TEST_ROOT/errors" || exit_code=$?
  assert_eq "2" "$exit_code"
  assert_file_contains "$TEST_ROOT/errors" "unknown command"
  teardown_test
}

test_malformed_config_uses_defaults_without_breaking_status() {
  setup_test
  write_config <<'CONFIG'
this is not valid bash (
CONFIG
  local output
  output=$($CLI status 2>"$TEST_ROOT/errors")
  assert_eq "300" "$(jq -r .intervalSeconds <<<"$output")"
  assert_file_contains "$TEST_ROOT/errors" "could not evaluate configuration"
  teardown_test
}

test_failing_or_exiting_config_uses_defaults() {
  setup_test
  write_config <<'CONFIG'
INTERVAL_SECONDS=60
false
CONFIG
  assert_eq "300" "$(jq -r .intervalSeconds < <($CLI config 2>/dev/null))"
  write_config <<'CONFIG'
exit 0
CONFIG
  assert_eq "300" "$(jq -r .intervalSeconds < <($CLI config 2>/dev/null))"
  teardown_test
}

test_concurrent_manual_rotations_collapse_to_one() {
  setup_test
  write_config <<'CONFIG'
MODE="sequential"
CONFIG
  OMARCHY_SET_DELAY=0.2 $CLI next &
  local first_pid=$!
  OMARCHY_SET_DELAY=0.2 $CLI next &
  local second_pid=$!
  wait "$first_pid" "$second_pid"
  assert_eq "1" "$(wc -l <"$TEST_ROOT/rotations")"
  teardown_test
}

test_extras_source_limits_eligible_themes() {
  setup_test
  write_config <<'CONFIG'
MODE="sequential"
THEME_SOURCE="extras"
CONFIG
  $CLI next
  assert_eq "Catppuccin" "$(cat "$TEST_ROOT/current-theme")"
  teardown_test
}

test_status_reports_remaining_schedule_time() {
  setup_test
  mkdir -p "$XDG_STATE_HOME/omarchy-theme-rotator"
  printf '850\n' >"$XDG_STATE_HOME/omarchy-theme-rotator/last-rotation"
  assert_eq "150" "$(jq -r .remainingSeconds < <($CLI status))"
  teardown_test
}
