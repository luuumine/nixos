import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import ".."
import "../components" as Components

PanelWindow {
  id: notif
  property var notifications

  anchors {
    top: true
    right: true
  }
  margins {
    top: Theme.spacing
    right: Theme.spacing
  }

  implicitWidth: Theme.popupWidth
  implicitHeight: Math.max(1, column.implicitHeight)
  color: "transparent"

  visible: !GlobalStates.menuVisible

  WlrLayershell.layer: WlrLayer.Overlay

  ColumnLayout {
    id: column
    width: parent.width
    spacing: Theme.spacing

    Repeater {
      model: notif.notifications
      Components.NotificationCard {}
    }
  }
}
