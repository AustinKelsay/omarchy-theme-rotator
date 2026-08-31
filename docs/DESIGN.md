# Design

The CLI is the system's deep module. Callers provide one command and learn one
JSON status shape; configuration parsing, normalization, eligibility,
selection, locking, schedule accounting, persistence, and Omarchy process
interaction remain behind that interface.

There are three public seams:

1. `bin/omarchy-theme-rotator` for rotation behavior.
2. `install.sh` for installation lifecycle behavior.
3. `Status.js`, the widget contract module whose interface parses versioned
   status JSON, formats schedule state, and maps mouse buttons to CLI actions.

The third seam is deliberately a plain JavaScript module: QML rendering remains
an implementation detail, while the user-visible status and control contract is
executable in both Omarchy Shell and the test suite.

Omarchy and the local filesystem are local-substitutable dependencies. Tests
exercise the real CLI with temporary XDG directories and executable `omarchy`,
`notify-send`, and clock adapters on `PATH`. No internal shell function is a
test surface.

`Service.qml` owns no rotation rules. It supplies wake-ups through `tick`; the
CLI decides whether a scheduled rotation is due. This makes missed wake-ups
safe and keeps policy in one place.
