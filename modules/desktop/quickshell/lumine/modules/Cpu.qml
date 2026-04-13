import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import ".."

Item {
  id: root

  implicitWidth: layout.implicitWidth
  implicitHeight: layout.implicitHeight

  property int usage: 0
  property int temp: 0

  property int lastIdle: 0
  property int lastTotal: 0

  RowLayout {
    id: layout
    anchors.centerIn: parent
    spacing: 0

    Text {
      color: Theme.colText
      font: Theme.barFont
      text: "CPU:"
    }

    Text {
      color: Theme.colText
      font: Theme.barFont
      text: String(root.usage).padStart(3, " ") + "%"
    }

    Text {
      font: Theme.barFont
      text: String(root.temp).padStart(3, " ") + "°C"
      color: {
        if (root.temp >= Theme.tempCrit)
          return Theme.colCrit;
        if (root.temp >= Theme.tempErr)
          return Theme.colErr;
        if (root.temp >= Theme.tempWarn)
          return Theme.colWarn;
        if (root.temp >= Theme.tempOk)
          return Theme.colOk;
        return Theme.colNormal;
      }
    }
  }

  Process {
    id: usageProc
    running: true

    command: ["head", "-n1", "/proc/stat"]

    stdout: SplitParser {
      onRead: data => {
                var p = data.trim().split(/\s+/);
                var idle = parseInt(p[4]);
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
                if (root.lastTotal > 0) {
                  var timeIdle = idle - root.lastIdle;
                  var timeTotal = total - root.lastTotal;
                  root.usage = Math.round(100 * (1 - timeIdle / timeTotal));
                }
                root.lastTotal = total;
                root.lastIdle = idle;
              }
    }
  }

  Process {
    id: tempProc
    running: true

    command: ["sh", "-c", "for i in /sys/class/hwmon/hwmon*; do "
      + "grep -qE 'k10temp|coretemp' \"$i/name\" && "
      + "{ cat \"$i/temp1_input\"; break; }; done"]

    stdout: SplitParser {
      onRead: data => {
                var raw = parseInt(data.trim());
                if (!isNaN(raw)) {
                  root.temp = Math.round(raw / 1000);
                }
              }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      usageProc.running = true;
      tempProc.running = true;
    }
  }
}
