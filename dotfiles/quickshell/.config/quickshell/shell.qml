pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    // Theme — Catppuccin Mocha
    property color colRosewater: "#f5e0dc"
    property color colFlamingo: "#f2cdcd"
    property color colPink: "#f5c2e7"
    property color colMauve: "#cba6f7"
    property color colRed: "#f38ba8"
    property color colMaroon: "#eba0ac"
    property color colPeach: "#fab387"
    property color colYellow: "#f9e2af"
    property color colGreen: "#a6e3a1"
    property color colTeal: "#94e2d5"
    property color colSky: "#89dceb"
    property color colSapphire: "#74c7ec"
    property color colBlue: "#89b4fa"
    property color colLavender: "#b4befe"

    property color colText: "#cdd6f4"
    property color colSubtext1: "#bac2de"
    property color colSubtext0: "#a6adc8"

    property color colOverlay2: "#9399b2"
    property color colOverlay1: "#7f849c"
    property color colOverlay0: "#6c7086"

    property color colSurface2: "#585b70"
    property color colSurface1: "#45475a"
    property color colSurface0: "#313244"

    property color colBase: "#1e1e2e"
    property color colMantle: "#181825"
    property color colCrust: "#11111b"
    property string fontFamily: "DejaVuSansMono"
    property int fontSize: 16

    // System data
    property int cpuUsage: 0
    property int memUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var p = data.trim().split(/\s+/);
                var idle = parseInt(p[4]) + parseInt(p[5]);
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
                if (root.lastCpuTotal > 0) {
                    root.cpuUsage = Math.round(100 * (1 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal)));
                }
                root.lastCpuTotal = total;
                root.lastCpuIdle = idle;
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var parts = data.trim().split(/\s+/);
                var total = parseInt(parts[1]) || 1;
                var used = parseInt(parts[2]) || 0;
                root.memUsage = Math.round(100 * used / total);
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true;
            memProc.running = true;
        }
    }
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    color: root.colBase

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // Workspaces
        Repeater {
            model: 9
            Text {
                id: wsText
                required property int index
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                text: index + 1
                color: isActive ? root.colPink : (ws ? root.colLavender : root.colOverlay0)
                font {
                    family: root.fontFamily
                    pixelSize: root.fontSize
                    bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (wsText.index + 1))
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // Clock
        Text {
            id: clock
            color: root.colPink
            font {
                family: root.fontFamily
                pixelSize: root.fontSize
                bold: true
            }
            text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // CPU
        Text {
            text: "CPU: " + root.cpuUsage + "%"
            color: root.colYellow
            font {
                family: root.fontFamily
                pixelSize: root.fontSize
                bold: true
            }
        }

        Rectangle {
            implicitWidth: 1
            implicitHeight: 16
            color: root.colOverlay0
        }

        // Memory
        Text {
            text: "Mem: " + root.memUsage + "%"
            color: root.colTeal
            font {
                family: root.fontFamily
                pixelSize: root.fontSize
                bold: true
            }
        }
    }
}
