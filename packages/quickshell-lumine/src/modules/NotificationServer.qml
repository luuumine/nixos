import QtQuick
import Quickshell.Services.Notifications

import ".."

NotificationServer {
  id: server
  property ListModel history: ListModel {}

  actionsSupported: true
  bodySupported: true
  imageSupported: true

  property Connections _stateListener: Connections {
    target: GlobalStates

    function onMenuVisibleChanged() {
      let activePopups = server.trackedNotifications.values;

      while (activePopups.length > 0)
        activePopups[0].tracked = false;

      GlobalStates.hasUnread = false;
    }
  }

  onNotification: function (n) {
    history.insert(0, {
                     summary: n.summary,
                     body: n.body,
                     appName: n.appName,
                     urgency: n.urgency,
                     time: Qt.formatDateTime(new Date(), "HH:mm")
                   });
    n.tracked = true;
  }
}
