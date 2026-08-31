# Coding standards

- Bash entry points use `set -euo pipefail`; sourced modules do not change the
  caller's shell options.
- Test behavior through the CLI, installer, or `Status.js` widget contract
  module; do not assert on QML source text.
- Keep environment and process dependencies behind the CLI seam and replace
  them with executable adapters in tests.
- Quote expansions unless intentional word splitting is documented.
- Errors go to stderr and include the failed operation.
- JSON output is produced with `jq`, never string interpolation.
- Public command behavior must be documented in `docs/SPEC.md` and README.
- QML processes must reject overlapping invocations and handle non-zero exits.
