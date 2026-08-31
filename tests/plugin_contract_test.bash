#!/usr/bin/env bash

# shellcheck source=tests/test_helper.bash
source "$(dirname -- "${BASH_SOURCE[0]}")/test_helper.bash"

test_manifest_and_qml_share_the_cli_contract() {
  setup_test
  jq -e '
    .version == "2.0.0"
    and (.kinds | index("service") != null)
    and (.kinds | index("bar-widget") != null)
    and .entryPoints.service == "Service.qml"
    and .entryPoints.barWidget == "BarWidget.qml"
  ' "$REPO_ROOT/manifest.json" >/dev/null
  local status_json
  status_json=$($CLI status)
  node - "$REPO_ROOT/Status.js" "$status_json" <<'JAVASCRIPT'
const status = require(process.argv[2])
const parsed = status.parseStatus(process.argv[3])
if (parsed.theme !== "Ristretto") process.exit(1)
if (parsed.intervalSeconds !== 300) process.exit(1)
if (status.formatRemaining(65) !== "1:05") process.exit(1)
if (status.actionForButton(1, 1, 2) !== "next") process.exit(1)
if (status.actionForButton(2, 1, 2) !== "toggle") process.exit(1)
if (status.actionForButton(4, 1, 2) !== "") process.exit(1)
try {
  status.parseStatus('{"schemaVersion":2}')
  process.exit(1)
} catch (error) {
  if (!String(error).includes("unsupported schema version")) process.exit(1)
}
JAVASCRIPT
  teardown_test
}
