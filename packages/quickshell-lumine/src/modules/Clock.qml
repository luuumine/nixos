import QtQuick
import Quickshell

import ".."

Text {
  id: root

  color: Theme.colText
  font {
    family: Theme.fontFamily
    pixelSize: Theme.fontSize
  }

  text: Qt.formatDateTime(timeSource.date, "dd MMM HH:mm")

  SystemClock {
    id: timeSource
    precision: SystemClock.Minutes
  }
}
