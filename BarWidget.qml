import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Status.js" as Status

BarWidget {
  id: root
  moduleName: "plebdev.theme-rotator"

  property bool paused: false
  property bool statusAvailable: false
  property string currentTheme: "Loading…"
  property int intervalSeconds: 300
  property int remainingSeconds: 300
  property string rotationMode: "random"
  property string themeSource: "all"

  readonly property string helper: Quickshell.env("HOME") + "/.config/omarchy/plugins/plebdev.theme-rotator/bin/omarchy-theme-rotator"
  readonly property string stateLabel: !statusAvailable ? "Unavailable" : paused ? "Paused" : Status.formatRemaining(remainingSeconds)

  function refresh() {
    if (!statusProcess.running) statusProcess.running = true
  }

  function runAction(action) {
    if (actionProcess.running) return
    actionProcess.command = [root.helper, action]
    actionProcess.running = true
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: statusProcess
    command: [root.helper, "status"]
    stdout: StdioCollector { id: statusOutput; waitForEnd: true }
    onExited: function(exitCode) {
      root.statusAvailable = exitCode === 0
      if (exitCode !== 0) return
      try {
        var statusPayload = Status.parseStatus(String(statusOutput.text || "{}"))
        root.paused = statusPayload.paused
        root.currentTheme = statusPayload.theme
        root.intervalSeconds = statusPayload.intervalSeconds
        root.remainingSeconds = statusPayload.remainingSeconds
        root.rotationMode = statusPayload.mode
        root.themeSource = statusPayload.source
      } catch (error) {
        root.statusAvailable = false
        console.warn("Theme Rotator status parse failed:", error)
      }
    }
  }

  Process {
    id: actionProcess
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.statusAvailable = false
        console.warn("Theme Rotator action failed with exit code", exitCode)
      }
      actionRefresh.restart()
    }
  }

  Timer {
    interval: 5000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Timer {
    id: actionRefresh
    interval: 250
    repeat: false
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    slotSize: Style.bar.statusSlot
    tooltipText: "Theme Rotator · " + root.stateLabel
      + "\n" + root.currentTheme
      + "\n" + root.rotationMode + " · " + root.themeSource
      + " · every " + Math.round(root.intervalSeconds / 60) + " min"
      + "\nLeft: rotate now  Right: pause/resume"
    iconComponent: Component {
      Text {
        anchors.centerIn: parent
        text: !root.statusAvailable ? "󰅚" : root.paused ? "󰏤" : "󰔛"
        color: root.bar ? root.bar.barForeground : Color.foreground
        opacity: root.statusAvailable && !root.paused ? 1.0 : 0.5
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.icon
      }
    }
    onPressed: function(buttonCode) {
      var action = Status.actionForButton(buttonCode, Qt.LeftButton, Qt.RightButton)
      if (action !== "") root.runAction(action)
    }
  }
}
