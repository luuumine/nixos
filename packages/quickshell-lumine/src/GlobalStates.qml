pragma Singleton
import QtQuick

QtObject {
  property bool menuVisible: false
  property bool launcherVisible: false
  property bool hasUnread: false

  property int weekStart: 1 // Monday
}
