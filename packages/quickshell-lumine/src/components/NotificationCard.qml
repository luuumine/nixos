import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

import ".."

Rectangle {
  id: card
  required property var modelData

  Timer {
    running: card.modelData.urgency !== NotificationUrgency.Critical
    interval: 5000 // 5000ms
    onTriggered: {
      GlobalStates.hasUnread = true;
      card.modelData.dismiss();
    }
  }

  Layout.fillWidth: true
  Layout.preferredHeight: layout.implicitHeight + Theme.padding
  radius: Theme.radius
  color: Theme.colSurface0

  border.width: 2
  border.color: modelData.urgency === NotificationUrgency.Critical
                ? Theme.colRed : Theme.secondary

  visible: !GlobalStates.menuVisible

  RowLayout {
    id: layout
    anchors.fill: parent
    anchors.margins: Theme.spacing
    spacing: Theme.spacing

    Image {
      Layout.preferredHeight: Theme.notifIconSize
      Layout.preferredWidth: Theme.notifIconSize
      Layout.alignment: Qt.AlignTop
      fillMode: Image.PreserveAspectFit
      visible: source.toString() !== ""
      source: card.modelData.image || card.modelData.appIcon || ""
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2

      Text {
        Layout.fillWidth: true
        text: card.modelData.summary
        color: Theme.colText
        font: Theme.cardTitleFont
      }

      Text {
        Layout.fillWidth: true
        text: card.modelData.body
        visible: text !== ""
        color: Theme.colSubtext0
        font: Theme.smallFont
        wrapMode: Text.WordWrap
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: function (mouse) {
      if (mouse.button === Qt.RightButton) {
        card.modelData.dismiss();
      } else if (mouse.button === Qt.LeftButton) {
        let actionList = card.modelData.actions;
        let totalActions = actionList.length || actionList.count || 0;
        let triggered = false;

        for (let i = 0; i < totalActions; i++) {
          let action = actionList[i];
          if (action && action.identifier === "default") {
            action.invoke();
            triggered = true;
            break;
          }
        }

        if (!triggered) {
          card.modelData.dismiss();
        }
      }
    }
  }
}
