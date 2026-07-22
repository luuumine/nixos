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

  GlobalShortcut {
    name: "openMenu"
    description: "open the menu"
    onPressed: GlobalStates.menuVisible = true
  }

  GlobalShortcut {
    name: "closeMenu"
    description: "close the menu"
    onPressed: GlobalStates.menuVisible = false
  }

  GlobalShortcut {
    name: "toggleMenu"
    description: "toggle the menu"
    onPressed: GlobalStates.menuVisible = !GlobalStates.menuVisible
  }
}
