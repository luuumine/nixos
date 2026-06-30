import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import ".."
import "../components" as Components

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
  implicitHeight: column.implicitHeight + 2 * Theme.spacing

  visible: GlobalStates.menuVisible
  color: "transparent"

  WlrLayershell.layer: WlrLayer.Top

  Rectangle {
    anchors.fill: parent
    radius: Theme.radius
    color: Theme.colSurface1

    ColumnLayout {
      id: column
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: Theme.spacing
      spacing: Theme.spacing

      RowLayout {
        Layout.fillWidth: true

        Text {
          text: "Notifications"
          color: Theme.colText
          font: Theme.titleFont
          Layout.fillWidth: true
        }

        Text {
          text: "Clear all"
          visible: menu.notificationsList.count > 0
          color: Theme.colRed
          font: Theme.mainFont
          MouseArea {
            anchors.fill: parent
            onClicked: menu.notificationsList.clear()
          }
        }
      }

      ColumnLayout {
        Layout.topMargin: Theme.padding
        Layout.bottomMargin: Theme.padding
        spacing: Theme.spacing
        visible: menu.notificationsList.count === 0

        Text {
          text: "🔔"
          color: Theme.dim
          font.pixelSize: Theme.fontSizeTitle + 16
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
        }

        Text {
          text: "No notifications"
          color: Theme.colOverlay1
          font: Theme.mainFont
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
        }
      }

      ListView {
        id: notiflist
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(400, contentHeight)

        clip: true
        spacing: Theme.spacing

        model: menu.notificationsList

        delegate: Components.NotificationEvent {
          onRemoveRequested: idx => ListView.view.model.remove(idx)
        }
      }
    }
  }
}
