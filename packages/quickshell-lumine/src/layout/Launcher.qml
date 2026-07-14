pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland

import ".."
import "../modules"

PanelWindow {
  id: launcherWindow

  visible: GlobalStates.launcherVisible

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  focusable: true

  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.2)
    MouseArea {
      anchors.fill: parent
      onClicked: GlobalStates.launcherVisible = false
    }
  }

  AppLauncher {
    anchors.centerIn: parent
    width: 0.5 * launcherWindow.width
    height: 0.3 * launcherWindow.height
  }
}
