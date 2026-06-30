import QtQuick
import QtQuick.Layouts

import ".."
import "../components" as Components
import "../modules" as Modules

RowLayout {
  Modules.Cpu {}
  Components.Separator {}
  Modules.Clock {}
  Components.UnreadDot {}
}
