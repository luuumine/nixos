import QtQuick
import Quickshell.Hyprland

import ".."

Row {
  id: root
  spacing: Theme.spacing

  Repeater {
    model: 9

    Text {
      required property int index
      property int wsId: index + 1

      property var workspaceData: Hyprland.workspaces.values.find(w => w.id
                                                                  === wsId)

      property bool isActive: Hyprland.focusedWorkspace
                              && Hyprland.focusedWorkspace.id === wsId

      property bool isOccupied: workspaceData !== undefined

      text: wsId
      font {
        family: Theme.fontFamily
        pixelSize: Theme.fontSize
        bold: isOccupied
      }

      color: {
        if (isActive)
          return Theme.primary;
        if (isOccupied)
          return Theme.secondary;
        return Theme.dim;
      }
    }
  }
}
