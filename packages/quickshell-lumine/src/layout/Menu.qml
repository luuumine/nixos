import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import ".."
import "../modules" as Modules

PanelWindow {
  id: menu
  property var notificationsList

  anchors {
    top: true
    right: true
  }
  margins {
    top: Theme.spacing
    right: Theme.spacing
  }

  implicitWidth: Theme.menuWidth
  implicitHeight: container.implicitHeight + 2 * Theme.spacing

  visible: GlobalStates.menuVisible
  color: "transparent"

  WlrLayershell.layer: WlrLayer.Top

  Rectangle {
    id: container
    anchors.fill: parent
    color: Theme.colSurface1
    radius: Theme.radius

    implicitHeight: column.implicitHeight + 2 * (Theme.spacing)

    ColumnLayout {
      id: column

      anchors.fill: parent
      anchors.margins: Theme.spacing
      spacing: Theme.spacing

      Modules.CalendarWidget {}

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Theme.colOverlay0
      }

      Modules.NotificationCenter {
        notificationsList: menu.notificationsList
      }
    }
  }
}
