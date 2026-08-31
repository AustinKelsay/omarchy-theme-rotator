# Theme Rotator 2.0 specification

## Installation

- The repository must validate as an Omarchy shell plugin.
- `omarchy plugin add <url> --enable` must install everything required for
  automatic rotation; no root access or system service is required.
- An optional installer must support idempotent install, upgrade, and uninstall.
- Existing configuration must be preserved during upgrades and uninstall.
- The installer must migrate away from the legacy systemd user daemon safely.

## Rotation

- Scheduled rotation occurs only when the configured interval has elapsed.
- Pausing suppresses scheduled rotation but not an explicit manual rotation.
- Random mode chooses an eligible theme without repeating the active theme.
- Sequential mode follows Omarchy's returned order and wraps at the end.
- Excluded themes are compared as normalized slugs.
- Failed rotations must not advance the schedule.
- Concurrent rotation attempts must collapse to one operation.

## Interface

- The CLI exposes `status`, `tick`, `next`, `pause`, `resume`, `toggle`,
  `config`, and `help` commands.
- `status` emits a stable JSON document for the widget and other callers.
- `config` prints the effective validated configuration.
- Invalid configuration falls back to safe defaults and reports warnings.
- Commands return non-zero with actionable errors when dependencies fail.

## Shell experience

- The plugin contains a native background service and bar widget.
- The widget communicates only through the CLI JSON contract.
- The widget shows current theme, schedule state, mode, source, and interval.
- Left click rotates now; right click toggles paused state.

## Quality

- Behavioral tests cover the CLI, lifecycle installer, and widget contract seams.
- CI validates shell syntax, ShellCheck, plugin metadata, tests, and docs hygiene.
- The repository documents its domain language, design, contribution workflow,
  security posture, and release process.

