import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

import ".."

Rectangle {
  id: root

  required property int index
  required property string summary
  required property string body
  required property string appName
  required property string time
  required property int urgency

  signal removeRequested(int idx)

  width: parent ? parent.width : 0
  height: layout.implicitHeight + (Theme.spacing * 2)

  radius: Theme.radius
  color: Theme.colSurface0

  border.width: 1
  border.color: root.urgency === NotificationUrgency.Critical ? Theme.colRed :
                                                                Theme.secondary

  ColumnLayout {
    id: layout

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: Theme.spacing
    spacing: Theme.spacing / 2

    RowLayout {
      Layout.fillWidth: true

      Text {
        text: root.summary
        color: Theme.colText
        font {
          family: Theme.fontFamilyMain
          pixelSize: Theme.fontSizeMedium
          bold: true
        }
        Layout.fillWidth: true
        elide: Text.ElideRight
      }

      Text {
        text: root.time
        color: Theme.colSubtext0
        font {
          family: Theme.fontFamilyMain
          pixelSize: Theme.fontSizeSmall
        }
      }

      Text {
        text: "✕"
        color: Theme.colRed
        font {
          family: Theme.fontFamilyMain
          pixelSize: Theme.fontSizeMedium
          bold: true
        }

        MouseArea {
          anchors.fill: parent
          anchors.margins: -5
          onClicked: root.removeRequested(root.index)
        }
      }
    }

    Text {
      text: root.body
      visible: text !== ""
      color: Theme.colSubtext0
      font {
        family: Theme.fontFamilyMain
        pixelSize: Theme.fontSizeSmall
      }
      Layout.fillWidth: true
      elide: Text.ElideRight
      maximumLineCount: 1
    }

    Text {
      text: root.appName
      visible: text !== ""
      color: Theme.colOverlay1
      font {
        family: Theme.fontFamilyMain
        pixelSize: Theme.fontSizeSmall
      }
      Layout.fillWidth: true
    }
  }
}
