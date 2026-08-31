import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root
  readonly property string helper: Quickshell.env("HOME") + "/.config/omarchy/plugins/plebdev.theme-rotator/bin/omarchy-theme-rotator"

  function tick() {
    if (!tickProcess.running) tickProcess.running = true
  }

  Process {
    id: tickProcess
    command: [root.helper, "tick"]
    onExited: function(exitCode) {
      if (exitCode !== 0) console.warn("Theme Rotator tick failed with exit code", exitCode)
    }
  }

  Timer {
    interval: 5000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.tick()
  }
}

