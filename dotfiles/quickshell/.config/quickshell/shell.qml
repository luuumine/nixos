import QtQuick
import Quickshell

import "layout"

Scope {
  Variants {
    model: Quickshell.screens
    delegate: TopBar {
      required property var modelData
      targetScreen: modelData
    }
  }
}
