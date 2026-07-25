pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import ".."

ColumnLayout {
  id: root
  Layout.fillWidth: true
  spacing: Theme.spacing

  property date today: new Date()

  property int viewYear: today.getFullYear()
  property int viewMonth: today.getMonth()

  readonly property int daysInMonth: new Date(viewYear, viewMonth + 1,
                                              0).getDate()

  readonly property int firstDay: (new Date(viewYear, viewMonth, 1).getDay()
                                   - GlobalStates.weekStart + 7) % 7

  readonly property int weeksInMonth: Math.ceil((firstDay + daysInMonth) / 7)
                                      * 7

  readonly property var weekdays: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

  RowLayout {
    Layout.fillWidth: true
    Text {
      text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1),
                          "MMMM yyyy")
      color: Theme.colText
      font: Theme.titleFont
      Layout.fillWidth: true
    }

    Row {
      id: buttonRow
      spacing: Theme.spacing

      Rectangle {
        height: 20
        width: 20
        color: "transparent"
        Text {
          anchors.centerIn: parent
          text: ""
          color: refreshArea.containsMouse ? Theme.primary : Theme.colText
          font: Theme.titleFont
        }
        MouseArea {
          id: refreshArea
          hoverEnabled: true
          anchors.fill: parent
          onClicked: {
            root.viewMonth = root.today.getMonth();
            root.viewYear = root.today.getFullYear();
          }
          cursorShape: Qt.PointingHandCursor
        }
      }
      Rectangle {
        height: 20
        width: 20
        color: "transparent"
        Text {
          anchors.centerIn: parent
          text: ""
          color: previousMonthArea.containsMouse ? Theme.primary : Theme.colText
          font: Theme.titleFont
        }
        MouseArea {
          id: previousMonthArea
          hoverEnabled: true
          anchors.fill: parent
          onClicked: {
            if (root.viewMonth == 0) {
              root.viewMonth = 11;
              root.viewYear--;
            } else {
              root.viewMonth--;
            }
          }
          cursorShape: Qt.PointingHandCursor
        }
      }
      Rectangle {
        height: 20
        width: 20
        color: "transparent"
        Text {
          anchors.centerIn: parent
          text: ""
          color: nextMonthArea.containsMouse ? Theme.primary : Theme.colText
          font: Theme.titleFont
        }
        MouseArea {
          id: nextMonthArea
          hoverEnabled: true
          anchors.fill: parent
          onClicked: {
            if (root.viewMonth == 11) {
              root.viewMonth = 0;
              root.viewYear++;
            } else {
              root.viewMonth++;
            }
          }
          cursorShape: Qt.PointingHandCursor
        }
      }
    }
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
        readonly property date dateValue: valid ? new Date(root.viewYear,
                                                           root.viewMonth, day) :
                                                  new Date(0)

        readonly property bool isToday: valid && dateValue.toDateString() === (
                                          new Date()).toDateString()
        readonly property bool isSelected: valid && dateValue.toDateString()
                                           === root.today.toDateString()

        border.width: 2
        border.color: isToday ? Theme.colOverlay2 : "transparent"
        radius: 4

        color: "transparent"

        Text {
          anchors.centerIn: cell
          visible: cell.valid
          text: cell.day
          color: Theme.colText
          font: Theme.mainFont
        }
      }
    }
  }
}
