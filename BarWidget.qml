import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "plebdev.theme-rotator"

  property bool paused: false
  property string currentTheme: "Loading…"
  property int intervalSeconds: 300
  property int remainingSeconds: 0
  property string rotationMode: "random"
  property string themeSource: "all"

  readonly property string helper: Quickshell.env("HOME") + "/.local/bin/omarchy-theme-rotator"
  readonly property string stateLabel: paused ? "Paused" : formatRemaining(remainingSeconds)

  function formatRemaining(seconds) {
    var minutes = Math.floor(seconds / 60)
    var secs = seconds % 60
    return minutes + ":" + (secs < 10 ? "0" : "") + secs
  }

  function refresh() {
    if (!statusProcess.running) statusProcess.running = true
  }

  function runAction(action) {
    Quickshell.execDetached([helper, action])
    actionRefresh.restart()
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: statusProcess
    command: [root.helper, "status"]
    stdout: StdioCollector {
      id: statusOutput
      waitForEnd: true
    }
    onExited: function(exitCode) {
      if (exitCode !== 0) return
      try {
        var value = JSON.parse(String(statusOutput.text || "{}"))
        root.paused = value.paused === true
        root.currentTheme = String(value.theme || "Unknown")
        root.intervalSeconds = Number(value.intervalSeconds || 300)
        root.remainingSeconds = Number(value.remainingSeconds || 0)
        root.rotationMode = String(value.mode || "random")
        root.themeSource = String(value.source || "all")
      } catch (error) {
        console.warn("Theme Rotator status parse failed:", error)
      }
    }
  }

  Process {
    id: restartProcess
    command: ["systemctl", "--user", "restart", "omarchy-theme-rotator.service"]
    onExited: actionRefresh.restart()
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
    interval: 750
    repeat: false
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    slotSize: Style.bar.statusSlot
    tooltipText: "Theme Rotator: " + root.stateLabel
      + "\n" + root.currentTheme
      + "\n" + root.rotationMode + " · " + root.themeSource
      + " · every " + Math.round(root.intervalSeconds / 60) + " min"
      + "\nLeft: next  Right: pause/resume  Middle: reload config"
    iconComponent: Component {
      Text {
        anchors.centerIn: parent
        text: root.paused ? "󰏤" : "󰔛"
        color: root.bar ? root.bar.barForeground : Color.foreground
        opacity: root.paused ? 0.45 : 1.0
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.icon
      }
    }
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.runAction("toggle")
      else if (buttonCode === Qt.MiddleButton) {
        if (!restartProcess.running) restartProcess.running = true
      } else root.runAction("next")
    }
  }
}
