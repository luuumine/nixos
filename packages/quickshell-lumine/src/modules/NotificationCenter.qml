import QtQuick
import QtQuick.Layouts

import ".."
import "../components/" as Components

ColumnLayout {
  id: root
  Layout.fillWidth: true
  spacing: Theme.spacing

  required property var notificationsList

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
      visible: root.notificationsList.count > 0
      color: Theme.colRed
      font: Theme.mainFont
      MouseArea {
        anchors.fill: parent
        onClicked: root.notificationsList.clear()
      }
    }
  }

  ColumnLayout {
    Layout.topMargin: Theme.padding
    Layout.bottomMargin: Theme.padding
    spacing: Theme.spacing
    visible: root.notificationsList.count === 0

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

    model: root.notificationsList

    delegate: Components.NotificationEvent {
      onRemoveRequested: idx => ListView.view.model.remove(idx)
    }
  }
}
