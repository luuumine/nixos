pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import ".."

Rectangle {
  id: delegateRoot
  required property var modelData
  required property bool isCurrentItem

  height: 30
  width: delegateRoot.ListView.view.width
  color: isCurrentItem ? Theme.colSurface1 : Theme.colSurface0
  radius: 4

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: Theme.spacing
    anchors.rightMargin: Theme.spacing
    spacing: Theme.spacing

    Image {
      Layout.preferredWidth: 24
      Layout.preferredHeight: 24
      Layout.alignment: Qt.AlignCenter
      source: delegateRoot.modelData.icon ? "image://icon/"
                                            + delegateRoot.modelData.icon : ""
      sourceSize: Qt.size(24, 24)
      fillMode: Image.PreserveAspectFit
    }

    Text {
      text: delegateRoot.modelData.name
      color: Theme.text
      font: Theme.mainFont
    }

    Text {
      text: delegateRoot.modelData.genericName ? "("
                                                 + delegateRoot.modelData.genericName
                                                 + ")" : ""
      color: Theme.colSubtext0
      font: Theme.mainFont
      Layout.fillWidth: true
      elide: Text.ElideRight
    }
  }
}
