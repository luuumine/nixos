import QtQuick
import QtQuick.Layouts

import ".."

Rectangle {
  width: Theme.unreadDotSize
  height: Theme.unreadDotSize

  radius: width / 2

  color: GlobalStates.hasUnread ? Theme.primary : "transparent"

  Layout.alignment: Qt.AlignRight
}
