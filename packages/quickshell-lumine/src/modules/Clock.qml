import QtQuick
import Quickshell

import ".."

Text {
  id: root

  color: Theme.colText
  font: Theme.mainFont

  text: Qt.formatDateTime(timeSource.date, "dd MMM HH:mm")

  SystemClock {
    id: timeSource
    precision: SystemClock.Minutes
  }

  MouseArea {
    anchors.fill: parent
    onClicked: GlobalStates.menuVisible = !GlobalStates.menuVisible
  }
}
