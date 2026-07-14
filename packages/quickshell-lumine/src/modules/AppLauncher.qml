pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import ".."
import "../components"
import "../utils/LauncherUtils.js" as Utils

Rectangle {
  id: root
  radius: Theme.radius
  color: Theme.colSurface0

  property var allApps: Utils.getAllApps(DesktopEntries.applications.values)
  property var filteredApps: Utils.getFilteredApps(allApps,
                                                   searchInput.text.trim())

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Theme.spacing
    spacing: Theme.spacing

    RowLayout {
      Layout.fillWidth: true
      spacing: Theme.spacing

      TextField {
        id: searchInput
        Layout.fillWidth: true
        placeholderText: "type to filter"
        color: Theme.text
        font: Theme.mainFont

        background: Rectangle {
          color: Theme.colSurface1
          radius: Theme.radius / 2
        }

        focus: true

        onVisibleChanged: {
          if (visible) {
            text = "";
            appList.currentIndex = 0;
            forceActiveFocus();
          }
        }

        Keys.onEscapePressed: GlobalStates.launcherVisible = false
        Keys.onUpPressed: {
          appList.decrementCurrentIndex();
          if (appList.currentIndex > 0)
          appList.positionViewAtIndex(appList.currentIndex - 1,
                                      ListView.Contain);
        }
        Keys.onDownPressed: {
          appList.incrementCurrentIndex();
          if (appList.currentIndex < appList.count - 1)
          appList.positionViewAtIndex(appList.currentIndex + 1,
                                      ListView.Contain);
        }
        Keys.onReturnPressed: {
          if (root.filteredApps.length > 0) {
            root.filteredApps[appList.currentIndex].execute();
            GlobalStates.launcherVisible = false;
          }
        }
      }

      Text {
        text: (appList.count > 0 ? appList.currentIndex + 1 : 0) + "/"
              + appList.count

        color: Theme.colSubtext0
        font: Theme.smallFont
      }
    }

    Rectangle {
      Layout.fillWidth: true
      implicitHeight: 2
      color: Theme.colSapphire
    }

    ListView {
      id: appList
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true

      model: root.filteredApps

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton

        onWheel: wheel => {
          if (wheel.angleDelta.y > 0) {
            appList.decrementCurrentIndex();
            if (appList.currentIndex > 0)
              appList.positionViewAtIndex(appList.currentIndex - 1,
                                          ListView.Contain);
          } else if (wheel.angleDelta.y < 0) {
            appList.incrementCurrentIndex();
            if (appList.currentIndex < appList.count - 1)
              appList.positionViewAtIndex(appList.currentIndex + 1,
                                          ListView.Contain);
          }
        }
      }

      ScrollBar.vertical: ScrollBar {
        active: true
        policy: ScrollBar.AsNeeded

        contentItem: Rectangle {
          implicitWidth: 4
          radius: 2
          color: Theme.colSurface2
        }
      }

      delegate: LauncherItem {
        width: ListView.view.width - 8
        isCurrentItem: ListView.isCurrentItem
      }
    }
  }
}
