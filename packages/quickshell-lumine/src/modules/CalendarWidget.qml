pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import ".."

ColumnLayout {
  id: root
  Layout.fillWidth: true
  spacing: Theme.spacing

  property date today: new Date()

  readonly property int year: today.getFullYear()
  readonly property int month: today.getMonth()

  readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()

  readonly property int firstDay: (new Date(year, month, 1).getDay()
                                   - GlobalStates.weekStart + 7) % 7

  readonly property int weeksInMonth: Math.ceil((firstDay + daysInMonth) / 7)
                                      * 7

  readonly property var weekdays: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

  Text {
    text: Qt.formatDate(root.today, "dddd, dd MMMM")
    color: Theme.colText
    font: Theme.titleFont
    Layout.fillWidth: true
  }

  GridLayout {
    columns: 7

    Repeater {
      model: 7

      Text {
        required property int index

        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter

        text: root.weekdays[(index + GlobalStates.weekStart) % 7]

        color: Theme.colText
        font: Theme.mainFont
      }
    }

    Repeater {
      model: root.weeksInMonth

      Rectangle {
        id: cell
        required property int index

        Layout.fillWidth: true
        Layout.preferredHeight: 40

        readonly property int day: index - root.firstDay + 1

        readonly property bool valid: day > 0 && day <= root.daysInMonth
        readonly property date dateValue: valid ? new Date(root.year, root.month,
                                                           day) : new Date(0)

        readonly property bool isToday: valid && dateValue.toDateString() === (
                                          new Date()).toDateString()
        readonly property bool isSelected: valid && dateValue.toDateString()
                                           === root.today.toDateString()

        border.width: (isSelected || isToday) ? 2 : 0
        border.color: isSelected ? Theme.colOverlay2 : (isToday
                                                        ? Theme.colOverlay0 :
                                                          "transparent")
        radius: 4

        color: area.containsMouse ? Theme.colSurface0 : "transparent"

        Text {
          anchors.centerIn: cell
          visible: cell.valid
          text: cell.day
          color: Theme.colText
          font: Theme.mainFont
        }
        MouseArea {
          id: area
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
          onClicked: root.today = cell.dateValue
        }
      }
    }
  }
}
