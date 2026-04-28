import QtQuick
import Quickshell

import ".."

PanelWindow {
  id: bar
  required property var targetScreen
  screen: targetScreen

  anchors {
    top: true
    left: true
    right: true
  }

  color: "transparent"

  implicitHeight: Theme.barHeight

  BarLeft {
    anchors.left: parent.left
    anchors.leftMargin: Theme.padding
    anchors.verticalCenter: parent.verticalCenter
  }

  BarCenter {
    anchors.centerIn: parent
  }

  BarRight {
    anchors.right: parent.right
    anchors.rightMargin: Theme.padding
    anchors.verticalCenter: parent.verticalCenter
  }
}
