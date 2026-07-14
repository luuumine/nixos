import QtQuick
import Quickshell.Hyprland

import ".."

Item {
  id: root

  GlobalShortcut {
    name: "openLauncher"
    description: "open the launcher"

    onPressed: GlobalStates.launcherVisible = true
  }
}
