import QtQuick
import Quickshell

import "layout"
import "modules"

Scope {

  Shortcuts {}

  NotificationServer {
    id: notifserver
  }

  Variants {
    model: Quickshell.screens
    delegate: TopBar {
      required property var modelData
      targetScreen: modelData
    }
  }

  Menu {
    id: mainMenu
    notificationsList: notifserver.history
  }

  NotificationsPopups {
    notifications: notifserver.trackedNotifications
  }

  Launcher {
    id: launcher
  }
}
