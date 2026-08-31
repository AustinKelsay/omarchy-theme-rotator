function parseStatus(json) {
  var statusPayload = JSON.parse(json)
  if (statusPayload.schemaVersion !== 1) throw new Error("unsupported schema version")
  return {
    paused: statusPayload.paused === true,
    theme: String(statusPayload.theme || "Unknown"),
    intervalSeconds: Number(statusPayload.intervalSeconds || 300),
    remainingSeconds: Number(statusPayload.remainingSeconds || 0),
    mode: String(statusPayload.mode || "random"),
    source: String(statusPayload.source || "all")
  }
}

function formatRemaining(seconds) {
  var safeSeconds = Math.max(0, Number(seconds) || 0)
  var minutes = Math.floor(safeSeconds / 60)
  var secs = safeSeconds % 60
  return minutes + ":" + (secs < 10 ? "0" : "") + secs
}

function actionForButton(button, leftButton, rightButton) {
  if (button === leftButton) return "next"
  if (button === rightButton) return "toggle"
  return ""
}

if (typeof module !== "undefined") {
  module.exports = { parseStatus: parseStatus, formatRemaining: formatRemaining, actionForButton: actionForButton }
}
